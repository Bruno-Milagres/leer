## Why

Toda a infra de servidores (tabela `servers`, `ServersDao`, `SecureCredentialStore`, `OpdsClient.validate()`) já existe desde M01/M02, mas não há UI para cadastrar, editar ou remover servidores. O onboarding (M10) vai depender da tela de servidor. Além disso, as preferências de leitura (tema, fonte, espaçamento) são in-memory no `readerSettingsProvider` (M05) e se perdem ao fechar o app. M08 resolve ambos: gestão de servidores e persistência de preferências.

## What Changes

- Implementar `ServerSettingsScreen`: lista de servidores com status, adicionar/editar/remover servidor, formulário com URL + usuário + senha, teste de conexão, ativar/desativar
- Implementar `ReaderSettingsScreen`: persistir preferências de leitura (tema, fonte, tamanho, espaçamento) em `SharedPreferences`
- Atualizar `SettingsScreen` hub com links corretos e info contextual

## Capabilities

### New Capabilities
- `settings-sources`: Gestão de servidores Calibre-Web (CRUD, teste de conexão, ativar/desativar) e persistência de preferências de leitura

### Modified Capabilities

_(nenhuma spec existente requer mudança)_

## Impact

- **Arquivos reescritos**: `server_settings_screen.dart`, `reader_settings_screen.dart`, `settings_screen.dart`
- **Arquivos novos**: `lib/features/settings/providers/settings_providers.dart`
- **Dependência nova**: `shared_preferences` (para persistir preferências de leitura)
- **DAOs**: `ServersDao` (já existe — insertServer, updateServer, deleteServer, setActive)
- **Infra**: `SecureCredentialStore`, `OpdsClient.validate()` (já existem)
