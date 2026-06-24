import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../providers/annotations_providers.dart';

class AnnotationsScreen extends ConsumerWidget {
  const AnnotationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final annotationsAsync = ref.watch(allAnnotationsWithBookProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Anotações')),
      body: annotationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateView(
          message: 'Erro ao carregar anotações',
          onRetry: () => ref.invalidate(allAnnotationsWithBookProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              title: 'Nenhuma anotação',
              message: 'Destaques e notas feitos durante a leitura aparecerão aqui',
              icon: Icons.bookmark_border_rounded,
            );
          }

          final grouped = <int, (Book, List<Annotation>)>{};
          for (final (annotation, book) in items) {
            final entry = grouped.putIfAbsent(
                book.id, () => (book, <Annotation>[]));
            entry.$2.add(annotation);
          }

          final groups = grouped.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(AppTokens.spaceMd),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final (book, annotations) = groups[index];
              return _BookAnnotationGroup(
                book: book,
                annotations: annotations,
                onDelete: (id) {
                  ref.read(databaseProvider).annotationsDao.deleteAnnotation(id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BookAnnotationGroup extends StatelessWidget {
  const _BookAnnotationGroup({
    required this.book,
    required this.annotations,
    required this.onDelete,
  });

  final Book book;
  final List<Annotation> annotations;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                book.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              tooltip: 'Copiar anotações',
              onPressed: () => _exportToClipboard(context),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.spaceSm),
        ...annotations.map((a) => Dismissible(
              key: ValueKey(a.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: AppTokens.spaceMd),
                color: theme.colorScheme.error,
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) => onDelete(a.id),
              child: _AnnotationItem(
                annotation: a,
                bookId: book.id,
              ),
            )),
        const SizedBox(height: AppTokens.spaceLg),
      ],
    );
  }

  void _exportToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln(book.title);
    buffer.writeln('---');
    for (final a in annotations) {
      buffer.writeln('"${a.selectedText}"');
      if (a.note != null && a.note!.isNotEmpty) {
        buffer.writeln('→ ${a.note}');
      }
      buffer.writeln();
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anotações copiadas')),
    );
  }
}

class _AnnotationItem extends StatelessWidget {
  const _AnnotationItem({
    required this.annotation,
    required this.bookId,
  });

  final Annotation annotation;
  final int bookId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(
      int.parse(annotation.color.replaceFirst('#', '0xFF')),
    );

    return InkWell(
      onTap: () => context.go('/library/book/$bookId/read'),
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTokens.spaceSm,
          horizontal: AppTokens.spaceSm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTokens.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${annotation.selectedText}"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (annotation.note != null &&
                      annotation.note!.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.spaceXs),
                    Text(
                      annotation.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
