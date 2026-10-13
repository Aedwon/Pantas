import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

final readerPositionRepositoryProvider = Provider<ReaderPositionRepository>(
  (ref) =>
      ReaderPositionRepository(ref.watch(appPreferencesRepositoryProvider)),
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
}

class ReadMarkingController {
  ReadMarkingController({
    required this.lessonId,
    required this.examId,
    required this.progressRepository,
    required this.preferencesRepository,
    DateTime Function()? clock,
    this.onMarked,
  }) : _clock = clock ?? DateTime.now;

  final LessonId lessonId;
  final ExamId? examId;
  final LessonProgressRepository progressRepository;
  final AppPreferencesRepository preferencesRepository;

  /// Called once after the lesson is marked read, so screens that show the
  /// day's lessons can refresh.
  final void Function()? onMarked;
  final DateTime Function() _clock;

  DateTime? _openedAt;
  bool _hasMarked = false;

  Future<void> onOpen() async {
    _openedAt = _clock();
    if (examId != null) {
      await preferencesRepository.pushOpenedLesson(
        examId: examId!,
        lessonId: lessonId,
      );
    }
  }

  void onScroll({required double offset, required double maxExtent}) {
    if (_hasMarked || _openedAt == null) return;

    final isAtEnd = maxExtent == 0 || offset >= maxExtent - 24;
    final dwellTime = _clock().difference(_openedAt!);

    if (isAtEnd && dwellTime >= readDwellFloor) {
      _hasMarked = true;
      unawaited(_markRead());
    }
  }

  Future<void> _markRead() async {
    await progressRepository.markRead(lessonId);
    onMarked?.call();
  }
}

final readerContextProvider =
    FutureProvider.family<ReaderContext?, LessonId>((ref, lessonId) async {
  final lesson = await ref.watch(lessonByIdProvider(lessonId).future);
  if (lesson == null) return null;

  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return null;

  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;

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
Future<void> toggleBookmark(WidgetRef ref, LessonId lessonId) async {
  final repo = ref.read(lessonBookmarksRepositoryProvider);
  final isMarked = await repo.isMarked(lessonId);
  if (isMarked) {
    await repo.unmark(lessonId);
  } else {
    await repo.mark(lessonId);
  }
  final exam = (await ref.read(activeExamFocusProvider.future)).exam;
  if (exam != null) {
    final prefs = ref.read(bookmarkPrefsRepositoryProvider);
    final order = await prefs.readCustomOrder(exam.id);
    await prefs.saveCustomOrder(
      exam.id,
      [if (!isMarked) lessonId, ...order.where((id) => id != lessonId)],
    );
  }
  ref
    ..invalidate(readerContextProvider(lessonId))
    ..invalidate(isBookmarkedProvider(lessonId))
    ..invalidate(bookmarkRowsProvider)
    ..invalidate(studyMapProvider);
}
