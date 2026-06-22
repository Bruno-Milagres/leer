## Why

O projeto **Leer** existe hoje apenas como especificação (`SPEC.md`) — não há código, estrutura de pastas, nem dependências configuradas. Para sair do papel precisamos de uma fundação executável: o scaffold Flutter, o tema Material You, a navegação, o banco local e os serviços de base que todos os módulos posteriores (M02–M10) vão consumir. Esta mudança estabelece essa fundação e divide o restante do trabalho em uma estrutura de tasks pronta para implementação incremental.

## What Changes

- Cria o projeto Flutter `com.brm.leer` (min SDK 26) com `pubspec.yaml` e todas as dependências do stack (riverpod, go_router, drift, dio, xml, flutter_epub_viewer, dynamic_color, palette_generator, etc.).
- Define a estrutura de diretórios `lib/core`, `lib/features`, `lib/shared`, `assets/` e `test/` conforme a seção 11 do SPEC.
- Implementa o **tema** (paleta warm-dark/light, tipografia Playfair/Inter/Literata, tokens de raio e animação) com suporte a Material You dinâmico e fallback.
- Implementa a **navegação** com `go_router` (shell com `NavigationBar` de 3 destinos) e todas as rotas declaradas.
- Implementa o **schema do banco local** com drift (`servers`, `books`, `reading_progress`, `annotations`) e os DAOs base.
- Implementa o **serviço OPDS** (conexão Calibre-Web, parse de feed Atom/XML, sync da biblioteca) e o gerenciamento de servidores com credenciais em `flutter_secure_storage`.
- Implementa as telas de feature: biblioteca (grid/filtros), detalhe do livro, leitor EPUB, downloads, anotações, configurações e onboarding.
- Implementa widgets compartilhados (shimmer, estados de erro, estados vazios).
- Estabelece a **estrutura de tasks pré-dividida** por módulo (M01–M10) para guiar a implementação.

## Capabilities

### New Capabilities

- `app-foundation`: scaffold do projeto, tema Material You, tipografia, tokens visuais, shell de navegação e widgets compartilhados de estado (shimmer/erro/vazio).
- `local-database`: schema drift (`servers`, `books`, `reading_progress`, `annotations`), DAOs e migrações.
- `server-management`: cadastro de múltiplos servidores Calibre-Web, validação de endpoint OPDS, servidor ativo e credenciais seguras.
- `opds-sync`: conexão com Calibre-Web, parse do feed OPDS 1.2 e sincronização da biblioteca para o banco local.
- `library-browsing`: tela de biblioteca em grid de 2 colunas, chips de filtro, drawer lateral, pull-to-refresh e estados de carregamento/vazio.
- `book-detail`: tela de detalhe com paleta dinâmica extraída da capa, stats, progresso, download e abas descrição/anotações.
- `epub-reader`: leitor EPUB com UI hide/show, temas de leitura, configurações de fonte, virada de página e persistência de progresso (CFI).
- `annotations`: destaques e notas no leitor, lista global agrupada por livro e exportação de texto.
- `downloads`: gestão de livros offline, tamanho ocupado, remoção e ordenação.
- `onboarding`: fluxo de primeiro acesso com configuração guiada do servidor.

### Modified Capabilities

<!-- Nenhuma. Projeto greenfield, sem specs existentes. -->

## Impact

- **Código**: cria toda a árvore `lib/`, `assets/`, `test/` e `pubspec.yaml`. Projeto greenfield — nenhum código existente é afetado.
- **Dependências**: introduz todo o stack da seção 3 do SPEC.
- **Plataforma**: Android min SDK 26; iOS fora de escopo na v1.
- **Backend**: depende de uma instância Calibre-Web com OPDS habilitado para uso real (não para build/testes).
