import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_end.dart';

// ignore_for_file: cascade_invocations

/// The end screen's motion against frames P06, P06_EndRM and W06.
Future<void> _pumpEnd(
  WidgetTester tester, {
  required double width,
  bool still = false,
  List<bool> outcomes = const [true, false, true],
}) async {
  tester.view
    ..physicalSize = Size(width, width >= 1024 ? 900 : 844)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = width >= 1024;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, width >= 1024 ? 900 : 844),
        disableAnimations: still,
      ),
      child: MaterialApp(
        theme: buildLightTheme(web: width >= 1024),
        home: Scaffold(
          body: FirstRunEnd(
            outcomes: outcomes,
            stems: const ['One', 'Two', 'Three'],
            subjectName: 'Mathematics',
            onDone: () {},
            onOpenMistake: (_) {},
          ),
        ),
      ),
    ),
  );
}

double _strip(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(const ValueKey('quiz-count-strip')))
    .transform
    .getTranslation()
    .y;

double _opacityOf(WidgetTester tester, Key key) => tester
    .widget<Opacity>(
      find.ancestor(of: find.byKey(key), matching: find.byType(Opacity)).first,
    )
    .opacity;

double _scaleOf(WidgetTester tester, Key key) => tester
    .widget<Transform>(
      find
          .ancestor(of: find.byKey(key), matching: find.byType(Transform))
          .first,
    )
    .transform
    .getMaxScaleOnAxis();

