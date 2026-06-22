import 'dart:convert';

import 'package:dio/dio.dart';

import 'opds_entry.dart';
import 'opds_exception.dart';
import 'opds_parser.dart';

/// Cliente HTTP para o catálogo OPDS de um servidor Calibre-Web.
///
/// Usa autenticação básica quando há credenciais e resolve URLs relativas dos
/// links (capa/download) contra a base do servidor.
class OpdsClient {
  OpdsClient({Dio? dio, OpdsParser? parser})
      : _dio = dio ?? Dio(),
        _parser = parser ?? const OpdsParser();

  final Dio _dio;
  final OpdsParser _parser;

  static const _opdsPath = '/opds';

  /// Recupera e faz o parse do catálogo de livros do [baseUrl].
  ///
  /// As URLs relativas de capa/download são resolvidas para absolutas.
  Future<List<OpdsEntry>> fetchCatalog({
    required String baseUrl,
    String? username,
    String? password,
  }) async {
    final base = _normalizeBase(baseUrl);
    final feedUrl = '$base$_opdsPath';

    final Response<String> response;
    try {
      response = await _dio.get<String>(
        feedUrl,
        options: Options(
          responseType: ResponseType.plain,
          headers: _authHeaders(username, password),
          validateStatus: (s) => s != null && s < 500,
        ),
      );
    } on DioException catch (e) {
      throw OpdsException(
        e.response?.statusCode == 401
            ? OpdsErrorKind.unauthorized
            : OpdsErrorKind.unreachable,
        e.message,
      );
    }

    if (response.statusCode == 401) {
      throw const OpdsException(OpdsErrorKind.unauthorized);
    }
    final body = response.data;
    if (body == null || body.isEmpty) {
      throw const OpdsException(OpdsErrorKind.invalidFeed);
    }

    final List<OpdsEntry> entries;
    try {
      entries = _parser.parse(body);
    } catch (_) {
      throw const OpdsException(OpdsErrorKind.invalidFeed);
    }

    return entries.map((e) => _resolveUrls(e, base)).toList(growable: false);
  }

  /// Apenas valida que o endpoint OPDS responde um feed (seção 4.1).
  Future<void> validate({
    required String baseUrl,
    String? username,
    String? password,
  }) =>
      fetchCatalog(baseUrl: baseUrl, username: username, password: password);

  Map<String, String> _authHeaders(String? username, String? password) {
    if (username == null || username.isEmpty) return const {};
    final token = base64Encode(utf8.encode('$username:${password ?? ''}'));
    return {'authorization': 'Basic $token'};
  }

  String _normalizeBase(String url) {
    var base = url.trim();
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (base.endsWith('/opds')) base = base.substring(0, base.length - 5);
    return base;
  }

  OpdsEntry _resolveUrls(OpdsEntry e, String base) {
    String? abs(String? href) {
      if (href == null || href.isEmpty) return href;
      if (href.startsWith('http://') || href.startsWith('https://')) {
        return href;
      }
      return '$base${href.startsWith('/') ? '' : '/'}$href';
    }

    return OpdsEntry(
      calibreId: e.calibreId,
      title: e.title,
      author: e.author,
      series: e.series,
      seriesIndex: e.seriesIndex,
      coverUrl: abs(e.coverUrl),
      downloadUrl: abs(e.downloadUrl)!,
      language: e.language,
      fileSizeKb: e.fileSizeKb,
      description: e.description,
      tags: e.tags,
    );
  }
}
