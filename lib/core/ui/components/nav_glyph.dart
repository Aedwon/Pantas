import 'package:flutter/material.dart';

/// Which of the four bottom-navigation glyphs to draw.
enum NavGlyphKind { home, study, quiz, progress }

/// A navigation glyph drawn as an outline that fills from the bottom up.
///
/// [fill] is the height of the filled region as a fraction of the glyph box,
/// measured from the bottom. 0 is the plain outline, 1 is wholly filled.
/// The caller owns the animation; this widget is a pure function of its
/// arguments.
class NavGlyph extends StatelessWidget {
  const NavGlyph({
    required this.kind,
    required this.fill,
    required this.color,
    this.size = 23,
    super.key,
  });

  final NavGlyphKind kind;
  final double fill;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: NavGlyphPainter(
          kind: kind,
          fill: fill.clamp(0.0, 1.0),
          color: color,
        ),
      ),
    );
  }
}

/// Public so widget tests can assert on [shouldRepaint].
class NavGlyphPainter extends CustomPainter {
  const NavGlyphPainter({
    required this.kind,
    required this.fill,
    required this.color,
  });

  final NavGlyphKind kind;
  final double fill;
  final Color color;

  /// The grid every path below is authored on.
  static const double _grid = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _grid;
    final path = _pathFor(kind)
        .transform(Matrix4.diagonal3Values(scale, scale, 1).storage);

    if (fill > 0) {
      final top = size.height * (1 - fill);
      canvas
        ..save()
        ..clipRect(Rect.fromLTRB(0, top, size.width, size.height))
        ..drawPath(path, Paint()..color = color)
        ..restore();
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * size.width / 23
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  Path _pathFor(NavGlyphKind kind) {
    switch (kind) {
      case NavGlyphKind.home:
        return _house();
      case NavGlyphKind.study:
        return _openBook();
      case NavGlyphKind.quiz:
        return _bubble();
      case NavGlyphKind.progress:
        return _sheet();
    }
  }

  /// A house: roof apex at the top centre, walls down to the baseline.
  Path _house() {
    return Path()
      ..moveTo(12, 3)
      ..lineTo(21, 10.5)
      ..lineTo(21, 20.5)
      ..lineTo(3, 20.5)
      ..lineTo(3, 10.5)
      ..close();
  }

  /// An open book: two leaves meeting at a central spine.
  Path _openBook() {
    return Path()
      ..moveTo(12, 6.5)
      ..cubicTo(9.5, 4.5, 6, 4.5, 3, 5.5)
      ..lineTo(3, 19)
      ..cubicTo(6, 18, 9.5, 18, 12, 20)
      ..cubicTo(14.5, 18, 18, 18, 21, 19)
      ..lineTo(21, 5.5)
      ..cubicTo(18, 4.5, 14.5, 4.5, 12, 6.5)
      ..close();
  }

  /// A single answer bubble. The fill sweep is the metaphor: ink rising
  /// into a bubble is a pencil shading an answer sheet.
  Path _bubble() {
    return Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 8.5));
  }

  /// A sheet with a folded corner and a line rising across it.
  Path _sheet() {
    return Path()
      ..moveTo(5, 3)
      ..lineTo(14.5, 3)
      ..lineTo(19, 7.5)
      ..lineTo(19, 21)
      ..lineTo(5, 21)
      ..close()
      ..moveTo(8, 17)
      ..lineTo(11, 13.5)
      ..lineTo(13.5, 15.5)
      ..lineTo(16, 11);
  }

  @override
  bool shouldRepaint(NavGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.fill != fill ||
        oldDelegate.color != color;
  }
}
