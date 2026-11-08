import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class ScoreHeadline extends StatefulWidget {
  const ScoreHeadline({
    required this.scoreRaw,
    required this.scoreTotal,
    required this.band,
    required this.wasForfeited,
    this.disableAnimations = false,
    super.key,
  });

  final int scoreRaw;
  final int scoreTotal;
  final ScoreBand? band;
  final bool wasForfeited;
  final bool disableAnimations;

  @override
  State<ScoreHeadline> createState() => _ScoreHeadlineState();
}

class _ScoreHeadlineState extends State<ScoreHeadline> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final targetPercent = widget.scoreTotal > 0
        ? (widget.scoreRaw / widget.scoreTotal * 100).round()
        : 0;

    final animationsDisabled = widget.disableAnimations ||
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        !TickerMode.valuesOf(context).enabled;

    String? bandText;
    if (!widget.wasForfeited && widget.band != null) {
      bandText = switch (widget.band!) {
        ScoreBand.pass => 'Passing',
        ScoreBand.close => 'Close to passing',
        ScoreBand.fail => 'Not passing',
      };
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: animationsDisabled ? targetPercent.toDouble() : 0,
                end: targetPercent.toDouble(),
              ),
              duration: animationsDisabled
                  ? Duration.zero
                  : const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Text(
                  '${value.round()}',
                  style: PantasType.phoneDisplayM.copyWith(
                    color: colors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            Text(
              '%',
              style: PantasType.phoneBody.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        if (bandText != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            bandText,
            style: PantasType.webLink.copyWith(color: colors.textPrimary),
          ),
        ],
        const SizedBox(height: PantasSpace.s4),
        Text(
          '${widget.scoreRaw} of ${widget.scoreTotal}',
          style: PantasType.phoneCaption.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}
