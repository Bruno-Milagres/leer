## ADDED Requirements

### Requirement: Grid de livros com 2 colunas

A tela de biblioteca SHALL exibir os livros do servidor ativo em um grid de 2 colunas. Cada card SHALL exibir: capa do livro (imagem remota com cache), título (máximo 2 linhas, truncado com ellipsis), autor (máximo 1 linha) e barra de progresso de leitura quando houver progresso registrado.

#### Scenario: Servidor ativo com livros sincronizados
- **WHEN** o servidor ativo possui livros na tabela `books`
- **THEN** a tela exibe um grid de 2 colunas com um card por livro, ordenado por título

#### Scenario: Livro com progresso de leitura
- **WHEN** um livro possui registro em `reading_progress` com percentage > 0
- **THEN** o card exibe um `LinearProgressIndicator` na base com o percentual

#### Scenario: Livro sem progresso de leitura
- **WHEN** um livro não possui registro em `reading_progress`
- **THEN** o card não exibe barra de progresso

#### Scenario: Livro sem capa
- **WHEN** o campo `coverUrl` do livro é nulo
- **THEN** o card exibe um placeholder com ícone de livro

### Requirement: Capa com cache de imagem

A capa dos livros SHALL ser carregada via `CachedNetworkImage` com autenticação básica do servidor ativo. Enquanto a imagem carrega, SHALL exibir um shimmer placeholder.

#### Scenario: Capa carregando
- **WHEN** a imagem da capa ainda está sendo baixada
- **THEN** o card exibe um `ShimmerBox` no lugar da capa

#### Scenario: Capa carregada com sucesso
- **WHEN** a imagem é recebida com sucesso
- **THEN** a capa é exibida preenchendo o espaço do card com `BoxFit.cover`

#### Scenario: Falha no carregamento da capa
- **WHEN** a imagem falha ao carregar (rede, 404, etc.)
- **THEN** o card exibe o mesmo placeholder de ícone usado quando `coverUrl` é nulo

### Requirement: Chips de filtro horizontais

A tela SHALL exibir chips de filtro em uma barra horizontal com scroll acima do grid. Os filtros disponíveis SHALL ser: Todos, Lendo, Baixados, Por Série. O chip ativo SHALL ter estilo visual diferenciado (filled vs outlined).

#### Scenario: Filtro padrão ao abrir
- **WHEN** a tela de biblioteca é aberta
- **THEN** o chip "Todos" está selecionado e todos os livros são exibidos

#### Scenario: Filtro "Lendo" selecionado
- **WHEN** o usuário toca no chip "Lendo"
- **THEN** o grid exibe apenas livros com `reading_progress.percentage` entre 1 e 99

#### Scenario: Filtro "Baixados" selecionado
- **WHEN** o usuário toca no chip "Baixados"
- **THEN** o grid exibe apenas livros com `isDownloaded == true`

#### Scenario: Filtro "Por Série" selecionado
- **WHEN** o usuário toca no chip "Por Série"
- **THEN** os livros são agrupados por série, ordenados por `seriesIndex`, com um header de texto para cada série. Livros sem série aparecem ao final sob "Sem série"

### Requirement: Pull-to-refresh sincroniza catálogo

A tela SHALL suportar pull-to-refresh que dispara uma sincronização completa do catálogo OPDS do servidor ativo. O refresh SHALL usar as credenciais armazenadas no `SecureCredentialStore`.

#### Scenario: Refresh bem-sucedido
- **WHEN** o usuário puxa a tela para baixo e o servidor responde
- **THEN** o catálogo é sincronizado via `LibrarySyncService`, o grid é atualizado automaticamente via stream, e o indicador de refresh desaparece

#### Scenario: Refresh com servidor inacessível
- **WHEN** o usuário puxa a tela para baixo e o servidor não responde
- **THEN** o indicador de refresh desaparece e um snackbar exibe a mensagem de erro

#### Scenario: Refresh com credenciais inválidas
- **WHEN** o servidor retorna 401 durante o refresh
- **THEN** um snackbar exibe "Credenciais inválidas" e sugere verificar as configurações

### Requirement: Estado de carregamento com shimmer

A tela SHALL exibir um grid de placeholders shimmer enquanto os livros estão sendo carregados pela primeira vez (provider em estado loading).

#### Scenario: Primeiro carregamento
- **WHEN** os livros estão carregando (stream ainda não emitiu dados)
- **THEN** a tela exibe 8 cards de shimmer no grid de 2 colunas

### Requirement: Estado vazio

A tela SHALL exibir o `EmptyStateView` quando o servidor ativo não possui livros sincronizados. A mensagem SHALL orientar o usuário a adicionar livros ou sincronizar.

#### Scenario: Biblioteca vazia após sync
- **WHEN** o servidor ativo está acessível mas não possui livros no feed OPDS
- **THEN** a tela exibe "Nenhum livro encontrado" com ícone e sugestão de pull-to-refresh

### Requirement: Estado de erro

A tela SHALL exibir o `ErrorStateView` quando ocorre erro ao carregar os livros. O botão "Tentar novamente" SHALL disparar nova tentativa de sync.

#### Scenario: Erro no stream de livros
- **WHEN** o provider de livros emite um erro
- **THEN** a tela exibe `ErrorStateView` com mensagem e botão de retry

### Requirement: Navegação para detalhe do livro

O tap em um card de livro SHALL navegar para a tela de detalhe (`/library/book/:id`).

#### Scenario: Tap no card de livro
- **WHEN** o usuário toca em um card de livro
- **THEN** o app navega para `/library/book/{bookId}`
