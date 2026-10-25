import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A beam on a fulcrum, with the load on one side and the effort on the
/// other.
///
/// ```yaml
///     figureSpec:
///       kind: lever-balance
///       loadDistance: 2
///       effortDistance: 5
/// ```
///
/// The two distances place the fulcrum along the beam in proportion. They
/// are never printed: the stem gives them in metres and the drawing is a
/// diagram, not a scale.
class LeverBalanceFigure extends StatelessWidget {
  const LeverBalanceFigure({
    required this.loadDistance,
    required this.effortDistance,
    super.key,
  });

  static const kind = 'lever-balance';

  final double loadDistance;
  final double effortDistance;

  /// Null when the spec cannot be read.
  static LeverBalanceFigure? fromSpec(Map<String, Object?> spec) {
    final load = spec['loadDistance'];
    final effort = spec['effortDistance'];
    if (load is! num || effort is! num) return null;
    if (load <= 0 || effort <= 0) return null;
    return LeverBalanceFigure(
      loadDistance: load.toDouble(),
      effortDistance: effort.toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A beam resting on a fulcrum. The load sits on the short side '
          'and the effort is applied on the long side.',
      child: SizedBox(
        height: 110,
        child: CustomPaint(
          painter: _LeverPainter(
            loadDistance: loadDistance,
            effortDistance: effortDistance,
            ink: colors.label,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _LeverPainter extends CustomPainter {
  _LeverPainter({
    required this.loadDistance,
    required this.effortDistance,
    required this.ink,
  });

  final double loadDistance;
  final double effortDistance;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    const margin = 20.0;
    final beamY = size.height * 0.55;
    final usable = size.width - margin * 2;
    // The fulcrum sits where the two distances put it.
    final total = loadDistance + effortDistance;
    final fulcrumX = margin + usable * (loadDistance / total);

    canvas.drawLine(
      Offset(margin, beamY),
      Offset(size.width - margin, beamY),
      hairline,
    );

    // The fulcrum: a triangle under the beam.
    final triangle = Path()
      ..moveTo(fulcrumX, beamY)
      ..lineTo(fulcrumX - 13, beamY + 22)
      ..lineTo(fulcrumX + 13, beamY + 22)
      ..close();
    canvas.drawPath(triangle, hairline);

    // The load: a box sitting on the beam at the load end.
    const box = 22.0;
    canvas.drawRect(
      Rect.fromLTWH(margin - 2, beamY - box, box, box),
      hairline,
    );

    // The effort: an arrow pressing down at the effort end.
    final effortX = size.width - margin;
    canvas
      ..drawLine(
        Offset(effortX, beamY - 34),
        Offset(effortX, beamY - 4),
        hairline,
      )
      ..drawLine(
        Offset(effortX, beamY - 4),
        Offset(effortX - 6, beamY - 14),
        hairline,
      )
      ..drawLine(
        Offset(effortX, beamY - 4),
        Offset(effortX + 6, beamY - 14),
        hairline,
      );
  }

  @override
  bool shouldRepaint(_LeverPainter old) =>
      old.loadDistance != loadDistance ||
      old.effortDistance != effortDistance ||
      old.ink != ink;
}
