## Why

O container Calibre-Web já está rodando localmente via Docker Compose (`compose/`), mas o código Flutter não tem um `.env` centralizado para apontar para o backend. Quando mudarmos de ambiente (dev local → Oracle → outra máquina), precisamos editar código ou configs espalhadas. Um `.env` na raiz do projeto resolve isso com uma única fonte de verdade para URLs e credenciais de dev.

## What Changes

- Criar `.env` e `.env.example` na raiz do projeto com variáveis de ambiente para o backend Calibre-Web (URL OPDS, porta, credenciais de dev)
- Adicionar suporte no Flutter para ler essas variáveis via `--dart-define-from-file` no build/run
- Parametrizar o `docker-compose.yml` existente para usar as mesmas variáveis do `.env`
- Documentar o fluxo de troca de ambiente no README do compose

## Capabilities

### New Capabilities
- `env-config`: Configuração de ambiente via `.env` — define variáveis para URL do Calibre-Web, porta, credenciais de dev e permite trocar de backend (local/Oracle/remoto) alterando apenas o `.env`

### Modified Capabilities

_(nenhuma spec existente para modificar)_

## Impact

- **Arquivos novos**: `.env`, `.env.example`, `lib/core/config/env_config.dart`
- **Arquivos modificados**: `compose/docker-compose.yml` (parametrizar porta/imagem), `.gitignore` (ignorar `.env`)
- **Build**: flutter run/build passa a usar `--dart-define-from-file=.env`
- **Dependências**: nenhuma nova (Dart `String.fromEnvironment` é built-in)
