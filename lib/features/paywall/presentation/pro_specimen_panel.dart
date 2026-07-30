import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/domain/pro_specimen.dart';

/// Screen 1's argument: one real gated panel, shown as a Free user sees it
/// and as Pro sees it. Both halves are the sample.
class ProSpecimenPanel extends StatelessWidget {
  const ProSpecimenPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // The tier tag. 10/700 uppercase, exactly how the level control marks
    // its active label: muted for the inactive tier, ink for the active one.
    Widget tag(String text, {required bool active}) {
      return Text(
        text,
        style: styles.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: active ? colors.ink : colors.inkMuted,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The plate. Title plus the Sample mark on one baseline, then the
        // rule. Sample is inkMuted, never board green: board green is
        // budgeted to the button, one per screen.
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(proSpecimen.panelName, style: styles.headlineSmall),
            ),
            Text(
              'Sample',
              style: styles.labelSmall.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
        Container(
          height: 1.6,
          color: colors.ink,
          margin: const EdgeInsets.only(top: 6),
        ),

        const SizedBox(height: 14),
        tag('Free', active: false),
        const SizedBox(height: 5),
        Text(
          '${proSpecimen.leftLabel}  vs.  ${proSpecimen.rightLabel}',
          style: styles.headlineSmall.copyWith(
            fontSize: 14,
            color: colors.inkMuted,
          ),
        ),
        const SizedBox(height: 4),
        const FaintBars(widthFactors: [0.9, 0.65]),

        const SizedBox(height: 14),
        tag('Pro', active: true),
        const SizedBox(height: 5),
        Text(
          '${proSpecimen.leftLabel} ${proSpecimen.leftFigure}%  vs.  '
          '${proSpecimen.rightLabel} ${proSpecimen.rightFigure}%',
          style: styles.headlineSmall.copyWith(fontSize: 14),
        ),

        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The figure outranks the headline. Ink, not rust: rust is
            // reserved for a loss and this is an illustration.
            Text(
              '${proSpecimen.gapFigure}',
              style: styles.displayLarge.copyWith(fontSize: 30, height: 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                proSpecimen.sentence,
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
