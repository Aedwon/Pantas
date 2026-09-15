import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/answer_reveal.dart';
import 'package:pantas/core/ui/components/back_chevron.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/confirmation_dialog.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_sheet.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/components/progress_rule.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:pantas/core/ui/components/question_grid_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/pages/debrief_page.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

enum QuizPageMode { quick, today, drill, retake, inline, resume, practice }

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    required this.examId,
    this.topicId,
    this.lessonId,
    this.mode = QuizPageMode.quick,
    this.prepared,
    this.proIsActive = false,
    super.key,
  });
  final String examId;
  final String? topicId;
  final String? lessonId;
  final QuizPageMode mode;
  final PreparedTodaySession? prepared;
  final bool proIsActive;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

String _questionStageKey(QuestionId id) => 'quiz-question-$id';

class _PreparedQuestionStage extends ConsumerStatefulWidget {
  const _PreparedQuestionStage({
    required this.proIsActive,
  });

  final bool proIsActive;

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
  QuestionId? _retiringQuestionId;
  Widget? _retiringPane;
  QuestionId? _lastVisibleQuestionId;
  Widget? _lastVisiblePane;
  bool _deferPreparationForTransition = false;
  int _transitionGeneration = 0;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    ref.read(quizControllerProvider.notifier).clearQuestionPreparation();
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
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
    if (running == null) return const FaintBars();

    final session = running.session;
    final questionShownAt = running.questionShownAt;
    _syncSession(session);

    final currentIndex = session.currentIndex;
    final question = session.currentQuestion;
    final passageId = question.passageId;
    final passageState =
        passageId != null ? ref.watch(passageByIdProvider(passageId)) : null;
    final passage = passageState?.valueOrNull;
    if (passageId != null && passage == null) {
      return const FaintBars();
    }

    final outcome = session.currentOutcome;
    if (outcome == null && questionShownAt == null) {
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

    _scheduleNextPreparationIfReady(session, questionShownAt);

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

    final children = <Widget>[];
    final retiringQuestionId = _retiringQuestionId;
    final retiringPane = _retiringPane;
    if (retiringQuestionId != null && retiringPane != null) {
      children.add(
        Offstage(
          key: ValueKey<String>(_questionStageKey(retiringQuestionId)),
          child: _interactionGate(enabled: false, child: retiringPane),
        ),
      );
    }

    children.add(
      Offstage(
        key: ValueKey<String>(_questionStageKey(question.id)),
        offstage: false,
        child: currentPane,
      ),
    );

    final preparedIndex = _preparedIndex;
    QuestionId? preparedQuestionId;
    if (preparedIndex != null &&
        preparedIndex != currentIndex &&
        preparedIndex >= 0 &&
        preparedIndex < session.questions.length) {
      final prepared = session.questions[preparedIndex];
      if (prepared.passageId == null) {
        preparedQuestionId = prepared.id;
        children.add(
          Offstage(
            key: ValueKey<String>(_questionStageKey(prepared.id)),
            child: _interactionGate(
              enabled: false,
              child: _plainQuestionPane(prepared),
            ),
          ),
        );
      }
    }

    _plainQuestionPanes.removeWhere(
      (id, _) =>
          id != question.id &&
          id != preparedQuestionId &&
          id != retiringQuestionId,
    );
    _lastVisibleQuestionId = question.id;
    _lastVisiblePane = currentPane;

    return Stack(alignment: Alignment.topLeft, children: children);
  }

  void _syncSession(QuizSession session) {
    if (_sessionId != session.sessionId) {
      _transitionGeneration += 1;
      _transitionTimer?.cancel();
      _transitionTimer = null;
      _plainQuestionPanes.clear();
      _preparedIndex = null;
      _scheduledPrepareIndex = null;
      _retiringQuestionId = null;
      _retiringPane = null;
      _lastVisibleQuestionId = null;
      _lastVisiblePane = null;
      _deferPreparationForTransition = false;
      _sessionId = session.sessionId;
      _currentIndex = session.currentIndex;
      return;
    }

    final oldIndex = _currentIndex;
    final newIndex = session.currentIndex;
    if (oldIndex != null && newIndex != oldIndex) {
      if (newIndex == oldIndex + 1 &&
          _preparedIndex == newIndex &&
          oldIndex >= 0 &&
          oldIndex < session.questions.length) {
        final oldQuestion = session.questions[oldIndex];
        if (_lastVisibleQuestionId == oldQuestion.id &&
            _lastVisiblePane != null) {
          _retiringQuestionId = oldQuestion.id;
          _retiringPane = _lastVisiblePane;
          _deferPreparationForTransition = true;
          _scheduleTransitionHousekeeping(
            sessionId: session.sessionId,
            currentIndex: newIndex,
          );
        }
      } else {
        _transitionGeneration += 1;
        _transitionTimer?.cancel();
        _transitionTimer = null;
        _preparedIndex = null;
        _scheduledPrepareIndex = null;
        _retiringQuestionId = null;
        _retiringPane = null;
        _deferPreparationForTransition = false;
      }
    }
    _currentIndex = newIndex;
  }

