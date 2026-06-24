# annotations

Destaques e notas de leitura do app Leer.

## Requirements

### Requirement: Seleção de texto com menu de ações no reader

O leitor SHALL exibir um menu flutuante quando o usuário seleciona texto via pressão longa. O menu SHALL oferecer as opções: Destacar (com seletor de cor), Anotar e Copiar.

#### Scenario: Seleção de texto
- **WHEN** o usuário faz pressão longa e seleciona texto no reader
- **THEN** um menu flutuante aparece acima/abaixo da seleção com as opções Destacar, Anotar e Copiar

#### Scenario: Copiar texto
- **WHEN** o usuário toca "Copiar" no menu de seleção
- **THEN** o texto selecionado é copiado para o clipboard e o menu fecha

### Requirement: Destacar texto com cores

O leitor SHALL permitir destacar o texto selecionado em 4 cores: amarelo, verde, azul e rosa. O destaque SHALL ser salvo na tabela `annotations` com o CFI, texto selecionado e cor.

#### Scenario: Criar destaque amarelo
- **WHEN** o usuário toca "Destacar" e seleciona a cor amarela
- **THEN** o texto é destacado visualmente no viewer com amarelo e salvo no banco

#### Scenario: Criar destaque com outra cor
- **WHEN** o usuário seleciona verde, azul ou rosa
- **THEN** o destaque usa a cor selecionada

### Requirement: Adicionar nota a um destaque

O leitor SHALL permitir adicionar uma nota de texto ao criar um destaque. Um dialog SHALL ser exibido para o usuário digitar a nota.

#### Scenario: Criar anotação com nota
- **WHEN** o usuário toca "Anotar" no menu de seleção
- **THEN** um dialog é exibido para digitar a nota, e ao confirmar, o destaque + nota são salvos

#### Scenario: Criar anotação sem nota
- **WHEN** o usuário confirma o dialog sem digitar texto
- **THEN** apenas o destaque é salvo, sem nota

### Requirement: Restauração de highlights ao abrir livro

O leitor SHALL restaurar visualmente todos os highlights salvos quando o EPUB é carregado, usando `EpubController.addHighlight()` com o CFI e cor de cada anotação.

#### Scenario: Livro com highlights salvos
- **WHEN** o EPUB é carregado e o livro possui anotações no banco
- **THEN** cada highlight é renderizado no viewer com a cor correta

#### Scenario: Livro sem highlights
- **WHEN** o livro não possui anotações
- **THEN** nenhum highlight é renderizado

### Requirement: Tela global de anotações agrupada por livro

A tela `AnnotationsScreen` SHALL exibir todas as anotações do usuário agrupadas por livro. Cada item SHALL mostrar: texto destacado, nota (se houver), cor do destaque e data.

#### Scenario: Anotações de múltiplos livros
- **WHEN** existem anotações em 3 livros diferentes
- **THEN** a tela exibe 3 seções com header do título de cada livro e suas anotações

#### Scenario: Sem anotações
- **WHEN** não existem anotações
- **THEN** a tela exibe `EmptyStateView` com mensagem orientativa

### Requirement: Exportação para clipboard

A tela de anotações SHALL permitir copiar todas as anotações de um livro para o clipboard em formato texto simples.

#### Scenario: Exportar anotações de um livro
- **WHEN** o usuário toca no botão de copiar no header de um livro
- **THEN** todas as anotações daquele livro são formatadas como texto e copiadas para o clipboard, com snackbar de confirmação

### Requirement: Navegação para posição do destaque

O tap em uma anotação na tela global ou na aba de anotações do detalhe SHALL navegar para o reader na posição exata do CFI.

#### Scenario: Tap em anotação
- **WHEN** o usuário toca em uma anotação na lista
- **THEN** o app navega para `/library/book/:id/read` e o reader abre na posição do CFI

### Requirement: Deletar anotação

O usuário SHALL poder deletar uma anotação via swipe ou menu contextual.

#### Scenario: Deletar anotação por swipe
- **WHEN** o usuário faz swipe em uma anotação na lista
- **THEN** a anotação é removida do banco e da lista
