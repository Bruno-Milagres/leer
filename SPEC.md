# Leer — OpenSpec v0.2

> Leitor de ebooks open source, sem anúncios, sem cobranças. Funciona com Calibre-Web, pasta local, e (futuramente) sincroniza progresso entre dispositivos.

---

## 1. Visão geral

**Leer** é um aplicativo Android de leitura de ebooks com arquitetura de **múltiplas fontes de biblioteca**. A fonte primária é o Calibre-Web via OPDS, mas o app também lê EPUBs de uma pasta local do dispositivo. O Leer não converte arquivos nem tem loja — ele faz uma coisa bem feita: agregar suas fontes de livros e oferecer a melhor experiência de leitura possível num celular Android moderno.

### Princípios

- **Fonte-agnóstico** — a UI não sabe (nem precisa saber) de onde o livro veio. Calibre-Web, pasta local ou outra fonte futura: todas implementam a mesma interface.
- **Calibre-first, mas não Calibre-only** — o Calibre-Web é a experiência mais completa, mas o app funciona sem ele.
- **Offline-capable** — livros baixados/importados ficam disponíveis sem conexão.
- **Open source** — licença MIT, sem telemetria, sem analytics, sem anúncios.
- **Material You** — segue o design system do Android 12+, com paleta adaptativa extraída da capa do livro ativo.

---

## 2. Contexto técnico

| Item | Decisão |
|---|---|
| Plataforma | Android (mínimo SDK 26) |
| Framework | Flutter 3.32 / Dart 3.8 |
| Pacote | `com.brm.leer` |
| Backend primário | Calibre-Web com OPDS habilitado |
| Fontes alternativas | Pasta local (v1) · WebDAV/Drive (backlog) |
| Protocolo de biblioteca | OPDS 1.2 (Atom/XML) |
| Protocolo de sync | KOSync (v1.1) |
| Formato de leitura | EPUB |

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
| File picker / pasta | `file_picker` | latest |
| Credenciais seguras | `flutter_secure_storage` | latest |
| Hash (KOSync) | `crypto` | latest |

---

## 4. Arquitetura de fontes de biblioteca (Library Sources)

O conceito central da v0.2. Toda fonte de livros implementa uma interface comum, e o resto do app trabalha contra essa abstração — nunca contra uma fonte específica.

```
                 ┌──────────────────┐
                 │   LibraryRepo    │  ← agrega todas as fontes ativas
                 └────────┬─────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
   CalibreSource    LocalFolderSource   (WebDavSource)
   (OPDS)           (file system)        backlog
```

### Interface `LibrarySource`

```dart
abstract class LibrarySource {
  String get id;            // identificador único da fonte
  String get displayName;   // "Calibre · Oracle", "Pasta local"
  SourceType get type;      // calibre | localFolder | webdav

  Future<List<Book>> listBooks();          // lista o catálogo
  Future<File> fetchBook(Book book);        // baixa/abre o EPUB
  Future<Uint8List?> fetchCover(Book book); // capa (pode ser null)
  Future<bool> testConnection();            // valida a fonte
}
```

### Fontes na v1

| Fonte | Status | Descrição |
|---|---|---|
| **CalibreSource** | v1 | OPDS feed do Calibre-Web. Fonte primária, experiência completa. |
| **LocalFolderSource** | v1 | Lê EPUBs de uma pasta escolhida pelo usuário no dispositivo. Extrai metadados do próprio EPUB (OPF). |
| **WebDavSource** | backlog | Nextcloud/WebDAV genérico. Adiado por complexidade de auth/sync. |
| **DriveSource** | backlog | Google Drive. Adiado — OAuth e conflito de sync custosos. |

### LocalFolderSource — detalhes

- Usuário escolhe uma pasta via `file_picker` (modo diretório)
- O app varre `.epub` recursivamente
- Metadados (título, autor, capa, idioma) extraídos do `content.opf` dentro do EPUB
- Sem download — o arquivo já está local, só indexa caminho
- Mudanças na pasta detectadas no refresh manual (sem file watcher na v1)

---

## 5. Funcionalidades

### 5.1 Configuração de fontes

- Tela de fontes lista todas as fontes cadastradas com status (online/offline)
- **Adicionar Calibre-Web**: URL, usuário, senha → testa conexão e valida OPDS
- **Adicionar pasta local**: seletor de diretório do dispositivo
- Múltiplas fontes podem coexistir e ficar ativas simultaneamente
- Credenciais de Calibre armazenadas com `flutter_secure_storage`
- Cada fonte pode ser ativada/desativada individualmente

### 5.2 Biblioteca

