## ADDED Requirements

### Requirement: Renderização de EPUB
O sistema SHALL renderizar arquivos EPUB usando `flutter_epub_viewer` em uma interface de leitura limpa, sem app bar nem navegação visíveis durante a leitura.

#### Scenario: Abertura do livro
- **WHEN** o usuário aciona "Começar a Ler"/"Continuar Lendo"
- **THEN** o EPUB é renderizado em tela cheia, restaurando a posição salva (CFI) se existir

#### Scenario: Livro não baixado ao abrir o leitor
- **WHEN** o usuário abre o leitor de um livro não baixado
- **THEN** o app inicia o download e abre o leitor ao concluir

### Requirement: Controles sobrepostos
O sistema SHALL revelar/ocultar os controles de leitura com fade ao tocar no centro da tela, exibindo no topo o título e botão fechar, e na base um slider de progresso com o nome do capítulo atual.

#### Scenario: Revelar controles
- **WHEN** o usuário toca no centro da tela durante a leitura
- **THEN** os controles aparecem com transição de fade

#### Scenario: Ocultar controles
- **WHEN** os controles estão visíveis e o usuário toca novamente no centro
- **THEN** os controles desaparecem com fade

### Requirement: Temas e tipografia de leitura
O sistema SHALL oferecer temas de leitura Claro, Sépia, Escuro e AMOLED e configurações de fonte (família com Literata padrão, tamanho e espaçamento).

#### Scenario: Troca de tema
- **WHEN** o usuário seleciona o tema Sépia
- **THEN** o conteúdo do leitor é re-renderizado com as cores sépia

#### Scenario: Ajuste de tamanho de fonte
- **WHEN** o usuário aumenta o tamanho da fonte
- **THEN** o texto é re-renderizado no novo tamanho e a configuração persiste

### Requirement: Persistência de progresso
O sistema SHALL salvar automaticamente o progresso (CFI, percentual e capítulo) a cada página virada na tabela `reading_progress`.

#### Scenario: Salvar ao virar página
- **WHEN** o usuário vira a página
- **THEN** o CFI atual, o percentual e o capítulo são gravados em `reading_progress`

### Requirement: Virada de página
O sistema SHALL permitir virar páginas por swipe horizontal com leve efeito de parallax.

#### Scenario: Swipe para avançar
- **WHEN** o usuário desliza horizontalmente para a esquerda
- **THEN** o leitor avança para a próxima página
