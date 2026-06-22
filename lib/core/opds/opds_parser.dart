import 'package:xml/xml.dart';

import 'opds_entry.dart';

/// Faz o parse de um feed OPDS 1.2 (Atom/XML) do Calibre-Web em [OpdsEntry]s.
///
/// É tolerante a campos opcionais ausentes: série, idioma, descrição, tamanho
/// e capa podem faltar sem causar erro.
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

  List<OpdsEntry> parse(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final feed = document.rootElement;
    return feed
        .findElements('entry')
        .map(_parseEntry)
        .whereType<OpdsEntry>()
        .toList(growable: false);
  }

  OpdsEntry? _parseEntry(XmlElement entry) {
    final title = _text(entry, 'title');
    if (title == null) return null;

    final acquisition = _findLink(entry, _acquisitionRels,
        epubPreferred: true);
    if (acquisition == null) return null; // sem download não é um livro lível

    final id = _text(entry, 'id') ?? acquisition;
    final calibreId = _extractCalibreId(id);

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
    final el = parent.findElements(name).firstOrNull ??
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
    final seriesEl = entry.findAllElements('series').firstOrNull ??
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
  String? _findLink(XmlElement entry, Set<String> rels,
      {bool epubPreferred = false}) {
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
    final link = entry.findElements('link').firstWhere(
          (l) => l.getAttribute('href') == downloadHref,
          orElse: () => entry,
        );
    final length = link.getAttribute('length');
    final bytes = int.tryParse(length ?? '');
    if (bytes == null) return null;
    return (bytes / 1024).round();
  }

  /// Extrai o id numérico do Calibre de uma URN como `urn:uuid:...` ou
  /// `/opds/...` quando presente; caso contrário usa o próprio id.
  String _extractCalibreId(String id) {
    final match = RegExp(r'(\d+)$').firstMatch(id.trim());
    return match?.group(1) ?? id.trim();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
