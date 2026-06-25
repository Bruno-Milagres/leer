import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/reader/providers/reader_providers.dart';
import 'features/settings/providers/settings_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsService = ReaderPrefsService();
  final savedSettings = await prefsService.load();

  runApp(
    ProviderScope(
      overrides: [readerSettingsProvider.overrideWith((ref) => savedSettings)],
      child: const LeerApp(),
    ),
  );
}
