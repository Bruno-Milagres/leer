import 'dart:convert';

import 'package:dio/dio.dart';

import 'opds_entry.dart';
import 'opds_exception.dart';
import 'opds_parser.dart';

/// Cliente HTTP para o catálogo OPDS de um servidor Calibre-Web.
///
/// O `/opds` raiz do Calibre-Web é um feed de navegação; os livros ficam em
/// sub-catálogos (`/opds/books/letter/...`). Este cliente percorre a árvore de
/// navegação do ramo de livros, coletando todas as entradas de aquisição.
class OpdsClient {
  OpdsClient({Dio? dio, OpdsParser? parser})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
      _parser = parser ?? const OpdsParser();

  final Dio _dio;
  final OpdsParser _parser;

  static const _opdsPath = '/opds';
  static const _maxDepth = 6;

  /// Recupera e faz o parse do catálogo de livros do [baseUrl], percorrendo os
  /// sub-catálogos de navegação. URLs de capa/download são resolvidas.
  Future<List<OpdsEntry>> fetchCatalog({
    required String baseUrl,
    String? username,
    String? password,
  }) async {
    final base = _normalizeBase(baseUrl);
    final headers = _authHeaders(username, password);
    final collected = <String, OpdsEntry>{};
    final visited = <String>{};

    await _crawl('$base$_opdsPath', base, headers, collected, visited);

    return collected.values.toList(growable: false);
  }

  Future<void> _crawl(
    String url,
    String base,
    Map<String, String> headers,
    Map<String, OpdsEntry> collected,
    Set<String> visited, {
    int depth = 0,
  }) async {
    if (depth > _maxDepth) return;
    if (!visited.add(url)) return;

    final body = await _fetch(url, headers);

    final OpdsFeed feed;
    try {
      feed = _parser.parseFeed(body);
    } catch (_) {
      throw const OpdsException(OpdsErrorKind.invalidFeed);
    }

    for (final book in feed.books) {
      final resolved = _resolveUrls(book, base);
      collected[resolved.calibreId] = resolved;
    }

    // Paginação dentro de uma listagem de livros.
    if (feed.nextLink != null) {
      await _crawl(
        _abs(feed.nextLink!, base),
        base,
        headers,
        collected,
        visited,
        depth: depth,
      );
    }

    // Sub-catálogos: apenas o ramo de livros (evita autores/séries/hot/etc.).
    for (final nav in feed.navigationLinks) {
      if (!nav.contains('/books')) continue;
      await _crawl(
        _abs(nav, base),
        base,
        headers,
        collected,
        visited,
        depth: depth + 1,
      );
    }
  }

  Future<String> _fetch(String url, Map<String, String> headers) async {
    final Response<String> response;
    try {
      response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: headers,
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
    return body;
  }

  /// Valida que o endpoint OPDS responde um feed válido (seção 4.1). Não
  /// percorre a biblioteca inteira — apenas o feed raiz.
  Future<void> validate({
    required String baseUrl,
    String? username,
    String? password,
  }) async {
    final base = _normalizeBase(baseUrl);
    final body = await _fetch('$base$_opdsPath', _authHeaders(username, password));
    try {
      _parser.parseFeed(body);
    } catch (_) {
      throw const OpdsException(OpdsErrorKind.invalidFeed);
    }
  }

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

  String _abs(String href, String base) {
    if (href.startsWith('http://') || href.startsWith('https://')) return href;
    return '$base${href.startsWith('/') ? '' : '/'}$href';
  }

  OpdsEntry _resolveUrls(OpdsEntry e, String base) {
    return OpdsEntry(
      calibreId: e.calibreId,
      title: e.title,
      author: e.author,
      series: e.series,
      seriesIndex: e.seriesIndex,
      coverUrl: e.coverUrl == null ? null : _abs(e.coverUrl!, base),
      downloadUrl: _abs(e.downloadUrl, base),
      language: e.language,
      fileSizeKb: e.fileSizeKb,
      description: e.description,
      tags: e.tags,
    );
  }
}
