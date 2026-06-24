## 1. Providers

- [x] 1.1 Criar `lib/features/annotations/providers/annotations_providers.dart` com `allAnnotationsProvider` (StreamProvider que assiste todas as anotações com JOIN em books para título) e `bookAnnotationsProvider(bookId)` (StreamProvider.family)

## 2. Reader — seleção de texto e highlights

- [x] 2.1 Adicionar `onSelection` callback no `EpubViewer` do `ReaderScreen` que captura texto selecionado, CFI e coordenadas da seleção
- [x] 2.2 Implementar menu flutuante de seleção (`_SelectionMenu`) posicionado sobre a seleção, com opções: Destacar (4 circles de cor), Anotar, Copiar
- [x] 2.3 Implementar ação "Destacar": salva no `AnnotationsDao` com cor selecionada e chama `EpubController.addHighlight()`
- [x] 2.4 Implementar ação "Anotar": exibe `AlertDialog` com `TextField` para nota, salva destaque + nota, chama `addHighlight()`
- [x] 2.5 Implementar ação "Copiar": copia texto para clipboard via `Clipboard.setData()`
- [x] 2.6 Restaurar highlights salvos no `onEpubLoaded`: busca anotações do livro e chama `addHighlight()` para cada uma

## 3. AnnotationsScreen — tela global

- [x] 3.1 Reescrever `annotations_screen.dart` — lista agrupada por livro usando `allAnnotationsProvider`, com header por livro e items mostrando texto, nota, cor e data
- [x] 3.2 Implementar botão de export no header de cada livro que formata anotações como texto e copia para clipboard
- [x] 3.3 Implementar tap em anotação que navega para `/library/book/:id/read` (reader abre no CFI)
- [x] 3.4 Implementar swipe-to-delete em cada anotação com `Dismissible`
- [x] 3.5 Implementar empty state quando não há anotações

## 4. BookDetailScreen — aba anotações real

- [x] 4.1 Atualizar aba "Anotações" no `BookDetailScreen` para listar anotações reais do livro com tap para navegar ao CFI e swipe para deletar

## 5. Validação

- [x] 5.1 Verificar que o app compila sem erros (`flutter analyze`)
