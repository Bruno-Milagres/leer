# Changelog

Todas as mudanças notáveis do Leer são documentadas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

## [Não lançado]

### Adicionado (M01 · Foundation)
- Scaffold do projeto Flutter `com.brm.leer` (min SDK 26) com o stack do SPEC.
- Tema Material You (warm-dark/light) com `dynamic_color` + fallbacks do SPEC,
  tipografia (Playfair Display / Inter / Literata empacotadas em assets, OFL) e
  tokens.
- Banco local drift (`servers`, `books`, `reading_progress`, `annotations`),
  DAOs reativos e armazenamento seguro de credenciais.
- Navegação `go_router` com shell de 3 destinos e redirect de onboarding.
- Widgets compartilhados: shimmer, estado de erro e estado vazio.

### Adicionado (M02 · OPDS — parcial)
- Cliente OPDS (`dio` + auth básica), parser Atom/XML tolerante a campos
  ausentes e serviço de sincronização que preserva o estado local de download
  e progresso.
