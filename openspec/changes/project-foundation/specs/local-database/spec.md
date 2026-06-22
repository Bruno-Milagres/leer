## ADDED Requirements

### Requirement: Schema do banco local
O sistema SHALL definir um banco de dados drift com as tabelas `servers`, `books`, `reading_progress` e `annotations` conforme a seção 5 do SPEC.

#### Scenario: Tabela servers
- **WHEN** o schema é inicializado
- **THEN** a tabela `servers` possui `id` (PK autoincrement), `name`, `url`, `username` (nullable), `password` (nullable, apenas referência), `is_active` (default true) e `created_at`

#### Scenario: Tabela books
- **WHEN** o schema é inicializado
- **THEN** a tabela `books` possui `id` (PK), `server_id` (FK), `calibre_id`, `title`, `author`, `series`, `series_index`, `cover_url`, `opds_download_url`, `local_epub_path` (nullable), `is_downloaded` (default false), `language`, `page_count`, `file_size_kb`, `description`, `tags` (JSON), `added_at` e `synced_at`

#### Scenario: Tabela reading_progress
- **WHEN** o schema é inicializado
- **THEN** a tabela `reading_progress` possui `book_id` (PK, FK), `cfi`, `percentage` (default 0), `chapter` (nullable) e `updated_at`

#### Scenario: Tabela annotations
- **WHEN** o schema é inicializado
- **THEN** a tabela `annotations` possui `id` (PK), `book_id` (FK), `cfi`, `selected_text`, `note` (nullable), `color` (default `#FFB300`) e `created_at`

### Requirement: DAOs de acesso a dados
O sistema SHALL expor DAOs drift para operações CRUD sobre servidores, livros, progresso e anotações.

#### Scenario: Consulta reativa de livros
- **WHEN** um consumidor observa a lista de livros de um servidor ativo
- **THEN** o DAO retorna um stream que emite atualizações quando os livros mudam

### Requirement: Migrações de banco
O sistema SHALL versionar o schema e suportar migrações incrementais sem perda de dados do usuário.

#### Scenario: Abertura do banco existente
- **WHEN** o app abre um banco de versão anterior
- **THEN** as migrações registradas são aplicadas e os dados existentes são preservados
