# Leer — OpenSpec v0.1

> Leitor de ebooks open source, sem anúncios, sem cobranças, construído para funcionar com Calibre-Web como backend.

---

## 1. Visão geral

**Leer** é um aplicativo Android de leitura de ebooks que usa o Calibre-Web como biblioteca remota via protocolo OPDS. O app não gerencia livros, não converte arquivos, não tem loja — ele faz uma coisa bem feita: conectar na sua biblioteca Calibre e oferecer a melhor experiência de leitura possível num celular Android moderno.

### Princípios

- **Calibre-first** — toda gestão de biblioteca acontece no Calibre-Web. O app é cliente, não servidor.
- **Offline-capable** — livros baixados ficam disponíveis sem conexão.
- **Open source** — licença MIT, sem telemetria, sem analytics, sem anúncios.
- **Material You** — segue o design system do Android 12+, com paleta adaptativa extraída da capa do livro ativo.

---

## 2. Contexto técnico

| Item | Decisão |
|---|---|
| Plataforma | Android (mínimo SDK 26) |
| Framework | Flutter 3.32 / Dart 3.8 |
| Pacote | `com.brm.leer` |
| Backend esperado | Calibre-Web com OPDS habilitado |
| Protocolo de biblioteca | OPDS 1.2 (Atom/XML) |
| Formato de leitura | EPUB (convertido pelo Calibre quando necessário) |

---

## 3. Stack

| Camada | Biblioteca | Versão |
|---|---|---|
| State management | `riverpod` | 2.x |
| Navegação | `go_router` | 15.x |
| Banco local | `drift` | 2.x |
| HTTP | `dio` | 5.x |
| Parse OPDS/XML | `xml` | 6.x |
| Leitor EPUB | `flutter_epub_viewer` | latest |
| Tema dinâmico | `dynamic_color` | latest |
| Paleta de capa | `palette_generator` | latest |
| Cache de imagens | `cached_network_image` | latest |
| Storage path | `path_provider` | latest |
| File picker | `file_picker` | latest |

---

## 4. Funcionalidades

### 4.1 Configuração de servidor

- O usuário informa URL, usuário e senha do Calibre-Web
- O app testa a conexão e valida o endpoint OPDS
- Múltiplos servidores podem ser cadastrados (ex: casa + Oracle)
- Um servidor é marcado como ativo por vez
- Credenciais armazenadas com `flutter_secure_storage`

### 4.2 Biblioteca

- Lista todos os livros disponíveis no servidor OPDS ativo
- Exibição em **grid de 2 colunas** com capa dominando o card
- Cada card exibe: capa, título (2 linhas max), autor, barra de progresso se iniciado
- **Chips de filtro** horizontais com scroll: Todos / Lendo / Baixados / Por Série
- **Drawer de filtro lateral** (desliza da esquerda): por autor, série, tag, status
- Pull-to-refresh para sincronizar com o servidor
- Shimmer loading nos cards durante carregamento
- Estado vazio com ilustração e CTA para configurar servidor

### 4.3 Detalhe do livro

- Capa grande centralizada com fundo desfocado extraído da própria capa
- Título, autor, série com índice (ex: "Livro 2 de The Expanse")
- Stats: páginas estimadas, idioma, tamanho do arquivo
- Barra de progresso com label (ex: "34% · Capítulo 5")
- Botão primário: "Continuar Lendo" ou "Começar a Ler"
- Botão secundário: "Baixar" (quando não cacheado) ou "Remover download"
- Abas: Descrição | Anotações (com badge de contagem)
- Cor do tema da tela extraída da capa via `PaletteGenerator`

### 4.4 Leitor

- Renderiza EPUB via `flutter_epub_viewer` (WebView nativa)
- Interface completamente limpa durante leitura (sem app bar, sem nav)
- Tap no centro revela/oculta controles com fade
- Controles revelados:
  - Topo: título do livro + botão fechar (X)
  - Base: slider de progresso + nome do capítulo atual
- Temas de leitura: Claro / Sépia / Escuro / AMOLED
- Configurações de fonte: família (Literata padrão, + opções), tamanho, espaçamento
- Virada de página: swipe horizontal com leve parallax
- Progresso salvo automaticamente a cada página virada (CFI)
- Suporte a anotações: pressão longa seleciona texto → opções: Destacar / Anotar / Copiar
- Cores de destaque: amarelo, verde, azul, rosa

### 4.5 Downloads

- Lista de livros baixados localmente (disponíveis offline)
- Tamanho ocupado total
- Swipe para remover download individual
- Ordenação: recentes, título, autor

### 4.6 Anotações

- Lista global de todos os destaques e notas
- Agrupada por livro
- Exportação em texto simples (cópia para clipboard)
- Tap em anotação abre o livro na posição exata (CFI)

---

## 5. Modelo de dados (drift)

### `servers`
```
id            INTEGER PK AUTOINCREMENT
name          TEXT              -- "Casa", "Oracle"
url           TEXT              -- "http://192.168.1.x:8083"
username      TEXT NULLABLE
password      TEXT NULLABLE     -- armazenado em secure storage, aqui só referência
is_active     BOOLEAN DEFAULT true
created_at    DATETIME
```

