import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final assessmentResultProvider =
    FutureProvider.family<AssessmentResult?, ExamId>((ref, examId) async {
  final row =
      await ref.watch(assessmentRepositoryProvider).resultForExam(examId);
  if (row == null) return null;
  final topics =
      await ref.watch(contentRepositoryProvider).topicsByExam(examId);
  return AssessmentResult.fromRow(row, topics);
});

final _assessmentExamNameProvider =
    FutureProvider.family<String, ExamId>((ref, examId) async {
  final exams = await ref.watch(contentRepositoryProvider).listExams();
  return exams.firstWhere((exam) => exam.id == examId).name;
});

class AssessmentResultsPage extends ConsumerWidget {
  const AssessmentResultsPage({required this.examId, super.key});

  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(assessmentResultProvider(examId));
    final examName =
        ref.watch(_assessmentExamNameProvider(examId)).valueOrNull ?? examId;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: asyncResult.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(assessmentResultProvider(examId)),
          ),
        ),
        data: (result) {
          if (result == null) {
            return const Center(child: Text('No assessment found.'));
          }
          return _ResultsBody(
            result: result,
            examId: examId,
            examName: examName,
          );
        },
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.result,
    required this.examId,
    required this.examName,
  });

  final AssessmentResult result;
  final ExamId examId;
  final String examName;

  List<TopicMastery> get _weakTopics {
    final weak = result.topicMasteries
        .where((m) => m.level == MasteryLevel.weak)
        .toList();
    if (weak.isNotEmpty) return weak.take(3).toList();
    return result.topicMasteries.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final weak = _weakTopics;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your $examName Profile', style: textStyles.headlineSmall),
        const SizedBox(height: 16),
        Text('Topic Breakdown', style: textStyles.headlineSmall),
        const SizedBox(height: 12),
        for (final mastery in result.topicMasteries) ...[
          _TopicBar(mastery: mastery),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        Text('Focus Areas', style: textStyles.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Your recommendations update as you study',
          style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < weak.length; i++) ...[
          _TopicCta(mastery: weak[i], examId: examId, isFirst: i == 0),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TopicBar extends StatelessWidget {
  const _TopicBar({required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    final barColor = switch (mastery.level) {
      MasteryLevel.weak => colors.error,
      MasteryLevel.moderate => colors.warning,
      MasteryLevel.strong => colors.success,
    };
    final pct = (mastery.accuracy * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                mastery.topic.name,
                style: textStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$pct%',
              style:
                  textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: mastery.accuracy,
            backgroundColor: colors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}

class _TopicCta extends StatelessWidget {
  const _TopicCta({
    required this.mastery,
    required this.examId,
    required this.isFirst,
  });

  final TopicMastery mastery;
  final ExamId examId;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mastery.topic.name,
                  style: textStyles.headlineSmall,
                ),
              ),
              if (isFirst)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Start here',
                    style:
                        textStyles.labelSmall.copyWith(color: colors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Study →',
                  onPressed: () => context.push(
                    '/learn/topic/${mastery.topic.id}?examId=$examId',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Quiz →',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.go(
                    Uri(
                      path: '/quiz/quick/$examId',
                      queryParameters: {'topicId': mastery.topic.id},
                    ).toString(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
