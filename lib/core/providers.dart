import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/secure_credential_store.dart';
import 'opds/opds_client.dart';
import 'sources/library_repository.dart';
import 'sources/source_factory.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureCredentialStoreProvider = Provider<SecureCredentialStore>(
  (ref) => SecureCredentialStore(),
);

final opdsClientProvider = Provider<OpdsClient>((ref) => OpdsClient());

final sourceFactoryProvider = Provider<SourceFactory>((ref) {
  return SourceFactory(
    opdsClient: ref.watch(opdsClientProvider),
    credentialStore: ref.watch(secureCredentialStoreProvider),
    database: ref.watch(databaseProvider),
  );
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(
    database: ref.watch(databaseProvider),
    sourceFactory: ref.watch(sourceFactoryProvider),
  );
});

/// Stream de fontes ativas — fonte da verdade para "há fonte configurada?".
final activeSourcesProvider = StreamProvider<List<Source>>((ref) {
  return ref.watch(databaseProvider).sourcesDao.watchActive();
});

/// Stream de todas as fontes cadastradas.
final allSourcesProvider = StreamProvider<List<Source>>((ref) {
  return ref.watch(databaseProvider).sourcesDao.watchAll();
});