- Agrega livros de **todas as fontes ativas** num único catálogo
- Exibição em **grid de 2 colunas** com capa dominando o card
- Cada card exibe: capa, título (2 linhas max), autor, barra de progresso se iniciado
- Badge discreto indicando a fonte (ícone Calibre / pasta) quando há múltiplas fontes
- **Chips de filtro** horizontais com scroll: Todos / Lendo / Baixados / Por Série / Por Fonte
- **Drawer de filtro lateral** (desliza da esquerda): por autor, série, tag, status, fonte
- Pull-to-refresh para sincronizar todas as fontes
- Shimmer loading nos cards durante carregamento
- Estado vazio com ilustração e CTA para configurar a primeira fonte

### 5.3 Detalhe do livro

- Capa grande centralizada com fundo desfocado extraído da própria capa
- Título, autor, série com índice (ex: "Livro 2 de The Expanse")
- Origem do livro (qual fonte) exibida discretamente
- Stats: páginas estimadas, idioma, tamanho do arquivo
- Barra de progresso com label (ex: "34% · Capítulo 5")
- Botão primário: "Continuar Lendo" ou "Começar a Ler"
- Botão secundário: "Baixar" (Calibre, não cacheado) ou "Remover download"
  - Livros de pasta local não mostram botão de download (já são locais)
- Abas: Descrição | Anotações (com badge de contagem)
- Cor do tema da tela extraída da capa via `PaletteGenerator`

### 5.4 Leitor

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
- **Sync de progresso (v1.1)**: ao abrir/fechar, reconcilia posição com servidor KOSync
- Suporte a anotações: pressão longa seleciona texto → opções: Destacar / Anotar / Copiar
- Cores de destaque: amarelo, verde, azul, rosa

### 5.5 Downloads

- Lista de livros baixados localmente (disponíveis offline)
- Aplica-se a livros de Calibre; livros de pasta local já são offline por natureza
- Tamanho ocupado total
- Swipe para remover download individual
- Ordenação: recentes, título, autor

### 5.6 Anotações

- Lista global de todos os destaques e notas
- Agrupada por livro
- Exportação em texto simples (cópia para clipboard)
- Tap em anotação abre o livro na posição exata (CFI)

### 5.7 Sincronização de progresso (v1.1)

Permite manter o mesmo ponto de leitura entre dispositivos (ex: celular ↔ tablet).

- **Protocolo**: KOSync — padrão aberto, mesmo usado pelo KOReader e suportado pelo Calibre-Web Automated
- **Servidor**: roda junto do Calibre-Web no Oracle (sem backend separado)
- **Identificação de documento**: hash do conteúdo do EPUB (partial MD5, padrão KOSync) — funciona mesmo que o arquivo venha de fontes diferentes
- **O que sincroniza**: posição de leitura (progress/percentage) por documento e dispositivo
- **Reconciliação**: ao abrir um livro, compara progresso local vs. servidor; o mais recente vence; conflito real (ambos avançaram offline) pergunta ao usuário
- **Configuração**: usuário informa endpoint KOSync + credenciais nas configurações
- **Fora do escopo do sync v1.1**: anotações e destaques permanecem locais (sync deles fica para depois)

---

## 6. Modelo de dados (drift)

### `sources`
```
id              INTEGER PK AUTOINCREMENT
type            TEXT              -- 'calibre' | 'localFolder' | 'webdav'
name            TEXT              -- "Oracle", "Casa", "Pasta Downloads"
url             TEXT NULLABLE     -- URL (calibre/webdav) ou caminho (pasta)
username        TEXT NULLABLE
has_credentials BOOLEAN DEFAULT false  -- senha real fica em secure storage
is_active       BOOLEAN DEFAULT true
created_at      DATETIME
```

### `books`
```
id                INTEGER PK AUTOINCREMENT
source_id         INTEGER FK sources.id
external_id       TEXT              -- ID na fonte (calibre_id ou path hash)
content_hash      TEXT NULLABLE     -- partial MD5 p/ KOSync (v1.1)
title             TEXT
author            TEXT NULLABLE
series            TEXT NULLABLE
series_index      REAL NULLABLE
cover_url         TEXT NULLABLE     -- URL remota ou caminho local da capa
download_url      TEXT NULLABLE     -- URL OPDS (calibre) ou path (local)
local_epub_path   TEXT NULLABLE     -- NULL = não disponível offline
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
device_id    TEXT NULLABLE     -- identificador do dispositivo (v1.1)
synced_at    DATETIME NULLABLE -- última sync com servidor (v1.1)
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

### `sync_config` (v1.1)
```
id           INTEGER PK AUTOINCREMENT
endpoint     TEXT              -- URL do servidor KOSync
username     TEXT
device_id    TEXT              -- gerado uma vez por instalação
device_name  TEXT              -- "Celular BrM", "Tablet"
is_enabled   BOOLEAN DEFAULT false
last_sync_at DATETIME NULLABLE
```

---

## 7. Navegação (go_router)

```
/                      → redirect para /library
/library               → LibraryScreen
/library/book/:id      → BookDetailScreen
/library/book/:id/read → ReaderScreen
/downloads             → DownloadsScreen
/annotations           → AnnotationsScreen
/settings              → SettingsScreen
/settings/sources      → SourcesScreen            (lista de fontes)
/settings/sources/add  → AddSourceScreen          (calibre ou pasta)
/settings/reader       → ReaderSettingsScreen
/settings/sync         → SyncSettingsScreen        (v1.1)
/onboarding            → OnboardingScreen          (primeiro acesso)
```

Shell com `NavigationBar` em 3 destinos: Biblioteca / Downloads / Configurações.
NavigationBar oculta durante leitura.

---

## 8. Visual & Tema

### Paleta base (warm dark — confirmada pelo ícone/mockup)

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

### Identidade

```
Ícone:    Pardal sobre livro aberto, paleta caramelo/marrom
          Versões adaptive light + dark
