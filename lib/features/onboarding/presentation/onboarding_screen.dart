import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/empty_state.dart';

/// M09 — primeiro acesso. Implementação completa do fluxo guiado virá no módulo.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyStateView(
          icon: Icons.auto_stories_rounded,
          title: 'Bem-vindo ao Leer',
          message:
              'Conecte sua biblioteca Calibre-Web para começar a ler.',
          actionLabel: 'Configurar servidor',
          onAction: () => context.go('/settings/server'),
        ),
      ),
    );
  }
}
