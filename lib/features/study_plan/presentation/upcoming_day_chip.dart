import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';

class UpcomingDayChip extends StatelessWidget {
  const UpcomingDayChip({
    required this.day,
    super.key,
  });

  final UpcomingPlanDay day;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(day.focusLabel, style: textStyles.bodyMedium),
          ),
          Text(
            day.isRestDay ? 'Rest' : '${day.estimatedQuestionCount} questions',
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
