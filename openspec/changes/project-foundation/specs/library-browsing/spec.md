## ADDED Requirements

### Requirement: Grid da biblioteca
O sistema SHALL exibir os livros do servidor ativo em um grid de 2 colunas, com a capa dominando cada card e exibindo título (máx 2 linhas), autor e barra de progresso quando a leitura foi iniciada.

#### Scenario: Renderização do grid
- **WHEN** existem livros sincronizados para o servidor ativo
- **THEN** a biblioteca exibe um grid de 2 colunas com os cards descritos

#### Scenario: Progresso no card
- **WHEN** um livro tem `reading_progress.percentage` maior que zero
- **THEN** o card exibe uma barra de progresso correspondente

### Requirement: Filtros de biblioteca
O sistema SHALL fornecer chips de filtro horizontais (Todos / Lendo / Baixados / Por Série) e um drawer lateral de filtro por autor, série, tag e status.

#### Scenario: Filtro por baixados
- **WHEN** o usuário seleciona o chip "Baixados"
- **THEN** o grid exibe apenas livros com `is_downloaded` verdadeiro

#### Scenario: Drawer de filtro por autor
- **WHEN** o usuário abre o drawer e escolhe um autor
- **THEN** o grid exibe apenas livros desse autor

### Requirement: Atualização e estados de carregamento
O sistema SHALL suportar pull-to-refresh para sincronizar com o servidor e exibir shimmer durante o carregamento e estado vazio quando não há livros.

#### Scenario: Pull-to-refresh
- **WHEN** o usuário puxa a lista para baixo
- **THEN** o app dispara uma sincronização OPDS e atualiza o grid ao concluir

#### Scenario: Estado vazio sem servidor
- **WHEN** não há servidor configurado
- **THEN** a biblioteca exibe um estado vazio com ilustração e CTA para configurar servidor

#### Scenario: Shimmer durante carregamento
- **WHEN** a biblioteca está carregando
- **THEN** exibe um grid de shimmer com 8 cards placeholder
