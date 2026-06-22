## Context

O Leer é um projeto greenfield: existe apenas o `SPEC.md`. Esta mudança constrói a fundação executável e a arquitetura que todos os módulos (M01–M10) vão usar. As principais restrições vêm do SPEC: Flutter 3.32/Dart 3.8, pacote `com.brm.leer`, Android min SDK 26, backend Calibre-Web via OPDS 1.2, leitura EPUB, sem telemetria, licença MIT, offline-capable e Material You.

A complexidade que justifica um design: o app é cross-cutting (10 capabilities), introduz todo um stack novo (riverpod/drift/dio/go_router/flutter_epub_viewer), tem modelo de dados não trivial e uma camada de sincronização OPDS com merge de estado local. Decisões tomadas aqui evitam retrabalho ao longo dos módulos.

## Goals / Non-Goals

**Goals:**
- Definir a arquitetura em camadas (core / features / shared) e o padrão de cada feature (data → repository → controller riverpod → UI).
- Fixar as escolhas de state management, navegação, persistência e rede para que os módulos seguintes apenas preencham.
- Garantir que o sync OPDS preserve estado local (download, progresso, anotações).
- Estabelecer o sistema de tema (Material You + paleta dinâmica por capa) e tipografia.

**Non-Goals:**
- Sincronização de progresso com o servidor (local-only na v1).
- iOS, audiobooks, DRM, conversão de PDF no app, loja integrada, multi-usuário (seção 10 do SPEC).
- Implementação final de cada tela — isto é coberto pelos módulos M03–M10; aqui definimos a estrutura e os contratos.

## Decisions

### Arquitetura em camadas por feature
Cada feature em `lib/features/<nome>/` segue: `data/` (models, mapeamento OPDS/drift), `application/` (controllers/notifiers riverpod + estado), `presentation/` (screens + widgets). O `lib/core/` concentra database, opds, theme e router compartilhados; `lib/shared/widgets/` os componentes de estado (shimmer/erro/vazio).
- **Alternativa considerada**: arquitetura por camada global (todos os models juntos, todas as telas juntas). Rejeitada por dificultar a navegação do código conforme o app cresce.

### Riverpod como state management
Usar `riverpod` 2.x com `AsyncNotifier`/`Notifier` providers. Repositórios expostos como providers, DAOs drift consumidos via streams para reatividade. 
- **Por quê**: integra naturalmente com streams do drift e com estados async (loading/error/data) exigidos pelos estados de UI da seção 8.
- **Alternativa**: bloc. Rejeitada por verbosidade frente ao tamanho do app e à reatividade nativa do drift.

### drift para persistência com mapeamento direto do SPEC
As 4 tabelas seguem literalmente a seção 5. `tags` como TEXT JSON. Senha NÃO vai para a tabela `servers` — só uma referência; o valor real fica em `flutter_secure_storage` com chave derivada do `server.id`.
- **Por quê**: drift dá streams reativos + migrações versionadas; secure storage atende ao requisito de não persistir credenciais em claro.

### Camada OPDS isolada em core/opds
`OpdsService` (dio + parse `xml`) retorna modelos puros; um `LibrarySyncService` faz o merge no drift. O merge usa `calibre_id` + `server_id` como chave natural para decidir insert vs. update, e nunca sobrescreve `local_epub_path`, `is_downloaded` nem registros de `reading_progress`/`annotations`.
- **Por quê**: separar transporte/parse da persistência facilita testes (parse testável com fixtures XML) e protege o estado offline do usuário.

### Tema: dynamic_color + PaletteGenerator
`dynamic_color` fornece o esquema do sistema (Android 12+); fallback para os hex do SPEC. Na tela de detalhe e como acento contextual, `palette_generator` extrai a cor dominante da capa. Tokens (raios, durações) centralizados em `core/theme`.
- **Alternativa**: tema estático. Rejeitada porque Material You é um princípio explícito do SPEC.

### Navegação: go_router com ShellRoute
Um `ShellRoute` envolve Biblioteca/Downloads/Configurações com `NavigationBar`; rotas de leitura (`/library/book/:id/read`) ficam fora do shell para ocultar a barra. Redirect de `/` para `/library`, e redirect global para `/onboarding` quando não há servidor.
- **Por quê**: atende ao requisito de NavigationBar oculta na leitura e ao fluxo de primeiro acesso.

### EPUB via flutter_epub_viewer (WebView)
O leitor encapsula o WebView do `flutter_epub_viewer`. Progresso persistido por CFI a cada virada; anotações ancoradas por CFI. Temas de leitura aplicados via injeção de estilo no viewer.
- **Risco conhecido**: a API de CFI/seleção do plugin pode variar entre versões — encapsular num adapter (`ReaderController`) para isolar o app dessas mudanças.

## Risks / Trade-offs

- **API do flutter_epub_viewer instável (CFI, seleção de texto, temas)** → Encapsular toda interação atrás de um `ReaderController`/adapter; cobrir o mapeamento de CFI com testes; fixar versão no pubspec.
- **Variações de feed OPDS entre versões do Calibre-Web** → Parser tolerante a campos ausentes (já refletido nas specs) e testes com fixtures XML reais.
- **Merge de sync apagando estado offline** → Regra explícita de preservação de `local_epub_path`/`is_downloaded`/progresso/anotações; testar o caminho de re-sync.
- **Credenciais em secure storage vs. referência no banco** → Garantir limpeza do secure storage ao remover um servidor para não deixar credenciais órfãs.
- **Escopo grande numa única mudança** → Tasks pré-divididas por módulo (M01–M10) permitem implementação e revisão incrementais; M01 entrega a fundação compilável antes dos demais.

## Migration Plan

Projeto greenfield — sem migração de dados. Sequência de entrega: M01 (fundação compilável) → M02 (OPDS) → M03–M09 (features) → M10 (polish). Cada módulo é mergeável de forma independente sobre a fundação. Rollback = reverter os commits do módulo; o schema do banco é versionado desde a v1 para suportar migrações futuras.

## Open Questions

- Versão exata a fixar de `flutter_epub_viewer` (o SPEC diz "latest") — decidir na M05 após validar a API de CFI/seleção.
- Estratégia de paginação do feed OPDS para bibliotecas grandes (feed único vs. páginas) — avaliar na M02 conforme comportamento real do Calibre-Web.
- Necessidade de busca textual na biblioteca além dos filtros — fora do SPEC v1; confirmar com o usuário se deve entrar.