### `books`
```
id                INTEGER PK AUTOINCREMENT
server_id         INTEGER FK servers.id
calibre_id        TEXT              -- ID interno do Calibre
title             TEXT
author            TEXT NULLABLE
series            TEXT NULLABLE
series_index      REAL NULLABLE
cover_url         TEXT NULLABLE
opds_download_url TEXT
local_epub_path   TEXT NULLABLE     -- NULL = não baixado
is_downloaded     BOOLEAN DEFAULT false
language          TEXT NULLABLE
page_count        INTEGER NULLABLE
file_size_kb      INTEGER NULLABLE
description       TEXT NULLABLE
tags              TEXT NULLABLE     -- JSON array
added_at          DATETIME
synced_at         DATETIME
```

### `reading_progress`
```
book_id      INTEGER PK FK books.id
cfi          TEXT              -- EPUB CFI (posição exata)
percentage   INTEGER DEFAULT 0
chapter      TEXT NULLABLE
updated_at   DATETIME
```

### `annotations`
```
id             INTEGER PK AUTOINCREMENT
book_id        INTEGER FK books.id
cfi            TEXT              -- posição do destaque
selected_text  TEXT
note           TEXT NULLABLE
color          TEXT DEFAULT '#FFB300'
created_at     DATETIME
```

---

## 6. Navegação (go_router)

```
/                     → redirect para /library
/library              → LibraryScreen
/library/book/:id     → BookDetailScreen
/library/book/:id/read → ReaderScreen
/downloads            → DownloadsScreen
/annotations          → AnnotationsScreen
/settings             → SettingsScreen
/settings/server      → ServerSettingsScreen
/settings/reader      → ReaderSettingsScreen
/onboarding           → OnboardingScreen (primeiro acesso)
```

Shell com `NavigationBar` em 3 destinos: Biblioteca / Downloads / Configurações.
NavigationBar oculta durante leitura.

---

## 7. Visual & Tema

### Paleta base (warm dark — inspirada no resultado do v0)

```
background:     #0F0D0C   -- quase preto com toque quente
surface:        #1C1917   -- superfície com marrom muito sutil
surface-variant:#292524
primary:        dynamic (Material You) -- fallback #C2956C (caramelo)
on-primary:     #1C1917
text-primary:   #EDE8E3
text-muted:     #9C9189
border:         #2E2A27
```

### Paleta base (light)

```
background:     #FFFBF7
surface:        #F5F0EB
primary:        dynamic (Material You) -- fallback #8B5E3C
text-primary:   #1C1917
text-muted:     #6B6259
```

### Tipografia

```
Display / Títulos:  Playfair Display (serifada, personalidade)
Body / UI:          Inter (legibilidade, neutro)
Leitura (reader):   Literata (otimizada para tela, padrão)
                    + opções: Georgia, Open Sans, Roboto Slab
```

### Tokens

```
border-radius-card:   12px
border-radius-sheet:  24px
border-radius-chip:   8px
border-radius-button: 12px
elevation-card:       sutil (sem sombra pesada, borda 1px surface-variant)
animation-duration:   250ms (Material standard easing)
```

---

## 8. Estados de UI

| Estado | Comportamento |
|---|---|
| Sem servidor configurado | Onboarding com ilustração de estante + CTA |
| Servidor inacessível | Banner de erro + botão Tentar novamente |
| Carregando biblioteca | Shimmer grid (8 cards placeholder) |
| Biblioteca vazia | Ilustração + "Nenhum livro encontrado" |
| Livro não baixado | Botão "Baixar" no detail, tap no reader inicia download |
| Download em progresso | Progress indicator linear no card |
| Leitura offline | Badge "Offline" discreto no reader |

---

## 9. Módulos de desenvolvimento (ordem sugerida)

| # | Módulo | Descrição |
|---|---|---|
| M01 | Foundation | Projeto base, tema, navegação, drift schema |
| M02 | OPDS Service | Conexão Calibre-Web, parse feed, sync biblioteca |
| M03 | Library Screen | Grid, shimmer, chips, drawer de filtro |
| M04 | Book Detail | Tela de detalhe, download, paleta dinâmica |
| M05 | Reader | Leitor EPUB, progresso, temas, UI hide/show |
| M06 | Annotations | Destaques, notas, lista global, export |
| M07 | Downloads | Gestão offline, remoção, tamanho |
| M08 | Settings | Servidor, preferências de leitura |
| M09 | Onboarding | Primeiro acesso, configuração guiada |
| M10 | Polish | Transições, empty states, acessibilidade |

---

## 10. Fora de escopo (v1)

- Conversão de PDF no app (responsabilidade do Calibre-Web)
- Suporte a DRM
- Sincronização de progresso com o servidor (local only na v1)
- iOS
- Suporte a audiobooks
- Loja de ebooks integrada
- Multi-usuário

---

## 11. Repositório

```
leer/
├── SPEC.md                  ← este documento
├── CHANGELOG.md
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── database/        -- drift
│   │   ├── opds/            -- OPDSService
│   │   ├── theme/           -- Material You + paleta dinâmica
│   │   └── router/          -- go_router
│   ├── features/
│   │   ├── library/
│   │   ├── reader/
│   │   ├── downloads/
│   │   ├── annotations/
│   │   └── settings/
│   └── shared/
│       └── widgets/         -- shimmer, error states, empty states
├── assets/
│   ├── fonts/
│   └── illustrations/
└── test/
```

---

*Leer · OpenSpec v0.1 · Junho 2026*
