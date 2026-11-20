import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/figure_registry.dart';
import 'package:pantas/core/ui/figures/grid_polygon_figure.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

/// The four content figures, as the content lead writes them.
const _specs = <String, Map<String, Object?>>{
  'q0006-split': {
    'kind': 'grid-polygon',
    'width': 8,
    'height': 4,
    'vertices': [
      [0, 0],
      [8, 0],
      [5, 4],
      [0, 4],
    ],
    'xTicks': [0, 5, 8],
  },
  'q0006-solution': {
    'kind': 'grid-polygon',
    'width': 8,
    'height': 4,
    'vertices': [
      [0, 0],
      [8, 0],
      [5, 4],
      [0, 4],
    ],
    'xTicks': [0, 5, 8],
    'splits': [
      [
        [5, 0],
        [5, 4],
      ],
    ],
    'labels': [
      {
        'at': [2.5, 2],
        'text': '5 × 4 = 20',
      },
      {
        'at': [6.4, 0.9],
        'text': '6',
      },
    ],
  },
  'q0012-surrounding': {
    'kind': 'grid-polygon',
    'width': 6,
    'height': 5,
    'vertices': [
      [0, 0],
      [6, 0],
      [6, 2],
      [4, 5],
      [0, 5],
    ],
  },
  'q0016-comparison': {
    'kind': 'grid-polygon',
    'panels': [
      {
        'title': 'P',
        'width': 6,
        'height': 4,
        'vertices': [
          [0, 0],
          [6, 0],
          [4, 4],
          [0, 4],
        ],
      },
      {
        'title': 'Q',
        'width': 5,
        'height': 5,
        'vertices': [
          [0, 0],
          [5, 0],
          [5, 5],
          [0, 3],
        ],
      },
    ],
  },
  'q0014-missing-corner': {
    'kind': 'grid-polygon',
    'width': 4,
    'height': 4,
    'gridWithinPolygon': true,
    'vertices': [
      [0, 0],
      [4, 0],
      [4, 3],
      [3, 3],
      [3, 4],
      [0, 4],
    ],
  },
};

