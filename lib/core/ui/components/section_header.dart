import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Serif section heading with an optional trailing action on the same
/// baseline. Never boxed, never all-caps.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.action,
    this.onAction,
    this.trailing,
    super.key,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: Text(title, style: styles.headlineSmall)),
        if (trailing != null) trailing!,
        if (action != null)
          // Padding (not Center) keeps the action text on the title's
          // baseline while still reaching the 48dp minimum tap target.
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 17.5,
                horizontal: 8,
              ),
              child: Text(
                action!,
                style: styles.labelSmall.copyWith(
                  color: onAction != null ? colors.board : colors.inkMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
