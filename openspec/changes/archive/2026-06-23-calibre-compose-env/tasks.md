## 1. Arquivos de ambiente

- [x] 1.1 Criar `.env.example` na raiz com todas as variáveis documentadas (CALIBRE_WEB_HOST, CALIBRE_WEB_PORT, CALIBRE_WEB_USERNAME, CALIBRE_WEB_PASSWORD, TZ)
- [x] 1.2 Criar `.env` na raiz copiando `.env.example` com valores padrão de dev local (localhost, 8083, admin, admin123, America/Sao_Paulo)
- [x] 1.3 Adicionar `.env` ao `.gitignore` da raiz do projeto

## 2. Docker Compose parametrizado

- [x] 2.1 Atualizar `compose/docker-compose.yml` para usar `${CALIBRE_WEB_PORT}` na porta mapeada e `${TZ}` no timezone
- [x] 2.2 Configurar o `docker-compose.yml` para ler o `.env` da raiz do projeto (`env_file: ../.env`)
- [x] 2.3 Atualizar `compose/README.md` com instruções de uso do `.env` e troca de ambiente

## 3. Flutter EnvConfig

- [x] 3.1 Criar `lib/core/config/env_config.dart` com classe estática usando `String.fromEnvironment()` para cada variável, com fallbacks para emulador
- [x] 3.2 Documentar no README principal o uso de `flutter run --dart-define-from-file=.env`

## 4. Validação

- [x] 4.1 Testar `docker compose --env-file ../.env up -d` de dentro de `compose/` e verificar que o container sobe com a porta do .env
- [x] 4.2 Verificar que `.env` é ignorado pelo git (`git status` não mostra o arquivo)
