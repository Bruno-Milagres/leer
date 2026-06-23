## Context

O projeto Leer já possui um container Calibre-Web funcional em `compose/docker-compose.yml` com porta 8083 fixa e sem variáveis de ambiente externas. O app Flutter (ainda em bootstrap) vai precisar apontar para o backend OPDS. Hoje, o README do compose instrui o dev a usar `localhost:8083`, `10.0.2.2:8083` (emulador) ou o IP da máquina (celular físico), mas isso não está codificado em nenhum config — cada dev resolve na hora.

O SPEC.md define que Calibre-Web é o backend primário e que o app deve ser fonte-agnóstico. A configuração de ambiente precisa alimentar tanto o Docker Compose quanto o Flutter sem duplicar valores.

## Goals / Non-Goals

**Goals:**
- `.env` na raiz como fonte única de verdade para URL do Calibre-Web, porta e credenciais de dev
- Docker Compose lê variáveis do `.env` (porta mapeada, timezone)
- Flutter lê variáveis via `--dart-define-from-file=.env` em dev e via build config em release
- Trocar de backend (local → Oracle → outra máquina) = editar 1 arquivo
- `.env.example` versionado com valores padrão documentados

**Non-Goals:**
- Gerenciamento de secrets para produção (o `.env` é para dev)
- Configuração de múltiplas fontes simultâneas (isso é responsabilidade do `LibrarySource` no app)
- CI/CD — pipelines ficam pra depois
- Variáveis para KOSync (v1.1, fora deste escopo)

## Decisions

### 1. `.env` na raiz do projeto (não dentro de `compose/`)

O `.env` fica na raiz porque alimenta **dois consumidores**: Docker Compose e Flutter. O Docker Compose será invocado com `--env-file ../.env` ou referenciará via path relativo. O Flutter usa `--dart-define-from-file` apontando para a raiz.

**Alternativa descartada**: `.env` dentro de `compose/` — obrigaria o Flutter a referenciar `compose/.env`, acoplando o build do app à estrutura do Docker.

### 2. `--dart-define-from-file` (não `flutter_dotenv`)

O Dart suporta `String.fromEnvironment()` nativamente quando as variáveis são passadas via `--dart-define`. Usar `--dart-define-from-file=.env` no `flutter run` injeta todas as variáveis do `.env` como compile-time constants — sem dependência extra.

**Alternativa descartada**: `flutter_dotenv` — adiciona dependência, lê em runtime (mais lento no startup), e o arquivo `.env` precisa ser incluído nos assets do app (risco de expor secrets no APK).

### 3. Classe `EnvConfig` estática com fallbacks

Uma classe Dart simples (`lib/core/config/env_config.dart`) expõe as variáveis como getters estáticos com `String.fromEnvironment` + fallback para valores de dev padrão. Isso garante que o app funciona mesmo sem `.env` (usa `http://10.0.2.2:8083` como default — funciona no emulador).

### 4. Docker Compose parametrizado parcialmente

Apenas a porta externa e timezone serão variáveis no `docker-compose.yml`. A imagem e volumes ficam fixos — não há cenário real de trocar a imagem do Calibre-Web entre ambientes.

## Risks / Trade-offs

- **[Risk]** Dev esquece de rodar com `--dart-define-from-file` → app usa fallbacks de emulador, que podem não funcionar no celular físico.
  → **Mitigation**: Documentar no README e criar script/alias de conveniência. Fallback é funcional no emulador, que é o cenário mais comum.

- **[Risk]** `.env` acidentalmente commitado com credenciais reais.
  → **Mitigation**: `.gitignore` já incluirá `.env`. O `.env.example` terá apenas valores de dev/placeholder.

- **[Trade-off]** `--dart-define-from-file` injeta valores em compile-time, não runtime. Trocar de ambiente exige rebuild.
  → Aceitável para dev. Em produção, o app terá UI de configuração de fontes (tela de Settings) — o `.env` é só para o default de dev.
