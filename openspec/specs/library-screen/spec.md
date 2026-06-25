# library-screen

Tela principal de biblioteca do app Leer.

## Requirements

### Requirement: Grid de livros com 2 colunas

A tela de biblioteca SHALL exibir os livros de todas as fontes ativas em um grid de 2 colunas. Cada card SHALL exibir: capa do livro (imagem remota com cache para Calibre, imagem local para pasta), título (máximo 2 linhas, truncado com ellipsis), autor (máximo 1 linha), barra de progresso de leitura quando houver progresso registrado, e badge de fonte quando há múltiplas fontes ativas.

#### Scenario: Múltiplas fontes ativas com livros
- **WHEN** existem fontes ativas com livros indexados
- **THEN** a tela exibe um grid de 2 colunas com todos os livros de todas as fontes, ordenados por título

#### Scenario: Livro com progresso de leitura
- **WHEN** um livro possui registro em `reading_progress` com percentage > 0
- **THEN** o card exibe um `LinearProgressIndicator` na base com o percentual

#### Scenario: Livro sem progresso de leitura
- **WHEN** um livro não possui registro em `reading_progress`
- **THEN** o card não exibe barra de progresso

#### Scenario: Livro sem capa
- **WHEN** o campo `coverUrl` do livro é nulo
- **THEN** o card exibe um placeholder com ícone de livro

#### Scenario: Badge de fonte com múltiplas fontes
- **WHEN** há mais de uma fonte ativa
- **THEN** cada card exibe um badge discreto indicando a fonte (ícone Calibre / pasta)

#### Scenario: Fonte única ativa
- **WHEN** há apenas uma fonte ativa
- **THEN** os cards não exibem badge de fonte

### Requirement: Capa com cache de imagem

A capa dos livros SHALL ser carregada via `CachedNetworkImage` com autenticação para livros de Calibre, ou via `Image.file` para livros de pasta local (capa extraída em cache). Enquanto a imagem carrega, SHALL exibir um shimmer placeholder.

#### Scenario: Capa de livro Calibre carregando
- **WHEN** a imagem da capa de um livro Calibre ainda está sendo baixada
- **THEN** o card exibe um `ShimmerBox` no lugar da capa

#### Scenario: Capa de livro local
- **WHEN** o livro é de pasta local e possui capa extraída em cache
- **THEN** a capa é carregada do arquivo local sem shimmer

#### Scenario: Falha no carregamento da capa
- **WHEN** a imagem falha ao carregar (rede, 404, etc.)
- **THEN** o card exibe o mesmo placeholder de ícone usado quando `coverUrl` é nulo

### Requirement: Chips de filtro horizontais

A tela SHALL exibir chips de filtro em uma barra horizontal com scroll acima do grid. Os filtros disponíveis SHALL ser: Todos, Lendo, Baixados, Por Série, Por Fonte. O chip ativo SHALL ter estilo visual diferenciado (filled vs outlined).

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

#### Scenario: Filtro "Por Fonte" selecionado
- **WHEN** o usuário toca no chip "Por Fonte"
- **THEN** os livros são agrupados pela fonte de origem, com header mostrando o nome da fonte

### Requirement: Pull-to-refresh sincroniza catálogo

A tela SHALL suportar pull-to-refresh que dispara sincronização de todas as fontes ativas em paralelo. Para fontes Calibre, SHALL usar OPDS com credenciais. Para fontes de pasta local, SHALL re-varrer a pasta.

#### Scenario: Refresh bem-sucedido com múltiplas fontes
- **WHEN** o usuário puxa a tela para baixo e todas as fontes respondem
- **THEN** todas as fontes são sincronizadas, o grid é atualizado, e o indicador desaparece

#### Scenario: Refresh com uma fonte falhando
- **WHEN** o refresh falha para uma fonte mas sucede para outras
- **THEN** um snackbar exibe o erro da fonte que falhou; as demais atualizam normalmente

#### Scenario: Refresh com credenciais inválidas
- **WHEN** uma fonte Calibre retorna 401 durante o refresh
- **THEN** um snackbar exibe "Credenciais inválidas" para aquela fonte

### Requirement: Estado de carregamento com shimmer

A tela SHALL exibir um grid de placeholders shimmer enquanto os livros estão sendo carregados pela primeira vez (provider em estado loading).

#### Scenario: Primeiro carregamento
- **WHEN** os livros estão carregando (stream ainda não emitiu dados)
- **THEN** a tela exibe 8 cards de shimmer no grid de 2 colunas

### Requirement: Estado vazio

A tela SHALL exibir o `EmptyStateView` quando nenhuma fonte ativa possui livros. A mensagem SHALL orientar o usuário a adicionar livros ou configurar uma fonte.

#### Scenario: Biblioteca vazia com fontes ativas
- **WHEN** as fontes ativas não possuem livros
- **THEN** a tela exibe "Nenhum livro encontrado" com ícone e sugestão de pull-to-refresh

#### Scenario: Nenhuma fonte configurada
- **WHEN** não há fontes cadastradas
- **THEN** o redirect para onboarding é acionado (não chega nesta tela)

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
