import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/route_leave_guard.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart'
    as passage_ui;
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/quiz/application/quiz_leave_guard.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/web_quiz_question.dart';

enum QuizPageMode { quick, today, drill, retake, inline, resume, practice }

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    required this.examId,
    this.topicId,
    this.lessonId,
    this.mode = QuizPageMode.quick,
    this.prepared,
    this.proIsActive,
    this.customSessionId,
    super.key,
  });
  final String examId;
  final String? topicId;
  final String? lessonId;
  final QuizPageMode mode;
  final PreparedTodaySession? prepared;
  final bool? proIsActive;
  final String? customSessionId;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

String _questionStageKey(QuestionId id) => 'quiz-question-$id';

class _PreparedQuestionStage extends ConsumerStatefulWidget {
  const _PreparedQuestionStage({
    required this.proIsActive,
    this.proPaused = false,
    this.viewIndex,
  });

  final bool proIsActive;
  final bool proPaused;
  final int? viewIndex;

  @override
  ConsumerState<_PreparedQuestionStage> createState() =>
      _PreparedQuestionStageState();
}

class _PreparedQuestionStageState
    extends ConsumerState<_PreparedQuestionStage> {
  final Map<QuestionId, Widget> _plainQuestionPanes = <QuestionId, Widget>{};

  String? _sessionId;
  int? _currentIndex;
  int? _preparedIndex;
  int? _scheduledPrepareIndex;
  bool _deferPreparationForTransition = false;
  Timer? _deferPreparationTimer;

  @override
  void initState() {
    super.initState();
    ref.read(quizControllerProvider.notifier).clearQuestionPreparation();
  }

  @override
  void dispose() {
    _deferPreparationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = ref.watch(
      quizControllerProvider.select(
        (state) => state is QuizRunning
            ? (
                session: state.session,
                questionShownAt: state.questionShownAt,
              )
            : null,
      ),
    );
    if (running == null) return const SizedBox.shrink();

    final actualSession = running.session;
    final session = widget.viewIndex == null
        ? actualSession
        : actualSession.copyWith(currentIndex: widget.viewIndex!);
    final questionShownAt = running.questionShownAt;
    _syncSession(actualSession);

    final currentIndex = session.currentIndex;
    final question = session.currentQuestion;
    final passageId = question.passageId;
    final passageState =
        passageId != null ? ref.watch(passageByIdProvider(passageId)) : null;
    final passage = passageState?.valueOrNull;
    if (passageId != null && passage == null) {
      if (passageState!.isLoading) return const SkeletonQuestionPage();
      return errorFor(
        'quiz',
        () => ref.invalidate(passageByIdProvider(passageId)),
      );
    }

    final outcome = session.currentOutcome;
    if (widget.viewIndex == null &&
        outcome == null &&
        questionShownAt == null) {
      final sessionId = session.sessionId;
      final questionIndex = currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(quizControllerProvider.notifier).markQuestionReady(
              sessionId: sessionId,
              questionIndex: questionIndex,
            );
      });
    }

    if (widget.viewIndex == null) {
      _scheduleNextPreparationIfReady(actualSession, questionShownAt);
    }

    final currentPane = outcome == null
        ? _interactionGate(
            enabled: questionShownAt != null,
            child: _plainQuestionPane(question, passage: passage),
          )
        // The same wrappers as before the check, so the question keeps its
        // state and the reveal plays instead of starting from its end.
        : _interactionGate(
            enabled: true,
            child: _revealedQuestionPane(
              session,
              question,
              passage: passage,
            ),
          );

    final preparedIndex = widget.viewIndex == null ? _preparedIndex : null;
    final preparedIsCurrent =
        _deferPreparationForTransition && preparedIndex == currentIndex;
    final children = <Widget>[];
    QuestionId? preparedQuestionId;

    if (preparedIndex != null &&
        preparedIndex >= 0 &&
        preparedIndex < session.questions.length) {
      final prepared = session.questions[preparedIndex];
      if (prepared.passageId == null) {
        preparedQuestionId = prepared.id;
        children
          ..add(
            Opacity(
              key: ValueKey<String>(_questionStageKey(prepared.id)),
              opacity: 1,
              child: _interactionGate(
                enabled: preparedIsCurrent &&
                    outcome == null &&
                    questionShownAt != null,
                child: RepaintBoundary(
                  child: _plainQuestionPane(prepared),
                ),
              ),
            ),
          )
          ..add(
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  key: const ValueKey<String>('quiz-question-prepaint-cover'),
                  opacity: preparedIsCurrent ? 0 : 1,
                  child: ColoredBox(color: context.colors.background),
                ),
              ),
            ),
          );
      }
    }

    if (!preparedIsCurrent) {
      children.add(
        Opacity(
          key: ValueKey<String>(_questionStageKey(question.id)),
          opacity: 1,
          child: currentPane,
        ),
      );
    }

    _plainQuestionPanes.removeWhere(
      (id, _) => id != question.id && id != preparedQuestionId,
    );

    return Stack(alignment: Alignment.topLeft, children: children);
  }

  void _syncSession(QuizSession session) {
    if (_sessionId != session.sessionId) {
      _deferPreparationTimer?.cancel();
      _deferPreparationTimer = null;
      _plainQuestionPanes.clear();
      _preparedIndex = null;
      _scheduledPrepareIndex = null;
      _deferPreparationForTransition = false;
      _sessionId = session.sessionId;
      _currentIndex = session.currentIndex;
      return;
    }

    final oldIndex = _currentIndex;
    final newIndex = session.currentIndex;
    if (oldIndex != null && newIndex != oldIndex) {
      if (newIndex == oldIndex + 1 && _preparedIndex == newIndex) {
        _deferPreparationForTransition = true;
        _deferPreparationTimer?.cancel();
        final sessionId = session.sessionId;
        _deferPreparationTimer = Timer(const Duration(milliseconds: 120), () {
          _deferPreparationTimer = null;
          if (!mounted) return;

          final state = ref.read(quizControllerProvider);
          if (state is! QuizRunning ||
              state.session.sessionId != sessionId ||
              state.session.currentIndex != newIndex) {
            return;
          }

          setState(() {
            if (_preparedIndex == newIndex) {
              _preparedIndex = null;
            }
            _deferPreparationForTransition = false;
          });
        });
      } else if (newIndex != oldIndex + 1) {
        _deferPreparationTimer?.cancel();
        _deferPreparationTimer = null;
        _preparedIndex = null;
        _scheduledPrepareIndex = null;
        _deferPreparationForTransition = false;
      }
    }
    _currentIndex = newIndex;
  }

  void _scheduleNextPreparationIfReady(
    QuizSession session,
    DateTime? questionShownAt,
  ) {
    if (_deferPreparationForTransition) return;
    if (questionShownAt == null && session.currentOutcome == null) {
      return;
    }

    final sessionId = session.sessionId;
    final nextIndex = session.currentIndex + 1;
    if (nextIndex >= session.questions.length) return;
    final next = session.questions[nextIndex];
    if (next.passageId != null) return;
    if (_preparedIndex == nextIndex || _scheduledPrepareIndex == nextIndex) {
      return;
    }

    _scheduledPrepareIndex = nextIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sessionId != sessionId) return;
      if (_scheduledPrepareIndex == nextIndex) {
        _scheduledPrepareIndex = null;
      }

      final state = ref.read(quizControllerProvider);
      if (state is! QuizRunning || state.session.sessionId != sessionId) {
        return;
      }
      final current = state.session;
      if (current.currentIndex + 1 != nextIndex ||
          nextIndex >= current.questions.length ||
          current.questions[nextIndex].passageId != null) {
        return;
      }
      setState(() => _preparedIndex = nextIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _sessionId != sessionId ||
            _preparedIndex != nextIndex) {
          return;
        }

        final renderedState = ref.read(quizControllerProvider);
        if (renderedState is! QuizRunning ||
            renderedState.session.sessionId != sessionId ||
            renderedState.session.currentIndex + 1 != nextIndex ||
            nextIndex >= renderedState.session.questions.length) {
          return;
        }

        ref.read(quizControllerProvider.notifier).markQuestionPrepared(
              sessionId: sessionId,
              questionIndex: nextIndex,
            );
      });
    });
  }

  Widget _plainQuestionPane(Question question, {Passage? passage}) =>
      _plainQuestionPanes.putIfAbsent(
        question.id,
        () => _QuestionContent(
          question: question,
          passage: passage,
          proIsActive: widget.proIsActive,
          proPaused: widget.proPaused,
        ),
      );

  Widget _revealedQuestionPane(
    QuizSession session,
    Question question, {
    Passage? passage,
  }) =>
      _QuestionContent(
        question: question,
        passage: passage,
        outcome: session.currentOutcome,
        proIsActive: widget.proIsActive,
        proPaused: widget.proPaused,
      );

  Widget _interactionGate({required bool enabled, required Widget child}) {
    // A pane that cannot be used also stays out of the Tab order. The next
    // question is built under a cover while this one is answered; without
    // this, every choice took a second, invisible Tab stop.
    return ExcludeSemantics(
      excluding: !enabled,
      child: ExcludeFocus(
        excluding: !enabled,
        child: IgnorePointer(ignoring: !enabled, child: child),
      ),
    );
  }
}

