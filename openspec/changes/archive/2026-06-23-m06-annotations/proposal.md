## Why

O leitor já funciona (M05) mas não permite interagir com o texto — destacar, anotar ou copiar. As anotações são um diferencial de leitores sérios e o SPEC define isso como v1. Além disso, a tela global de Anotações é placeholder e a aba "Anotações" no detalhe do livro (M04) mostra "Nenhuma anotação" sem funcionalidade real. O `AnnotationsDao` e a tabela `annotations` já existem desde M01 — falta a UI e a integração com o reader.

## What Changes

- Integrar seleção de texto no `ReaderScreen`: pressão longa seleciona texto → menu flutuante com opções Destacar / Anotar / Copiar
- Suporte a 4 cores de destaque (amarelo, verde, azul, rosa) conforme `AppColors.highlightColors`
- Renderizar highlights salvos no viewer via `EpubController.addHighlight()`
- Implementar a tela global `AnnotationsScreen`: lista de todas as anotações agrupadas por livro
- Exportação em texto simples (copiar para clipboard)
- Tap em anotação navega para o livro na posição exata (CFI)
- Atualizar aba "Anotações" no `BookDetailScreen` para listar anotações reais do livro

## Capabilities

### New Capabilities
- `annotations`: Criação de destaques/notas no reader, tela global de anotações agrupada por livro, export para clipboard, navegação por CFI

### Modified Capabilities

_(nenhuma spec existente requer mudança de requisitos)_

## Impact

- **Arquivos modificados**: `lib/features/reader/presentation/reader_screen.dart` (seleção de texto + highlights), `lib/features/book_detail/presentation/book_detail_screen.dart` (aba anotações real)
- **Arquivo reescrito**: `lib/features/annotations/presentation/annotations_screen.dart`
- **Arquivos novos**: `lib/features/annotations/providers/annotations_providers.dart`
- **Dependências usadas**: `AnnotationsDao` (já existe), `EpubController.addHighlight()` (já disponível no pacote)
