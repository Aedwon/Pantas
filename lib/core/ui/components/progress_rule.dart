import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// 3px board-green progress line on a faint track.
class ProgressRule extends StatelessWidget {
  const ProgressRule({required this.value, super.key});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // clamp on a double receiver returns double; no toDouble() needed.
    final factor = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.progressHeight / 2),
      child: Container(
        height: AppDimensions.progressHeight,
        width: double.infinity,
        color: colors.ruleFaint,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: factor,
          child: Container(
            decoration: BoxDecoration(color: colors.board),
          ),
        ),
      ),
    );
  }
}
