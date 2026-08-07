import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// One or two springs hanging from a beam, each with a weight on the end.
///
/// ```yaml
///     figureSpec:
///       kind: spring-scale
///       springs:
///         - label: A
///           stretch: 3
///         - label: B
///           stretch: 8
/// ```
///
/// `stretch` sets how far the spring is drawn, relative to the others in the
/// same figure. It is a proportion, never a measurement: **the drawing
/// carries no centimetre scale and prints no number**, because the question
/// states the numbers and the app has measured nothing.
///
/// `label` is optional and only used when there are two springs to tell
/// apart. It is the label the stem itself uses, never a choice letter.
class SpringScaleFigure extends StatelessWidget {
  const SpringScaleFigure({required this.springs, super.key});

  static const kind = 'spring-scale';

  final List<SpringSpec> springs;

  /// Null when the spec cannot be read.
  static SpringScaleFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['springs'];
    if (raw is! List || raw.isEmpty || raw.length > 3) return null;

    final springs = <SpringSpec>[];
    for (final entry in raw) {
      if (entry is! Map) return null;
      final stretch = entry['stretch'];
      final label = entry['label'];
      if (stretch is! num || stretch <= 0) return null;
      if (label != null && label is! String) return null;
      springs.add(
        SpringSpec(stretch: stretch.toDouble(), label: label as String?),
      );
    }
    return SpringScaleFigure(springs: springs);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final described = springs.length == 1
        ? 'A spring hanging from a beam with a weight on the end.'
        : '${springs.length} springs hanging from the same beam, each with a '
            'weight. The longer spring has stretched further.';

    return Semantics(
      label: described,
      child: SizedBox(
        height: 150,
        child: CustomPaint(
          painter: _SpringPainter(
            springs: springs,
            ink: colors.ink,
            labelStyle: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// One spring in the figure.
class SpringSpec {
  const SpringSpec({required this.stretch, this.label});

  final double stretch;
  final String? label;
}

class _SpringPainter extends CustomPainter {
  _SpringPainter({
    required this.springs,
    required this.ink,
    required this.labelStyle,
  });

  final List<SpringSpec> springs;
  final Color ink;
  final TextStyle labelStyle;

  static const _coils = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final hairline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;

    const beamY = 14.0;
    const weightSide = 22.0;
    final longest = springs.map((s) => s.stretch).reduce(math.max);
    // The longest spring reaches most of the way down, and the rest are
    // drawn in proportion to it. Nothing here is to scale in centimetres.
    final maxLength = size.height - beamY - weightSide - 26;

    canvas.drawLine(
      const Offset(8, beamY),
      Offset(size.width - 8, beamY),
      hairline,
    );

    final slotWidth = size.width / springs.length;
    for (var i = 0; i < springs.length; i++) {
      final spring = springs[i];
      final cx = slotWidth * (i + 0.5);
      final length = maxLength * (spring.stretch / longest);
      _drawSpring(canvas, cx, beamY, length, hairline);
      _drawWeight(canvas, cx, beamY + length, weightSide, hairline);
      final label = spring.label;
      if (label != null) {
        _drawLabel(canvas, label, cx, beamY + length + weightSide + 6);
      }
    }
  }

  void _drawSpring(
    Canvas canvas,
    double cx,
    double top,
    double length,
    Paint paint,
  ) {
    const width = 11.0;
    final path = Path()..moveTo(cx, top);
    final segment = length / (_coils * 2 + 2);
    var y = top + segment;
    path.lineTo(cx, y);
    for (var i = 0; i < _coils * 2; i++) {
      y += segment;
      path.lineTo(cx + (i.isEven ? width : -width), y);
    }
    path
      ..lineTo(cx, y + segment)
      ..lineTo(cx, top + length);
    canvas.drawPath(path, paint);
  }

  void _drawWeight(
    Canvas canvas,
    double cx,
    double top,
    double side,
    Paint paint,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(cx - side / 2, top, side, side * 0.8),
      paint,
    );
  }

  void _drawLabel(Canvas canvas, String text, double cx, double top) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(cx - painter.width / 2, top));
  }

  @override
  bool shouldRepaint(_SpringPainter old) =>
      old.ink != ink ||
      old.springs.length != springs.length ||
      old.springs.first.stretch != springs.first.stretch;
}
