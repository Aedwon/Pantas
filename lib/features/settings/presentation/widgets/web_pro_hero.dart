import 'package:flutter/material.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class WebProHero extends StatelessWidget {
  const WebProHero({required this.heading, this.detail, super.key});
  final String heading;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final headingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PANTAS PRO',
          style: t.sm.copyWith(
            color: t.colors.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: .52,
          ),
        ),
        const SizedBox(height: 8),
        Text(heading, style: t.h2),
        if (detail != null) ...[
          const SizedBox(height: 8),
          Text(detail!, style: t.sub.copyWith(fontSize: 16, height: 1.45)),
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
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, feature) in perks.indexed) ...[
            if (index > 0) const SizedBox(height: 8),
            Row(
              children: [
                CustomPaint(
                  size: const Size.square(14),
                  painter: _CheckPainter(t.colors.accent),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(feature, style: t.style(16, height: 1.3))),
              ],
            ),
          ],
        ],
      ),
    );
    return Container(
      key: const ValueKey('pro-hero'),
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: t.dark ? Border.all(color: t.cardEdge) : null,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.colors.surface, t.colors.surface, t.colors.accentTint],
          stops: const [0, .55, 1],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The perks take the width of the longest one, so none wraps while
          // the heading column has room (5Q-15). Too little room left for the
          // heading stacks the two.
          final scaler = MediaQuery.textScalerOf(context);
          var longest = 0.0;
          for (final perk in perks) {
            final painter = TextPainter(
              text: TextSpan(text: perk, style: t.style(16, height: 1.3)),
              textDirection: Directionality.of(context),
              textScaler: scaler,
              maxLines: 1,
            )..layout();
            if (painter.width > longest) longest = painter.width;
            painter.dispose();
          }
          // Tick, its gap, and a hair for rounding.
          final perksWidth = longest + 14 + 10 + 2;
          final headingWidth = constraints.maxWidth - 24 - perksWidth;
          if (constraints.maxWidth < 544 || headingWidth < 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [headingColumn, const SizedBox(height: 24), features],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headingColumn),
              const SizedBox(width: 24),
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
