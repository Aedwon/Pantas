import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
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
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: context.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Quiz', style: context.textStyles.headlineMedium),
      ),
      body: asyncFocus.when(
        loading: () => const PageScaffold(body: FaintBars()),
        error: (_, __) => PageScaffold(
          body: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: 'Could not load your practice. Pull down to try again.',
            actionLabel: 'Try again',
            onAction: () => ref.invalidate(activeExamFocusProvider),
          ),
        ),
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          return _QuizTabBody(exam: focus.exam!);
        },
      ),
    );
  }
}

class _ChooseExamFallback extends StatelessWidget {
  const _ChooseExamFallback();

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return PageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}

class _QuizTabBody extends ConsumerWidget {
  const _QuizTabBody({required this.exam});

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
            unawaited(context.push('/quiz/today/${exam.id}'));
          },
        ),
      );
      return;
    }

    if (!context.mounted) return;
    unawaited(context.push('/quiz/today/${exam.id}'));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      children: [
        Text(exam.shortName, style: styles.displaySmall),
        const SizedBox(height: 20),
        // The session panel and the mock panel land here in plans 2b and 2c.
        BoardButton(
          label: "Start today's session",
          onPressed: () => _onStartQuiz(context, ref),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'More ways to practice'),
        InkTableRow(
          title: 'Your mistakes',
          subtitle: "Questions you've got wrong",
          onTap: () => context.push('/quiz/retake/${exam.id}'),
        ),
        InkTableRow(
          title: 'Choose what to practice',
          subtitle: 'One topic or one lesson, your choice of length',
          bottomRule: false,
          // The practice picker is seam 3. Until it exists this row must not
          // be tappable, because a dead chevron is worse than none.
          onTap: null,
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
