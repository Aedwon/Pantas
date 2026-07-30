import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';

class MockResumeSheet extends StatelessWidget {
  const MockResumeSheet({
    required this.attempt,
    required this.onResume,
    required this.onDiscard,
    super.key,
  });

  final MockAttempt attempt;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final remainingSeconds =
        (attempt.durationMinutes * 60) - attempt.elapsedSeconds;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(attempt.blueprintName, style: textStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Elapsed ${_format(attempt.elapsedSeconds)} · '
              'Remaining ${_format(remainingSeconds)}',
              style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: 16),
            BoardButton(label: 'Resume', onPressed: onResume),
            const SizedBox(height: 8),
            BoardButton(
              label: 'Discard',
              secondary: true,
              onPressed: onDiscard,
            ),
          ],
        ),
      ),
    );
  }

  String _format(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }
}
