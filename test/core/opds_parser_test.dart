import 'package:flutter_test/flutter_test.dart';
import 'package:leer/core/opds/opds_parser.dart';

const _feedCompleto = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom"
      xmlns:dcterms="http://purl.org/dc/terms/"
      xmlns:calibre="http://calibre.kovidgoyal.net/2009/metadata">
  <entry>
    <title>Leviathan Wakes</title>
    <id>urn:calibre:42</id>
    <author><name>James S. A. Corey</name></author>
    <dcterms:language>eng</dcterms:language>
    <calibre:series>The Expanse</calibre:series>
    <calibre:series_index>1.0</calibre:series_index>
    <summary>Humanity has colonized the solar system.</summary>
    <category label="Ficção científica" term="sci-fi"/>
    <link rel="http://opds-spec.org/image" href="/opds/cover/42" type="image/jpeg"/>
    <link rel="http://opds-spec.org/acquisition" href="/opds/download/42.epub"
          type="application/epub+zip" length="1048576"/>
  </entry>
</feed>
''';

const _feedMinimo = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <entry>
    <title>Sem Metadados</title>
    <id>urn:calibre:7</id>
    <link rel="http://opds-spec.org/acquisition" href="/opds/download/7.epub"
          type="application/epub+zip"/>
  </entry>
  <entry>
    <title>Entrada de navegação sem download</title>
    <link rel="subsection" href="/opds/category/1"/>
  </entry>
</feed>
''';

void main() {
  const parser = OpdsParser();

  test('faz parse de entrada com metadados completos', () {
    final entries = parser.parse(_feedCompleto);
    expect(entries, hasLength(1));
    final e = entries.single;
    expect(e.title, 'Leviathan Wakes');
    expect(e.author, 'James S. A. Corey');
    expect(e.series, 'The Expanse');
    expect(e.seriesIndex, 1.0);
    expect(e.language, 'eng');
    expect(e.calibreId, '42');
    expect(e.downloadUrl, '/opds/download/42.epub');
    expect(e.coverUrl, '/opds/cover/42');
    expect(e.fileSizeKb, 1024);
    expect(e.tags, contains('Ficção científica'));
    expect(e.description, contains('colonized'));
  });

  test('tolera campos opcionais ausentes', () {
    final entries = parser.parse(_feedMinimo);
    // A entrada de navegação (sem link de aquisição) é ignorada.
    expect(entries, hasLength(1));
    final e = entries.single;
    expect(e.title, 'Sem Metadados');
    expect(e.author, isNull);
    expect(e.series, isNull);
    expect(e.seriesIndex, isNull);
    expect(e.description, isNull);
    expect(e.fileSizeKb, isNull);
  });
}
