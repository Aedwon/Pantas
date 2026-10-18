import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

export 'package:pantas/features/lesson/domain/models/bookmark_order.dart';

String? _actor(AuthState? state) => switch (state) {
      AnonymousAuthState(:final uid) => 'anonymous:$uid',
      SignedInAuthState(:final user) => 'signed:${user.uid}',
      _ => null,
    };

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
  int _epoch = 0;
  ReaderBoundary? _boundary;

  @override
  Future<BookmarkOrder> build() async {
    _disposed = false;
    final epoch = ++_epoch;
    bool current() => !_disposed && epoch == _epoch;
    ref.onDispose(() {
      _disposed = true;
      _epoch++;
    });
    final initialActor = ref.read(authStateProvider);
    var actorKnown = initialActor.hasValue;
    var lastActor = _actor(initialActor.valueOrNull);
    ref.listen(authStateProvider, (_, next) {
      if (!next.hasValue) return;
      final actor = _actor(next.valueOrNull);
      if (actorKnown && actor != lastActor) ref.invalidateSelf();
      actorKnown = true;
      lastActor = actor;
    });
    final prefs = ref.watch(bookmarkPrefsRepositoryProvider);
    final focus = ref.watch(activeExamFocusProvider.future);
    var missingToken = false;
    ref.listen(bookmarkPreferenceChangesProvider, (before, after) {
      if (missingToken && (before?.hasValue ?? false) && after.hasValue) {
        ref.invalidateSelf();
      } else if (state.hasValue && after.hasValue && !_saving) {
        unawaited(_reload());
      }
    });
    final token = await prefs.readToken();
    missingToken = token == null;
    final exam = (await focus).exam;
    _examId = exam?.id;
    if (exam == null || !current()) return BookmarkOrder.recent;
    final boundary =
        token == null ? null : ReaderBoundary(examId: exam.id, token: token);
    _boundary = boundary;
    final order = await prefs.readOrder(
      examId: exam.id,
      boundary: boundary,
      isCurrent: current,
    );
    if (!current() || (token == null && await prefs.readToken() != null)) {
      throw const BookmarkActionExpired();
    }
    return order;
  }

  Future<void> _reload() async {
    final exam = _examId;
    final epoch = _epoch;
    final boundary = _boundary;
    bool current() => !_disposed && epoch == _epoch;
    if (exam == null) return;
    try {
      final order = await ref
          .read(bookmarkPrefsRepositoryProvider)
          .readOrder(examId: exam, boundary: boundary, isCurrent: current);
      if (current() &&
          !_saving &&
          exam == _examId &&
          state.valueOrNull != order) {
        state = AsyncData(order);
      }
    } on BookmarkActionExpired {
      // Expired reads cannot publish an old preference into a new view.
    } on Exception catch (error, stack) {
      if (current()) state = AsyncError(error, stack);
    }
  }

  Future<void> choose(
    BookmarkOrder order, {
    ReaderBoundary? boundary,
    bool Function()? isCurrent,
  }) async {
    final prefs = ref.read(bookmarkPrefsRepositoryProvider);
    final focus =
        boundary == null ? ref.read(activeExamFocusProvider.future) : null;
    await future;
    if (_disposed || (isCurrent != null && !isCurrent())) return;
    final exam = boundary?.examId ?? (await focus!).exam?.id;
    if (exam == null || _disposed || (isCurrent != null && !isCurrent())) {
      return;
    }
    _saving = true;
    try {
      await prefs.saveOrder(
        order,
        examId: exam,
        boundary: boundary,
        isCurrent: isCurrent,
      );
      if (!_disposed && (isCurrent == null || isCurrent())) {
        state = AsyncData(order);
      }
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
  var alive = true;
  ref.onDispose(() => alive = false);
  final initialActor = ref.read(authStateProvider);
  var actorKnown = initialActor.hasValue;
  var lastActor = _actor(initialActor.valueOrNull);
  ref.listen(authStateProvider, (_, next) {
    if (!next.hasValue) return;
    final actor = _actor(next.valueOrNull);
    if (actorKnown && actor != lastActor) ref.invalidateSelf();
    actorKnown = true;
    lastActor = actor;
  });
  final prefs = ref.watch(bookmarkPrefsRepositoryProvider);
  final tokenFuture = prefs.readToken();
  final focus = ref.watch(activeExamFocusProvider.future);
  final mapFuture = ref.watch(studyMapProvider.future);
  final orderFuture = ref.watch(bookmarkOrderProvider.future);
  var missingToken = false;
  var migrationDone = false;
  void expireMissing() {
    if (missingToken) {
      alive = false;
      ref.invalidateSelf();
    }
  }

  ref
    ..listen(bookmarkMembershipProvider, (before, after) {
      if ((before?.hasValue ?? false) && after.hasValue) {
        alive = false;
        ref.invalidateSelf();
      }
    })
    ..listen(bookmarkPreferenceChangesProvider, (before, after) {
      if ((before?.hasValue ?? false) && after.hasValue) {
        if (missingToken) {
          expireMissing();
          return;
        }
        final examId = ref.read(activeExamFocusProvider).valueOrNull?.exam?.id;
        final key = 'bookmark_order.$examId';
        final previous =
            before!.requireValue.where((r) => r.key == key).firstOrNull?.value;
        final next =
            after.requireValue.where((r) => r.key == key).firstOrNull?.value;
        if (migrationDone && previous != next) ref.invalidateSelf();
      }
    });
  final token = await tokenFuture;
  missingToken = token == null;
  final map = await mapFuture;
  if (map == null || !alive) return const [];
  final exam = (await focus).exam;
  if (exam == null || !alive) return const [];
  final boundary =
      token == null ? null : ReaderBoundary(examId: exam.id, token: token);
  final order = await orderFuture;
  if (!alive) return const [];
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

  final recent = await repo.recentFirst();
  final legacy = await repo.customOrder();
  if (!alive) return const [];
  final custom = await prefs.readCustomOrder(
    exam.id,
    boundary: boundary,
    isCurrent: () => alive,
    legacyOrder: [
      for (final row in legacy)
        if (byLessonId.containsKey(row.lessonId)) row.lessonId,
    ],
  );
  if (!alive) return const [];
  if (token == null && await prefs.readToken() != null) {
    throw const BookmarkActionExpired();
  }
  if (!alive) return const [];
  migrationDone = true;
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
