import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Sources, Books, ReadingProgress, Annotations],
  daos: [SourcesDao, BooksDao, ReadingProgressDao, AnnotationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'leer'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(sources);

        await customStatement('''
              INSERT INTO sources (id, type, name, url, username, has_credentials, is_active, created_at)
              SELECT id, 'calibre', name, url, username,
                     CASE WHEN username IS NOT NULL THEN 1 ELSE 0 END,
                     is_active, created_at
              FROM servers
            ''');

        await customStatement(
          'ALTER TABLE books RENAME COLUMN server_id TO source_id',
        );
        await customStatement(
          'ALTER TABLE books RENAME COLUMN calibre_id TO external_id',
        );
        await customStatement(
          'ALTER TABLE books RENAME COLUMN opds_download_url TO download_url',
        );

        await customStatement('DROP TABLE servers');
      }
    },
  );
}
