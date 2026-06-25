import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../reader/providers/reader_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(activeSourcesProvider);
    final readerSettings = ref.watch(readerSettingsProvider);

    final sourcesSubtitle = sourcesAsync.when(
      data: (sources) {
        if (sources.isEmpty) return 'Nenhuma fonte configurada';
        return '${sources.length} ${sources.length == 1 ? 'fonte ativa' : 'fontes ativas'}';
      },
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
            leading: const Icon(Icons.library_books_rounded),
            title: const Text('Fontes'),
            subtitle: Text(sourcesSubtitle),
            onTap: () => context.go('/settings/sources'),
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
