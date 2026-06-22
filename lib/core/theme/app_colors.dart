import 'package:flutter/material.dart';

/// Paletas base do Leer (seção 7 do SPEC).
///
/// Estas cores são o *fallback* quando o Material You dinâmico não está
/// disponível. Quando o sistema fornece um [ColorScheme] dinâmico, ele tem
/// precedência (ver [AppTheme]).
class AppColors {
  AppColors._();

  // Warm dark
  static const Color darkBackground = Color(0xFF0F0D0C);
  static const Color darkSurface = Color(0xFF1C1917);
  static const Color darkSurfaceVariant = Color(0xFF292524);
  static const Color darkPrimary = Color(0xFFC2956C); // caramelo
  static const Color darkOnPrimary = Color(0xFF1C1917);
  static const Color darkTextPrimary = Color(0xFFEDE8E3);
  static const Color darkTextMuted = Color(0xFF9C9189);
  static const Color darkBorder = Color(0xFF2E2A27);

  // Light
  static const Color lightBackground = Color(0xFFFFFBF7);
  static const Color lightSurface = Color(0xFFF5F0EB);
  static const Color lightPrimary = Color(0xFF8B5E3C);
  static const Color lightOnPrimary = Color(0xFFFFFBF7);
  static const Color lightTextPrimary = Color(0xFF1C1917);
  static const Color lightTextMuted = Color(0xFF6B6259);
  static const Color lightBorder = Color(0xFFE3DBD2);

  /// Cores padrão de destaque de anotações (seção 4.4).
  static const Color highlightYellow = Color(0xFFFFB300);
  static const Color highlightGreen = Color(0xFF66BB6A);
  static const Color highlightBlue = Color(0xFF42A5F5);
  static const Color highlightPink = Color(0xFFEC407A);

  static const List<Color> highlightColors = [
    highlightYellow,
    highlightGreen,
    highlightBlue,
    highlightPink,
  ];

  /// ColorScheme de fallback (dark).
  static ColorScheme get darkScheme => const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        outline: darkBorder,
      );

  /// ColorScheme de fallback (light).
  static ColorScheme get lightScheme => const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: Color(0xFFEDE4DA),
        outline: lightBorder,
      );
}
