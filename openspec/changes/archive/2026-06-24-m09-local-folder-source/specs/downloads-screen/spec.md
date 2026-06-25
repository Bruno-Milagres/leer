## MODIFIED Requirements

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

### Requirement: Remover download por swipe
O usuário SHALL poder remover um download via swipe horizontal. A remoção SHALL deletar o arquivo local e resetar o estado no banco. Aplica-se apenas a livros de Calibre.

#### Scenario: Swipe para remover download Calibre
- **WHEN** o usuário faz swipe em um livro Calibre baixado
- **THEN** o arquivo local é deletado, o livro sai da lista, e o tamanho total é recalculado

### Requirement: Estado vazio
A tela SHALL exibir `EmptyStateView` quando não há livros de Calibre baixados.

#### Scenario: Sem downloads Calibre
- **WHEN** nenhum livro de Calibre está baixado (mesmo que existam livros locais)
- **THEN** a tela exibe "Nenhum download" com mensagem orientativa
