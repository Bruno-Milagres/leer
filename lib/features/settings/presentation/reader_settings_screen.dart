import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../reader/providers/reader_providers.dart';
import '../providers/settings_providers.dart';

class ReaderSettingsScreen extends ConsumerWidget {
  const ReaderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(readerSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferências de leitura')),
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.spaceMd),
        children: [
          Text('Tema de leitura', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceSm),
          Row(
            children: ReaderThemeType.values.map((t) {
              final colors = _themeColors(t);
              final selected = t == settings.theme;
              return Padding(
                padding: const EdgeInsets.only(right: AppTokens.spaceSm),
                child: GestureDetector(
                  onTap: () => _update(ref, settings.copyWith(theme: t)),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.$1,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text('Aa',
                              style: TextStyle(color: colors.$2, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_themeLabel(t),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Text('Fonte', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTokens.spaceSm),
          Wrap(
            spacing: AppTokens.spaceSm,
            children: readerFontFamilies.map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: f == settings.fontFamily,
                onSelected: (_) =>
                    _update(ref, settings.copyWith(fontFamily: f)),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Text('Tamanho: ${settings.fontSize}px',
              style: theme.textTheme.titleSmall),
          Slider(
            value: settings.fontSize.toDouble(),
            min: 12,
            max: 28,
            divisions: 16,
            label: '${settings.fontSize}',
            onChanged: (v) =>
                _update(ref, settings.copyWith(fontSize: v.round())),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Text(
              'Espaçamento: ${settings.lineSpacing.toStringAsFixed(1)}',
              style: theme.textTheme.titleSmall),
          Slider(
            value: settings.lineSpacing,
            min: 1.0,
            max: 2.5,
            divisions: 15,
            label: settings.lineSpacing.toStringAsFixed(1),
            onChanged: (v) =>
                _update(ref, settings.copyWith(lineSpacing: v)),
          ),
          const SizedBox(height: AppTokens.spaceLg),
          Container(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            decoration: BoxDecoration(
              color: _themeColors(settings.theme).$1,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            ),
            child: Text(
              'O pardal pousou sobre o livro aberto e observou as palavras com curiosidade, como se pudesse ler cada história que se escondia entre as páginas.',
              style: TextStyle(
                fontFamily: settings.fontFamily,
                fontSize: settings.fontSize.toDouble(),
                height: settings.lineSpacing,
                color: _themeColors(settings.theme).$2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _update(WidgetRef ref, ReaderSettings settings) {
    ref.read(readerSettingsProvider.notifier).state = settings;
    ref.read(readerPrefsServiceProvider).save(settings);
  }

  (Color, Color) _themeColors(ReaderThemeType t) {
    switch (t) {
      case ReaderThemeType.light:
        return (Colors.white, Colors.black);
      case ReaderThemeType.sepia:
        return (const Color(0xFFF5E6CA), const Color(0xFF5B4636));
      case ReaderThemeType.dark:
        return (const Color(0xFF1C1917), const Color(0xFFD4D0CB));
      case ReaderThemeType.amoled:
        return (Colors.black, const Color(0xFFB0B0B0));
    }
  }

  String _themeLabel(ReaderThemeType t) {
    switch (t) {
      case ReaderThemeType.light:
        return 'Claro';
      case ReaderThemeType.sepia:
        return 'Sépia';
      case ReaderThemeType.dark:
        return 'Escuro';
      case ReaderThemeType.amoled:
        return 'AMOLED';
    }
  }
}
