import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/hold_to_repeat.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Widget step() => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingAgeGateStep(
          currentYear: 2026,
          onAgeGatePassed: () {},
        ),
      );

  Future<void> pump(WidgetTester tester) => pumpAccessibilitySurface(
        tester,
        step(),
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );

  String year(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;
  final down = find.byTooltip('Earlier year');
  final up = find.byTooltip('Next year');
  PantasButton continueButton(WidgetTester tester) =>
      tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Continue'),
      );

  testWidgets('390: year field and both step buttons, no wheel',
      (tester) async {
    await pump(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('YEAR'), findsOneWidget);
    expect(down, findsOneWidget);
    expect(up, findsOneWidget);
    expect(find.byType(ValueWheel), findsNothing);
    expect(find.text('Type it, or use the arrows.'), findsOneWidget);
    expect(find.text('Type it, or use ↑ and ↓.'), findsNothing);
  });

  testWidgets('390: each step button is at least 48 by 48', (tester) async {
    await pump(tester);
    for (final finder in [down, up]) {
      final size = tester.getSize(
        find.ancestor(of: finder, matching: find.byType(HoldToRepeat)),
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    // Earlier year sits left of Next year, side by side in one row.
    expect(
      tester.getCenter(down).dx,
      lessThan(tester.getCenter(up).dx),
    );
    expect(tester.getCenter(down).dy, tester.getCenter(up).dy);
  });

  testWidgets('390: an out-of-range year shows the hint and turns Continue off',
      (tester) async {
    await pump(tester);
    expect(continueButton(tester).onPressed, isNotNull);
    await tester.enterText(find.byType(TextField), '1925');
    await tester.pump();
    expect(find.text('Enter a year from 1926 to 2026.'), findsOneWidget);
    expect(continueButton(tester).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '2000');
    await tester.pump();
    expect(find.textContaining('Enter a year from'), findsNothing);
    expect(continueButton(tester).onPressed, isNotNull);
  });

  testWidgets('390: the field takes digits only, at most four', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '');
    await tester.enterText(find.byType(TextField), 'a19b99999');
    await tester.pump();
    expect(year(tester), '1999');
  });

  testWidgets('390: a tap moves one year', (tester) async {
    await pump(tester);
    await tester.tap(up);
    await tester.pump();
    expect(year(tester), '2013');
    await tester.tap(down);
    await tester.tap(down);
    await tester.pump();
    expect(year(tester), '2011');
  });

  testWidgets('390: keyboard or screen-reader activation still steps once',
      (tester) async {
    await pump(tester);
    await tester.tap(up);
    await tester.pump();
    expect(year(tester), '2013');
    tester
        .widget<PantasIconButton>(find.byType(PantasIconButton).last)
        .onPressed!();
    await tester.pump();
    expect(year(tester), '2014');
  });

  group('press and hold', () {
    Future<TestGesture> hold(WidgetTester tester, Finder finder) async {
      final gesture = await tester.startGesture(tester.getCenter(finder));
      await tester.pump();
      return gesture;
    }

    testWidgets('moves one year at 400 ms, then every 150 ms', (tester) async {
      await pump(tester);
      final gesture = await hold(tester, up);
      expect(year(tester), '2013');
      await tester.pump(const Duration(milliseconds: 399));
      expect(year(tester), '2013');
      await tester.pump(const Duration(milliseconds: 1));
      expect(year(tester), '2014');
      await tester.pump(const Duration(milliseconds: 150));
      expect(year(tester), '2015');
      await tester.pump(const Duration(milliseconds: 300));
      expect(year(tester), '2017');
      await gesture.up();
      await tester.pump();
      expect(year(tester), '2017', reason: 'release adds no extra step');
    });

    testWidgets('speeds up to every 50 ms after 1.5 s', (tester) async {
      await pump(tester);
      final gesture = await hold(tester, down);
      expect(year(tester), '2011');
      await tester.pump(const Duration(milliseconds: 400));
      // Repeats at 400, 550, ... 1450 (8), then 1600 (9th) is still slow.
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(year(tester), '${2012 - 1 - 8}');
      await tester.pump(const Duration(milliseconds: 150));
      expect(year(tester), '${2012 - 1 - 9}');
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(year(tester), '${2012 - 1 - 13}');
      await gesture.up();
    });

    testWidgets('stops on release', (tester) async {
      await pump(tester);
      final gesture = await hold(tester, up);
      await tester.pump(const Duration(milliseconds: 400));
      expect(year(tester), '2014');
      await gesture.up();
      await tester.pump(const Duration(seconds: 2));
      expect(year(tester), '2014');
    });

    testWidgets('stops on cancel', (tester) async {
      await pump(tester);
      final gesture = await hold(tester, up);
      await tester.pump(const Duration(milliseconds: 400));
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 2));
      expect(year(tester), '2014');
    });

    testWidgets('stops at the end of the range', (tester) async {
      await pump(tester);
      final gesture = await hold(tester, up);
      await tester.pump(const Duration(seconds: 6));
      expect(year(tester), '2026');
      await gesture.up();
      await tester.pump();
      expect(year(tester), '2026');
      final low = await hold(tester, down);
      await tester.pump(const Duration(seconds: 15));
      expect(year(tester), '1926');
      await low.up();
      await tester.pump();
      expect(year(tester), '1926');
    });
  });

  for (final cell in [
    for (final width in [390.0, 320.0])
      for (final dark in [false, true])
        for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
  ]) {
    testWidgets('matrix: no overflow ($cell)', (tester) async {
      await pumpDs(tester, cell, step(), scroll: false);
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byTooltip('Earlier year'), findsOneWidget);
      expect(find.byTooltip('Next year'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1900');
      await tester.pump();
      expect(find.textContaining('Enter a year from'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
