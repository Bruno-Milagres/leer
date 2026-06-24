# epub-reader

Leitor EPUB imersivo do app Leer.

## Requirements

### Requirement: Renderização de EPUB

O leitor SHALL renderizar o arquivo EPUB local via `flutter_epub_viewer`. O EPUB SHALL ser carregado do `localEpubPath` do livro. Se o caminho for inválido ou o arquivo não existir, SHALL exibir erro e permitir voltar.

#### Scenario: EPUB carregado com sucesso
- **WHEN** o livro possui `localEpubPath` válido apontando para um arquivo existente
- **THEN** o EPUB é renderizado na tela em modo imersivo (fullscreen)

#### Scenario: Arquivo EPUB não encontrado
- **WHEN** o `localEpubPath` aponta para um arquivo inexistente
- **THEN** a tela exibe mensagem de erro com botão para voltar

### Requirement: Interface imersiva com controles toggle

O leitor SHALL exibir uma interface limpa sem app bar ou navigation bar durante a leitura. Tap no centro da tela SHALL revelar/ocultar controles com animação fade.

#### Scenario: Leitura sem controles
- **WHEN** o leitor está em modo imersivo (controles ocultos)
- **THEN** a tela exibe apenas o conteúdo do EPUB, sem barras

#### Scenario: Revelar controles
- **WHEN** o usuário toca no centro da tela
- **THEN** os controles aparecem com fade: barra superior (título + botão fechar) e barra inferior (slider de progresso + capítulo)

#### Scenario: Ocultar controles
- **WHEN** os controles estão visíveis e o usuário toca no centro novamente
- **THEN** os controles desaparecem com fade

### Requirement: Barra superior com título e fechar

Os controles superiores SHALL exibir o título do livro e um botão de fechar (X) que navega de volta para a tela de detalhe.

#### Scenario: Fechar leitor
- **WHEN** o usuário toca no botão X com controles visíveis
- **THEN** o progresso é salvo e o app navega de volta

### Requirement: Barra inferior com progresso e capítulo

Os controles inferiores SHALL exibir o nome do capítulo atual e um slider de progresso que permite navegar pelo livro.

#### Scenario: Slider de progresso
- **WHEN** o usuário arrasta o slider para 50%
- **THEN** o viewer navega para a posição correspondente no EPUB

#### Scenario: Capítulo atualizado
- **WHEN** o usuário muda de capítulo durante a leitura
- **THEN** o nome do capítulo na barra inferior é atualizado

### Requirement: Temas de leitura

O leitor SHALL suportar 4 temas: Claro (fundo branco, texto preto), Sépia (fundo bege, texto marrom), Escuro (fundo cinza escuro, texto claro) e AMOLED (fundo preto puro, texto cinza claro). O tema SHALL ser selecionável via controles.

#### Scenario: Trocar para tema Sépia
- **WHEN** o usuário seleciona o tema Sépia nos controles
- **THEN** o fundo do viewer muda para bege e o texto para marrom escuro

#### Scenario: Tema padrão
- **WHEN** o leitor é aberto pela primeira vez
- **THEN** o tema Claro é aplicado

### Requirement: Configuração de fonte

O leitor SHALL permitir configurar família de fonte (Literata padrão, Georgia, Open Sans, Roboto Slab), tamanho (12–28px, default 18) e espaçamento entre linhas (1.0–2.5, default 1.5). As configurações SHALL ser aplicadas em tempo real.

#### Scenario: Mudar tamanho da fonte
- **WHEN** o usuário ajusta o slider de tamanho para 22px
- **THEN** o texto do EPUB é re-renderizado com fonte 22px imediatamente

#### Scenario: Mudar família da fonte
- **WHEN** o usuário seleciona "Georgia"
- **THEN** o texto do EPUB é re-renderizado com Georgia

### Requirement: Salvamento automático de progresso

O leitor SHALL salvar o progresso de leitura (CFI, percentual, capítulo) automaticamente a cada mudança de página, com debounce de 1 segundo. O progresso também SHALL ser salvo ao sair da tela.

#### Scenario: Progresso salvo ao virar página
- **WHEN** o usuário vira para uma nova página e 1 segundo se passa sem nova virada
- **THEN** o CFI, percentual e capítulo são salvos em `reading_progress`

#### Scenario: Progresso salvo ao fechar
- **WHEN** o usuário fecha o leitor (botão X ou back)
- **THEN** o progresso atual é salvo antes de navegar

### Requirement: Restauração de posição

O leitor SHALL restaurar a posição de leitura ao reabrir um livro que possui progresso salvo, usando o CFI armazenado.

#### Scenario: Reabrir livro com progresso
- **WHEN** o livro possui `reading_progress.cfi` salvo
- **THEN** o viewer abre na posição exata do CFI

#### Scenario: Abrir livro pela primeira vez
- **WHEN** o livro não possui progresso salvo
- **THEN** o viewer abre no início do EPUB
