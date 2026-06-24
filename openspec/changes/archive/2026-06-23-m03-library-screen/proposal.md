## Why

A tela de Biblioteca é a home do app — o primeiro ponto de contato do usuário após configurar um servidor. Hoje é um placeholder (`"em construção (M03)"`). O M01/M02 já entregam o tema, navegação, drift schema, OPDS client e sync service. Tudo está pronto para montar a tela real que exibe livros, permite filtrar e sincronizar com o Calibre-Web.

## What Changes

- Substituir o placeholder `LibraryScreen` por um grid de 2 colunas com cards de livro (capa, título, autor, barra de progresso)
- Implementar o provider de livros que assiste a tabela `books` do servidor ativo
- Criar `BookCard` widget reutilizável com capa via `cached_network_image` e layout conforme SPEC seção 5.2
- Adicionar chips de filtro horizontais: Todos / Lendo / Baixados / Por Série
- Implementar shimmer loading usando o `ShimmerBox` existente durante carregamento
- Implementar pull-to-refresh que dispara sync OPDS via `LibrarySyncService`
- Exibir `EmptyStateView` quando a biblioteca está vazia
- Exibir `ErrorStateView` quando o servidor está inacessível

## Capabilities

### New Capabilities
- `library-screen`: Tela principal de biblioteca — grid de livros, filtros por chip, pull-to-refresh com sync OPDS, estados de loading/empty/error

### Modified Capabilities

_(nenhuma spec existente requer mudança de requisitos)_

## Impact

- **Arquivo reescrito**: `lib/features/library/presentation/library_screen.dart`
- **Arquivos novos**: `lib/features/library/presentation/book_card.dart`, `lib/features/library/providers/library_providers.dart`
- **Dependências usadas**: `cached_network_image` (já no pubspec), `flutter_riverpod` (já no pubspec)
- **Providers novos**: `libraryBooksProvider`, `libraryFilterProvider`
- **Sem breaking changes**: nenhuma API pública alterada, apenas a UI do placeholder é substituída
