import '../database/app_database.dart';
import '../database/secure_credential_store.dart';
import '../opds/opds_client.dart';
import 'calibre_source.dart';
import 'library_source.dart';
import 'local_folder_source.dart';

class SourceFactory {
  SourceFactory({
    required OpdsClient opdsClient,
    required SecureCredentialStore credentialStore,
    required AppDatabase database,
  }) : _opdsClient = opdsClient,
       _credentialStore = credentialStore,
       _database = database;

  final OpdsClient _opdsClient;
  final SecureCredentialStore _credentialStore;
  final AppDatabase _database;

  LibrarySource create(Source source) {
    final type = SourceType.fromString(source.type);
    return switch (type) {
      SourceType.calibre => CalibreSource(
        source: source,
        opdsClient: _opdsClient,
        credentialStore: _credentialStore,
      ),
      SourceType.localFolder => LocalFolderSource(
        source: source,
        database: _database,
      ),
    };
  }
}
