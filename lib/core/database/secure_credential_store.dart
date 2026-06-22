import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazena as senhas dos servidores fora do banco, em armazenamento seguro.
///
/// A tabela `servers` guarda apenas a referência (o `id`); o valor da senha
/// vive aqui, atendendo ao requisito de não persistir credenciais em claro.
class SecureCredentialStore {
  SecureCredentialStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  String _key(int serverId) => 'server_password_$serverId';

  Future<void> savePassword(int serverId, String? password) async {
    final key = _key(serverId);
    if (password == null || password.isEmpty) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: password);
    }
  }

  Future<String?> readPassword(int serverId) =>
      _storage.read(key: _key(serverId));

  /// Limpa a credencial ao remover um servidor (evita credenciais órfãs).
  Future<void> deletePassword(int serverId) =>
      _storage.delete(key: _key(serverId));
}
