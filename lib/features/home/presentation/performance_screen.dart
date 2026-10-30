import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/practice_launcher.dart';
import 'package:pantas/features/home/presentation/topic_detail_page.dart';
import 'package:pantas/features/home/presentation/widgets/progress_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/web_performance_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/home');

/// `/performance`: Your performance, reached from Home's card. The title and
/// back stay on a load failure, with Try Again (DT_Error).
class PerformanceScreen extends ConsumerWidget {
  const PerformanceScreen({this.initialLevel, super.key});
  final int? initialLevel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(performanceViewProvider);
    final order = ref.watch(tableOrderProvider);
    final pro = ref.watch(currentStudyCoverageProvider);
    final paused = ref.watch(entitlementProvider).valueOrNull?.state ==
        EntitlementState.paused;
    final view = data.unwrapPrevious().asData?.value;
    final saved = order.valueOrNull;
    if (view == null || saved == null) {
      final failed = data.hasError || order.hasError;
      if (context.wideWeb) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(44, 28, 44, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebPerformanceHeader(
                  onBack: () => _back(context),
                  description: false,
                ),
                const SizedBox(height: 28),
                if (failed)
                  WebCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 120,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: context.webTokens.colors.tertiaryLabel,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load your performance.',
                          style: context.webTokens.style(
                            17,
                            color: context.webTokens.colors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 12),
                        WebButton(
                          label: 'Try Again',
                          variant: WebButtonVariant.secondary,
                          onPressed: () {
                            ref
                              ..invalidate(performanceViewProvider)
                              ..invalidate(tableOrderProvider);
                          },
                        ),
                      ],
                    ),
                  )
                else
                  const WebPerformanceLoading(),
              ],
            ),
          ),
        );
      }
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
            const PerformanceSkeleton(),
        ],
      );
    }
    return PerformancePage(
      data: view,
      pro: pro,
      paused: paused,
      initialLevel: initialLevel ?? (pro ? saved.level.index : 0),
      initialSort: saved.direction == TableSortDirection.descending
          ? SortCycleOrder.strongest
          : SortCycleOrder.weakest,
      onBack: () => _back(context),
      onTopic: (id) {
        if (context.wideWeb) {
          unawaited(
            showGeneralDialog<void>(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Close topic',
              barrierColor: Colors.black.withValues(alpha: .28),
              transitionDuration: Duration.zero,
              pageBuilder: (context, animation, secondaryAnimation) => Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 480,
                  child: TopicScreen(topicId: id, inDrawer: true),
                ),
              ),
            ),
          );
        } else {
          unawaited(
            context.push('/performance/topic/${Uri.encodeComponent(id)}'),
          );
        }
      },
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
  const TopicScreen({required this.topicId, this.inDrawer = false, super.key});
  final String topicId;
  final bool inDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(currentStudyCoverageProvider)) {
      return const PerformanceScreen(initialLevel: 1);
    }
    if (context.wideWeb && !inDrawer) {
      return Stack(
        children: [
          const PerformanceScreen(initialLevel: 1),
          ModalBarrier(
            color: Colors.black.withValues(alpha: .28),
            onDismiss: () => _back(context),
            semanticsLabel: 'Close topic',
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 480,
              child: TopicScreen(topicId: topicId, inDrawer: true),
            ),
          ),
        ],
      );
    }
    final detail = ref.watch(topicDetailProvider(topicId));
    final data = detail.unwrapPrevious().asData?.value;
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
            const SkeletonGroups(rowHeight: 63),
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
