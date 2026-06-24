## 1. Data layer (DAO + Providers)

- [x] 1.1 Adicionar query no `BooksDao` que faz LEFT JOIN `books` + `reading_progress` retornando lista de tuplas `(Book, ReadingProgressData?)`  para o servidor ativo, evitando N+1
- [x] 1.2 Criar `lib/features/library/providers/library_providers.dart` com `libraryBooksProvider` (StreamProvider derivado do servidor ativo) e `libraryFilterProvider` (StateProvider com enum `LibraryFilter`: all, reading, downloaded, bySeries)
- [x] 1.3 Criar provider `filteredBooksProvider` que aplica o filtro selecionado sobre a lista de livros (filtra lendo/baixados, ou agrupa por série)

## 2. BookCard widget

- [x] 2.1 Criar `lib/features/library/presentation/book_card.dart` — widget stateless que recebe `Book` e `ReadingProgressData?`, exibe capa com `CachedNetworkImage` (auth headers do servidor), título (2 linhas), autor (1 linha), e `LinearProgressIndicator` quando há progresso
- [x] 2.2 Implementar placeholder para capa nula ou falha de carregamento (ícone de livro com fundo `surfaceContainerHighest`)
- [x] 2.3 Adicionar `ShimmerBox` como placeholder durante loading da imagem

## 3. LibraryScreen

- [x] 3.1 Reescrever `library_screen.dart` — scaffold com `AppBar` título "Biblioteca", body com `RefreshIndicator` + `CustomScrollView` contendo chips e grid
- [x] 3.2 Implementar barra de chips de filtro horizontais (Todos / Lendo / Baixados / Por Série) como `SliverToBoxAdapter` com `SingleChildScrollView` horizontal de `FilterChip`
- [x] 3.3 Implementar o grid de livros como `SliverGrid` de 2 colunas renderizando `BookCard`, com tap navegando para `/library/book/:id`
- [x] 3.4 Implementar estado de loading (shimmer grid com 8 placeholders) quando provider está carregando
- [x] 3.5 Implementar estado vazio com `EmptyStateView` quando lista de livros está vazia
- [x] 3.6 Implementar estado de erro com `ErrorStateView` e botão retry
- [x] 3.7 Implementar pull-to-refresh: lê servidor ativo + credenciais do `SecureCredentialStore`, chama `OpdsClient.fetchCatalog()`, passa para `LibrarySyncService.sync()`, exibe snackbar em caso de erro

## 4. Filtro "Por Série"

- [x] 4.1 Quando filtro "Por Série" está ativo, renderizar livros agrupados com headers de seção (nome da série) usando `SliverList` com separadores — livros sem série agrupados sob "Sem série" no final

## 5. Validação

- [x] 5.1 Verificar que o app compila sem erros (`flutter analyze`)
- [x] 5.2 Testar com o container Calibre-Web local: confirmar que grid exibe livros, pull-to-refresh sincroniza, chips filtram, e tap navega para detalhe
