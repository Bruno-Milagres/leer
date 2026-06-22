## ADDED Requirements

### Requirement: Cadastro de servidor
O sistema SHALL permitir que o usuário cadastre um servidor Calibre-Web informando nome, URL, usuário e senha.

#### Scenario: Cadastro bem-sucedido
- **WHEN** o usuário informa nome, URL e credenciais válidas e confirma
- **THEN** o servidor é persistido na tabela `servers` e as credenciais são gravadas em `flutter_secure_storage`

#### Scenario: Credenciais nunca em texto claro no banco
- **WHEN** um servidor é salvo
- **THEN** a senha NÃO é armazenada na tabela `servers`, apenas uma referência, ficando o valor em secure storage

### Requirement: Validação de endpoint OPDS
O sistema SHALL testar a conexão com o servidor e validar que o endpoint OPDS responde antes de marcar o cadastro como válido.

#### Scenario: Endpoint válido
- **WHEN** o usuário aciona "Testar conexão" com uma URL Calibre-Web com OPDS habilitado
- **THEN** o app reporta sucesso e permite salvar

#### Scenario: Endpoint inacessível ou inválido
- **WHEN** a URL não responde ou não retorna um feed OPDS válido
- **THEN** o app exibe um erro claro e não marca a conexão como válida

### Requirement: Múltiplos servidores e servidor ativo
O sistema SHALL permitir cadastrar múltiplos servidores e manter exatamente um marcado como ativo por vez.

#### Scenario: Trocar servidor ativo
- **WHEN** o usuário marca outro servidor como ativo
- **THEN** o servidor anterior deixa de ser ativo e a biblioteca passa a refletir o novo servidor ativo
