import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.fraction,
    this.size = 24,
    this.child,
    this.showCheck = true,
    super.key,
  }) : assert(fraction >= 0 && fraction <= 1, 'Fraction must be from 0 to 1.');
  final double fraction;
  final double size;
  final Widget? child;
  final bool showCheck;
  @override
  Widget build(BuildContext context) {
    if (fraction == 1 && showCheck) return const CheckMark();
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: '${(fraction * 100).round()} percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? fraction : 0, end: fraction),
        duration: still
            ? Duration.zero
            : Duration(milliseconds: size == 34 ? 1200 : 600),
        curve: size == 34
            ? const Interval(.25, 1, curve: PantasCurves.houseOut)
            : PantasCurves.houseOut,
        builder: (context, value, _) => SizedBox.square(
          dimension: size,
          child: CustomPaint(
            key: const ValueKey('progress-ring-paint'),
            painter: _RingPainter(
              fraction: value,
              track: fraction == 0
                  ? context.colors.chevron
                  : size == 34
                      ? context.colors.accentTint
                      : context.colors.separator,
              fill: context.colors.accent,
              stroke: fraction == 0
                  ? 1.5
                  : size == 34
                      ? 2.5
                      : 2.4,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
    required this.stroke,
  });
  final double fraction;
  final Color track;
  final Color fill;
  final double stroke;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = stroke == 1.5 ? size.width / 2 - .75 : size.width / 2 - 1.5;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width == 24 && fraction > 0 ? 2 : stroke)
      ..color = track;
    canvas.drawCircle(center, radius, paint);
    if (fraction > 0) {
      paint
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * fraction,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      track != oldDelegate.track ||
      fill != oldDelegate.fill ||
      stroke != oldDelegate.stroke;
}
