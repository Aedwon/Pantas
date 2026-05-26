import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_availability.dart';
import 'package:flutter/material.dart';

class MockStatusCard extends StatelessWidget {
  const MockStatusCard({
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
    final (title, action, callback) = switch (availability.state) {
      MockAvailabilityState.available => ('Mock ready', 'Start mock', onStart),
      MockAvailabilityState.cooldown => (
          'Next mock in ${availability.cooldownRemaining!.inDays} days',
          'Review results',
          onStart
        ),
      MockAvailabilityState.inProgress => ('Resume mock', 'Resume', onResume),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textStyles.headlineSmall),
          const SizedBox(height: 8),
          const Text('A timed exam-style practice run.'),
          const SizedBox(height: 12),
          AppButton(label: action, onPressed: callback),
        ],
      ),
    );
  }
}
