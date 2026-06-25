import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../book_detail/providers/book_detail_providers.dart';
import '../providers/downloads_providers.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(sortedDownloadsProvider);
    final sort = ref.watch(downloadsSortProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: booksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateView(
          message: 'Erro ao carregar downloads',
          onRetry: () => ref.invalidate(downloadsProvider),
        ),
        data: (books) {
          if (books.isEmpty) {
            return const EmptyStateView(
              title: 'Nenhum download',
              message: 'Livros baixados para leitura offline aparecerão aqui',
              icon: Icons.download_done_rounded,
            );
          }

          final totalKb = books.fold<int>(
            0,
            (sum, b) => sum + (b.fileSizeKb ?? 0),
          );

          return Column(
            children: [
              _TotalSizeHeader(totalKb: totalKb, bookCount: books.length),
              _SortChips(
                selected: sort,
                onChanged: (s) =>
                    ref.read(downloadsSortProvider.notifier).state = s,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _DownloadItem(
                      book: book,
                      onTap: () => context.go('/library/book/${book.id}'),
                      onDismissed: () => _deleteDownload(ref, book),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteDownload(WidgetRef ref, Book book) {
    if (book.localEpubPath == null) return;
    ref
        .read(bookDownloadServiceProvider)
        .deleteDownload(book.id, book.localEpubPath!);
  }
}

class _TotalSizeHeader extends StatelessWidget {
  const _TotalSizeHeader({required this.totalKb, required this.bookCount});

  final int totalKb;
  final int bookCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeText = totalKb >= 1024
        ? '${(totalKb / 1024).toStringAsFixed(1)} MB'
        : '$totalKb KB';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage_rounded,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Text(
            '$bookCount ${bookCount == 1 ? 'livro' : 'livros'} · $sizeText',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  const _SortChips({required this.selected, required this.onChanged});

  final DownloadsSort selected;
  final ValueChanged<DownloadsSort> onChanged;

  static const _labels = {
    DownloadsSort.recent: 'Recentes',
    DownloadsSort.title: 'Título',
    DownloadsSort.author: 'Autor',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMd,
        vertical: AppTokens.spaceXs,
      ),
      child: Wrap(
        spacing: AppTokens.spaceSm,
        children: DownloadsSort.values.map((s) {
          return FilterChip(
            label: Text(_labels[s]!),
            selected: s == selected,
            onSelected: (_) => onChanged(s),
          );
        }).toList(),
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  const _DownloadItem({
    required this.book,
    required this.onTap,
    required this.onDismissed,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeText = book.fileSizeKb != null
        ? (book.fileSizeKb! >= 1024
              ? '${(book.fileSizeKb! / 1024).toStringAsFixed(1)} MB'
              : '${book.fileSizeKb} KB')
        : '—';

    return Dismissible(
      key: ValueKey(book.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTokens.spaceMd),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDismissed(),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 48,
          height: 72,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: book.coverUrl != null
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.menu_book_rounded, size: 24),
                    ),
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.menu_book_rounded, size: 24),
                  ),
          ),
        ),
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${book.author ?? 'Autor desconhecido'} · $sizeText',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
