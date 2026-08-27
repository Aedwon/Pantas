import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/assessment/domain/models/topic_mastery.dart';

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
      appBar: AppBar(title: const Text('Your results')),
      body: asyncResult.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(assessmentResultProvider(examId)),
          ),
        ),
        data: (result) {
          if (result == null) {
            return Center(
              child: Text(
                'No assessment found.',
                style: context.textStyles.bodyMedium
                    .copyWith(color: context.colors.inkMuted),
              ),
            );
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Your $examName profile', style: textStyles.displaySmall),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Topic breakdown'),
        for (final mastery in result.topicMasteries)
          _TopicRow(mastery: mastery),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Focus areas'),
        Text(
          'Your recommendations update as you study',
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < weak.length; i++)
          _FocusAreaRow(
            mastery: weak[i],
            examId: examId,
            isFirst: i == 0,
          ),
        const SizedBox(height: 16),
        BoardButton(
          label: 'Start studying',
          onPressed: () => context.go(
            '/study?topicId=${weak.first.topic.id}',
          ),
        ),
      ],
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.mastery});

  final TopicMastery mastery;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final pct = (mastery.accuracy * 100).round();
    final meterColor = switch (mastery.level) {
      MasteryLevel.weak => colors.rust,
      MasteryLevel.moderate => colors.amber,
      MasteryLevel.strong => colors.board,
    };
    final levelLabel = switch (mastery.level) {
      MasteryLevel.weak => 'Weak',
      MasteryLevel.moderate => 'Moderate',
      MasteryLevel.strong => 'Strong',
    };

    return Semantics(
      label: '${mastery.topic.name}, $pct%, $levelLabel',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.ruleFaint,
                // ignore: avoid_redundant_argument_values
                width: AppDimensions.hairline,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  mastery.topic.name,
                  style: styles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              InlineMeter(value: mastery.accuracy, color: meterColor),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '$pct%',
                  textAlign: TextAlign.right,
                  style: styles.bodySmall.copyWith(color: meterColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusAreaRow extends StatelessWidget {
  const _FocusAreaRow({
    required this.mastery,
    required this.examId,
    required this.isFirst,
  });

  final TopicMastery mastery;
  final ExamId examId;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return InkTableRow(
      title: mastery.topic.name,
      subtitle: isFirst ? 'Start here' : null,
      state: isFirst ? InkRowState.active : InkRowState.plain,
      meta: '${(mastery.accuracy * 100).round()}%',
      onTap: () => context.go(
        '/study?topicId=${mastery.topic.id}',
      ),
    );
  }
}
