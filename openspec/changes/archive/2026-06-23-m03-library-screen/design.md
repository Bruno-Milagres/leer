## Context

M01 e M02 entregaram: tema Material You, navegação com `go_router`, drift schema (servers, books, reading_progress, annotations), DAOs, `OpdsClient`, `LibrarySyncService`, e widgets compartilhados (`ShimmerBox`, `EmptyStateView`, `ErrorStateView`). A `LibraryScreen` é um placeholder. O router já redireciona para `/onboarding` quando não há servidor e para `/library` quando há.

O banco tem livros indexados por `serverId` + `calibreId`. O `BooksDao` expõe `watchByServer(serverId)` e `watchDownloaded()`. O `ReadingProgressDao` expõe `watchForBook(bookId)`.

## Goals / Non-Goals

**Goals:**
- Grid responsivo de livros com capa, título, autor e progresso
- Chips de filtro rápido no topo (Todos, Lendo, Baixados, Por Série)
- Pull-to-refresh que sincroniza o catálogo OPDS do servidor ativo
- Estados de loading (shimmer), empty e error integrados
- Provider layer com Riverpod que reage ao servidor ativo e filtros

**Non-Goals:**
- Drawer de filtro lateral (planejado, mas adiado — chips cobrem o MVP)
- Badge de fonte (M03 trabalha com servidor único; multi-fonte vem no M09)
- Busca textual (será avaliado no M11 Polish)
- Ordenação (título, autor, recentes) — chips já permitem agrupamento por série

## Decisions

### 1. Riverpod providers como camada reativa

A tela assiste 3 providers:
- `activeServerProvider` (já existe) — determina se há servidor e qual é
- `libraryBooksProvider` — `StreamProvider` que assiste `booksDao.watchByServer(serverId)`, derivado do servidor ativo
- `libraryFilterProvider` — `StateProvider<LibraryFilter>` com enum (all, reading, downloaded, bySeries)

O grid se reconstrói quando o servidor ativo muda, quando livros são sincronizados ou quando o filtro muda.

**Alternativa descartada**: FutureProvider com refresh manual — perde a reatividade do stream do drift.

### 2. BookCard como widget stateless com aspect ratio fixo

O card tem proporção de capa de livro (~2:3). Usa `CachedNetworkImage` para a capa com placeholder shimmer. Título truncado em 2 linhas, autor em 1 linha. Se houver `ReadingProgress`, exibe `LinearProgressIndicator` na base do card.

O card recebe um `Book` e um `ReadingProgressData?` — não faz query própria. A tela busca o progresso junto, evitando N+1 de providers.

**Alternativa descartada**: `FutureBuilder` por card para progresso — causaria rebuild cascata e queries duplicadas.

### 3. Sync via pull-to-refresh

O pull-to-refresh dispara:
1. Lê servidor ativo + credenciais do `SecureCredentialStore`
2. Chama `OpdsClient.fetchCatalog()`
3. Passa resultado para `LibrarySyncService.sync()`
4. O stream do drift notifica automaticamente o grid

O RefreshIndicator encapsula o body inteiro. Erros no sync são exibidos via `ScaffoldMessenger.showSnackBar`.

### 4. Shimmer grid como estado de loading

Quando `libraryBooksProvider` está em estado loading, exibe um grid de 8 `ShimmerBox` cards (usando `AppTokens.shimmerPlaceholderCount`) com a mesma proporção do `BookCard` — reutiliza o `ShimmerBox` de M01.

## Risks / Trade-offs

- **[Risk]** Lista grande de livros (500+) pode ficar lenta com grid de imagens.
  → **Mitigation**: `SliverGrid` + `CachedNetworkImage` com cache de disco. Suficiente para v1. Paginação fica para M11 se necessário.

- **[Trade-off]** Filtro "Por Série" agrupa livros in-memory no provider, sem SQL dedicado.
  → Aceitável para catálogos até ~1000 livros. Se escalar, migrar para query drift com GROUP BY.

- **[Risk]** Progresso de leitura precisa de join com `reading_progress` — pode ser N+1.
  → **Mitigation**: Criar query no DAO que faz LEFT JOIN books + reading_progress retornando tupla. Evita N queries.
