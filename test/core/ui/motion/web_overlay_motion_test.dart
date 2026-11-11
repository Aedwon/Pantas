import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

const _panel = Key('panel');

/// The operating system's reduced motion setting. A controller left on its
/// default behavior runs at 5% of its time under it, so a fade that must last
/// 150 ms is only proved with this set.
void _systemReducedMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<void> _open(
  WidgetTester tester, {
  required WebOverlayMotion motion,
  bool still = false,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (still) _systemReducedMotion(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(1440, 900),
          disableAnimations: still,
        ),
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => showWebOverlay<void>(
              context: context,
              motion: motion,
              barrierLabel: 'Close',
              barrierColor: Colors.black54,
              builder: (_) => const Align(
                alignment: Alignment.centerRight,
                child: SizedBox(key: _panel, width: 400, height: 900),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
}

void main() {
  testWidgets('a drawer slides in from the right and back out', (tester) async {
    await _open(tester, motion: WebOverlayMotion.drawer);
    final start = tester.getTopLeft(find.byKey(_panel)).dx;
    expect(start, greaterThan(1440));
    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getTopLeft(find.byKey(_panel)).dx;
    expect(middle, lessThan(start));
    expect(middle, greaterThan(1040));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);

    await tester.tapAt(const Offset(100, 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.byKey(_panel)).dx, greaterThan(1040));
    await tester.pumpAndSettle();
    expect(find.byKey(_panel), findsNothing);
  });

  testWidgets('a dialog fades and rises into place', (tester) async {
    await _open(tester, motion: WebOverlayMotion.dialog);
    await tester.pump(const Duration(milliseconds: 40));
    final fade = tester.widget<Opacity>(
      find
          .ancestor(of: find.byKey(_panel), matching: find.byType(Opacity))
          .first,
    );
    expect(fade.opacity, inExclusiveRange(0, 1));
    expect(tester.getTopLeft(find.byKey(_panel)).dy, greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_panel)).dy, 0);
  });

  group('reduced motion fades in place over 150 ms', () {
    double panelOpacity(WidgetTester tester) => tester
        .widget<Opacity>(
          find
              .ancestor(of: find.byKey(_panel), matching: find.byType(Opacity))
              .first,
        )
        .opacity;

    double routeScrim(WidgetTester tester) => tester
        .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier).last)
        .color
        .value!
        .a;

    for (final entry in {
      'drawer': WebOverlayMotion.drawer,
      'dialog': WebOverlayMotion.dialog,
      'lesson': WebOverlayMotion.lesson,
    }.entries) {
      testWidgets('a ${entry.key} route fades with no slide or rise',
          (tester) async {
        await _open(tester, motion: entry.value, still: true);
        final place = tester.getTopLeft(find.byKey(_panel));
        await tester.pump(const Duration(milliseconds: 75));
        expect(tester.getTopLeft(find.byKey(_panel)), place);
        expect(place.dx, 1040);
        expect(place.dy, 0);
        expect(panelOpacity(tester), closeTo(.5, .02));
        expect(routeScrim(tester), closeTo(.54 / 2, .02));
        await tester.pump(const Duration(milliseconds: 76));
        expect(panelOpacity(tester), 1);
        expect(routeScrim(tester), closeTo(.54, .01));
      });
    }

    testWidgets('a route fades out over 150 ms and leaves', (tester) async {
      await _open(tester, motion: WebOverlayMotion.drawer, still: true);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
      expect(panelOpacity(tester), closeTo(.5, .02));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump();
      expect(find.byKey(_panel), findsNothing);
    });
  });

  test('the reduced preset fades in 150 ms with no travel', () {
    const reduced = WebOverlayMotion.reduced;
    expect(reduced.open, PantasDurations.short2);
    expect(reduced.close, PantasDurations.short2);
    expect(reduced.scrim, PantasDurations.short2);
    expect(reduced.open.inMilliseconds, 150);
    expect(reduced.slide, Offset.zero);
    expect(reduced.rise, 0);
    expect(reduced.travel, 0);
    expect(reduced.fade, isTrue);
  });

  test('the drawer carries the phone sheet numbers', () {
    expect(WebOverlayMotion.drawer.open.inMilliseconds, 450);
    expect(WebOverlayMotion.drawer.close.inMilliseconds, 400);
    expect(WebOverlayMotion.dialog.open.inMilliseconds, 420);
    expect(WebOverlayMotion.dialog.close.inMilliseconds, 320);
  });

  test('the lesson rise and popover carry the phone numbers', () {
    expect(WebOverlayMotion.lesson.open.inMilliseconds, 320);
    expect(WebOverlayMotion.lesson.close.inMilliseconds, 320);
    expect(WebOverlayMotion.lesson.rise, 24);
    expect(WebOverlayMotion.lesson.fade, isTrue);
    expect(WebOverlayMotion.popover.open.inMilliseconds, 240);
    expect(WebOverlayMotion.popover.rise, 8);
  });

  testWidgets('a lesson rises 24 px and fades over 320 ms', (tester) async {
    await _open(tester, motion: WebOverlayMotion.lesson);
    await tester.pump(const Duration(milliseconds: 60));
    final fade = tester.widget<Opacity>(
      find
          .ancestor(of: find.byKey(_panel), matching: find.byType(Opacity))
          .first,
    );
    expect(fade.opacity, inExclusiveRange(0, 1));
    expect(tester.getTopLeft(find.byKey(_panel)).dy, inExclusiveRange(0, 24));
    await tester.pump(const Duration(milliseconds: 320));
    expect(tester.getTopLeft(find.byKey(_panel)).dy, 0);
  });

  group('WebOverlayLayer', () {
    const layer = Key('layer');

    Future<void> mount(
      WidgetTester tester, {
      bool still = false,
      WebOverlayExit? exit,
      VoidCallback? onDismiss,
    }) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      if (still) _systemReducedMotion(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 900),
              disableAnimations: still,
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: WebOverlayLayer(
                      key: layer,
                      motion: WebOverlayMotion.drawer,
                      onDismiss: onDismiss ?? () {},
                      exit: exit,
                      child: const SizedBox(key: _panel, width: 400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('a page that opens with a drawer slides it in', (tester) async {
      await mount(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final middle = tester.getTopLeft(find.byKey(_panel)).dx;
      expect(middle, inExclusiveRange(1040, 1440));
      final scrim = tester
          .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
          .color
          .value!;
      expect(scrim.a, inExclusiveRange(0, .28));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
      expect(
        tester
            .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
            .color
            .value,
        const Color(0x47000000),
      );
    });

    testWidgets('reduced motion fades panel and scrim in place over 150 ms',
        (tester) async {
      await mount(tester, still: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
      final fade = tester.widget<Opacity>(
        find
            .ancestor(of: find.byKey(_panel), matching: find.byType(Opacity))
            .first,
      );
      expect(fade.opacity, closeTo(.5, .02));
      expect(
        tester
            .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
            .color
            .value!
            .a,
        closeTo(.28 / 2, .02),
      );
      await tester.pump(const Duration(milliseconds: 76));
      expect(tester.hasRunningAnimations, isFalse);
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.byKey(_panel),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        1,
      );
    });

    Color scrim(WidgetTester tester) => tester
        .widget<AnimatedModalBarrier>(find.byType(AnimatedModalBarrier))
        .color
        .value!;

    testWidgets('closing plays the slide backward, then leaves once',
        (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      var dismissed = 0;
      await mount(tester, exit: exit, onDismiss: () => dismissed++);
      await tester.pumpAndSettle();
      exit.close(() => left++);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(left, 0);
      expect(exit.closing, isTrue);
      final middle = tester.getTopLeft(find.byKey(_panel)).dx;
      expect(middle, inExclusiveRange(1040, 1440));
      expect(scrim(tester).a, inExclusiveRange(0, .28));
      // The scrim no longer answers while the layer leaves.
      await tester.tapAt(const Offset(100, 100));
      expect(dismissed, 0);
      // A second close changes nothing.
      exit.close(() => left += 10);
      await tester.pumpAndSettle();
      expect(left, 1);
      expect(tester.getTopLeft(find.byKey(_panel)).dx, greaterThan(1440));
      expect(scrim(tester).a, 0);
    });

    testWidgets('closing takes the drawer close time', (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mount(tester, exit: exit);
      await tester.pumpAndSettle();
      exit.close(() => left++);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 399));
      expect(left, 0);
      await tester.pump(const Duration(milliseconds: 2));
      await tester.pump();
      expect(left, 1);
    });

    testWidgets('reduced motion fades out over 150 ms, then leaves once',
        (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mount(tester, still: true, exit: exit);
      await tester.pumpAndSettle();
      exit.close(() => left++);
      expect(left, 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(left, 0);
      expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
      expect(scrim(tester).a, inExclusiveRange(0, .28));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pump();
      expect(left, 1);
      expect(tester.hasRunningAnimations, isFalse);
      expect(scrim(tester).a, 0);
    });

    testWidgets('a layer that is not showing leaves at once', (tester) async {
      var left = 0;
      WebOverlayExit().close(() => left++);
      expect(left, 1);
    });

    testWidgets('closing before the slide-in ends turns it round',
        (tester) async {
      final exit = WebOverlayExit();
      var left = 0;
      await mount(tester, exit: exit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final inFlight = tester.getTopLeft(find.byKey(_panel)).dx;
      exit.close(() => left++);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getTopLeft(find.byKey(_panel)).dx, greaterThan(inFlight));
      await tester.pumpAndSettle();
      expect(left, 1);
    });
  });
}
