import 'package:flutter/material.dart';

/// Tipografia do Leer (seção 7 do SPEC).
///
/// - Display / títulos: Playfair Display (serifada, personalidade)
/// - Body / UI: Inter (legibilidade, neutro)
/// - Leitura: Literata (ver [ReaderFontFamily])
///
/// As fontes são empacotadas em `assets/fonts` (variable fonts, OFL), o que
/// mantém o app totalmente offline-capable — sem busca de fontes em runtime.
class AppTypography {
  AppTypography._();

  static const String displayFamily = 'Playfair Display';
  static const String bodyFamily = 'Inter';
  static const String readerDefaultFamily = 'Literata';

  static TextTheme textTheme(ColorScheme scheme) {
    final base = ThemeData(brightness: scheme.brightness).textTheme;

    TextStyle? display(TextStyle? s) => s?.copyWith(fontFamily: displayFamily);
    TextStyle? body(TextStyle? s) => s?.copyWith(fontFamily: bodyFamily);

    return base
        .copyWith(
          displayLarge: display(base.displayLarge),
          displayMedium: display(base.displayMedium),
          displaySmall: display(base.displaySmall),
          headlineLarge: display(base.headlineLarge),
          headlineMedium: display(base.headlineMedium),
          headlineSmall: display(base.headlineSmall),
          titleLarge: display(base.titleLarge),
          titleMedium: body(base.titleMedium),
          titleSmall: body(base.titleSmall),
          bodyLarge: body(base.bodyLarge),
          bodyMedium: body(base.bodyMedium),
          bodySmall: body(base.bodySmall),
          labelLarge: body(base.labelLarge),
          labelMedium: body(base.labelMedium),
          labelSmall: body(base.labelSmall),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
  }
}

/// Famílias de fonte disponíveis no leitor (seção 4.4).
enum ReaderFontFamily {
  literata('Literata'),
  georgia('Georgia'),
  openSans('Open Sans'),
  robotoSlab('Roboto Slab');

  const ReaderFontFamily(this.label);
  final String label;
}
