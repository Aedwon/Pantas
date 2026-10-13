import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/practice_row_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

class QuizTodayCounts {
  const QuizTodayCounts({
    required this.reviewsDone,
    required this.reviewsTotal,
    required this.newDone,
    required this.newTotal,
  });
  final int reviewsDone;
  final int reviewsTotal;
  final int newDone;
  final int newTotal;
}

final quizTodayCountsProvider = FutureProvider.autoDispose
    .family<QuizTodayCounts, ExamId>((ref, examId) async {
  final today = await ref.watch(roadmapTodayProvider(examId).future);
  final plan = today.snapshot.plan;
  return QuizTodayCounts(
    reviewsTotal: plan.reviewQuestionIds.length,
    reviewsDone: plan.reviewQuestionIds.length -
        today.remaining.reviewQuestionIds.length,
    newTotal: plan.newQuestionIds.length,
    newDone: plan.newQuestionIds.length - today.remaining.newQuestionIds.length,
  );
});

final quizPracticeCountsProvider = FutureProvider.autoDispose
    .family<({int mistakes, int flags}), ExamId>((ref, examId) async {
  final mistakes = await ref.watch(recentMistakeCountProvider(examId).future);
  final flags = await ref.watch(questionFlagsRepositoryProvider).flaggedIds();
  final topicIds = (await ref.watch(scopedTopicsProvider(examId).future))
      .map((topic) => topic.id)
      .toSet();
  final questions =
      await ref.watch(contentRepositoryProvider).questionsByIds(flags);
  return (
    mistakes: mistakes,
    flags: questions.values.where((q) => topicIds.contains(q.topicId)).length
  );
});

class QuizTabScreen extends ConsumerStatefulWidget {
  const QuizTabScreen({this.mockPanel, super.key});
  final Widget? mockPanel;
  @override
  ConsumerState<QuizTabScreen> createState() => _QuizTabScreenState();
}

