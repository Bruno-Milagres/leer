import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../providers/book_detail_providers.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  ColorScheme? _dynamicScheme;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookDetailProvider(widget.bookId));
    final progressAsync = ref.watch(bookProgressProvider(widget.bookId));
    final annotationCountAsync =
        ref.watch(annotationCountProvider(widget.bookId));

    return bookAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateView(
          message: 'Erro ao carregar livro',
          onRetry: () => ref.invalidate(bookDetailProvider(widget.bookId)),
        ),
      ),
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyStateView(title: 'Livro não encontrado'),
          );
        }

        final progress = progressAsync.valueOrNull;
        final annotationCount = annotationCountAsync.valueOrNull ?? 0;
        final baseTheme = Theme.of(context);
        final effectiveTheme = _dynamicScheme != null
            ? baseTheme.copyWith(colorScheme: _dynamicScheme)
            : baseTheme;

        _extractPalette(book, baseTheme.brightness);

        return Theme(
          data: effectiveTheme,
          child: Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    expandedHeight: 340,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _BookHeader(book: book),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _MetadataSection(
                      book: book,
                      progress: progress,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ActionButtons(
                      book: book,
                      progress: progress,
                      isDownloading: _isDownloading,
                      onRead: () =>
                          context.go('/library/book/${book.id}/read'),
                      onDownload: () => _download(book),
                      onRemoveDownload: () => _removeDownload(book),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TabBar(
                      tabs: [
                        const Tab(text: 'Descrição'),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Anotações'),
                              if (annotationCount > 0) ...[
                                const SizedBox(width: AppTokens.spaceSm),
                                Badge.count(count: annotationCount),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _DescriptionTab(description: book.description),
                    const _AnnotationsTab(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _extractPalette(Book book, Brightness brightness) {
    if (_dynamicScheme != null || book.coverUrl == null) return;

    final provider = CachedNetworkImageProvider(book.coverUrl!);
    PaletteGenerator.fromImageProvider(
      provider,
      maximumColorCount: 4,
      timeout: const Duration(seconds: 3),
    ).then((palette) {
      final dominant = palette.dominantColor?.color;
      if (dominant != null && mounted) {
        setState(() {
          _dynamicScheme = ColorScheme.fromSeed(
            seedColor: dominant,
            brightness: brightness,
          );
        });
      }
    }).catchError((_) {});
  }

  Future<void> _download(Book book) async {
    setState(() => _isDownloading = true);
    try {
      final server = ref.read(activeServerProvider).valueOrNull;
      final password = server != null
          ? await ref
              .read(secureCredentialStoreProvider)
              .readPassword(server.id)
          : null;

      await ref.read(bookDownloadServiceProvider).download(
            book,
            username: server?.username,
            password: password,
          );
      ref.invalidate(bookDetailProvider(widget.bookId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _removeDownload(Book book) async {
    if (book.localEpubPath == null) return;
    try {
      await ref
          .read(bookDownloadServiceProvider)
          .deleteDownload(book.id, book.localEpubPath!);
      ref.invalidate(bookDetailProvider(widget.bookId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover: $e')),
        );
      }
    }
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    if (book.coverUrl == null) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: CachedNetworkImage(
            imageUrl: book.coverUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ShimmerBox(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Container(color: Colors.black54),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.spaceLg),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerBox(),
                  errorWidget: (_, __, ___) => Container(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: const Icon(Icons.menu_book_rounded, size: 48),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.book, this.progress});

  final Book book;
  final ReadingProgressData? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.title, style: theme.textTheme.headlineSmall),
          if (book.author != null) ...[
            const SizedBox(height: AppTokens.spaceXs),
            Text(
              book.author!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (book.series != null) ...[
            const SizedBox(height: AppTokens.spaceXs),
            Text(
              book.seriesIndex != null
                  ? 'Livro ${book.seriesIndex!.toInt()} de ${book.series}'
                  : book.series!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: AppTokens.spaceSm),
          _StatsRow(book: book),
          if (progress != null && progress!.percentage > 0) ...[
            const SizedBox(height: AppTokens.spaceMd),
            _ProgressBar(progress: progress!),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[];
    if (book.pageCount != null) chips.add('${book.pageCount} páginas');
    if (book.language != null) chips.add(book.language!);
    if (book.fileSizeKb != null) chips.add(_formatSize(book.fileSizeKb!));

    if (chips.isEmpty) return const SizedBox.shrink();

    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Wrap(
      spacing: AppTokens.spaceMd,
      children: chips
          .map((c) => Text(c, style: style))
          .toList(),
    );
  }

  String _formatSize(int kb) {
    if (kb >= 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '$kb KB';
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final ReadingProgressData progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = progress.chapter != null
        ? '${progress.percentage}% · ${progress.chapter}'
        : '${progress.percentage}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTokens.spaceXs),
        LinearProgressIndicator(
          value: progress.percentage / 100,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.book,
    this.progress,
    required this.isDownloading,
    required this.onRead,
    required this.onDownload,
    required this.onRemoveDownload,
  });

  final Book book;
  final ReadingProgressData? progress;
  final bool isDownloading;
  final VoidCallback onRead;
  final VoidCallback onDownload;
  final VoidCallback onRemoveDownload;

  @override
  Widget build(BuildContext context) {
    final hasProgress = progress != null && progress!.percentage > 0;
    final readLabel = hasProgress ? 'Continuar Lendo' : 'Começar a Ler';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: book.isDownloaded ? onRead : null,
              icon: Icon(hasProgress
                  ? Icons.auto_stories_rounded
                  : Icons.menu_book_rounded),
              label: Text(book.isDownloaded ? readLabel : 'Baixar para Ler'),
            ),
          ),
          const SizedBox(width: AppTokens.spaceSm),
          if (book.isDownloaded)
            OutlinedButton.icon(
              onPressed: onRemoveDownload,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Remover'),
            )
          else
            OutlinedButton.icon(
              onPressed: isDownloading ? null : onDownload,
              icon: isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(isDownloading ? 'Baixando...' : 'Baixar'),
            ),
        ],
      ),
    );
  }
}

class _DescriptionTab extends StatelessWidget {
  const _DescriptionTab({this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) {
      return const EmptyStateView(
        title: 'Sem descrição',
        icon: Icons.description_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      child: Text(
        description!,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _AnnotationsTab extends StatelessWidget {
  const _AnnotationsTab();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateView(
      title: 'Nenhuma anotação',
      message: 'Destaques e notas aparecerão aqui',
      icon: Icons.bookmark_border_rounded,
    );
  }
}
