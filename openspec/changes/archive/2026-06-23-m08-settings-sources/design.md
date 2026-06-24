## Context

A tabela `servers` tem `id`, `name`, `url`, `username`, `isActive`, `createdAt`. O `ServersDao` expõe `watchAll()`, `getActive()`, `insertServer()`, `updateServer()`, `deleteServer()`, `setActive()`. O `SecureCredentialStore` salva/lê/deleta senha por serverId. O `OpdsClient.validate()` testa conexão. O `readerSettingsProvider` é in-memory.

## Goals / Non-Goals

**Goals:**
- Tela de lista de servidores com status (online badge via teste rápido)
- Formulário para adicionar/editar servidor (nome, URL, usuário, senha)
- Botão "Testar conexão" que valida OPDS
- Ativar/desativar servidor (toggle)
- Remover servidor (com confirmação)
- Persistir preferências de leitura em SharedPreferences
- Carregar preferências ao iniciar o app

**Non-Goals:**
- Multi-fonte simultânea na library screen (M09 para Local Folder, multi-Calibre é futuro)
- Gestão de pasta local (M09)
- Sync settings / KOSync (v1.1)

## Decisions

### 1. Formulário de servidor como tela dedicada

A `ServerSettingsScreen` lista servidores. O tap em "Adicionar" ou em um servidor existente abre uma tela/dialog de formulário. Usamos um `showModalBottomSheet` com campos nome, URL, usuário, senha e botão "Testar conexão".

### 2. Teste de conexão inline

O botão "Testar" chama `OpdsClient.validate()` e mostra resultado inline (ícone check verde ou X vermelho com mensagem). Não bloqueia o salvamento — o usuário pode salvar mesmo sem testar.

### 3. SharedPreferences para preferências de leitura

As preferências (tema, fontFamily, fontSize, lineSpacing) são salvas como chaves individuais em `SharedPreferences`. Um `readerPrefsProvider` inicializa o `readerSettingsProvider` ao carregar o app. A `ReaderSettingsScreen` permite ajustar e salva em tempo real.

Alternativa descartada: tabela drift — overengineering para 4 campos simples.

### 4. Settings hub com info contextual

O hub mostra: servidor ativo (nome + URL) abaixo do item "Servidor", e preview das preferências de leitura (ex: "Literata · 18px") abaixo do item "Leitura".

## Risks / Trade-offs

- **[Risk]** `shared_preferences` precisa ser adicionado ao pubspec.
  → Dependência leve e padrão do Flutter. Já é transitiva via vários pacotes.

- **[Trade-off]** Teste de conexão pode ser lento em redes ruins.
  → Timeout de 5s. Feedback visual com `CircularProgressIndicator` durante o teste.
