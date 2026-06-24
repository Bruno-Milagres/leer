## Context

O `BooksDao` já tem `watchDownloaded()` que retorna stream de livros com `isDownloaded == true`. O `BookDownloadService` (M04) tem `deleteDownload(bookId, localPath)` que deleta o arquivo e reseta o banco. A `DownloadsScreen` é a segunda aba do navigation bar (índice 1 no `StatefulShellRoute`).

## Goals / Non-Goals

**Goals:**
- Lista de livros baixados com capa miniatura, título, autor, tamanho
- Tamanho total ocupado calculado a partir de `fileSizeKb` dos livros
- Swipe-to-delete que usa `BookDownloadService.deleteDownload()`
- Ordenação por 3 critérios: recentes, título, autor
- Tap navega para detalhe
- Empty state

**Non-Goals:**
- Download em batch (selecionar múltiplos para baixar)
- Limite de storage com alerta
- Progresso de download em tempo real na lista

## Decisions

### 1. StreamProvider reativo do watchDownloaded

`downloadsProvider` assiste `BooksDao.watchDownloaded()`. A lista é filtrada/ordenada em memória via `downloadsSortProvider` (StateProvider com enum).

### 2. Tamanho total via soma de fileSizeKb

O total é calculado client-side somando `fileSizeKb` de todos os livros na lista. Exibido como header fixo acima da lista. Para livros sem `fileSizeKb` (campo nullable), usamos 0.

### 3. Reutilizar BookDownloadService para delete

O swipe chama `BookDownloadService.deleteDownload()` que já existe. Após a deleção, o stream do drift notifica automaticamente a lista.

## Risks / Trade-offs

- **[Trade-off]** `fileSizeKb` pode ser null para alguns livros (metadado opcional do OPDS).
  → Exibimos "—" para livros sem tamanho e excluímos do total.
