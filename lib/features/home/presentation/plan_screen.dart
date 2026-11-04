import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/plan_data.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/settling_retry.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';
import 'package:pantas/features/home/presentation/widgets/plan_skeletons.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

void _back(BuildContext context, {String fallback = '/home'}) =>
    context.canPop() ? context.pop() : context.go(fallback);

/// Leaves the plan the way it was entered, so Home slides back into place,
/// from a day or week pane as well as from the plan itself.
void _backToHome(BuildContext context) {
  final router = GoRouter.of(context);
  while (router.canPop()) {
    router.pop();
  }
  if (router.routerDelegate.currentConfiguration.uri.path != '/home') {
    router.go('/home');
  }
}

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({
    this.webPane,
    this.selectedWeek,
    this.onPaneClose,
    super.key,
  });
  final Widget? webPane;
  final String? selectedWeek;

  /// Closes the pane beside the plan. Esc on the plan closes an open pane
  /// instead of leaving the plan, also when the pane was opened directly and
  /// holds no focus (5Q-13).
  final VoidCallback? onPaneClose;
  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  int _limit = 5;
  int _displayLimit = 5;

  /// The last plan shown. A reload after a lesson closes keeps it on screen, so
  /// the page does not blank and replay its entrance behind the closing drawer.
  PlanView? _lastView;

  /// A read that fails only because the app is still settling is retried here
  /// and the page keeps its skeleton. The error shows once the failure is real.
  late final SettlingRetry _settling = SettlingRetry(
    retry: () {
      if (mounted) ref.invalidate(planViewProvider(_limit));
    },
  );
  bool _holding = false;

  @override
  void dispose() {
    _settling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = ref.watch(planViewProvider(_displayLimit));
    final value = ref.watch(planViewProvider(_limit));
    ref.listen(planViewProvider(_limit), (_, next) {
      if (next.hasError && !next.isLoading) {
        _holding = _settling.failed(next.error!);
      } else if (next.hasValue && !next.isLoading) {
        _holding = false;
        _settling.reset();
      }
    });
    final holding = value.hasError && _holding;
    final arrived = value.unwrapPrevious().asData?.value;
    final view = arrived ??
        displayed.unwrapPrevious().asData?.value ??
        (value.hasError && !holding ? null : _lastView);
    _lastView = view;
    if (arrived != null) _displayLimit = _limit;
    final pro = ref.watch(currentStudyCoverageProvider);
    if (!pro && ref.watch(studyCoverageLoadingProvider)) {
      return _waiting(context, const AsyncLoading<void>(), () {});
    }
    if (view == null) {
      firstScreenReady(context, ref, ready: value.hasError && !holding);
      return _waiting(
        context,
        holding ? const AsyncLoading<PlanView>() : value,
        () {
          _settling.reset();
          ref.invalidate(planViewProvider(_limit));
        },
      );
    }
    if (view.state == RoadmapState.needsAssessment ||
        view.state == RoadmapState.noContent ||
        view.state == RoadmapState.examPassedAwaitingAnswer) {
      final exam = ref.watch(activeExamFocusProvider).valueOrNull?.exam;
      if (exam == null) return chooseExamFallback(context);
      return HomeTodayScreen(
        examId: exam.id,
        onSetDate: () => unawaited(context.push<void>('/settings')),
        pageBuilder: (today, _) => context.wideWeb
            // The same frame as the Plan page, so the page starts at the
            // shared left edge (4N-10).
            ? PlanWebFrame(
                title: 'Your plan',
                onBack: () => _back(context),
                child: today,
              )
            : PantasPage(
                title: 'Your plan',
                backLabel: 'Home',
                onBack: () => _back(context),
                children: [today],
              ),
      );
    }
    firstScreenReady(context, ref);
    return PlanPage(
      webPane: widget.webPane,
      selectedWeek: widget.selectedWeek,
      onHistory: () => unawaited(context.push<void>('/plan/history')),
      pro: pro,
      paused: ref.watch(entitlementProvider).valueOrNull?.state ==
          EntitlementState.paused,
      done: view.done,
      total: view.total,
      nodes: view.nodes,
      history: view.history,
      initialShown: _limit,
      subtitle: view.subtitle,
      left: view.left,
      hasMore: view.next != null,
      loadingMore: _displayLimit != _limit,
      paginationError: value.hasError && !holding
          ? errorFor('plan', () => ref.invalidate(planViewProvider(_limit)))
          : null,
      onMore: () => setState(() => _limit += 10),
      onBack: () => widget.webPane != null && widget.onPaneClose != null
          ? widget.onPaneClose!()
          : _back(context),
      onToday: () => context.wideWeb ? _backToHome(context) : _back(context),
      onWeek: (start) => unawaited(context.push<void>('/plan/week/$start')),
      onPro: () => unawaited(context.push<void>('/settings/pro')),
    );
  }
}

