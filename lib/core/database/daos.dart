import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Sources])
class SourcesDao extends DatabaseAccessor<AppDatabase> with _$SourcesDaoMixin {
  SourcesDao(super.db);

  Stream<List<Source>> watchAll() => (select(
    sources,
  )..orderBy([(s) => OrderingTerm(expression: s.createdAt)])).watch();

  Future<List<Source>> getAll() => select(sources).get();

  Stream<List<Source>> watchActive() =>
      (select(sources)..where((s) => s.isActive.equals(true))).watch();

  Future<List<Source>> getActive() =>
      (select(sources)..where((s) => s.isActive.equals(true))).get();

  Future<Source?> getById(int id) =>
      (select(sources)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertSource(SourcesCompanion entry) =>
      into(sources).insert(entry);

  Future<bool> updateSource(Source entry) => update(sources).replace(entry);

  Future<void> deleteSource(int id) =>
      (delete(sources)..where((s) => s.id.equals(id))).go();

  Future<void> toggleActive(int id, bool active) =>
      (update(sources)..where((s) => s.id.equals(id))).write(
        SourcesCompanion(isActive: Value(active)),
      );
}

@DriftAccessor(tables: [Books, ReadingProgress, Sources])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  Stream<List<Book>> watchBySource(int sourceId) =>
      (select(books)..where((b) => b.sourceId.equals(sourceId))).watch();

  Stream<List<Book>> watchDownloaded() =>
      (select(books)..where((b) => b.isDownloaded.equals(true))).watch();

  Stream<List<Book>> watchDownloadedCalibre() {
    final query = select(books).join([
      innerJoin(sources, sources.id.equalsExp(books.sourceId)),
    ])..where(books.isDownloaded.equals(true) & sources.type.equals('calibre'));

    return query.watch().map(
      (rows) => rows.map((row) => row.readTable(books)).toList(),
    );
  }

  Stream<List<(Book, ReadingProgressData?)>> watchWithProgressBySource(
    int sourceId,
  ) {
    final query =
        select(books).join([
            leftOuterJoin(
              readingProgress,
              readingProgress.bookId.equalsExp(books.id),
            ),
          ])
          ..where(books.sourceId.equals(sourceId))
          ..orderBy([OrderingTerm.asc(books.title)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final book = row.readTable(books);
        final progress = row.readTableOrNull(readingProgress);
        return (book, progress);
      }).toList(),
    );
  }

  Stream<List<(Book, ReadingProgressData?)>>
  watchWithProgressByActiveSources() {
    final query =
        select(books).join([
            innerJoin(sources, sources.id.equalsExp(books.sourceId)),
            leftOuterJoin(
              readingProgress,
              readingProgress.bookId.equalsExp(books.id),
            ),
          ])
          ..where(sources.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(books.title)]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final book = row.readTable(books);
        final progress = row.readTableOrNull(readingProgress);
        return (book, progress);
      }).toList(),
    );
  }

  Future<Book?> getById(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getByExternalId(int sourceId, String externalId) =>
      (select(books)..where(
            (b) =>
                b.sourceId.equals(sourceId) & b.externalId.equals(externalId),
          ))
          .getSingleOrNull();

  Future<int> upsert(BooksCompanion entry) =>
      into(books).insertOnConflictUpdate(entry);

  Future<bool> updateBook(Book entry) => update(books).replace(entry);

  Future<void> setDownloadState(
    int id, {
    String? localPath,
    required bool downloaded,
  }) => (update(books)..where((b) => b.id.equals(id))).write(
    BooksCompanion(
      localEpubPath: Value(localPath),
      isDownloaded: Value(downloaded),
    ),
  );

  Future<void> deleteBySourceNotIn(
    int sourceId,
    List<String> externalIds,
  ) async {
    if (externalIds.isEmpty) {
      await (delete(books)..where((b) => b.sourceId.equals(sourceId))).go();
      return;
    }
    await (delete(books)..where(
          (b) =>
              b.sourceId.equals(sourceId) & b.externalId.isNotIn(externalIds),
        ))
        .go();
  }
}

@DriftAccessor(tables: [ReadingProgress])
class ReadingProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingProgressDaoMixin {
  ReadingProgressDao(super.db);

  Future<ReadingProgressData?> getForBook(int bookId) => (select(
    readingProgress,
  )..where((p) => p.bookId.equals(bookId))).getSingleOrNull();

  Stream<ReadingProgressData?> watchForBook(int bookId) => (select(
    readingProgress,
  )..where((p) => p.bookId.equals(bookId))).watchSingleOrNull();

  Future<void> save(ReadingProgressCompanion entry) =>
      into(readingProgress).insertOnConflictUpdate(entry);
}

@DriftAccessor(tables: [Annotations, Books])
class AnnotationsDao extends DatabaseAccessor<AppDatabase>
    with _$AnnotationsDaoMixin {
  AnnotationsDao(super.db);

  Stream<List<Annotation>> watchAll() => (select(
    annotations,
  )..orderBy([(a) => OrderingTerm(expression: a.bookId)])).watch();

  Stream<List<(Annotation, Book)>> watchAllWithBook() {
    final query =
        select(annotations).join([
          innerJoin(books, books.id.equalsExp(annotations.bookId)),
        ])..orderBy([
          OrderingTerm.asc(books.title),
          OrderingTerm.desc(annotations.createdAt),
        ]);

    return query.watch().map(
      (rows) => rows.map((row) {
        final annotation = row.readTable(annotations);
        final book = row.readTable(books);
        return (annotation, book);
      }).toList(),
    );
  }

  Stream<List<Annotation>> watchForBook(int bookId) =>
      (select(annotations)..where((a) => a.bookId.equals(bookId))).watch();

  Future<int> countForBook(int bookId) async {
    final count = annotations.id.count();
    final query = selectOnly(annotations)
      ..addColumns([count])
      ..where(annotations.bookId.equals(bookId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> insertAnnotation(AnnotationsCompanion entry) =>
      into(annotations).insert(entry);

  Future<void> deleteAnnotation(int id) =>
      (delete(annotations)..where((a) => a.id.equals(id))).go();
}
