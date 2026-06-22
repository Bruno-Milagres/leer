import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/secure_credential_store.dart';
import 'opds/library_sync_service.dart';
import 'opds/opds_client.dart';

/// Provedores de infraestrutura compartilhados por todo o app.

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureCredentialStoreProvider = Provider<SecureCredentialStore>(
  (ref) => SecureCredentialStore(),
);

final opdsClientProvider = Provider<OpdsClient>((ref) => OpdsClient());

final librarySyncServiceProvider = Provider<LibrarySyncService>(
  (ref) => LibrarySyncService(ref.watch(databaseProvider)),
);

/// Stream do servidor ativo — fonte da verdade para "há servidor configurado?".
final activeServerProvider = StreamProvider((ref) {
  return ref.watch(databaseProvider).serversDao.watchActive();
});
