import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

/// A canvas that keeps what a painter draws, so these tests check the real
/// painters and not a copy of their maths.
class _RecordingCanvas implements Canvas {
  final lines = <(Offset, Offset)>[];
  final circles = <(Offset, double)>[];
  final paragraphs = <(ui.Paragraph, Offset)>[];
  final shapeBounds = <Rect>[];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => lines.add((p1, p2));

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    circles.add((c, radius));
    shapeBounds.add(Rect.fromCircle(center: c, radius: radius));
  }

  @override
  void drawRect(Rect rect, Paint paint) => shapeBounds.add(rect);

  @override
  void drawPath(Path path, Paint paint) => shapeBounds.add(path.getBounds());

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) =>
      paragraphs.add((paragraph, offset));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const _forms = ['square', 'circle', 'triangle', 'pentagon', 'star'];

SeriesItem _item(Map<String, Object?> entry) =>
    FigureSeriesFigure.parseItem(entry)!;

double _toSegment(Offset p, Offset a, Offset b) {
  final edge = b - a;
  final len2 = edge.dx * edge.dx + edge.dy * edge.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * edge.dx + (p - a).dy * edge.dy) / len2).clamp(
    0.0,
    1.0,
  );
  return (p - (a + edge * t)).distance;
}

/// How far [p] is from the outline of [form], or negative when outside.
double _clearance(String form, Offset centre, double r, Offset p) {
  final corners = SeriesGeometry.corners(form, centre, r);
  if (corners == null) return r - (p - centre).distance;
  var best = double.infinity;
  for (var i = 0; i < corners.length; i++) {
    best = math.min(
      best,
      _toSegment(p, corners[i], corners[(i + 1) % corners.length]),
    );
  }
  final inside = SeriesGeometry.formPath(form, centre, r).contains(p);
  return inside ? best : -best;
}

_RecordingCanvas _paint(SeriesItem item, Offset centre, double r) {
  final canvas = _RecordingCanvas();
  FigureSeriesFigure.paintItem(
    canvas,
    item,
    centre,
    r,
    const SeriesPalette(
      ink: Colors.black,
      paper: Colors.white,
      frame: Colors.grey,
      mark: Colors.grey,
    ),
  );
  return canvas;
}

