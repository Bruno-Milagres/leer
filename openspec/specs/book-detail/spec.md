# book-detail

Tela de detalhe do livro no app Leer.

## Requirements

### Requirement: Exibição de informações do livro

A tela de detalhe SHALL exibir: título, autor, série com índice (ex: "Livro 2 de The Expanse"), stats (páginas estimadas, idioma, tamanho do arquivo em KB/MB), e descrição do livro.

#### Scenario: Livro com todas as informações
- **WHEN** o livro possui título, autor, série, seriesIndex, pageCount, language, fileSizeKb e description
- **THEN** a tela exibe todas as informações formatadas

#### Scenario: Livro com informações mínimas
- **WHEN** o livro possui apenas título e downloadUrl (campos opcionais são nulos)
- **THEN** a tela exibe o título e omite seções de metadados ausentes sem erros

### Requirement: Capa com fundo desfocado

A tela SHALL exibir a capa do livro centralizada sobre um fundo desfocado (blur) extraído da mesma capa. O blur SHALL usar sigma suficiente para ser decorativo sem revelar detalhes. Um overlay escuro semi-transparente SHALL ser aplicado sobre o blur para garantir legibilidade.

#### Scenario: Livro com capa
- **WHEN** o livro possui `coverUrl` válido
- **THEN** a tela exibe o fundo blur + capa nítida centralizada

#### Scenario: Livro sem capa
- **WHEN** o campo `coverUrl` é nulo
- **THEN** a tela exibe um fundo sólido com placeholder de ícone de livro

### Requirement: Paleta dinâmica extraída da capa

A tela SHALL extrair a cor dominante da capa via `PaletteGenerator` e usar `ColorScheme.fromSeed()` para tematizar a tela. Se a extração falhar ou a capa for nula, SHALL usar o tema padrão do app.

#### Scenario: Extração de cor bem-sucedida
- **WHEN** a capa é carregada e `PaletteGenerator` extrai a cor dominante
- **THEN** a tela usa um `ColorScheme` baseado na cor extraída

#### Scenario: Extração falha
- **WHEN** `PaletteGenerator` falha ou faz timeout
- **THEN** a tela usa o `ColorScheme` padrão do app sem erro visível

### Requirement: Barra de progresso de leitura

A tela SHALL exibir uma barra de progresso com label quando o livro possui progresso de leitura registrado. O label SHALL mostrar o percentual e o capítulo atual (ex: "34% · Capítulo 5").

#### Scenario: Livro com progresso
- **WHEN** `reading_progress.percentage` > 0
- **THEN** a tela exibe `LinearProgressIndicator` + label com percentual e capítulo

#### Scenario: Livro sem progresso
- **WHEN** não há registro em `reading_progress` para o livro
- **THEN** a barra de progresso não é exibida

### Requirement: Botão primário de leitura

A tela SHALL exibir um botão primário que navega para o reader (`/library/book/:id/read`). O label SHALL ser "Continuar Lendo" quando há progresso > 0, e "Começar a Ler" caso contrário. O botão SHALL estar habilitado apenas quando o livro está baixado localmente.

#### Scenario: Livro baixado sem progresso
- **WHEN** `isDownloaded == true` e não há progresso
- **THEN** o botão exibe "Começar a Ler" e navega ao tap

#### Scenario: Livro baixado com progresso
- **WHEN** `isDownloaded == true` e `percentage > 0`
- **THEN** o botão exibe "Continuar Lendo" e navega ao tap

#### Scenario: Livro não baixado
- **WHEN** `isDownloaded == false`
- **THEN** o botão de leitura está desabilitado ou exibe "Baixar para Ler"

### Requirement: Download de EPUB

A tela SHALL permitir baixar o EPUB do servidor Calibre-Web. O download SHALL usar autenticação básica, salvar o arquivo localmente e atualizar o estado no banco (`isDownloaded`, `localEpubPath`).

#### Scenario: Iniciar download
- **WHEN** o usuário toca no botão "Baixar" e o livro não está baixado
- **THEN** o download inicia, o botão mostra estado de loading, e ao concluir o livro é marcado como baixado

#### Scenario: Download com falha
- **WHEN** o download falha (rede, 401, etc.)
- **THEN** um snackbar exibe a mensagem de erro e o estado permanece não-baixado

#### Scenario: Remover download
- **WHEN** o usuário toca em "Remover download" e o livro está baixado
- **THEN** o arquivo local é deletado, `isDownloaded` volta a false e `localEpubPath` volta a null

### Requirement: Abas Descrição e Anotações

A tela SHALL exibir duas abas: "Descrição" com o texto da descrição do livro, e "Anotações" com badge mostrando a contagem de anotações quando > 0.

#### Scenario: Aba Descrição
- **WHEN** o usuário está na aba Descrição
- **THEN** a tela exibe o texto de `description` do livro, ou "Sem descrição" quando nulo

#### Scenario: Aba Anotações com badge
- **WHEN** o livro possui 3 anotações
- **THEN** o tab "Anotações" exibe badge com "3"

#### Scenario: Aba Anotações vazia
- **WHEN** o livro não possui anotações
- **THEN** o tab "Anotações" não exibe badge e o conteúdo mostra "Nenhuma anotação"