  void _scheduleTransitionHousekeeping({
    required String sessionId,
    required int currentIndex,
  }) {
    final generation = ++_transitionGeneration;
    _transitionTimer?.cancel();
    _transitionTimer = Timer(const Duration(milliseconds: 120), () {
      _transitionTimer = null;
      if (!mounted || generation != _transitionGeneration) return;

      final state = ref.read(quizControllerProvider);
      if (state is! QuizRunning ||
          state.session.sessionId != sessionId ||
          state.session.currentIndex != currentIndex) {
        return;
      }

      setState(() {
        _retiringQuestionId = null;
        _retiringPane = null;
        if (_preparedIndex == currentIndex) {
          _preparedIndex = null;
        }
        _deferPreparationForTransition = false;
      });
    });
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

  Widget _plainQuestionPane(Question question, {Passage? passage}) {
    return _plainQuestionPanes.putIfAbsent(
      question.id,
      () => QuestionCard(
        question: question,
        passage: passage,
        onAnswer: (chosenChoiceId) => ref
            .read(quizControllerProvider.notifier)
            .answer(chosenChoiceId: chosenChoiceId),
      ),
    );
  }

  Widget _revealedQuestionPane(
    QuizSession session,
    Question question, {
    Passage? passage,
  }) {
    final outcome = session.currentOutcome!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionCard(
          question: question,
          passage: passage,
          chosenChoiceId: outcome.chosenChoiceId,
          revealed: true,
          onAnswer: null,
        ),
        AnswerReveal(
          question: question,
          chosenChoiceId: outcome.chosenChoiceId,
          proIsActive: widget.proIsActive,
          nextReviewIntervalDays: outcome.nextReviewIntervalDays,
        ),
      ],
    );
  }

  Widget _interactionGate({required bool enabled, required Widget child}) {
    return ExcludeSemantics(
      excluding: !enabled,
      child: IgnorePointer(ignoring: !enabled, child: child),
    );
  }
}

class _QuizAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _QuizAppBar({
    required this.onConfirmLeave,
    required this.onBack,
    required this.onOpenGrid,
    required this.onToggleFlag,
  });

  final VoidCallback onConfirmLeave;
  final VoidCallback onBack;
  final Future<void> Function(QuizSession session) onOpenGrid;
  final Future<void> Function(QuestionId questionId) onToggleFlag;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;
    final session = ref.watch(
      quizControllerProvider.select(
        (state) => state is QuizRunning ? state.session : null,
      ),
    );

    return AppBar(
      toolbarHeight: 56,
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: session != null
          ? IconButton(
              tooltip: 'Quit session',
              icon: Icon(Icons.close, size: 17, color: colors.inkMuted),
              onPressed: onConfirmLeave,
            )
          : IconButton(
              tooltip: 'Back',
              icon: BackChevron(color: colors.inkMuted),
              onPressed: onBack,
            ),
      actions: [
        if (session != null) ...[
          Semantics(
            button: true,
            enabled: true,
            label: 'Question ${session.currentIndex + 1} of '
                '${session.questions.length}. '
                'Open question navigator',
            onTap: () => unawaited(onOpenGrid(session)),
            child: ExcludeSemantics(
              child: InkWell(
                onTap: () => unawaited(onOpenGrid(session)),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${session.currentIndex + 1} of '
                          '${session.questions.length}',
                          style: styles.bodySmall.copyWith(
                            fontSize: 12.5,
                            color: colors.inkMuted,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more,
                          size: 11,
                          color: colors.inkMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final flagged =
                  ref.watch(flaggedIdsProvider).valueOrNull ?? const {};
              final isFlagged = flagged.contains(session.currentQuestion.id);
              final questionNumber = session.currentIndex + 1;
              void toggle() =>
                  unawaited(onToggleFlag(session.currentQuestion.id));
              return Semantics(
                button: true,
                enabled: true,
                toggled: isFlagged,
                label: isFlagged
                    ? 'Remove flag from question $questionNumber'
                    : 'Flag question $questionNumber',
                onTap: toggle,
                child: ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: 48,
                    child: IconButton(
                      onPressed: toggle,
                      icon: PennantMark(isSet: isFlagged),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _QuizBody extends ConsumerWidget {
  const _QuizBody({
    required this.proIsActive,
    required this.onRetry,
  });

  final bool proIsActive;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateType = ref.watch(
      quizControllerProvider.select((state) => state.runtimeType),
    );
    if (stateType == QuizRunning) {
      return _RunningQuizBody(proIsActive: proIsActive);
    }

    final state = ref.watch(quizControllerProvider);
    return switch (state) {
      QuizIdle() || QuizLoading() => const FaintBars(),
      QuizRunning() => _RunningQuizBody(proIsActive: proIsActive),
      QuizComplete(:final attempt, :final session) => DebriefPage(
          attemptId: attempt.id,
          proIsActive: proIsActive,
          sessionOverride: session,
          attemptOverride: attempt,
        ),
      QuizFailure(:final message) => ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: message,
          actionLabel: 'Retry',
          onAction: onRetry,
        ),
    };
  }
}

class _RunningQuizBody extends StatelessWidget {
  const _RunningQuizBody({required this.proIsActive});

  final bool proIsActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _QuizProgress(),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PreparedQuestionStage(proIsActive: proIsActive),
          ),
        ),
        const _QuizFooter(),
      ],
    );
  }
}

class _QuizProgress extends ConsumerWidget {
  const _QuizProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      quizControllerProvider.select(
        (state) => state is QuizRunning
            ? (
                currentIndex: state.session.currentIndex,
                total: state.session.questions.length,
              )
            : null,
      ),
    );
    if (progress == null) return const SizedBox.shrink();
    return ProgressRule(
      value: (progress.currentIndex + 1) / progress.total,
    );
  }
}

