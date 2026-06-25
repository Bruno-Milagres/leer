## ADDED Requirements

### Requirement: Interface LibrarySource
O sistema SHALL definir uma interface `LibrarySource` com os métodos: `listBooks()`, `fetchBook(Book)`, `fetchCover(Book)`, `testConnection()` e as propriedades `id`, `displayName`, `type`. Todas as fontes de biblioteca SHALL implementar esta interface.

#### Scenario: CalibreSource implementa LibrarySource
- **WHEN** uma fonte do tipo `calibre` é usada
- **THEN** o `CalibreSource` implementa `LibrarySource` usando o cliente OPDS existente

#### Scenario: LocalFolderSource implementa LibrarySource
- **WHEN** uma fonte do tipo `localFolder` é usada
- **THEN** o `LocalFolderSource` implementa `LibrarySource` usando varredura de pasta e extração OPF

### Requirement: CalibreSource encapsula OPDS
O `CalibreSource` SHALL encapsular a lógica existente de `OpdsClient` + `LibrarySyncService`. O `listBooks()` SHALL fazer fetch + parse do feed OPDS e retornar os livros. O `fetchBook()` SHALL baixar o EPUB via URL OPDS com autenticação básica.

#### Scenario: listBooks de CalibreSource
- **WHEN** `listBooks()` é chamado em um CalibreSource com servidor acessível
- **THEN** retorna a lista de livros parseada do feed OPDS

#### Scenario: fetchBook de CalibreSource
- **WHEN** `fetchBook()` é chamado para um livro de Calibre
- **THEN** o EPUB é baixado via `OpdsClient` e salvo localmente

#### Scenario: testConnection de CalibreSource
- **WHEN** `testConnection()` é chamado
- **THEN** valida o endpoint OPDS e retorna `true` se o feed é válido

### Requirement: LibraryRepository agrega fontes
O `LibraryRepository` SHALL agregar livros de todas as fontes ativas. O `watchAllBooks()` SHALL retornar um stream reativo combinando livros de todas as fontes ativas da tabela `sources`.

#### Scenario: Duas fontes ativas
- **WHEN** existem um CalibreSource e um LocalFolderSource ambos ativos
- **THEN** `watchAllBooks()` retorna livros de ambas as fontes combinados

#### Scenario: Fonte desativada
- **WHEN** uma fonte é desativada pelo usuário
- **THEN** seus livros deixam de aparecer no stream agregado

### Requirement: Refresh por fonte
O `LibraryRepository` SHALL suportar refresh individual por fonte ou refresh de todas as fontes ativas. O refresh de `CalibreSource` SHALL sincronizar via OPDS. O refresh de `LocalFolderSource` SHALL re-varrer a pasta.

#### Scenario: Refresh de todas as fontes
- **WHEN** o usuário faz pull-to-refresh na biblioteca
- **THEN** todas as fontes ativas são sincronizadas em paralelo

#### Scenario: Refresh de fonte individual
- **WHEN** o refresh é disparado para uma fonte específica
- **THEN** apenas essa fonte é sincronizada

### Requirement: Tabela sources substitui servers
O sistema SHALL usar a tabela `sources` (seção 6 do SPEC) em vez de `servers`. A tabela SHALL ter campo `type` (`calibre` | `localFolder`) e suportar múltiplas fontes ativas simultaneamente.

#### Scenario: Migração de servers para sources
- **WHEN** o app é atualizado de schemaVersion 1 para 2
- **THEN** servidores existentes são migrados para `sources` com `type = 'calibre'` preservando dados

#### Scenario: Múltiplas fontes ativas
- **WHEN** o usuário tem um CalibreSource e um LocalFolderSource ambos ativos
- **THEN** ambas as fontes contribuem livros para a biblioteca
