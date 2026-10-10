import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

/// [overlayBuilder] lets the mock finale add its two balls to this same arc.
class HalfRingGauge extends StatelessWidget {
  const HalfRingGauge({
    required this.fraction,
    required this.label,
    this.overlayBuilder,
    this.decimalPlaces = 0,
    super.key,
  }) : assert(
          fraction >= 0 && fraction <= 1,
          'Accuracy must be between zero and one.',
        );

  final int decimalPlaces;
  final double fraction;
  final String label;
  final Widget Function(BuildContext, double)? overlayBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label:
          '$label ${(fraction * 100).toStringAsFixed(decimalPlaces)} percent',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        duration: still ? Duration.zero : const Duration(milliseconds: 1400),
        curve: const Interval(3 / 14, 1, curve: PantasCurves.houseOut),
        builder: (context, progress, child) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 112,
              child: Stack(
                children: [
                  CustomPaint(
                    key: const ValueKey('half-ring-paint'),
                    size: const Size(220, 112),
                    painter: _GaugePainter(
                      fraction: fraction * progress,
                      fill: colors.accent,
                      track: colors.fill,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            (fraction * progress * 100)
                                .toStringAsFixed(decimalPlaces),
                            style: type.largeTitle
                                .copyWith(fontSize: 44, letterSpacing: -1.32)
                                .tabular,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '%',
                            style: type.emphasized.copyWith(
                              fontSize: 20,
                              letterSpacing: -.24,
                              color: colors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (overlayBuilder != null)
                    overlayBuilder!(context, fraction * progress),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: type.subheadStrong),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({
    required this.fraction,
    required this.fill,
    required this.track,
  });
  final double fraction;
  final Color fill;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = track;
    const rect = Rect.fromLTWH(18, 10, 184, 184);
    canvas.drawArc(rect, math.pi, math.pi, false, paint);
    if (fraction > 0) {
      paint.color = fill;
      canvas.drawArc(rect, math.pi, math.pi * fraction, false, paint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.fill != fill ||
      oldDelegate.track != track;
}
