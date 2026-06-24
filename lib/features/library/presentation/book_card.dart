import 'dart:convert';

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
    this.serverUsername,
    this.serverPassword,
    this.onTap,
  });

  final Book book;
  final ReadingProgressData? progress;
  final String? serverUsername;
  final String? serverPassword;
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

    return CachedNetworkImage(
      imageUrl: book.coverUrl!,
      fit: BoxFit.cover,
      httpHeaders: _authHeaders,
      placeholder: (_, __) => const ShimmerBox(),
      errorWidget: (_, __, ___) => _CoverPlaceholder(theme: theme),
    );
  }

  Map<String, String> get _authHeaders {
    if (serverUsername == null || serverUsername!.isEmpty) return const {};
    final token = base64Encode(
      utf8.encode('$serverUsername:${serverPassword ?? ''}'),
    );
    return {'authorization': 'Basic $token'};
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
