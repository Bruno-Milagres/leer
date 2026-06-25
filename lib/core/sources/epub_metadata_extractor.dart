import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'library_source.dart';

class EpubExtractResult {
  const EpubExtractResult({required this.metadata, this.coverBytes});

  final BookMetadata metadata;
  final Uint8List? coverBytes;
}

class EpubMetadataExtractor {
  EpubExtractResult? extract(File file, String externalId) {
    try {
      final bytes = file.readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      final opfPath = _findOpfPath(archive);
      if (opfPath == null) return null;

      final opfFile = archive.findFile(opfPath);
      if (opfFile == null) return null;

      final opfContent = String.fromCharCodes(opfFile.content as List<int>);
      final opfDoc = XmlDocument.parse(opfContent);
      final opfDir = opfPath.contains('/')
          ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
          : '';

      final metadata = _parseOpf(opfDoc, externalId, file);
      final coverBytes = _extractCover(archive, opfDoc, opfDir);

      return EpubExtractResult(metadata: metadata, coverBytes: coverBytes);
    } catch (_) {
      return null;
    }
  }

  String? _findOpfPath(Archive archive) {
    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile == null) return null;

    try {
      final content = String.fromCharCodes(containerFile.content as List<int>);
      final doc = XmlDocument.parse(content);
      final rootfile = doc.findAllElements('rootfile').firstOrNull;
      return rootfile?.getAttribute('full-path');
    } catch (_) {
      return null;
    }
  }

  BookMetadata _parseOpf(XmlDocument doc, String externalId, File file) {
    String? dcText(String name) {
      final el =
          doc.findAllElements('dc:$name').firstOrNull ??
          doc.findAllElements(name).firstOrNull;
      final text = el?.innerText.trim();
      return (text == null || text.isEmpty) ? null : text;
    }

    final title = dcText('title') ?? _fileNameWithoutExtension(file);
    final author = dcText('creator');
    final language = dcText('language');
    final description = dcText('description');

    String? seriesName;
    double? seriesIndex;
    for (final meta in doc.findAllElements('meta')) {
      final name = meta.getAttribute('name');
      final content = meta.getAttribute('content');
      if (name == 'calibre:series' && content != null && content.isNotEmpty) {
        seriesName = content;
      }
      if (name == 'calibre:series_index' && content != null) {
        seriesIndex = double.tryParse(content);
      }
    }

    final fileSizeKb = (file.lengthSync() / 1024).round();

    return BookMetadata(
      externalId: externalId,
      title: title,
      author: author,
      series: seriesName,
      seriesIndex: seriesIndex,
      localEpubPath: file.path,
      isDownloaded: true,
      downloadUrl: file.path,
      language: language,
      fileSizeKb: fileSizeKb,
      description: description,
    );
  }

  Uint8List? _extractCover(Archive archive, XmlDocument opfDoc, String opfDir) {
    final coverHref = _findCoverHref(opfDoc);
    if (coverHref == null) return null;

    final coverPath = coverHref.startsWith('/')
        ? coverHref.substring(1)
        : '$opfDir$coverHref';

    final coverFile = archive.findFile(coverPath);
    if (coverFile == null) return null;

    return Uint8List.fromList(coverFile.content as List<int>);
  }

  String? _findCoverHref(XmlDocument doc) {
    // Method 1: manifest item with properties="cover-image"
    for (final item in doc.findAllElements('item')) {
      if (item.getAttribute('properties')?.contains('cover-image') == true) {
        return item.getAttribute('href');
      }
    }

    // Method 2: meta[name=cover] → content references manifest item id
    for (final meta in doc.findAllElements('meta')) {
      if (meta.getAttribute('name') == 'cover') {
        final coverId = meta.getAttribute('content');
        if (coverId != null) {
          for (final item in doc.findAllElements('item')) {
            if (item.getAttribute('id') == coverId) {
              return item.getAttribute('href');
            }
          }
        }
      }
    }

    return null;
  }

  String _fileNameWithoutExtension(File file) {
    final name = file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    return dot > 0 ? name.substring(0, dot) : name;
  }
}
