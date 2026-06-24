## Why

O M04 implementou download de EPUB e o `BooksDao.watchDownloaded()` já existe, mas a tela de Downloads é placeholder. O usuário precisa ver quais livros estão disponíveis offline, quanto espaço ocupam, e poder remover downloads individualmente. É a terceira aba do navigation bar — precisa funcionar.

## What Changes

- Substituir o placeholder `DownloadsScreen` pela tela funcional conforme SPEC seção 5.5
- Lista de livros baixados com capa, título, autor e tamanho do arquivo
- Exibição do tamanho total ocupado no topo
- Swipe-to-delete para remover download individual (deleta arquivo + reseta estado no banco)
- Ordenação: recentes (padrão), título, autor — via chips ou dropdown
- Tap no livro navega para detalhe (`/library/book/:id`)
- Empty state quando não há downloads

## Capabilities

### New Capabilities
- `downloads-screen`: Tela de gestão de downloads offline — lista de livros baixados, tamanho total, remoção individual, ordenação

### Modified Capabilities

_(nenhuma spec existente requer mudança)_

## Impact

- **Arquivo reescrito**: `lib/features/downloads/presentation/downloads_screen.dart`
- **Arquivos novos**: `lib/features/downloads/providers/downloads_providers.dart`
- **Dependências usadas**: `BooksDao.watchDownloaded()` (já existe), `BookDownloadService.deleteDownload()` (já existe no M04)
