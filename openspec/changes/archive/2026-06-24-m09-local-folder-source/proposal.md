## Why

O SPEC v0.2 introduz a arquitetura de múltiplas fontes de biblioteca (seção 4). Hoje o app é Calibre-only: banco, sync e UI estão acoplados a `servers`/OPDS. Para permitir que o usuário leia EPUBs de uma pasta local — sem precisar de um servidor — o app precisa da abstração `LibrarySource` e de uma implementação `LocalFolderSource`. Isso também prepara o terreno para fontes futuras (WebDAV, Drive) sem retrabalho.

## What Changes

- Criar interface `LibrarySource` (`listBooks`, `fetchBook`, `fetchCover`, `testConnection`) conforme seção 4 do SPEC
- Implementar `CalibreSource` encapsulando o código OPDS existente atrás da nova interface
- Implementar `LocalFolderSource`: varredura recursiva de `.epub` numa pasta, extração de metadados via OPF (`content.opf` dentro do EPUB)
- Criar `LibraryRepository` que agrega livros de todas as fontes ativas
- **BREAKING**: migrar schema drift de `servers` para `sources` (nova tabela com campo `type`: `calibre` | `localFolder`), schemaVersion 1→2
- Atualizar `Books` para referenciar `sources` em vez de `servers`, trocar `calibreId`/`opdsDownloadUrl` por campos genéricos (`externalId`, `downloadUrl`)
- Adaptar a UI de Settings/Sources para cadastrar tanto Calibre-Web quanto pasta local
- Adaptar Library Screen para agregar livros de múltiplas fontes ativas e exibir badge de fonte
- Adaptar Book Detail para ocultar botão "Baixar" em livros de pasta local (já são locais)

## Capabilities

### New Capabilities
- `local-folder-source`: Varredura de pasta local, extração de metadados OPF do EPUB, indexação de livros locais
- `library-sources`: Abstração `LibrarySource`, `CalibreSource`, `LibraryRepository`, agregação multi-fonte

### Modified Capabilities
- `settings-sources`: Gestão genérica de fontes (Calibre + pasta local) em vez de apenas servidores
- `library-screen`: Agregação de livros de múltiplas fontes ativas, badge de fonte nos cards
- `book-detail`: Origem do livro exibida, botão de download adaptado para livros locais
- `downloads-screen`: Filtra apenas livros de Calibre (livros locais já são offline por natureza)

## Impact

- **Banco de dados**: migração destrutiva de `servers` → `sources` e refatoração de `books` (FK + campos renomeados). SchemaVersion 2.
- **Providers**: substituir `activeServerProvider` por `activeSourcesProvider` (agora multi-fonte). Todos os consumers que dependem do servidor ativo precisam adaptar.
- **core/opds/**: `LibrarySyncService` passa a ser específico de `CalibreSource`. `OpdsClient` não muda.
- **Dependências**: `archive` (pub.dev) para descompactar EPUB e ler `content.opf` in-memory. `file_picker` já está no pubspec.
- **Navegação**: rotas `/settings/server` → `/settings/sources` e `/settings/sources/add`.
