import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
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
    this.subjectName = '',
  });

  final LessonId lessonId;
  final String title;
  final String topicName;
  final int estimatedMinutes;
  final String subjectName;
}

final bookmarkPrefsRepositoryProvider = Provider<BookmarkPrefsRepository>(
  (ref) => BookmarkPrefsRepository(ref.watch(appDatabaseProvider)),
);

final bookmarkMembershipProvider = StreamProvider<List<LessonBookmarkLocalRow>>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .select(ref.watch(appDatabaseProvider).lessonBookmarksLocal)
      .watch(),
);
final bookmarkPreferenceChangesProvider = StreamProvider<List<AccountPrefRow>>(
  (ref) => ref
      .watch(appDatabaseProvider)
      .select(ref.watch(appDatabaseProvider).accountPrefs)
      .watch(),
);

class BookmarkOrderController extends AsyncNotifier<BookmarkOrder> {
  String? _examId;
  bool _saving = false;
  bool _disposed = false;

  @override
  Future<BookmarkOrder> build() async {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
    _examId = exam?.id;
    if (exam == null) return BookmarkOrder.recent;
    final order = await ref
        .read(bookmarkPrefsRepositoryProvider)
        .readOrder(examId: exam.id);
    ref.listen(bookmarkPreferenceChangesProvider, (previous, next) {
      // Read current storage rather than replaying an older stream snapshot.
      if (state.hasValue && next.hasValue && !_saving) unawaited(_reload());
    });
    return order;
  }

  Future<void> _reload() async {
    final exam = _examId;
    if (exam == null) return;
    try {
      final order = await ref
          .read(bookmarkPrefsRepositoryProvider)
          .readOrder(examId: exam);
      if (!_disposed &&
          !_saving &&
          exam == _examId &&
          state.valueOrNull != order) {
        state = AsyncData(order);
      }
    } on Exception catch (error, stack) {
      if (!_disposed) state = AsyncError(error, stack);
    }
  }

  Future<void> choose(BookmarkOrder order) async {
    await future;
    final exam = (await ref.read(activeExamFocusProvider.future)).exam;
    if (exam == null) return;
    _saving = true;
    try {
      await ref
          .read(bookmarkPrefsRepositoryProvider)
          .saveOrder(order, examId: exam.id);
      state = AsyncData(order);
    } finally {
      _saving = false;
    }
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
          subjectName: subject.name,
        );
      }
    }
  }

  final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
  if (exam == null) return const [];
  final recent = await repo.recentFirst();
  final legacy = await repo.customOrder();
  final prefs = ref.watch(bookmarkPrefsRepositoryProvider);
  final custom = await prefs.readCustomOrder(
    exam.id,
    legacyOrder: [
      for (final row in legacy)
        if (byLessonId.containsKey(row.lessonId)) row.lessonId,
    ],
  );
  // Subscribe after migration so its initial write cannot cancel this read.
  ref
    ..listen(bookmarkMembershipProvider, (previous, next) {
      if ((previous?.hasValue ?? false) && next.hasValue) ref.invalidateSelf();
    })
    ..listen(bookmarkPreferenceChangesProvider, (previous, next) {
      if ((previous?.hasValue ?? false) && next.hasValue) {
        final key = 'bookmark_order.${exam.id}';
        final before = previous!.requireValue
            .where((row) => row.key == key)
            .firstOrNull
            ?.value;
        final after =
            next.requireValue.where((row) => row.key == key).firstOrNull?.value;
        if (before != after) ref.invalidateSelf();
      }
    });
  final marked = {for (final row in recent) row.lessonId};
  final ids = [
    for (final row in recent)
      if (byLessonId.containsKey(row.lessonId) &&
          !custom.contains(row.lessonId))
        row.lessonId,
    for (final id in custom)
      if (marked.contains(id) && byLessonId.containsKey(id)) id,
  ];
  final ordered = switch (order) {
    BookmarkOrder.recent => recent,
    BookmarkOrder.oldest => List<LessonBookmarkLocalRow>.of(recent),
    BookmarkOrder.custom => null,
    BookmarkOrder.bySubject => null,
  };
  if (order == BookmarkOrder.custom) {
    return [for (final id in ids) byLessonId[id]!];
  }

  if (ordered != null) {
    ordered.sort((a, b) {
      final time = order == BookmarkOrder.recent
          ? b.markedAt.compareTo(a.markedAt)
          : a.markedAt.compareTo(b.markedAt);
      return time != 0
          ? time
          : (byLessonId[a.lessonId]?.title ?? '')
              .compareTo(byLessonId[b.lessonId]?.title ?? '');
    });
    return [
      // A bookmark whose lesson is no longer in the corpus is dropped rather
      // than drawn as a blank row. Content can be withdrawn between releases.
      for (final row in ordered)
        if (byLessonId[row.lessonId] case final bookmark?) bookmark,
    ];
  }

  return [
    for (final lessonId in corpusOrder)
      if (marked.contains(lessonId))
        if (byLessonId[lessonId] case final bookmark?) bookmark,
  ];
});

final bookmarkCountProvider = FutureProvider<int>((ref) async {
  return (await ref.watch(bookmarkRowsProvider.future)).length;
});
