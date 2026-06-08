import 'package:cse_cet_reviewer/core/ui/components/confirmation_dialog.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/question_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/quiz_progress_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/done_for_today_celebration.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/post_answer_toast.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum QuizPageMode { quick, today, drill, retake, inline }

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({
    required this.examId,
    this.topicId,
    this.lessonId,
    this.mode = QuizPageMode.quick,
    super.key,
  });
  final String examId;
  final String? topicId;
  final String? lessonId;
  final QuizPageMode mode;

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
        case QuizPageMode.drill:
          final topicId = widget.topicId;
          if (topicId == null) {
            controller.startToday(examId: widget.examId);
          } else {
            controller.startDrill(examId: widget.examId, topicId: topicId);
          }
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
        title: Text(_titleFor(widget.mode)),
        leading: state is QuizRunning
            ? IconButton(
                tooltip: 'Quit session',
                icon: const Icon(Icons.close),
                onPressed: () => _confirmQuit(context, ref),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (state) {
          QuizIdle() || QuizLoading() => const SkeletonCard(),
          QuizRunning(:final session) => Column(
              children: [
                QuizProgressBar(
                  current: session.currentIndex + 1,
                  total: session.questions.length,
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

  String _titleFor(QuizPageMode mode) => switch (mode) {
        QuizPageMode.quick => 'Quick Quiz',
        QuizPageMode.today => "Today's Session",
        QuizPageMode.drill => 'Drill',
        QuizPageMode.retake => 'Retake Mistakes',
        QuizPageMode.inline => 'Quiz yourself',
      };

  Future<void> _confirmQuit(BuildContext context, WidgetRef ref) {
    return showAppConfirmationDialog(
      context: context,
      title: 'Quit session?',
      body: 'Your progress is saved.',
      cancelLabel: 'Keep going',
      confirmLabel: 'Quit',
      onCancel: () {},
      onConfirm: () {
        ref.read(quizControllerProvider.notifier).reset();
        context.go('/quiz');
      },
    );
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
