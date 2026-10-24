import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/domain/study_models.dart';

/// THE web seam for Home and performance.
///
/// Every screen in this family reads native storage on a phone. On web the
/// authoritative reads come from the server (`getRoadmap`, `getStudyInsights`)
/// and are wired by the web data lane. Each provider below is the single
/// replacement point for one read. Until that lane lands they fail
/// recoverably or report no evidence; native code is never a web fallback and
/// nothing here computes a figure locally.
///
/// The Today loader is the same seam, in `homeTodayLoaderProvider`
/// (`home_today.dart`), whose web branch is replaced the same way.
bool get kIsWebStudy => kIsWeb;

/// Actual end of the account's active trial grant for the selected exam
/// (`getStudyInsights.trialEndsAt`). Null means no trial evidence, never a
/// guess.
final webTrialEndsAtProvider = FutureProvider.autoDispose<DateTime?>(
  (ref) async {
    final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
    if (exam == null) return null;
    final value = await ref.watch(serverStudyInsightsProvider(exam.id).future);
    final endsAt = value.trialEndsAt;
    return endsAt == null ? null : DateTime.fromMillisecondsSinceEpoch(endsAt);
  },
);

/// Subjects, topics and lessons for the performance screen, from the
/// server's insights read.
final webPerformanceViewProvider =
    FutureProvider.autoDispose<PerformanceViewData>(
  (ref) async {
    final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
    if (exam == null) throw StateError('Study exam unavailable');
    final value = await ref.watch(serverStudyInsightsProvider(exam.id).future);
    final subjectNames = {for (final row in value.subjects) row.id: row.title};
    final topicNames = {for (final row in value.topics) row.id: row.title};
    final subjectOf = {
      for (final row in value.topics)
        if (row.parentId != null) row.id: row.parentId!,
    };
    PerformanceRow row(StudyPerformanceRow item, String? parent) =>
        PerformanceRow(
          id: item.id,
          title: item.title,
          subtext: parent,
          correct: item.correct,
          answered: item.answered,
          secondsPerQuestion: null,
        );
    return PerformanceViewData(
      subjects: [for (final item in value.subjects) row(item, null)],
      topics: [
        for (final item in value.topics) row(item, subjectNames[item.parentId]),
      ],
      lessons: [
        for (final item in value.lessons) row(item, topicNames[item.parentId]),
      ],
      subjectCounts: {
        for (final item in value.subjects)
          if (item.topicCount != null) item.id: item.topicCount!,
      },
      lessonLevelAvailable: value.lessonLevelAvailable,
      parentSubjectIds: {
        ...subjectOf,
        for (final item in value.lessons)
          if (subjectOf[item.parentId] != null)
            item.id: subjectOf[item.parentId]!,
      },
    );
  },
);

/// One topic's detail from the server's insights read.
final webTopicDetailProvider =
    FutureProvider.autoDispose.family<TopicDetail, String>(
  (ref, topicId) async =>
      throw StateError('Server insights reader is required'),
);
