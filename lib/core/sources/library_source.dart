import 'dart:io';
import 'dart:typed_data';

enum SourceType {
  calibre,
  localFolder;

  static SourceType fromString(String value) => switch (value) {
    'calibre' => SourceType.calibre,
    'localFolder' => SourceType.localFolder,
    _ => throw ArgumentError('Unknown source type: $value'),
  };

  String toDbString() => switch (this) {
    SourceType.calibre => 'calibre',
    SourceType.localFolder => 'localFolder',
  };
}

abstract class LibrarySource {
  String get id;
  String get displayName;
  SourceType get type;

  Future<List<BookMetadata>> listBooks();
  Future<File> fetchBook(String downloadUrl);
  Future<Uint8List?> fetchCover(String? coverRef);
  Future<bool> testConnection();
}

class BookMetadata {
  const BookMetadata({
    required this.externalId,
    required this.title,
    this.author,
    this.series,
    this.seriesIndex,
    this.coverUrl,
    this.downloadUrl,
    this.localEpubPath,
    this.isDownloaded = false,
    this.language,
    this.pageCount,
    this.fileSizeKb,
    this.description,
    this.tags = const [],
  });

  final String externalId;
  final String title;
  final String? author;
  final String? series;
  final double? seriesIndex;
  final String? coverUrl;
  final String? downloadUrl;
  final String? localEpubPath;
  final bool isDownloaded;
  final String? language;
  final int? pageCount;
  final int? fileSizeKb;
  final String? description;
  final List<String> tags;
}
