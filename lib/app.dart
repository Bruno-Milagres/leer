import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Raiz do app. Integra Material You (dynamic_color) com fallback do SPEC e o
/// router go_router.
class LeerApp extends ConsumerWidget {
  const LeerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'Leer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(lightDynamic?.harmonized()),
          darkTheme: AppTheme.dark(darkDynamic?.harmonized()),
          themeMode: ThemeMode.system,
          routerConfig: router,
        );
      },
    );
  }
}
