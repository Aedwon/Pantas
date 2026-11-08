import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';

/// The Nov 3 motion preview's own curve solver, ported, so the app's numbers
/// are checked against the page that was approved and not against themselves.
double _bezier(double x1, double y1, double x2, double y2, double t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  var a = 0.0;
  var b = 1.0;
  var m = .5;
  for (var i = 0; i < 48; i++) {
    m = (a + b) / 2;
    final x =
        3 * x1 * m * (1 - m) * (1 - m) + 3 * x2 * m * m * (1 - m) + m * m * m;
    if ((x - t).abs() < 1e-6) break;
    if (x < t) {
      a = m;
    } else {
      b = m;
    }
  }
  return 3 * y1 * m * (1 - m) * (1 - m) + 3 * y2 * m * m * (1 - m) + m * m * m;
}

double _ease(double t) => _bezier(.25, .1, .25, 1, t);
double _shared(double t) => _bezier(.32, .72, 0, 1, t);
double _ph(double ms, double a, double b) =>
    ((ms - a) / (b - a)).clamp(0.0, 1.0);

void main() {
  testWidgets('an instant route opens and leaves in no time', (tester) async {
    final route = PaneTransitionRoute<void>(
      page: PaneTransitionPage<void>(
        transition: (_) => PaneTransition.instant,
        child: const Text('page'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(route),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
    expect(find.text('page'), findsOneWidget);
  });

  group('the approved numbers', () {
    test('the curves are the preview curves', () {
      for (final t in [.1, .25, .5, .75, .9]) {
        expect(PantasCurves.fade.transform(t), closeTo(_ease(t), .005));
        expect(PantasCurves.move.transform(t), closeTo(_shared(t), .005));
      }
    });

    test('item 15: the detail leaves 0 to 90 ms and arrives 70 to 240 ms', () {
      for (final ms in <double>[0, 30, 60, 90, 120, 180, 240]) {
        final p = ms / 240;
        expect(
          PaneMotion.outgoingOpacity(p),
          closeTo(1 - _ease(_ph(ms, 0, 90)), .005),
          reason: 'out at $ms ms',
        );
        expect(
          PaneMotion.incomingOpacity(p),
          closeTo(_shared(_ph(ms, 70, 240)), .005),
          reason: 'in at $ms ms',
        );
        expect(
          PaneMotion.incomingLift(p),
          closeTo(8 * (1 - _shared(_ph(ms, 70, 240))), .04),
          reason: 'lift at $ms ms',
        );
      }
      expect(PaneMotion.outgoingOpacity(0), 1);
      expect(PaneMotion.outgoingOpacity(1), 0);
      expect(PaneMotion.incomingOpacity(0), 0);
      expect(PaneMotion.incomingOpacity(1), 1);
      expect(PaneMotion.incomingLift(0), 8);
      expect(PaneMotion.incomingLift(1), 0);
    });

    test('item 1: the page fades in 240 ms on ease with no movement', () {
      for (final ms in <double>[0, 60, 120, 180, 240]) {
        expect(
          PaneMotion.fadeOpacity(ms / 240),
          closeTo(_ease(ms / 240), .005),
        );
      }
    });
  });

  // Two pages that look like Settings: a still heading and list, a detail.
  Widget page(String name) => Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: Colors.white,
              child: Text('Settings', key: ValueKey('heading-$name')),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ColoredBox(
                    color: Colors.white,
                    child: SizedBox(
                      width: 300,
                      height: 500,
                      child: Text('list', key: ValueKey('list-$name')),
                    ),
                  ),
                  Expanded(
                    child: PaneDetailMotion(
                      background: Colors.white,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child:
                            Text('detail $name', key: ValueKey('detail-$name')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> pumpApp(
    WidgetTester tester, {
    bool reduced = false,
    TargetPlatform platform = TargetPlatform.macOS,
  }) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(platform: platform),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: page('a'),
      ),
    );
  }

  Future<void> open(
    WidgetTester tester,
    PaneTransition transition, {
    String name = 'b',
  }) async {
    final context = navigatorKey.currentContext!;
    unawaited(
      navigatorKey.currentState!.push<void>(
        PaneTransitionPage<void>(
          key: ValueKey(name),
          transition: (_) => transition,
          child: page(name),
        ).createRoute(context),
      ),
    );
    // One frame puts the route in the Navigator, one builds it at 0 percent.
    await tester.pump();
    await tester.pump();
  }

  Rect rect(WidgetTester tester, String key) =>
      tester.getRect(find.byKey(ValueKey(key)));

  double opacityOf(WidgetTester tester, String detail) => tester
      .widget<Opacity>(
        find.ancestor(
          of: find.byKey(ValueKey(detail)),
          matching: find.byType(Opacity),
        ),
      )
      .opacity;

  // 0, 25, 50, 75 and 100 percent of 240 ms.
  const quarter = Duration(milliseconds: 60);
  const stops = [0.0, .25, .5, .75, 1.0];

  testWidgets('item 15: heading and list stay put, the detail follows Option A',
      (tester) async {
    await pumpApp(tester);
    final heading = rect(tester, 'heading-a');
    final list = rect(tester, 'list-a');
    final detailAt = rect(tester, 'detail-a');
    await open(tester, PaneTransition.detail);

    for (final stop in stops) {
      if (stop > 0) await tester.pump(quarter);
      final reason = 'at ${(stop * 100).round()} percent';
      for (final name in ['a', 'b']) {
        expect(rect(tester, 'heading-$name'), heading, reason: reason);
        expect(rect(tester, 'list-$name'), list, reason: reason);
      }
      expect(
        opacityOf(tester, 'detail-b'),
        closeTo(PaneMotion.incomingOpacity(stop), .001),
        reason: reason,
      );
      expect(
        rect(tester, 'detail-b').top - detailAt.top,
        closeTo(PaneMotion.incomingLift(stop), .001),
        reason: reason,
      );
      expect(rect(tester, 'detail-b').left, detailAt.left, reason: reason);
      expect(
        opacityOf(tester, 'detail-a'),
        closeTo(PaneMotion.outgoingOpacity(stop), .001),
        reason: reason,
      );
      expect(rect(tester, 'detail-a'), detailAt, reason: reason);
    }
    // Done: the first page has left the screen and the detail has landed.
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('detail-a')), findsNothing);
    expect(rect(tester, 'detail-b'), detailAt);
    expect(opacityOf(tester, 'detail-b'), 1);
  });

  testWidgets('item 15: going back plays the same motion in reverse',
      (tester) async {
    await pumpApp(tester);
    final heading = rect(tester, 'heading-a');
    await open(tester, PaneTransition.detail);
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await tester.pump();
    var previous = opacityOf(tester, 'detail-b');
    for (final stop in stops.reversed.skip(1)) {
      await tester.pump(quarter);
      expect(rect(tester, 'heading-b'), heading);
      expect(rect(tester, 'heading-a'), heading);
      expect(
        opacityOf(tester, 'detail-b'),
        closeTo(PaneMotion.incomingOpacity(stop), .001),
      );
      expect(
        opacityOf(tester, 'detail-a'),
        closeTo(PaneMotion.outgoingOpacity(stop), .001),
      );
      expect(opacityOf(tester, 'detail-b'), lessThanOrEqualTo(previous));
      previous = opacityOf(tester, 'detail-b');
    }
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'detail-a'), 1);
  });

  testWidgets('item 15: with reduced motion the final state shows at once',
      (tester) async {
    await pumpApp(tester, reduced: true);
    final detailAt = rect(tester, 'detail-a');
    await open(tester, PaneTransition.detail);
    expect(opacityOf(tester, 'detail-b'), 1);
    expect(rect(tester, 'detail-b'), detailAt);
    expect(opacityOf(tester, 'detail-a'), 1);
    final fill = tester.widget<ColoredBox>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('detail-b')),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(fill.color, Colors.white, reason: 'nothing shows through');
  });

  testWidgets('item 1: the page fades in and nothing behind it moves',
      (tester) async {
    await pumpApp(tester);
    final heading = rect(tester, 'heading-a');
    final list = rect(tester, 'list-a');
    await open(tester, PaneTransition.fade);

    for (final stop in stops) {
      if (stop > 0) await tester.pump(quarter);
      final reason = 'at ${(stop * 100).round()} percent';
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('heading-b')),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(
        fade.opacity.value,
        closeTo(PaneMotion.fadeOpacity(stop), .001),
        reason: reason,
      );
      for (final name in ['a', 'b']) {
        expect(rect(tester, 'heading-$name'), heading, reason: reason);
        expect(rect(tester, 'list-$name'), list, reason: reason);
      }
      expect(opacityOf(tester, 'detail-a'), 1, reason: reason);
      expect(opacityOf(tester, 'detail-b'), 1, reason: reason);
    }
    await tester.pumpAndSettle();
    expect(rect(tester, 'heading-b'), heading);
  });

  testWidgets('item 1: with reduced motion there is no fade at all',
      (tester) async {
    await pumpApp(tester, reduced: true);
    await open(tester, PaneTransition.fade);
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('heading-b')),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    testWidgets('$platform: the platform transition still slides the page',
        (tester) async {
      await pumpApp(tester, platform: platform);
      final heading = rect(tester, 'heading-a');
      await open(tester, PaneTransition.platform);
      await tester.pump(const Duration(milliseconds: 100));

      expect(rect(tester, 'heading-b').left, greaterThan(heading.left));
      expect(rect(tester, 'heading-a').left, lessThan(heading.left));
      await tester.pumpAndSettle();
      expect(rect(tester, 'heading-b'), heading);
    });
  }
}
