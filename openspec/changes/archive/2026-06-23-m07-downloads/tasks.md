## 1. Providers

- [x] 1.1 Criar `lib/features/downloads/providers/downloads_providers.dart` com `downloadsProvider` (StreamProvider que assiste `watchDownloaded()`), `downloadsSortProvider` (StateProvider com enum: recent, title, author), e `sortedDownloadsProvider` que aplica ordenação

## 2. DownloadsScreen

- [x] 2.1 Reescrever `downloads_screen.dart` — AppBar com título "Downloads", body com header de tamanho total + lista de livros baixados
- [x] 2.2 Implementar header com tamanho total ocupado (soma de `fileSizeKb`, formatado como KB/MB)
- [x] 2.3 Implementar chips de ordenação (Recentes / Título / Autor) acima da lista
- [x] 2.4 Implementar item de lista com capa miniatura (48x72), título, autor e tamanho, com tap navegando para `/library/book/:id`
- [x] 2.5 Implementar swipe-to-delete com `Dismissible` que chama `BookDownloadService.deleteDownload()`
- [x] 2.6 Implementar empty state com `EmptyStateView`

## 3. Validação

- [x] 3.1 Verificar que o app compila sem erros (`flutter analyze`)
