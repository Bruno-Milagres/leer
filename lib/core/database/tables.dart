import 'package:drift/drift.dart';

/// Fontes de biblioteca cadastradas (seção 4/6 do SPEC v0.2).
///
/// Suporta múltiplos tipos: Calibre-Web (OPDS) e pasta local.
/// A senha NÃO é persistida aqui — apenas `hasCredentials` indica se há
/// credenciais no `flutter_secure_storage` (ver `SecureCredentialStore`).
class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()(); // 'calibre' | 'localFolder'
  TextColumn get name => text()();
  TextColumn get url => text().nullable()(); // URL (calibre) ou caminho (pasta)
  TextColumn get username => text().nullable()();
  BoolColumn get hasCredentials =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Livros indexados de qualquer fonte de biblioteca.
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId =>
      integer().references(Sources, #id, onDelete: KeyAction.cascade)();
  TextColumn get externalId => text()(); // calibre_id ou hash do path relativo
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get series => text().nullable()();
  RealColumn get seriesIndex => real().nullable()();
  TextColumn get coverUrl => text().nullable()();
  TextColumn get downloadUrl =>
      text().nullable()(); // URL OPDS ou path absoluto
  TextColumn get localEpubPath => text().nullable()();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
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
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

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
  TextColumn get color => text().withDefault(const Constant('#FFB300'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
