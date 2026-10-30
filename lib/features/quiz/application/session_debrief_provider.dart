import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/lesson_meta.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

final class DebriefRecommendation {
  const DebriefRecommendation({
    required this.title,
    required this.because,
    required this.lessonId,
    this.questionIds = const [],
  });
  final String title;
  final String because;
  final String lessonId;
  final List<String> questionIds;
}

final class DebriefPlanData {
  const DebriefPlanData({required this.lessonTitles, this.next});
  final Map<String, String> lessonTitles;
  final DebriefRecommendation? next;
}

String debriefBecause(PlanReasonKind kind, String target) => switch (kind) {
      PlanReasonKind.prerequisite => '$target builds on it.',
      PlanReasonKind.followUp => 'Practice this before going back to $target.',
      PlanReasonKind.weakTopic => 'Your recent answers in $target need work.',
      PlanReasonKind.nextUp => 'It is next in your plan for $target.',
    };

/// Reads catalog metadata only. Missing recommendations stay absent; no sample
/// lesson or inferred reason is substituted for an empty or unavailable plan.
final sessionDebriefPlanProvider = FutureProvider.autoDispose
    .family<DebriefPlanData, String>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  final metadata = await content.lessonMetaByTopics(topics.map((t) => t.id));
  final lessons = <String, LessonMeta>{
    for (final group in metadata.values)
      for (final lesson in group) lesson.id: lesson,
  };
  final titles = {for (final l in lessons.values) l.id: l.title};
  final today = await ref.watch(roadmapTodayProvider(examId).future);
  final plan = today.remaining;
  final questions =
      await content.selectionRowsByTopics(topics.map((t) => t.id));
  final byQuestion = {
    for (final group in questions.values)
      for (final q in group) q.id: q,
  };
  final candidates = [
    ...plan.lessonIds,
    ...plan.reviewQuestionIds,
    ...plan.newQuestionIds,
  ];
  for (final id in candidates) {
    final reason = plan.reasons[id];
    final lesson = lessons[id] ?? lessons[byQuestion[id]?.lessonId];
    if (reason == null || lesson == null) continue;
    final topic = topics.where((t) => t.id == lesson.topicId).firstOrNull;
    final target = switch (reason.kind) {
      PlanReasonKind.prerequisite ||
      PlanReasonKind.followUp =>
        titles[reason.forLessonId],
      PlanReasonKind.weakTopic || PlanReasonKind.nextUp => topic?.name,
    };
    if (target == null) continue;
    final practice = !plan.lessonIds.contains(id);
    return DebriefPlanData(
      lessonTitles: titles,
      next: DebriefRecommendation(
        title: practice ? '${lesson.title} practice' : lesson.title,
        because: debriefBecause(reason.kind, target),
        lessonId: lesson.id,
        questionIds: practice
            ? [
                for (final qid in [
                  ...plan.reviewQuestionIds,
                  ...plan.newQuestionIds,
                ])
                  if (byQuestion[qid]?.lessonId == lesson.id) qid,
              ]
            : const [],
      ),
    );
  }
  return DebriefPlanData(lessonTitles: titles);
});

/// Claims a day before showing a diagnosis. The preference belongs to the
/// account, not the exam, so switching exams cannot show a second prompt today.
/// No protected detail is persisted.
final sessionDebriefClaimProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, sessionId) async {
  final auth = await ref.watch(authStateProvider.future);
  final uid = switch (auth) {
    AnonymousAuthState(:final uid) => uid,
    SignedInAuthState(:final user) => user.uid,
    _ => null,
  };
  if (uid == null) return false;
  final prefs = ref.watch(appPreferencesRepositoryProvider);
  final day = ref.read(nowProvider)().toLocal();
  final stamp = '${day.year}-${day.month}-${day.day}';
  final key = 'debrief_diagnosis_day_v1:$uid';
  final sessionKey = 'debrief_diagnosis_session_v1:$uid:$sessionId';
  final db = ref.watch(appDatabaseProvider);
  return db.transaction(() async {
    if (await prefs.deviceValue(key) == stamp ||
        await prefs.deviceValue(sessionKey) != null) {
      return false;
    }
    if (ref.read(authStateProvider).valueOrNull != auth) return false;
    await prefs.setDeviceValue(key, stamp);
    await prefs.setDeviceValue(sessionKey, 'shown');
    return true;
  });
});
