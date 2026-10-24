import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/practice_launcher.dart';
import 'package:pantas/features/home/presentation/topic_detail_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/home');

/// `/performance`: Your performance, reached from Home's card. The title and
/// back stay on a load failure, with Try Again (DT_Error).
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(performanceViewProvider);
    final order = ref.watch(tableOrderProvider);
    final pro = ref.watch(proForActiveExamProvider).valueOrNull ?? false;
    final paused = ref.watch(entitlementProvider).valueOrNull?.state ==
        EntitlementState.paused;
    final view = data.valueOrNull;
    final saved = order.valueOrNull;
    if (view == null || saved == null) {
      final failed = data.hasError || order.hasError;
      return PantasPage(
        title: 'Your performance',
        backLabel: 'Home',
        onBack: () => _back(context),
        children: [
          if (failed)
            errorFor('performance', () {
              ref
                ..invalidate(performanceViewProvider)
                ..invalidate(tableOrderProvider);
            })
          else
            loadingFor(const AsyncLoading<void>()),
        ],
      );
    }
    return PerformancePage(
      data: view,
      pro: pro,
      paused: paused,
      initialLevel: pro ? saved.level.index : 0,
      initialSort: saved.direction == TableSortDirection.descending
          ? SortCycleOrder.strongest
          : SortCycleOrder.weakest,
      onBack: () => _back(context),
      onTopic: (id) => unawaited(
        context.push('/performance/topic/${Uri.encodeComponent(id)}'),
      ),
      onLesson: (id) =>
          unawaited(context.push('/lesson/${Uri.encodeComponent(id)}')),
      onPro: () => unawaited(context.push('/settings/pro')),
      onOrderChanged: (level, sort, subjectId) {
        final notifier = ref.read(tableOrderProvider.notifier);
        unawaited(notifier.setLevel(TableLevel.values[level]));
        // Alphabetical is a view of the names, not a stored measured order.
        if (sort != SortCycleOrder.alphabetical) {
          unawaited(notifier.setSortKey(TableSortKey.score));
          unawaited(
            notifier.setDirection(
              sort == SortCycleOrder.weakest
                  ? TableSortDirection.ascending
                  : TableSortDirection.descending,
            ),
          );
        }
        unawaited(notifier.setSubjectId(subjectId));
      },
    );
  }
}

/// `/performance/topic/:topicId`.
class TopicScreen extends ConsumerWidget {
  const TopicScreen({required this.topicId, super.key});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(topicDetailProvider(topicId));
    final data = detail.valueOrNull;
    if (data == null) {
      return PantasPage(
        title: 'Topic',
        backLabel: 'Your performance',
        onBack: () => _back(context),
        children: [
          if (detail.hasError)
            errorFor(
              'topic',
              () => ref.invalidate(topicDetailProvider(topicId)),
            )
          else
            loadingFor(const AsyncLoading<void>()),
        ],
      );
    }
    return TopicDetailPage(
      detail: data,
      onBack: () => _back(context),
      onLesson: (id) =>
          unawaited(context.push('/lesson/${Uri.encodeComponent(id)}')),
      onPractice: () {
        final examId = ref.read(activeExamFocusProvider).valueOrNull?.exam?.id;
        if (examId == null) return;
        unawaited(
          startTopicPractice(context, ref, examId: examId, topicId: topicId),
        );
      },
    );
  }
}