Widget _waiting<T>(
  BuildContext context,
  AsyncValue<T> value,
  VoidCallback retry, {
  String title = 'Your plan',
  VoidCallback? onBack,
  PlanSkeletonKind kind = PlanSkeletonKind.plan,
}) {
  if (context.wideWeb) {
    return PlanWebFrame(
      title: title,
      onBack: onBack ?? () => _back(context),
      child: value.hasError
          ? WebCard(
              padding:
                  const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_outlined, size: 28),
                  const SizedBox(height: 16),
                  const Text('Could not load your plan.'),
                  const SizedBox(height: 16),
                  WebButton(
                    label: 'Try Again',
                    variant: WebButtonVariant.secondary,
                    onPressed: retry,
                  ),
                ],
              ),
            )
          : WebPlanLoading(kind: kind),
    );
  }
  return PantasPage(
    title: title,
    backLabel: 'Home',
    onBack: onBack ?? () => _back(context),
    children: [
      if (value.hasError)
        errorFor('plan', retry, boardLayout: true)
      else
        PlanSkeleton(kind: kind),
    ],
  );
}

/// The day before a plan began. The popover never opens for it, but one opened
/// while the read was slow closes itself here.
class _NoPlanDay extends StatefulWidget {
  const _NoPlanDay({required this.date, required this.popover});
  final DateTime date;
  final bool popover;

  @override
  State<_NoPlanDay> createState() => _NoPlanDayState();
}

class _NoPlanDayState extends State<_NoPlanDay> {
  @override
  void initState() {
    super.initState();
    if (widget.popover) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(Navigator.of(context).maybePop());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.popover) return const SizedBox.shrink();
    final title = DateFormat('EEEE, MMMM d', 'en_US').format(widget.date);
    const line = 'Your plan had not started on this day.';
    if (context.wideWeb) {
      return PlanWebFrame(
        title: title,
        onBack: () => _back(context),
        child: const WebCard(
          padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          child: Center(child: Text(line)),
        ),
      );
    }
    return PantasPage(
      title: title,
      backLabel: 'Home',
      onBack: () => _back(context),
      children: const [Text(line)],
    );
  }
}

class PlanDayScreen extends ConsumerStatefulWidget {
  const PlanDayScreen({
    required this.date,
    this.backLabel = 'Home',
    this.popover = false,
    this.onReadEarly,
    super.key,
  });
  final String date;
  final String backLabel;
  final bool popover;
  final Future<void> Function(BuildContext, String, String, LessonDayContext)?
      onReadEarly;
  @override
  ConsumerState<PlanDayScreen> createState() => _PlanDayScreenState();
}

class _PlanDayScreenState extends ConsumerState<PlanDayScreen> {
  PlanDayView? _opened;

  /// The last day shown, kept through a reload as [_PlanScreenState] does.
  PlanDayView? _lastView;
  Future<Future<bool> Function()>? _guard;
  String? _guardExamId;

