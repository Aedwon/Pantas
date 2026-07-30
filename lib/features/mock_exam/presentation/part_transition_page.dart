import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PartTransitionPage extends StatelessWidget {
  const PartTransitionPage({
    required this.closedPartName,
    required this.closedPartMinutes,
    required this.answered,
    required this.total,
    required this.blank,
    required this.flagged,
    required this.nextPartName,
    required this.nextPartQuestions,
    required this.nextPartMinutes,
    required this.closedPartNumber,
    required this.nextPartNumber,
    required this.onStartNext,
    super.key,
  });

  final String closedPartName;
  final int closedPartMinutes;
  final int answered;
  final int total;
  final int blank;
  final int flagged;
  final String nextPartName;
  final int nextPartQuestions;
  final int nextPartMinutes;
  final int closedPartNumber;
  final int nextPartNumber;
  final VoidCallback onStartNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time is up for Part $closedPartNumber.',
                  style: textStyles.displayMedium.copyWith(
                    fontFamily: 'SourceSans3',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$closedPartName · $closedPartMinutes minutes',
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 32),
                const SectionHeader(title: 'What you did'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$answered',
                      style: textStyles.displayLarge.copyWith(
                        fontFamily: 'SourceSans3',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
                    ),
                    Text(
                      'of $total answered',
                      style: textStyles.mathBody.copyWith(
                        fontFamily: 'SourceSans3',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$blank left blank · $flagged you flagged',
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Part $closedPartNumber is closed. You cannot go back to it.',
                  style: textStyles.labelLarge.copyWith(
                    color: colors.ink,
                  ),
                ),
                const Spacer(),
                const SectionHeader(title: 'Next'),
                const SizedBox(height: 8),
                Text(
                  '$nextPartName · $nextPartQuestions questions · '
                  '$nextPartMinutes minutes',
                  style: textStyles.bodyRegular.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
                const SizedBox(height: 24),
                BoardButton(
                  label: 'Start Part $nextPartNumber',
                  onPressed: onStartNext,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Part $nextPartNumber time begins as soon as you tap.',
                    style: textStyles.captionSmall.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
