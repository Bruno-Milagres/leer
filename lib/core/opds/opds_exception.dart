/// Tipos de erro de OPDS consumíveis pela UI (seção 8 do SPEC).
enum OpdsErrorKind {
  /// Credenciais rejeitadas (401).
  unauthorized,

  /// Host inacessível / timeout / sem conexão.
  unreachable,

  /// Resposta não é um feed OPDS válido.
  invalidFeed,

  /// Erro inesperado.
  unknown,
}

class OpdsException implements Exception {
  const OpdsException(this.kind, [this.message]);

  final OpdsErrorKind kind;
  final String? message;

  String get userMessage {
    switch (kind) {
      case OpdsErrorKind.unauthorized:
        return 'Usuário ou senha inválidos.';
      case OpdsErrorKind.unreachable:
        return 'Não foi possível conectar ao servidor. Verifique a URL e a rede.';
      case OpdsErrorKind.invalidFeed:
        return 'O endereço não respondeu um catálogo OPDS válido.';
      case OpdsErrorKind.unknown:
        return message ?? 'Ocorreu um erro inesperado.';
    }
  }

  @override
  String toString() => 'OpdsException($kind, $message)';
}
