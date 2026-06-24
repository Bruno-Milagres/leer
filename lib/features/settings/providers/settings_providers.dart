import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../reader/providers/reader_providers.dart';

final allServersProvider = StreamProvider<List<Server>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.serversDao.watchAll();
});

class ReaderPrefsService {
  static const _keyTheme = 'reader_theme';
  static const _keyFontFamily = 'reader_font_family';
  static const _keyFontSize = 'reader_font_size';
  static const _keyLineSpacing = 'reader_line_spacing';

  Future<ReaderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ReaderSettings(
      theme: ReaderThemeType.values[prefs.getInt(_keyTheme) ?? 0],
      fontFamily: prefs.getString(_keyFontFamily) ?? 'Literata',
      fontSize: prefs.getInt(_keyFontSize) ?? 18,
      lineSpacing: prefs.getDouble(_keyLineSpacing) ?? 1.5,
    );
  }

  Future<void> save(ReaderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, settings.theme.index);
    await prefs.setString(_keyFontFamily, settings.fontFamily);
    await prefs.setInt(_keyFontSize, settings.fontSize);
    await prefs.setDouble(_keyLineSpacing, settings.lineSpacing);
  }
}

final readerPrefsServiceProvider = Provider<ReaderPrefsService>(
  (ref) => ReaderPrefsService(),
);
