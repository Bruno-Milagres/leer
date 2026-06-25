import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../database/secure_credential_store.dart';
import '../opds/opds_client.dart';
import 'library_source.dart';

class CalibreSource implements LibrarySource {
  CalibreSource({
    required this.source,
    required OpdsClient opdsClient,
    required SecureCredentialStore credentialStore,
    Dio? dio,
  }) : _opdsClient = opdsClient,
       _credentialStore = credentialStore,
       _dio = dio ?? Dio();

  final Source source;
  final OpdsClient _opdsClient;
  final SecureCredentialStore _credentialStore;
  final Dio _dio;

  @override
  String get id => source.id.toString();

  @override
  String get displayName => source.name;

  @override
  SourceType get type => SourceType.calibre;

  Future<String?> _password() => _credentialStore.readPassword(source.id);

  @override
  Future<List<BookMetadata>> listBooks() async {
    final password = await _password();
    final entries = await _opdsClient.fetchCatalog(
      baseUrl: source.url!,
      username: source.username,
      password: password,
    );

    return entries
        .map(
          (e) => BookMetadata(
            externalId: e.calibreId,
            title: e.title,
            author: e.author,
            series: e.series,
            seriesIndex: e.seriesIndex,
            coverUrl: e.coverUrl,
            downloadUrl: e.downloadUrl,
            language: e.language,
            fileSizeKb: e.fileSizeKb,
            description: e.description,
            tags: e.tags,
          ),
        )
        .toList();
  }

  @override
  Future<File> fetchBook(String downloadUrl) async {
    final password = await _password();
    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    if (!booksDir.existsSync()) {
      booksDir.createSync(recursive: true);
    }

    final fileName =
        '${source.id}_${downloadUrl.hashCode.toRadixString(16)}.epub';
    final localPath = '${booksDir.path}/$fileName';

    await _dio.download(
      downloadUrl,
      localPath,
      options: Options(headers: _authHeaders(source.username, password)),
    );

    return File(localPath);
  }

  @override
  Future<Uint8List?> fetchCover(String? coverRef) async {
    if (coverRef == null) return null;
    final password = await _password();

    final response = await _dio.get<List<int>>(
      coverRef,
      options: Options(
        responseType: ResponseType.bytes,
        headers: _authHeaders(source.username, password),
      ),
    );

    return response.data != null ? Uint8List.fromList(response.data!) : null;
  }

  @override
  Future<bool> testConnection() async {
    try {
      final password = await _password();
      await _opdsClient.validate(
        baseUrl: source.url!,
        username: source.username,
        password: password,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _authHeaders(String? username, String? password) {
    if (username == null || username.isEmpty) return const {};
    final token = base64Encode(utf8.encode('$username:${password ?? ''}'));
    return {'authorization': 'Basic $token'};
  }
}