void main() {
  group('phone (P06)', () {
    testWidgets('the count rolls 64 px rows, 400 ms then 1200 ms',
        (tester) async {
      await _pumpEnd(tester, width: 390);
      expect(find.byKey(const ValueKey('quiz-count-strip')), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_strip(tester), 0);
      // 400 ms wait, then half way through the 1200 ms: 1000 ms.
      await tester.pump(const Duration(milliseconds: 700));
      expect(
        _strip(tester),
        closeTo(-2 * 64 * PantasCurves.gauge.transform(.5), .01),
      );
      // It is a smooth roll, not a tick: the offset is between two rows.
      expect(_strip(tester) % 64, isNot(0));
      await tester.pump(const Duration(milliseconds: 700));
      expect(_strip(tester), -128);
      await tester.pumpAndSettle();
    });

    testWidgets('the clip is one row tall and fades at the top and bottom',
        (tester) async {
      await _pumpEnd(tester, width: 390);
      final clip = find.ancestor(
        of: find.byKey(const ValueKey('quiz-count-strip')),
        matching: find.byType(ClipRect),
      );
      expect(tester.getSize(clip.first).height, 64);
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('quiz-count-strip')),
          matching: find.byType(ShaderMask),
        ),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
    });

    testWidgets(
        'keeps its own timeline: dots from 400 ms, mistakes from 1620 ms',
        (tester) async {
      await _pumpEnd(tester, width: 390);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_opacityOf(tester, const ValueKey('end-dot-1')), 0);
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 0);
      await tester.pump(const Duration(milliseconds: 1200));
      expect(_opacityOf(tester, const ValueKey('end-dot-1')), 1);
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 0);
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 1);
    });

    testWidgets('the dots start 270 ms apart, at 400, 670 and 940 ms',
        (tester) async {
      await _pumpEnd(tester, width: 390);
      await tester.pump(const Duration(milliseconds: 500));
      expect(_opacityOf(tester, const ValueKey('end-dot-1')), greaterThan(0));
      expect(_opacityOf(tester, const ValueKey('end-dot-2')), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(_opacityOf(tester, const ValueKey('end-dot-2')), greaterThan(0));
      expect(_opacityOf(tester, const ValueKey('end-dot-3')), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(_opacityOf(tester, const ValueKey('end-dot-3')), greaterThan(0));
      await tester.pumpAndSettle();
    });

    testWidgets(
        '"correct" fades in alone at 1600 ms, the row 80 ms behind '
        'the block', (tester) async {
      await _pumpEnd(tester, width: 390);
      final correct = find.text('correct');
      final row = find.text('Two');
      await tester.pump(const Duration(milliseconds: 1550));
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 0);
      await tester.pump(const Duration(milliseconds: 100));
      // 1650 ms: "correct" (from 1600) and the block (from 1620) have begun;
      // the row (from 1700) has not.
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: correct, matching: find.byType(Opacity)).first,
            )
            .opacity,
        greaterThan(0),
      );
      expect(
        _opacityOf(tester, const ValueKey('end-mistakes')),
        greaterThan(0),
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: row, matching: find.byType(Opacity)).first,
            )
            .opacity,
        0,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: row, matching: find.byType(Opacity)).first,
            )
            .opacity,
        greaterThan(0),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Reduce Motion shows the final number at once', (tester) async {
      await _pumpEnd(tester, width: 390, still: true);
      expect(_strip(tester), -128);
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 1);
    });
  });

  group('wide (W06)', () {
    testWidgets('the count rolls from 300 ms for 1200 ms on the enter curve',
        (tester) async {
      await _pumpEnd(tester, width: 1440);
      await tester.pump(const Duration(milliseconds: 250));
      expect(_strip(tester), 0);
      // 300 ms delay, half way through 1200 ms is 900 ms. Rows are 80 px.
      await tester.pump(const Duration(milliseconds: 650));
      expect(
        _strip(tester),
        closeTo(-2 * 80 * PantasCurves.enter.transform(.5), .01),
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(_strip(tester), -160);
      await tester.pumpAndSettle();
    });

    testWidgets('the dots pop 400 ms at .30, .38 and .46 s', (tester) async {
      await _pumpEnd(tester, width: 1440);
      await tester.pump(const Duration(milliseconds: 290));
      for (final n in [1, 2, 3]) {
        expect(_opacityOf(tester, ValueKey('end-dot-$n')), 0);
      }
      // 330 ms: dot 1 is 30 ms in, dot 2 has not started.
      await tester.pump(const Duration(milliseconds: 40));
      expect(_opacityOf(tester, const ValueKey('end-dot-1')), greaterThan(0));
      expect(_opacityOf(tester, const ValueKey('end-dot-2')), 0);
      expect(_opacityOf(tester, const ValueKey('end-dot-3')), 0);
      // 400 ms: dot 2 has started, dot 3 has not.
      await tester.pump(const Duration(milliseconds: 70));
      expect(_opacityOf(tester, const ValueKey('end-dot-2')), greaterThan(0));
      expect(_opacityOf(tester, const ValueKey('end-dot-3')), 0);
      // The spring overshoots to 1.12 at 60 percent: dot 1 at 540 ms.
      await tester.pump(const Duration(milliseconds: 140));
      expect(_scaleOf(tester, const ValueKey('end-dot-1')), greaterThan(1));
      await tester.pump(const Duration(milliseconds: 400));
      for (final n in [1, 2, 3]) {
        expect(_opacityOf(tester, ValueKey('end-dot-$n')), 1);
        expect(_scaleOf(tester, ValueKey('end-dot-$n')), 1);
      }
      await tester.pumpAndSettle();
    });

    testWidgets('the mistakes block rises in .5 s at 1.1 s', (tester) async {
      await _pumpEnd(tester, width: 1440);
      await tester.pump(const Duration(milliseconds: 1050));
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 0);
      await tester.pump(const Duration(milliseconds: 300));
      final mid = _opacityOf(tester, const ValueKey('end-mistakes'));
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 1);
      await tester.pumpAndSettle();
    });

    testWidgets('the title and the line are drawn at once, as on the board',
        (tester) async {
      await _pumpEnd(tester, width: 1440);
      final title = find.text('You finished the lesson');
      expect(
        tester
            .widgetList<Opacity>(
              find.ancestor(of: title, matching: find.byType(Opacity)),
            )
            .where((o) => o.opacity < 1),
        isEmpty,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('Reduce Motion shows everything final at once', (tester) async {
      await _pumpEnd(tester, width: 1440, still: true);
      expect(_strip(tester), -160);
      expect(_opacityOf(tester, const ValueKey('end-mistakes')), 1);
      for (final n in [1, 2, 3]) {
        expect(_opacityOf(tester, ValueKey('end-dot-$n')), 1);
      }
    });
  });
}