Nome:     Leer (ler PT/ES/DE + move de Pokémon)
```

---

## 9. Estados de UI

| Estado | Comportamento |
|---|---|
| Sem fonte configurada | Onboarding com ilustração de estante + CTA |
| Fonte inacessível | Banner de erro por fonte + botão Tentar novamente |
| Carregando biblioteca | Shimmer grid (8 cards placeholder) |
| Biblioteca vazia | Ilustração + "Nenhum livro encontrado" |
| Livro não baixado (Calibre) | Botão "Baixar"; tap no reader inicia download |
| Download em progresso | Progress indicator linear no card |
| Leitura offline | Badge "Offline" discreto no reader |
| Conflito de sync (v1.1) | Sheet perguntando qual posição manter |

---

## 10. Roadmap por versão

### v1 (lançamento)
- M01 Foundation
- M02 Calibre Source (OPDS)
- M03 Library Screen
- M04 Book Detail
- M05 Reader
- M06 Annotations
- M07 Downloads
- M08 Settings + Sources
- M09 Local Folder Source
- M10 Onboarding
- M11 Polish

### v1.1 (pós-lançamento)
- M12 KOSync — sincronização de progresso entre dispositivos

### Backlog (sem data)
- WebDAV / Nextcloud source
- Google Drive source
- Sync de anotações
- iOS

---

## 11. Módulos de desenvolvimento

| # | Módulo | Versão | Descrição |
|---|---|---|---|
| M01 | Foundation | v1 | Projeto base, tema, navegação, drift schema, abstração LibrarySource |
| M02 | Calibre Source | v1 | OPDS, parse feed, CalibreSource implementa LibrarySource |
| M03 | Library Screen | v1 | Grid, shimmer, chips, drawer de filtro, agregação multi-fonte |
| M04 | Book Detail | v1 | Tela de detalhe, download, paleta dinâmica |
| M05 | Reader | v1 | Leitor EPUB, progresso, temas, UI hide/show |
| M06 | Annotations | v1 | Destaques, notas, lista global, export |
| M07 | Downloads | v1 | Gestão offline, remoção, tamanho |
| M08 | Settings + Sources | v1 | Gestão de fontes, preferências de leitura |
| M09 | Local Folder Source | v1 | LocalFolderSource, varredura de pasta, extração de OPF |
| M10 | Onboarding | v1 | Primeiro acesso, configuração guiada da primeira fonte |
| M11 | Polish | v1 | Transições, empty states, acessibilidade |
| M12 | KOSync | v1.1 | Sincronização de progresso entre dispositivos |

---

## 12. Fora de escopo (v1 e v1.1)

- Conversão de PDF no app (responsabilidade do Calibre-Web)
- Suporte a DRM
- Sync de anotações entre dispositivos (só progresso na v1.1)
- iOS
- Suporte a audiobooks
- Loja de ebooks integrada
- Multi-usuário num mesmo dispositivo

---

## 13. Repositório

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
│   │   ├── sources/         -- LibrarySource + implementações
│   │   │   ├── library_source.dart
│   │   │   ├── calibre_source.dart
│   │   │   ├── local_folder_source.dart
│   │   │   └── library_repository.dart
│   │   ├── sync/            -- KOSync client (v1.1)
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
│   ├── icon/                -- ícone do pardal (adaptive)
│   └── illustrations/
└── test/
```

---

*Leer · OpenSpec v0.2 · Junho 2026*

### Changelog do SPEC
- **v0.2** — Arquitetura de Library Sources (Calibre + pasta local); sync de progresso via KOSync (v1.1); roadmap versionado; pasta local promovida a v1; WebDAV/Drive movidos para backlog.
- **v0.1** — Versão inicial. Calibre-Web only.