  /// Retrying recaptures the current owner, so the screen recovers after a
  /// real context change. A check that was already handed out keeps its
  /// original owner and still fails for a stale one.
  void _retryOwner() {
    setState(() => _guard = null);
    ref.invalidate(planDayViewProvider(widget.date));
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    final value = ref.watch(planDayViewProvider(date));
    firstScreenReady(context, ref, ready: value.hasError);
    final held = _lastView;
    final view = value.unwrapPrevious().asData?.value ??
        (held != null && !value.hasError && dayKey(held.date) == date
            ? held
            : null);
    _lastView = view;
    if (view == null) {
      // The popover is a small card: a page heading there flashes as a ghost.
      if (widget.popover && !value.hasError) {
        return const WebPlanLoading(kind: PlanSkeletonKind.day);
      }
      // The list stays while only the pane is loading.
      if (context.wideWeb && !value.hasError) {
        final day = DateTime.parse(date);
        return PlanScreen(
          webPane: const WebPlanLoading(kind: PlanSkeletonKind.day),
          selectedWeek: dayKey(
            DateTime(day.year, day.month, day.day - day.weekday % 7),
          ),
        );
      }
      return _waiting(
        context,
        value,
        () => ref.invalidate(planDayViewProvider(date)),
        onBack: widget.popover ? () => Navigator.of(context).pop() : null,
        kind: PlanSkeletonKind.day,
      );
    }
    if (view.kind == 'locked') return const PlanScreen();
    if (view.kind == 'unknown' || view.plan == null) {
      firstScreenReady(context, ref);
      // A student who started mid-week has no plan for the days before the
      // start. That is not a failure, so it never shows the retry state.
      if (view.kind == 'unknown' &&
          !DateTime.parse(date).isAfter(DateTime.now())) {
        return _NoPlanDay(date: view.date, popover: widget.popover);
      }
      return _waiting(
        context,
        const AsyncError<void>('Unknown stored day', StackTrace.empty),
        () => ref.invalidate(planDayViewProvider(date)),
        onBack: widget.popover ? () => Navigator.of(context).pop() : null,
      );
    }
    final examId = ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
    if (examId == null) return chooseExamFallback(context);
    if (_guardExamId != examId) _guard = null;
    _guardExamId = examId;
    _guard ??= ref
        .read(todayQuestionLauncherProvider)
        .captureGuard(examId, isAlive: () => mounted);
    if (view.kind == 'future') _opened ??= view;
    final shown = _opened == null ? view : retainOpenedPlanDay(_opened!, view);
    return FutureBuilder<bool>(
      future: _guard!.then((check) => check()),
      builder: (context, owner) {
        firstScreenReady(
          context,
          ref,
          ready: owner.connectionState == ConnectionState.done &&
              (owner.data != true || shown.kind != 'today'),
        );
        if (owner.data != true) {
          if (widget.popover && owner.connectionState != ConnectionState.done) {
            return const WebPlanLoading(kind: PlanSkeletonKind.day);
          }
          return _waiting(
            context,
            owner.connectionState == ConnectionState.done
                ? const AsyncError<void>('Plan owner changed', StackTrace.empty)
                : const AsyncLoading<void>(),
            _retryOwner,
            onBack: widget.popover ? () => Navigator.of(context).pop() : null,
          );
        }
        return _day(context, shown, examId);
      },
    );
  }

