## ADDED Requirements

### Requirement: Projeto Flutter base
O sistema SHALL ser um aplicativo Flutter (3.32 / Dart 3.8) com identificador de pacote `com.brm.leer`, targetando Android com SDK mínimo 26.

#### Scenario: Build de debug em Android
- **WHEN** o desenvolvedor executa `flutter run` em um dispositivo/emulador Android API 26+
- **THEN** o aplicativo compila e inicia sem erros, exibindo a tela inicial

#### Scenario: Estrutura de diretórios
- **WHEN** o projeto é inspecionado
- **THEN** existem os diretórios `lib/core`, `lib/features`, `lib/shared/widgets`, `assets/fonts`, `assets/illustrations` e `test/` conforme a seção 11 do SPEC

### Requirement: Tema Material You
O sistema SHALL aplicar um tema baseado em Material 3 com paletas warm-dark e light, derivando cores dinâmicas via `dynamic_color` quando disponível e usando os fallbacks definidos no SPEC quando não.

#### Scenario: Cores dinâmicas disponíveis
- **WHEN** o dispositivo expõe um esquema de cores Material You (Android 12+)
- **THEN** o app deriva `primary` a partir do esquema do sistema

#### Scenario: Fallback de cor
- **WHEN** o dispositivo não fornece esquema dinâmico
- **THEN** o app usa `#C2956C` como `primary` no tema escuro e `#8B5E3C` no tema claro

#### Scenario: Tokens visuais
- **WHEN** um componente usa os tokens de tema
- **THEN** estão disponíveis raio de card 12px, sheet 24px, chip 8px, botão 12px e duração de animação padrão de 250ms

### Requirement: Tipografia
O sistema SHALL registrar as famílias Playfair Display (títulos), Inter (UI/corpo) e Literata (leitura) e expô-las via `TextTheme`.

#### Scenario: Fontes registradas
- **WHEN** o app é construído
- **THEN** as fontes Playfair Display, Inter e Literata estão declaradas em `pubspec.yaml` e disponíveis no tema

### Requirement: Widgets compartilhados de estado
O sistema SHALL fornecer widgets reutilizáveis para shimmer de carregamento, estado de erro com ação de retry e estado vazio com ilustração e CTA.

#### Scenario: Shimmer de carregamento
- **WHEN** uma tela está carregando dados de lista
- **THEN** ela pode renderizar o widget de shimmer placeholder compartilhado

#### Scenario: Estado de erro com retry
- **WHEN** uma operação falha
- **THEN** o widget de erro compartilhado exibe a mensagem e um botão "Tentar novamente" que dispara um callback
