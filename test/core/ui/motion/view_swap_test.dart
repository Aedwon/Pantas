import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';

import 'preview_curves.dart';

// Item 17, demo 9: the changing block fades and slides 12 px, 240 ms. The old
// one leaves over 0 to 100 ms on the ease; the new one arrives over 60 to
// 240 ms on the shared ease. With fade off the old one is gone at once and the
// new one slides 24 px.
class _Counter extends StatefulWidget {
  const _Counter(this.label);
  final String label;
  static int builds = 0;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  @override
  void initState() {
    super.initState();
    _Counter.builds++;
  }

  @override
  Widget build(BuildContext context) => Text(widget.label);
}

Widget _app(
  int index, {
  bool fade = true,
  bool reduced = false,
}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: ViewSwap(
                index: index,
                fade: fade,
                child: _Counter(index == 0 ? 'Day' : 'Week'),
              ),
            ),
          ),
        ),
      ),
    );

double _opacity(WidgetTester tester, String text) => tester
    .widget<Opacity>(
      find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first,
    )
    .opacity;

double _x(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dx;

void main() {
  setUp(() => _Counter.builds = 0);

  testWidgets('fade and slide: old out 0 to 100 ms, new in 60 to 240 ms',
      (tester) async {
    await tester.pumpWidget(_app(0));
    final home = _x(tester, 'Day');
    await tester.pumpWidget(_app(1));
    await tester.pump();
    var elapsed = 0;
    for (final ms in [30, 30, 30, 30, 60, 60]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      final out = previewEase(previewPhase(elapsed.toDouble(), 0, 100));
      final inn = previewShared(previewPhase(elapsed.toDouble(), 60, 240));
      if (out < 1) {
        expect(
          _opacity(tester, 'Day'),
          closeTo(1 - out, .01),
          reason: '$elapsed',
        );
        expect(
          _x(tester, 'Day'),
          closeTo(home - 12 * out, .1),
          reason: '$elapsed',
        );
      } else {
        expect(find.text('Day'), findsNothing, reason: 'gone at $elapsed');
      }
      expect(_opacity(tester, 'Week'), closeTo(inn, .01), reason: '$elapsed');
      expect(
        _x(tester, 'Week'),
        closeTo(home + 12 * (1 - inn), .1),
        reason: '$elapsed',
      );
    }
    await tester.pumpAndSettle();
    expect(find.text('Day'), findsNothing);
    expect(_opacity(tester, 'Week'), 1);
    expect(_x(tester, 'Week'), home);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('going back to a lower view mirrors the direction',
      (tester) async {
    await tester.pumpWidget(_app(1));
    final home = _x(tester, 'Week');
    await tester.pumpWidget(_app(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    // The old block drifts right, the new one comes in from the left.
    expect(_x(tester, 'Week'), greaterThan(home));
    expect(_x(tester, 'Day'), lessThan(home));
    await tester.pumpAndSettle();
  });

  testWidgets('slide only: the old block leaves at once, the new slides 24 px',
      (tester) async {
    await tester.pumpWidget(_app(0, fade: false));
    final home = _x(tester, 'Day');
    await tester.pumpWidget(_app(1, fade: false));
    await tester.pump();
    var elapsed = 0;
    for (final ms in [60, 60, 60, 60]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      expect(find.text('Day'), findsNothing);
      expect(_opacity(tester, 'Week'), 1);
      expect(
        _x(tester, 'Week'),
        closeTo(home + 24 * (1 - previewShared(elapsed / 240)), .1),
        reason: '$elapsed',
      );
    }
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion shows the new block in one frame',
      (tester) async {
    await tester.pumpWidget(_app(0, reduced: true));
    await tester.pumpWidget(_app(1, reduced: true));
    await tester.pump();
    expect(find.text('Day'), findsNothing);
    expect(_opacity(tester, 'Week'), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the new block is built once and keeps its state to the end',
      (tester) async {
    await tester.pumpWidget(_app(0));
    await tester.pumpWidget(_app(1));
    await tester.pump();
    final during = _Counter.builds;
    await tester.pumpAndSettle();
    expect(_Counter.builds, during, reason: 'no rebuild when the swap ends');
  });

  testWidgets('the leaving block takes no taps and has no semantics',
      (tester) async {
    await tester.pumpWidget(_app(0));
    await tester.pumpWidget(_app(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(
      find.ancestor(of: find.text('Day'), matching: find.byType(IgnorePointer)),
      findsWidgets,
    );
    expect(
      find.ancestor(
        of: find.text('Day'),
        matching: find.byType(ExcludeSemantics),
      ),
      findsWidgets,
    );
    await tester.pumpAndSettle();
  });
}
