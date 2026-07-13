// lib/features/home/presentation/home_tab.dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_result_providers.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/home_masthead.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/home_stats_band.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/practice_panel.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/tendencies_panel.dart';
import 'package:cse_cet_reviewer/features/home/presentation/widgets/up_next_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncFocus.when(
          loading: () => const _HomeLoading(),
          error: (_, __) => _HomeError(
            onRetry: () => ref.invalidate(activeExamFocusProvider),
          ),
          data: (focus) {
            if (focus.needsSelection || focus.exam == null) {
              return const _ChooseExamHome();
            }
            return _SelectedExamHome(
              examId: focus.exam!.id,
            );
          },
        ),
      ),
    );
  }
}

class _SelectedExamHome extends ConsumerWidget {
  const _SelectedExamHome({required this.examId});

  final ExamId examId;

  Widget _upNextPanel(BuildContext context, WidgetRef ref) =>
      const UpNextPanel();

  Widget _practicePanel(BuildContext context, WidgetRef ref) =>
      const PracticePanel();

  Widget _tendenciesPanel(BuildContext context, WidgetRef ref) =>
      const TendenciesPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(assessmentResultProvider(examId));
    final now = DateTime.now();

    return asyncResult.when(
      loading: () => const _HomeLoading(),
      error: (_, __) => _HomeError(
        onRetry: () => ref.invalidate(assessmentResultProvider(examId)),
      ),
      data: (result) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          HomeMasthead(now: now),
          const SizedBox(height: 16),
          if (result == null)
            _NoAssessmentHome(examId: examId)
          else ...[
            HomeStatsBand(examId: examId, now: now),
            const SizedBox(height: 16),
            // Block order, spec Section 3. Each stub is replaced by exactly
            // one later plan; do not reorder them.
            _upNextPanel(context, ref), // Home plan 4
            _practicePanel(context, ref), // Home plan 5
            _tendenciesPanel(context, ref), // Home plan 6
          ],
        ],
      ),
    );
  }
}

class _ChooseExamHome extends StatelessWidget {
  const _ChooseExamHome();

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
          label: 'Get started',
          onPressed: () => context.go('/onboarding'),
        ),
      ],
    );
  }
}

class _NoAssessmentHome extends StatelessWidget {
  const _NoAssessmentHome({required this.examId});

  final ExamId examId;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Build your study plan', style: styles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Take the assessment to find what to study first.',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(
          label: 'Start the assessment',
          onPressed: () => context.push('/assessment/$examId'),
        ),
        const SizedBox(height: 10),
        BoardButton(
          label: 'Try a quick quiz',
          secondary: true,
          onPressed: () => context.push('/quiz/quick/$examId'),
        ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: const [FaintBars()],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Could not load your home. Pull down to try again.',
          actionLabel: 'Try again',
          onAction: onRetry,
        ),
      ],
    );
  }
}
