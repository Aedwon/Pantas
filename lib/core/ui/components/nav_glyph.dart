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
    final matrix = Matrix4.diagonal3Values(scale, scale, 1).storage;
    final outline = outlineFor(kind).transform(matrix);

    if (fill > 0) {
      final top = size.height * (1 - fill);
      canvas
        ..save()
        ..clipRect(Rect.fromLTRB(0, top, size.width, size.height))
        ..drawPath(
          fillRegionFor(kind).transform(matrix),
          Paint()..color = color,
        )
        ..restore();
    }

    canvas.drawPath(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * size.width / 23
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Everything the stroke draws. Public so a test can assert on the shape.
  ///
  /// Each glyph is an object with internal structure, which is what makes it
  /// read as a thing rather than a blob at 23px: a roof **and a doorway**, a
  /// spine and two leaves, a sheet with a folded corner and a rising line.
  /// The first cut drew only the outer silhouettes.
  Path outlineFor(NavGlyphKind kind) {
    switch (kind) {
      case NavGlyphKind.home:
        return _house();
      case NavGlyphKind.study:
        return _openBook();
      case NavGlyphKind.quiz:
        return _options();
      case NavGlyphKind.progress:
        return _sheet();
    }
  }

  /// What the ink rises into, which is not always the whole glyph.
  ///
  /// The quiz fills **one** of its three options, because a choice is one
  /// bubble shaded and not three. The progress sheet's rising line is a
  /// stroke, so filling it would print a blob across the page.
  Path fillRegionFor(NavGlyphKind kind) {
    switch (kind) {
      case NavGlyphKind.home:
        return _houseBody();
      case NavGlyphKind.study:
        return _openBookLeaves();
      case NavGlyphKind.quiz:
        return _optionChosen();
      case NavGlyphKind.progress:
        return _sheetBody();
    }
  }

  /// A house: roof apex at the top centre, walls to the baseline, a doorway.
  Path _house() => _houseBody()
    ..moveTo(9.3, 20.5)
    ..lineTo(9.3, 14.2)
    ..lineTo(14.7, 14.2)
    ..lineTo(14.7, 20.5);

  Path _houseBody() => Path()
    ..moveTo(3, 10.5)
    ..lineTo(12, 3)
    ..lineTo(21, 10.5)
    ..lineTo(21, 20.5)
    ..lineTo(3, 20.5)
    ..close();

  /// An open book: two leaves meeting at a central spine.
  ///
  /// Each leaf closes back to where it started, which is the spine, so the
  /// spine needs no segment of its own.
  Path _openBook() => _openBookLeaves();

  Path _openBookLeaves() => Path()
    ..moveTo(12, 6.4)
    ..cubicTo(12, 6.4, 9.2, 4.2, 3.8, 4.2)
    ..lineTo(3.8, 18.4)
    ..cubicTo(9.2, 18.4, 12, 20.6, 12, 20.6)
    ..close()
    ..moveTo(12, 6.4)
    ..cubicTo(12, 6.4, 14.8, 4.2, 20.2, 4.2)
    ..lineTo(20.2, 18.4)
    ..cubicTo(14.8, 18.4, 12, 20.6, 12, 20.6)
    ..close();

  /// Three options with their rules, the middle one shaded when active.
  ///
  /// Chosen by Aedwon on 28 July over the single bubble specced two days
  /// earlier: a lone circle has no internal structure, so beside a house and
  /// a book it read as a dot. The fill still carries the metaphor, because
  /// ink rising into one bubble is a pencil shading an answer.
  Path _options() {
    final path = Path();
    for (final y in const [6.8, 12.0, 17.2]) {
      path
        ..addOval(Rect.fromCircle(center: Offset(6.4, y), radius: 2.3))
        ..moveTo(11.4, y)
        ..lineTo(17.6, y);
    }
    return path;
  }

  Path _optionChosen() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(6.4, 12), radius: 2.3));

  /// A sheet with a folded corner and a line rising across it.
  Path _sheet() => _sheetBody()
    ..moveTo(14, 3.2)
    ..lineTo(14, 8.2)
    ..lineTo(19, 8.2)
    ..moveTo(8, 16.6)
    ..lineTo(10.8, 13.6)
    ..lineTo(13, 15.6)
    ..lineTo(16.2, 11.4);

  Path _sheetBody() => Path()
    ..moveTo(5, 3.2)
    ..lineTo(14, 3.2)
    ..lineTo(19, 8.2)
    ..lineTo(19, 20.8)
    ..lineTo(5, 20.8)
    ..close();

  @override
  bool shouldRepaint(NavGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.fill != fill ||
        oldDelegate.color != color;
  }
}
