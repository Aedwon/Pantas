import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_attempt.dart';
import 'package:flutter/material.dart';

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
    final remainingSeconds =
        (attempt.durationMinutes * 60) - attempt.elapsedSeconds;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(attempt.blueprintName),
              const SizedBox(height: 8),
              Text('Elapsed ${_format(attempt.elapsedSeconds)}'),
              Text('Remaining ${_format(remainingSeconds)}'),
              const SizedBox(height: 16),
              AppButton(label: 'Resume', onPressed: onResume),
              const SizedBox(height: 8),
              AppButton(
                label: 'Discard',
                variant: AppButtonVariant.secondary,
                onPressed: onDiscard,
              ),
            ],
          ),
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
