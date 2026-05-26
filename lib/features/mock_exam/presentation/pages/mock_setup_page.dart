import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
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
    final totalQuestions = parsedBlueprint.sections.fold<int>(
      0,
      (sum, section) => sum + section.questionCount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Mock setup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Ready to practice?', style: textStyles.headlineSmall),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parsedBlueprint.blueprint.name,
                  style: textStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text('${parsedBlueprint.blueprint.durationMinutes} min'),
                    Text('$totalQuestions questions'),
                  ],
                ),
                const SizedBox(height: 12),
                for (final section in parsedBlueprint.sections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(section.name),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Start mock', onPressed: onStart),
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
      body: const Center(child: Text('Choose a mock blueprint')),
    );
  }
}
