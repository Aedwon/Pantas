import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

class WebProHero extends StatelessWidget {
  const WebProHero({required this.heading, this.detail, super.key});
  final String heading;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final perkStyle = PantasType.webBody.copyWith(
      color: c.textPrimary,
      height: 1.3,
    );
    final headingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PANTAS PRO',
          style: PantasType.webEyebrow.copyWith(color: c.accent),
        ),
        const SizedBox(height: PantasSpace.s8),
        Text(heading, style: PantasType.webH2.copyWith(color: c.textPrimary)),
        if (detail != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            detail!,
            style: PantasType.webBody.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
    const perks = [
      'Unlimited mock exams',
      'Notes on why your answer was wrong',
      'The figures behind your study habits',
      "Progress that's always backed up",
      'Results by topic and lesson',
    ];
    final features = Padding(
      padding: const EdgeInsets.only(top: PantasSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, feature) in perks.indexed) ...[
            if (index > 0) const SizedBox(height: PantasSpace.s8),
            Row(
              children: [
                CustomPaint(
                  size: const Size.square(PantasSpace.s14),
                  painter: _CheckPainter(c.accent),
                ),
                const SizedBox(width: PantasSpace.s10),
                Expanded(child: Text(feature, style: perkStyle)),
              ],
            ),
          ],
        ],
      ),
    );
    return Container(
      key: const ValueKey('pro-hero'),
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s28,
        PantasSpace.s28,
        PantasSpace.s28,
        PantasSpace.s24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PantasRadius.r2xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.surfaceCard, c.surfaceCard, c.accentTint],
          stops: const [0, .55, 1],
        ),
      ),
      // The dark edge takes up no room: the card is the same size in both
      // themes (6T-11).
      foregroundDecoration: dark
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(PantasRadius.r2xl),
              border: Border.all(color: c.edgeCard),
            )
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The perks take the width of the longest one, so none wraps while
          // the heading column has room (5Q-15). Too little room left for the
          // heading stacks the two.
          final scaler = MediaQuery.textScalerOf(context);
          var longest = 0.0;
          for (final perk in perks) {
            final painter = TextPainter(
              text: TextSpan(text: perk, style: perkStyle),
              textDirection: Directionality.of(context),
              textScaler: scaler,
              maxLines: 1,
            )..layout();
            if (painter.width > longest) longest = painter.width;
            painter.dispose();
          }
          // Tick, its gap, and a hair for rounding.
          final perksWidth = longest + PantasSpace.s14 + PantasSpace.s10 + 2;
          final headingWidth =
              constraints.maxWidth - PantasSpace.s24 - perksWidth;
          if (constraints.maxWidth < 544 || headingWidth < 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headingColumn,
                const SizedBox(height: PantasSpace.s24),
                features,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headingColumn),
              const SizedBox(width: PantasSpace.s24),
              SizedBox(width: perksWidth, child: features),
            ],
          );
        },
      ),
    );
  }
}

/// The board's 14 px tick: stroke 3 on a 24 unit box, round caps and joins.
class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final path = Path()
      ..moveTo(5 * unit, 12.5 * unit)
      ..lineTo(9.5 * unit, 17 * unit)
      ..lineTo(19 * unit, 7 * unit);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => color != oldDelegate.color;
}
