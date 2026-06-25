# settings-sources

Gestão de fontes de biblioteca (Calibre-Web e pasta local) e preferências de leitura do app Leer.

## Requirements

### Requirement: Lista de servidores

A tela de fontes SHALL exibir todas as fontes cadastradas com nome, tipo (ícone Calibre / pasta), URL ou caminho, e indicador de ativo/inativo. Fontes ativas SHALL ter destaque visual. Múltiplas fontes podem estar ativas simultaneamente.

#### Scenario: Fontes cadastradas de tipos diferentes
- **WHEN** existem 1 CalibreSource e 1 LocalFolderSource cadastrados
- **THEN** a tela exibe 2 itens com ícone de tipo, nome, URL/caminho e toggle de ativo

#### Scenario: Sem fontes
- **WHEN** não há fontes cadastradas
- **THEN** a tela exibe empty state com CTA "Adicionar fonte"

### Requirement: Adicionar servidor

O usuário SHALL poder adicionar uma nova fonte de biblioteca. O formulário SHALL oferecer escolha de tipo: "Calibre-Web" ou "Pasta local". Para Calibre-Web, SHALL solicitar nome, URL, usuário e senha. Para pasta local, SHALL abrir o seletor de diretório. A senha de Calibre SHALL ser armazenada no `SecureCredentialStore`.

#### Scenario: Adicionar fonte Calibre válida
- **WHEN** o usuário escolhe "Calibre-Web", preenche nome, URL e credenciais e salva
- **THEN** a fonte é inserida no banco com `type = 'calibre'`, a senha é salva no secure storage, e a fonte aparece na lista

#### Scenario: Adicionar pasta local
- **WHEN** o usuário escolhe "Pasta local" e seleciona um diretório
- **THEN** a fonte é inserida no banco com `type = 'localFolder'` e o caminho da pasta, e a varredura inicial é disparada

#### Scenario: Adicionar primeira fonte
- **WHEN** não há fontes e o usuário adiciona a primeira
- **THEN** a fonte é automaticamente marcada como ativa

### Requirement: Remover servidor

O usuário SHALL poder remover uma fonte com confirmação. A remoção SHALL deletar credenciais (se Calibre), livros associados e cache de capas (se pasta local).

#### Scenario: Remover fonte Calibre com confirmação
- **WHEN** o usuário toca em remover uma fonte Calibre e confirma no dialog
- **THEN** a fonte, credenciais e livros associados são removidos

#### Scenario: Remover fonte pasta local
- **WHEN** o usuário toca em remover uma fonte de pasta local e confirma
- **THEN** a fonte e os livros indexados são removidos; os arquivos EPUB originais NÃO são deletados

### Requirement: Testar conexão de fonte

O formulário de fonte Calibre SHALL ter um botão "Testar conexão" que valida o endpoint OPDS. Para pasta local, o teste SHALL verificar se o caminho existe e é acessível.

#### Scenario: Conexão Calibre bem-sucedida
- **WHEN** o servidor Calibre responde com feed OPDS válido
- **THEN** exibe indicador de sucesso (check verde)

#### Scenario: Pasta local acessível
- **WHEN** o caminho da pasta local existe e é legível
- **THEN** exibe indicador de sucesso e contagem de EPUBs encontrados

#### Scenario: Pasta local inacessível
- **WHEN** o caminho não existe ou não tem permissão
- **THEN** exibe indicador de erro com mensagem descritiva

### Requirement: Ativar/desativar servidor

O usuário SHALL poder ativar ou desativar fontes individualmente via toggle. Múltiplas fontes podem estar ativas simultaneamente. A biblioteca agrega livros de todas as fontes ativas.

#### Scenario: Ativar fonte
- **WHEN** o usuário ativa uma fonte previamente desativada
- **THEN** os livros dessa fonte passam a aparecer na biblioteca

#### Scenario: Desativar fonte
- **WHEN** o usuário desativa uma fonte ativa
- **THEN** os livros dessa fonte deixam de aparecer na biblioteca

### Requirement: Persistência de preferências de leitura

As preferências de leitura (tema, fontFamily, fontSize, lineSpacing) SHALL ser persistidas em `SharedPreferences` e restauradas ao abrir o app.

#### Scenario: Salvar preferência de tema
- **WHEN** o usuário altera o tema para Sépia na tela de preferências
- **THEN** a preferência é salva e ao reabrir o app o tema Sépia é aplicado no reader

### Requirement: Tela de preferências de leitura

A `ReaderSettingsScreen` SHALL permitir configurar tema de leitura, família de fonte, tamanho e espaçamento, com preview do efeito.

#### Scenario: Ajustar tamanho da fonte
- **WHEN** o usuário move o slider de tamanho para 22px
- **THEN** o valor é salvo e refletido na próxima abertura do reader

### Requirement: Settings hub com info contextual

A tela principal de configurações SHALL exibir as fontes ativas (contagem e nomes) e as preferências atuais como subtítulo de cada item.

#### Scenario: Hub com múltiplas fontes ativas
- **WHEN** as fontes "Oracle" (Calibre) e "Downloads" (pasta) estão ativas
- **THEN** o item "Fontes" exibe "2 fontes ativas" como subtítulo

#### Scenario: Hub sem fontes
- **WHEN** não há fontes cadastradas
- **THEN** o item "Fontes" exibe "Nenhuma fonte configurada" como subtítulo
