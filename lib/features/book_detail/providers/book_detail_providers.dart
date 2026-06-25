import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../services/book_download_service.dart';

final bookDetailProvider = FutureProvider.family<Book?, int>((
  ref,
  bookId,
) async {
  final db = ref.watch(databaseProvider);
  return db.booksDao.getById(bookId);
});

final bookProgressProvider = StreamProvider.family<ReadingProgressData?, int>((
  ref,
  bookId,
) {
  final db = ref.watch(databaseProvider);
  return db.readingProgressDao.watchForBook(bookId);
});

final annotationCountProvider = FutureProvider.family<int, int>((
  ref,
  bookId,
) async {
  final db = ref.watch(databaseProvider);
  return db.annotationsDao.countForBook(bookId);
});

final bookDownloadServiceProvider = Provider<BookDownloadService>((ref) {
  final db = ref.watch(databaseProvider);
  return BookDownloadService(Dio(), db.booksDao);
});
