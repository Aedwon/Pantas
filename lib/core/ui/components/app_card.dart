import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppCardVariant { plain, accent, gradient }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.plain,
    this.gradient,
    this.padding,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Border? border;
    var bgColor = colors.surface;
    Gradient? resolvedGradient;

    switch (variant) {
      case AppCardVariant.plain:
        border = Border.all(color: colors.border);
      case AppCardVariant.accent:
        border = Border(
          top: BorderSide(color: colors.primary, width: 3),
          left: BorderSide(color: colors.border),
          right: BorderSide(color: colors.border),
          bottom: BorderSide(color: colors.border),
        );
      case AppCardVariant.gradient:
        resolvedGradient = gradient;
        bgColor = Colors.transparent;
        border = null;
    }

    final radius = BorderRadius.circular(AppDimensions.radiusLG);
    final hasNonUniformBorder =
        variant == AppCardVariant.accent && border != null;

    if (hasNonUniformBorder) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          padding: padding ?? const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            border: border,
            boxShadow: const [AppDimensions.shadowSM],
          ),
          child: child,
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: resolvedGradient == null ? bgColor : null,
        gradient: resolvedGradient,
        borderRadius: radius,
        border: border,
        boxShadow: const [AppDimensions.shadowSM],
      ),
      child: child,
    );
  }
}