  Widget _day(BuildContext context, PlanDayView view, String examId) {
    final date = widget.date;
    if (view.kind == 'today') {
      return HomeTodayScreen(
        examId: examId,
        noteTopGap: 0,
        pageBuilder: (today, data) => context.wideWeb
            ? PlanWebFrame(
                title: 'Today',
                backLabel: widget.backLabel,
                onBack: () => _back(context),
                child: today,
              )
            : PantasPage(
                title: 'Today',
                backLabel: widget.backLabel,
                onBack: () => _back(context),
                // The day's note sits under the title as the Plan page's
                // subtitle does, 2 px below it (4N-14).
                titlePadding: EdgeInsets.fromLTRB(
                  4,
                  0,
                  4,
                  data != null && homeDayNoteLabel(data) != null ? 2 : 20,
                ),
                children: [today],
              ),
      );
    }
    final plan = view.plan!;
    final remaining = view.remaining;
    final page = PlanDayPage(
      date: view.date,
      backLabel: widget.backLabel,
      past: view.kind == 'past',
      rest: plan.isRestDay,
      lessons: view.lessons,
      reviewsDone: plan.reviewQuestionIds.length -
          (remaining?.reviewQuestionIds.length ??
              plan.reviewQuestionIds.length),
      reviewsTotal: plan.reviewQuestionIds.length,
      newDone: plan.newQuestionIds.length -
          (remaining?.newQuestionIds.length ?? plan.newQuestionIds.length),
      newTotal: plan.newQuestionIds.length,
      // A day opened directly has no page behind it. Its parent is the plan.
      onBack: () => widget.popover
          ? Navigator.of(context).pop()
          : _back(context, fallback: context.wideWeb ? '/plan' : '/home'),
      onLesson: (lesson) async {
        if (!await (await _guard!)() || !mounted || !context.mounted) return;
        final dayContext = LessonDayContext(
          date: view.date,
          lessonIds: plan.lessonIds,
          index: plan.lessonIds.indexOf(lesson.id),
        );
        if (context.wideWeb && widget.onReadEarly != null) {
          await widget.onReadEarly!(
            context,
            lesson.id,
            '${DateFormat('EEEE', 'en_US').format(view.date)} · '
            '${lesson.subject}',
            dayContext,
          );
        } else {
          await context.push<void>(
            '/lesson/${Uri.encodeComponent(lesson.id)}?from=home',
            extra: LessonDayContext(
              date: view.date,
              lessonIds: plan.lessonIds,
              index: plan.lessonIds.indexOf(lesson.id),
            ),
          );
        }
        if (mounted) ref.invalidate(planDayViewProvider(date));
      },
    );
    if (context.wideWeb && !widget.popover) {
      return PlanScreen(
        onPaneClose: () => _back(context, fallback: '/plan'),
        webPane: page,
        selectedWeek: dayKey(
          DateTime(
            view.date.year,
            view.date.month,
            view.date.day - view.date.weekday % 7,
          ),
        ),
      );
    }
    return page;
  }
}

final planWeekViewProvider = FutureProvider.autoDispose
    .family<List<PlanDayView>, String>((ref, start) async {
  // One server read for the week; seven day reads took three seconds or more.
  if (ref.watch(studyUsesServerProvider)) {
    return ref.watch(planServerWeekProvider(start).future);
  }
  final day = DateTime.parse(start);
  return Future.wait([
    for (var i = 0; i < 7; i++)
      ref.watch(
        planDayViewProvider(
          dayKey(DateTime(day.year, day.month, day.day + i)),
        ).future,
      ),
  ]);
});

class PlanWeekScreen extends ConsumerWidget {
  const PlanWeekScreen({required this.start, super.key});
  final String start;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pro = ref.watch(currentStudyCoverageProvider);
    if (!pro && ref.watch(studyCoverageLoadingProvider)) {
      return _waiting(context, const AsyncLoading<void>(), () {});
    }
    if (!pro) return const PlanScreen();
    final value = ref.watch(planWeekViewProvider(start));
    firstScreenReady(context, ref, ready: value.hasError);
    final days = value.unwrapPrevious().asData?.value;
    if (days == null) {
      // The list stays while only the pane is loading.
      if (context.wideWeb && !value.hasError) {
        return PlanScreen(
          webPane: const WebPlanLoading(kind: PlanSkeletonKind.week),
          selectedWeek: start,
        );
      }
      return _waiting(
        context,
        value,
        () => ref.invalidate(planWeekViewProvider(start)),
        kind: PlanSkeletonKind.week,
      );
    }
    if (days.any((day) => day.kind == 'locked')) return const PlanScreen();
    firstScreenReady(context, ref);
    // A student who started mid-week has no plan for the days before the start.
    final planned = days.where((day) => day.plan != null).toList();
    if (days.length != 7 || planned.isEmpty) {
      return _waiting(
        context,
        const AsyncError<void>('Unknown stored week', StackTrace.empty),
        () => ref.invalidate(planWeekViewProvider(start)),
      );
    }
    final studyDays = ref.watch(userSettingsProvider).valueOrNull?.studyDays;
    final page = PlanWeekPage(
      title: planWeekTitle(localDay(DateTime.parse(start))),
      days: [
        for (final d in planned)
          PlanWeekDay(
            date: d.date,
            rest: d.plan?.isRestDay ?? false,
            lessonTitles: d.lessons.map((l) => l.title).toList(),
            mock: d.plan?.isMockDay ?? false,
          ),
      ],
      studyDaysLabel:
          studyDays == null ? '' : planStudyDaysLabel(studyDays.weekdays),
      // A week opened directly has no page behind it, and its parent is the
      // plan, not Home (5Q-13).
      onBack: () => _back(context, fallback: '/plan'),
      onChange: context.wideWeb
          ? () => unawaited(context.push<void>('/settings/exam'))
          : null,
      onDay: (day) => unawaited(
        context.push<void>(
          '/plan/day/${dayKey(day)}',
          extra: planWeekTitle(localDay(DateTime.parse(start))),
        ),
      ),
    );
    if (context.wideWeb) {
      return PlanScreen(
        webPane: page,
        selectedWeek: start,
        onPaneClose: () => _back(context, fallback: '/plan'),
      );
    }
    return page;
  }
}

