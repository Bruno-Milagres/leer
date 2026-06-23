# env-config

Configuração de ambiente via `.env` para o projeto Leer.

## Requirements

### Requirement: Arquivo .env como fonte única de configuração de ambiente

O projeto SHALL ter um arquivo `.env` na raiz com variáveis que configuram o backend Calibre-Web. O arquivo `.env` SHALL ser ignorado pelo git. Um arquivo `.env.example` SHALL ser versionado com valores padrão de desenvolvimento.

#### Scenario: Dev clona o projeto e configura ambiente local
- **WHEN** o desenvolvedor clona o repositório e copia `.env.example` para `.env`
- **THEN** o `.env` contém variáveis pré-preenchidas para o ambiente local (`localhost:8083`)

#### Scenario: Dev troca para ambiente remoto (Oracle)
- **WHEN** o desenvolvedor edita o `.env` alterando `CALIBRE_WEB_HOST` para o IP/domínio do servidor Oracle
- **THEN** tanto o app Flutter quanto o Docker Compose refletem o novo apontamento sem alteração de código

### Requirement: Variáveis de ambiente obrigatórias

O `.env` SHALL definir as seguintes variáveis:
- `CALIBRE_WEB_HOST`: hostname ou IP do Calibre-Web (ex: `localhost`, `10.0.2.2`, `192.168.1.100`)
- `CALIBRE_WEB_PORT`: porta do Calibre-Web (ex: `8083`)
- `CALIBRE_WEB_USERNAME`: usuário para autenticação OPDS (dev only)
- `CALIBRE_WEB_PASSWORD`: senha para autenticação OPDS (dev only)
- `TZ`: timezone para o container Docker

#### Scenario: Todas as variáveis presentes
- **WHEN** o `.env` contém todas as variáveis listadas
- **THEN** o app Flutter e o Docker Compose utilizam esses valores corretamente

#### Scenario: Variável de host aponta para emulador
- **WHEN** `CALIBRE_WEB_HOST=10.0.2.2` e o app roda no emulador Android
- **THEN** o app consegue alcançar o Calibre-Web rodando na máquina host

### Requirement: Flutter lê variáveis via compile-time defines

O app Flutter SHALL acessar as variáveis de ambiente via `String.fromEnvironment()`, injetadas pelo flag `--dart-define-from-file=.env` no comando `flutter run` ou `flutter build`.

#### Scenario: App Flutter roda com --dart-define-from-file
- **WHEN** o dev executa `flutter run --dart-define-from-file=.env`
- **THEN** a classe `EnvConfig` expõe `calibreWebHost`, `calibreWebPort`, `calibreWebUsername`, `calibreWebPassword` com os valores do `.env`

#### Scenario: App Flutter roda sem --dart-define-from-file
- **WHEN** o dev executa `flutter run` sem o flag
- **THEN** a classe `EnvConfig` retorna valores fallback funcionais para emulador (`10.0.2.2`, `8083`)

### Requirement: Docker Compose usa variáveis do .env

O `docker-compose.yml` SHALL usar variáveis do `.env` para a porta mapeada e timezone. O Docker Compose SHALL ser invocável com `docker compose --env-file ../.env up -d` de dentro da pasta `compose/`, ou o `.env` SHALL estar acessível via configuração relativa.

#### Scenario: Porta customizada via .env
- **WHEN** o `.env` define `CALIBRE_WEB_PORT=9090`
- **THEN** o container mapeia a porta `9090:8083` (host:container)

#### Scenario: Timezone customizada via .env
- **WHEN** o `.env` define `TZ=Europe/London`
- **THEN** o container usa `Europe/London` como timezone

### Requirement: .gitignore protege o .env

O `.gitignore` na raiz do projeto SHALL ignorar o arquivo `.env` para prevenir commit acidental de credenciais.

#### Scenario: Dev tenta adicionar .env ao git
- **WHEN** o dev executa `git add .env`
- **THEN** o git ignora o arquivo por estar listado no `.gitignore`
