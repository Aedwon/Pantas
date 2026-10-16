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
    this.positions,
    this.boundary,
    this.isCurrent,
  }) : _clock = clock ?? DateTime.now;

  final LessonId lessonId;
  final ExamId? examId;
  final bool Function()? isCurrent;
  final ReaderPositionRepository? positions;
  final ReaderBoundary? boundary;
  bool _disposed = false;
  bool get _current => !_disposed && (isCurrent?.call() ?? true);
  void dispose() => _disposed = true;

  Future<bool> _mutate(Future<void> Function() operation) async {
    if (!_current) return false;
    final token = boundary;
    if (token == null) {
      await operation();
      return _current;
    }
    return positions!.runGuarded(token, operation, isCurrent: () => _current);
  }

  final LessonProgressRepository progressRepository;
  final AppPreferencesRepository preferencesRepository;

  /// Called once after the lesson is marked read, so screens that show the
  /// day's lessons can refresh.
  final void Function()? onMarked;
  final DateTime Function() _clock;

  DateTime? _openedAt;
  bool _hasMarked = false;

  Future<void> onOpen() async {
    if (!_current) return;
    _openedAt = _clock();
    if (examId != null) {
      await _mutate(
        () => preferencesRepository.pushOpenedLesson(
          examId: examId!,
          lessonId: lessonId,
        ),
      );
    }
  }

  void onScroll({required double offset, required double maxExtent}) {
    if (!_current || _hasMarked || _openedAt == null) return;

    final isAtEnd = maxExtent == 0 || offset >= maxExtent - 24;
    final dwellTime = _clock().difference(_openedAt!);

    if (isAtEnd && dwellTime >= readDwellFloor) {
      _hasMarked = true;
      unawaited(_markRead());
    }
  }

  Future<void> _markRead() async {
    if (await _mutate(() => progressRepository.markRead(lessonId))) {
      onMarked?.call();
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
}) async {
  final repo = ref.read(lessonBookmarksRepositoryProvider);
  final prefs = ref.read(bookmarkPrefsRepositoryProvider);
  final positions = ref.read(readerPositionRepositoryProvider);
  final changed = await positions.runGuarded(
    boundary,
    () async {
      final isMarked = await repo.isMarked(lessonId);
      if (!isCurrent()) return;
      if (isMarked) {
        await repo.unmark(lessonId);
      } else {
        await repo.mark(lessonId);
      }
      final order = await prefs.readCustomOrder(boundary.examId);
      await prefs.saveCustomOrder(
        boundary.examId,
        [if (!isMarked) lessonId, ...order.where((id) => id != lessonId)],
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
