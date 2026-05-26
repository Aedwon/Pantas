import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';
import 'package:flutter/material.dart';

class MockResultsPage extends StatelessWidget {
  const MockResultsPage({
    required this.results,
    required this.proIsActive,
    this.forfeited = false,
    super.key,
  });

  final MockResults results;
  final bool proIsActive;
  final bool forfeited;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    return Scaffold(
      appBar: AppBar(title: const Text('Mock results')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (forfeited) ...[
            Text('Forfeited during strict mode',
                style: textStyles.headlineSmall),
            const SizedBox(height: 12),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${results.scoreRaw} / ${results.scoreTotal}',
                    style: textStyles.headlineMedium),
                Text('${results.percent.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How you did per part'),
                const SizedBox(height: 8),
                for (final section in results.sections)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.name),
                      Text('${section.correct}/${section.total}'),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Practice these next'),
                const SizedBox(height: 8),
                for (final topic in results.topWeak) Text(topic.drillRoute),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (proIsActive)
            const AppCard(child: Text('Answer review'))
          else
            const AppCard(
              child: Text('See every answer and why it is right'),
            ),
        ],
      ),
    );
  }
}
