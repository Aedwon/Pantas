// The held layout with plain boxes: where the plates sit, and that they hold
// in the same frame as the scroll. Spec: "Held figures".
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/held_reader.dart';
import 'package:pantas/core/ui/components/reader_figure_placement.dart';

Widget _box(double h, Key key) => SizedBox(key: key, height: h);

Widget _page({
  required double width,
  required ScrollController controller,
  double viewport = 800,
  double lift = 0,
}) {
  final entries = [
    HeldEntry(child: _box(60, const ValueKey('t0'))),
    HeldEntry(child: _box(900, const ValueKey('t1'))),
    const HeldEntry(kind: FlowKind.heading, child: SizedBox(height: 40)),
    HeldEntry(child: _box(900, const ValueKey('t3'))),
  ];
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(size: Size(width, viewport)),
      child: SizedBox(
        width: width,
        height: viewport,
        child: SingleChildScrollView(
          controller: controller,
          padding: EdgeInsets.only(top: 44 + lift),
          child: HeldReader(
            metrics: HeldMetrics.forWidth(width)!,
            viewportHeight: viewport,
            entries: entries,
            figures: [
              HeldFigure(
                id: 1,
                anchorStart: 1,
                anchorEnd: 1,
                blockStart: 0,
                plate: _box(300, const ValueKey('plate')),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('1440: text 640 wide, plate 400 wide in the right column',
      (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(_page(width: 1440, controller: controller));
    expect(tester.getSize(find.byKey(const ValueKey('t1'))).width, 640);
    expect(tester.getTopLeft(find.byKey(const ValueKey('t1'))).dx, 172);
    final plate = tester.getRect(find.byKey(const ValueKey('plate')));
    expect(plate.width, 400);
    expect(plate.left, 172 + 640 + 56);
    // Level with its anchor, plus 6.
    final anchor = tester.getTopLeft(find.byKey(const ValueKey('t1'))).dy;
    expect(plate.top, anchor + 6);
  });

  testWidgets('1100: 600 text, 300 plate, 40 px margin', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(_page(width: 1100, controller: controller));
    expect(tester.getSize(find.byKey(const ValueKey('t1'))).width, 600);
    expect(tester.getTopLeft(find.byKey(const ValueKey('t1'))).dx, 40);
    final plate = tester.getRect(find.byKey(const ValueKey('plate')));
    expect(plate.width, 300);
    expect(plate.left, 40 + 600 + 48);
  });

  testWidgets('the plate holds at 32 px from the window top in the same frame',
      (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(_page(width: 1440, controller: controller));
    final plateFinder = find.byKey(const ValueKey('plate'));
    final text = find.byKey(const ValueKey('t1'));
    for (final offset in [0.0, 100.0, 300.0, 500.0]) {
      controller.jumpTo(offset);
      await tester.pump();
      final plate = tester.getTopLeft(plateFinder).dy;
      final anchor = tester.getTopLeft(text).dy;
      final rest = anchor + 6;
      expect(
        plate,
        rest > 32 ? rest : 32,
        reason: 'offset $offset',
      );
    }
  });

  testWidgets('the end of the passage pushes the plate away with the scroll',
      (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(_page(width: 1440, controller: controller));
    final plateFinder = find.byKey(const ValueKey('plate'));
    final text = find.byKey(const ValueKey('t1'));
    controller.jumpTo(900);
    await tester.pump();
    final before = tester.getTopLeft(plateFinder).dy;
    final bottom = tester.getBottomLeft(text).dy;
    // Held until the passage end is reached, then the bottom meets it.
    expect(tester.getBottomLeft(plateFinder).dy, lessThanOrEqualTo(bottom));
    controller.jumpTo(1000);
    await tester.pump();
    final after = tester.getTopLeft(plateFinder).dy;
    // The plate moved with the scroll: 100 px up (or clamped at the end).
    expect(before - after, closeTo(100, 0.001));
  });

  testWidgets('the sticky line follows the window, not a scroll listener',
      (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(_page(width: 1440, controller: controller));
    controller.jumpTo(400);
    await tester.pump();
    final y = tester.getTopLeft(find.byKey(const ValueKey('plate'))).dy;
    expect(y, 32);
  });

  testWidgets('a tap on the plate reaches it where it is held', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = ScrollController();
    var taps = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 1440,
          height: 800,
          child: SingleChildScrollView(
            controller: controller,
            child: HeldReader(
              metrics: HeldMetrics.forWidth(1440)!,
              viewportHeight: 800,
              entries: [
                HeldEntry(child: _box(1500, const ValueKey('a'))),
              ],
              figures: [
                HeldFigure(
                  id: 1,
                  anchorStart: 0,
                  anchorEnd: 0,
                  blockStart: 0,
                  plate: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => taps++,
                    child: const SizedBox(height: 200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.jumpTo(600);
    await tester.pump();
    await tester.tapAt(const Offset(172 + 640 + 56 + 50, 32 + 50));
    expect(taps, 1);
  });
}