void main() {
  group('figure series: the dot row is clear of every line', () {
    const centre = Offset(100, 100);
    // The base radius a series draws at on a phone, and a large one.
    const radii = [20.0, 39.6];
    var shortest = 1.0;

    void expectClear(
      List<double> degrees,
      String form,
      int dots,
      double base,
      double scale,
    ) {
      final item = _item({
        'form': form,
        'dots': dots,
        if (degrees.length == 1) 'line': degrees.first,
        if (degrees.length > 1) 'lines': degrees,
      });
      final r = base * scale;
      final canvas = _paint(item, centre, r);
      final drawn = canvas.lines;
      final reason = '$form dots=$dots lines=$degrees r=$r';
      expect(canvas.circles.length, dots, reason: reason);
      // A line is never removed and never cut below 75% of its length.
      expect(drawn.length, degrees.length, reason: '$reason: a line vanished');
      for (var i = 0; i < degrees.length; i++) {
        final angle = (degrees[i] - 90) * math.pi / 180;
        final normal = SeriesGeometry.reach(form, r, angle, 0.8);
        final (a, b) = drawn[i];
        expect(
          (b - a).distance,
          greaterThanOrEqualTo(normal * 0.75 - 1e-6),
          reason: '$reason: line ${degrees[i]} is too short',
        );
        shortest = math.min(shortest, (b - a).distance / normal);
      }
      for (final (dot, radius) in canvas.circles) {
        for (final (a, b) in drawn) {
          expect(
            _toSegment(dot, a, b),
            greaterThanOrEqualTo(radius + 1),
            reason: reason,
          );
        }
        // Stays inside the outline, with its margin.
        expect(
          _clearance(form, centre, r, dot),
          greaterThanOrEqualTo(radius + 1),
          reason: reason,
        );
      }
    }

    test('one line at every 45 degrees, 0 to 5 dots, every form', () {
      for (final form in _forms) {
        for (final base in radii) {
          for (final scale in [0.62, 0.82, 1.0]) {
            for (var dots = 0; dots <= 5; dots++) {
              for (var degrees = 0; degrees < 360; degrees += 45) {
                expectClear([degrees.toDouble()], form, dots, base, scale);
              }
            }
          }
        }
      }
    });

    test('several lines at once', () {
      const sets = [
        [0.0, 90.0],
        [0.0, 180.0],
        [45.0, 225.0],
        [90.0, 270.0],
        [0.0, 45.0, 90.0, 135.0],
        [0.0, 90.0, 180.0, 270.0],
        [45.0, 135.0, 225.0, 315.0],
      ];
      for (final form in _forms) {
        for (final base in radii) {
          for (final degrees in sets) {
            for (var dots = 1; dots <= 5; dots++) {
              expectClear(degrees, form, dots, base, 1);
            }
          }
        }
      }
    });

    test('an arrow is also kept clear of the dots', () {
      for (final form in _forms) {
        for (final arrow in ['up', 'right', 'down', 'left']) {
          for (var dots = 1; dots <= 5; dots++) {
            final item = _item({'form': form, 'dots': dots, 'arrow': arrow});
            final canvas = _paint(item, centre, 39.6);
            final shaft = canvas.lines.first;
            final angle = ((const {
                      'up': 0.0,
                      'right': 90.0,
                      'down': 180.0,
                      'left': 270.0,
                    })[arrow]! -
                    90) *
                math.pi /
                180;
            final reach = SeriesGeometry.reach(form, 39.6, angle, 0.7);
            expect(canvas.lines.length, 3, reason: '$form $arrow $dots');
            expect(
              (shaft.$2 - shaft.$1).distance,
              greaterThanOrEqualTo(reach * 0.75 - 1e-6),
              reason: '$form $arrow $dots: arrow too short',
            );
            // The head stays whole.
            for (final head in canvas.lines.skip(1)) {
              expect(
                (head.$2 - head.$1).distance,
                closeTo(39.6 * 0.3 * math.min(1, reach / (39.6 * 0.7)), 1e-6),
                reason: '$form $arrow $dots: head cut',
              );
            }
            for (final (dot, radius) in canvas.circles) {
              expect(
                _toSegment(dot, shaft.$1, shaft.$2),
                greaterThanOrEqualTo(radius + 1),
                reason: '$form $arrow $dots',
              );
            }
          }
        }
      }
    });

    test('series 0018: a ray at 90 degrees no longer runs through the dots',
        () {
      // Figure-series 0018, four squares: line 0 and 90 alternate with 1 to
      // 4 dots, at the radius a four-item series draws at on a phone.
      for (final (line, dots) in [(0, 1), (90, 2), (0, 3), (90, 4)]) {
        expectClear([line.toDouble()], 'square', dots, 39.6, 1);
        expectClear([line.toDouble()], 'square', dots, 20, 1);
      }
    });
  });

  group('figure matrix: dots fit the cell form and size', () {
    const centre = Offset(60, 30);
    // A 3 by 3 cell is 60 high at the 180 high grid (radius 18), a 2 by 2
    // cell 65 high (19.5).
    const radii = [18.0, 19.5];
    const sizes = {'small': 0.62, 'medium': 0.82, 'large': 1.0};

    void expectFits(String form, double scale, int dots, double base) {
      final item = _item({'form': form, 'dots': dots});
      final r = base * scale;
      final canvas = _paint(item, centre, r);
      final reason = '$form r=$r dots=$dots';
      expect(canvas.circles.length, dots, reason: reason);
      final circles = canvas.circles;
      for (var i = 0; i < circles.length; i++) {
        final (a, ra) = circles[i];
        // Readable: not smaller than one pixel across two.
        expect(ra, greaterThanOrEqualTo(1.0), reason: reason);
        // Gap from the outline is at least one dot radius.
        expect(
          _clearance(form, centre, r, a) - ra,
          greaterThanOrEqualTo(ra - 1e-6),
          reason: reason,
        );
        for (var j = i + 1; j < circles.length; j++) {
          final (b, rb) = circles[j];
          // Gap between dots is at least one dot diameter.
          expect(
            (a - b).distance - ra - rb,
            greaterThanOrEqualTo(2 * ra - 1e-6),
            reason: reason,
          );
        }
      }
    }

    test('every form at every size with 1 to 5 dots', () {
      for (final form in _forms) {
        for (final scale in sizes.values) {
          for (final base in radii) {
            for (var dots = 1; dots <= 5; dots++) {
              expectFits(form, scale, dots, base);
            }
          }
        }
      }
    });

    test('matrices 0008: small, medium and large triangles with 1 to 3 dots',
        () {
      for (final scale in sizes.values) {
        for (var dots = 1; dots <= 3; dots++) {
          expectFits('triangle', scale, dots, 18);
        }
      }
    });
  });

  group('shape row: position numbers', () {
    const forms = [
      'square',
      'rectangle',
      'rhombus',
      'parallelogram',
      'triangle',
      'circle',
      'pentagon',
      'hexagon',
      'blob',
    ];

    Future<void> checkRow(WidgetTester tester, int count) async {
      tester.view
        ..physicalSize = const Size(360, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final spec = {
        'shapes': [
          for (var i = 0; i < count; i++)
            {
              'form': forms[i % forms.length],
              if (i == 1) 'dots': 2,
              if (forms[i % forms.length] == 'circle') 'lines': 2,
            },
        ],
      };
      final figure = ShapeRowFigure.fromSpec(spec)!;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [PantasColors.light, PantasTypeBundle.create()],
          ),
          home: Scaffold(body: figure),
        ),
      );
      final paint = tester.widget<CustomPaint>(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == '_ShapeRowPainter',
        ),
      );
      final size = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.painter.runtimeType.toString() == '_ShapeRowPainter',
        ),
      );
      final canvas = _RecordingCanvas();
      paint.painter!.paint(canvas, size);

      expect(canvas.paragraphs.length, count, reason: 'one number each');
      final slot = size.width / count;
      // The shapes drawn so far are all the bounds the canvas holds.
      final labelRects = <Rect>[];
      for (var i = 0; i < count; i++) {
        final (paragraph, offset) = canvas.paragraphs[i];
        final rect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          paragraph.longestLine,
          paragraph.height,
        );
        labelRects.add(rect);
        expect(
          rect.center.dx,
          closeTo(slot * (i + 0.5), 0.5),
          reason: 'number ${i + 1} is centred under its shape',
        );
        final canvasRect = Offset.zero & size;
        expect(
          rect.left >= canvasRect.left &&
              rect.right <= canvasRect.right &&
              rect.top >= canvasRect.top &&
              rect.bottom <= canvasRect.bottom,
          isTrue,
          reason: 'number ${i + 1} is inside the canvas',
        );
        for (final shape in canvas.shapeBounds) {
          expect(
            shape.overlaps(rect),
            isFalse,
            reason: 'number ${i + 1} overlaps a shape at $shape',
          );
        }
      }
      // All numbers sit on one line.
      expect(
        labelRects.map((r) => r.top.round()).toSet().length,
        1,
      );
    }

    for (final count in [3, 4, 5]) {
      testWidgets('N = $count: numbers centred, inside, clear of shapes', (
        tester,
      ) async {
        await checkRow(tester, count);
      });
    }

    testWidgets('the numbers use the figure font at a readable size', (
      tester,
    ) async {
      expect(ShapeRowGeometry.labelStyle.fontFamily, 'Source Serif 4');
      expect(ShapeRowGeometry.labelStyle.fontSize, greaterThanOrEqualTo(14));
    });

    testWidgets('the semantics label still lists the shapes in order', (
      tester,
    ) async {
      final figure = ShapeRowFigure.fromSpec({
        'shapes': [
          {'form': 'square'},
          {'form': 'circle'},
          {'form': 'triangle'},
        ],
      })!;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: [PantasColors.light, PantasTypeBundle.create()],
          ),
          home: Scaffold(body: figure),
        ),
      );
      expect(
        find.bySemanticsLabel(
          RegExp(r'^A row of 3 shapes: square, circle, triangle\.'),
        ),
        findsOneWidget,
      );
    });
  });
}
