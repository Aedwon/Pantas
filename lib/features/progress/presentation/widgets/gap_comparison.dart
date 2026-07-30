import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/how_you_work_provider.dart';

class GapComparison extends StatelessWidget {
  const GapComparison({
    required this.tendency,
    required this.isPro,
    super.key,
  });

  final Tendency tendency;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    if (!isPro) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaintBars(),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tendency.leftLabel,
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
                Text(
                  ' vs. ',
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
                Text(
                  tendency.rightLabel,
                  style: styles.bodySmall.copyWith(
                    fontSize: 11.5,
                    color: colors.inkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (tendency.gap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Not enough data yet',
              style: styles.bodyMedium.copyWith(
                color: colors.inkMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tendency.unlockAction,
              style: styles.bodySmall.copyWith(
                fontSize: 11.5,
                color: colors.inkMuted,
              ),
            ),
          ],
        ),
      );
    }

    final gapColor = tendency.isLoss ? colors.rust : colors.ink;

    final hasSourceFigures =
        tendency.leftFigure != null && tendency.rightFigure != null;

    final captionWidget = hasSourceFigures
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tendency.leftLabel} ${tendency.leftFigure}',
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
              Text(
                ' vs. ',
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
              Text(
                '${tendency.rightLabel} ${tendency.rightFigure}',
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tendency.leftLabel,
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
              Text(
                ' vs. ',
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
              Text(
                tendency.rightLabel,
                style: styles.bodySmall.copyWith(
                  fontSize: 11.5,
                  color: colors.inkMuted,
                ),
              ),
            ],
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tendency.gap!,
            style: TextStyle(
              fontFamily: 'SourceSans3',
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: gapColor,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tendency.sentence != null) ...[
                  Text(
                    tendency.sentence!,
                    style: styles.bodyMedium.copyWith(
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                captionWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
