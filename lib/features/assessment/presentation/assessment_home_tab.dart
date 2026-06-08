import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_result_providers.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/home_atom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssessmentHomeTab extends ConsumerWidget {
  const AssessmentHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncFocus.when(
          loading: () => const _HomeLoading(),
          error: (e, _) => _HomeError(
            message: e.toString(),
            onRetry: () => ref.invalidate(activeExamFocusProvider),
          ),
          data: (focus) {
            if (focus.needsSelection || focus.exam == null) {
              return const _ChooseExamHome();
            }
            return _SelectedExamHome(
              examId: focus.exam!.id,
              examShortName: focus.exam!.shortName,
            );
          },
        ),
      ),
    );
  }
}

String _greeting(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Magandang umaga,';
  if (h < 18) return 'Magandang hapon,';
  return 'Magandang gabi,';
}

class _SelectedExamHome extends ConsumerWidget {
  const _SelectedExamHome({
    required this.examId,
    required this.examShortName,
  });

  final ExamId examId;
  final String examShortName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final asyncResult = ref.watch(assessmentResultProvider(examId));

    final now = DateTime.now();
    final localDate = DateTime(now.year, now.month, now.day);
    final chip = ref
        .watch(
          homeAtomProvider(
            HomeAtomRequest(
              examId: examId,
              userId: 'local',
              localDate: localDate,
              now: localDate.add(const Duration(hours: 23, minutes: 59)),
            ),
          ),
        )
        .valueOrNull;

    return asyncResult.when(
      loading: () => const _HomeLoading(),
      error: (e, _) => _HomeError(
        message: e.toString(),
        onRetry: () => ref.invalidate(assessmentResultProvider(examId)),
      ),
      data: (result) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(DateTime.now()),
                      style:
                          styles.bodySmall.copyWith(color: colors.inkMuted),
                    ),
                    const SizedBox(height: 1),
                    Text(examShortName, style: styles.displaySmall),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: colors.inkMuted,
                ),
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (result != null) ...[
            _HomeStatsBand(result: result),
            const SizedBox(height: 12),
          ],
          if (chip != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colors.rule,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                ),
              ),
              child: Text.rich(
                TextSpan(
                  text: 'Lately — ',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  children: [
                    TextSpan(text: chip.text),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (result == null)
            _NoAssessmentHome(examId: examId)
          else
            _FocusTopics(result: result, examId: examId),
        ],
      ),
    );
  }
}

class _HomeStatsBand extends StatelessWidget {
  const _HomeStatsBand({required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    final masteries = result.topicMasteries;
    final totalCorrect =
        masteries.fold<int>(0, (sum, m) => sum + m.correct);
    final totalQuestions = masteries.fold<int>(0, (sum, m) => sum + m.total);
    final accuracyPct =
        totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions * 100).round();
    final strongCount =
        masteries.where((m) => m.level == MasteryLevel.strong).length;

    return StatsBand(
      figures: [
        StatFigure(value: '$accuracyPct%', label: 'accuracy'),
        StatFigure(
          value: '$strongCount',
          suffix: '/${masteries.length}',
          label: 'topics strong',
        ),
      ],
    );
  }
}

class _FocusTopics extends StatelessWidget {
  const _FocusTopics({required this.result, required this.examId});

  final AssessmentResult result;
  final ExamId examId;

  @override
  Widget build(BuildContext context) {
    final topics = result.topicMasteries.take(3).toList();
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Focus topics',
          action: 'View results',
          onAction: () => context.go('/assessment/$examId/results'),
        ),
        for (final mastery in topics)
          _FocusTopicRow(mastery: mastery, examId: examId),
        const SizedBox(height: 16),
        BoardButton(
          label: 'Continue studying',
          onPressed: () => context.go(_studyPath(topics.first)),
        ),
      ],
    );
  }

  String _studyPath(TopicMastery mastery) {
    return mastery.level == MasteryLevel.strong
        ? Uri(
            path: '/quiz/quick/$examId',
            queryParameters: {'topicId': mastery.topic.id},
          ).toString()
        : '/study/topic/${mastery.topic.id}?examId=$examId';
  }
}

class _FocusTopicRow extends StatelessWidget {
  const _FocusTopicRow({required this.mastery, required this.examId});

  final TopicMastery mastery;
  final ExamId examId;

  @override
  Widget build(BuildContext context) {
    final path = mastery.level == MasteryLevel.strong
        ? Uri(
            path: '/quiz/quick/$examId',
            queryParameters: {'topicId': mastery.topic.id},
          ).toString()
        : '/study/topic/${mastery.topic.id}?examId=$examId';
    return InkTableRow(
      title: mastery.topic.name,
      meta: '${(mastery.accuracy * 100).round()}%',
      onTap: () => context.go(path),
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
          onPressed: () => context.go('/assessment/$examId'),
        ),
        const SizedBox(height: 10),
        BoardButton(
          label: 'Try a quick quiz',
          secondary: true,
          onPressed: () => context.go('/quiz/quick/$examId'),
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
  const _HomeError({required this.message, required this.onRetry});

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
        BoardButton(
          label: 'Try again',
          secondary: true,
          onPressed: onRetry,
        ),
      ],
    );
  }
}
