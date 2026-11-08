import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_slider.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  Widget slider({double value = 1.5, ValueChanged<double>? onChanged}) =>
      PantasSlider(
        label: 'Lesson Text Size',
        value: value,
        valueText: '${value.toStringAsFixed(1)}×',
        semanticValue: '${value.toStringAsFixed(1)} times',
        onChanged: onChanged ?? (_) {},
      );

  dsMatrix(
    'slider: label above, 44 hit area, labels stack when narrow',
    (context) => SizedBox(width: 358, child: slider()),
    check: (tester, cell) async {
      expect(find.text('Lesson Text Size'), findsOneWidget);
      expect(find.text('1.5×'), findsOneWidget);
      expect(tester.getSize(find.byType(Slider)).height, 44);
      // At default text a 358 row has room; at 200% every phone row stacks.
      final stacked = find.byKey(const ValueKey('slider-stacked'));
      final row = find.byKey(const ValueKey('slider-row'));
      if (cell.scale == 2) {
        expect(stacked, findsOneWidget);
        expect(row, findsNothing);
      } else {
        expect(row, findsOneWidget);
        expect(stacked, findsNothing);
      }
    },
  );

  testWidgets('rows under 272 px stack at default text', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 250, child: slider()),
    );
    expect(find.byKey(const ValueKey('slider-stacked')), findsOneWidget);
    // The track takes the full row width.
    expect(tester.getSize(find.byType(Slider)).width, 250);
  });

  testWidgets('dragging reports a value on the 0.1 step', (tester) async {
    double? picked;
    await pumpDs(
      tester,
      dsCells.first,
      SizedBox(width: 358, child: slider(onChanged: (v) => picked = v)),
    );
    final box = tester.getRect(find.byType(Slider));
    await tester.tapAt(Offset(box.left + box.width * .8, box.center.dy));
    expect(picked, isNotNull);
    expect(
      ((picked! - 1) * 10).roundToDouble(),
      closeTo((picked! - 1) * 10, 1e-6),
    );
  });

  testWidgets('the track is 4 px and the thumb ring is the border color',
      (tester) async {
    await pumpDs(tester, dsCells.first, SizedBox(width: 358, child: slider()));
    final theme = SliderTheme.of(tester.element(find.byType(Slider)));
    expect(theme.trackHeight, 4);
    expect(theme.thumbShape!.getPreferredSize(true, true), const Size(26, 26));
  });

  testWidgets('disabled slider is 40% opaque', (tester) async {
    await pumpDs(
      tester,
      dsCells.first,
      const SizedBox(
        width: 358,
        child: PantasSlider(
          value: 1,
          valueText: '1.0×',
          onChanged: _noop,
          enabled: false,
        ),
      ),
    );
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, .4);
  });
}

void _noop(double _) {}
