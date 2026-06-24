import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/settings_providers.dart';

class ServerSettingsScreen extends ConsumerWidget {
  const ServerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serversAsync = ref.watch(allServersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Servidores')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServerForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: serversAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erro ao carregar')),
        data: (servers) {
          if (servers.isEmpty) {
            return EmptyStateView(
              title: 'Nenhum servidor',
              message: 'Adicione um servidor Calibre-Web para começar',
              icon: Icons.dns_rounded,
              actionLabel: 'Adicionar servidor',
              onAction: () => _showServerForm(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              return _ServerTile(
                server: server,
                onTap: () => _showServerForm(context, ref, server: server),
                onActivate: () =>
                    ref.read(databaseProvider).serversDao.setActive(server.id),
                onDelete: () => _confirmDelete(context, ref, server),
              );
            },
          );
        },
      ),
    );
  }

  void _showServerForm(BuildContext context, WidgetRef ref,
      {Server? server}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ServerForm(
          server: server,
          onTest: (url, username, password) =>
              ref.read(opdsClientProvider).validate(
                    baseUrl: url,
                    username: username,
                    password: password,
                  ),
          onSave: (name, url, username, password) async {
            final db = ref.read(databaseProvider);
            final credentials = ref.read(secureCredentialStoreProvider);

            if (server != null) {
              await db.serversDao.updateServer(server.copyWith(
                name: name,
                url: url,
                username: Value(username),
              ));
              if (password != null) {
                await credentials.savePassword(server.id, password);
              }
            } else {
              final id = await db.serversDao.insertServer(ServersCompanion(
                name: Value(name),
                url: Value(url),
                username: Value(username),
              ));
              await credentials.savePassword(id, password);
              final all = await db.serversDao.getAll();
              if (all.length == 1) {
                await db.serversDao.setActive(id);
              }
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Server server) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover servidor?'),
        content:
            Text('O servidor "${server.name}" e seus livros serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final credentials = ref.read(secureCredentialStoreProvider);
              await credentials.deletePassword(server.id);
              await db.serversDao.deleteServer(server.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.server,
    required this.onTap,
    required this.onActivate,
    required this.onDelete,
  });

  final Server server;
  final VoidCallback onTap;
  final VoidCallback onActivate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Icon(
        Icons.dns_rounded,
        color: server.isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(server.name),
      subtitle: Text(server.url, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!server.isActive)
            IconButton(
              icon: const Icon(Icons.radio_button_off_rounded),
              tooltip: 'Ativar',
              onPressed: onActivate,
            )
          else
            Icon(Icons.radio_button_checked_rounded,
                color: theme.colorScheme.primary),
          IconButton(
            icon:
                Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ServerForm extends StatefulWidget {
  const _ServerForm({
    this.server,
    required this.onTest,
    required this.onSave,
  });

  final Server? server;
  final Future<void> Function(String url, String? username, String? password)
      onTest;
  final Future<void> Function(
      String name, String url, String? username, String? password) onSave;

  @override
  State<_ServerForm> createState() => _ServerFormState();
}

class _ServerFormState extends State<_ServerForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _passCtrl;
  bool _testing = false;
  String? _testResult;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.server?.name ?? '');
    _urlCtrl = TextEditingController(text: widget.server?.url ?? '');
    _userCtrl = TextEditingController(text: widget.server?.username ?? '');
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.server != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Editar servidor' : 'Novo servidor',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome',
              hintText: 'Ex: Casa, Oracle',
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'http://192.168.1.100:8083',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppTokens.spaceSm),
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(labelText: 'Usuário'),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          TextField(
            controller: _passCtrl,
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: isEditing ? '(deixe vazio para manter)' : null,
            ),
            obscureText: true,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_find_rounded),
            label: Text(_testing ? 'Testando...' : 'Testar conexão'),
          ),
          if (_testResult != null) ...[
            const SizedBox(height: AppTokens.spaceSm),
            Text(
              _testResult!,
              style: TextStyle(
                color: _testResult!.startsWith('✓')
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.spaceMd),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Salvando...' : 'Salvar'),
          ),
          const SizedBox(height: AppTokens.spaceMd),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      await widget.onTest(
        _urlCtrl.text,
        _userCtrl.text.isNotEmpty ? _userCtrl.text : null,
        _passCtrl.text.isNotEmpty ? _passCtrl.text : null,
      );
      if (mounted) setState(() => _testResult = '✓ Conexão OK');
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('unauthorized')
            ? 'Credenciais inválidas'
            : 'Falha na conexão';
        setState(() => _testResult = '✗ $msg');
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _urlCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(
      _nameCtrl.text,
      _urlCtrl.text,
      _userCtrl.text.isNotEmpty ? _userCtrl.text : null,
      _passCtrl.text.isNotEmpty ? _passCtrl.text : null,
    );
    if (mounted) setState(() => _saving = false);
  }
}
