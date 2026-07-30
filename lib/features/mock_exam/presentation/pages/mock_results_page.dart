import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/severity.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/score_headline.dart';

class MockResultsPage extends StatelessWidget {
  const MockResultsPage({
    required this.results,
    required this.proIsActive,
    this.blueprintName = 'UPCAT full length',
    this.dateFormatted = '2 August 2026',
    this.forfeited = false,
    this.onReviewTap,
    this.disableAnimations = false,
    super.key,
  });

  final MockResults results;
  final bool proIsActive;
  final String blueprintName;
  final String dateFormatted;
  final bool forfeited;
  final VoidCallback? onReviewTap;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock results'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Row(
            children: [
              Text(
                blueprintName,
                style: styles.headlineMedium.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (forfeited) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.rust),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Forfeited',
                    style: styles.bodySmall.copyWith(
                      color: colors.rust,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            dateFormatted,
            style: styles.bodySmall.copyWith(
              fontSize: 12,
              color: colors.inkMuted,
            ),
          ),
          const SizedBox(height: 24),
          ScoreHeadline(
            scoreRaw: results.scoreRaw,
            scoreTotal: results.scoreTotal,
            band: results.band,
            wasForfeited: forfeited,
            disableAnimations: disableAnimations,
          ),
          if (forfeited) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Exam was forfeited before completion.',
                style: styles.bodySmall.copyWith(
                  color: colors.inkMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          const SectionHeader(title: 'Performance'),
          const SizedBox(height: 8),
          for (final section in results.sections) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      section.name,
                      style: styles.bodyMedium,
                    ),
                  ),
                  InlineMeter(
                    value: section.accuracy,
                    color: severityFor(section.accuracy, colors),
                    width: 54,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${(section.accuracy * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: styles.bodySmall.copyWith(
                        color: colors.inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${section.timeSeconds ~/ 60}m',
                    style: styles.bodySmall.copyWith(
                      color: colors.inkMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: AppDimensions.hairline, color: colors.ruleFaint),
          ],
          if (results.topWeak.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Practice these next'),
            const SizedBox(height: 8),
            for (final weak in results.topWeak.take(3)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        weak.topicId,
                        style: styles.bodyMedium,
                      ),
                    ),
                    Text(
                      '${(weak.accuracy * 100).round()}%',
                      style: styles.bodySmall.copyWith(
                        color: colors.inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const InkChevron(),
                  ],
                ),
              ),
              Container(
                height: AppDimensions.hairline,
                color: colors.ruleFaint,
              ),
            ],
          ],
          const SizedBox(height: 32),
          Container(height: AppDimensions.hairline, color: colors.rule),
          InkWell(
            onTap: onReviewTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Go through all ${results.scoreTotal} questions',
                      style: styles.headlineSmall.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const InkChevron(),
                ],
              ),
            ),
          ),
          Container(height: AppDimensions.hairline, color: colors.rule),
          const SizedBox(height: 24),
          Text(
            proIsActive
                ? 'Saved.'
                : 'Saved. Free tier keeps scores locally. Reopens in 7 days.',
            style: styles.bodySmall.copyWith(
              color: colors.inkMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
