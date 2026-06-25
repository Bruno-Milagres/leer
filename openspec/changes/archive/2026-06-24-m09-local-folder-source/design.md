## Context

O Leer v0.1 funciona exclusivamente com Calibre-Web via OPDS. O banco usa a tabela `servers` com FK direta em `books.serverId`, e campos Calibre-específicos (`calibreId`, `opdsDownloadUrl`). O SPEC v0.2 (seção 4) exige que o app suporte múltiplas fontes de biblioteca via abstração `LibrarySource`, e a primeira fonte alternativa — pasta local — entra na v1 como M09.

O código existente que precisa ser refatorado: `tables.dart` (schema), `daos.dart`, `library_sync_service.dart`, `providers.dart` (activeServerProvider), `app_router.dart` (redirect de onboarding), e as telas de Settings, Library, Book Detail e Downloads.

## Goals / Non-Goals

**Goals:**
- Introduzir a abstração `LibrarySource` para desacoplar a UI/persistência de qualquer fonte específica.
- Implementar `LocalFolderSource` com varredura recursiva e extração de metadados OPF.
- Migrar o schema drift de `servers` para `sources` (schemaVersion 2) com migração automática de dados.
- Adaptar o fluxo de multi-fonte: múltiplas fontes ativas, agregação na biblioteca, badge de fonte.

**Non-Goals:**
- WebDAV, Google Drive ou outras fontes futuras — só a interface e as duas implementações v1.
- File watcher automático para pasta local — v1 usa refresh manual.
- Sync de progresso entre fontes — progresso é local por livro.
- Mover EPUB de uma fonte para outra.

## Decisions

### Abstração LibrarySource em core/sources/

Criar `lib/core/sources/` com:
- `library_source.dart` — classe abstrata com `id`, `displayName`, `type` (enum `SourceType { calibre, localFolder }`), `listBooks()`, `fetchBook()`, `fetchCover()`, `testConnection()`.
- `calibre_source.dart` — implementa `LibrarySource`, compõe `OpdsClient` + `OpdsParser`. Recebe a `Source` (tabela) e credenciais.
- `local_folder_source.dart` — implementa `LibrarySource`, usa `dart:io` para varredura e `archive` para leitura OPF.
- `library_repository.dart` — agrega fontes ativas, expõe `watchAllBooks()` (stream do drift filtrando por fontes ativas) e `refreshAll()`.

**Alternativa considerada**: manter `OpdsClient` diretamente na feature de library sem abstração. Rejeitada porque o SPEC exige que a UI seja fonte-agnóstica e que fontes futuras pluguem na mesma interface.

### Migração do schema drift: servers → sources

Nova tabela `Sources`:
```
id, type (TEXT: 'calibre'|'localFolder'), name, url (nullable), 
username (nullable), hasCredentials (bool), isActive (bool), createdAt
```

Tabela `Books` refatorada:
- `serverId` → `sourceId` (FK para `sources`)
- `calibreId` → `externalId` (TEXT — calibre_id para Calibre, hash do path relativo para local)
- `opdsDownloadUrl` → `downloadUrl` (TEXT nullable — URL OPDS para Calibre, path absoluto para local)

Migração (schemaVersion 1→2):
1. Criar tabela `sources` copiando dados de `servers` com `type = 'calibre'`, `hasCredentials = (username IS NOT NULL)`.
2. Renomear colunas em `books` (`serverId→sourceId`, `calibreId→externalId`, `opdsDownloadUrl→downloadUrl`).
3. Dropar tabela `servers`.

O drift suporta `m.createTable(sources)` + raw SQL para copiar dados + `m.deleteTable('servers')`.

**Alternativa considerada**: manter `servers` e criar `sources` como tabela separada. Rejeitada por criar redundância e complexidade — a migração é simples e o app é pré-lançamento (sem base de usuários).

### Extração de metadados EPUB via archive

Usar o pacote `archive` (pub.dev) para ler o EPUB como ZIP in-memory:
1. Ler `META-INF/container.xml` para localizar o `rootfile` (path do OPF).
2. Parsear o OPF (`content.opf`) via `xml` para extrair `dc:title`, `dc:creator`, `dc:language`, `dc:description`, e metadados Calibre (`calibre:series`, `calibre:series_index`).
3. Localizar o item de capa (`cover-image` property no manifest, ou `meta[name=cover]` → `content` referenciando item id).
4. Extrair a imagem de capa e salvar em `getApplicationCacheDirectory()/covers/<sourceId>_<hash>.jpg`.

