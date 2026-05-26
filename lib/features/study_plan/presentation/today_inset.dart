import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';

class TodayInset extends StatelessWidget {
  const TodayInset({
    required this.plan,
    required this.onStart,
    super.key,
  });

  final TodayPlan plan;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.headline, style: textStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            plan.why,
            style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BreakdownChip('${plan.reviewCount} reviews'),
              if (plan.lessonId != null) const _BreakdownChip('1 lesson'),
              if (plan.drillTopicName != null)
                _BreakdownChip('${plan.drillTopicName} drill'),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: "Start today's session",
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: textStyles.bodySmall),
      ),
    );
  }
}