void main() {
  group('spec parsing', () {
    test('the registry builds every content figure', () {
      for (final entry in _specs.entries) {
        expect(
          FigureRegistry.build(entry.value),
          isA<GridPolygonFigure>(),
          reason: entry.key,
        );
      }
    });

    test('reads 8 by 4 and 4 by 4 grids and any vertices', () {
      final wide = GridPolygonFigure.fromSpec(_specs['q0006-split']!)!;
      expect(wide.panels.single.width, 8);
      expect(wide.panels.single.height, 4);
      expect(wide.panels.single.vertices.length, 4);
      final square = GridPolygonFigure.fromSpec(
        _specs['q0014-missing-corner']!,
      )!;
      expect(square.panels.single.width, 4);
      expect(square.panels.single.vertices.length, 6);
      expect(square.panels.single.gridWithinPolygon, isTrue);
    });

    test('a question spec with no split or label draws the shape only', () {
      final panel =
          GridPolygonFigure.fromSpec(_specs['q0006-split']!)!.panels.single;
      expect(panel.splits, isEmpty);
      expect(panel.labels, isEmpty);
    });

    test('reads splits, labels and ticks', () {
      final panel =
          GridPolygonFigure.fromSpec(_specs['q0006-solution']!)!.panels.single;
      expect(panel.splits.length, 1);
      expect(panel.labels.first.$2, '5 × 4 = 20');
      expect(panel.xTicks, [0, 5, 8]);
    });

    test('reads two panels with titles', () {
      final figure = GridPolygonFigure.fromSpec(_specs['q0016-comparison']!)!;
      expect(figure.panels.map((p) => p.title), ['P', 'Q']);
    });

    test('a bad spec reads as null', () {
      Map<String, Object?> with_(String key, Object? value) =>
          {..._specs['q0006-solution']!, key: value};
      expect(GridPolygonFigure.fromSpec(with_('width', 0)), isNull);
      expect(GridPolygonFigure.fromSpec(with_('width', 99)), isNull);
      expect(GridPolygonFigure.fromSpec(with_('width', 'x')), isNull);
      expect(
        GridPolygonFigure.fromSpec(
          with_('vertices', [
            [0, 0],
            [1, 1],
          ]),
        ),
        isNull,
      );
      // A vertex outside the grid.
      expect(
        GridPolygonFigure.fromSpec(
          with_('vertices', [
            [0, 0],
            [9, 0],
            [0, 4],
          ]),
        ),
        isNull,
      );
      expect(GridPolygonFigure.fromSpec(with_('xTicks', [9])), isNull);
      expect(
        GridPolygonFigure.fromSpec(
          with_('labels', [
            {
              'at': [1, 1],
              'text': '',
            },
          ]),
        ),
        isNull,
      );
      expect(
        GridPolygonFigure.fromSpec(
          with_('splits', [
            [
              [1, 1],
              [1, 1],
            ],
          ]),
        ),
        isNull,
      );
      expect(GridPolygonFigure.fromSpec(with_('panels', [])), isNull);
    });
  });

  testWidgets('a question draws the figure from its JSON spec', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const QuestionFigure(
        specJson: '{"kind":"grid-polygon","width":4,"height":4,'
            '"vertices":[[0,0],[4,0],[4,4]]}',
      ),
    );
    expect(find.byType(GridPolygonFigure), findsOneWidget);
    expect(find.textContaining('has not been drawn'), findsNothing);
  });

  for (final entry in _specs.entries) {
    dsMatrix(
      'grid polygon ${entry.key} fits without overflow',
      (context) => FigureRegistry.build(entry.value)!,
      check: (tester, cell) async {
        final box = tester.getSize(find.byType(GridPolygonFigure));
        expect(box.width, lessThanOrEqualTo(cell.width));
      },
    );
  }

  group('render', () {
    final outDir = Platform.environment['GRID_POLYGON_OUT'];

    Future<ui.Image> render(
      WidgetTester tester,
      Map<String, Object?> spec, {
      required bool dark,
    }) async {
      final key = GlobalKey();
      await pumpDs(
        tester,
        DsCell(390, 1, dark: dark),
        RepaintBoundary(
          key: key,
          child: Builder(
            builder: (context) => ColoredBox(
              color: context.colors.background,
              child: SizedBox(
                width: 358,
                child: FigureRegistry.build(spec),
              ),
            ),
          ),
        ),
      );
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() => boundary.toImage(pixelRatio: 2)))!;
    }

    for (final dark in [false, true]) {
      for (final entry in _specs.entries) {
        testWidgets('${entry.key} ${dark ? 'dark' : 'light'}', (tester) async {
          await loadDsFonts();
          final image = await render(tester, entry.value, dark: dark);
          final data = (await tester.runAsync(image.toByteData))!;
          // The outline is the app accent: some pixels carry exactly it.
          final colors = (dark ? buildDarkTheme() : buildLightTheme())
              .extension<PantasColors>()!;
          var outline = 0;
          var fill = 0;
          final target = colors.accent;
          // The fill is the accent at 18% over the page background.
          final bg = colors.background;
          int mix(double t, double b) =>
              (t * 255 * 0.18 + b * 255 * 0.82).round();
          final fr = mix(target.r, bg.r);
          final fg = mix(target.g, bg.g);
          final fb = mix(target.b, bg.b);
          for (var i = 0; i < data.lengthInBytes; i += 4) {
            final r = data.getUint8(i);
            final g = data.getUint8(i + 1);
            final b = data.getUint8(i + 2);
            if (r == (target.r * 255).round() &&
                g == (target.g * 255).round() &&
                b == (target.b * 255).round()) {
              outline++;
            } else if ((r - fr).abs() <= 2 &&
                (g - fg).abs() <= 2 &&
                (b - fb).abs() <= 2) {
              fill++;
            }
          }
          expect(outline, greaterThan(200), reason: 'solid outline');
          expect(fill, greaterThan(1000), reason: 'translucent fill');
          if (outDir != null) {
            final png = (await tester.runAsync(
              () => image.toByteData(format: ui.ImageByteFormat.png),
            ))!;
            await tester.runAsync(() async {
              await Directory(outDir).create(recursive: true);
              await File(
                '$outDir/${entry.key}-${dark ? 'dark' : 'light'}.png',
              ).writeAsBytes(png.buffer.asUint8List());
            });
          }
        });
      }
    }
  });
}
