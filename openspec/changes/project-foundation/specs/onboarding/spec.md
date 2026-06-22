## ADDED Requirements

### Requirement: Fluxo de primeiro acesso
O sistema SHALL exibir uma tela de onboarding no primeiro acesso, quando nenhum servidor está configurado, com ilustração de estante e CTA para configurar o servidor.

#### Scenario: Primeiro acesso sem servidor
- **WHEN** o app é aberto e não há servidor cadastrado
- **THEN** o usuário é direcionado ao onboarding com a ilustração e o CTA

#### Scenario: Acesso subsequente com servidor
- **WHEN** o app é aberto e já existe um servidor ativo
- **THEN** o onboarding é ignorado e o usuário vai direto para a biblioteca

### Requirement: Configuração guiada do servidor
O sistema SHALL conduzir o usuário pelo cadastro e validação do servidor a partir do onboarding, concluindo na biblioteca após sucesso.

#### Scenario: Conclusão do onboarding
- **WHEN** o usuário cadastra e valida um servidor com sucesso pelo onboarding
- **THEN** o app marca o onboarding como concluído e navega para a biblioteca
