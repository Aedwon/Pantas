import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

void _still(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<void> _mount(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .descendant(
            of: find.byType(PressScale),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform
    .entry(0, 0);

void main() {
  group('WebButton', () {
    testWidgets('shrinks under a press and springs back', (tester) async {
      await _mount(tester, WebButton(label: 'Save', onPressed: () {}));
      expect(_scale(tester), 1);
      final press =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final middle = _scale(tester);
      expect(middle, inExclusiveRange(.96, 1));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_scale(tester), closeTo(.96, .001));
      await press.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(_scale(tester), inExclusiveRange(.96, 1));
      await tester.pumpAndSettle();
      expect(_scale(tester), 1);
    });

    testWidgets('a disabled button does not shrink', (tester) async {
      await _mount(tester, const WebButton(label: 'Save'));
      final press =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(_scale(tester), 1);
      await press.up();
    });

    testWidgets('colors fade over the shared 160 ms', (tester) async {
      await _mount(tester, WebButton(label: 'Save', onPressed: () {}));
      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.animationDuration, const Duration(milliseconds: 160));
    });

    testWidgets('reduced motion neither shrinks nor fades', (tester) async {
      _still(tester);
      await _mount(tester, WebButton(label: 'Save', onPressed: () {}));
      final press =
          await tester.startGesture(tester.getCenter(find.text('Save')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.descendant(
          of: find.byType(PressScale),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
      await press.up();
      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.animationDuration, Duration.zero);
    });
  });

  group('WebBottomBar', () {
    Future<void> mountBar(WidgetTester tester, WebBarState state) => _mount(
          tester,
          SizedBox(
            width: 720,
            child: WebBottomBar(
              counter: '1 of 10',
              action: const Text('Next'),
              state: state,
            ),
          ),
        );

    Color? fill(WidgetTester tester) => (tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer))
            .decoration! as BoxDecoration)
        .color;

    Color? shown(WidgetTester tester) => (tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(AnimatedContainer),
                matching: find.byType(DecoratedBox),
              ),
            )
            .first
            .decoration as BoxDecoration)
        .color;

    testWidgets('fades to a result in 300 ms and back in 250 ms',
        (tester) async {
      await mountBar(tester, WebBarState.neutral);
      final neutral = shown(tester);
      await mountBar(tester, WebBarState.right);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final middle = shown(tester);
      expect(middle, isNot(neutral));
      expect(middle, isNot(fill(tester)));
      await tester.pump(const Duration(milliseconds: 250));
      expect(shown(tester), fill(tester));

      await mountBar(tester, WebBarState.neutral);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(shown(tester), isNot(neutral));
      await tester.pump(const Duration(milliseconds: 200));
      expect(shown(tester), neutral);
    });

    testWidgets('reduced motion changes color at once', (tester) async {
      _still(tester);
      await mountBar(tester, WebBarState.neutral);
      await mountBar(tester, WebBarState.wrong);
      await tester.pump();
      expect(shown(tester), fill(tester));
    });
  });

  group('WebRootModal', () {
    var dismissed = 0;
    Future<void> mountModal(WidgetTester tester, {bool dismissible = true}) =>
        tester.pumpWidget(
          MaterialApp(
            theme: buildLightTheme(web: true),
            home: WebRootModal(
              onDismiss: dismissible ? () => dismissed++ : null,
              modal: (_) => const SizedBox(
                key: Key('dialog'),
                width: 400,
                height: 200,
              ),
              child: const Scaffold(body: Text('Page')),
            ),
          ),
        );

    Opacity fade(WidgetTester tester) => tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(const Key('dialog')),
                matching: find.byType(Opacity),
              )
              .first,
        );

    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      dismissed = 0;
    }

    testWidgets('the scrim and dialog fade in and the dialog rises',
        (tester) async {
      await open(tester);
      await mountModal(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      expect(fade(tester).opacity, inExclusiveRange(0, 1));
      final rising = tester.getTopLeft(find.byKey(const Key('dialog'))).dy;
      final scrim = tester
          .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
          .color
          .value!;
      expect(scrim.a, inExclusiveRange(0, .32));
      await tester.pumpAndSettle();
      expect(fade(tester).opacity, 1);
      expect(
        tester.getTopLeft(find.byKey(const Key('dialog'))).dy,
        lessThan(rising),
      );
      expect(
        tester.getCenter(find.byKey(const Key('dialog'))),
        const Offset(720, 450),
      );
      expect(
        tester
            .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
            .color
            .value,
        const Color(0x521D1D1F),
      );
    });

    testWidgets('a scrim tap dismisses only when asked to', (tester) async {
      await open(tester);
      await mountModal(tester);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(40, 40));
      expect(dismissed, 1);
      await mountModal(tester, dismissible: false);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(40, 40));
      expect(dismissed, 1);
    });

    testWidgets('reduced motion shows the dialog at once', (tester) async {
      _still(tester);
      await open(tester);
      await mountModal(tester);
      await tester.pump();
      await tester.pump();
      expect(fade(tester).opacity, 1);
      expect(
        tester.getCenter(find.byKey(const Key('dialog'))),
        const Offset(720, 450),
      );
    });
  });
}
