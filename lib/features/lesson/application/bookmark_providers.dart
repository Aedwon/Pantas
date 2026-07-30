import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

export 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

/// What one bookmark row prints. Everything on it comes from the map the
/// screen behind is already holding, so a row costs no query of its own.
class BookmarkRow {
  const BookmarkRow({
    required this.lessonId,
    required this.title,
    required this.topicName,
    required this.estimatedMinutes,
  });

  final LessonId lessonId;
  final String title;
  final String topicName;
  final int estimatedMinutes;
}

final bookmarkPrefsRepositoryProvider = Provider<BookmarkPrefsRepository>(
  (ref) => BookmarkPrefsRepository(ref.watch(appDatabaseProvider)),
);

class BookmarkOrderController extends AsyncNotifier<BookmarkOrder> {
  @override
  Future<BookmarkOrder> build() =>
      ref.read(bookmarkPrefsRepositoryProvider).readOrder();

  Future<void> choose(BookmarkOrder order) async {
    await ref.read(bookmarkPrefsRepositoryProvider).saveOrder(order);
    state = AsyncData(order);
  }
}

final bookmarkOrderProvider =
    AsyncNotifierProvider<BookmarkOrderController, BookmarkOrder>(
  BookmarkOrderController.new,
);

final bookmarkRowsProvider = FutureProvider<List<BookmarkRow>>((ref) async {
  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return const [];

  final order = await ref.watch(bookmarkOrderProvider.future);
  final repo = ref.watch(lessonBookmarksRepositoryProvider);

  // The map's own walk is subject order, then topic order, then the authored
  // lesson order, which is exactly what "By subject" means.
  final byLessonId = <LessonId, BookmarkRow>{};
  final corpusOrder = <LessonId>[];
  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      for (final lesson in topic.lessons) {
        corpusOrder.add(lesson.id);
        byLessonId[lesson.id] = BookmarkRow(
          lessonId: lesson.id,
          title: lesson.title,
          topicName: topic.name,
          estimatedMinutes: lesson.estimatedMinutes,
        );
      }
    }
  }

  final ordered = switch (order) {
    BookmarkOrder.recent => await repo.recentFirst(),
    BookmarkOrder.oldest => await repo.oldestFirst(),
    BookmarkOrder.custom => await repo.customOrder(),
    BookmarkOrder.bySubject => null,
  };

  if (ordered != null) {
    return [
      // A bookmark whose lesson is no longer in the corpus is dropped rather
      // than drawn as a blank row. Content can be withdrawn between releases.
      for (final row in ordered)
        if (byLessonId[row.lessonId] case final bookmark?) bookmark,
    ];
  }

  final marked = await repo.markedIds();
  return [
    for (final lessonId in corpusOrder)
      if (marked.contains(lessonId))
        if (byLessonId[lessonId] case final bookmark?) bookmark,
  ];
});

final bookmarkCountProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(bookmarkRowsProvider.future)).length;
});
