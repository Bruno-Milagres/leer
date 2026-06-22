## ADDED Requirements

### Requirement: Download de livro para offline
O sistema SHALL baixar o arquivo EPUB de um livro via OPDS e armazená-lo localmente usando `path_provider`, atualizando `local_epub_path` e `is_downloaded`.

#### Scenario: Download bem-sucedido
- **WHEN** o usuário aciona "Baixar" em um livro
- **THEN** o EPUB é salvo no armazenamento do app e o livro passa a ter `is_downloaded` verdadeiro com `local_epub_path` preenchido

#### Scenario: Progresso do download
- **WHEN** um download está em andamento
- **THEN** o card do livro exibe um indicador de progresso linear

### Requirement: Lista de downloads
O sistema SHALL exibir uma lista dos livros baixados localmente, o tamanho total ocupado e suportar ordenação por recentes, título e autor.

#### Scenario: Tamanho total ocupado
- **WHEN** o usuário abre a tela de downloads
- **THEN** a tela exibe a soma dos tamanhos dos arquivos baixados

#### Scenario: Ordenação por título
- **WHEN** o usuário escolhe ordenar por título
- **THEN** a lista é reordenada alfabeticamente por título

### Requirement: Remoção de download
O sistema SHALL permitir remover um download por swipe, apagando o arquivo local e limpando `local_epub_path`/`is_downloaded`, sem remover o livro da biblioteca.

#### Scenario: Remover download por swipe
- **WHEN** o usuário desliza um item da lista de downloads para removê-lo
- **THEN** o arquivo local é apagado, `is_downloaded` vira falso e o livro continua visível na biblioteca
