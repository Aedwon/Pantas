import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';

final readerPositionRepositoryProvider = Provider<ReaderPositionRepository>(
  (ref) => ReaderPositionRepository(
    ref.watch(appPreferencesRepositoryProvider),
    database: ref.watch(appDatabaseProvider),
  ),
);

const readDwellFloor = Duration(seconds: 15);

class ReaderContext {
  const ReaderContext({
    required this.lesson,
    required this.topicId,
    required this.topicName,
    required this.next,
    required this.positionInTopic,
    required this.lessonsInTopic,
    required this.topicLessons,
    required this.isRead,
    required this.isBookmarked,
    required this.examId,
    this.boundary,
    this.topicEnding,
    this.nextTopic,
  });

  final Lesson lesson;
  final TopicId topicId;
  final String topicName;
  final StudyLesson? next;
  final int positionInTopic;
  final int lessonsInTopic;
  final List<StudyLesson> topicLessons;
  final bool isRead;
  final bool isBookmarked;
  final ExamId? examId;
  final ReaderBoundary? boundary;
  final LessonEnding? topicEnding;
  final StudyTopic? nextTopic;
}

class ReadMarkingController {
  ReadMarkingController({
    required this.lessonId,
    required this.examId,
    required this.progressRepository,
    required this.preferencesRepository,
    DateTime Function()? clock,
    this.onMarked,
    this.onOpened,
    this.onSaveFailed,
    this.readMetrics,
    this.positions,
    this.boundary,
    this.isCurrent,
  }) : _clock = clock ?? DateTime.now;

  final LessonId lessonId;
  final ExamId? examId;
  final bool Function()? isCurrent;
  final ReaderPositionRepository? positions;
  final ReaderBoundary? boundary;
  final LessonProgressRepository progressRepository;
  final AppPreferencesRepository preferencesRepository;
  final void Function()? onMarked;
  final void Function()? onOpened;
  final void Function({required bool failed})? onSaveFailed;
  final ({double offset, double maxExtent})? Function()? readMetrics;
  final DateTime Function() _clock;
  bool _disposed = false;
  bool _visible = true;
  bool _pendingMark = false;
  bool _resumeAfterPending = false;
  bool _hasMarked = false;
  bool _openFailed = false;
  bool _markFailed = false;
  bool _floorReached = false;
  double? _offset;
  double? _maxExtent;
  DateTime? _openedAt;
  Timer? _floorTimer;

  bool get _current => !_disposed && (isCurrent?.call() ?? true);

  void dispose() {
    _disposed = true;
    _floorTimer?.cancel();
  }

  void setVisible({required bool visible}) {
    final resumed = visible && !_visible;
    _visible = visible;
    if (resumed && _pendingMark) _resumeAfterPending = true;
    if (visible) _evaluate();
  }

  Future<bool> _mutate(
    Future<void> Function() operation, {
    bool requireVisible = false,
  }) async {
    bool current() => _current && (!requireVisible || (_visible && _atEnd));
    if (!current()) return false;
    final token = boundary;
    if (token == null) {
      await operation();
      return current();
    }
    return positions!.runGuarded(token, operation, isCurrent: current);
  }

  void _publishFailure() {
    if (_current) onSaveFailed?.call(failed: _openFailed || _markFailed);
  }

  Future<void> onOpen() async {
    if (!_current) return;
    if (_openedAt == null) {
      _openedAt = _clock();
      _floorTimer = Timer(readDwellFloor, () {
        _floorReached = true;
        _evaluate();
      });
    }
    if (examId == null) return;
    try {
      final saved = await _mutate(
        () => preferencesRepository.pushOpenedLesson(
          examId: examId!,
          lessonId: lessonId,
        ),
      );
      if (!saved || !_current) return;
      _openFailed = false;
      onOpened?.call();
      _publishFailure();
    } catch (_) {
      _openFailed = true;
      _publishFailure();
    }
  }

  Future<void> retry() async {
    if (!_current) return;
    if (_openFailed) await onOpen();
    _evaluate();
  }

  void onScroll({required double offset, required double maxExtent}) {
    _offset = offset;
    _maxExtent = maxExtent;
    _evaluate();
  }

  bool get _atEnd {
    final metrics = readMetrics?.call();
    // A real layout callback must supply current metrics, never stale geometry.
    if (readMetrics != null && metrics == null) return false;
    final offset = metrics?.offset ?? _offset;
    final maxExtent = metrics?.maxExtent ?? _maxExtent;
    return offset != null &&
        maxExtent != null &&
        (maxExtent == 0 || offset >= maxExtent - 24);
  }

  void _evaluate() {
    if (!_current ||
        !_visible ||
        _hasMarked ||
        _pendingMark ||
        _openedAt == null) {
      return;
    }
    final elapsed =
        _floorReached || _clock().difference(_openedAt!) >= readDwellFloor;
    if (!_atEnd || !elapsed) return;
    _pendingMark = true;
    unawaited(_markRead());
  }

