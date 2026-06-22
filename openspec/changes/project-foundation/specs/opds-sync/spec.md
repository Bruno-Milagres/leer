## ADDED Requirements

### Requirement: Conexão com Calibre-Web via OPDS
O sistema SHALL conectar-se ao servidor ativo usando `dio` com autenticação básica e recuperar o feed OPDS 1.2 (Atom/XML).

#### Scenario: Recuperação autenticada do feed
- **WHEN** o servidor ativo exige autenticação e as credenciais estão em secure storage
- **THEN** o app envia as credenciais e recebe o feed OPDS com status 200

#### Scenario: Falha de autenticação
- **WHEN** as credenciais são rejeitadas (401)
- **THEN** o app reporta erro de autenticação sem travar a UI

### Requirement: Parse do feed OPDS
O sistema SHALL fazer o parse do feed Atom/XML extraindo, por entrada, título, autor, série e índice, capa, link de download EPUB, idioma, tamanho e descrição quando presentes.

#### Scenario: Entrada com metadados completos
- **WHEN** uma entrada OPDS contém todos os campos
- **THEN** o app produz um modelo de livro com todos os campos preenchidos

#### Scenario: Campos opcionais ausentes
- **WHEN** uma entrada não possui série ou descrição
- **THEN** o app produz um modelo de livro com esses campos nulos, sem erro

### Requirement: Sincronização da biblioteca
O sistema SHALL sincronizar o feed OPDS com a tabela local `books`, inserindo novos livros, atualizando metadados alterados e preservando o estado local de download e progresso.

#### Scenario: Sync inicial
- **WHEN** o usuário sincroniza pela primeira vez um servidor
- **THEN** todos os livros do feed são inseridos na tabela `books` com `synced_at` atualizado

#### Scenario: Re-sync preservando estado local
- **WHEN** o usuário sincroniza novamente um livro já baixado e com progresso
- **THEN** os metadados são atualizados mas `local_epub_path`, `is_downloaded` e o progresso de leitura são preservados
