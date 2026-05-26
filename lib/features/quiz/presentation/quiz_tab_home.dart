import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncFocus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [_ExamCard(exam: focus.exam!)],
          );
        },
      ),
    );
  }
}

class _ChooseExamFallback extends StatelessWidget {
  const _ChooseExamFallback();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your exam', style: textStyles.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Pick the exam you are reviewing for.',
                style: textStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Choose exam',
                onPressed: () => context.go('/onboarding'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExamCard extends ConsumerWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  Future<void> _onStartQuiz(BuildContext context, WidgetRef ref) async {
    final isDismissed = await ref.read(quizNudgeDismissedProvider.future);
    final anyRead = await ref.read(anyLessonReadProvider.future);

    if (!isDismissed && !anyRead) {
      if (!context.mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => _QuizNudgeSheet(
          onReadLessons: () {
            Navigator.of(sheetContext).pop();
            context.go('/study');
          },
          onStartAnyway: () async {
            await ref.read(quizNudgeRepositoryProvider).markDismissed();
            ref.invalidate(quizNudgeDismissedProvider);
            if (!sheetContext.mounted) return;
            Navigator.of(sheetContext).pop();
            if (!context.mounted) return;
            context.go('/quiz/today/${exam.id}');
          },
        ),
      );
      return;
    }

    if (!context.mounted) return;
    context.go('/quiz/today/${exam.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.name,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            exam.shortName,
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: "Start Today's Session",
            onPressed: () => _onStartQuiz(context, ref),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Study Plan',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/plan'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Retake Mistakes',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/quiz/retake/${exam.id}'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Drill a topic',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/quiz/drill/${exam.id}'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Study',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/study'),
          ),
        ],
      ),
    );
  }
}

class _QuizNudgeSheet extends StatelessWidget {
  const _QuizNudgeSheet({
    required this.onReadLessons,
    required this.onStartAnyway,
  });

  final VoidCallback onReadLessons;
  final VoidCallback onStartAnyway;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study first for better results',
              style: textStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't read any lessons for this exam yet. "
              'Reading the material before quizzing helps you retain it '
              'longer.',
              style:
                  textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Study',
              onPressed: onReadLessons,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Start quiz anyway',
              variant: AppButtonVariant.secondary,
              onPressed: onStartAnyway,
            ),
          ],
        ),
      ),
    );
  }
}
