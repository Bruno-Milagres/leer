import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

class ReaderBookData {
  const ReaderBookData({required this.book, this.progress});
  final Book book;
  final ReadingProgressData? progress;
}

final readerBookProvider =
    FutureProvider.family<ReaderBookData?, int>((ref, bookId) async {
  final db = ref.watch(databaseProvider);
  final book = await db.booksDao.getById(bookId);
  if (book == null) return null;
  final progress = await db.readingProgressDao.getForBook(bookId);
  return ReaderBookData(book: book, progress: progress);
});

enum ReaderThemeType { light, sepia, dark, amoled }

class ReaderSettings {
  const ReaderSettings({
    this.theme = ReaderThemeType.light,
    this.fontFamily = 'Literata',
    this.fontSize = 18,
    this.lineSpacing = 1.5,
  });

  final ReaderThemeType theme;
  final String fontFamily;
  final int fontSize;
  final double lineSpacing;

  ReaderSettings copyWith({
    ReaderThemeType? theme,
    String? fontFamily,
    int? fontSize,
    double? lineSpacing,
  }) =>
      ReaderSettings(
        theme: theme ?? this.theme,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        lineSpacing: lineSpacing ?? this.lineSpacing,
      );

  EpubDisplaySettings toDisplaySettings() {
    return EpubDisplaySettings(
      fontSize: fontSize,
      theme: _toEpubTheme(),
      snap: true,
      flow: EpubFlow.paginated,
    );
  }

  EpubTheme _toEpubTheme() {
    switch (theme) {
      case ReaderThemeType.light:
        return EpubTheme.custom(
          backgroundDecoration: const BoxDecoration(color: Colors.white),
          foregroundColor: Colors.black,
          customCss: _cssOverrides(),
        );
      case ReaderThemeType.sepia:
        return EpubTheme.custom(
          backgroundDecoration:
              const BoxDecoration(color: Color(0xFFF5E6CA)),
          foregroundColor: const Color(0xFF5B4636),
          customCss: _cssOverrides(),
        );
      case ReaderThemeType.dark:
        return EpubTheme.custom(
          backgroundDecoration:
              const BoxDecoration(color: Color(0xFF1C1917)),
          foregroundColor: const Color(0xFFD4D0CB),
          customCss: _cssOverrides(),
        );
      case ReaderThemeType.amoled:
        return EpubTheme.custom(
          backgroundDecoration:
              const BoxDecoration(color: Colors.black),
          foregroundColor: const Color(0xFFB0B0B0),
          customCss: _cssOverrides(),
        );
    }
  }

  Map<String, dynamic> _cssOverrides() => {
        'body': {
          'font-family': '$fontFamily, serif !important',
          'line-height': '${lineSpacing}em !important',
        },
      };
}

const readerFontFamilies = ['Literata', 'Georgia', 'Open Sans', 'Roboto Slab'];

final readerSettingsProvider = StateProvider<ReaderSettings>(
  (ref) => const ReaderSettings(),
);
