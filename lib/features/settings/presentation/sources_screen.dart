import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(allSourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fontes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSourceDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: sourcesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erro ao carregar')),
        data: (sources) {
          if (sources.isEmpty) {
            return EmptyStateView(
              title: 'Nenhuma fonte',
              message: 'Adicione uma fonte de biblioteca para começar',
              icon: Icons.library_books_rounded,
              actionLabel: 'Adicionar fonte',
              onAction: () => _showAddSourceDialog(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: sources.length,
            itemBuilder: (context, index) {
              final source = sources[index];
              return _SourceTile(
                source: source,
                onToggle: (active) => ref
                    .read(databaseProvider)
                    .sourcesDao
                    .toggleActive(source.id, active),
                onEdit: () {
                  if (source.type == 'calibre') {
                    _showCalibreForm(context, ref, source: source);
                  }
                },
                onDelete: () => _confirmDelete(context, ref, source),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSourceDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTokens.spaceMd),
            Text('Adicionar fonte', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: AppTokens.spaceMd),
            ListTile(
              leading: const Icon(Icons.dns_rounded),
              title: const Text('Calibre-Web'),
              subtitle: const Text('Servidor OPDS com autenticação'),
              onTap: () {
                Navigator.pop(ctx);
                _showCalibreForm(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: const Text('Pasta local'),
              subtitle: const Text('Ler EPUBs de uma pasta do dispositivo'),
              onTap: () {
                Navigator.pop(ctx);
                _addLocalFolder(context, ref);
              },
            ),
            const SizedBox(height: AppTokens.spaceMd),
          ],
        ),
      ),
    );
  }

  void _showCalibreForm(BuildContext context, WidgetRef ref, {Source? source}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _CalibreForm(
          source: source,
          onTest: (url, username, password) async {
            var effectivePassword = password;
            if (source != null && (password == null || password.isEmpty)) {
              effectivePassword = await ref
                  .read(secureCredentialStoreProvider)
                  .readPassword(source.id);
            }
            await ref.read(opdsClientProvider).validate(
                  baseUrl: url,
                  username: username,
                  password: effectivePassword,
                );
          },
          onSave: (name, url, username, password) async {
            final db = ref.read(databaseProvider);
            final credentials = ref.read(secureCredentialStoreProvider);

            if (source != null) {
              await db.sourcesDao.updateSource(
                source.copyWith(
                  name: name,
                  url: Value(url),
                  username: Value(username),
                  hasCredentials: username != null,
                ),
              );
              if (password != null) {
                await credentials.savePassword(source.id, password);
              }
            } else {
              final id = await db.sourcesDao.insertSource(
                SourcesCompanion(
                  type: const Value('calibre'),
                  name: Value(name),
                  url: Value(url),
                  username: Value(username),
                  hasCredentials: Value(username != null),
                ),
              );
              await credentials.savePassword(id, password);
              final all = await db.sourcesDao.getAll();
              if (all.length == 1) {
                await db.sourcesDao.toggleActive(id, true);
              }
            }
            if (ctx.mounted) Navigator.pop(ctx);
            // Sync automático após fechar o form
            try {
              final sources = await db.sourcesDao.getAll();
              final newSource = sources.lastOrNull;
              if (newSource != null) {
                await ref
                    .read(libraryRepositoryProvider)
                    .refreshSource(newSource.id);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao sincronizar: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _addLocalFolder(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final db = ref.read(databaseProvider);
    final folderName = result.split('/').last.split('\\').last;

    final id = await db.sourcesDao.insertSource(
      SourcesCompanion(
        type: const Value('localFolder'),
        name: Value(folderName),
        url: Value(result),
      ),
    );

    final all = await db.sourcesDao.getAll();
    if (all.length == 1) {
      await db.sourcesDao.toggleActive(id, true);
    }

    // Trigger initial scan
    if (context.mounted) {
      ref.read(libraryRepositoryProvider).refreshSource(id);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Source source) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover fonte?'),
        content: Text(
          source.type == 'calibre'
              ? 'A fonte "${source.name}" e seus livros serão removidos.'
              : 'A fonte "${source.name}" será removida. Os arquivos EPUB originais não serão deletados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              if (source.type == 'calibre') {
                final credentials = ref.read(secureCredentialStoreProvider);
                await credentials.deletePassword(source.id);
              }
              await db.sourcesDao.deleteSource(source.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.source,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Source source;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCalibre = source.type == 'calibre';

    return ListTile(
      onTap: isCalibre ? onEdit : null,
      leading: Icon(
        isCalibre ? Icons.dns_rounded : Icons.folder_rounded,
        color: source.isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(source.name),
      subtitle: Text(
        source.url ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: source.isActive, onChanged: onToggle),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _CalibreForm extends StatefulWidget {
  const _CalibreForm({this.source, required this.onTest, required this.onSave});

  final Source? source;
  final Future<void> Function(String url, String? username, String? password)
  onTest;
  final Future<void> Function(
    String name,
    String url,
    String? username,
    String? password,
  )
  onSave;

  @override
  State<_CalibreForm> createState() => _CalibreFormState();
}

class _CalibreFormState extends State<_CalibreForm> {
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
    _nameCtrl = TextEditingController(text: widget.source?.name ?? '');
    _urlCtrl = TextEditingController(text: widget.source?.url ?? '');
    _userCtrl = TextEditingController(text: widget.source?.username ?? '');
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
    final isEditing = widget.source != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isEditing ? 'Editar fonte Calibre' : 'Novo Calibre-Web',
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
              helperText: isEditing ? '✓ Senha salva no dispositivo' : null,
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
