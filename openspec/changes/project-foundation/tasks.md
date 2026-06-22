## 1. M01 · Foundation — scaffold e dependências

- [x] 1.1 Criar projeto Flutter `com.brm.leer` (org `com.brm`, min SDK 26) e configurar `pubspec.yaml` com o stack da seção 3 do SPEC
- [x] 1.2 Criar a árvore de diretórios: `lib/core/{database,opds,theme,router}`, `lib/features/{library,reader,downloads,annotations,settings,onboarding,book_detail}`, `lib/shared/widgets`, `assets/{fonts,illustrations}`, `test/`
- [x] 1.3 Adicionar fontes (Playfair Display, Inter, Literata) em `assets/fonts` e declará-las no `pubspec.yaml`
- [x] 1.4 Configurar `flutter_lints`/`analysis_options.yaml` e licença MIT
- [x] 1.5 Criar `main.dart` e `app.dart` com `ProviderScope` (riverpod) e `MaterialApp.router`

## 2. M01 · Foundation — tema e tipografia

- [x] 2.1 Implementar `core/theme/colors.dart` com paletas warm-dark e light (valores da seção 7)
- [x] 2.2 Implementar `core/theme/typography.dart` com TextTheme (Playfair títulos, Inter UI, Literata leitura)
- [x] 2.3 Implementar `core/theme/tokens.dart` (raios de card/sheet/chip/botão, duração 250ms)
- [x] 2.4 Integrar `dynamic_color` com fallback para os primaries do SPEC; expor `lightTheme`/`darkTheme`
- [x] 2.5 Implementar widgets compartilhados em `shared/widgets`: shimmer, estado de erro com retry, estado vazio com CTA

## 3. M01 · Foundation — banco local (drift)

- [x] 3.1 Definir tabelas drift `servers`, `books`, `reading_progress`, `annotations` conforme seção 5
- [x] 3.2 Configurar `AppDatabase` (schemaVersion 1, conexão via `path_provider`) e geração de código (`build_runner`)
- [x] 3.3 Implementar DAOs: `ServersDao`, `BooksDao` (com streams reativos), `ReadingProgressDao`, `AnnotationsDao`
- [x] 3.4 Implementar estratégia de migração e teste de abertura de banco

## 4. M01 · Foundation — navegação (go_router)

- [x] 4.1 Implementar `core/router/app_router.dart` com todas as rotas da seção 6
- [x] 4.2 Configurar `ShellRoute` com `NavigationBar` (Biblioteca / Downloads / Configurações) e manter rotas de leitura fora do shell
- [x] 4.3 Implementar redirect `/`→`/library` e redirect para `/onboarding` quando não há servidor configurado

## 5. M02 · OPDS Service

- [x] 5.1 Implementar `core/opds/opds_client.dart` (dio com auth básica, leitura de credenciais do secure storage)
- [x] 5.2 Implementar `core/opds/opds_parser.dart` (parse Atom/XML → modelos), tolerante a campos opcionais ausentes
- [x] 5.3 Implementar `LibrarySyncService` com merge no drift preservando `local_epub_path`/`is_downloaded`/progresso/anotações
- [x] 5.4 Tratar erros (401, host inacessível, feed inválido) com tipos de erro consumíveis pela UI
- [ ] 5.5 Testes de parse com fixtures XML reais e teste de re-sync preservando estado local

## 6. M03 · Library Screen

- [ ] 6.1 Implementar controller riverpod da biblioteca (lista reativa do servidor ativo + filtros)
- [ ] 6.2 Implementar `LibraryScreen` com grid de 2 colunas e `BookCard` (capa, título 2 linhas, autor, barra de progresso)
- [ ] 6.3 Implementar chips de filtro horizontais (Todos / Lendo / Baixados / Por Série)
- [ ] 6.4 Implementar drawer lateral de filtro por autor, série, tag e status
- [ ] 6.5 Implementar pull-to-refresh (dispara sync OPDS), shimmer grid (8 placeholders) e estado vazio com CTA
- [ ] 6.6 Integrar `cached_network_image` para capas

## 7. M04 · Book Detail

