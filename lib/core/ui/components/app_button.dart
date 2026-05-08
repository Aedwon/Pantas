import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
  disabled,
  loading
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final isDisabled = variant == AppButtonVariant.disabled;
    final isLoading = variant == AppButtonVariant.loading;

    final Color bgColor;
    final Color textColor;
    Border? border;
    BoxShadow? shadow;

    switch (variant) {
      case AppButtonVariant.primary || AppButtonVariant.loading:
        bgColor = colors.primary;
        textColor = Colors.white;
        shadow = BoxShadow(
          color: colors.primary.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        );
      case AppButtonVariant.secondary:
        bgColor = colors.surface;
        textColor = colors.primary;
        border = Border.all(color: colors.primary, width: 2);
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = colors.primary;
      case AppButtonVariant.destructive:
        bgColor = colors.error;
        textColor = Colors.white;
      case AppButtonVariant.disabled:
        bgColor = colors.border;
        textColor = colors.onSurfaceMuted;
    }

    final Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
      );
    } else if (leadingIcon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon!,
          const SizedBox(width: 8),
          Text(
            label,
            style: styles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600, color: textColor),
          ),
        ],
      );
    } else {
      child = Text(
        label,
        style: styles.bodyMedium
            .copyWith(fontWeight: FontWeight.w600, color: textColor),
      );
    }

    return Opacity(
      opacity: isLoading ? 0.8 : 1.0,
      child: GestureDetector(
        onTap: (isDisabled || isLoading) ? null : onPressed,
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(minHeight: AppDimensions.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: border,
            boxShadow: shadow != null ? [shadow] : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
