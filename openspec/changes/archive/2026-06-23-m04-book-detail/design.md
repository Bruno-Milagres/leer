## Context

M03 entregou o grid de livros com navegação para `/library/book/:id`. O `BookDetailScreen` recebe `bookId` e é placeholder. O banco já tem `BooksDao.getById()`, `ReadingProgressDao.watchForBook()` e `AnnotationsDao.countForBook()`. O `SecureCredentialStore` permite ler a senha do servidor. O `OpdsClient` resolve URLs absolutas de download no fetch.

A tela de detalhe é a mais visualmente rica do app — fundo blur, paleta dinâmica, abas. É onde o download de EPUB acontece pela primeira vez.

## Goals / Non-Goals

**Goals:**
- Tela de detalhe completa conforme SPEC 5.3
- Paleta dinâmica extraída da capa via `PaletteGenerator`
- Download de EPUB com salvamento local e atualização de estado no banco
- Botões de ação contextual (ler/baixar/remover download)
- Abas Descrição + Anotações com badge de contagem

**Non-Goals:**
- Leitor EPUB (M05)
- Lista de anotações editável (M06 — aqui só exibe contagem no badge)
- Download com progresso em tempo real (snackbar de início/fim é suficiente para v1)
- Multi-fonte / badge de origem (M09 — por ora é sempre Calibre)

## Decisions

### 1. PaletteGenerator para tema dinâmico da tela

A capa do livro é carregada como `ImageProvider`, passada para `PaletteGenerator.fromImageProvider()`, e a cor dominante (`dominantColor`) é usada para gerar um `ColorScheme.fromSeed()` que envolve a tela num `Theme()` override. Se a capa não existir ou falhar, usa o tema padrão do app.

**Alternativa descartada**: `dynamic_color` — esse é para Material You do sistema, não para cores extraídas de uma imagem arbitrária.

### 2. Fundo desfocado com ImageFiltered

O fundo é a capa do livro renderizada em fullscreen com `BoxFit.cover` + `ImageFilter.blur(sigmaX: 25, sigmaY: 25)` + overlay semi-transparente escuro. A capa nítida fica centralizada sobre o blur.

### 3. Download service simples com Dio

`BookDownloadService` encapsula: baixa o EPUB via `Dio.download()` com auth headers, salva em `getApplicationDocumentsDirectory()` + `books/{bookId}.epub`, atualiza `BooksDao.setDownloadState()`. Sem fila, sem progresso granular — um `Future<void>` que o provider chama.

**Alternativa descartada**: package de download manager — overengineering para v1 com downloads sequenciais.

### 4. FutureProvider para livro + StreamProvider para progresso

- `bookDetailProvider(bookId)` — `FutureProvider.family` que busca `BooksDao.getById()`
- `bookProgressProvider(bookId)` — `StreamProvider.family` que assiste `ReadingProgressDao.watchForBook()`
- `annotationCountProvider(bookId)` — `FutureProvider.family` que busca `AnnotationsDao.countForBook()`

O livro é `FutureProvider` (não muda em tempo real na tela de detalhe), mas o progresso é stream (pode mudar se o user voltar do reader).

### 5. Abas com DefaultTabController

`DefaultTabController` com 2 tabs: Descrição (texto scrollável) e Anotações (placeholder com contagem — lista completa vem no M06). O badge no tab "Anotações" mostra o count quando > 0.

## Risks / Trade-offs

- **[Risk]** `PaletteGenerator.fromImageProvider()` pode ser lento em capas grandes.
  → **Mitigation**: Usar `maximumColorCount: 4` e `timeout`. Se falhar, fallback pro tema do app.

- **[Trade-off]** Download não mostra progresso em % — apenas estado (não baixado / baixando / baixado).
  → Aceitável para v1. EPUBs são tipicamente <5MB. Progresso granular pode vir no M11 Polish.

- **[Risk]** Fundo blur pode ter jank em dispositivos fracos.
  → **Mitigation**: O blur é estático (não anima), então o custo é só no build inicial.
