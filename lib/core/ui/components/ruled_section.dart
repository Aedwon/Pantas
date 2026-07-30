import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The card replacement: a flat content block bounded by a 1px hairline.
/// Depth comes from rules, never shadows.
class RuledSection extends StatelessWidget {
  const RuledSection({
    required this.child,
    this.topRule = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    super.key,
  });

  final Widget child;
  final bool topRule;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        border: topRule
            ? Border(
                top: BorderSide(
                  color: context.colors.rule,
                  // ignore: avoid_redundant_argument_values
                  width: AppDimensions.hairline,
                ),
              )
            : null,
      ),
      child: child,
    );
  }
}
