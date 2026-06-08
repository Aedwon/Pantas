import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    required this.current,
    required this.total,
    super.key,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current of $total',
          style: styles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 8),
        ProgressRule(value: total == 0 ? 0 : current / total),
      ],
    );
  }
}
