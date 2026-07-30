import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/components/stats_band.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/pace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _numberToWordsOrDigits(int n) {
  return switch (n) {
    1 => 'one',
    2 => 'two',
    3 => 'three',
    4 => 'four',
    5 => 'five',
    6 => 'six',
    7 => 'seven',
    8 => 'eight',
    9 => 'nine',
    10 => 'ten',
    _ => '$n',
  };
}

String _numberToWordsOrDigitsCapitalized(int n) {
  final s = _numberToWordsOrDigits(n);
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

class YourPacePanel extends ConsumerWidget {
  const YourPacePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paceAsync = ref.watch(paceProvider);

    return paceAsync.when(
      data: (pace) {
        if (pace == null) return const SizedBox.shrink();

        final percentage = pace.lessonsTotal == 0
            ? 0
            : ((pace.lessonsRead / pace.lessonsTotal) * 100).round();

        final figures = <StatFigure>[
          StatFigure(
            value: '$percentage%',
            label: 'lessons read',
          ),
          if (pace.daysLeft != null)
            StatFigure(
              value: '${pace.daysLeft}',
              label: pace.daysLeft == 1 ? 'day left' : 'days left',
            ),
        ];

        final sentenceWidget = _buildSentence(context, pace);

        return RuledPanel(
          heading: 'Your pace',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatsBand(
                figures: figures,
                centred: true,
              ),
              if (sentenceWidget != null) ...[
                const SizedBox(height: 12),
                sentenceWidget,
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget? _buildSentence(BuildContext context, PaceReading pace) {
    final styles = context.textStyles;
    final colors = context.colors;
    final baseStyle = styles.bodyMedium.copyWith(color: colors.ink);

    final rate = pace.lessonsPerWeek;
    final daysLeft = pace.daysLeft;
    final daysPast = pace.daysPastExam;
    final rateToFinish = pace.rateToFinishInTime;
    final remaining = pace.lessonsTotal - pace.lessonsRead;

    // Condition 1: Finishes late
    if (daysPast != null && rateToFinish != null && rate != null) {
      final rateText = _numberToWordsOrDigits(rate);
      final lessonWord = rate == 1 ? 'lesson' : 'lessons';
      final pastText = _numberToWordsOrDigits(daysPast);
      final dayWord = daysPast == 1 ? 'day' : 'days';
      final fixText = _numberToWordsOrDigitsCapitalized(rateToFinish);

      return Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: 'At $rateText $lessonWord a week you finish '),
            TextSpan(
              text: '$pastText $dayWord after the exam',
              style: TextStyle(color: colors.amber),
            ),
            TextSpan(text: '. $fixText a week closes the gap.'),
          ],
        ),
      );
    }

    // Condition 2: Finishes in time
    if (rate != null && rate > 0 && daysLeft != null && daysPast == null) {
      final rateText = _numberToWordsOrDigits(rate);
      final lessonWord = rate == 1 ? 'lesson' : 'lessons';
      return Text(
        'At $rateText $lessonWord a week you finish before the exam.',
        style: baseStyle,
      );
    }

    // Condition 3: Rate is zero
    if (rate == 0) {
      final remainingText = remaining == 1 ? 'is 1' : 'are $remaining';
      return Text(
        'You have not read a lesson in four weeks. There $remainingText left.',
        style: baseStyle,
      );
    }

    // Condition 4: Below sample floor (rate == null)
    if (rate == null) {
      return null;
    }

    // Condition 5: No day count (daysLeft == null, rate > 0)
    if (daysLeft == null && rate > 0) {
      final rateText = _numberToWordsOrDigits(rate);
      final lessonWord = rate == 1 ? 'lesson' : 'lessons';
      final weeks = (remaining / rate).ceil();
      final weeksText = _numberToWordsOrDigits(weeks);
      final weekWord = weeks == 1 ? 'week' : 'weeks';
      return Text(
        'At $rateText $lessonWord a week you have about $weeksText '
        '$weekWord of reading left.',
        style: baseStyle,
      );
    }

    return null;
  }
}
