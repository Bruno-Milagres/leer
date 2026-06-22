import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leer/core/theme/app_theme.dart';

void main() {
  test('Tema escuro de fallback usa o primary caramelo do SPEC', () {
    final theme = AppTheme.dark();
    expect(theme.colorScheme.primary, const Color(0xFFC2956C));
  });

  testWidgets('ProviderScope constrói sem erros', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const SizedBox()),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