class PlanHistoryScreen extends ConsumerStatefulWidget {
  const PlanHistoryScreen({this.onBack, super.key});
  final VoidCallback? onBack;
  @override
  ConsumerState<PlanHistoryScreen> createState() => _PlanHistoryScreenState();
}

class _PlanHistoryScreenState extends ConsumerState<PlanHistoryScreen> {
  int _limit = 15;
  int _displayLimit = 15;
  @override
  Widget build(BuildContext context) {
    final displayed = ref.watch(planViewProvider(_displayLimit));
    final value = ref.watch(planViewProvider(_limit));
    final arrived = value.unwrapPrevious().asData?.value;
    final view = arrived ?? displayed.unwrapPrevious().asData?.value;
    if (arrived != null) _displayLimit = _limit;
    if (!ref.watch(currentStudyCoverageProvider)) return const PlanScreen();
    firstScreenReady(context, ref, ready: !value.isLoading);
    if (view == null) {
      return _waiting(
        context,
        value,
        () => ref.invalidate(planViewProvider(_limit)),
        title: 'History',
        kind: PlanSkeletonKind.history,
      );
    }
    final error = value.hasError
        ? errorFor('plan', () => ref.invalidate(planViewProvider(_limit)))
        : null;
    if (!context.wideWeb) {
      return PlanHistoryPage(
        history: view.history,
        hasMore: view.next != null,
        loadingMore: value.isLoading,
        onMore: () => setState(() => _limit += 10),
        paginationError: error,
        onBack: widget.onBack ?? () => _back(context),
      );
    }
    return PlanWebFrame(
      title: 'History',
      backLabel: 'Your plan',
      subtitle: 'Every time your plan adjusted, and why.',
      onBack: widget.onBack ?? () => _back(context),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: PlanWebHistory(
            entries: view.history,
            hasMore: view.next != null,
            loading: value.isLoading,
            onMore: () => setState(() => _limit += 10),
            error: error,
          ),
        ),
      ),
    );
  }
}

/// Reads the day first, for at most [_popoverWait], so the popover's fade plays
/// on the day and not on an empty card that pops full a moment later.
Future<void> showPlanPastDay(BuildContext context, DateTime date) async {
  final container = ProviderScope.containerOf(context);
  final hold = container.listen(
    planDayViewProvider(dayKey(date)),
    (_, __) {},
  );
  PlanDayView? view;
  try {
    view = await container
        .read(planDayViewProvider(dayKey(date)).future)
        .timeout(_popoverWait);
  } on Object catch (_) {
    // A slow or failed read shows its own state inside the popover.
  }
  // A day before the plan began has nothing to show, so the strip offers no
  // card for it, as the week page lists no row for it.
  if (!context.mounted || view?.kind == 'unknown') {
    hold.close();
    return;
  }
  await _openPlanPastDay(context, date);
  hold.close();
}

const _popoverWait = Duration(milliseconds: 120);

Future<void> _openPlanPastDay(BuildContext context, DateTime date) =>
    showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.popover,
      barrierLabel: 'Close day',
      barrierColor: Colors.transparent,
      builder: (dialogContext) => SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 128, right: 150),
            child: SizedBox(
              width: 400,
              child: Material(
                color: Colors.transparent,
                child: PlanDayScreen(date: dayKey(date), popover: true),
              ),
            ),
          ),
        ),
      ),
    );
