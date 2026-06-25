import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'epub_metadata_extractor.dart';
import 'library_source.dart';

class LocalFolderSource implements LibrarySource {
  LocalFolderSource({
    required this.source,
    required AppDatabase database,
    EpubMetadataExtractor? extractor,
  }) : _db = database,
       _extractor = extractor ?? EpubMetadataExtractor();

  final Source source;
  final AppDatabase _db;
  final EpubMetadataExtractor _extractor;

  @override
  String get id => source.id.toString();

  @override
  String get displayName => source.name;

  @override
  SourceType get type => SourceType.localFolder;

  String get _folderPath => source.url!;

  @override
  Future<List<BookMetadata>> listBooks() async {
    final dir = Directory(_folderPath);
    if (!dir.existsSync()) return [];

    final epubs = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.epub'))
        .toList();

    final cacheDir = await _coverCacheDir();
    final results = <BookMetadata>[];
    final foundExternalIds = <String>[];

    for (final file in epubs) {
      final relativePath = file.path.substring(_folderPath.length);
      final externalId = _hashPath(relativePath);
      foundExternalIds.add(externalId);

      final extracted = _extractor.extract(file, externalId);
      if (extracted == null) continue;

      String? coverUrl;
      if (extracted.coverBytes != null) {
        coverUrl = await _saveCover(
          cacheDir,
          source.id,
          externalId,
          extracted.coverBytes!,
        );
      }

      results.add(
        BookMetadata(
          externalId: extracted.metadata.externalId,
          title: extracted.metadata.title,
          author: extracted.metadata.author,
          series: extracted.metadata.series,
          seriesIndex: extracted.metadata.seriesIndex,
          coverUrl: coverUrl,
          downloadUrl: file.path,
          localEpubPath: file.path,
          isDownloaded: true,
          language: extracted.metadata.language,
          fileSizeKb: extracted.metadata.fileSizeKb,
          description: extracted.metadata.description,
          tags: extracted.metadata.tags,
        ),
      );
    }

    await _db.booksDao.deleteBySourceNotIn(source.id, foundExternalIds);

    return results;
  }

  @override
  Future<File> fetchBook(String downloadUrl) async {
    return File(downloadUrl);
  }

  @override
  Future<Uint8List?> fetchCover(String? coverRef) async {
    if (coverRef == null) return null;
    final file = File(coverRef);
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  @override
  Future<bool> testConnection() async {
    try {
      final dir = Directory(_folderPath);
      if (!dir.existsSync()) return false;

      final epubCount = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.epub'))
          .length;
      return epubCount >= 0; // true even if empty
    } catch (_) {
      return false;
    }
  }

  String _hashPath(String relativePath) {
    return md5.convert(utf8.encode(relativePath)).toString().substring(0, 16);
  }

  Future<Directory> _coverCacheDir() async {
    final cache = await getApplicationCacheDirectory();
    final dir = Directory('${cache.path}/covers');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  Future<String> _saveCover(
    Directory cacheDir,
    int sourceId,
    String externalId,
    Uint8List bytes,
  ) async {
    final path = '${cacheDir.path}/${sourceId}_$externalId.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
