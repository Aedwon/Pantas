import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/choice_figure.dart';

void main() {
  final series = jsonEncode({'form': 'square', 'rotation': 45, 'dots': 3});
  final shape = jsonEncode({'form': 'circle', 'lines': 3});

  group('reading one item', () {
    test('a series item and a matrix cell read the same item contract', () {
      expect(ChoiceFigure.parse('figure-series', series), isNotNull);
      expect(ChoiceFigure.parse('figure-matrix', series), isNotNull);
    });

    test('a shape-row shape reads its own fields', () {
      expect(ChoiceFigure.parse('shape-row', shape), isNotNull);
      // A series item is not a shape: it has no `circle` form with dots 9.
      expect(
        ChoiceFigure.parse(
          'shape-row',
          jsonEncode({'form': 'circle', 'dots': 9}),
        ),
        isNull,
      );
    });

    test('cube-net and paper-fold have no single-item painter', () {
      for (final kind in ['cube-net', 'paper-fold', 'gear-train']) {
        expect(ChoiceFigure.parse(kind, series), isNull, reason: kind);
      }
    });

    test('nothing to draw reads as null, not as an error', () {
      expect(ChoiceFigure.parse('figure-series', null), isNull);
      expect(ChoiceFigure.parse('figure-series', ''), isNull);
      expect(ChoiceFigure.parse('figure-series', '{'), isNull);
      expect(ChoiceFigure.parse('figure-series', '[]'), isNull);
      expect(ChoiceFigure.parse(null, series), isNull);
    });

    test('the kind comes from the question figure spec', () {
      expect(
        ChoiceFigure.kindOf(jsonEncode({'kind': 'shape-row'})),
        'shape-row',
      );
      expect(ChoiceFigure.kindOf(null), isNull);
      expect(ChoiceFigure.kindOf('nope'), isNull);
    });
  });

  group('drawing one item', () {
    Future<ByteData> pixels(WidgetTester tester, ChoiceFigure figure) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: SizedBox.square(
                dimension: 100,
                child: ChoiceFigureDrawing(figure: figure),
              ),
            ),
          ),
        ),
      );
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
      return (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData();
        image.dispose();
        return data!;
      }))!;
    }

    int ink(ByteData data) {
      var count = 0;
      for (var i = 3; i < data.lengthInBytes; i += 4) {
        if (data.getUint8(i) > 0) count++;
      }
      return count;
    }

    testWidgets('a series item draws ink', (tester) async {
      final data =
          await pixels(tester, ChoiceFigure.parse('figure-series', series)!);
      expect(ink(data), greaterThan(100));
    });

    testWidgets('a shape draws more ink with more lines', (tester) async {
      final one = ink(
        await pixels(
          tester,
          ChoiceFigure.parse('shape-row', jsonEncode({'form': 'circle'}))!,
        ),
      );
      final three =
          ink(await pixels(tester, ChoiceFigure.parse('shape-row', shape)!));
      expect(one, greaterThan(100));
      expect(three, greaterThan(one));
    });

    testWidgets('a shape draws no position number', (tester) async {
      // The row writes 1 to N under its shapes. A choice shows the shape
      // only, so the bottom of a centered shape holds no ink.
      final data = await pixels(
        tester,
        ChoiceFigure.parse('shape-row', jsonEncode({'form': 'square'}))!,
      );
      expect(ink(data), greaterThan(100));
      for (var y = 88; y < 100; y++) {
        for (var x = 0; x < 100; x++) {
          expect(data.getUint8((y * 100 + x) * 4 + 3), 0, reason: '$x,$y');
        }
      }
    });
  });
}
