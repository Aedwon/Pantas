import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
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
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

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
      if (passageState!.isLoading) return loadingFor(passageState);
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
        : _revealedQuestionPane(
            session,
            question,
            passage: passage,
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
    return ExcludeSemantics(
      excluding: !enabled,
      child: IgnorePointer(ignoring: !enabled, child: child),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startForMode(ref.read(quizControllerProvider.notifier));
    });
  }

  String? _seenSessionId;
  int? _viewIndex;
  bool _gridOpen = false;
  bool _leaveOpen = false;
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

  @override
  void dispose() {
    _toastDelay?.cancel();
    _toastHide?.cancel();
    _toastRemove?.cancel();
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
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state is QuizFailure
                ? errorFor(
                    'quiz',
                    () => _startForMode(
                      ref.read(quizControllerProvider.notifier),
                    ),
                  )
                : loadingFor(const AsyncLoading<void>()),
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                          child: bar,
                        ),
                      ],
                    );
                  }
                  return Stack(
                    children: [
                      Positioned.fill(child: scroll),
                      Positioned(left: 16, right: 16, bottom: 18, child: bar),
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
      });

  void _lookAt(int? index) {
    setState(() => _viewIndex = index);
    if (_questionScroll.hasClients) _questionScroll.jumpTo(0);
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
        unawaited(controller.resumeToday(examId: widget.examId));
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
      builder: (dialogContext) => CenteredDialog(
        title: 'Leave this session?',
        message:
            "Every answer you've given is already saved. You can pick this "
            'up from the Quiz tab whenever you like.',
        primaryLabel: 'Keep Going',
        secondaryLabel: 'Leave',
        onConfirm: () => Navigator.of(dialogContext).pop(false),
        onCancel: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    _leaveOpen = false;
    if ((leave ?? false) && mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _leave(context);
      });
    }
  }

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
            if (!mounted) return;
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

  Widget _flag(String id, bool flagged) {
    final icon = Icon(
      PantasIcons.flag,
      size: 21,
      color: flagged ? context.colors.accent : context.colors.controlOutline,
    );
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
