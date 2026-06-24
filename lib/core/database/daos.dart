import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [Servers])
class ServersDao extends DatabaseAccessor<AppDatabase> with _$ServersDaoMixin {
  ServersDao(super.db);

  Stream<List<Server>> watchAll() =>
      (select(servers)..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
          .watch();

  Future<List<Server>> getAll() => select(servers).get();

  Future<Server?> getActive() =>
      (select(servers)..where((s) => s.isActive.equals(true)))
          .getSingleOrNull();

  Stream<Server?> watchActive() =>
      (select(servers)..where((s) => s.isActive.equals(true)))
          .watchSingleOrNull();

  Future<int> insertServer(ServersCompanion entry) => into(servers).insert(entry);

  Future<bool> updateServer(Server entry) => update(servers).replace(entry);

  Future<void> deleteServer(int id) =>
      (delete(servers)..where((s) => s.id.equals(id))).go();

  /// Marca [id] como ativo e desativa os demais, atomicamente.
  Future<void> setActive(int id) => transaction(() async {
        await update(servers).write(const ServersCompanion(isActive: Value(false)));
        await (update(servers)..where((s) => s.id.equals(id)))
            .write(const ServersCompanion(isActive: Value(true)));
      });
}

@DriftAccessor(tables: [Books, ReadingProgress])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  Stream<List<Book>> watchByServer(int serverId) =>
      (select(books)..where((b) => b.serverId.equals(serverId))).watch();

  Stream<List<Book>> watchDownloaded() =>
      (select(books)..where((b) => b.isDownloaded.equals(true))).watch();

  Stream<List<(Book, ReadingProgressData?)>> watchWithProgressByServer(
      int serverId) {
    final query = select(books).join([
      leftOuterJoin(
          readingProgress, readingProgress.bookId.equalsExp(books.id)),
    ])
      ..where(books.serverId.equals(serverId))
      ..orderBy([OrderingTerm.asc(books.title)]);

    return query.watch().map((rows) => rows.map((row) {
          final book = row.readTable(books);
          final progress = row.readTableOrNull(readingProgress);
          return (book, progress);
        }).toList());
  }

  Future<Book?> getById(int id) =>
      (select(books)..where((b) => b.id.equals(id))).getSingleOrNull();

  Future<Book?> getByCalibreId(int serverId, String calibreId) =>
      (select(books)
            ..where((b) =>
                b.serverId.equals(serverId) & b.calibreId.equals(calibreId)))
          .getSingleOrNull();

  Future<int> upsert(BooksCompanion entry) =>
      into(books).insertOnConflictUpdate(entry);

  Future<bool> updateBook(Book entry) => update(books).replace(entry);

  Future<void> setDownloadState(int id, {String? localPath, required bool downloaded}) =>
      (update(books)..where((b) => b.id.equals(id))).write(
        BooksCompanion(
          localEpubPath: Value(localPath),
          isDownloaded: Value(downloaded),
        ),
      );
}

@DriftAccessor(tables: [ReadingProgress])
class ReadingProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingProgressDaoMixin {
  ReadingProgressDao(super.db);

  Future<ReadingProgressData?> getForBook(int bookId) =>
      (select(readingProgress)..where((p) => p.bookId.equals(bookId)))
          .getSingleOrNull();

  Stream<ReadingProgressData?> watchForBook(int bookId) =>
      (select(readingProgress)..where((p) => p.bookId.equals(bookId)))
          .watchSingleOrNull();

  Future<void> save(ReadingProgressCompanion entry) =>
      into(readingProgress).insertOnConflictUpdate(entry);
}

@DriftAccessor(tables: [Annotations, Books])
class AnnotationsDao extends DatabaseAccessor<AppDatabase>
    with _$AnnotationsDaoMixin {
  AnnotationsDao(super.db);

  Stream<List<Annotation>> watchAll() =>
      (select(annotations)
            ..orderBy([(a) => OrderingTerm(expression: a.bookId)]))
          .watch();

  Stream<List<(Annotation, Book)>> watchAllWithBook() {
    final query = select(annotations).join([
      innerJoin(books, books.id.equalsExp(annotations.bookId)),
    ])
      ..orderBy([OrderingTerm.asc(books.title), OrderingTerm.desc(annotations.createdAt)]);

    return query.watch().map((rows) => rows.map((row) {
          final annotation = row.readTable(annotations);
          final book = row.readTable(books);
          return (annotation, book);
        }).toList());
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
