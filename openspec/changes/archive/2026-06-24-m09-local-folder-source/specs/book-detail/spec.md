## MODIFIED Requirements

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
