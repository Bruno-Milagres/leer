// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daos.dart';

// ignore_for_file: type=lint
mixin _$ServersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ServersTable get servers => attachedDatabase.servers;
  ServersDaoManager get managers => ServersDaoManager(this);
}

class ServersDaoManager {
  final _$ServersDaoMixin _db;
  ServersDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
}

mixin _$BooksDaoMixin on DatabaseAccessor<AppDatabase> {
  $ServersTable get servers => attachedDatabase.servers;
  $BooksTable get books => attachedDatabase.books;
  $ReadingProgressTable get readingProgress => attachedDatabase.readingProgress;
  BooksDaoManager get managers => BooksDaoManager(this);
}

class BooksDaoManager {
  final _$BooksDaoMixin _db;
  BooksDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(
        _db.attachedDatabase,
        _db.readingProgress,
      );
}

mixin _$ReadingProgressDaoMixin on DatabaseAccessor<AppDatabase> {
  $ServersTable get servers => attachedDatabase.servers;
  $BooksTable get books => attachedDatabase.books;
  $ReadingProgressTable get readingProgress => attachedDatabase.readingProgress;
  ReadingProgressDaoManager get managers => ReadingProgressDaoManager(this);
}

class ReadingProgressDaoManager {
  final _$ReadingProgressDaoMixin _db;
  ReadingProgressDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(
        _db.attachedDatabase,
        _db.readingProgress,
      );
}

mixin _$AnnotationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ServersTable get servers => attachedDatabase.servers;
  $BooksTable get books => attachedDatabase.books;
  $AnnotationsTable get annotations => attachedDatabase.annotations;
  AnnotationsDaoManager get managers => AnnotationsDaoManager(this);
}

class AnnotationsDaoManager {
  final _$AnnotationsDaoMixin _db;
  AnnotationsDaoManager(this._db);
  $$ServersTableTableManager get servers =>
      $$ServersTableTableManager(_db.attachedDatabase, _db.servers);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$AnnotationsTableTableManager get annotations =>
      $$AnnotationsTableTableManager(_db.attachedDatabase, _db.annotations);
}
