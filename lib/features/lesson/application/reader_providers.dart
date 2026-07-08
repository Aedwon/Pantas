import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/study_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderContext {
  const ReaderContext({
    required this.lesson,
    required this.topicName,
    required this.next,
    required this.positionInTopic,
    required this.lessonsInTopic,
    required this.isRead,
    required this.isBookmarked,
    required this.examId,
  });

  final Lesson lesson;
  final String topicName;
  final StudyLesson? next;
  final int positionInTopic;
  final int lessonsInTopic;
  final bool isRead;
  final bool isBookmarked;
  final ExamId? examId;
}

final readerContextProvider =
    FutureProvider.family<ReaderContext?, LessonId>((ref, lessonId) async {
  final lesson = await ref.watch(lessonByIdProvider(lessonId).future);
  if (lesson == null) return null;

  final map = await ref.watch(studyMapProvider.future);
  if (map == null) return null;

  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;

  String? topicName;
  StudyLesson? nextLesson;
  int? positionInTopic;
  int? lessonsInTopic;
  bool isRead = false;
  bool isBookmarked = false;

  for (final subject in map.subjects) {
    for (final topic in subject.topics) {
      final index = topic.lessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        topicName = topic.name;
        positionInTopic = index + 1;
        lessonsInTopic = topic.lessons.length;
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

  if (topicName == null || positionInTopic == null || lessonsInTopic == null) {
    return null;
  }

  return ReaderContext(
    lesson: lesson,
    topicName: topicName,
    next: nextLesson,
    positionInTopic: positionInTopic,
    lessonsInTopic: lessonsInTopic,
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

Future<void> toggleBookmark(dynamic ref, LessonId lessonId) async {
  final repo = ref.read(lessonBookmarksRepositoryProvider);
  final isMarked = await repo.isMarked(lessonId);
  if (isMarked) {
    await repo.unmark(lessonId);
  } else {
    await repo.mark(lessonId);
  }
  ref.invalidate(readerContextProvider(lessonId));
  ref.invalidate(isBookmarkedProvider(lessonId));
  ref.invalidate(studyMapProvider);
}
