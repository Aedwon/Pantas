import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
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
    final colors = context.colors;
    final (title, action, callback) = switch (availability.state) {
      MockAvailabilityState.available => ('Mock ready', 'Start mock', onStart),
      MockAvailabilityState.cooldown => (
          'Next mock in ${availability.cooldownRemaining!.inDays} days',
          'Review results',
          onStart
        ),
      MockAvailabilityState.inProgress => ('Resume mock', 'Resume', onResume),
      MockAvailabilityState.noBlueprint => (
          'Mock paper not ready',
          null,
          null,
        ),
    };

    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'A timed exam-style practice run.',
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            BoardButton(label: action, onPressed: callback),
          ],
        ],
      ),
    );
  }
}
