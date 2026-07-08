import 'dart:async';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/confirmation_dialog.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/core/ui/components/question_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/done_for_today_celebration.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/post_answer_toast.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/question_flag_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum QuizPageMode { quick, today, drill, retake, inline, resume, practice }

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    required this.examId,
    this.topicId,
    this.lessonId,
    this.mode = QuizPageMode.quick,
    this.proIsActive = false,
    super.key,
  });
  final String examId;
  final String? topicId;
  final String? lessonId;
  final QuizPageMode mode;
  final bool proIsActive;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(quizControllerProvider.notifier);
      switch (widget.mode) {
        case QuizPageMode.quick:
          controller.start(examId: widget.examId, topicId: widget.topicId);
        case QuizPageMode.today:
          controller.startToday(examId: widget.examId, topicId: widget.topicId);
        case QuizPageMode.resume:
          controller.resumeToday(examId: widget.examId);
        case QuizPageMode.drill:
          final topicId = widget.topicId;
          if (topicId == null) {
            controller.startToday(examId: widget.examId);
          } else {
            controller.startDrill(examId: widget.examId, topicId: topicId);
          }
        case QuizPageMode.practice:
          // The picker already started the session before routing here, so
          // this mode only renders it. Starting again would discard the
          // student's selection and build a different session.
          break;
        case QuizPageMode.retake:
          controller.startRetake(examId: widget.examId);
        case QuizPageMode.inline:
          final lessonId = widget.lessonId;
          if (lessonId == null) {
            controller.startToday(examId: widget.examId);
          } else {
            controller.startInline(examId: widget.examId, lessonId: lessonId);
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final state = ref.watch(quizControllerProvider);

    ref.listen(quizControllerProvider, (previous, next) {
      final outcome = _latestNewOutcome(previous, next);
      if (outcome != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(PostAnswerToast.snackBar(outcome));
      }
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: state is QuizRunning
            // The tooltips are the only label these icons carry. Without them
            // a screen reader announces an unnamed button, and the
            // accessibility plan requires every control to be labeled.
            ? IconButton(
                tooltip: 'Quit session',
                icon: Icon(Icons.close, size: 17, color: colors.inkMuted),
                onPressed: _confirmLeave,
              )
            : IconButton(
                tooltip: 'Back',
                icon: Icon(Icons.arrow_back, size: 17, color: colors.inkMuted),
                onPressed: () => _leave(context),
              ),
        actions: [
          if (state is QuizRunning) ...[
            // [context] [mark], the reader's rule. The counter takes
            // the context
            // slot so the flag never moves as the number's width changes.
            InkWell(
              onTap: () => unawaited(_openGrid(state.session)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.session.currentIndex + 1} of '
                      '${state.session.questions.length}',
                      style: styles.bodySmall.copyWith(
                        fontSize: 12.5,
                        color: colors.inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 11, color: colors.inkMuted),
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, _) {
                final flagged =
                    ref.watch(flaggedIdsProvider).valueOrNull ?? const {};
                return IconButton(
                  onPressed: () => unawaited(
                    _toggleFlag(state.session.currentQuestion.id),
                  ),
                  icon: PennantMark(
                    isSet: flagged.contains(state.session.currentQuestion.id),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (state) {
          QuizIdle() || QuizLoading() => const FaintBars(),
          QuizRunning(:final session) => Column(
              children: [
                ProgressRule(
                  value: (session.currentIndex + 1) / session.questions.length,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: QuestionCard(
                      question: session.currentQuestion,
                      onAnswer: (chosenChoiceId) => ref
                          .read(quizControllerProvider.notifier)
                          .answer(chosenChoiceId: chosenChoiceId),
                    ),
                  ),
                ),
              ],
            ),
          QuizComplete(:final attempt, :final session) =>
            DoneForTodayCelebration(
              attempt: attempt,
              session: session,
            ),
          QuizFailure(:final message) => ErrorBanner(
              variant: ErrorBannerVariant.error,
              message: message,
              actionLabel: 'Retry',
              onAction: () => ref
                  .read(quizControllerProvider.notifier)
                  .start(examId: widget.examId, topicId: widget.topicId),
            ),
        },
      ),
    );
  }

  Future<void> _openGrid(QuizSession session) async {
    // Task 7 builds the grid sheet
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
        ..showSnackBar(
          const SnackBar(content: Text('Flag removed')),
        );
    }
  }

  /// Returns to whatever pushed this session, falling back to the Quiz tab
  /// when there is no stack to pop: a notification tap opens the route cold.
  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }

  AnswerOutcome? _latestNewOutcome(
    QuizControllerState? previous,
    QuizControllerState next,
  ) {
    final previousCount = switch (previous) {
      QuizRunning(:final session) => session.outcomes.length,
      QuizComplete(:final session) => session.outcomes.length,
      _ => 0,
    };
    final nextOutcomes = switch (next) {
      QuizRunning(:final session) => session.outcomes,
      QuizComplete(:final session) => session.outcomes,
      _ => const <AnswerOutcome>[],
    };
    if (nextOutcomes.length <= previousCount || nextOutcomes.isEmpty) {
      return null;
    }
    return nextOutcomes.last;
  }
}
