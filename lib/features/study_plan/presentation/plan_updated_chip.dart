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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          'Plan updated for the week',
          style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
        ),
      ),
    );
  }
}
