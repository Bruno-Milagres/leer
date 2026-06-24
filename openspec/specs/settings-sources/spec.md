# settings-sources

Gestão de servidores Calibre-Web e preferências de leitura do app Leer.

## Requirements

### Requirement: Lista de servidores

A tela de servidores SHALL exibir todos os servidores cadastrados com nome, URL e indicador de ativo/inativo. O servidor ativo SHALL ter destaque visual.

#### Scenario: Servidores cadastrados
- **WHEN** existem 2 servidores cadastrados
- **THEN** a tela exibe 2 itens com nome, URL e badge de ativo para o servidor ativo

#### Scenario: Sem servidores
- **WHEN** não há servidores cadastrados
- **THEN** a tela exibe empty state com CTA "Adicionar servidor"

### Requirement: Adicionar servidor

O usuário SHALL poder adicionar um novo servidor Calibre-Web informando nome, URL, usuário e senha. A senha SHALL ser armazenada no `SecureCredentialStore`.

#### Scenario: Adicionar servidor válido
- **WHEN** o usuário preenche nome, URL e credenciais e salva
- **THEN** o servidor é inserido no banco, a senha é salva no secure storage, e o servidor aparece na lista

#### Scenario: Adicionar primeiro servidor
- **WHEN** não há servidores e o usuário adiciona o primeiro
- **THEN** o servidor é automaticamente marcado como ativo

### Requirement: Editar servidor

O usuário SHALL poder editar nome, URL, usuário e senha de um servidor existente.

#### Scenario: Editar URL do servidor
- **WHEN** o usuário altera a URL de um servidor e salva
- **THEN** a URL é atualizada no banco

### Requirement: Remover servidor

O usuário SHALL poder remover um servidor com confirmação. A remoção SHALL deletar credenciais e livros associados.

#### Scenario: Remover servidor com confirmação
- **WHEN** o usuário toca em remover e confirma no dialog
- **THEN** o servidor, credenciais e livros associados são removidos

### Requirement: Testar conexão

O formulário SHALL ter um botão "Testar conexão" que valida o endpoint OPDS usando as credenciais informadas.

#### Scenario: Conexão bem-sucedida
- **WHEN** o servidor responde com feed OPDS válido
- **THEN** exibe indicador de sucesso (check verde)

#### Scenario: Conexão falha
- **WHEN** o servidor não responde ou retorna 401
- **THEN** exibe indicador de erro com mensagem descritiva

### Requirement: Ativar/desativar servidor

O usuário SHALL poder ativar um servidor, desativando o anterior automaticamente.

#### Scenario: Ativar servidor
- **WHEN** o usuário ativa o servidor "Oracle"
- **THEN** "Oracle" fica ativo e o anterior fica inativo

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

A tela principal de configurações SHALL exibir o servidor ativo (nome) e as preferências atuais como subtítulo de cada item.

#### Scenario: Hub com servidor ativo
- **WHEN** o servidor "Oracle" está ativo
- **THEN** o item "Servidor" exibe "Oracle" como subtítulo
