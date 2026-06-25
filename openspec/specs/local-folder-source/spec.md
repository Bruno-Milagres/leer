# local-folder-source

Fonte de biblioteca a partir de uma pasta local do dispositivo: varredura de EPUBs, extração de metadados OPF e indexação offline.

## Requirements

### Requirement: Seleção de pasta local via file picker
O sistema SHALL permitir que o usuário selecione uma pasta do dispositivo via `file_picker` (modo diretório). O caminho selecionado SHALL ser persistido na tabela `sources` com `type = 'localFolder'`.

#### Scenario: Selecionar pasta com EPUBs
- **WHEN** o usuário seleciona uma pasta que contém arquivos `.epub`
- **THEN** o sistema cria uma fonte do tipo `localFolder` com o caminho da pasta e a marca como ativa

#### Scenario: Selecionar pasta vazia
- **WHEN** o usuário seleciona uma pasta sem arquivos `.epub`
- **THEN** o sistema cria a fonte normalmente e a biblioteca mostra estado vazio para essa fonte

#### Scenario: Cancelar seleção
- **WHEN** o usuário cancela o seletor de pasta
- **THEN** nenhuma fonte é criada e o usuário retorna à tela anterior

### Requirement: Varredura recursiva de EPUBs
O sistema SHALL varrer recursivamente a pasta selecionada buscando todos os arquivos com extensão `.epub`. A varredura SHALL ser executada no refresh manual (pull-to-refresh) e ao adicionar a fonte.

#### Scenario: Pasta com EPUBs em subdiretórios
- **WHEN** a pasta contém EPUBs em subdiretórios aninhados
- **THEN** todos os EPUBs são encontrados e indexados

#### Scenario: Arquivos não-EPUB ignorados
- **WHEN** a pasta contém PDFs, TXTs e outros formatos além de EPUBs
- **THEN** apenas arquivos `.epub` são indexados

### Requirement: Extração de metadados via OPF
O sistema SHALL extrair metadados de cada EPUB lendo o `content.opf` (ou equivalente via `container.xml`) dentro do arquivo ZIP. Os metadados extraídos SHALL incluir: título (`dc:title`), autor (`dc:creator`), idioma (`dc:language`), descrição (`dc:description`), série (`meta[name=calibre:series]`), índice da série (`meta[name=calibre:series_index]`), e capa (item com `properties="cover-image"` ou `meta[name=cover]`).

#### Scenario: EPUB com metadados completos
- **WHEN** o `content.opf` contém `dc:title`, `dc:creator`, `dc:language` e capa
- **THEN** o livro é indexado com todos os metadados preenchidos

#### Scenario: EPUB com metadados mínimos
- **WHEN** o `content.opf` contém apenas `dc:title`
- **THEN** o livro é indexado com título; autor, idioma e capa ficam nulos

#### Scenario: EPUB corrompido ou sem OPF
- **WHEN** o arquivo `.epub` não pode ser lido como ZIP ou não contém `content.opf`
- **THEN** o arquivo é ignorado silenciosamente (log de aviso) e os demais EPUBs continuam sendo processados

### Requirement: Capa extraída do EPUB
O sistema SHALL extrair a imagem de capa do EPUB e salvá-la como arquivo local em cache. O caminho da capa salva SHALL ser persistido no campo `coverUrl` do livro para exibição na biblioteca.

#### Scenario: EPUB com capa declarada
- **WHEN** o OPF declara um item de capa (via `cover-image` property ou `meta[name=cover]`)
- **THEN** a imagem é extraída do EPUB e salva em cache; `coverUrl` aponta para o caminho local

#### Scenario: EPUB sem capa
- **WHEN** o OPF não declara nenhum item de capa
- **THEN** `coverUrl` é nulo e a UI exibe placeholder

### Requirement: Livros locais já são offline
Livros de pasta local SHALL ter `isDownloaded = true` e `localEpubPath` apontando para o caminho original do arquivo. O sistema SHALL NOT exibir opção de download para esses livros.

#### Scenario: Livro local acessível
- **WHEN** o livro é de uma fonte `localFolder` e o arquivo existe no caminho
- **THEN** o livro abre diretamente no reader sem necessidade de download

#### Scenario: Arquivo removido externamente
- **WHEN** o arquivo EPUB foi deletado da pasta fora do app
- **THEN** no próximo refresh a entrada é removida da biblioteca

### Requirement: Identificação única de livro local
O sistema SHALL usar um hash do caminho relativo do arquivo dentro da pasta como `externalId` para livros locais, garantindo que re-scans não dupliquem entradas.

#### Scenario: Re-scan da mesma pasta
- **WHEN** o usuário faz refresh e os mesmos EPUBs estão presentes
- **THEN** os metadados são atualizados mas as entradas não são duplicadas

#### Scenario: EPUB adicionado à pasta
- **WHEN** um novo EPUB aparece na pasta desde o último scan
- **THEN** uma nova entrada é criada na biblioteca

#### Scenario: EPUB removido da pasta
- **WHEN** um EPUB previamente indexado não existe mais na pasta
- **THEN** a entrada é removida da biblioteca (preservando anotações via cascade policy)
