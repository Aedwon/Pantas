import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePlanCard extends StatelessWidget {
  const HomePlanCard({
    required this.view,
    super.key,
  });

  final PlanView view;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's focus", style: textStyles.labelLarge),
          const SizedBox(height: 6),
          Text(view.today.headline, style: textStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '${view.weeksToExam} weeks to exam · ${_paceLabel(view.paceStatus.name)}',
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'See plan',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/plan'),
          ),
        ],
      ),
    );
  }

  static String _paceLabel(String value) {
    return switch (value) {
      'onPace' => 'On pace',
      'behind' => 'Behind',
      'ahead' => 'Ahead',
      _ => value,
    };
  }
}
