import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';

const _panel = Key('panel');

Future<void> _open(
  WidgetTester tester, {
  required WebOverlayMotion motion,
  bool still = false,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
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

  testWidgets('reduced motion shows the overlay at once', (tester) async {
    await _open(tester, motion: WebOverlayMotion.drawer, still: true);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
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

    Future<void> mount(WidgetTester tester, {bool still = false}) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
                      onDismiss: () {},
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

    testWidgets('reduced motion puts it in place at once', (tester) async {
      await mount(tester, still: true);
      expect(tester.getTopLeft(find.byKey(_panel)).dx, 1040);
    });
  });
}
