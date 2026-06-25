import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/empty_state.dart';

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
              'Conecte sua biblioteca Calibre-Web ou escolha uma pasta local para começar a ler.',
          actionLabel: 'Configurar fonte',
          onAction: () => context.go('/settings/sources'),
        ),
      ),
    );
  }
}
