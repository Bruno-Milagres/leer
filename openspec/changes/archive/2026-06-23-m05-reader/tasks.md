## 1. Providers

- [x] 1.1 Criar `lib/features/reader/providers/reader_providers.dart` com `readerBookProvider(bookId)` (FutureProvider.family que busca livro + progresso salvo), e `readerSettingsProvider` (StateProvider com tema, fontFamily, fontSize, lineSpacing)

## 2. Reader controls

- [x] 2.1 Criar `lib/features/reader/presentation/reader_controls.dart` — widget com barra superior (título + botão X) e barra inferior (nome do capítulo + slider de progresso), envolvidos em `AnimatedOpacity`
- [x] 2.2 Adicionar botão de settings (ícone Aa) na barra superior que abre bottom sheet de configuração de fonte (família, tamanho, espaçamento) e seletor de tema de leitura (4 círculos coloridos)

## 3. ReaderScreen

- [x] 3.1 Reescrever `reader_screen.dart` — carrega livro e progresso via provider, verifica que `localEpubPath` existe, exibe erro se não
- [x] 3.2 Integrar `EpubViewer` fullscreen com `EpubSource.fromFile`, passando `initialCfi` do progresso salvo e `EpubDisplaySettings` (tema + fonte)
- [x] 3.3 Implementar Stack com `EpubViewer` + `ReaderControls` overlay, com `GestureDetector` no centro para toggle visibilidade
- [x] 3.4 Implementar callback `onChapterChanged` que atualiza o nome do capítulo nos controles
- [x] 3.5 Implementar callback `onRelocated`/`onPageChanged` com debounce de 1s que salva CFI + percentage + chapter no `ReadingProgressDao`
- [x] 3.6 Salvar progresso ao sair da tela (dispose / PopScope)
- [x] 3.7 Aplicar system UI overlay style para imersão (status bar transparente, navigation bar oculta)

## 4. Temas de leitura

- [x] 4.1 Definir os 4 temas de leitura (Claro, Sépia, Escuro, AMOLED) como constantes com backgroundColor e textColor, e aplicar via `EpubDisplaySettings` ao viewer

## 5. Validação

- [x] 5.1 Verificar que o app compila sem erros (`flutter analyze`)
