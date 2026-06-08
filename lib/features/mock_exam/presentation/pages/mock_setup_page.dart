import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:flutter/material.dart';

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
    final totalQuestions = parsedBlueprint.sections.fold<int>(
      0,
      (sum, section) => sum + section.questionCount,
    );

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
                Text(
                  parsedBlueprint.blueprint.name,
                  style: textStyles.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${parsedBlueprint.blueprint.durationMinutes} min · '
                  '$totalQuestions questions',
                  style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: 8),
                for (final section in parsedBlueprint.sections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(section.name, style: textStyles.bodyMedium),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BoardButton(label: 'Start mock', onPressed: onStart),
        ],
      ),
    );
  }
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