  Future<void> _markRead() async {
    var rejected = false;
    try {
      final saved = await _mutate(
        () => progressRepository.markRead(lessonId),
        requireVisible: true,
      );
      rejected = !saved;
      if (!saved || !_current) return;
      _hasMarked = true;
      _markFailed = false;
      onMarked?.call();
      _publishFailure();
    } catch (_) {
      _markFailed = true;
      _publishFailure();
    } finally {
      _pendingMark = false;
      final resume = _resumeAfterPending;
      _resumeAfterPending = false;
      if (resume && rejected) _evaluate();
    }
  }
}

final readerContextProvider =
    FutureProvider.family<ReaderContext?, LessonId>((ref, lessonId) async {
  // Capture provenance before loading content, and cancel this capture on the
  // existing auth/exam/provider lifetime. A later callback cannot create a token.
  var current = true;
  ref.onDispose(() => current = false);
  await ref.watch(authStateProvider.future);
  if (!current) return null;
  final positions = ref.watch(readerPositionRepositoryProvider);
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (!current || focus.exam == null) return null;
  final examId = focus.exam!.id;
  final boundary =
      await positions.readBoundary(examId, isCurrent: () => current);
  if (boundary == null || !current) return null;
  final lesson = await ref.watch(lessonByIdProvider(lessonId).future);
  if (!current || lesson == null) return null;
  final map = await ref.watch(studyMapProvider.future);
  if (!current || map == null) return null;
  if (!await positions.isBoundaryCurrent(boundary, isCurrent: () => current)) {
    return null;
  }

  TopicId? topicId;
  String? topicName;
  StudyLesson? nextLesson;
  int? positionInTopic;
  int? lessonsInTopic;
  var topicLessons = const <StudyLesson>[];
  var isRead = false;
  var isBookmarked = false;

  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      final index = topic.lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        topicId = topic.id;
        topicName = topic.name;
        positionInTopic = index + 1;
        lessonsInTopic = topic.lessons.length;
        topicLessons = topic.lessons;
        if (index + 1 < topic.lessons.length) {
          nextLesson = topic.lessons[index + 1];
        }
        isRead = topic.lessons[index].isRead;
        isBookmarked = topic.lessons[index].isBookmarked;
        break;
      }
    }
    if (topicName != null) break;
  }

  if (topicId == null ||
      topicName == null ||
      positionInTopic == null ||
      lessonsInTopic == null) {
    return null;
  }

  final subjects = map.subjects;
  final subject =
      subjects.firstWhere((s) => s.topics.any((t) => t.id == topicId));
  final topic = subject.topics.firstWhere((t) => t.id == topicId);
  final topics = [for (final s in subjects) ...s.topics]
      .where((t) => t.lessons.isNotEmpty)
      .toList();
  final topicIndex = topics.indexWhere((t) => t.id == topicId);
  final nextTopic = topicIndex >= 0 && topicIndex + 1 < topics.length
      ? topics[topicIndex + 1]
      : null;
  return ReaderContext(
    lesson: lesson,
    topicId: topicId,
    topicName: topicName,
    next: nextLesson,
    positionInTopic: positionInTopic,
    lessonsInTopic: lessonsInTopic,
    topicLessons: topicLessons,
    isRead: isRead,
    isBookmarked: isBookmarked,
    examId: examId,
    boundary: boundary,
    nextTopic: nextTopic,
    topicEnding: decideEnding(
      topic: topic,
      subject: subject,
      examShortName: map.examShortName,
      studentName: null,
      today: DateTime.now(),
      nextTopic: nextTopic,
    ),
  );
});

final isBookmarkedProvider =
    FutureProvider.family<bool, LessonId>((ref, lessonId) async {
  final repo = ref.watch(lessonBookmarksRepositoryProvider);
  return repo.isMarked(lessonId);
});

/// Called from a widget, so it takes a [WidgetRef] rather than a bare
/// dynamic: an untyped ref turns every call below into a dynamic dispatch and
/// hides real errors from the analyzer.
Future<void> toggleBookmark(
  WidgetRef ref,
  LessonId lessonId, {
  required ReaderBoundary boundary,
  required bool Function() isCurrent,
  bool? bookmarked,
}) async {
  final repo = ref.read(lessonBookmarksRepositoryProvider);
  final prefs = ref.read(bookmarkPrefsRepositoryProvider);
  final positions = ref.read(readerPositionRepositoryProvider);
  final changed = await positions.runGuarded(
    boundary,
    () async {
      final isMarked = await repo.isMarked(lessonId);
      if (!isCurrent()) return;
      final next = bookmarked ?? !isMarked;
      if (next == isMarked) return;
      if (next) {
        await repo.mark(lessonId);
      } else {
        await repo.unmark(lessonId);
      }
      final order = await prefs.readCustomOrder(boundary.examId);
      await prefs.saveCustomOrder(
        boundary.examId,
        [if (next) lessonId, ...order.where((id) => id != lessonId)],
      );
    },
    isCurrent: isCurrent,
  );
  if (!changed || !isCurrent()) return;
  ref
    ..invalidate(readerContextProvider(lessonId))
    ..invalidate(isBookmarkedProvider(lessonId))
    ..invalidate(bookmarkRowsProvider)
    ..invalidate(studyMapProvider);
}
