// lib/features/home/presentation/widgets/home_stats_band.dart
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_result_providers.dart';
import 'package:cse_cet_reviewer/features/home/presentation/home_providers.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/home_atom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeStatsBand extends ConsumerWidget {
  const HomeStatsBand({
    required this.examId,
    required this.now,
    super.key,
  });

  final ExamId examId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;

    final result = ref.watch(assessmentResultProvider(examId)).valueOrNull;
    if (result == null) return const SizedBox.shrink();

    final masteries = result.topicMasteries;
    final totalCorrect = masteries.fold<int>(0, (sum, m) => sum + m.correct);
    final totalQuestions = masteries.fold<int>(0, (sum, m) => sum + m.total);
    final accuracyPct =
        totalQuestions == 0 ? 0 : (totalCorrect / totalQuestions * 100).round();

    final lessonsRead = ref.watch(lessonsReadProvider(examId)).valueOrNull ??
        const LessonsRead(read: 0, total: 0);

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatsBand(
          centred: true,
          figures: [
            StatFigure(value: '$accuracyPct%', label: 'accuracy'),
            StatFigure(
              value: '${lessonsRead.read}',
              suffix: '/${lessonsRead.total}',
              label: 'lessons read',
            ),
          ],
        ),
        if (chip != null && chip.text.isNotEmpty)
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
                text: 'Lately: ',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
                children: [
                  TextSpan(
                    text: chip.text,
                    style: styles.bodySmall,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
