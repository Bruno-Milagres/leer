## 1. Schema drift — migração servers → sources

- [x] 1.1 Criar tabela `Sources` em `tables.dart` com campos: id, type, name, url (nullable), username (nullable), hasCredentials (bool), isActive (bool), createdAt
- [x] 1.2 Refatorar tabela `Books`: renomear `serverId` → `sourceId` (FK para Sources), `calibreId` → `externalId`, `opdsDownloadUrl` → `downloadUrl` (nullable)
- [x] 1.3 Implementar migração schemaVersion 1→2 em `AppDatabase`: criar `sources` com dados de `servers`, atualizar colunas em `books`, dropar `servers`
- [x] 1.4 Criar `SourcesDao` (watchAll, watchActive, insertSource, updateSource, deleteSource, toggleActive)
- [x] 1.5 Adaptar `BooksDao`: renomear métodos (`watchBySource`, `getByExternalId`, `watchByActiveSources`), adicionar `deleteBySourceNotIn` para cleanup de livros removidos
- [x] 1.6 Rodar `build_runner` e verificar que o app compila com o novo schema

## 2. Abstração LibrarySource

- [x] 2.1 Criar `lib/core/sources/library_source.dart` com classe abstrata e enum `SourceType`
- [x] 2.2 Criar `lib/core/sources/calibre_source.dart` encapsulando `OpdsClient` + `OpdsParser` + sync atrás da interface `LibrarySource`
- [x] 2.3 Criar `lib/core/sources/source_factory.dart` — factory que instancia `CalibreSource` ou `LocalFolderSource` a partir de um `Source` (tabela)

## 3. LocalFolderSource

- [x] 3.1 Adicionar dependência `archive` ao `pubspec.yaml`
- [x] 3.2 Criar `lib/core/sources/epub_metadata_extractor.dart`: leitura de container.xml → OPF → extração de título, autor, idioma, descrição, série, capa
- [x] 3.3 Criar `lib/core/sources/local_folder_source.dart` implementando `LibrarySource`: varredura recursiva de `.epub`, extração OPF, indexação no drift
- [x] 3.4 Implementar cache de capas: extrair imagem de capa do EPUB e salvar em `cacheDir/covers/<sourceId>_<hash>.ext`
- [x] 3.5 Implementar cleanup de livros removidos: no refresh, comparar EPUBs na pasta com entries no banco e remover ausentes

## 4. LibraryRepository e providers

- [x] 4.1 Criar `lib/core/sources/library_repository.dart`: agrega fontes ativas, expõe `watchAllBooks()` e `refreshAll()`
- [x] 4.2 Refatorar `providers.dart`: substituir `activeServerProvider` por `activeSourcesProvider` (Stream<List<Source>>), adicionar `libraryRepositoryProvider` e `sourceFactoryProvider`
- [x] 4.3 Adaptar `app_router.dart`: redirect de onboarding de `activeServer == null` para `sources.isEmpty`

## 5. UI — Settings / Sources

- [x] 5.1 Refatorar `ServerSettingsScreen` → `SourcesScreen`: listar fontes com ícone de tipo, nome, URL/caminho e toggle de ativo
- [x] 5.2 Implementar formulário de adição com escolha de tipo: "Calibre-Web" (formulário com nome/URL/user/senha + testar conexão) e "Pasta local" (file picker de diretório)
- [x] 5.3 Adaptar `SettingsScreen`: item "Fontes" com subtítulo mostrando contagem de fontes ativas
- [x] 5.4 Atualizar rotas: `/settings/server` → `/settings/sources`, adicionar `/settings/sources/add`

## 6. UI — Library Screen (multi-fonte)

- [x] 6.1 Refatorar `LibraryController` para usar `LibraryRepository.watchAllBooks()` em vez de `BooksDao.watchByServer()`
- [x] 6.2 Adicionar chip de filtro "Por Fonte" agrupando livros por nome da fonte
- [x] 6.3 Implementar badge de fonte nos cards quando há múltiplas fontes ativas
- [x] 6.4 Adaptar pull-to-refresh para chamar `LibraryRepository.refreshAll()`
- [x] 6.5 Adaptar carregamento de capas: `CachedNetworkImage` para Calibre, `Image.file` para livros locais

## 7. UI — Book Detail e Downloads

- [x] 7.1 Adaptar `BookDetailScreen`: exibir nome da fonte de origem, ocultar botão download para livros locais, botão "Ler" sempre habilitado para livros locais
- [x] 7.2 Adaptar `DownloadsScreen`: filtrar apenas livros de Calibre (`source.type == 'calibre'` e `isDownloaded == true`)

## 8. Verificação

- [x] 8.1 `flutter analyze` sem erros e `dart format` aplicado
- [x] 8.2 Smoke test manual: adicionar fonte Calibre → sync → ver livro na biblioteca (validado em dispositivo Android via adb reverse + Calibre-Web local)