class _QuizFooter extends ConsumerWidget {
  const _QuizFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footer = ref.watch(
      quizControllerProvider.select(
        (state) => state is QuizRunning
            ? (
                visible: state.session.currentOutcome != null,
                complete: state.session.isComplete,
              )
            : null,
      ),
    );
    if (footer == null || !footer.visible) {
      return const SizedBox.shrink();
    }
    return BoardButton(
      label: footer.complete ? 'Done' : 'Next',
      secondary: !footer.complete,
      onPressed: () => unawaited(
        ref.read(quizControllerProvider.notifier).next(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _QuizAppBar(
        onConfirmLeave: () => unawaited(_confirmLeave()),
        onBack: () => _leave(context),
        onOpenGrid: _openGrid,
        onToggleFlag: _toggleFlag,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _QuizBody(
          proIsActive: widget.proIsActive,
          onRetry: () =>
              _startForMode(ref.read(quizControllerProvider.notifier)),
        ),
      ),
    );
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
        // Picker-owned sessions are already persisted before this renderer is
        // entered. Recreating one here would lose the original picked scope.
        break;
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

  /// The counter in the app bar opens the session, so a student can see
  /// what is left and go back to anything they have answered.
  Future<void> _openGrid(QuizSession session) async {
    final flagged = ref.read(flaggedIdsProvider).valueOrNull ?? const {};

    final target = await showInkSheet<int>(
      context: context,
      builder: (sheetContext) => QuestionGridSheet(
        columns: 5,
        cells: [
          for (var i = 0; i < session.questions.length; i += 1)
            GridCell(
              number: i + 1,
              mark: i < session.outcomes.length
                  ? (session.outcomes[i].isCorrect
                      ? GridCellMark.correct
                      : GridCellMark.wrong)
                  : GridCellMark.none,
              isFlagged: flagged.contains(session.questions[i].id),
              isCurrent: i == session.currentIndex,
              // Only what has been answered, and the question on screen.
              // Jumping ahead would skip questions the scheduler has not
              // been told about.
              isEnabled:
                  i <= session.outcomes.length && i < session.questions.length,
            ),
        ],
        onTap: (number) => Navigator.of(sheetContext).pop(number - 1),
      ),
    );

    if (target == null) return;
    await ref.read(quizControllerProvider.notifier).goTo(target);
  }

  Future<void> _confirmLeave() async {
    // Leaving does not quit the session: the row stays open, which is what
    // makes the tab's "Still going" state true and what the copy promises.
    await showAppConfirmationDialog(
      context: context,
      title: 'Leave this session?',
      body: "Every answer you've given is already saved. You can pick this "
          'up from the Quiz tab whenever you like.',
      cancelLabel: 'Keep going',
      confirmLabel: 'Leave',
      isDestructive: false,
      onCancel: () {},
      onConfirm: () => _leave(context),
    );
  }

  Future<void> _toggleFlag(QuestionId questionId) async {
    final toggleResult = await ref
        .read(questionFlagControllerProvider.notifier)
        .toggle(questionId);

    if (!mounted) return;

    if (toggleResult == FlagToggle.firstFlagged) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Flagged. Find it in the Quiz tab.'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                unawaited(
                  ref
                      .read(questionFlagControllerProvider.notifier)
                      .toggle(questionId),
                );
              },
            ),
          ),
        );
    } else if (toggleResult == FlagToggle.unflagged) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Flag removed')));
    }
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
