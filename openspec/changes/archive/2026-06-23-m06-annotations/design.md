## Context

M05 entregou o leitor EPUB funcional com `onTextSelected` e `onSelection` callbacks disponíveis no `EpubViewer`. O `EpubController` expõe `addHighlight(cfi, color, opacity)` e `removeHighlight(cfi)`. A tabela `annotations` tem campos `bookId`, `cfi`, `selectedText`, `note`, `color`, `createdAt`. O `AnnotationsDao` tem `watchAll()`, `watchForBook()`, `countForBook()`, `insertAnnotation()`, `deleteAnnotation()`. O `BookDetailScreen` já tem aba "Anotações" com placeholder.

## Goals / Non-Goals

**Goals:**
- Menu de seleção no reader com Destacar (4 cores) / Anotar / Copiar
- Highlights renderizados no viewer ao carregar o livro (restauração)
- Tela global de anotações agrupada por livro
- Export: copiar todas anotações de um livro para clipboard
- Tap em anotação navega para `/library/book/:id/read` com CFI
- Aba real de anotações no detalhe do livro

**Non-Goals:**
- Edição de anotação existente (v1 só cria e deleta)
- Sync de anotações entre dispositivos (backlog)
- Exportação em formato estruturado (Markdown, JSON) — apenas texto simples

## Decisions

### 1. Menu de seleção via onSelection callback

Usamos `onSelection` do `EpubViewer` que fornece coordenadas relativas ao WebView. Quando o callback dispara, exibimos um `Positioned` widget (menu flutuante) posicionado acima da seleção com as opções. O menu usa `Stack` + `Overlay` para ficar sobre o viewer.

Alternativa descartada: `selectionContextMenu` nativo — limitado visualmente e não permite cores customizadas.

### 2. Highlights restaurados no onEpubLoaded

Ao carregar o EPUB (`onEpubLoaded`), buscamos todas as anotações do livro via `AnnotationsDao.watchForBook()` e chamamos `EpubController.addHighlight()` para cada uma. Isso restaura os highlights visuais no viewer.

### 3. Tela global com SliverList agrupada

A `AnnotationsScreen` usa um `StreamProvider` que assiste `AnnotationsDao.watchAll()` com JOIN em `books` para obter o título. Agrupa por livro usando headers de seção. Cada item mostra: texto destacado, nota (se houver), cor, e data.

### 4. Export via Clipboard

Botão "Copiar" por livro formata todas as anotações como texto simples:
```
📖 Título do Livro
---
"texto destacado"
→ nota (se houver)

"outro texto"
---
```
E copia para clipboard via `Clipboard.setData()`.

## Risks / Trade-offs

- **[Risk]** `addHighlight` pode não suportar restauração se o viewer renderiza páginas sob demanda.
  → **Mitigation**: O epubjs (base do viewer) indexa highlights por CFI globalmente, então funciona independente da página visível.

- **[Trade-off]** Sem edição de anotações — apenas criar e deletar.
  → Aceitável para v1. Edição inline adiciona complexidade de UI que não justifica no MVP.
