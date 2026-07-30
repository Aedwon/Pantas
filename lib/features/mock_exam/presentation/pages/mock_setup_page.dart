import 'package:flutter/material.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ruled_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';

class MockSetupPage extends StatelessWidget {
  const MockSetupPage({
    required this.parsedBlueprint,
    required this.onStart,
    super.key,
  });

  final ParsedMockBlueprint parsedBlueprint;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final blueprint = parsedBlueprint.blueprint;
    final isSectional = blueprint.sectionalTiming == SectionalTiming.sectional;
    final totalQuestions = parsedBlueprint.sections.fold<int>(
      0,
      (sum, section) => sum + section.questionCount,
    );
    final published = blueprint.totalPublishedItems;

    return Scaffold(
      appBar: AppBar(title: const Text('Mock setup')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('Ready to practice?', style: textStyles.headlineMedium),
          const SizedBox(height: 12),
          RuledSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blueprint.name, style: textStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  blueprint.durationMinutes > 0
                      ? '${blueprint.durationMinutes} min '
                          '· $totalQuestions questions'
                      : 'Untimed · $totalQuestions questions',
                  style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: 8),
                for (final section in parsedBlueprint.sections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            section.name,
                            style: textStyles.bodyMedium,
                          ),
                        ),
                        // A per-part limit governs nothing when the parts
                        // are not timed separately, and printing it would
                        // imply a rule the exam does not have.
                        if (isSectional && section.sectionalMinutes != null)
                          Text(
                            '${section.sectionalMinutes} min',
                            style: textStyles.bodySmall
                                .copyWith(color: colors.inkMuted),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _timingRule(blueprint.sectionalTiming),
            style: textStyles.bodyMedium,
          ),
          if (published != null && published > totalQuestions) ...[
            const SizedBox(height: 10),
            Text(
              'The real exam has $published items. This practice run covers '
              'the $totalQuestions the app can mark for you.',
              style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
            ),
          ],
          const SizedBox(height: 16),
          BoardButton(label: 'Start mock', onPressed: onStart),
        ],
      ),
    );
  }

  /// Three statements, and there is no fourth.
  ///
  /// The unknown case says what the app is doing and why. A student who
  /// later takes the real exam and finds it sectional must not feel the app
  /// misled them: we do not know, and here is what we chose in the absence
  /// of knowing.
  String _timingRule(SectionalTiming? timing) => switch (timing) {
        SectionalTiming.sectional =>
          'This exam runs part by part. Once a part ends you cannot go back.',
        SectionalTiming.roamable => 'You can move around the whole exam.',
        null => 'We do not know yet whether this exam lets you go back '
            'between parts. This practice run lets you move around the '
            'whole thing.',
      };
}

class MockSetupPlaceholderPage extends StatelessWidget {
  const MockSetupPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock setup')),
      body: Center(
        child: Text(
          'Choose a mock blueprint',
          style: context.textStyles.bodyMedium
              .copyWith(color: context.colors.inkMuted),
        ),
      ),
    );
  }
}
