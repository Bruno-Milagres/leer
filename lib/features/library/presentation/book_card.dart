import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../shared/widgets/shimmer_box.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.progress,
    this.showSourceBadge = false,
    this.onTap,
  });

  final Book book;
  final ReadingProgressData? progress;
  final bool showSourceBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCover(theme),
                  if (progress != null && progress!.percentage > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: progress!.percentage / 100,
                        minHeight: 3,
                        backgroundColor: Colors.black38,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  if (showSourceBadge)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _SourceBadge(book: book),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          if (book.author != null)
            Text(
              book.author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCover(ThemeData theme) {
    if (book.coverUrl == null || book.coverUrl!.isEmpty) {
      return _CoverPlaceholder(theme: theme);
    }

    if (_isLocalPath(book.coverUrl!)) {
      final file = File(book.coverUrl!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return _CoverPlaceholder(theme: theme);
    }

    return CachedNetworkImage(
      imageUrl: book.coverUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ShimmerBox(),
      errorWidget: (_, __, ___) => _CoverPlaceholder(theme: theme),
    );
  }

  bool _isLocalPath(String url) {
    return !url.startsWith('http://') && !url.startsWith('https://');
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        book.downloadUrl != null && !book.downloadUrl!.startsWith('http')
            ? Icons.folder_rounded
            : Icons.dns_rounded,
        size: 14,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.menu_book_rounded,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
