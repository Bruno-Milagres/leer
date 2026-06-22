## ADDED Requirements

### Requirement: Criação de destaques e notas
O sistema SHALL permitir, no leitor, selecionar texto por pressão longa e oferecer as ações Destacar, Anotar e Copiar, com cores de destaque amarelo, verde, azul e rosa.

#### Scenario: Criar destaque
- **WHEN** o usuário seleciona texto e escolhe Destacar com uma cor
- **THEN** uma anotação é gravada em `annotations` com o CFI, o texto selecionado e a cor

#### Scenario: Adicionar nota a uma seleção
- **WHEN** o usuário seleciona texto e escolhe Anotar e digita uma nota
- **THEN** a anotação é gravada com o campo `note` preenchido

### Requirement: Lista global de anotações
O sistema SHALL exibir uma lista global de todos os destaques e notas agrupada por livro.

#### Scenario: Agrupamento por livro
- **WHEN** o usuário abre a tela de anotações
- **THEN** as anotações são exibidas agrupadas pelo livro a que pertencem

### Requirement: Navegação para a posição da anotação
O sistema SHALL abrir o livro na posição exata (CFI) ao tocar em uma anotação.

#### Scenario: Tap na anotação
- **WHEN** o usuário toca em uma anotação na lista
- **THEN** o leitor abre o livro correspondente e navega até o CFI da anotação

### Requirement: Exportação de anotações
O sistema SHALL permitir exportar as anotações em texto simples copiando para a área de transferência.

#### Scenario: Exportar para clipboard
- **WHEN** o usuário aciona exportar
- **THEN** o texto consolidado das anotações é copiado para a área de transferência
