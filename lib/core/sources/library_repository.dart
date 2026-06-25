import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'source_factory.dart';

typedef BookWithProgress = (Book, ReadingProgressData?);

class LibraryRepository {
  LibraryRepository({
    required AppDatabase database,
    required SourceFactory sourceFactory,
  }) : _db = database,
       _sourceFactory = sourceFactory;

  final AppDatabase _db;
  final SourceFactory _sourceFactory;

  Stream<List<BookWithProgress>> watchAllBooks() {
    return _db.booksDao.watchWithProgressByActiveSources();
  }

  Future<void> refreshAll() async {
    final activeSources = await _db.sourcesDao.getActive();
    final futures = activeSources.map((s) => _refreshSource(s));
    await Future.wait(futures, eagerError: false);
  }

  Future<void> refreshSource(int sourceId) async {
    final source = await _db.sourcesDao.getById(sourceId);
    if (source == null) return;
    await _refreshSource(source);
  }

  Future<void> _refreshSource(Source source) async {
    final librarySource = _sourceFactory.create(source);
    final books = await librarySource.listBooks();
    final now = DateTime.now();

    await _db.transaction(() async {
      for (final meta in books) {
        final existing = await _db.booksDao.getByExternalId(
          source.id,
          meta.externalId,
        );

        final companion = BooksCompanion(
          sourceId: Value(source.id),
          externalId: Value(meta.externalId),
          title: Value(meta.title),
          author: Value(meta.author),
          series: Value(meta.series),
          seriesIndex: Value(meta.seriesIndex),
          coverUrl: Value(meta.coverUrl),
          downloadUrl: Value(meta.downloadUrl),
          language: Value(meta.language),
          fileSizeKb: Value(meta.fileSizeKb),
          description: Value(meta.description),
          tags: Value(meta.tags.isEmpty ? null : jsonEncode(meta.tags)),
          syncedAt: Value(now),
        );

        if (existing == null) {
          await _db.booksDao.upsert(
            companion.copyWith(
              localEpubPath: Value(meta.localEpubPath),
              isDownloaded: Value(meta.isDownloaded),
            ),
          );
        } else {
          final update = companion;
          if (meta.isDownloaded) {
            await (_db.update(
              _db.books,
            )..where((b) => b.id.equals(existing.id))).write(
              update.copyWith(
                localEpubPath: Value(meta.localEpubPath),
                isDownloaded: Value(meta.isDownloaded),
              ),
            );
          } else {
            await (_db.update(
              _db.books,
            )..where((b) => b.id.equals(existing.id))).write(update);
          }
        }
      }
    });
  }
}
