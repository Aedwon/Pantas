import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/legacy_theme_shim.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

/// The ring and the check of the sent state, each drawn to its own progress.
class SentMarkPainter extends CustomPainter {
  const SentMarkPainter({
    required this.ring,
    required this.check,
    required this.color,
  });

  /// 0 to 1: how much of the circle is drawn.
  final double ring;

  /// 0 to 1: how much of the check is drawn.
  final double check;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 76;
    final circle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * k
      ..strokeCap = StrokeCap.round
      ..color = color;
    if (ring > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(38 * k, 38 * k), radius: 35 * k),
        -math.pi / 2,
        math.pi * 2 * ring,
        false,
        circle,
      );
    }
    if (check > 0) {
      final path = Path()
        ..moveTo(24 * k, 39 * k)
        ..lineTo(33.5 * k, 48.5 * k)
        ..lineTo(53 * k, 29 * k);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color;
      for (final m in path.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * check), paint);
      }
    }
  }

  @override
  bool shouldRepaint(SentMarkPainter old) =>
      old.ring != ring || old.check != check || old.color != color;
}

/// "Survey sent": the ring draws, the check follows, three ripples spread and
/// the words rise in one after another.
class SurveySent extends StatelessWidget {
  const SurveySent({required this.onBack, super.key});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s24,
        PantasSpace.s56,
        PantasSpace.s24,
        PantasSpace.s40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            key: const ValueKey('sent-mark'),
            dimension: 76,
            child: Stack(
              children: [
                for (final ms in const [700, 820, 940])
                  Positioned.fill(child: _Ripple(delay: ms)),
                Positioned.fill(
                  child: Semantics(
                    label: 'Sent',
                    image: true,
                    child: FbTimeline(
                      duration: const Duration(milliseconds: 770),
                      builder: (context, t, _) {
                        final ms = t * 770;
                        return CustomPaint(
                          painter: SentMarkPainter(
                            ring: PantasCurves.draw
                                .transform((ms / 500).clamp(0.0, 1.0)),
                            check: PantasCurves.draw
                                .transform(((ms - 420) / 350).clamp(0.0, 1.0)),
                            color: c.accent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PantasSpace.s20),
          FbRise(
            dy: 14,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 300),
            child: Semantics(
              header: true,
              child: Text(
                'Survey sent',
                textAlign: TextAlign.center,
                style: PantasType.webH2.copyWith(color: c.textPrimary),
              ),
            ),
          ),
          FbRise(
            dy: 14,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 380),
            child: Padding(
              padding: const EdgeInsets.only(top: PantasSpace.s8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Text(
                  'Thank you for helping shape Pantas. '
                  'Your answers go straight to the team.',
                  textAlign: TextAlign.center,
                  style: PantasType.webSub.copyWith(color: c.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: PantasSpace.s24),
          FbRise(
            dy: 14,
            duration: const Duration(milliseconds: 450),
            delay: const Duration(milliseconds: 460),
            child: FbButton(
              onPressed: onBack,
              tint: true,
              compact: true,
              child: const Text('Back to Feedback'),
            ),
          ),
        ],
      ),
    );
  }
}

/// One ripple: a spread of 0 to 22 px that fades from 38 percent accent to
/// nothing (700 ms, ease out).
class _Ripple extends StatelessWidget {
  const _Ripple({required this.delay});
  final int delay;

  @override
  Widget build(BuildContext context) {
    // The boards use rgba(11,122,104,.38) in both themes.
    final color = context.fb.accent;
    return ExcludeSemantics(
      child: FbTimeline(
        duration: const Duration(milliseconds: 700),
        delay: Duration(milliseconds: delay),
        builder: (context, t, _) {
          // Reduced motion lands on t = 1: the ripple is already gone.
          final e = LegacyCurves.easeOut.transform(t);
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: t == 0
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: .38 * (1 - e)),
                        spreadRadius: 22 * e,
                      ),
                    ],
            ),
          );
        },
      ),
    );
  }
}
