import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class HomeTodayData {
  HomeTodayData({
    required this.today,
    required List<HomeTodayLesson> lessons,
    required this.questionWork,
    required this.canAdvance,
    this.examName = '',
    this.examShortName = '',
    this.extras = const HomeDayExtras(),
  }) : lessons = List.unmodifiable(lessons);
  final RoadmapToday today;
  final List<HomeTodayLesson> lessons;
  final TodayQuestionWork? questionWork;
  final bool canAdvance;
  final String examName;
  final String examShortName;

  /// The calm line and the mock row, read with the same rule on every
  /// platform.
  final HomeDayExtras extras;
}

typedef HomeTodayLoader = Future<HomeTodayData> Function(
  String examId,
  Future<Future<bool> Function()> originalGuard,
);

/// The platform seam is replaced by the authoritative server reader on web.
/// The native reader must never become a web fallback.
final homeTodayLoaderProvider = Provider<HomeTodayLoader>((ref) {
  return (examId, originalGuard) async {
    if (kIsWeb) throw StateError('Server roadmap reader is required');
    final guard = await originalGuard;
    if (!await guard()) throw StateError('Home owner changed');
    final work = await ref.read(todayQuestionLauncherProvider).load(
          examId,
          originalGuard: originalGuard,
        );
    final today = work.today;
    final contentDb = ref.read(contentDatabaseProvider);
    final groups = await ref
        .read(contentRepositoryProvider)
        .lessonMetaByTopics(today.snapshot.digest.scopeTopicIds);
    final byId = {
      for (final group in groups.values)
        for (final lesson in group) lesson.id: lesson,
    };
    final topics = await (contentDb.select(contentDb.contentTopics)
          ..where((t) => t.id.isIn(today.snapshot.digest.scopeTopicIds)))
        .get();
    final subjects = await (contentDb.select(contentDb.contentSubjects)
          ..where((s) => s.id.isIn(topics.map((t) => t.subjectId))))
        .get();
    final subjectNames = {for (final s in subjects) s.id: s.name};
    final names = {for (final t in topics) t.id: subjectNames[t.subjectId]};
    final positions = ref.read(readerPositionRepositoryProvider);
    final lessons = <HomeTodayLesson>[];
    for (final id in today.snapshot.plan.lessonIds) {
      final lesson = byId[id];
      if (lesson == null || names[lesson.topicId] == null) {
        throw StateError('Planned lesson content unavailable');
      }
      lessons.add(
        HomeTodayLesson(
          id: id,
          title: lesson.title,
          subject: names[lesson.topicId]!,
          minutes: lesson.estimatedMinutes,
          read: !today.remaining.lessonIds.contains(id),
          fraction: await positions.readFraction(examId, id),
          advanced: today.snapshot.plan.advancedIds.contains(id),
        ),
      );
    }
    final canAdvance = await ref
        .read(roadmapControllerProvider)
        .canAdvance(examId, originalGuard: originalGuard);
    final exam = (await ref.read(activeExamFocusProvider.future)).exam;
    final settings = await ref.read(userSettingsProvider.future);
    final shortName = exam?.shortName ?? '';
    final extras = await readHomeDayExtras(
      today: today.snapshot,
      examShortName: shortName,
      studyDays: settings.studyDays,
      recentChanges: () =>
          ref.read(roadmapChangeLogRepositoryProvider).recent(examId),
      priorSnapshot: () => ref
          .read(roadmapDayRepositoryProvider)
          .latestBefore(examId, today.snapshot.day),
      mockDurationMinutes: () async {
        final blueprints =
            await ref.read(mockBlueprintRepoProvider).byExam(examId);
        return blueprints.firstOrNull?.durationMinutes;
      },
    );
    if (!await guard()) throw StateError('Home owner changed');
    return HomeTodayData(
      today: today,
      lessons: lessons,
      questionWork: work,
      canAdvance: canAdvance,
      examName: exam?.name ?? '',
      examShortName: shortName,
      extras: extras,
    );
  };
});
