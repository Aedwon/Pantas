import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/concept_diagram_figure.dart';
import 'package:pantas/core/ui/figures/coordinate_graph_figure.dart';
import 'package:pantas/core/ui/figures/figure_matrix_figure.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:pantas/core/ui/figures/fluid_vessel_figure.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/paper_fold_figure.dart';
import 'package:pantas/core/ui/figures/pulley_system_figure.dart';
import 'package:pantas/core/ui/figures/shape_row_figure.dart';
import 'package:pantas/core/ui/figures/stability_shape_figure.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  PantasColors colors = PantasColors.light,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(extensions: [colors, PantasType.create()]),
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
    ),
  );
}

/// How many teeth an outline has: the runs of points on the tooth radius.
int _teethIn(List<Offset> outline, Offset centre, double radius) {
  bool onTooth(Offset p) => ((p - centre).distance - radius).abs() < 1e-6;
  var runs = 0;
  for (var i = 0; i < outline.length; i++) {
    final previous = outline[(i - 1 + outline.length) % outline.length];
    if (onTooth(outline[i]) && !onTooth(previous)) runs++;
  }
  return runs;
}

double _distanceToOutline(Offset point, List<Offset> corners) {
  var best = double.infinity;
  for (var i = 0; i < corners.length; i++) {
    final a = corners[i];
    final b = corners[(i + 1) % corners.length];
    final edge = b - a;
    final t = (((point - a).dx * edge.dx + (point - a).dy * edge.dy) /
            (edge.dx * edge.dx + edge.dy * edge.dy))
        .clamp(0.0, 1.0);
    best = math.min(best, (point - (a + edge * t)).distance);
  }
  return best;
}

