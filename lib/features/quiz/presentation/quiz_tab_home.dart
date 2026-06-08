import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
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
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => _QuizError(
          message: e.toString(),
          onRetry: () => ref.invalidate(activeExamFocusProvider),
        ),
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [_ExamActions(exam: focus.exam!)],
          );
        },
      ),
    );
  }
}

class _QuizError extends StatelessWidget {
  const _QuizError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Something went wrong', style: styles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          message,
          style: styles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(label: 'Try again', secondary: true, onPressed: onRetry),
      ],
    );
  }
}

class _ChooseExamFallback extends StatelessWidget {
  const _ChooseExamFallback();

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Choose your exam', style: styles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Pick the exam you are reviewing for.',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(
          label: 'Choose exam',
          onPressed: () => context.go('/onboarding'),
        ),
      ],
    );
  }
}

class _ExamActions extends ConsumerWidget {
  const _ExamActions({required this.exam});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exam.name, style: textStyles.headlineMedium),
        const SizedBox(height: 2),
        Text(
          exam.shortName,
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(
          label: "Start today's session",
          onPressed: () => _onStartQuiz(context, ref),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'More practice'),
        InkTableRow(
          title: 'Retake mistakes',
          onTap: () => context.go('/quiz/retake/${exam.id}'),
        ),
        InkTableRow(
          title: 'Drill a topic',
          onTap: () => context.go('/quiz/drill/${exam.id}'),
        ),
        InkTableRow(
          title: 'Study plan',
          onTap: () => context.go('/plan'),
        ),
        InkTableRow(
          title: 'Study',
          bottomRule: false,
          onTap: () => context.go('/study'),
        ),
      ],
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
              style: textStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't read any lessons for this exam yet. "
              'Reading the material before quizzing helps you retain it '
              'longer.',
              style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 24),
            BoardButton(
              label: 'Study',
              onPressed: onReadLessons,
            ),
            const SizedBox(height: 8),
            BoardButton(
              label: 'Start quiz anyway',
              secondary: true,
              onPressed: onStartAnyway,
            ),
          ],
        ),
      ),
    );
  }
}
