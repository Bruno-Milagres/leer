import 'package:flutter/animation.dart';

/// Tokens visuais do design system (seção 7 do SPEC).
class AppTokens {
  AppTokens._();

  // Border radius
  static const double radiusCard = 12;
  static const double radiusSheet = 24;
  static const double radiusChip = 8;
  static const double radiusButton = 12;

  // Espaçamentos base
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  // Animação (Material standard easing)
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOutCubicEmphasized;

  // Biblioteca
  static const int libraryGridColumns = 2;
  static const int shimmerPlaceholderCount = 8;
}
