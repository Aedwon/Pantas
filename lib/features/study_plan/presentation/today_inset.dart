import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ruled_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';

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
    final breakdown = [
      '${plan.reviewCount} reviews',
      if (plan.lessonId != null) '1 lesson',
      if (plan.drillTopicName != null) '${plan.drillTopicName} drill',
    ].join(' · ');

    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.headline, style: textStyles.headlineMedium),
          const SizedBox(height: 6),
          Text(
            plan.why,
            style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 6),
          Text(
            breakdown,
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          BoardButton(label: "Start today's session", onPressed: onStart),
        ],
      ),
    );
  }
}
