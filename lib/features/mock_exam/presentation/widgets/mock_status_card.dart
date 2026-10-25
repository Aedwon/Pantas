import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_availability.dart';

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
    final textStyles = context.type;
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

    return GroupedSection(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textStyles.emphasized),
            const SizedBox(height: 4),
            Text(
              'A timed exam-style practice run.',
              style: textStyles.subhead.copyWith(color: colors.secondaryLabel),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              PantasButton(label: action, onPressed: callback),
            ],
          ],
        ),
      ],
    );
  }
}
