import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';

class ClockRule extends StatelessWidget implements PreferredSizeWidget {
  const ClockRule({
    required this.remaining,
    required this.partLength,
    super.key,
  });

  final Duration remaining;
  final Duration partLength;

  @override
  Size get preferredSize => const Size.fromHeight(1.6);

  @override
  Widget build(BuildContext context) {
    final urgency = urgencyFor(remaining);
    final fraction =
        remainingFraction(partLength: partLength, remaining: remaining);
    final colors = context.colors;

    final double height;
    final Color color;

    switch (urgency) {
      case ClockUrgency.ample:
        height = 1.0;
        color = colors.ink.withValues(alpha: 0.55);
      case ClockUrgency.closing:
        height = 1.6;
        color = colors.ink;
      case ClockUrgency.last:
        height = 1.6;
        color = colors.amber;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        key: const Key('clock-rule-fill'),
        widthFactor: fraction,
        child: Container(
          key: const Key('clock-rule-bar'),
          height: height,
          constraints: BoxConstraints(maxHeight: height),
          decoration: BoxDecoration(
            color: color,
          ),
        ),
      ),
    );
  }
}