**Alternativa considerada**: `epubx` ou `epub_parser`. Rejeitada por serem mais pesados e trazerem parsing de conteúdo completo — precisamos apenas do OPF.

### Multi-fonte ativa (toggle ao invés de radio)

A tabela `sources.isActive` muda de semântica: na v0.1, apenas um servidor podia ser ativo (radio button). Na v0.2, múltiplas fontes podem estar ativas (toggle). O `activeServerProvider` (stream de `Server?`) é substituído por `activeSourcesProvider` (stream de `List<Source>`).

O redirect de onboarding muda de `activeServer == null` para `sources.isEmpty` (não há nenhuma fonte cadastrada).

**Alternativa considerada**: manter radio (uma fonte ativa por vez). Rejeitada porque o SPEC diz explicitamente "Múltiplas fontes podem coexistir e ficar ativas simultaneamente" (seção 5.1).

### Cache de capas locais

Capas de livros locais são extraídas do EPUB e salvas em `getApplicationCacheDirectory()/covers/`. O `coverUrl` no banco aponta para o path local da capa (prefixo `file://` ou path absoluto). A UI detecta se é URL remota ou local pelo scheme.

**Por quê**: evitar re-extrair a capa do EPUB em cada renderização. O cache é invalidado quando a fonte é removida (cleanup do diretório por sourceId).

### SourcesDao substitui ServersDao

Novo `SourcesDao` com:
- `watchAll()` — stream de todas as fontes
- `watchActive()` — stream de fontes ativas (`isActive == true`), retorna `List<Source>`
- `insertSource(SourcesCompanion)` → `int`
- `updateSource(Source)` → `bool`
- `deleteSource(int id)` → cascade nos livros
- `toggleActive(int id, bool active)` — toggle individual

`BooksDao` adaptado:
- `watchByServer()` → `watchBySource(int sourceId)`
- `watchWithProgressByServer()` → `watchWithProgressBySource(int sourceId)`
- `getByCalibreId()` → `getByExternalId(int sourceId, String externalId)`
- Novo: `watchByActiveSources(List<int> sourceIds)` — usado pelo LibraryRepository
- Novo: `deleteBySourceNotIn(int sourceId, List<String> externalIds)` — para limpar livros removidos da pasta

## Risks / Trade-offs

- **Migração destrutiva em app pré-lançamento** → Aceitável por não haver base de usuários. Migração SQL é simples e testável.
- **Performance de varredura em pastas grandes** → Varredura é O(n) nos arquivos; extração OPF usa stream read do ZIP (não carrega o EPUB inteiro em memória). Para bibliotecas com centenas de EPUBs, isolar em `compute()` para não bloquear a UI.
- **Permissões de acesso à pasta (SAF no Android)** → `file_picker` retorna um path via SAF. Em Android 11+, o acesso persistido pode ser perdido. Tratar `FileSystemException` no refresh mostrando erro ao usuário para re-selecionar a pasta.
- **Metadados OPF inconsistentes** → Parser tolerante: título é obrigatório (fallback para nome do arquivo), demais campos são opcionais. EPUBs sem OPF são ignorados.
- **Mudança de `Server?` para `List<Source>` quebra providers dependentes** → Refatorar todos os consumers de `activeServerProvider` num passo atômico (task dedicada).

## Migration Plan

Ordem de implementação:
1. Schema drift + migração + DAOs (base para tudo)
2. Interface `LibrarySource` + `CalibreSource` (refatorar OPDS existente, sem quebrar funcionalidade)
3. `LocalFolderSource` + extração OPF (feature nova)
4. `LibraryRepository` + providers refatorados
5. UI de Settings/Sources (cadastro de fontes)
6. UI de Library (agregação multi-fonte, badge)
7. UI de Book Detail e Downloads (adaptações menores)

Rollback: reverter os commits do M09. O schemaVersion 2 não é retro-compatível com v1 — mas como o app é pré-lançamento, isso é aceitável.

## Open Questions

- **Persistência de permissão SAF**: o `file_picker` no Android 11+ pode não persistir acesso entre sessões. Validar se `getDirectoryPath()` retorna um path usável em cold starts, ou se é necessário usar `openDocumentTree` com `takePersistableUriPermission`.
- **Tamanho do EPUB para livros locais**: o `fileSizeKb` pode ser calculado via `File.lengthSync()` ou durante a varredura. Decidir se é calculado no scan ou lazy.
