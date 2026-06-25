import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

enum LibraryFilter { all, reading, downloaded, bySeries, bySource }

final libraryFilterProvider = StateProvider<LibraryFilter>(
  (ref) => LibraryFilter.all,
);

typedef BookWithProgress = (Book, ReadingProgressData?);

final libraryBooksProvider = StreamProvider<List<BookWithProgress>>((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return repository.watchAllBooks();
});

final activeSourceCountProvider = Provider<int>((ref) {
  final sourcesAsync = ref.watch(activeSourcesProvider);
  return sourcesAsync.valueOrNull?.length ?? 0;
});

final filteredBooksProvider = Provider<AsyncValue<List<BookWithProgress>>>((
  ref,
) {
  final booksAsync = ref.watch(libraryBooksProvider);
  final filter = ref.watch(libraryFilterProvider);

  return booksAsync.whenData((books) {
    switch (filter) {
      case LibraryFilter.all:
        return books;
      case LibraryFilter.reading:
        return books
            .where(
              (e) =>
                  e.$2 != null &&
                  e.$2!.percentage > 0 &&
                  e.$2!.percentage < 100,
            )
            .toList();
      case LibraryFilter.downloaded:
        return books.where((e) => e.$1.isDownloaded).toList();
      case LibraryFilter.bySeries:
        final withSeries = books.where((e) => e.$1.series != null).toList()
          ..sort((a, b) {
            final cmp = a.$1.series!.compareTo(b.$1.series!);
            if (cmp != 0) return cmp;
            return (a.$1.seriesIndex ?? 0).compareTo(b.$1.seriesIndex ?? 0);
          });
        final withoutSeries = books.where((e) => e.$1.series == null).toList();
        return [...withSeries, ...withoutSeries];
      case LibraryFilter.bySource:
        final sorted = List<BookWithProgress>.from(books)
          ..sort((a, b) => a.$1.sourceId.compareTo(b.$1.sourceId));
        return sorted;
    }
  });
});
