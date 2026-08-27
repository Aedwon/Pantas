import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: 'Plan updated for the week',
            liveRegion: true,
            child: ExcludeSemantics(
              child: Text(
                'Plan updated for the week',
                style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ),
          ),
        ),
        Semantics(
          label: 'Dismiss plan update',
          button: true,
          onTap: onDismissed,
          child: ExcludeSemantics(
            child: IconButton(
              onPressed: onDismissed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.close, size: 16, color: colors.inkMuted),
              tooltip: 'Dismiss plan update',
            ),
          ),
        ),
      ],
    );
  }
}
