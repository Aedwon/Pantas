import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/exam_name_line.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/tab_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/practice_row_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/widgets/session_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({this.mockPanel, super.key});

  /// Built by the router, which is the only layer allowed to see both this
  /// feature and `features/mock_exam`. Null in tests and while the exam is
  /// still loading.
  final Widget? mockPanel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    // The header sits above the list rather than in an AppBar, which is how
    // Study already did it and is what makes all three tabs start at the same
    // distance from the top.
    return Scaffold(
      backgroundColor: context.colors.background,
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
          return _QuizTabBody(exam: focus.exam!, mockPanel: mockPanel);
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
  const _QuizTabBody({required this.exam, this.mockPanel});

  final Exam exam;
  final Widget? mockPanel;

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
    final mistakes = ref.watch(recentMistakeCountProvider(exam.id)).valueOrNull;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TabHeader(title: 'Quiz'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                ExamNameLine(exam.shortName),
                SessionPanel(
                  exam: exam,
                  onStart: () => _onStartQuiz(context, ref),
                ),
                if (mockPanel != null) mockPanel!,
                // The panels above are the tab's own work. This is a list
                // of doors to somewhere else, and it needs the air to say so.
                const SizedBox(height: 28),
                const SectionHeader(title: 'More ways to practice'),
                InkTableRow(
                  title: 'Your mistakes',
                  subtitle: mistakes == null
                      ? ''
                      : mistakes == 0
                          ? 'Nothing to fix yet'
                          : "$mistakes you've got wrong in the last month",
                  // Dimmed with no chevron when empty: a door with
                  // nothing behind it should not invite a tap.
                  onTap: mistakes == null || mistakes == 0
                      ? null
                      : () => context.push('/quiz/retake/${exam.id}'),
                ),
                InkTableRow(
                  title: 'Choose what to practice',
                  subtitle: 'One topic or one lesson, your choice of length',
                  bottomRule: false,
                  onTap: () => context.push('/quiz/practice/${exam.id}'),
                ),
                const SizedBox(height: 28),
                _FlaggedSection(exam: exam),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlaggedSection extends ConsumerWidget {
  const _FlaggedSection({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final summary = ref.watch(flagSummaryProvider).valueOrNull;
    if (summary == null) return const SizedBox.shrink();

    // The count sits in the heading's trailing slot rather than in the row,
    // so the section reads as a tally before the student reads the row at all.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Flagged',
          trailing: summary.count == 0
              ? null
              : Text('${summary.count}', style: styles.headlineSmall),
        ),
        InkTableRow(
          title: summary.count == 0
              ? 'Flag anything you want to come back to'
              : 'Questions you flagged',
          subtitle: summary.count == 0
              ? ''
              : '${summary.count} kept, across ${summary.topicCount} '
                  '${summary.topicCount == 1 ? 'topic' : 'topics'}',
          bottomRule: false,
          onTap: summary.count == 0
              ? null
              : () {
                  final focus = ref.read(activeExamFocusProvider).valueOrNull;
                  final exam = focus?.exam;
                  if (exam != null) {
                    context.push('/quiz/flagged/${exam.id}');
                  }
                },
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
