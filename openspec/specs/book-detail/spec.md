# book-detail

Tela de detalhe do livro no app Leer.

## Requirements

### Requirement: Exibição de informações do livro

A tela de detalhe SHALL exibir: título, autor, série com índice, stats (páginas estimadas, idioma, tamanho do arquivo), descrição, e a origem do livro (nome da fonte) exibida discretamente.

#### Scenario: Livro com todas as informações
- **WHEN** o livro possui título, autor, série, seriesIndex, pageCount, language, fileSizeKb e description
- **THEN** a tela exibe todas as informações formatadas, incluindo a fonte de origem

#### Scenario: Livro com informações mínimas
- **WHEN** o livro possui apenas título e downloadUrl (campos opcionais são nulos)
- **THEN** a tela exibe o título e omite seções de metadados ausentes sem erros

#### Scenario: Origem do livro exibida
- **WHEN** o livro pertence à fonte "Oracle" (Calibre)
- **THEN** a tela exibe "Oracle" discretamente junto aos stats

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

A tela SHALL exibir um botão primário que navega para o reader. Para livros de pasta local, o botão SHALL estar sempre habilitado. Para livros de Calibre, o label SHALL ser "Continuar Lendo" (com progresso), "Começar a Ler" (baixado sem progresso) ou "Baixar para Ler" (não baixado).

#### Scenario: Livro local sem progresso
- **WHEN** o livro é de pasta local e não tem progresso
- **THEN** o botão exibe "Começar a Ler" e navega ao tap

#### Scenario: Livro local com progresso
- **WHEN** o livro é de pasta local e tem progresso > 0
- **THEN** o botão exibe "Continuar Lendo" e navega ao tap

#### Scenario: Livro Calibre baixado com progresso
- **WHEN** `isDownloaded == true` e `percentage > 0`
- **THEN** o botão exibe "Continuar Lendo" e navega ao tap

#### Scenario: Livro Calibre não baixado
- **WHEN** o livro é de Calibre e `isDownloaded == false`
- **THEN** o botão exibe "Baixar para Ler"

### Requirement: Download de EPUB

A tela SHALL permitir baixar o EPUB para livros de Calibre. Livros de pasta local SHALL NOT exibir botão de download (já são locais por natureza). O download SHALL usar autenticação básica, salvar o arquivo localmente e atualizar o estado no banco.

#### Scenario: Iniciar download (Calibre)
- **WHEN** o usuário toca no botão "Baixar" e o livro de Calibre não está baixado
- **THEN** o download inicia, o botão mostra estado de loading, e ao concluir o livro é marcado como baixado

#### Scenario: Livro de pasta local
- **WHEN** o livro é de uma fonte `localFolder`
- **THEN** não há botão de download; o botão primário "Ler" está sempre habilitado

#### Scenario: Download com falha
- **WHEN** o download falha (rede, 401, etc.)
- **THEN** um snackbar exibe a mensagem de erro e o estado permanece não-baixado

#### Scenario: Remover download (Calibre)
- **WHEN** o usuário toca em "Remover download" e o livro Calibre está baixado
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
