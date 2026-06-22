import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Servers, Books, ReadingProgress, Annotations],
  daos: [ServersDao, BooksDao, ReadingProgressDao, AnnotationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'leer'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onUpgrade: (m, from, to) async {
          // Migrações incrementais futuras vão aqui (schemaVersion > 1),
          // preservando os dados existentes do usuário.
        },
      );
}
