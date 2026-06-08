import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          if (forfeited) ...[
            Text(
              'Forfeited during strict mode',
              style: textStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
          ],
          StatsBand(
            figures: [
              StatFigure(
                value: '${results.scoreRaw}',
                suffix: '/${results.scoreTotal}',
                label: 'score',
              ),
              StatFigure(
                value: '${results.percent.toStringAsFixed(0)}%',
                label: 'accuracy',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SectionHeader(title: 'How you did per part'),
          for (final section in results.sections)
            InkTableRow(
              title: section.name,
              meta: '${section.correct}/${section.total}',
            ),
          const SizedBox(height: 12),
          const SectionHeader(title: 'Practice these next'),
          for (final topic in results.topWeak)
            InkTableRow(title: topic.drillRoute),
          const SizedBox(height: 12),
          if (proIsActive)
            const RuledSection(
              child: SectionHeader(title: 'Answer review'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Answer review',
                  action: 'Unlock with Pro',
                  onAction: () {},
                ),
                const FaintBars(),
              ],
            ),
        ],
      ),
    );
  }
}
