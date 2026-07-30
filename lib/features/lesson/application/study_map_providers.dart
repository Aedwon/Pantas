import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';

/// Null when no exam is chosen. The screen draws its own fallback for that,
/// so it is a state rather than an error.
final studyMapProvider = FutureProvider<StudyMap?>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) return null;

  final content = ref.watch(contentRepositoryProvider);
  final scopedTopics = await ref.watch(scopedTopicsProvider(exam.id).future);
  final scopedSubjects =
      await ref.watch(scopedSubjectsProvider(exam.id).future);

  final topicsBySubject = <SubjectId, List<Topic>>{};
  for (final topic in scopedTopics) {
    topicsBySubject.putIfAbsent(topic.subjectId, () => []).add(topic);
  }

  final topicIds = [
    for (final topics in topicsBySubject.values)
      for (final topic in topics) topic.id,
  ];

  return buildStudyMap(
    exam: exam,
    subjects: scopedSubjects,
    topicsBySubject: topicsBySubject,
    lessonsByTopic: await content.lessonsByTopics(topicIds),
    readLessonIds:
        await ref.watch(lessonProgressRepositoryProvider).readLessonIds(),
    bookmarkedLessonIds:
        await ref.watch(lessonBookmarksRepositoryProvider).markedIds(),
  );
});

/// Which topic is expanded, at most one, remembered per exam across visits to
/// the tab. One at a time is what bounds the page: fully expanded, UPCAT is
/// 164 rows.
class OpenTopicController extends AsyncNotifier<TopicId?> {
  @override
  Future<TopicId?> build() async {
    final examId = await _examId();
    if (examId == null) return null;
    return ref.read(appPreferencesRepositoryProvider).openTopicId(examId);
  }

  Future<void> toggle(TopicId topicId) async {
    final next = state.valueOrNull == topicId ? null : topicId;
    await _write(next);
  }

  Future<void> close() => _write(null);

  Future<void> _write(TopicId? topicId) async {
    final examId = await _examId();
    if (examId == null) return;
    await ref
        .read(appPreferencesRepositoryProvider)
        .setOpenTopicId(examId: examId, topicId: topicId);
    state = AsyncData(topicId);
  }

  Future<ExamId?> _examId() async {
    final focus = await ref.read(activeExamFocusProvider.future);
    return focus.exam?.id;
  }
}

final openTopicProvider = AsyncNotifierProvider<OpenTopicController, TopicId?>(
  OpenTopicController.new,
);

/// The lesson the "Last opened" row offers to resume. Null hides the row.
final lastOpenedLessonProvider = FutureProvider<Lesson?>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final examId = focus.exam?.id;
  if (examId == null) return null;

  final lessonId = await ref
      .watch(appPreferencesRepositoryProvider)
      .lastOpenedLessonId(examId);
  if (lessonId == null) return null;

  return ref.watch(contentRepositoryProvider).lessonById(lessonId);
});
