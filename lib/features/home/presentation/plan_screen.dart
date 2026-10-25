import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/features/home/application/plan_data.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/home');

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});
  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  int _limit = 5;
  int _displayLimit = 5;
  @override
  Widget build(BuildContext context) {
    final displayed = ref.watch(planViewProvider(_displayLimit));
    final value = ref.watch(planViewProvider(_limit));
    final arrived = value.unwrapPrevious().asData?.value;
    final view = arrived ?? displayed.unwrapPrevious().asData?.value;
    if (arrived != null) _displayLimit = _limit;
    final pro = ref.watch(currentStudyCoverageProvider);
    if (!pro && ref.watch(studyCoverageLoadingProvider)) {
      return _waiting(context, const AsyncLoading<void>(), () {});
    }
    if (view == null) {
      return _waiting(
        context,
        value,
        () => ref.invalidate(planViewProvider(_limit)),
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
        pageBuilder: (today, _) => PantasPage(
          title: 'Your plan',
          backLabel: 'Home',
          onBack: () => _back(context),
          children: [today],
        ),
      );
    }
    return PlanPage(
      pro: pro,
      paused: ref.watch(entitlementProvider).valueOrNull?.state ==
          EntitlementState.paused,
      done: view.done,
      total: view.total,
      nodes: view.nodes,
      history: view.history,
      initialShown: _limit,
      subtitle: view.subtitle,
      hasMore: view.next != null,
      loadingMore: _displayLimit != _limit,
      paginationError: value.hasError
          ? errorFor('plan', () => ref.invalidate(planViewProvider(_limit)))
          : null,
      onMore: () => setState(() => _limit += 10),
      onBack: () => _back(context),
      onToday: () {},
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
}) =>
    PantasPage(
      title: title,
      backLabel: 'Home',
      onBack: () => _back(context),
      children: [
        if (value.hasError)
          errorFor('plan', retry, boardLayout: true)
        else
          loadingFor(value),
      ],
    );

class PlanDayScreen extends ConsumerStatefulWidget {
  const PlanDayScreen({
    required this.date,
    this.backLabel = 'Home',
    super.key,
  });
  final String date;
  final String backLabel;
  @override
  ConsumerState<PlanDayScreen> createState() => _PlanDayScreenState();
}

class _PlanDayScreenState extends ConsumerState<PlanDayScreen> {
  PlanDayView? _opened;
  Future<Future<bool> Function()>? _guard;
  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    final value = ref.watch(planDayViewProvider(date));
    final view = value.unwrapPrevious().asData?.value;
    if (view == null) {
      return _waiting(
        context,
        value,
        () => ref.invalidate(planDayViewProvider(date)),
      );
    }
    if (view.kind == 'locked') return const PlanScreen();
    if (view.kind == 'unknown' || view.plan == null) {
      return _waiting(
        context,
        const AsyncError<void>('Unknown stored day', StackTrace.empty),
        () => ref.invalidate(planDayViewProvider(date)),
      );
    }
    final examId = ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id;
    if (examId == null) return chooseExamFallback(context);
    _guard ??= ref
        .read(todayQuestionLauncherProvider)
        .captureGuard(examId, isAlive: () => mounted);
    if (view.kind == 'future') _opened ??= view;
    final shown = _opened == null ? view : retainOpenedPlanDay(_opened!, view);
    return FutureBuilder<bool>(
      future: _guard!.then((check) => check()),
      builder: (context, owner) {
        if (owner.data != true) {
          return _waiting(
            context,
            owner.connectionState == ConnectionState.done
                ? const AsyncError<void>('Plan owner changed', StackTrace.empty)
                : const AsyncLoading<void>(),
            () => ref.invalidate(planDayViewProvider(date)),
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
        pageBuilder: (today, _) => PantasPage(
          title: 'Today',
          backLabel: widget.backLabel,
          onBack: () => _back(context),
          children: [today],
        ),
      );
    }
    final plan = view.plan!;
    final remaining = view.remaining;
    return PlanDayPage(
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
      onBack: () => _back(context),
      onLesson: (lesson) async {
        if (!await (await _guard!)() || !mounted || !context.mounted) return;
        await context.push<void>(
          '/lesson/${Uri.encodeComponent(lesson.id)}?from=home',
          extra: LessonDayContext(
            date: view.date,
            lessonIds: plan.lessonIds,
            index: plan.lessonIds.indexOf(lesson.id),
          ),
        );
        if (mounted) ref.invalidate(planDayViewProvider(date));
      },
    );
  }
}

final planWeekViewProvider = FutureProvider.autoDispose
    .family<List<PlanDayView>, String>((ref, start) async {
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
    final days = value.unwrapPrevious().asData?.value;
    if (days == null) {
      return _waiting(
        context,
        value,
        () => ref.invalidate(planWeekViewProvider(start)),
      );
    }
    if (days.any((day) => day.kind == 'locked')) return const PlanScreen();
    if (days.length != 7 || days.any((day) => day.plan == null)) {
      return _waiting(
        context,
        const AsyncError<void>('Unknown stored week', StackTrace.empty),
        () => ref.invalidate(planWeekViewProvider(start)),
      );
    }
    final studyDays = ref.watch(userSettingsProvider).valueOrNull?.studyDays;
    return PlanWeekPage(
      title: planWeekTitle(localDay(DateTime.parse(start))),
      days: [
        for (final d in days)
          PlanWeekDay(
            date: d.date,
            rest: d.plan?.isRestDay ?? false,
            lessonTitles: d.lessons.map((l) => l.title).toList(),
          ),
      ],
      studyDaysLabel:
          studyDays == null ? '' : planStudyDaysLabel(studyDays.weekdays),
      onBack: () => _back(context),
      onDay: (day) => unawaited(
        context.push<void>(
          '/plan/day/${dayKey(day)}',
          extra: planWeekTitle(localDay(DateTime.parse(start))),
        ),
      ),
    );
  }
}
