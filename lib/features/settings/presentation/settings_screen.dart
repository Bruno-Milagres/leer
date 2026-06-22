import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// M08 — Configurações (hub). Itens detalhados virão no módulo.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns_rounded),
            title: const Text('Servidor'),
            subtitle: const Text('Calibre-Web e conexão OPDS'),
            onTap: () => context.go('/settings/server'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Leitura'),
            subtitle: const Text('Tema, fonte e espaçamento'),
            onTap: () => context.go('/settings/reader'),
          ),
        ],
      ),
    );
  }
}
