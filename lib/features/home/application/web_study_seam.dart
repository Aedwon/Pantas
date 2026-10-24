import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';

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
  (ref) async => null,
);

/// Subjects, topics and lessons for the performance screen, from the
/// server's insights read.
final webPerformanceViewProvider =
    FutureProvider.autoDispose<PerformanceViewData>(
  (ref) async => throw StateError('Server insights reader is required'),
);

/// One topic's detail from the server's insights read.
final webTopicDetailProvider =
    FutureProvider.autoDispose.family<TopicDetail, String>(
  (ref, topicId) async =>
      throw StateError('Server insights reader is required'),
);
