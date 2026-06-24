## 1. Download service

- [x] 1.1 Criar `lib/features/book_detail/services/book_download_service.dart` — baixa EPUB via `Dio.download()` com auth headers, salva em `getApplicationDocumentsDirectory()/books/{bookId}.epub`, atualiza `BooksDao.setDownloadState()`
- [x] 1.2 Adicionar método `deleteDownload(int bookId, String localPath)` que deleta o arquivo e reseta o estado no banco

## 2. Providers

- [x] 2.1 Criar `lib/features/book_detail/providers/book_detail_providers.dart` com `bookDetailProvider(bookId)` (FutureProvider.family), `bookProgressProvider(bookId)` (StreamProvider.family), `annotationCountProvider(bookId)` (FutureProvider.family)
- [x] 2.2 Adicionar provider para `BookDownloadService`

## 3. BookDetailScreen

- [x] 3.1 Reescrever `book_detail_screen.dart` — scaffold sem AppBar fixa, body com `CustomScrollView` contendo: header com blur + capa + metadados, seção de botões, abas
- [x] 3.2 Implementar header: fundo blur da capa (`ImageFilter.blur`), capa nítida centralizada com aspect ratio ~2:3, overlay escuro
- [x] 3.3 Implementar paleta dinâmica: `PaletteGenerator.fromImageProvider()` extrai cor dominante, `ColorScheme.fromSeed()` envolve a tela com `Theme()` override
- [x] 3.4 Implementar seção de metadados: título, autor, série com índice, stats (páginas, idioma, tamanho formatado)
- [x] 3.5 Implementar barra de progresso com label (percentual + capítulo) quando há progresso
- [x] 3.6 Implementar botão primário "Começar a Ler" / "Continuar Lendo" — navega para `/library/book/:id/read`, desabilitado se não baixado
- [x] 3.7 Implementar botão secundário "Baixar" / "Remover download" com estado de loading durante download
- [x] 3.8 Implementar abas com `DefaultTabController`: Descrição (texto scrollável) e Anotações (contagem + placeholder "Nenhuma anotação")
- [x] 3.9 Badge de contagem no tab Anotações quando count > 0

## 4. Validação

- [x] 4.1 Verificar que o app compila sem erros (`flutter analyze`)
