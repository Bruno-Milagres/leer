import 'package:drift/drift.dart';

/// Servidores Calibre-Web cadastrados (seção 5 do SPEC).
///
/// A senha NÃO é persistida aqui — apenas uma referência. O valor real fica em
/// `flutter_secure_storage` (ver `SecureCredentialStore`).
class Servers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get url => text()();
  TextColumn get username => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Livros sincronizados do feed OPDS.
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId =>
      integer().references(Servers, #id, onDelete: KeyAction.cascade)();
  TextColumn get calibreId => text()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get series => text().nullable()();
  RealColumn get seriesIndex => real().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get opdsDownloadUrl => text()();
  TextColumn get localEpubPath => text().nullable()();
  BoolColumn get isDownloaded =>
      boolean().withDefault(const Constant(false))();
  TextColumn get language => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get fileSizeKb => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Progresso de leitura por livro (1:1 com Books).
class ReadingProgress extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get cfi => text().nullable()();
  IntColumn get percentage => integer().withDefault(const Constant(0))();
  TextColumn get chapter => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {bookId};
}

/// Destaques e notas de leitura.
class Annotations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get cfi => text()();
  TextColumn get selectedText => text()();
  TextColumn get note => text().nullable()();
  TextColumn get color =>
      text().withDefault(const Constant('#FFB300'))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
