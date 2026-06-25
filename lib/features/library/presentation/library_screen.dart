import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../providers/library_providers.dart';
import 'book_card.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(filteredBooksProvider);
    final filter = ref.watch(libraryFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context, ref),
        child: CustomScrollView(
          slivers: [
            _FilterChipsBar(
              selected: filter,
              onChanged: (f) =>
                  ref.read(libraryFilterProvider.notifier).state = f,
            ),
            booksAsync.when(
              loading: () => const _ShimmerGrid(),
              error: (err, _) => SliverFillRemaining(
                child: ErrorStateView(
                  message: 'Erro ao carregar biblioteca',
                  onRetry: () => ref.invalidate(libraryBooksProvider),
                ),
              ),
              data: (books) {
                if (books.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyStateView(
                      title: 'Nenhum livro encontrado',
                      message: 'Puxe para baixo para sincronizar suas fontes',
                    ),
                  );
                }

                if (filter == LibraryFilter.bySeries) {
                  return _SeriesGroupedList(books: books, ref: ref);
                }

                if (filter == LibraryFilter.bySource) {
                  return _SourceGroupedList(books: books, ref: ref);
                }

                return _BooksGrid(books: books, ref: ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(libraryRepositoryProvider).refreshAll();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao sincronizar: $e')));
    }
  }
}

class _FilterChipsBar extends StatelessWidget {
  const _FilterChipsBar({required this.selected, required this.onChanged});

  final LibraryFilter selected;
  final ValueChanged<LibraryFilter> onChanged;

  static const _labels = {
    LibraryFilter.all: 'Todos',
    LibraryFilter.reading: 'Lendo',
    LibraryFilter.downloaded: 'Baixados',
    LibraryFilter.bySeries: 'Por Série',
    LibraryFilter.bySource: 'Por Fonte',
  };

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMd,
          vertical: AppTokens.spaceSm,
        ),
        child: Wrap(
          spacing: AppTokens.spaceSm,
          children: LibraryFilter.values.map((f) {
            return FilterChip(
              label: Text(_labels[f]!),
              selected: f == selected,
              onSelected: (_) => onChanged(f),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BooksGrid extends StatelessWidget {
  const _BooksGrid({required this.books, required this.ref});

  final List<BookWithProgress> books;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final sourceCount = ref.read(activeSourceCountProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppTokens.libraryGridColumns,
          mainAxisSpacing: AppTokens.spaceMd,
          crossAxisSpacing: AppTokens.spaceMd,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final (book, progress) = books[index];
          return BookCard(
            book: book,
            progress: progress,
            showSourceBadge: sourceCount > 1,
            onTap: () => context.go('/library/book/${book.id}'),
          );
        }, childCount: books.length),
      ),
    );
  }
}

class _SeriesGroupedList extends StatelessWidget {
  const _SeriesGroupedList({required this.books, required this.ref});

  final List<BookWithProgress> books;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<BookWithProgress>>{};
    for (final entry in books) {
      final key = entry.$1.series ?? '\x00';
      (groups[key] ??= []).add(entry);
    }

    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        if (a == '\x00') return 1;
        if (b == '\x00') return -1;
        return a.compareTo(b);
      });

    final sourceCount = ref.read(activeSourceCountProvider);
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final key = sortedKeys[index];
          final groupBooks = groups[key]!;
          final seriesName = key == '\x00' ? 'Sem série' : key;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppTokens.spaceLg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.spaceSm,
                ),
                child: Text(
                  seriesName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppTokens.libraryGridColumns,
                  mainAxisSpacing: AppTokens.spaceMd,
                  crossAxisSpacing: AppTokens.spaceMd,
                  childAspectRatio: 0.55,
                ),
                itemCount: groupBooks.length,
                itemBuilder: (context, i) {
                  final (book, progress) = groupBooks[i];
                  return BookCard(
                    book: book,
                    progress: progress,
                    showSourceBadge: sourceCount > 1,
                    onTap: () => context.go('/library/book/${book.id}'),
                  );
                },
              ),
            ],
          );
        }, childCount: sortedKeys.length),
      ),
    );
  }
}

class _SourceGroupedList extends ConsumerWidget {
  const _SourceGroupedList({required this.books, required this.ref});

  final List<BookWithProgress> books;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final sourcesAsync = widgetRef.watch(allSourcesProvider);
    final sourceNames = <int, String>{};
    if (sourcesAsync.hasValue) {
      for (final s in sourcesAsync.value!) {
        sourceNames[s.id] = s.name;
      }
    }

    final groups = <int, List<BookWithProgress>>{};
    for (final entry in books) {
      (groups[entry.$1.sourceId] ??= []).add(entry);
    }

    final sortedKeys = groups.keys.toList()..sort();
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final sourceId = sortedKeys[index];
          final groupBooks = groups[sourceId]!;
          final sourceName = sourceNames[sourceId] ?? 'Fonte $sourceId';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: AppTokens.spaceLg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.spaceSm,
                ),
                child: Text(
                  sourceName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: AppTokens.libraryGridColumns,
                  mainAxisSpacing: AppTokens.spaceMd,
                  crossAxisSpacing: AppTokens.spaceMd,
                  childAspectRatio: 0.55,
                ),
                itemCount: groupBooks.length,
                itemBuilder: (context, i) {
                  final (book, progress) = groupBooks[i];
                  return BookCard(
                    book: book,
                    progress: progress,
                    showSourceBadge: false,
                    onTap: () => context.go('/library/book/${book.id}'),
                  );
                },
              ),
            ],
          );
        }, childCount: sortedKeys.length),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppTokens.libraryGridColumns,
          mainAxisSpacing: AppTokens.spaceMd,
          crossAxisSpacing: AppTokens.spaceMd,
          childAspectRatio: 0.55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, _) => ShimmerBox(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          ),
          childCount: AppTokens.shimmerPlaceholderCount,
        ),
      ),
    );
  }
}
