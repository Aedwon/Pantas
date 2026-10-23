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
  Size get preferredSize => const Size.fromHeight(5);

  @override
  Widget build(BuildContext context) {
    final urgency = urgencyFor(remaining);
    final fraction =
        remainingFraction(partLength: partLength, remaining: remaining);
    final colors = context.colors;

    const height = 5.0;
    final color = switch (urgency) {
      ClockUrgency.ample => colors.accentFill,
      ClockUrgency.closing => colors.warningText,
      ClockUrgency.last => colors.wrongText,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          key: const Key('clock-rule-fill'),
          widthFactor: fraction,
          child: Container(
            key: const Key('clock-rule-bar'),
            height: height,
            constraints: const BoxConstraints(maxHeight: height),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}
