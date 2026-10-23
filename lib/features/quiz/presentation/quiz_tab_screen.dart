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
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/today_questions.dart';
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
  Future<Future<bool> Function()>? _questionGuard;
  Future<TodayQuestionWork>? _questionWork;
  TodayQuestionKind? _questionSheet;
  int _questionGeneration = 0;
  bool _startingQuestions = false;
  bool _questionFailed = false;
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
      ..invalidate(todayQuestionWorkProvider(exam.id))
      ..invalidate(roadmapTodayProvider(exam.id))
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
    ref.listen(activeExamFocusProvider, (previous, next) {
      if (previous?.unwrapPrevious().asData?.value.exam?.id !=
              next.unwrapPrevious().asData?.value.exam?.id &&
          _questionSheet != null) {
        _dismissQuestions();
      }
    });
    final page = PantasPage(
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
    final examId = focus.unwrapPrevious().asData?.value.exam?.id;
    return PantasSheet(
      page: page,
      label: _questionSheet == TodayQuestionKind.newQuestions
          ? 'New questions'
          : 'Reviews',
      open: _questionSheet != null && examId != null,
      onDismiss: _dismissQuestions,
      readerContents: true,
      scrollable: false,
      child: _questionSheet != null && examId != null
          ? _questionsSheet(examId)
          : const SizedBox.shrink(),
    );
  }

  void _dismissQuestions() {
    _questionGeneration++;
    _questionGuard = null;
    _questionWork = null;
    if (mounted) {
      setState(() {
        _questionSheet = null;
        _startingQuestions = false;
        _questionFailed = false;
      });
    }
  }

  void _showQuestions(String examId, TodayQuestionKind kind) {
    _questionGeneration++;
    _captureQuestions(examId);
    _questionWork = ref.read(todayQuestionLauncherProvider).load(
          examId,
          originalGuard: _questionGuard,
        );
    unawaited(
      _questionWork!.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
    setState(() {
      _questionSheet = kind;
      _questionFailed = false;
    });
  }

  Widget _questionsSheet(String examId) {
    final kind = _questionSheet!;
    return FutureBuilder<TodayQuestionWork>(
      future: _questionWork,
      builder: (context, snapshot) {
        final work = snapshot.connectionState != ConnectionState.done
            ? const AsyncLoading<TodayQuestionWork>()
            : snapshot.hasError
                ? AsyncError<TodayQuestionWork>(
                    snapshot.error!,
                    snapshot.stackTrace ?? StackTrace.current,
                  )
                : AsyncData(snapshot.data!);
        return work.when(
          loading: () => loadingFor(work),
          error: (error, _) => errorFor(
            'questions',
            () => setState(() {
              _questionWork = ref.read(todayQuestionLauncherProvider).load(
                    examId,
                    originalGuard: _questionGuard,
                  );
              unawaited(
                _questionWork!
                    .then<void>((_) {}, onError: (Object _, StackTrace __) {}),
              );
            }),
            error: error,
          ),
          data: (data) {
            final reviews = kind == TodayQuestionKind.reviews;
            final rows = <Widget>[];
            if (reviews) {
              for (var i = 0; i < data.reviewSizes.length; i++) {
                rows.add(
                  _sheetRow(
                    'Session ${i + 1}',
                    data.reviewProgress[i],
                    data.reviewSizes[i],
                  ),
                );
              }
            } else {
              for (final row in data.newRows) {
                rows.add(_sheetRow(row.title, row.done, row.total));
              }
            }
            return TodayQuestionsSheet(
              title: reviews ? 'Reviews' : 'New questions',
              done: reviews ? data.reviewsDone : data.newDone,
              total: reviews ? data.reviewsTotal : data.newTotal,
              rows: rows,
              startLabel: reviews ? 'Start Reviews' : 'Start New Questions',
              busy: _startingQuestions,
              onStart: (reviews
                      ? data.reviewSizes.isNotEmpty
                      : data.newQuestions.isNotEmpty)
                  ? () => unawaited(_startQuestions(examId, kind, work: data))
                  : null,
              failure: _questionFailed
                  ? StateView(
                      message: 'Could not start your quiz.',
                      onRetry: () =>
                          unawaited(_startQuestions(examId, kind, work: data)),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _sheetRow(String title, int done, int total) => ListRow(
        title: title,
        titleWidget: Text(
          title,
          style: context.type.body.copyWith(fontSize: 16, height: 1.35),
        ),
        value: '$total',
        valueStyle: context.type.subhead.copyWith(
          fontSize: 14,
          color: context.colors.secondaryLabel,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        minimumHeight: 0,
        verticalPadding: 9,
        leading: total > 0 && done == total
            ? const CheckMark()
            : ProgressRing(fraction: total == 0 ? 0 : done / total),
        variant: ListRowVariant.value,
      );

  void _captureQuestions(String examId) {
    final generation = _questionGeneration;
    _questionGuard = ref.read(todayQuestionLauncherProvider).captureGuard(
          examId,
          isAlive: () =>
              mounted &&
              generation == _questionGeneration &&
              ref
                      .read(activeExamFocusProvider)
                      .unwrapPrevious()
                      .asData
                      ?.value
                      .exam
                      ?.id ==
                  examId,
        );
  }

  Future<void> _startQuestions(
    String examId,
    TodayQuestionKind kind, {
    TodayQuestionWork? work,
  }) async {
    if (_startingQuestions) return;
    final generation = _questionGeneration;
    bool current() =>
        mounted &&
        generation == _questionGeneration &&
        ref
                .read(activeExamFocusProvider)
                .unwrapPrevious()
                .asData
                ?.value
                .exam
                ?.id ==
            examId;
    setState(() {
      _startingQuestions = true;
      _questionFailed = false;
    });
    try {
      final launcher = ref.read(todayQuestionLauncherProvider);
      if (_questionGuard == null) _captureQuestions(examId);
      final data =
          work ?? await launcher.load(examId, originalGuard: _questionGuard);
      if (!current()) return;
      await launcher.start(data, kind: kind, isAlive: current);
      if (!current()) return;
      _dismissQuestions();
      await _open('/quiz/resume/${Uri.encodeComponent(examId)}');
    } on Object {
      if (current()) setState(() => _questionFailed = true);
    } finally {
      if (current()) setState(() => _startingQuestions = false);
    }
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
              TodayQuestionRow(
                title: 'Reviews',
                subtitle: state is SessionPanelInProgress &&
                        state.reviewSession != null
                    ? 'Session ${state.reviewSession!.ordinal} '
                        'of ${state.reviewSession!.total}'
                    : 'Questions due today',
                done: state is SessionPanelInProgress &&
                        state.reviewSession != null
                    ? state.reviewSession!.done
                    : n.reviewsDone,
                total: state is SessionPanelInProgress &&
                        state.reviewSession != null
                    ? state.reviewSession!.questions
                    : n.reviewsTotal,
                fillDelay: Duration(
                  milliseconds: state is SessionPanelInProgress ? 600 : 500,
                ),
                onTap: () => _showQuestions(examId, TodayQuestionKind.reviews),
              ),
              TodayQuestionRow(
                title: 'New questions',
                divider: false,
                subtitle: "From today's lessons",
                done: n.newDone,
                total: n.newTotal,
                fillDelay: const Duration(milliseconds: 620),
                onTap: () =>
                    _showQuestions(examId, TodayQuestionKind.newQuestions),
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
                ),
              if (state is SessionPanelAvailable &&
                  (counts.unwrapPrevious().asData?.value.reviewsTotal ?? 0) >
                      (counts.unwrapPrevious().asData?.value.reviewsDone ?? 0))
                PantasButton(
                  label: 'Continue Reviews',
                  busy: _startingQuestions,
                  onPressed: () => unawaited(
                    _startQuestions(examId, TodayQuestionKind.reviews),
                  ),
                ),
              if (_questionFailed && _questionSheet == null)
                StateView(
                  message: 'Could not start your quiz.',
                  onRetry: () => unawaited(
                    _startQuestions(examId, TodayQuestionKind.reviews),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

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
