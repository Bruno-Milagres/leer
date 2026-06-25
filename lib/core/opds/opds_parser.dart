import 'package:xml/xml.dart';

import 'opds_entry.dart';

/// Resultado do parse de um feed OPDS: livros (entries de aquisição), links de
/// navegação (sub-catálogos) e link de paginação (`next`).
class OpdsFeed {
  const OpdsFeed({
    this.books = const [],
    this.navigationLinks = const [],
    this.nextLink,
  });

  final List<OpdsEntry> books;
  final List<String> navigationLinks;
  final String? nextLink;
}

/// Faz o parse de um feed OPDS 1.2 (Atom/XML) do Calibre-Web em [OpdsEntry]s.
///
/// É tolerante a campos opcionais ausentes: série, idioma, descrição, tamanho
/// e capa podem faltar sem causar erro. Distingue entries de livro (com link
/// de aquisição) de entries de navegação (sub-catálogos).
class OpdsParser {
  const OpdsParser();

  /// Relações de link usadas pelo Calibre-Web.
  static const _acquisitionRels = {
    'http://opds-spec.org/acquisition',
    'http://opds-spec.org/acquisition/open-access',
  };
  static const _coverRels = {
    'http://opds-spec.org/image',
    'http://opds-spec.org/cover',
    'http://opds-spec.org/image/thumbnail',
    'http://opds-spec.org/thumbnail',
  };

  /// Retorna apenas os livros (compatibilidade). Para feeds de navegação
  /// (como o `/opds` raiz do Calibre-Web), retorna lista vazia.
  List<OpdsEntry> parse(String xmlString) => parseFeed(xmlString).books;

  /// Parse completo do feed: livros + links de navegação + paginação.
  OpdsFeed parseFeed(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final feed = document.rootElement;

    final books = <OpdsEntry>[];
    final navLinks = <String>[];

    for (final entry in feed.findElements('entry')) {
      final book = _parseEntry(entry);
      if (book != null) {
        books.add(book);
      } else {
        final nav = _navigationLink(entry);
        if (nav != null) navLinks.add(nav);
      }
    }

    return OpdsFeed(
      books: books,
      navigationLinks: navLinks,
      nextLink: _feedNextLink(feed),
    );
  }

  /// Link de sub-catálogo de um entry de navegação (sem aquisição).
  String? _navigationLink(XmlElement entry) {
    for (final link in entry.findElements('link')) {
      final rel = link.getAttribute('rel');
      if (rel != null && _coverRels.contains(rel)) continue;
      final type = link.getAttribute('type') ?? '';
      if (type.contains('opds-catalog') || rel == 'subsection') {
        return link.getAttribute('href');
      }
    }
    return null;
  }

  /// Link de paginação `next` no nível do feed.
  String? _feedNextLink(XmlElement feed) {
    for (final link in feed.findElements('link')) {
      if (link.getAttribute('rel') == 'next') {
        return link.getAttribute('href');
      }
    }
    return null;
  }

  OpdsEntry? _parseEntry(XmlElement entry) {
    final title = _text(entry, 'title');
    if (title == null) return null;

    final acquisition = _findLink(entry, _acquisitionRels, epubPreferred: true);
    if (acquisition == null) return null; // sem download não é um livro lível

    final id = _text(entry, 'id') ?? acquisition;
    final calibreId =
        _extractCalibreId(acquisition) ?? _extractCalibreId(id) ?? id.trim();

    final cover = _findLink(entry, _coverRels);
    final author = _authorName(entry);
    final series = _series(entry);

    return OpdsEntry(
      calibreId: calibreId,
      title: title.trim(),
      author: author,
      series: series?.name,
      seriesIndex: series?.index,
      coverUrl: cover,
      downloadUrl: acquisition,
      language: _text(entry, 'dcterms:language') ?? _text(entry, 'language'),
      fileSizeKb: _fileSizeKb(entry, acquisition),
      description: _text(entry, 'summary') ?? _text(entry, 'content'),
      tags: _tags(entry),
    );
  }

  String? _text(XmlElement parent, String name) {
    final el =
        parent.findElements(name).firstOrNull ??
        parent.findAllElements(name).firstOrNull;
    final value = el?.innerText.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  String? _authorName(XmlElement entry) {
    final author = entry.findElements('author').firstOrNull;
    if (author == null) return null;
    return author.findElements('name').firstOrNull?.innerText.trim();
  }

  ({String name, double? index})? _series(XmlElement entry) {
    // Calibre expõe a série via <series> ou Dublin Core extensions.
    final seriesEl =
        entry.findAllElements('series').firstOrNull ??
        entry.findAllElements('calibre:series').firstOrNull;
    if (seriesEl == null) return null;
    final name = seriesEl.innerText.trim();
    if (name.isEmpty) return null;

    final indexEl = entry.findAllElements('calibre:series_index').firstOrNull;
    final index = double.tryParse(indexEl?.innerText.trim() ?? '');
    return (name: name, index: index);
  }

  List<String> _tags(XmlElement entry) {
    return entry
        .findElements('category')
        .map((c) => c.getAttribute('label') ?? c.getAttribute('term'))
        .whereType<String>()
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
  }

  /// Procura o primeiro link cujo `rel` casa com [rels]. Quando
  /// [epubPreferred], dá preferência a links com `type` EPUB.
  String? _findLink(
    XmlElement entry,
    Set<String> rels, {
    bool epubPreferred = false,
  }) {
    final links = entry.findElements('link').where((l) {
      final rel = l.getAttribute('rel');
      return rel != null && rels.contains(rel);
    }).toList();
    if (links.isEmpty) return null;

    if (epubPreferred) {
      final epub = links.firstWhere(
        (l) => (l.getAttribute('type') ?? '').contains('epub'),
        orElse: () => links.first,
      );
      return epub.getAttribute('href');
    }
    return links.first.getAttribute('href');
  }

  int? _fileSizeKb(XmlElement entry, String downloadHref) {
    final link = entry
        .findElements('link')
        .firstWhere(
          (l) => l.getAttribute('href') == downloadHref,
          orElse: () => entry,
        );
    final length = link.getAttribute('length');
    final bytes = int.tryParse(length ?? '');
    if (bytes == null) return null;
    return (bytes / 1024).round();
  }

  /// Extrai o id numérico do Calibre. Prefere o id presente na URL de download
  /// (`/opds/download/{id}/epub/`); cai para dígitos finais do id do entry.
  String? _extractCalibreId(String s) {
    final download = RegExp(r'/download/(\d+)').firstMatch(s);
    if (download != null) return download.group(1);
    final trailing = RegExp(r'(\d+)/?$').firstMatch(s.trim());
    return trailing?.group(1);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
