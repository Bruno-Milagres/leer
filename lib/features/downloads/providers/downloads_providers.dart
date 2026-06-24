import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

enum DownloadsSort { recent, title, author }

final downloadsSortProvider = StateProvider<DownloadsSort>(
  (ref) => DownloadsSort.recent,
);

final downloadsProvider = StreamProvider<List<Book>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.booksDao.watchDownloaded();
});

final sortedDownloadsProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final booksAsync = ref.watch(downloadsProvider);
  final sort = ref.watch(downloadsSortProvider);

  return booksAsync.whenData((books) {
    final sorted = List<Book>.from(books);
    switch (sort) {
      case DownloadsSort.recent:
        sorted.sort((a, b) => b.syncedAt.compareTo(a.syncedAt));
      case DownloadsSort.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
      case DownloadsSort.author:
        sorted.sort((a, b) =>
            (a.author ?? '').compareTo(b.author ?? ''));
    }
    return sorted;
  });
});
