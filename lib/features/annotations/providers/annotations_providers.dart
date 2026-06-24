import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

typedef AnnotationWithBook = (Annotation, Book);

final allAnnotationsWithBookProvider =
    StreamProvider<List<AnnotationWithBook>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.annotationsDao.watchAllWithBook();
});

final bookAnnotationsProvider =
    StreamProvider.family<List<Annotation>, int>((ref, bookId) {
  final db = ref.watch(databaseProvider);
  return db.annotationsDao.watchForBook(bookId);
});
