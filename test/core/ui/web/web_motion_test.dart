import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../motion/preview_curves.dart';

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

    testWidgets('colors fade over the shared 150 ms', (tester) async {
      await _mount(tester, WebButton(label: 'Save', onPressed: () {}));
      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.animationDuration, const Duration(milliseconds: 150));
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

  group('WebRootModal exit', () {
    Future<void> mountModal(
      WidgetTester tester, {
      required WebOverlayExit exit,
      VoidCallback? onBack,
      bool still = false,
    }) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 900),
              disableAnimations: still,
            ),
            child: WebRootModal(
              exit: exit,
              onBack: onBack,
              onDismiss: () {},
              modal: (_) => const SizedBox(
                key: Key('dialog'),
                width: 400,
                height: 200,
              ),
              child: const Scaffold(body: Text('Page')),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    double fade(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(const Key('dialog')),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;

    testWidgets('the dialog fades out and the page leaves after it',
        (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mountModal(tester, exit: exit);
      await tester.pumpAndSettle();
      expect(fade(tester), 1);
      exit.close(() => left++);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(fade(tester), inExclusiveRange(0, 1));
      expect(left, 0);
      await tester.pumpAndSettle();
      expect(left, 1);
      expect(fade(tester), 0);
    });

    testWidgets('system Back plays the exit, then runs onBack once',
        (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mountModal(tester, exit: exit, onBack: () => left++);
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(fade(tester), inExclusiveRange(0, 1));
      expect(left, 0);
      await navigator.maybePop();
      await tester.pumpAndSettle();
      expect(left, 1);
    });

    testWidgets('reduced motion leaves at once', (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mountModal(tester, exit: exit, onBack: () => left++, still: true);
      exit.close(() => left++);
      expect(left, 1);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('WebCard selected', () {
    Widget card({required bool selected, bool still = false}) => MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: still),
            child: Scaffold(
              body: WebCard(
                selected: selected,
                child: const SizedBox(width: 200, height: 60),
              ),
            ),
          ),
        );

    Container box(WidgetTester tester) => tester.widget<Container>(
          find
              .descendant(
                of: find.byType(WebCard),
                matching: find.byType(Container),
              )
              .first,
        );
    Color fill(WidgetTester tester) =>
        (box(tester).decoration! as BoxDecoration).color!;
    double outline(WidgetTester tester) {
      final decoration = box(tester).foregroundDecoration as BoxDecoration?;
      return decoration == null
          ? 0
          : (decoration.border! as Border).top.color.a;
    }

    testWidgets('the tint and outline fade in over 150 ms', (tester) async {
      await tester.pumpWidget(card(selected: false));
      final start = fill(tester);
      expect(outline(tester), 0);
      await tester.pumpWidget(card(selected: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      final p = previewEase(.5);
      expect(outline(tester), closeTo(p, .02));
      expect(fill(tester), isNot(start));
      expect(fill(tester), isNot(const Color(0xFFE4F1EE)));
      await tester.pump(const Duration(milliseconds: 90));
      expect(fill(tester), const Color(0xFFE4F1EE));
      expect(outline(tester), 1);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a card that starts selected is not animated', (tester) async {
      await tester.pumpWidget(card(selected: true));
      expect(fill(tester), const Color(0xFFE4F1EE));
      expect(outline(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion changes it at once', (tester) async {
      await tester.pumpWidget(card(selected: false, still: true));
      await tester.pumpWidget(card(selected: true, still: true));
      await tester.pump();
      expect(fill(tester), const Color(0xFFE4F1EE));
      expect(outline(tester), 1);
    });
  });

  group('WebRow hover chevron', () {
    Widget row({bool still = false}) => MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: still),
            child: Scaffold(
              body: SizedBox(
                width: 400,
                child: WebRow(
                  title: 'Practice',
                  chevron: WebRowChevron.hover,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );

    double shown(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(WebChevron),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    Future<TestGesture> hover(WidgetTester tester) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1000, 800));
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Practice')));
      await tester.pump();
      return mouse;
    }

    testWidgets('fades in over 150 ms on hover and out on leaving',
        (tester) async {
      await tester.pumpWidget(row());
      expect(shown(tester), 0);
      final mouse = await hover(tester);
      await tester.pump(const Duration(milliseconds: 75));
      expect(shown(tester), closeTo(previewEase(.5), .02));
      await tester.pump(const Duration(milliseconds: 90));
      expect(shown(tester), 1);
      await mouse.moveTo(const Offset(1000, 800));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(shown(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(shown(tester), 0);
    });

    testWidgets('reduced motion shows it at once', (tester) async {
      await tester.pumpWidget(row(still: true));
      await hover(tester);
      await tester.pump();
      expect(shown(tester), 1);
    });
  });

  group('WebPickerColumn', () {
    final values = [for (var i = 0; i < 30; i++) 'v$i'];

    Widget column(int selected, {bool still = false}) => MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: still),
            child: Scaffold(
              body: Center(
                child: WebPickerColumn(
                  values: values,
                  selectedIndex: selected,
                  label: 'Day',
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        );

    double top(WidgetTester tester, String text) =>
        tester.getTopLeft(find.text(text)).dy;

    testWidgets('rows slide a row to the new value over 240 ms',
        (tester) async {
      await tester.pumpWidget(column(10));
      final settled = top(tester, 'v10');
      await tester.pumpWidget(column(11));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // v11 was one row below the middle and v10 is leaving it upward.
      expect(top(tester, 'v10'), inExclusiveRange(settled - 40, settled));
      expect(top(tester, 'v11'), greaterThan(settled));
      await tester.pump(const Duration(milliseconds: 150));
      expect(top(tester, 'v11'), settled);
      expect(top(tester, 'v10'), settled - 40);
      expect(find.text('v8'), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('quick picks never fall more than a row behind',
        (tester) async {
      await tester.pumpWidget(column(10));
      final middle = top(tester, 'v10');
      for (var i = 11; i <= 20; i++) {
        await tester.pumpWidget(column(i));
        await tester.pump(const Duration(milliseconds: 16));
        // The row now chosen is within one row of the middle.
        expect(top(tester, 'v$i') - middle, lessThanOrEqualTo(40.001));
      }
      await tester.pumpAndSettle();
      expect(top(tester, 'v20'), middle);
    });

    testWidgets('reduced motion moves the rows at once', (tester) async {
      await tester.pumpWidget(column(10, still: true));
      final settled = top(tester, 'v10');
      await tester.pumpWidget(column(14, still: true));
      expect(top(tester, 'v14'), settled);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