void main() {
  group('rhombus', () {
    test('has four equal sides and is not a square', () {
      final c = ShapeRowGeometry.rhombus(const Offset(50, 50), 30);
      final sides = [
        for (var i = 0; i < 4; i++) (c[(i + 1) % 4] - c[i]).distance,
      ];
      for (final side in sides) {
        expect(side, closeTo(sides.first, 1e-9));
      }
      final tall = (c[2] - c[0]).distance;
      final wide = (c[3] - c[1]).distance;
      expect(tall, isNot(closeTo(wide, 1)));
      // Upright, so it does not read as a turned square.
      expect(c[0].dx, c[2].dx);
      expect(c[1].dy, c[3].dy);
    });
  });

  group('gear teeth', () {
    test('a gear has exactly the tooth count it is given', () {
      const centre = Offset(100, 100);
      for (final teeth in [10, 30, 12, 8, 45]) {
        final outline = GearGeometry.outline(centre, 40, 4, teeth);
        expect(_teethIn(outline, centre, 40), teeth, reason: '$teeth teeth');
      }
    });

    testWidgets('a 10 and 30 tooth pair builds from the spec', (tester) async {
      final figure = FigureRegistry.build(const {
        'kind': 'gear-train',
        'gears': 2,
        'showFirstTurn': false,
        'teeth': [10, 30],
      })!;
      await _pump(tester, figure);
      expect((figure as GearTrainFigure).teeth, [10, 30]);
    });
  });

  group('coordinate grid', () {
    testWidgets('has twelve cells to match twelve units', (tester) async {
      await _pump(
        tester,
        const CoordinateGraphFigure(
          type: 'system',
          formula: 'Crossing at (3, 4)',
          points: [Offset(3, 4)],
        ),
      );
      final box = tester.renderObject(find.byType(CustomPaint).last);
      final grid = PantasColors.light.fill;
      // Eleven inner lines each way: 22 grid lines in the faint color.
      var pattern = paints;
      for (var i = 0; i < 22; i++) {
        pattern = pattern..line(color: grid);
      }
      expect(box, pattern);
      // Ten cells would draw only 18, which cannot satisfy that pattern.
      var tooMany = paints;
      for (var i = 0; i < 23; i++) {
        tooMany = tooMany..line(color: grid);
      }
      expect(box, isNot(tooMany));
    });
  });

  group('Venn diagram', () {
    test('single regions are drawn, each in its own circle only', () {
      final layout = VennLayout.threeCircle(
        const Size(358, 220),
        center: '5',
        overlaps: const {'ab': '10', 'bc': '5', 'ca': '7'},
        singleRegions: const {'a': '23', 'b': '20', 'c': '18'},
      );
      final texts = [for (final (t, _) in layout.numbers) t];
      expect(texts, containsAll(['23', '20', '18', '10', '7', '5']));
      expect(texts, hasLength(7));

      bool inside(Offset p, int i) =>
          (p - layout.centres[i]).distance < layout.radius - 8;
      bool outside(Offset p, int i) =>
          (p - layout.centres[i]).distance > layout.radius + 8;
      Offset at(String text, {int skip = 0}) =>
          layout.numbers.where((n) => n.$1 == text).elementAt(skip).$2;

      final a = at('23');
      expect([inside(a, 0), outside(a, 1), outside(a, 2)], everyElement(true));
      final b = at('20');
      expect([outside(b, 0), inside(b, 1), outside(b, 2)], everyElement(true));
      final c = at('18');
      expect([outside(c, 0), outside(c, 1), inside(c, 2)], everyElement(true));
      final ab = at('10');
      expect(
        [inside(ab, 0), inside(ab, 1), outside(ab, 2)],
        everyElement(true),
      );
      final ca = at('7');
      expect(
        [inside(ca, 0), outside(ca, 1), inside(ca, 2)],
        everyElement(true),
      );
    });
  });

  group('series and matrix figures', () {
    test('dots stay inside every outline, clear of its edge', () {
      const centre = Offset(100, 100);
      for (final form in ['triangle', 'square', 'circle', 'pentagon', 'star']) {
        for (final r in [18.0, 30.0]) {
          for (var count = 1; count <= 4; count++) {
            final row = SeriesGeometry.dotRow(form, centre, r, count);
            final path = SeriesGeometry.formPath(form, centre, r);
            for (final dot in row.centres) {
              for (final edge in [
                const Offset(1, 0),
                const Offset(-1, 0),
                const Offset(0, 1),
                const Offset(0, -1),
              ]) {
                expect(
                  path.contains(dot + edge * row.radius),
                  isTrue,
                  reason: '$form r=$r $count dots',
                );
              }
            }
          }
        }
      }
    });

    test('a corner dot sits clear of a pentagon edge', () {
      const centre = Offset(100, 100);
      final corners = SeriesGeometry.corners('pentagon', centre, 30)!;
      for (final corner in [
        'top-left',
        'top-right',
        'bottom-left',
        'bottom-right',
      ]) {
        final dot = SeriesGeometry.cornerDot('pentagon', corner, centre, 30);
        expect(_distanceToOutline(dot, corners), greaterThan(3 + 2));
      }
    });

    test('lines and arrows stop inside a triangle', () {
      const centre = Offset(100, 100);
      const r = 30.0;
      final path = SeriesGeometry.formPath('triangle', centre, r);
      for (var degrees = 0; degrees < 360; degrees += 15) {
        final angle = (degrees - 90) * math.pi / 180;
        for (final share in [0.8, 0.7]) {
          final length = SeriesGeometry.reach('triangle', r, angle, share);
          final tip =
              centre + Offset(math.cos(angle), math.sin(angle)) * length;
          expect(path.contains(tip), isTrue, reason: '$degrees degrees');
        }
      }
    });

    testWidgets('black and white fill get a fixed panel in dark mode', (
      tester,
    ) async {
      late SeriesPalette named;
      late SeriesPalette plain;
      final namedItems = [
        FigureSeriesFigure.parseItem(
          const {'form': 'circle', 'fill': 'black'},
        )!,
        FigureSeriesFigure.parseItem(
          const {'form': 'circle', 'fill': 'white'},
        )!,
      ];
      final plainItems = [
        FigureSeriesFigure.parseItem(const {'form': 'circle', 'fill': 0.5})!,
        FigureSeriesFigure.parseItem(const {'form': 'circle'})!,
      ];
      await _pump(
        tester,
        Builder(
          builder: (context) {
            named = SeriesPalette.of(context, namedItems);
            plain = SeriesPalette.of(context, plainItems);
            return const SizedBox();
          },
        ),
        colors: PantasColors.dark,
      );
      expect(named.panel, isTrue);
      expect(named.ink, const Color(0xFF1D1D1F));
      expect(named.paper, const Color(0xFFFFFFFF));
      expect(plain.panel, isFalse);
      expect(plain.ink, PantasColors.dark.label);

      await _pump(
        tester,
        Builder(
          builder: (context) {
            named = SeriesPalette.of(context, namedItems);
            return const SizedBox();
          },
        ),
      );
      expect(named.panel, isFalse);
    });

    testWidgets('a matrix naming black and white gets the panel too', (
      tester,
    ) async {
      final figure = FigureMatrixFigure.fromSpec(const {
        'rows': 2,
        'cols': 2,
        'cells': [
          {'form': 'square', 'fill': 'black'},
          {'form': 'square', 'fill': 'white'},
          {'form': 'square', 'fill': 'white'},
          'blank',
        ],
      })!;
      await _pump(tester, figure, colors: PantasColors.dark);
      final box = tester.renderObject(find.byType(CustomPaint).last);
      expect(box, paints..rrect(color: const Color(0xFFFFFFFF)));
    });

    testWidgets('marks over a black fill are paper colored', (tester) async {
      const item = {'form': 'square', 'fill': 'black', 'dots': 1};
      await _pump(
        tester,
        FigureSeriesFigure.fromSpec(const {
          'items': [item, item],
          'blank': false,
        })!,
      );
      final box = tester.renderObject(find.byType(CustomPaint).last);
      expect(
        box,
        paints..circle(color: PantasColors.light.background),
      );
    });
  });

  group('fluid vessels', () {
    test('inner walls stop above the floor and the floor spans the arms', () {
      for (final columns in [2, 3]) {
        final layout =
            FluidVesselGeometry.connected(const Size(358, 140), columns);
        final floorY = layout.floor.$1.dy;
        final reachFloor =
            layout.walls.where((w) => w.$2.dy == floorY).toList();
        expect(reachFloor, hasLength(2), reason: 'only the outer walls');
        final xs = [for (final w in reachFloor) w.$1.dx]..sort();
        expect(layout.floor.$1.dx, xs.first);
        expect(layout.floor.$2.dx, xs.last);
        expect(layout.ceilings, hasLength(columns - 1));
        for (final ceiling in layout.ceilings) {
          expect(ceiling.$1.dy, lessThan(floorY));
        }
      }
    });
  });

  group('stability shapes', () {
    test('a tilted 2 by 3 box keeps its proportions and fits the figure', () {
      const shape = StabilityShape(
        form: 'box',
        baseWidth: 2,
        height: 3,
        tiltDegrees: 22,
      );
      const groundY = 116.0;
      final unit = StabilityGeometry.fitUnit(
        shapes: const [shape],
        slot: 358,
        groundY: groundY,
      );
      final corners = StabilityGeometry.outline(shape, unit);
      expect(
        (corners[1] - corners[0]).distance / (corners[2] - corners[1]).distance,
        closeTo(2 / 3, 1e-9),
      );
      final angle = shape.tiltDegrees * math.pi / 180;
      for (final corner in corners) {
        final y = corner.dx * math.sin(angle) + corner.dy * math.cos(angle);
        expect(groundY + y, greaterThanOrEqualTo(0));
      }
    });
  });

  group('paper folding', () {
    test('every crease of a three-fold sheet is listed', () {
      const full = Rect.fromLTWH(0, 0, 160, 100);
      final creases = PaperFoldGeometry.creases(
        full,
        const ['vertical', 'horizontal', 'vertical'],
      );
      final vertical = creases.where((c) => c.$1.dx == c.$2.dx).toList();
      final horizontal = creases.where((c) => c.$1.dy == c.$2.dy).toList();
      expect(
        {for (final c in vertical) c.$1.dx},
        {40.0, 80.0, 120.0},
      );
      expect({for (final c in horizontal) c.$1.dy}, {50.0});

      // Together the vertical creases run the full height at each place.
      for (final x in [40.0, 80.0, 120.0]) {
        final spans = vertical.where((c) => c.$1.dx == x).toList();
        final ys = [
          for (final c in spans) ...[c.$1.dy, c.$2.dy],
        ];
        expect(ys.reduce(math.min), 0);
        expect(ys.reduce(math.max), 100);
      }
    });

    test('a notch on the fold has its base on the fold', () {
      final points = PaperFoldGeometry.notchOnFold(const Offset(50, 60));
      expect(points[0].dx, 50);
      expect(points[2].dx, 50);
      expect(points[1].dx, greaterThan(50));
    });
  });

  group('pulleys', () {
    testWidgets('a movable pulley hangs from the beam and carries the load', (
      tester,
    ) async {
      await _pump(
        tester,
        const PulleySystemFigure(fixed: 0, movable: 1, comparison: false),
      );
      final paint = find.descendant(
        of: find.byType(PulleySystemFigure),
        matching: find.byType(CustomPaint),
      );
      final box = tester.renderObject(paint);
      final centreX = tester.getSize(paint).width / 2;
      // Both ropes rise to the beam, at y 12, with no gap below it.
      expect(
        box,
        paints
          ..line() // the beam
          ..circle() // the pulley
          ..line(p2: Offset(centreX - 15, 12))
          ..line(p2: Offset(centreX + 15, 12)),
      );
    });
  });
}
