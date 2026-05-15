import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/question_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/quiz_progress_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({required this.examId, super.key});
  final String examId;

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizControllerProvider.notifier).start(examId: widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizControllerProvider);
    ref.listen(quizControllerProvider, (_, next) {
      if (next is QuizComplete) {
        context.go('/quiz/results/${next.attempt.id}');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Quiz')),
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
          QuizComplete(:final attempt) => EmptyState(
              illustration: '⏳',
              headline: 'Wrapping up…',
              body: 'Loading your results.',
              ctaLabel: 'Continue',
              onCta: () => context.go('/quiz/results/${attempt.id}'),
            ),
          QuizFailure(:final message) => ErrorBanner(
              variant: ErrorBannerVariant.error,
              message: message,
              actionLabel: 'Retry',
              onAction: () => ref
                  .read(quizControllerProvider.notifier)
                  .start(examId: widget.examId),
            ),
        },
      ),
    );
  }
}
