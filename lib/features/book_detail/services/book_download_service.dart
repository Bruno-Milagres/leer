import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos.dart';

class BookDownloadService {
  BookDownloadService(this._dio, this._booksDao);

  final Dio _dio;
  final BooksDao _booksDao;

  Future<void> download(Book book, {String? username, String? password}) async {
    if (book.downloadUrl == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final booksDir = Directory('${dir.path}/books');
    if (!booksDir.existsSync()) {
      booksDir.createSync(recursive: true);
    }

    final localPath = '${booksDir.path}/${book.id}.epub';

    await _dio.download(
      book.downloadUrl!,
      localPath,
      options: Options(headers: _authHeaders(username, password)),
    );

    await _booksDao.setDownloadState(
      book.id,
      localPath: localPath,
      downloaded: true,
    );
  }

  Future<void> deleteDownload(int bookId, String localPath) async {
    final file = File(localPath);
    if (file.existsSync()) {
      file.deleteSync();
    }

    await _booksDao.setDownloadState(
      bookId,
      localPath: null,
      downloaded: false,
    );
  }

  Map<String, String> _authHeaders(String? username, String? password) {
    if (username == null || username.isEmpty) return const {};
    final token = base64Encode(utf8.encode('$username:${password ?? ''}'));
    return {'authorization': 'Basic $token'};
  }
}
