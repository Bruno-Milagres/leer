import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'opds_entry.dart';

/// Sincroniza o catálogo OPDS com a tabela local `books`.
///
/// Regras de merge (ver design.md):
/// - chave natural = (`sourceId`, `externalId`);
/// - novos livros são inseridos;
/// - metadados de livros existentes são atualizados;
/// - estado local — `localEpubPath`, `isDownloaded` e os registros de
///   `reading_progress`/`annotations` — é SEMPRE preservado.
class LibrarySyncService {
  LibrarySyncService(this._db);

  final AppDatabase _db;

  Future<int> sync(int sourceId, List<OpdsEntry> entries) async {
    final now = DateTime.now();
    var changed = 0;

    await _db.transaction(() async {
      for (final entry in entries) {
        final existing = await _db.booksDao.getByExternalId(
          sourceId,
          entry.calibreId,
        );

        final companion = BooksCompanion(
          sourceId: Value(sourceId),
          externalId: Value(entry.calibreId),
          title: Value(entry.title),
          author: Value(entry.author),
          series: Value(entry.series),
          seriesIndex: Value(entry.seriesIndex),
          coverUrl: Value(entry.coverUrl),
          downloadUrl: Value(entry.downloadUrl),
          language: Value(entry.language),
          fileSizeKb: Value(entry.fileSizeKb),
          description: Value(entry.description),
          tags: Value(entry.tags.isEmpty ? null : jsonEncode(entry.tags)),
          syncedAt: Value(now),
        );

        if (existing == null) {
          await _db.booksDao.upsert(companion);
          changed++;
        } else {
          // Preserva estado local: não tocamos em localEpubPath/isDownloaded.
          await (_db.update(
            _db.books,
          )..where((b) => b.id.equals(existing.id))).write(companion);
        }
      }
    });

    return changed;
  }
}
