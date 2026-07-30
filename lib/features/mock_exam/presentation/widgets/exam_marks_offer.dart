import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ExamMarksOffer extends StatelessWidget {
  const ExamMarksOffer({
    required this.count,
    required this.onKeepAll,
    required this.onDismiss,
    super.key,
  });

  final int count;
  final VoidCallback onKeepAll;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.rule),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You marked $count to come back to while the clock was '
            'running. Keep them to practice?',
            style: styles.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BoardButton(
                  label: 'Flag all $count',
                  onPressed: onKeepAll,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BoardButton(
                  label: 'No thanks',
                  onPressed: onDismiss,
                  secondary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
