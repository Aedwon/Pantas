import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
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
    final asyncExams = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncExams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) {
          if (exams.isEmpty) {
            return const Center(child: Text('No exams available.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exam = exams[index];
              return _ExamCard(exam: exam);
            },
          );
        },
      ),
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
            context.go('/learn');
          },
          onStartAnyway: () async {
            await ref.read(quizNudgeRepositoryProvider).markDismissed();
            ref.invalidate(quizNudgeDismissedProvider);
            if (!sheetContext.mounted) return;
            Navigator.of(sheetContext).pop();
            if (!context.mounted) return;
            context.go('/quiz/quick/${exam.id}');
          },
        ),
      );
      return;
    }

    context.go('/quiz/quick/${exam.id}');
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
            label: 'Start Quick Quiz',
            onPressed: () => _onStartQuiz(context, ref),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Browse Lessons',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/learn'),
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
            Text('Study first for better results',
                style: textStyles.headlineSmall),
            const SizedBox(height: 12),
            Text(
              "You haven't read any lessons for this exam yet. "
              'Reading the material before quizzing helps you retain it longer.',
              style:
                  textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Read lessons',
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
