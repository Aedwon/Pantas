import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/pump_app.dart';

const edgeGrow = Cubic(.32, .72, 0, 1);

BoxDecoration frame(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(FloatingBar),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => box.decoration)
    .whereType<BoxDecoration>()
    .firstWhere((decoration) => decoration.color != null);

void main() {
  testWidgets('content opts into exact frame duration and curve',
      (tester) async {
    await tester.pumpApp(
      const FloatingBar.content(
        transitionDuration: Duration(milliseconds: 420),
        transitionCurve: edgeGrow,
        child: Text('Form'),
      ),
    );
    final animation = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(FloatingBar),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect(animation.duration, const Duration(milliseconds: 420));
    expect(animation.curve, edgeGrow);
  });
  testWidgets('normal and omitted content defaults stay unchanged',
      (tester) async {
    for (final state in FloatingBarState.values) {
      await tester.pumpApp(
        FloatingBar(
          left: const SizedBox(),
          counter: '1 of 2',
          right: const SizedBox(),
          state: state,
        ),
      );
      final normal =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(
        normal.duration,
        Duration(
          milliseconds: state == FloatingBarState.neutral ? 250 : 300,
        ),
      );
      expect(normal.curve, Curves.linear);
      await tester.pumpApp(
        FloatingBar.content(state: state, child: const Text('Form')),
      );
      final content =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(content.duration, normal.duration);
      expect(content.curve, Curves.linear);
    }
  });
  testWidgets('frame radius and fill follow the supplied event-relative curve',
      (tester) async {
    var open = false;
    await tester.pumpApp(
      StatefulBuilder(
        builder: (context, update) => FloatingBar.content(
          state: open ? FloatingBarState.neutral : FloatingBarState.wrong,
          radius: open ? 24 : 30,
          transitionDuration: const Duration(milliseconds: 420),
          transitionCurve: edgeGrow,
          child: TextButton(
            onPressed: () => update(() => open = !open),
            child: const Text('Expand'),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(FloatingBar));
    final start = context.colors.floatingWrong;
    final end = context.colors.surface;
    await tester.tap(find.text('Expand'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    final middle = frame(tester);
    expect(middle.color, Color.lerp(start, end, edgeGrow.transform(.5)));
    expect(
      (middle.borderRadius! as BorderRadius).topLeft.x,
      closeTo(30 - 6 * edgeGrow.transform(.5), .001),
    );
    await tester.pump(const Duration(milliseconds: 210));
    expect(frame(tester).color, end);
    expect((frame(tester).borderRadius! as BorderRadius).topLeft.x, 24);
    await tester.pumpApp(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion overrides a caller-supplied duration',
      (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: FloatingBar.content(
          transitionDuration: Duration(seconds: 3),
          transitionCurve: edgeGrow,
          child: Text('Form'),
        ),
      ),
    );
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration,
      Duration.zero,
    );
  });
}