final _questionTopicProvider = FutureProvider.family<String, String>(
  (ref, id) async =>
      (await ref.watch(contentRepositoryProvider).topicById(id))?.name ?? '',
);

class _QuestionContent extends ConsumerWidget {
  const _QuestionContent({
    required this.question,
    required this.proIsActive,
    this.proPaused = false,
    this.passage,
    this.outcome,
  });
  final Question question;
  final Passage? passage;
  final AnswerOutcome? outcome;
  final bool proIsActive;
  final bool proPaused;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(quizControllerProvider);
    final chosen = outcome?.chosenChoiceId ??
        (running is QuizRunning &&
                running.session.currentQuestion.id == question.id
            ? running.selectedChoiceId
            : null);
    final correct = question.correctChoice;
    final picked = question.choices.where((c) => c.id == chosen).firstOrNull;
    if (context.wideWeb) {
      return WebQuizQuestion(
        question: question,
        subject:
            ref.watch(_questionTopicProvider(question.topicId)).valueOrNull ??
                '',
        chosenId: chosen,
        checked: outcome != null,
        pro: proIsActive,
        proPaused: proPaused,
        passage: passage,
        passagePosition: passage == null || running is! QuizRunning
            ? null
            : (
                ordinal: running.session.questions
                    .take(running.session.currentIndex + 1)
                    .where((q) => q.passageId == question.passageId)
                    .length,
                total: running.session.questions
                    .where((q) => q.passageId == question.passageId)
                    .length,
              ),
        onPick: outcome != null || running is! QuizRunning || running.checking
            ? null
            : (id) => ref
                .read(quizControllerProvider.notifier)
                .pick(chosenChoiceId: id),
      );
    }
    return LessonTextScale(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            subject: ref
                    .watch(_questionTopicProvider(question.topicId))
                    .valueOrNull ??
                '',
            stem: question.stem,
            passage: passage == null
                ? null
                : passage_ui.PassageCard(
                    title: passage!.title,
                    text: passage!.body,
                  ),
            figure: question.figureSpecJson == null
                ? null
                : QuestionFigure(specJson: question.figureSpecJson),
            choices: [
              for (final choice in question.choices)
                ChoiceRow(
                  letter: choice.label,
                  text: choice.text,
                  state: outcome == null
                      ? choice.id == chosen
                          ? ChoiceRowState.picked
                          : ChoiceRowState.plain
                      : choice.id == correct.id
                          ? ChoiceRowState.right
                          : choice.id == chosen
                              ? ChoiceRowState.wrong
                              : ChoiceRowState.dimmed,
                  onTap: outcome != null ||
                          running is! QuizRunning ||
                          running.checking
                      ? null
                      : () => ref
                          .read(quizControllerProvider.notifier)
                          .pick(chosenChoiceId: choice.id),
                ),
            ],
          ),
          if (outcome != null) ...[
            const SizedBox(height: 20),
            AnswerReveal(
              key: ValueKey('reveal-${question.id}'),
              correctLetter: correct.label,
              explanation: question.explanation,
              pickedLetter: picked?.label,
              wrongPick:
                  proIsActive && !outcome!.isCorrect ? picked?.rationale : null,
            ),
            if (proPaused && !outcome!.isCorrect) ...[
              const SizedBox(height: 12),
              const ProPausedLine(),
            ],
          ],
        ],
      ),
    );
  }
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final ScreenTimer _timing = ScreenTimer('screen.quizstart');

  @override
  void initState() {
    super.initState();
    final guard = ref.read(quizLeaveGuardProvider)..running = _allowLeave;
    _guard = guard;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startForMode(ref.read(quizControllerProvider.notifier));
    });
  }

  RouteLeaveGuard? _guard;

  /// Browser Back reaches the route's `onExit` instead of this page's pop
  /// handling. While a session runs it shows the same dialog as Esc and the
  /// close button. Leaving after the student confirmed, or before a session
  /// is on screen (loading, failed, finished), is always allowed.
  Future<bool> _allowLeave() async {
    if (!mounted ||
        _allowPop ||
        ref.read(quizControllerProvider) is! QuizRunning) {
      return true;
    }
    unawaited(_confirmLeave());
    return false;
  }

  String? _seenSessionId;
  int? _viewIndex;
  bool _gridOpen = false;
  bool _leaveOpen = false;
  BuildContext? _leaveContext;
  bool _allowPop = false;
  Future<void> Function()? _retryWrite;
  int _writeVersion = 0;
  bool _flagBusy = false;
  String? _poppingFlag;
  bool _toastVisible = false;
  String? _toastMessage;
  QuestionId? _undoFlag;
  Timer? _toastDelay;
  Timer? _toastHide;
  Timer? _toastRemove;
  final ScrollController _questionScroll = ScrollController();
  final Set<String> _reported = {};
  String? _reportStatus;
  Timer? _reportTimer;
  final LayerLink _barLink = LayerLink();

  @override
  void dispose() {
    _guard?.detach(_allowLeave);
    _toastDelay?.cancel();
    _toastHide?.cancel();
    _toastRemove?.cancel();
    _reportTimer?.cancel();
    _questionScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pro = widget.proIsActive ??
        ref.watch(proForActiveExamProvider).unwrapPrevious().asData?.value ??
        false;
    final paused = widget.proIsActive == null &&
        ref.watch(entitlementProvider).valueOrNull?.state ==
            EntitlementState.paused;
    final state = ref.watch(quizControllerProvider);
    firstScreenReady(
      context,
      ref,
      ready: state is QuizRunning || state is QuizFailure,
    );
    _timing.settled(ready: state is QuizRunning);
    if (state is QuizComplete) {
      return QuizSessionEndPage(
        key: ValueKey('quiz-end-${state.attempt.id}'),
        attemptId: state.attempt.id,
        proIsActive: widget.proIsActive,
        sessionOverride: state.session,
        fresh: _seenSessionId == state.session.sessionId,
        custom: widget.customSessionId == state.session.sessionId &&
            state.session.origin == SessionOrigin.drill,
      );
    }
    if (state is QuizRunning && state.session.examId == widget.examId) {
      _seenSessionId = state.session.sessionId;
    }
    if (state is! QuizRunning) {
      if (state is QuizQuestionsUnavailable) {
        return QuestionsUnavailable(
          notFound: true,
          onRetry: () => _startForMode(
            ref.read(quizControllerProvider.notifier),
          ),
        );
      }
      final child =
          state is QuizFailure && ref.watch(contentLimitReachedProvider)
              ? const StateView(message: contentLimitMessage)
              : state is QuizFailure
                  ? errorFor(
                      'quiz',
                      () => _startForMode(
                        ref.read(quizControllerProvider.notifier),
                      ),
                    )
                  : const SkeletonQuestionPage();
      if (context.wideWeb) {
        return QuizUnavailableFrame(
          onClose: () => _leave(context),
          child: child,
        );
      }
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    }
    final session = state.session;
    final index = _viewIndex ?? session.currentIndex;
    final question = session.questions[index];
    final outcome =
        index < session.outcomes.length ? session.outcomes[index] : null;
    final lookingBack = _viewIndex != null && index != session.currentIndex;
    final flagged =
        ref.watch(flaggedIdsProvider).valueOrNull ?? const <String>{};
    if (context.wideWeb) {
      return _webPage(state, index, flagged, pro: pro, paused: paused);
    }
    final page = Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Leave session',
                    constraints:
                        const BoxConstraints.tightFor(width: 44, height: 44),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => unawaited(_confirmLeave()),
                    icon: Icon(
                      PantasIcons.close,
                      size: 22,
                      color: context.colors.controlOutline,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Report a question',
                    constraints:
                        const BoxConstraints.tightFor(width: 44, height: 44),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final saved = await openQuestionReport(
                        context,
                        question.id,
                        queue: ReportQueue(ref.read(appDatabaseProvider)),
                      );
                      if ((saved ?? false) && mounted) {
                        setState(() => _reported.add(question.id));
                      }
                    },
                    icon: IconTheme(
                      data: IconThemeData(
                        size: 21,
                        color: _reported.contains(question.id)
                            ? context.colors.accent
                            : context.colors.controlOutline,
                      ),
                      child: PantasIcons.report,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final large = MediaQuery.textScalerOf(context).scale(16) > 24;
                  final counter = _counter(
                    index,
                    session.questions.length,
                    enabled: !state.checking,
                  );
                  final flag = Semantics(
                    button: true,
                    enabled: !_flagBusy,
                    toggled: flagged.contains(question.id),
                    label: flagged.contains(question.id)
                        ? 'Remove flag from question ${index + 1}'
                        : 'Flag question ${index + 1}',
                    onTap: _flagBusy
                        ? null
                        : () => unawaited(_toggleFlag(question.id)),
                    child: ExcludeSemantics(
                      child: IconButton(
                        constraints:
                            const BoxConstraints(minWidth: 44, minHeight: 44),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        tooltip: flagged.contains(question.id)
                            ? 'Remove flag'
                            : 'Flag question',
                        onPressed: _flagBusy
                            ? null
                            : () => unawaited(_toggleFlag(question.id)),
                        icon: _flag(question.id, flagged.contains(question.id)),
                      ),
                    ),
                  );
                  final action = PantasButton(
                    label: lookingBack
                        ? 'Back to ${session.currentIndex + 1}'
                        : outcome == null
                            ? 'Check'
                            : session.isComplete
                                ? 'Finish'
                                : 'Next',
                    disabledForeground: outcome == null
                        ? context.colors.disabledActionLabel
                        : null,
                    // QV_MissPro: Next carries a chevron.
                    trailing:
                        !lookingBack && outcome != null && !session.isComplete
                            ? Icon(PantasIcons.next, size: 16)
                            : null,
                    fullWidth: large,
                    height: 44,
                    radius: 99,
                    fontSize: 16,
                    horizontalPadding: 18,
                    busy: state.checking,
                    onPressed: lookingBack
                        ? () => _lookAt(null)
                        : outcome == null
                            ? (state.selectedChoiceId == null || state.checking
                                ? null
                                : () => unawaited(_check()))
                            : () => unawaited(_next()),
                  );
                  final bar = FloatingBar.content(
                    state: outcome == null
                        ? FloatingBarState.neutral
                        : outcome.isCorrect
                            ? FloatingBarState.right
                            : FloatingBarState.wrong,
                    child: large
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(children: [Expanded(child: counter), flag]),
                              action,
                            ],
                          )
                        : Row(
                            children: [Expanded(child: counter), flag, action],
                          ),
                  );
                  final scroll = SingleChildScrollView(
                    key: const ValueKey('quiz-scroll'),
                    controller: _questionScroll,
                    padding: EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      large
                          ? 24
                          : FloatingBar.contentBottomInset +
                              24 +
                              MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PreparedQuestionStage(
                          proIsActive: pro,
                          proPaused: paused,
                          viewIndex: _viewIndex,
                        ),
                        if (_retryWrite != null)
                          saveFailureLine(() => unawaited(_retryWrite!())),
                      ],
                    ),
                  );
                  final toast = _toastMessage == null
                      ? null
                      : Toast(
                          message: _toastMessage!,
                          visible: _toastVisible,
                          onUndo: _undoFlag == null
                              ? null
                              : () => unawaited(_toggleFlag(_undoFlag!)),
                        );
                  if (large) {
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(child: scroll),
                              if (toast != null)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 8,
                                  child: toast,
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
                          child: bar,
                        ),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      Positioned.fill(child: scroll),
                      Positioned(left: 16, right: 16, bottom: 26, child: bar),
                      if (toast != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 92,
                          child: toast,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    final wasGridOpen = _gridOpen;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !wasGridOpen) unawaited(_confirmLeave());
      },
      child: QuestionGridSheet(
        page: page,
        open: _gridOpen,
        onDismiss: () => setState(() => _gridOpen = false),
        summary: '${session.outcomes.length} of '
            '${session.questions.length} answered',
        parts: [
          QuestionGridPart(
            title: '',
            questions: [
              for (var n = 0; n < session.questions.length; n++)
                GridQuestion(
                  number: n + 1,
                  state: n < session.outcomes.length
                      ? session.outcomes[n].isCorrect
                          ? GridQuestionState.right
                          : GridQuestionState.wrong
                      : GridQuestionState.unreached,
                  current: n == index,
                  flagged: flagged.contains(session.questions[n].id),
                ),
            ],
          ),
        ],
        onSelected: (number) {
          if (number - 1 < session.outcomes.length) {
            _lookAt(number - 1 == session.currentIndex ? null : number - 1);
          }
        },
      ),
    );
  }

  Widget _webPage(
    QuizRunning state,
    int index,
    Set<String> flagged, {
    required bool pro,
    required bool paused,
  }) {
    final t = context.webTokens;
    final session = state.session;
    final total = session.questions.length;
    final current = session.currentIndex;
    final question = session.questions[index];
    final outcome =
        index < session.outcomes.length ? session.outcomes[index] : null;
    final lookingBack = _viewIndex != null && index != session.currentIndex;
    final batch = session.reviewBatch;
    final source = batch != null
        ? 'Reviews · Session ${batch.ordinal} of ${batch.total}'
        : session.origin == SessionOrigin.newQuestions
            ? "New questions · From today's lessons"
            : 'Quiz';
    final label = lookingBack
        ? 'Back to ${session.currentIndex + 1}'
        : outcome == null
            ? 'Check'
            : session.isComplete
                ? 'Finish'
                : 'Next';
    void action() {
      if (state.checking) return;
      if (lookingBack) {
        _lookAt(null);
      } else if (outcome == null) {
        if (state.selectedChoiceId != null) unawaited(_check());
      } else {
        unawaited(_next());
      }
    }

    // The question grid opens over the spot the toast sits on. The grid wins:
    // the toast leaves, so the grid is whole and the flagged cell shows what
    // the toast said.
    if (_gridOpen && _toastVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _gridOpen && _toastVisible) _dropToast();
      });
    }

    // The Leave dialog owns the keys while it is open. Its own focus keeps
    // them away from this page; this is the second guard, for a page that
    // gets the focus back anyway.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (_leaveOpen) {
            _dismissLeave();
          } else if (_gridOpen) {
            setState(() => _gridOpen = false);
          } else {
            unawaited(_confirmLeave());
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyF): () {
          if (!_leaveOpen && !_flagBusy) unawaited(_toggleFlag(question.id));
        },
        const SingleActivator(LogicalKeyboardKey.keyG): () {
          if (!_leaveOpen && !state.checking) {
            setState(() => _gridOpen = !_gridOpen);
          }
        },
        // A to E pick a choice, as on the assessment. They stop once the
        // question is checked, while it is being checked, and in a dialog.
        ...answerKeyBindings(
          choiceCount: () => question.choices.length,
          onPick: (i) {
            if (_leaveOpen || state.checking || outcome != null) return;
            ref
                .read(quizControllerProvider.notifier)
                .pick(chosenChoiceId: question.choices[i].id);
          },
        ),
      },
      child: KeyFocusKeeper(
        // The page's own node only holds its keys: Tab skips it.
        skipTraversal: true,
        // Enter runs the control that holds focus. An answer that is already
        // picked is the exception: Enter on it checks it.
        onKeyEvent: enterKeyHandler(
          () {
            if (!_leaveOpen) action();
          },
          keepsEnter: (focused) =>
              focused.findAncestorWidgetOfExactType<WebAnswerOption>()?.state ==
              WebOptionState.selected,
        ),
        child: PopScope(
          canPop: _allowPop,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) unawaited(_confirmLeave());
          },
          child: Scaffold(
            backgroundColor: t.colors.background,
            body: Column(
              children: [
                WebCenteredTopBar(
                  titleKey: const ValueKey('quiz-top-title'),
                  title: source,
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebTopBarButton(
                        tooltip: 'Leave session',
                        onPressed: () => unawaited(_confirmLeave()),
                        icon: Icon(PantasIcons.close, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const WebKeyHint('Esc'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_reportStatus == question.id)
                        Text(
                          'Saved on this device.',
                          style: t.sm,
                        ),
                      WebTopBarButton(
                        tooltip: 'Report a question',
                        onPressed: () async {
                          final saved = await openQuestionReport(
                            context,
                            question.id,
                            queue: ReportQueue(
                              ref.read(appDatabaseProvider),
                            ),
                          );
                          if ((saved ?? false) && mounted) {
                            _reportTimer?.cancel();
                            setState(() {
                              _reported.add(question.id);
                              _reportStatus = question.id;
                            });
                            _reportTimer = Timer(
                              const Duration(seconds: 4),
                              () {
                                if (mounted) {
                                  setState(() => _reportStatus = null);
                                }
                              },
                            );
                          }
                        },
                        icon: IconTheme(
                          data: IconThemeData(
                            color: _reported.contains(question.id)
                                ? t.colors.accent
                                : t.colors.secondaryLabel,
                          ),
                          child: PantasIcons.report,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          controller: _questionScroll,
                          padding: EdgeInsets.fromLTRB(
                            40,
                            question.passageId == null ? 56 : 24,
                            40,
                            140,
                          ),
                          child: Column(
                            children: [
                              _PreparedQuestionStage(
                                proIsActive: pro,
                                proPaused: paused,
                                viewIndex: _viewIndex,
                              ),
                              if (_retryWrite != null)
                                saveFailureLine(
                                  () => unawaited(_retryWrite!()),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: _Popover(
                          open: _gridOpen,
                          builder: (_) => GestureDetector(
                            onTap: () => setState(() => _gridOpen = false),
                            behavior: HitTestBehavior.translucent,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 28,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: CompositedTransformTarget(
                            link: _barLink,
                            child: IntrinsicWidth(
                              child: WebBottomBar(
                                compact: true,
                                counterChevron: true,
                                counter: '${index + 1} of $total',
                                counterLabel:
                                    'Question ${index + 1} of $total. '
                                    'Open question navigator',
                                onCounterPressed: state.checking
                                    ? null
                                    : () => setState(
                                          () => _gridOpen = !_gridOpen,
                                        ),
                                state: outcome == null
                                    ? WebBarState.neutral
                                    : outcome.isCorrect
                                        ? WebBarState.right
                                        : WebBarState.wrong,
                                action: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // The same name and switch the phone
                                    // gives its flag.
                                    Semantics(
                                      button: true,
                                      enabled: !_flagBusy,
                                      toggled: flagged.contains(question.id),
                                      label: flagged.contains(question.id)
                                          ? 'Remove flag from question '
                                              '${index + 1}'
                                          : 'Flag question ${index + 1}',
                                      onTap: _flagBusy
                                          ? null
                                          : () => unawaited(
                                                _toggleFlag(question.id),
                                              ),
                                      child: ExcludeSemantics(
                                        child: IconButton(
                                          tooltip: flagged.contains(question.id)
                                              ? 'Remove flag'
                                              : 'Flag question',
                                          constraints:
                                              const BoxConstraints.tightFor(
                                            width: 46,
                                            height: 46,
                                          ),
                                          padding: EdgeInsets.zero,
                                          visualDensity: VisualDensity.standard,
                                          style: IconButton.styleFrom(
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            shape: const CircleBorder(),
                                          ),
                                          // Stays enabled while the write
                                          // runs: a disabled button gives
                                          // up its focus, and the ring
                                          // jumped to the counter.
                                          onPressed: () {
                                            if (!_flagBusy) {
                                              unawaited(
                                                _toggleFlag(question.id),
                                              );
                                            }
                                          },
                                          icon: _flag(
                                            question.id,
                                            flagged.contains(question.id),
                                            web: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    WebButton(
                                      label: label,
                                      pill: true,
                                      keyHint: 'Enter',
                                      busy: state.checking,
                                      onPressed: state.checking ||
                                              (!lookingBack &&
                                                  outcome == null &&
                                                  state.selectedChoiceId ==
                                                      null)
                                          ? null
                                          : action,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        // The follower stays outside the fade: a box
                        // between it and the Stack would refuse taps away
                        // from (0, 0).
                        child: CompositedTransformFollower(
                          link: _barLink,
                          followerAnchor: Alignment.bottomLeft,
                          offset: const Offset(.8, -12),
                          child: _Popover(
                            open: _gridOpen,
                            builder: (_) => SizedBox(
                              width: 376,
                              child: WebCard(
                                radius: 14,
                                floating: true,
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Questions',
                                          style: t.style(
                                            17,
                                            weight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            '${session.outcomes.length} of '
                                            '$total answered',
                                            style: t.sm,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 360,
                                      ),
                                      // Board QS_Grid: five equal columns,
                                      // 44 px cells 8 px apart. The dark edge
                                      // marks the question on screen.
                                      child: GridView.count(
                                        crossAxisCount: 5,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                        childAspectRatio: 61.6 / 44,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        children: [
                                          for (var n = 0;
                                              n < session.questions.length;
                                              n++)
                                            _WebGridCell(
                                              key: ValueKey(
                                                'web-grid-question-$n',
                                              ),
                                              number: n + 1,
                                              outcome:
                                                  n < session.outcomes.length
                                                      ? session.outcomes[n]
                                                      : null,
                                              onScreen: n == index,
                                              flagged: flagged.contains(
                                                session.questions[n].id,
                                              ),
                                              onPressed: n <=
                                                      session.outcomes.length
                                                  ? () => _lookAt(
                                                        n == current ? null : n,
                                                      )
                                                  : null,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'Click any answered question '
                                      'to go back to it.',
                                      style: t.sm,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_toastMessage != null)
                        Positioned(
                          bottom: 108,
                          left: 24,
                          right: 24,
                          child: Center(
                            child: Toast(
                              web: true,
                              message: _toastMessage!,
                              visible: _toastVisible,
                              onUndo: _undoFlag == null
                                  ? null
                                  : () => unawaited(_toggleFlag(_undoFlag!)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _counter(int index, int total, {required bool enabled}) {
    void open() => setState(() => _gridOpen = true);
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Question ${index + 1} of $total. Open question navigator',
      onTap: enabled ? open : null,
      child: ExcludeSemantics(
        child: InkWell(
          key: const ValueKey('quiz-counter'),
          onTap: enabled ? open : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${index + 1} of $total',
                      style: context.type.subheadStrong,
                    ),
                  ),
                  const SizedBox(width: 4),
                  RotatedBox(
                    quarterTurns: 1,
                    child: Icon(
                      PantasIcons.next,
                      size: 14,
                      color: context.colors.controlOutline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runWrite(Future<void> Function() operation) async {
    final version = ++_writeVersion;
    try {
      await operation();
      if (mounted && version == _writeVersion) {
        setState(() => _retryWrite = null);
      }
    } catch (_) {
      if (mounted && version == _writeVersion) {
        setState(() => _retryWrite = () => _runWrite(operation));
      }
    }
  }

  Future<void> _check() =>
      _runWrite(() => ref.read(quizControllerProvider.notifier).check());

  Future<void> _next() => _runWrite(() async {
        await ref.read(quizControllerProvider.notifier).next();
        if (!mounted) return;
        if (_questionScroll.hasClients) _questionScroll.jumpTo(0);
        setState(() {
          _viewIndex = null;
          _poppingFlag = null;
        });
        releaseChoiceFocus(this);
      });

  void _lookAt(int? index) {
    setState(() => _viewIndex = index);
    if (_questionScroll.hasClients) _questionScroll.jumpTo(0);
    releaseChoiceFocus(this);
  }

  void _startForMode(QuizController controller) {
    switch (widget.mode) {
      case QuizPageMode.quick:
        unawaited(
          controller.start(examId: widget.examId, topicId: widget.topicId),
        );
      case QuizPageMode.today:
        unawaited(
          controller.startToday(
            examId: widget.examId,
            topicId: widget.topicId,
            prepared: widget.prepared,
          ),
        );
      case QuizPageMode.resume:
        unawaited(
          controller.resumeToday(examId: widget.examId).then((_) {
            // With no open session retrying cannot help: go back to the Quiz
            // tab. A read error keeps the retry screen.
            if (mounted &&
                ref.read(quizControllerProvider) is QuizNothingToResume) {
              _leave(context);
            }
          }),
        );
      case QuizPageMode.drill:
        final topicId = widget.topicId;
        if (topicId == null) {
          unawaited(controller.startToday(examId: widget.examId));
        } else {
          unawaited(
            controller.startDrill(examId: widget.examId, topicId: topicId),
          );
        }
      case QuizPageMode.practice:
        // Use a live prestarted run; cold routes resume only the stored row.
        final current = ref.read(quizControllerProvider);
        final hasCurrent = current is QuizRunning &&
                current.session.examId == widget.examId ||
            current is QuizComplete && current.session.examId == widget.examId;
        if (!hasCurrent) {
          unawaited(controller.resumeToday(examId: widget.examId));
        }
      case QuizPageMode.retake:
        unawaited(controller.startRetake(examId: widget.examId));
      case QuizPageMode.inline:
        final lessonId = widget.lessonId;
        if (lessonId == null) {
          unawaited(controller.startToday(examId: widget.examId));
        } else {
          unawaited(
            controller.startInline(examId: widget.examId, lessonId: lessonId),
          );
        }
    }
  }

  Future<void> _confirmLeave() async {
    if (_leaveOpen || _allowPop || !mounted) return;
    _leaveOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      barrierColor: context.colors.shadow.withValues(alpha: .34),
      builder: (dialogContext) {
        _leaveContext = dialogContext;
        return _leaveDialog(dialogContext);
      },
    );
    _leaveContext = null;
    _leaveOpen = false;
    if ((leave ?? false) && mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _leave(context);
      });
    }
  }

  /// Esc, from a page that has the focus while the dialog is open: Keep Going.
  void _dismissLeave() {
    final dialog = _leaveContext;
    if (dialog != null && dialog.mounted) Navigator.of(dialog).pop(false);
  }

  Widget _leaveDialog(BuildContext dialogContext) => context.wideWeb
      // Focus starts inside the dialog, so the keys stay with it: Esc and
      // Enter are Keep Going, the safe choice, and Tab reaches Leave.
      ? CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(dialogContext).pop(false),
          },
          child: EnterShortcut(
            onEnter: () => Navigator.of(dialogContext).pop(false),
            child: Focus(
              autofocus: true,
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: SizedBox(
                  width: 440,
                  child: WebCard(
                    radius: 22,
                    padding: const EdgeInsets.all(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const WebText(
                          'Leave this session?',
                          kind: WebTextKind.h3,
                        ),
                        const SizedBox(height: 18),
                        const WebText(
                            "Every answer you've given is already saved. "
                            'You can pick this up from the Quiz tab '
                            'whenever you like.'),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            WebButton(
                              label: 'Leave',
                              variant: WebButtonVariant.tertiary,
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                            ),
                            const SizedBox(width: 8),
                            WebButton(
                              label: 'Keep Going',
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      : CenteredDialog(
          title: 'Leave this session?',
          message: "Every answer you've given is already saved. "
              'You can pick this '
              'up from the Quiz tab whenever you like.',
          primaryLabel: 'Keep Going',
          secondaryLabel: 'Leave',
          // Board (QV_Leave): the card starts at y 300, 9 px under center.
          lift: -9,
          onConfirm: () => Navigator.of(dialogContext).pop(false),
          onCancel: () => Navigator.of(dialogContext).pop(true),
        );

  Future<void> _toggleFlag(QuestionId questionId) {
    final ids = ref.read(flaggedIdsProvider).valueOrNull ?? const <String>{};
    final flagged = !ids.contains(questionId);
    return _runWrite(() async {
      if (_flagBusy) return;
      setState(() => _flagBusy = true);
      try {
        final result = await ref
            .read(questionFlagControllerProvider.notifier)
            .setFlagged(questionId, flagged: flagged);
        if (!mounted) return;
        _toastDelay?.cancel();
        _toastHide?.cancel();
        _toastRemove?.cancel();
        setState(() {
          _toastMessage = null;
          _undoFlag = null;
          _toastVisible = false;
          _poppingFlag = result == FlagToggle.unflagged ? null : questionId;
        });
        if (result == FlagToggle.firstFlagged ||
            result == FlagToggle.unflagged) {
          _toastDelay = Timer(
              MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200), () {
            // A grid opened in the meantime keeps the spot to itself.
            if (!mounted || _gridOpen) return;
            setState(() {
              _toastVisible = true;
              _toastMessage = result == FlagToggle.firstFlagged
                  ? 'Flagged. Find it in the Quiz tab.'
                  : 'Flag removed';
              _undoFlag = result == FlagToggle.firstFlagged ? questionId : null;
            });
            _toastHide = Timer(const Duration(milliseconds: 2600), () {
              if (!mounted) return;
              setState(() => _toastVisible = false);
              _toastRemove = Timer(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _toastMessage = null;
                    _undoFlag = null;
                  });
                }
              });
            });
          });
        }
      } finally {
        if (mounted) setState(() => _flagBusy = false);
      }
    });
  }

  /// Takes the flag toast away now, with its usual fade, and for good.
  void _dropToast() {
    _toastDelay?.cancel();
    _toastHide?.cancel();
    _toastRemove?.cancel();
    setState(() {
      _toastVisible = false;
      _undoFlag = null;
    });
    _toastRemove = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  Widget _flag(String id, bool flagged, {bool web = false}) {
    // Phone boards (QV_Answer, QV_Flag): the flag on a pole, as on wide web.
    final Widget icon = WebFlagIcon(flagged: flagged);
    if (!flagged ||
        _poppingFlag != id ||
        MediaQuery.disableAnimationsOf(context)) {
      return icon;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      child: icon,
      builder: (context, value, child) {
        const curve = Cubic(.3, 1.5, .5, 1);
        final scale = value <= .5
            ? .6 + .62 * curve.transform(value * 2)
            : 1.22 - .22 * curve.transform((value - .5) * 2);
        return Transform.scale(
          key: const ValueKey('quiz-flag-pop'),
          scale: scale,
          child: child,
        );
      },
    );
  }

  /// Returns to whatever pushed this session, falling back to the Quiz tab
  /// when there is no stack to pop: a notification tap opens the route cold.
  void _leave(BuildContext context) {
    ref.invalidate(sessionPanelProvider(widget.examId));
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }
}

/// One number in the wide question navigator (board QS_Grid): tinted by how
/// it was answered, a hairline outline while unanswered, and a dark edge on
/// the question on screen. It is disabled until the question is answered.
class _WebGridCell extends StatelessWidget {
  const _WebGridCell({
    required this.number,
    required this.outcome,
    required this.onScreen,
    required this.onPressed,
    this.flagged = false,
    super.key,
  });
  final int number;
  final AnswerOutcome? outcome;
  final bool onScreen;
  final bool flagged;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final answered = outcome != null;
    final right = outcome?.isCorrect ?? false;
    final cell = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: t.style(
          15,
          weight: onScreen ? FontWeight.w700 : FontWeight.w600,
        ),
        backgroundColor: !answered
            ? t.colors.surface
            : right
                ? t.colors.accentTint
                : t.colors.wrongTint,
        disabledBackgroundColor: t.colors.surface,
        foregroundColor: !answered
            ? t.colors.tertiaryLabel
            : right
                ? t.colors.accent
                : t.colors.wrongText,
        disabledForegroundColor: t.colors.tertiaryLabel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: onScreen
              ? BorderSide(color: t.colors.label, width: 2)
              : answered
                  ? BorderSide.none
                  : BorderSide(color: t.colors.separator),
        ),
      ),
      child: Text(
        '$number',
        semanticsLabel: flagged ? '$number, flagged' : null,
      ),
    );
    if (!flagged) return cell;
    // The phone sheet marks a flagged question with a small flag on its cell;
    // the wide grid does the same, inside the cell so the grid does not
    // clip it.
    return Stack(
      children: [
        Positioned.fill(child: cell),
        Positioned(
          top: 5,
          right: 7,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Icon(
                PantasIcons.flag,
                key: const ValueKey('web-grid-flag'),
                size: 12,
                color: t.colors.label,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Keeps a wide popover on screen through its exit, with the popover motion the
/// other wide overlays use. [builder] runs only while it is open or leaving.
/// Opening it again during the exit turns it round from where it is.
class _Popover extends StatefulWidget {
  const _Popover({required this.open, required this.builder});
  final bool open;
  final WidgetBuilder builder;

  @override
  State<_Popover> createState() => _PopoverState();
}

class _PopoverState extends State<_Popover>
    with SingleTickerProviderStateMixin {
  static const _motion = WebOverlayMotion.popover;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _motion.open,
    reverseDuration: _motion.close,
    value: widget.open ? 1 : 0,
  );

  @override
  void didUpdateWidget(_Popover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.open ? 1 : 0;
    } else if (widget.open) {
      unawaited(_controller.forward());
    } else {
      unawaited(_controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!widget.open && _controller.isDismissed) {
            return const SizedBox.shrink();
          }
          return IgnorePointer(
            ignoring: !widget.open,
            child: _motion.transition(_controller, widget.builder(context)),
          );
        },
      );
}