class _QuizTabScreenState extends ConsumerState<QuizTabScreen>
    with WidgetsBindingObserver {
  bool _discarding = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    final exam = ref.read(activeExamFocusProvider).valueOrNull?.exam;
    if (exam == null) return;
    ref
      ..invalidate(sessionPanelProvider(exam.id))
      ..invalidate(quizTodayCountsProvider(exam.id))
      ..invalidate(quizPracticeCountsProvider(exam.id));
  }

  Future<void> _open(String route, {Object? extra}) async {
    await context.push<void>(route, extra: extra);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final focus = ref.watch(activeExamFocusProvider);
    return PantasPage(
      title: 'Quiz',
      bottomInset: 104,
      children: [
        focus.when(
          loading: () => loadingFor(focus),
          error: (error, _) => errorFor(
            'practice',
            () => ref.invalidate(activeExamFocusProvider),
            error: error,
          ),
          data: (value) {
            final exam = value.exam;
            if (exam == null) return chooseExamFallback(context);
            final session = ref.watch(sessionPanelProvider(exam.id));
            final counts = ref.watch(quizPracticeCountsProvider(exam.id));
            final paused = session.valueOrNull is SessionPanelInProgress;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _entry(
                  100,
                  session.when(
                    loading: () => loadingFor(session),
                    error: (error, _) => errorFor(
                      'practice',
                      () => ref.invalidate(sessionPanelProvider(exam.id)),
                      error: error,
                    ),
                    data: (state) => _today(exam.id, state),
                  ),
                ),
                if (widget.mockPanel != null) ...[
                  const SizedBox(height: 24),
                  _entry(190, widget.mockPanel!),
                ],
                const SizedBox(height: 24),
                _entry(
                  280,
                  counts.when(
                    loading: () => loadingFor(counts),
                    error: (error, _) => errorFor(
                      'questions',
                      () => ref.invalidate(quizPracticeCountsProvider(exam.id)),
                      error: error,
                    ),
                    data: (counts) => GroupedSection(
                      header: 'More ways to practice',
                      children: [
                        _practiceRow(
                          'Your past mistakes',
                          counts.mistakes,
                          icon: PantasIcons.close,
                          empty: 'Nothing to fix yet',
                          onTap: () =>
                              unawaited(_open('/quiz/retake/${exam.id}')),
                        ),
                        Opacity(
                          opacity: paused ? .45 : 1,
                          child: ListRow(
                            title: 'Customize your own',
                            variant: paused
                                ? ListRowVariant.value
                                : ListRowVariant.navigation,
                            icon: PantasIcons.practice,
                            iconColor:
                                paused ? context.colors.secondaryLabel : null,
                            subtitle: paused
                                ? 'Finish or discard your '
                                    'paused quiz first'
                                : null,
                            onTap: paused
                                ? null
                                : () => unawaited(
                                      _open('/quiz/practice/${exam.id}'),
                                    ),
                            divider: true,
                          ),
                        ),
                        _practiceRow(
                          'Flagged questions',
                          counts.flags,
                          icon: PantasIcons.flag,
                          empty: 'Flag a question to come back to it',
                          onTap: () =>
                              unawaited(_open('/quiz/flagged/${exam.id}')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _entry(int delay, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: delay + 450),
      curve: Interval(delay / (delay + 450), 1, curve: PantasCurves.houseOut),
      child: child,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
    );
  }

  Widget _practiceRow(
    String title,
    int count, {
    required IconData icon,
    required String empty,
    required VoidCallback onTap,
  }) =>
      Opacity(
        opacity: count == 0 ? .45 : 1,
        child: ListRow(
          title: title,
          icon: icon,
          variant:
              count == 0 ? ListRowVariant.value : ListRowVariant.navigation,
          iconColor: count == 0 ? context.colors.secondaryLabel : null,
          value: count == 0 ? null : '$count',
          subtitle: count == 0 ? empty : null,
          onTap: count == 0 ? null : onTap,
          divider: title == 'Your past mistakes',
        ),
      );

  Widget _today(String examId, SessionPanelState state) {
    if (state is SessionPanelNeedsAssessment) {
      if (state.questionCount == 0) return assessmentNotReady();
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'First, a short assessment',
                style: context.type.emphasized.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.264,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We check your strengths and weak spots first, '
                'so your plan is built around you.',
                style: context.type.subhead.copyWith(
                  color: context.colors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              PantasButton(
                label: 'Start Assessment',
                onPressed: () => unawaited(_open('/assessment/$examId')),
              ),
            ],
          ),
        ),
      );
    }
    final counts = ref.watch(quizTodayCountsProvider(examId));
    return GroupedSection(
      header: 'Today',
      children: [
        counts.when(
          loading: () => loadingFor(counts),
          error: (error, _) => errorFor(
            'questions',
            () => ref.invalidate(quizTodayCountsProvider(examId)),
            error: error,
          ),
          data: (n) => Column(
            children: [
              _todayRow(
                'Reviews',
                'Questions due today',
                state is SessionPanelInProgress
                    ? state.position
                    : n.reviewsDone,
                state is SessionPanelInProgress ? state.total : n.reviewsTotal,
                paused: state is SessionPanelInProgress,
              ),
              _todayRow(
                'New questions',
                "From today's lessons",
                n.newDone,
                n.newTotal,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state is SessionPanelInProgress) ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'You paused. Every answer was saved.',
                    style: context.type.subhead
                        .copyWith(color: context.colors.secondaryLabel),
                  ),
                ),
                const SizedBox(height: 14),
                PantasButton(
                  label: 'Resume',
                  onPressed: () => unawaited(_open('/quiz/resume/$examId')),
                ),
                TextButton(
                  onPressed:
                      _discarding ? null : () => unawaited(_discard(examId)),
                  child: Text(
                    'Discard this session',
                    style: context.type.subheadStrong
                        .copyWith(color: context.colors.accent),
                  ),
                ),
                if (_saveFailed)
                  saveFailureLine(() => unawaited(_discard(examId))),
              ] else if (state is SessionPanelCaughtUp)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    "That's all for today.",
                    style: context.type.subhead
                        .copyWith(color: context.colors.secondaryLabel),
                  ),
                )
              else if (state is SessionPanelAvailable)
                PantasButton(
                  label: state.plan.dueCount > 0
                      ? 'Continue Reviews'
                      : 'Start New Questions',
                  onPressed: () => unawaited(
                    _open('/quiz/today/$examId', extra: state.prepared),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _todayRow(
    String label,
    String detail,
    int done,
    int total, {
    bool paused = false,
  }) =>
      ListRow(
        title: label, subtitle: detail, value: '$done of $total',
        valueStyle: context.type.subhead.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colors.secondaryLabel,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        titleColor:
            total > 0 && done == total ? context.colors.secondaryLabel : null,
        // W4b owns the shared Today sheets. Add the controls
        // after that contract lands.
        variant: ListRowVariant.value,
        leading: total > 0 && done == total
            ? const CheckMark()
            : ProgressRing(
                fraction: total == 0 ? 0 : done / total,
                fillDuration: const Duration(milliseconds: 700),
                fillDelay: Duration(
                  milliseconds: label == 'Reviews' ? (paused ? 600 : 500) : 620,
                ),
              ),
        divider: true,
      );

  Future<void> _discard(String examId) async {
    if (_discarding) return;
    setState(() {
      _discarding = true;
      _saveFailed = false;
    });
    try {
      await ref.read(quitSessionProvider)(
        userId: todayUserId,
        examId: examId,
        now: ref.read(nowProvider)(),
      );
      if (mounted) _refresh();
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _discarding = false);
    }
  }
}
