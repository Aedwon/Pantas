import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact meter for score contexts (weak areas). Caller supplies the
/// semantic color per the budget: rust, amber, or board.
class InlineMeter extends StatelessWidget {
  const InlineMeter({
    required this.value,
    required this.color,
    super.key,
    this.width = 70,
  });

  final double value;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    // clamp on a double receiver returns double; no toDouble() needed.
    final factor = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      height: AppDimensions.progressHeight,
      child: Container(
        color: context.colors.ruleFaint,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: factor,
          child: Container(decoration: BoxDecoration(color: color)),
        ),
      ),
    );
  }
}
