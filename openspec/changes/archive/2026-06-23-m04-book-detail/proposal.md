## Why

A tela de detalhe do livro é o ponto de decisão do usuário — é onde ele vê as informações completas, decide se vai ler, baixar ou ver anotações. Hoje é um placeholder. Com o M03 entregando o grid funcional com navegação para `/library/book/:id`, o detalhe é o próximo passo natural para fechar o loop de navegação. Sem ele, o tap no card leva a uma tela vazia.

## What Changes

- Substituir o placeholder `BookDetailScreen` pela tela completa conforme SPEC seção 5.3
- Capa grande centralizada com fundo desfocado (blur da própria capa)
- Paleta dinâmica extraída da capa via `PaletteGenerator` que colore o tema da tela
- Informações: título, autor, série com índice, stats (páginas, idioma, tamanho)
- Barra de progresso com label quando há progresso de leitura
- Botão primário "Começar a Ler" / "Continuar Lendo" — navega para reader
- Botão secundário "Baixar" / "Remover download" com indicador de progresso
- Abas: Descrição | Anotações (com badge de contagem)
- Download do EPUB via Dio com salvamento local

## Capabilities

### New Capabilities
- `book-detail`: Tela de detalhe do livro — exibe informações completas, paleta dinâmica da capa, download de EPUB, navegação para reader, abas de descrição/anotações

### Modified Capabilities

_(nenhuma spec existente requer mudança de requisitos)_

## Impact

- **Arquivo reescrito**: `lib/features/book_detail/presentation/book_detail_screen.dart`
- **Arquivos novos**: `lib/features/book_detail/providers/book_detail_providers.dart`, `lib/features/book_detail/services/book_download_service.dart`
- **Dependências usadas**: `palette_generator`, `cached_network_image`, `dio`, `path_provider` (todas já no pubspec)
- **DAOs**: usa `BooksDao.getById()`, `ReadingProgressDao.watchForBook()`, `AnnotationsDao.countForBook()` (já existem)
