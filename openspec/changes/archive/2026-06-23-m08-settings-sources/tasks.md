## 1. Dependência

- [x] 1.1 Adicionar `shared_preferences` ao `pubspec.yaml` e rodar `flutter pub get`

## 2. Providers

- [x] 2.1 Criar `lib/features/settings/providers/settings_providers.dart` com `allServersProvider` (StreamProvider via `watchAll()`), e `readerPrefsService` que lê/escreve SharedPreferences e inicializa `readerSettingsProvider`

## 3. ServerSettingsScreen

- [x] 3.1 Reescrever `server_settings_screen.dart` — lista de servidores via `allServersProvider`, com badge de ativo, FAB para adicionar, e empty state
- [x] 3.2 Implementar bottom sheet de formulário (nome, URL, usuário, senha) com botão "Testar conexão" que chama `OpdsClient.validate()` e mostra resultado inline
- [x] 3.3 Implementar ação de salvar: insere servidor via `ServersDao`, salva senha via `SecureCredentialStore`, marca como ativo se for o primeiro
- [x] 3.4 Implementar edição: tap em servidor existente abre formulário preenchido, salva atualização
- [x] 3.5 Implementar remoção com dialog de confirmação que deleta servidor, credenciais e livros (cascade)
- [x] 3.6 Implementar toggle ativar/desativar via `ServersDao.setActive()`

## 4. ReaderSettingsScreen

- [x] 4.1 Reescrever `reader_settings_screen.dart` — exibe seletores de tema (4 circles), fonte (chips), slider tamanho e slider espaçamento, salvando em SharedPreferences a cada mudança
- [x] 4.2 Carregar preferências salvas ao iniciar e alimentar `readerSettingsProvider`

## 5. Settings hub

- [x] 5.1 Atualizar `settings_screen.dart` — exibir nome do servidor ativo como subtítulo e preview de preferências de leitura

## 6. Validação

- [x] 6.1 Verificar que o app compila sem erros (`flutter analyze`)
