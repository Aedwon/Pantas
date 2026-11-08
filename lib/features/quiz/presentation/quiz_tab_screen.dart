import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/paused_quiz_notice.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_side_overlay.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/quiz/domain/paused_quiz_conflict.dart';
import 'package:pantas/features/quiz/presentation/practice_row_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/widgets/quiz_skeletons.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

export 'package:pantas/features/quiz/presentation/practice_row_providers.dart'
    show quizPracticeCountsProvider;

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

class QuizTabScreen extends ConsumerStatefulWidget {
  const QuizTabScreen({this.mockPanel, this.mockReady = true, super.key});
  final bool mockReady;
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

  /// The failed start was refused because another quiz is paused.
  bool _questionPaused = false;
  bool _discarding = false;
  bool _saveFailed = false;
  final _leftKey = GlobalKey();
  final _mockKey = GlobalKey();

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
    final firstExamId = focus.valueOrNull?.exam?.id;
    var settled = !focus.isLoading;
    if (firstExamId != null) {
      final session = ref.watch(sessionPanelProvider(firstExamId));
      final counts = ref.watch(quizPracticeCountsProvider(firstExamId));
      final today = ref.watch(quizTodayCountsProvider(firstExamId));
      settled = settled &&
          !session.isLoading &&
          !counts.isLoading &&
          !today.isLoading;
    }
    firstScreenReady(
      context,
      ref,
      ready: settled && widget.mockReady,
      path: '/quiz',
    );
    ref.listen(activeExamFocusProvider, (previous, next) {
      if (previous?.unwrapPrevious().asData?.value.exam?.id !=
              next.unwrapPrevious().asData?.value.exam?.id &&
          _questionSheet != null) {
        _dismissQuestions();
      }
    });
    final page = context.wideWeb
        ? _web(focus)
        : PantasPage(
            title: 'Quiz',
            bottomInset: PantasLayout.reserveTabbar,
            // Board QZ_Tab: the title box starts at y 50 and the Today label
            // 14 px below it.
            titlePadding: const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s44,
              PantasSpace.s4,
              PantasSpace.s14,
            ),
            children: [
              focus.when(
                loading: () => const QuizPageSkeleton(),
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
                          loading: () => const QuizTodaySkeleton(),
                          error: (error, _) => errorFor(
                            'practice',
                            () => ref.invalidate(sessionPanelProvider(exam.id)),
                            error: error,
                          ),
                          data: (state) => _today(exam.id, state),
                        ),
                      ),
                      if (widget.mockPanel != null) ...[
                        const SizedBox(height: PantasSpace.s24),
                        _entry(190, widget.mockPanel!),
                      ],
                      const SizedBox(height: PantasSpace.s24),
                      _entry(
                        280,
                        counts.when(
                          loading: () => const QuizMoreSkeleton(),
                          error: (error, _) => errorFor(
                            'questions',
                            () => ref.invalidate(
                              quizPracticeCountsProvider(exam.id),
                            ),
                            error: error,
                          ),
                          data: (counts) => GroupedSection(
                            header: 'More ways to practice',
                            children: [
                              _practiceRow(
                                'Your past mistakes',
                                counts.mistakes,
                                glyph: _WebGlyphKind.mistakes,
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
                                  // Board (QZ_Tab): the sliders glyph.
                                  leading: _phoneGlyph(
                                    _WebGlyphKind.customize,
                                    paused
                                        ? context.colors.textSecondary
                                        : context.colors.accent,
                                  ),
                                  leadingGap: 14,
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
                                glyph: _WebGlyphKind.flagged,
                                empty: 'Flag a question to come back to it',
                                onTap: () => unawaited(
                                  _open('/quiz/flagged/${exam.id}'),
                                ),
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
    final label = _questionSheet == TodayQuestionKind.newQuestions
        ? 'New questions'
        : 'Reviews';
    // Wide web opens the same right drawer as Home, over the sidebar too
    // (7W-8). The phone keeps its sheet.
    if (context.wideWeb) {
      return HomeWebOverlay(
        page: page,
        label: label,
        open: _questionSheet != null && examId != null,
        drawer: true,
        onDismiss: _dismissQuestions,
        child: _questionSheet != null && examId != null
            ? _questionsSheet(examId)
            : const SizedBox.shrink(),
      );
    }
    return PantasSheet(
      page: page,
      label: label,
      open: _questionSheet != null && examId != null,
      onDismiss: _dismissQuestions,
      readerContents: true,
      scrollable: false,
      child: _questionSheet != null && examId != null
          ? _questionsSheet(examId)
          : const SizedBox.shrink(),
    );
  }

  Widget _web(AsyncValue<ActiveExamFocus> focus) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: context.webPageBottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WebText('Quiz', kind: WebTextKind.h1),
          const SizedBox(height: PantasSpace.s24),
          focus.when(
            loading: () => const QuizPageSkeleton(),
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
              // The phone's delays: Today 100, mock card 190, practice 280.
              // The keys keep the entrances from replaying when a resize
              // moves the blocks between the stacked and side-by-side layouts.
              final left = Column(
                key: _leftKey,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _entry(
                    100,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WebText('Today', kind: WebTextKind.eyebrow),
                        session.when(
                          loading: () => const QuizTodaySkeleton(),
                          error: (error, _) => errorFor(
                            'practice',
                            () => ref.invalidate(sessionPanelProvider(exam.id)),
                            error: error,
                          ),
                          data: (state) => _webToday(exam.id, state),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s28),
                  _entry(
                    280,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WebText(
                          'More ways to practice',
                          kind: WebTextKind.eyebrow,
                        ),
                        counts.when(
                          loading: () => const QuizMoreSkeleton(),
                          error: (error, _) => errorFor(
                            'questions',
                            () => ref.invalidate(
                              quizPracticeCountsProvider(exam.id),
                            ),
                            error: error,
                          ),
                          data: (n) => WebCard(
                            child: Column(
                              children: [
                                WebRow(
                                  boardMetrics: true,
                                  chevron: WebRowChevron.always,
                                  title: 'Your past mistakes',
                                  value:
                                      n.mistakes == 0 ? null : '${n.mistakes}',
                                  subtitle: n.mistakes == 0
                                      ? 'Nothing to fix yet'
                                      : null,
                                  dimmed: n.mistakes == 0,
                                  leading: const _WebPracticeGlyph(
                                    _WebGlyphKind.mistakes,
                                  ),
                                  onPressed: () => unawaited(
                                    _open('/quiz/retake/${exam.id}'),
                                  ),
                                ),
                                WebRow(
                                  boardMetrics: true,
                                  chevron: WebRowChevron.always,
                                  title: 'Customize your own',
                                  dimmed: paused,
                                  subtitle: paused
                                      ? 'Finish or discard your '
                                          'paused quiz first'
                                      : null,
                                  leading: const _WebPracticeGlyph(
                                    _WebGlyphKind.customize,
                                  ),
                                  onPressed: () => unawaited(
                                    _open('/quiz/practice/${exam.id}'),
                                  ),
                                ),
                                WebRow(
                                  boardMetrics: true,
                                  chevron: WebRowChevron.always,
                                  title: 'Flagged questions',
                                  value: n.flags == 0 ? null : '${n.flags}',
                                  subtitle: n.flags == 0
                                      ? 'Flag a question to come back to it'
                                      : null,
                                  dimmed: n.flags == 0,
                                  divider: false,
                                  leading: const _WebPracticeGlyph(
                                    _WebGlyphKind.flagged,
                                  ),
                                  onPressed: () => unawaited(
                                    _open('/quiz/flagged/${exam.id}'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final mock = widget.mockPanel == null
                  ? null
                  : _entry(190, widget.mockPanel!, key: _mockKey);
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 780) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        left,
                        const SizedBox(height: PantasSpace.s28),
                        if (mock != null) mock,
                      ],
                    );
                  }
                  // Board: flex bases 420 and 380 with a 28 gap. Spare width
                  // is shared equally; a shortfall shrinks by basis.
                  final free = constraints.maxWidth - 28 - 800;
                  final leftWidth =
                      free >= 0 ? 420 + free / 2 : 420 + free * 420 / 800;
                  final rightWidth =
                      free >= 0 ? 380 + free / 2 : 380 + free * 380 / 800;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: leftWidth, child: left),
                      const SizedBox(width: PantasSpace.s28),
                      SizedBox(
                        width: rightWidth,
                        child: mock ?? const SizedBox.shrink(),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _webToday(String examId, SessionPanelState state) {
    final t = context.webTokens;
    if (state is SessionPanelNeedsAssessment) {
      if (state.questionCount == 0) return assessmentNotReady();
      void start() => unawaited(_open('/assessment/$examId'));
      return Focus(
        onKeyEvent: enterKeyHandler(start),
        autofocus: true,
        child: WebCard(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s24,
              PantasSpace.s24,
              PantasSpace.s24,
              PantasSpace.s20,
            ),
            decoration: t.dark
                ? null
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: const Alignment(-1, -.55),
                      end: const Alignment(1, .55),
                      stops: const [.6, 1],
                      colors: [t.colors.surfaceCard, t.colors.accentTint],
                    ),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('First, a short assessment', style: t.h3),
                const SizedBox(height: PantasSpace.s10),
                Text(
                  'We check your strengths and weak spots first, '
                  'so your plan is built around you.',
                  style: PantasType.webBody
                      .copyWith(color: t.colors.textSecondary),
                ),
                const SizedBox(height: PantasSpace.s18),
                Align(
                  alignment: Alignment.centerRight,
                  child: WebButton(
                    label: 'Start Assessment',
                    keyHint: 'Enter',
                    onPressed: start,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final counts = ref.watch(quizTodayCountsProvider(examId));
    void start() {
      if (state is SessionPanelInProgress) {
        unawaited(_open('/quiz/resume/$examId'));
      } else {
        unawaited(_startQuestions(examId, TodayQuestionKind.reviews));
      }
    }

    return counts.when(
      loading: () => const QuizTodayRowsSkeleton(wide: true),
      error: (error, _) => errorFor(
        'questions',
        () => ref.invalidate(quizTodayCountsProvider(examId)),
        error: error,
      ),
      data: (n) {
        final progress =
            state is SessionPanelInProgress ? state.reviewSession : null;
        final canStart = state is SessionPanelInProgress ||
            state is SessionPanelAvailable && n.reviewsTotal > n.reviewsDone;
        final showFoot = canStart || _saveFailed || _questionFailed;
        // QZ_Done: everything due is done, so say so. The plan can still hold
        // work for another day, which is not due now.
        final dayDone = state is SessionPanelCaughtUp ||
            state is SessionPanelAvailable &&
                n.reviewsDone >= n.reviewsTotal &&
                n.newDone >= n.newTotal;
        // The board's ring is a 24 px circle in a 26 px box, 2 px empty stroke.
        // The fill takes the phone's 700 ms, and each row starts after the
        // phone's delay (`TodayQuestionRow`).
        Widget ring(int done, int total, Duration fillDelay) {
          if (total > 0 && done >= total) {
            return const SizedBox.square(
              dimension: 26,
              child: Center(child: CheckMark()),
            );
          }
          final fraction = total == 0 ? 0.0 : done / total;
          return SizedBox.square(
            dimension: 26,
            child: Center(
              child: fraction > 0
                  ? ProgressRing(
                      fraction: fraction,
                      size: 25,
                      fillDuration: const Duration(milliseconds: 700),
                      fillDelay: fillDelay,
                    )
                  : ProgressRing(
                      fraction: 0,
                      emptyStrokeWidth: 2,
                      emptyTrackColor: t.dark ? null : t.colors.dividerStrong,
                      fillDuration: const Duration(milliseconds: 700),
                      fillDelay: fillDelay,
                    ),
            ),
          );
        }

        final reviewsDone =
            n.reviewsTotal > 0 && n.reviewsDone >= n.reviewsTotal;
        final newDone = n.newTotal > 0 && n.newDone >= n.newTotal;
        Widget? sessionLabel() => state is SessionPanelAvailable
            ? Consumer(
                builder: (context, ref, _) {
                  final work =
                      ref.watch(todayQuestionWorkProvider(examId)).valueOrNull;
                  if (work == null) return const SizedBox.shrink();
                  final sizes = work.reviewSizes;
                  final current = sizes.indexed
                      .where(
                        (entry) => work.reviewProgress[entry.$1] < entry.$2,
                      )
                      .firstOrNull;
                  if (current == null) return const SizedBox.shrink();
                  return Text(
                    'Reviews · Session ${current.$1 + 1} '
                    'of ${sizes.length}',
                    style: t.sub,
                  );
                },
              )
            : null;
        final primary = WebButton(
          label:
              state is SessionPanelInProgress ? 'Resume' : 'Continue Reviews',
          keyHint: 'Enter',
          busy: _startingQuestions,
          onPressed: start,
        );
        return Focus(
          onKeyEvent: canStart ? enterKeyHandler(start) : null,
          autofocus: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebCard(
                child: Column(
                  children: [
                    WebRow(
                      boardMetrics: true,
                      chevron: WebRowChevron.always,
                      title: 'Reviews',
                      titleColor: reviewsDone ? t.colors.textSecondary : null,
                      subtitle: progress == null
                          ? 'Questions due today'
                          : 'Session ${progress.ordinal} '
                              'of ${progress.total}',
                      value: '${progress?.done ?? n.reviewsDone} of '
                          '${progress?.questions ?? n.reviewsTotal}',
                      leading: ring(
                        progress?.done ?? n.reviewsDone,
                        progress?.questions ?? n.reviewsTotal,
                        Duration(
                          milliseconds:
                              state is SessionPanelInProgress ? 600 : 500,
                        ),
                      ),
                      onPressed: () =>
                          _showQuestions(examId, TodayQuestionKind.reviews),
                    ),
                    WebRow(
                      boardMetrics: true,
                      chevron: WebRowChevron.always,
                      title: 'New questions',
                      titleColor: newDone ? t.colors.textSecondary : null,
                      subtitle: "From today's lessons",
                      value: '${n.newDone} of ${n.newTotal}',
                      divider: showFoot,
                      leading: ring(
                        n.newDone,
                        n.newTotal,
                        const Duration(milliseconds: 620),
                      ),
                      onPressed: () => _showQuestions(
                        examId,
                        TodayQuestionKind.newQuestions,
                      ),
                    ),
                    if (showFoot)
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s20,
                          PantasSpace.s16,
                          PantasSpace.s20,
                          PantasSpace.s18,
                        ),
                        decoration: BoxDecoration(
                          color: t.colors.surfaceInset,
                          border: Border(
                            top: BorderSide(
                              color: t.colors.divider,
                              width: webHairline(context),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state is SessionPanelInProgress) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'You paused. Every answer was saved.',
                                      style: t.sub,
                                    ),
                                  ),
                                  const SizedBox(width: PantasSpace.s16),
                                  _WebDiscardButton(
                                    onPressed: _discarding
                                        ? null
                                        : () => unawaited(_discard(examId)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: PantasSpace.s16),
                              primary,
                            ] else if (canStart)
                              Row(
                                children: [
                                  Expanded(
                                    child: sessionLabel() ??
                                        const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: PantasSpace.s16),
                                  primary,
                                ],
                              ),
                            if (_saveFailed)
                              saveFailureLine(
                                () => unawaited(_discard(examId)),
                              ),
                            if (_questionFailed)
                              StateView(
                                message: 'Could not start your quiz.',
                                onRetry: start,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (dayDone)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s4,
                    PantasSpace.s18,
                    PantasSpace.s4,
                    PantasSpace.s0,
                  ),
                  child: Text(
                    "That's all for today.",
                    style: PantasType.webSearchInput.copyWith(
                      color: t.colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
        _questionPaused = false;
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
      _questionPaused = false;
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
          loading: () => const QuizSheetSkeleton(),
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
            final wide = context.wideWeb;
            Widget row(
              String title,
              int done,
              int total, {
              bool last = false,
            }) =>
                wide
                    ? HomeDrawerQuestionRow(
                        title: title,
                        done: done,
                        total: total,
                        last: last,
                      )
                    : _sheetRow(title, done, total);
            if (reviews) {
              for (var i = 0; i < data.reviewSizes.length; i++) {
                rows.add(
                  row(
                    'Session ${i + 1}',
                    data.reviewProgress[i],
                    data.reviewSizes[i],
                    last: i == data.reviewSizes.length - 1,
                  ),
                );
              }
            } else {
              for (final r in data.newRows) {
                rows.add(
                  row(
                    r.title,
                    r.done,
                    r.total,
                    last: r == data.newRows.last,
                  ),
                );
              }
            }
            final sheet =
                wide ? HomeWebQuestionsSheet.new : TodayQuestionsSheet.new;
            return sheet(
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
              failure: !_questionFailed
                  ? null
                  : _questionPaused
                      ? PausedQuizNotice(
                          onResume: () {
                            _dismissQuestions();
                            unawaited(_open('/quiz/resume/$examId'));
                          },
                          onDiscard: _discarding
                              ? null
                              : () => unawaited(_discardPaused(examId)),
                        )
                      : StateView(
                          message: 'Could not start your quiz.',
                          onRetry: () => unawaited(
                            _startQuestions(examId, kind, work: data),
                          ),
                        ),
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
          style: PantasType.phoneCallout
              .copyWith(color: context.colors.textPrimary),
        ),
        value: '$total',
        valueStyle: PantasType.phoneFootnote
            .copyWith(color: context.colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(vertical: PantasSpace.s8),
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
      _questionPaused = false;
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
    } on Object catch (error) {
      if (current()) {
        setState(() {
          _questionFailed = true;
          _questionPaused = error is PausedQuizConflict;
        });
      }
    } finally {
      if (current()) setState(() => _startingQuestions = false);
    }
  }

  Widget _entry(int delay, Widget child, {Key? key}) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: delay + 450),
      curve: Interval(delay / (delay + 450), 1, curve: PantasCurves.house),
      child: child,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 12 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
    );
  }

  /// Board rows (QZ_Tab): a 21 px stroke glyph in a 28 px box, so the title
  /// starts at x 74.
  Widget _phoneGlyph(_WebGlyphKind kind, Color color) => ExcludeSemantics(
        child: SizedBox(
          width: PantasSpace.s28,
          child: Center(
            child: CustomPaint(
              size: const Size.square(21),
              painter: _WebGlyphPainter(kind, color),
            ),
          ),
        ),
      );

  Widget _practiceRow(
    String title,
    int count, {
    required _WebGlyphKind glyph,
    required String empty,
    required VoidCallback onTap,
  }) =>
      Opacity(
        opacity: count == 0 ? .45 : 1,
        child: ListRow(
          title: title,
          leading: _phoneGlyph(
            glyph,
            count == 0 ? context.colors.textSecondary : context.colors.accent,
          ),
          leadingGap: 14,
          variant:
              count == 0 ? ListRowVariant.value : ListRowVariant.navigation,
          value: count == 0 ? null : '$count',
          // The count keeps its own width and the title takes the rest. Shared
          // half and half, "Flagged questions" was cut short on a phone.
          naturalValue: true,
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
          color: context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(PantasRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s18,
            PantasSpace.s20,
            PantasSpace.s18,
            PantasSpace.s18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'First, a short assessment',
                style: PantasType.phoneTitle2.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: PantasSpace.s8),
              Text(
                'We check your strengths and weak spots first, '
                'so your plan is built around you.',
                style: PantasType.phoneExplanation
                    .copyWith(color: context.colors.textPrimary)
                    .copyWith(
                      color: context.colors.textSecondary,
                      height: 1.4,
                    ),
              ),
              // Board (QZ_First): 20 px from the line to the button.
              const SizedBox(height: PantasSpace.s16),
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
    final todayCounts = counts.unwrapPrevious().asData?.value;
    final reviewsLeft =
        (todayCounts?.reviewsTotal ?? 0) > (todayCounts?.reviewsDone ?? 0);
    // Nothing to say under the rows (no paused session, no line, no button):
    // the block would only be a blank strip.
    final dayDone = state is SessionPanelCaughtUp ||
        state is SessionPanelAvailable &&
            todayCounts != null &&
            !reviewsLeft &&
            todayCounts.newDone >= todayCounts.newTotal;
    final hasTail = state is SessionPanelInProgress ||
        dayDone ||
        (state is SessionPanelAvailable && reviewsLeft) ||
        (_questionFailed && _questionSheet == null);
    return GroupedSection(
      header: 'Today',
      children: [
        counts.when(
          loading: () => const QuizTodayRowsSkeleton(),
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
        if (hasTail)
          Padding(
            padding: EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s14,
              PantasSpace.s16,
              state is SessionPanelInProgress
                  ? PantasSpace.s10
                  : PantasSpace.s16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is SessionPanelInProgress) ...[
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      'You paused. Every answer was saved.',
                      style: PantasType.phoneExplanation
                          .copyWith(color: context.colors.textPrimary)
                          .copyWith(color: context.colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s14),
                  PantasButton(
                    label: 'Resume',
                    onPressed: () => unawaited(_open('/quiz/resume/$examId')),
                  ),
                  // Board (QZ_Resume): the link sits 6 px lower.
                  const SizedBox(height: PantasSpace.s6),
                  TextButton(
                    onPressed:
                        _discarding ? null : () => unawaited(_discard(examId)),
                    child: Text(
                      'Discard this session',
                      style: PantasType.phoneExplanation
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          )
                          .copyWith(color: context.colors.accent),
                    ),
                  ),
                  if (_saveFailed)
                    saveFailureLine(() => unawaited(_discard(examId))),
                ] else if (dayDone)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      "That's all for today.",
                      style: PantasType.phoneExplanation
                          .copyWith(color: context.colors.textPrimary)
                          .copyWith(color: context.colors.textSecondary),
                    ),
                  ),
                if (state is SessionPanelAvailable && reviewsLeft)
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

  /// Discards from the questions sheet, then lets the sheet start again.
  Future<void> _discardPaused(String examId) async {
    await _discard(examId);
    if (mounted && !_saveFailed) {
      setState(() => _questionFailed = _questionPaused = false);
    }
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

enum _WebGlyphKind { mistakes, customize, flagged }

/// The board's 22 px teal stroke glyphs (24 px viewBox, 2 px stroke).
class _WebPracticeGlyph extends StatelessWidget {
  const _WebPracticeGlyph(this.kind);
  final _WebGlyphKind kind;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: const Size.square(22),
          painter: _WebGlyphPainter(kind, context.webTokens.colors.accent),
        ),
      );
}

class _WebGlyphPainter extends CustomPainter {
  const _WebGlyphPainter(this.kind, this.color);
  final _WebGlyphKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    Offset o(double x, double y) => Offset(x * k, y * k);
    switch (kind) {
      case _WebGlyphKind.mistakes:
        canvas
          ..drawLine(o(6.5, 6.5), o(17.5, 17.5), paint)
          ..drawLine(o(17.5, 6.5), o(6.5, 17.5), paint);
      case _WebGlyphKind.customize:
        canvas
          ..drawLine(o(4, 7), o(13, 7), paint)
          ..drawLine(o(17, 7), o(20, 7), paint)
          ..drawLine(o(4, 17), o(7, 17), paint)
          ..drawLine(o(11, 17), o(20, 17), paint)
          ..drawCircle(o(15, 7), 2 * k, paint)
          ..drawCircle(o(9, 17), 2 * k, paint);
      case _WebGlyphKind.flagged:
        canvas
          ..drawLine(o(5.5, 21), o(5.5, 4.5), paint)
          ..drawPath(
            Path()
              ..moveTo(5.5 * k, 4.5 * k)
              ..lineTo(17 * k, 4.5 * k)
              ..lineTo(14.6 * k, 8.5 * k)
              ..lineTo(17 * k, 12.5 * k)
              ..lineTo(5.5 * k, 12.5 * k),
            paint,
          );
    }
  }

  @override
  bool shouldRepaint(_WebGlyphPainter old) =>
      old.kind != kind || old.color != color;
}

/// Board `.btn3`: 42 px text button, radius 11, 16 px semibold gray.
class _WebDiscardButton extends StatelessWidget {
  const _WebDiscardButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: const WidgetStatePropertyAll(Size(0, 42)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: PantasSpace.s14),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered)
              ? t.disabledBackground
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered)
              ? t.colors.textPrimary
              : t.colors.textSecondary,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PantasRadius.back),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          PantasType.webButton.copyWith(color: t.colors.textPrimary),
        ),
      ),
      child: const Text('Discard this session'),
    );
  }
}
