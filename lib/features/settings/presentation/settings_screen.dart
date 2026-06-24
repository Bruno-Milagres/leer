import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../reader/providers/reader_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeServer = ref.watch(activeServerProvider);
    final readerSettings = ref.watch(readerSettingsProvider);

    final serverSubtitle = activeServer.when(
      data: (s) => s?.name ?? 'Nenhum servidor configurado',
      loading: () => 'Carregando...',
      error: (_, __) => 'Erro',
    );

    final readerSubtitle =
        '${readerSettings.fontFamily} · ${readerSettings.fontSize}px';

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns_rounded),
            title: const Text('Servidores'),
            subtitle: Text(serverSubtitle),
            onTap: () => context.go('/settings/server'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Leitura'),
            subtitle: Text(readerSubtitle),
            onTap: () => context.go('/settings/reader'),
          ),
        ],
      ),
    );
  }
}
