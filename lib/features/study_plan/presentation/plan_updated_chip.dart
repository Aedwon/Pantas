import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PlanUpdatedChip extends StatelessWidget {
  const PlanUpdatedChip({
    required this.onDismissed,
    super.key,
  });

  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return GestureDetector(
      onTap: onDismissed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Text(
            'Plan updated for the week',
            style: textStyles.bodySmall.copyWith(color: colors.success),
          ),
        ),
      ),
    );
  }
}
