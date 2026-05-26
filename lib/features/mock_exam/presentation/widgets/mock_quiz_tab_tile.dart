import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:flutter/material.dart';

class MockQuizTabTile extends StatelessWidget {
  const MockQuizTabTile({
    required this.availability,
    required this.onStart,
    required this.onResume,
    super.key,
  });

  final MockAvailability availability;
  final VoidCallback onStart;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final (title, actionLabel, callback) = switch (availability.state) {
      MockAvailabilityState.available => ('Mock ready', 'Start mock', onStart),
      MockAvailabilityState.cooldown => (
          'Next mock in ${availability.cooldownRemaining!.inDays} days',
          'View details',
          onStart
        ),
      MockAvailabilityState.inProgress => (
          'Mock in progress',
          'Resume',
          onResume
        ),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Timed practice with a full exam-style question set.',
            style: textStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          AppButton(label: actionLabel, onPressed: callback),
        ],
      ),
    );
  }
}
