## ADDED Requirements

### Requirement: Tela de detalhe do livro
O sistema SHALL exibir uma tela de detalhe com capa grande centralizada sobre fundo desfocado extraído da própria capa, título, autor, série com índice, stats (páginas, idioma, tamanho) e barra de progresso com label.

#### Scenario: Exibição dos metadados
- **WHEN** o usuário abre o detalhe de um livro
- **THEN** a tela exibe capa, título, autor, série com índice e os stats disponíveis

#### Scenario: Label de progresso
- **WHEN** o livro tem progresso registrado
- **THEN** a barra exibe um label como "34% · Capítulo 5"

### Requirement: Paleta dinâmica a partir da capa
O sistema SHALL extrair uma cor dominante da capa via `PaletteGenerator` e aplicá-la ao tema da tela de detalhe.

#### Scenario: Cor extraída da capa
- **WHEN** a capa do livro carrega
- **THEN** a tela de detalhe tematiza seus acentos com a cor dominante extraída

### Requirement: Ações de leitura e download
O sistema SHALL oferecer um botão primário "Continuar Lendo"/"Começar a Ler" e um botão secundário "Baixar"/"Remover download" conforme o estado do livro.

#### Scenario: Livro não iniciado
- **WHEN** o livro não tem progresso
- **THEN** o botão primário exibe "Começar a Ler"

#### Scenario: Livro não baixado
- **WHEN** `is_downloaded` é falso
- **THEN** o botão secundário exibe "Baixar"

### Requirement: Abas de descrição e anotações
O sistema SHALL exibir abas Descrição e Anotações, com badge de contagem de anotações.

#### Scenario: Badge de contagem
- **WHEN** o livro possui 3 anotações
- **THEN** a aba Anotações exibe o badge "3"
