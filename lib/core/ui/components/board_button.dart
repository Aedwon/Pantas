import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Flat identity button. Board green is budgeted: at most one primary
/// BoardButton per screen.
class BoardButton extends StatelessWidget {
  const BoardButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.textStyles.labelLarge;
    final enabled = onPressed != null;
    if (secondary) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: AppDimensions.minTapTarget),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: style.copyWith(
                  color: enabled ? colors.board : colors.inkMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        // Ink (not DecoratedBox) so the fill is an ink decoration: splashes
        // paint above it instead of being hidden beneath an opaque box.
        child: Ink(
          decoration: BoxDecoration(
            color: enabled ? colors.board : colors.ruleFaint,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
          child: Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(minHeight: AppDimensions.minTapTarget),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              label,
              style: style.copyWith(
                color: enabled ? colors.onBoard : colors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