- [ ] 7.1 Implementar controller riverpod do detalhe (livro + progresso + contagem de anotações)
- [ ] 7.2 Implementar `BookDetailScreen` (capa grande, fundo desfocado da capa, título/autor/série, stats)
- [ ] 7.3 Extrair paleta dominante da capa via `palette_generator` e tematizar a tela
- [ ] 7.4 Implementar barra de progresso com label ("34% · Capítulo 5")
- [ ] 7.5 Implementar botões primário (Continuar/Começar a Ler) e secundário (Baixar/Remover download) conforme estado
- [ ] 7.6 Implementar abas Descrição | Anotações com badge de contagem

## 8. M05 · Reader

- [ ] 8.1 Implementar `ReaderController` (adapter) encapsulando `flutter_epub_viewer` (CFI, capítulo, seleção)
- [ ] 8.2 Implementar `ReaderScreen` em tela cheia, sem app bar/nav, restaurando CFI salvo na abertura
- [ ] 8.3 Implementar download sob demanda ao abrir o leitor de um livro não baixado
- [ ] 8.4 Implementar controles sobrepostos com fade (topo: título + fechar; base: slider + capítulo) via tap central
- [ ] 8.5 Implementar temas de leitura (Claro / Sépia / Escuro / AMOLED) e configurações de fonte (família/tamanho/espaçamento) com persistência
- [ ] 8.6 Implementar virada de página por swipe com parallax leve
- [ ] 8.7 Persistir progresso (CFI, percentual, capítulo) em `reading_progress` a cada virada

## 9. M06 · Annotations

- [ ] 9.1 Implementar seleção por pressão longa no leitor com menu Destacar / Anotar / Copiar
- [ ] 9.2 Persistir destaques/notas em `annotations` (CFI, texto, cor; cores amarelo/verde/azul/rosa)
- [ ] 9.3 Renderizar destaques existentes ao reabrir o livro
- [ ] 9.4 Implementar `AnnotationsScreen` (lista global agrupada por livro)
- [ ] 9.5 Implementar tap na anotação → abrir livro no CFI exato
- [ ] 9.6 Implementar exportação em texto simples para a área de transferência

## 10. M07 · Downloads

- [ ] 10.1 Implementar serviço de download de EPUB via OPDS com armazenamento via `path_provider`
- [ ] 10.2 Atualizar `local_epub_path`/`is_downloaded` e exibir progresso linear no card durante o download
- [ ] 10.3 Implementar `DownloadsScreen` (lista de baixados, tamanho total ocupado, ordenação recentes/título/autor)
- [ ] 10.4 Implementar swipe para remover download (apaga arquivo, limpa flags, mantém livro na biblioteca)

## 11. M08 · Settings

- [ ] 11.1 Implementar `SettingsScreen` (entradas para servidor e preferências de leitura)
- [ ] 11.2 Implementar `ServerSettingsScreen`: cadastro/edição, múltiplos servidores, marcar ativo, testar conexão/validar OPDS
- [ ] 11.3 Armazenar credenciais em `flutter_secure_storage` e limpar ao remover servidor
- [ ] 11.4 Implementar `ReaderSettingsScreen` (tema de leitura padrão, fonte, tamanho, espaçamento)

## 12. M09 · Onboarding

- [ ] 12.1 Implementar `OnboardingScreen` (ilustração de estante + CTA) exibida quando não há servidor
- [ ] 12.2 Implementar configuração guiada do servidor a partir do onboarding, concluindo na biblioteca
- [ ] 12.3 Persistir flag de onboarding concluído e integrar com o redirect do router

## 13. M10 · Polish

- [ ] 13.1 Refinar transições e animações (250ms, Material standard easing) entre telas
- [ ] 13.2 Revisar todos os empty/error/loading states (seção 8) para consistência visual
- [ ] 13.3 Acessibilidade: semantics, contraste, tamanhos de toque, navegação por leitor de tela
- [ ] 13.4 Badge "Offline" no leitor durante leitura sem conexão
- [ ] 13.5 Atualizar `CHANGELOG.md` e revisar `README`/licença

## 14. Verificação final

- [ ] 14.1 `flutter analyze` sem erros e `dart format` aplicado
- [ ] 14.2 `flutter test` passando (parse OPDS, sync merge, DAOs, mapeamento de CFI)
- [ ] 14.3 Smoke test manual em Android API 26+: onboarding → configurar servidor → sync → abrir livro → baixar → ler → anotar → progresso persistido
