import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A pulley system: a beam above, one fixed pulley or a run of movable
/// ones, and a load hanging underneath.
///
/// ```yaml
///     figureSpec:
///       kind: pulley-system
///       fixed: 1
///       movable: 0
/// ```
///
/// **A fixed pulley hangs from the beam and a movable one rides on the
/// rope with the load.** That difference is the whole of most of these
/// questions, so it is what the drawing has to make obvious.
class PulleySystemFigure extends StatelessWidget {
  const PulleySystemFigure({
    required this.fixed,
    required this.movable,
    required this.comparison,
    super.key,
  });

  static const kind = 'pulley-system';

  final int fixed;
  final int movable;
  final bool comparison;

  /// Null when the spec cannot be read.
  static PulleySystemFigure? fromSpec(Map<String, Object?> spec) {
    final fixed = spec['fixed'];
    final movable = spec['movable'];
    if (fixed is! int || movable is! int) return null;
    if (fixed < 0 || movable < 0 || fixed + movable < 1) return null;
    if (fixed > 3 || movable > 4) return null;
    final comparison = spec['comparison'] ?? false;
    if (comparison is! bool) return null;
    if (comparison && (fixed != 1 || movable != 1)) return null;
    return PulleySystemFigure(
      fixed: fixed,
      movable: movable,
      comparison: comparison,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final description = comparison
        ? 'A fixed pulley beside a separate movable pulley setup.'
        : movable == 0
            ? 'A fixed pulley hanging from a beam, with a load on one end '
                'of the '
                'rope and a hand pulling the other.'
            : '$movable movable '
                '${movable == 1 ? 'pulley' : 'pulleys'} carrying '
                'the load, with the rope running up to the beam.';
    return Semantics(
      label: description,
      child: SizedBox(
        height: 150,
        child: CustomPaint(
          painter: _PulleyPainter(
            fixed: fixed,
            movable: movable,
            comparison: comparison,
            ink: colors.ink,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PulleyPainter extends CustomPainter {
  _PulleyPainter({
    required this.fixed,
    required this.movable,
    required this.comparison,
    required this.ink,
  });

  final int fixed;
  final int movable;
  final bool comparison;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    if (comparison) {
      final half = Size(size.width / 2, size.height);
      _paintSystem(canvas, half, fixed: 1, movable: 0);
      canvas
        ..save()
        ..translate(half.width, 0);
      _paintSystem(canvas, half, fixed: 0, movable: 1);
      canvas.restore();
      return;
    }
    _paintSystem(canvas, size, fixed: fixed, movable: movable);
  }

  void _paintSystem(
    Canvas canvas,
    Size size, {
    required int fixed,
    required int movable,
  }) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    const beamY = 12.0;
    const radius = 15.0;
    final centreX = size.width / 2;

    canvas.drawLine(
      const Offset(12, beamY),
      Offset(size.width - 12, beamY),
      hairline,
    );

    // Fixed pulleys hang from the beam, side by side.
    const spread = radius * 2.6;
    final firstX = centreX - spread * (fixed - 1) / 2;
    for (var i = 0; i < fixed; i++) {
      final x = firstX + spread * i;
      canvas
        ..drawLine(Offset(x, beamY), Offset(x, beamY + 10), hairline)
        ..drawCircle(Offset(x, beamY + 10 + radius), radius, hairline);
    }

    // The load hangs below. Movable pulleys ride between the beam and it.
    final loadTop = size.height - 34;
    for (var i = 0; i < movable; i++) {
      final y = beamY + 46.0 + i * (radius * 2.4);
      canvas
        ..drawCircle(Offset(centreX, y), radius, hairline)
        ..drawLine(
          Offset(centreX - radius, y),
          Offset(centreX - radius, beamY + 10),
          hairline,
        )
        ..drawLine(
          Offset(centreX + radius, y),
          Offset(centreX + radius, beamY + 10),
          hairline,
        );
    }

    // The load, and the rope down to it.
    final ropeTop = movable == 0 ? beamY + 25 + radius : loadTop - 30;
    canvas
      ..drawLine(
        Offset(centreX, ropeTop),
        Offset(centreX, loadTop),
        hairline,
      )
      ..drawRect(Rect.fromLTWH(centreX - 16, loadTop, 32, 24), hairline);
  }

  @override
  bool shouldRepaint(_PulleyPainter old) =>
      old.fixed != fixed ||
      old.movable != movable ||
      old.comparison != comparison ||
      old.ink != ink;
}
