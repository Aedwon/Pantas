import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
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
  const PerformanceScreen({
    this.initialLevel,
    this.reportReady = true,
    this.openTopicId,
    super.key,
  });
  final bool reportReady;
  final int? initialLevel;

  /// The topic whose panel the page opened over it (an address opened on wide
  /// web), so its row stays tinted behind the panel.
  final String? openTopicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(performanceViewProvider);
    final order = ref.watch(tableOrderProvider);
    firstScreenReady(
      context,
      ref,
      ready: reportReady &&
          (data.hasError ||
              order.hasError ||
              (!data.isLoading && !order.isLoading)),
    );
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
            padding: EdgeInsets.only(bottom: context.webPageBottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WebPerformanceHeader(
                  onBack: () => _back(context),
                  description: false,
                ),
                const SizedBox(height: PantasSpace.s28),
                if (failed)
                  WebCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s24,
                      vertical: PantasSpace.s56,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 28,
                          color: context.webTokens.colors.textSecondary,
                        ),
                        const SizedBox(height: PantasSpace.s12),
                        Text(
                          'Could not load your performance.',
                          style: context.webTokens.style(
                            17,
                            color: context.webTokens.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s12),
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
      openTopicId: openTopicId,
      onTopic: (id) {
        if (context.wideWeb) {
          return showWebOverlay<void>(
            context: context,
            motion: WebOverlayMotion.drawerOf(PantasLayout.drawer),
            barrierLabel: 'Close topic',
            barrierColor: context.colors.scrim,
            builder: (context) => Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: PantasLayout.drawer,
                child: TopicScreen(topicId: id, inDrawer: true),
              ),
            ),
          );
        }
        unawaited(
          context.push('/performance/topic/${Uri.encodeComponent(id)}'),
        );
        return null;
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
  const TopicScreen({
    required this.topicId,
    this.inDrawer = false,
    this.exit,
    super.key,
  });
  final String topicId;
  final bool inDrawer;

  /// Set when the drawer is this route's own page: leaving plays its exit
  /// first.
  final WebOverlayExit? exit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(currentStudyCoverageProvider)) {
      return PerformanceScreen(
        initialLevel: 1,
        reportReady: !ref.watch(studyCoverageLoadingProvider),
      );
    }
    if (context.wideWeb && !inDrawer) return _TopicDrawerPage(topicId: topicId);
    void leave() {
      final exit = this.exit;
      if (exit == null) {
        _back(context);
      } else {
        exit.close(() => _back(context));
      }
    }

    final detail = ref.watch(topicDetailProvider(topicId));
    firstScreenReady(context, ref, ready: !detail.isLoading);
    final data = detail.unwrapPrevious().asData?.value;
    if (data == null) {
      return PantasPage(
        title: 'Topic',
        backLabel: 'Your performance',
        onBack: leave,
        children: [
          if (detail.error is TopicNotFound)
            // A topic the exam does not have: Try Again cannot help, so the
            // page says so and leaves the back link as the way out.
            const StateView(message: 'We could not find that topic.')
          else if (detail.hasError)
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
      onBack: leave,
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

/// A topic opened by address on wide web: the drawer over Performance is the
/// route's own page, so it plays its exit before the route pops. Back does too,
/// except at the start of the stack, where it still leaves the app.
class _TopicDrawerPage extends StatefulWidget {
  const _TopicDrawerPage({required this.topicId});
  final String topicId;

  @override
  State<_TopicDrawerPage> createState() => _TopicDrawerPageState();
}

class _TopicDrawerPageState extends State<_TopicDrawerPage> {
  final _exit = WebOverlayExit();

  @override
  Widget build(BuildContext context) => PopScope<void>(
        canPop: !(GoRouter.maybeOf(context)?.canPop() ?? false),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _exit.close(() => _back(context));
        },
        child: Stack(
          children: [
            // The page behind is covered, so Esc and focus belong to the
            // drawer, which plays its exit before leaving.
            ExcludeFocus(
              child: PerformanceScreen(
                initialLevel: 1,
                reportReady: false,
                openTopicId: widget.topicId,
              ),
            ),
            Positioned.fill(
              child: WebOverlayLayer(
                motion: WebOverlayMotion.drawerOf(PantasLayout.drawer),
                barrierLabel: 'Close topic',
                onDismiss: () => _exit.close(() => _back(context)),
                exit: _exit,
                child: SizedBox(
                  width: PantasLayout.drawer,
                  child: TopicScreen(
                    topicId: widget.topicId,
                    inDrawer: true,
                    exit: _exit,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
