# downloads-screen

Tela de gestão de downloads offline do app Leer.

## Requirements

### Requirement: Lista de livros baixados

A tela de downloads SHALL exibir livros baixados de fontes Calibre (`isDownloaded == true` e `source.type == 'calibre'`). Livros de pasta local SHALL NOT aparecer nesta lista (já são offline por natureza). Cada item SHALL mostrar: capa miniatura, título, autor e tamanho do arquivo.

#### Scenario: Livros Calibre baixados existem
- **WHEN** existem 5 livros de Calibre baixados
- **THEN** a tela exibe 5 items com capa, título, autor e tamanho

#### Scenario: Livros locais não aparecem
- **WHEN** existem 3 livros de pasta local e 2 de Calibre baixados
- **THEN** a tela exibe apenas os 2 livros de Calibre

#### Scenario: Livro sem tamanho informado
- **WHEN** um livro possui `fileSizeKb == null`
- **THEN** o item exibe "—" no lugar do tamanho

### Requirement: Tamanho total ocupado

A tela SHALL exibir o tamanho total ocupado por todos os downloads no topo da lista, calculado pela soma de `fileSizeKb`.

#### Scenario: Exibir tamanho total
- **WHEN** existem 3 livros baixados com tamanhos 1024, 2048 e 512 KB
- **THEN** o header exibe "3.5 MB"

### Requirement: Remover download por swipe

O usuário SHALL poder remover um download via swipe horizontal. A remoção SHALL deletar o arquivo local e resetar o estado no banco. Aplica-se apenas a livros de Calibre.

#### Scenario: Swipe para remover download Calibre
- **WHEN** o usuário faz swipe em um livro Calibre baixado
- **THEN** o arquivo local é deletado, o livro sai da lista, e o tamanho total é recalculado

### Requirement: Ordenação de downloads

A tela SHALL permitir ordenar a lista por: recentes (data de download, padrão), título (A-Z) ou autor (A-Z).

#### Scenario: Ordenar por título
- **WHEN** o usuário seleciona ordenação por título
- **THEN** a lista é reordenada alfabeticamente por título

### Requirement: Navegação para detalhe

O tap em um item SHALL navegar para a tela de detalhe do livro (`/library/book/:id`).

#### Scenario: Tap em livro baixado
- **WHEN** o usuário toca em um livro na lista de downloads
- **THEN** o app navega para `/library/book/{bookId}`

### Requirement: Estado vazio

A tela SHALL exibir `EmptyStateView` quando não há livros de Calibre baixados.

#### Scenario: Sem downloads Calibre
- **WHEN** nenhum livro de Calibre está baixado (mesmo que existam livros locais)
- **THEN** a tela exibe "Nenhum download" com mensagem orientativa
