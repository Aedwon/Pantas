import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_floating_bar.dart';

void main() {
  Widget harness({
    int position = 12,
    int total = 40,
    bool isFlagged = false,
    VoidCallback? onPrevious = _noop,
    VoidCallback? onNext = _noop,
    VoidCallback? onGrid,
    VoidCallback? onFlag,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MockFloatingBar(
            position: position,
            total: total,
            isFlagged: isFlagged,
            onPrevious: onPrevious,
            onNext: onNext,
            onGrid: onGrid ?? () {},
            onFlag: onFlag ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('previous is leftmost and next is rightmost', (tester) async {
    await tester.pumpWidget(harness());

    final prevX = tester.getCenter(find.byKey(const ValueKey('mock-prev'))).dx;
    final gridX = tester.getCenter(find.byKey(const ValueKey('mock-grid'))).dx;
    final nextX = tester.getCenter(find.byKey(const ValueKey('mock-next'))).dx;
    expect(prevX, lessThan(gridX));
    expect(gridX, lessThan(nextX));
  });

  testWidgets('the counter opens the grid too', (tester) async {
    var opened = 0;
    await tester.pumpWidget(harness(onGrid: () => opened += 1));

    await tester.tap(find.text('12 of 40'));
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    expect(opened, 2);
  });

  testWidgets('previous dims at the first item and stays in place',
      (tester) async {
    await tester.pumpWidget(harness(onPrevious: null));

    final before = tester.getCenter(find.byKey(const ValueKey('mock-grid')));
    expect(find.byKey(const ValueKey('mock-prev')), findsOneWidget);

    await tester.pumpWidget(harness());
    expect(tester.getCenter(find.byKey(const ValueKey('mock-grid'))), before);
  });

  testWidgets('a dimmed control does not fire', (tester) async {
    var moved = 0;
    await tester.pumpWidget(harness(onNext: null, onGrid: () => moved += 1));

    await tester.tap(find.byKey(const ValueKey('mock-next')));
    expect(moved, 0);
  });

  testWidgets('every control reaches 46', (tester) async {
    await tester.pumpWidget(harness());

    for (final key in ['mock-prev', 'mock-grid', 'mock-flag', 'mock-next']) {
      final size = tester.getSize(find.byKey(ValueKey(key)));
      expect(size.width, greaterThanOrEqualTo(46));
      expect(size.height, greaterThanOrEqualTo(46));
    }
  });

  testWidgets('the bar is 54 tall', (tester) async {
    await tester.pumpWidget(harness());

    expect(tester.getSize(find.byType(MockFloatingBar)).height, 54);
  });

  testWidgets('the grid side carries five more pixels than the base gap',
      (tester) async {
    await tester.pumpWidget(harness());

    // An optical correction: the grid glyph is dense to its edges and the
    // pennant carries its own whitespace, so equal metric gaps read
    // unequal. Not to be normalised.
    expect(
      tester.widget<MockFloatingBar>(find.byType(MockFloatingBar)).gridSideGap,
      21,
    );
  });

  testWidgets('the flag reads its state', (tester) async {
    await tester.pumpWidget(harness(isFlagged: true));
    expect(find.byKey(const ValueKey('mock-flag')), findsOneWidget);

    var flagged = 0;
    await tester.pumpWidget(harness(onFlag: () => flagged += 1));
    await tester.tap(find.byKey(const ValueKey('mock-flag')));
    expect(flagged, 1);
  });
}

void _noop() {}
