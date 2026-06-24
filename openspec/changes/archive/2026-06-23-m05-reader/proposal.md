## Why

O leitor é a funcionalidade central do app — sem ele, o Leer não cumpre seu propósito. M04 já entrega o botão "Começar a Ler" que navega para `/library/book/:id/read`, mas a tela é placeholder. O `flutter_epub_viewer` já está no pubspec e o fluxo de download de EPUB está funcional. É hora de integrar o viewer real.

## What Changes

- Substituir o placeholder `ReaderScreen` pelo leitor EPUB funcional via `flutter_epub_viewer`
- Interface limpa durante leitura: imersão total, sem app bar ou navigation bar
- Tap no centro revela/oculta controles com animação fade:
  - Topo: título do livro + botão fechar (X)
  - Base: slider de progresso + nome do capítulo
- Temas de leitura: Claro / Sépia / Escuro / AMOLED
- Configurações de fonte: família (Literata padrão, + opções), tamanho, espaçamento entre linhas
- Progresso salvo automaticamente via CFI a cada mudança de página
- Restauração da posição ao reabrir o livro (lê CFI salvo do banco)

## Capabilities

### New Capabilities
- `epub-reader`: Leitor EPUB imersivo com controles hide/show, temas de leitura, configuração de fonte, salvamento automático de progresso via CFI

### Modified Capabilities

_(nenhuma spec existente requer mudança)_

## Impact

- **Arquivo reescrito**: `lib/features/reader/presentation/reader_screen.dart`
- **Arquivos novos**: `lib/features/reader/providers/reader_providers.dart`, `lib/features/reader/presentation/reader_controls.dart`
- **Dependências usadas**: `flutter_epub_viewer` (já no pubspec)
- **DAOs**: `ReadingProgressDao.save()`, `ReadingProgressDao.getForBook()`, `BooksDao.getById()` (já existem)
- **Fora de escopo**: anotações (M06), KOSync (v1.1)
