## Context

M04 entrega o botão "Começar a Ler" / "Continuar Lendo" que navega para `/library/book/:id/read`. O `ReaderScreen` recebe `bookId` e é placeholder. O banco tem `ReadingProgressDao` com `save()` e `getForBook()`. Livros baixados têm `localEpubPath` preenchido. O `flutter_epub_viewer` expõe o widget `EpubViewer` que renderiza EPUB em WebView nativa.

## Goals / Non-Goals

**Goals:**
- Leitor EPUB funcional com `flutter_epub_viewer`
- Interface imersiva: tela cheia, controles aparecem/desaparecem com tap
- 4 temas de leitura (Claro, Sépia, Escuro, AMOLED)
- Configuração de fonte (família, tamanho, espaçamento)
- Progresso salvo em CFI automaticamente a cada página
- Restaurar posição ao reabrir livro

**Non-Goals:**
- Anotações/destaques (M06)
- Sync de progresso KOSync (v1.1)
- Virada de página com parallax customizado (o viewer tem seu próprio gesto)
- Busca no texto

## Decisions

### 1. EpubViewer como widget central

O `EpubViewer` do pacote `flutter_epub_viewer` recebe o path do arquivo EPUB e callbacks. Ele gerencia a renderização, paginação e gestos internamente via WebView. Usamos:
- `epubSource: EpubSource.fromFile(File(path))` para carregar do caminho local
- `initialCfi` para restaurar posição
- `onChapterChanged` para atualizar capítulo nos controles
- `onPageChanged` / `onRelocated` para salvar progresso (CFI + percentage)
- `onTextSelected` para futuro suporte a anotações (M06 — por ora não tratamos)

### 2. Controles via Stack + AnimatedOpacity

O `ReaderScreen` é um `Stack`:
- Camada inferior: `EpubViewer` fullscreen
- Camada superior: controles (top bar + bottom bar) com `AnimatedOpacity`
- `GestureDetector` transparente no centro para toggle dos controles
- `IgnorePointer` nos controles quando ocultos para não interceptar gestos do viewer

### 3. Temas de leitura como EpubTheme

Cada tema (Claro/Sépia/Escuro/AMOLED) define `backgroundColor` e `textColor` passados ao `EpubViewer` via `epubDisplaySettings`. O tema do reader é independente do tema do app — o usuário pode estar em dark mode no app mas ler em sépia.

Armazenamos a preferência de tema/fonte em `SharedPreferences` (leve, não precisa de drift). Para v1, usamos `StateProvider` em memória — persistência de preferências de leitura vem no M08 Settings.

### 4. Salvamento de progresso debounced

A cada `onRelocated`, salvamos CFI + percentage no `ReadingProgressDao`. Para evitar writes excessivos, aplicamos debounce de 1 segundo — só salva se nenhuma nova página vier em 1s.

### 5. Configuração de fonte via bottom sheet

Tap no ícone de settings (Aa) nos controles abre um `showModalBottomSheet` com:
- Selector de família (Literata, Georgia, Open Sans, Roboto Slab)
- Slider de tamanho (12–28, default 18)
- Slider de espaçamento (1.0–2.5, default 1.5)

Mudanças aplicadas em tempo real via controller do `EpubViewer`.

## Risks / Trade-offs

- **[Risk]** O `flutter_epub_viewer` pode ter limitações de API que impeçam algum controle (ex: tema aplicado via CSS injection).
  → **Mitigation**: O pacote suporta `EpubDisplaySettings` com fontSize, fontFamily, textColor, backgroundColor. Se algo faltar, podemos injetar CSS custom.

- **[Trade-off]** Preferências de leitura ficam em memória (não persistidas) até M08.
  → Aceitável — são 3 campos e o default (Literata, 18, 1.5) funciona bem. Persistência virá.

- **[Risk]** Debounce de progresso pode perder a última página se o app for killado.
  → **Mitigation**: Também salvamos ao sair da tela (`dispose` / `WillPopScope`).
