import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  setUp(() {
    db = inMemoryDatabase();
  });
  tearDown(() => db.close());
  Future<void> pump(
    WidgetTester tester, {
    VoidCallback? passed,
    Brightness brightness = Brightness.light,
    double scale = 1,
    AppPreferencesRepository? preferences,
    bool disableAnimations = true,
  }) =>
      pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            if (preferences != null)
              appPreferencesRepositoryProvider.overrideWithValue(preferences),
          ],
          child: OnboardingAgeGateStep(
            currentYear: 2026,
            onAgeGatePassed: passed ?? () {},
          ),
        ),
        brightness: brightness,
        textScale: scale,
        viewportSize: const Size(390, 844),
        disableAnimations: disableAnimations,
      );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('age input and blocked state $brightness $scale',
          (tester) async {
        await pump(tester, brightness: brightness, scale: scale);
        expect(find.text('When were you born?'), findsOneWidget);
        expect(
          find.text('We only ask this once and never keep it.'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Continue'),
              )
              .onPressed,
          isNotNull,
        );
        final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
        expect(wheel.values[wheel.selectedIndex], '2012');
        wheel.onSelected(wheel.values.indexOf('2014'));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text("Pantas isn't available yet"), findsOneWidget);
        expect(find.byType(ValueWheel), findsNothing);
        expect(find.text('Try a Different Year'), findsOneWidget);
        expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Try a Different Year'));
        await tester.pumpAndSettle();
        expect(find.byType(ValueWheel), findsOneWidget);
      });
    }
  }
  testWidgets('age passes at 13 and stores no birth year', (tester) async {
    var passed = 0;
    await pump(tester, passed: () => passed++);
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2013'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
    expect(
      (await db.select(db.devicePrefs).get()).any((row) => row.value == '2013'),
      isFalse,
    );
  });
  testWidgets('failed age save keeps the year and retries the same write',
      (tester) async {
    var passed = 0;
    await pump(
      tester,
      passed: () => passed++,
      preferences: _FailingAgePreferences(db),
    );
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2013'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    expect(passed, 0);
    final retained = tester.widget<ValueWheel>(find.byType(ValueWheel));
    expect(retained.values[retained.selectedIndex], '2013');
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('blocked state fades as one frame and returning pushes the frame',
      (tester) async {
    await pump(tester, disableAnimations: false);
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2014'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    final fade = find
        .ancestor(
          of: find.text('Try a Different Year'),
          matching: find.byType(Opacity),
        )
        .first;
    expect(fade, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<Opacity>(fade).opacity, closeTo(.802403, .002));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Try a Different Year'));
    await tester.pump();
    final slide = find
        .descendant(
          of: find.byKey(const ValueKey('age-return-motion')),
          matching: find.byType(Transform),
        )
        .first;
    expect(slide, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 190));
    expect(
      tester.widget<Transform>(slide).transform.storage[12],
      closeTo(2.00213, .03),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('year selection can be changed with the keyboard',
      (tester) async {
    await pump(tester);
    Focus.of(
      tester.element(find.byType(ListWheelScrollView)),
      createDependency: false,
    ).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    expect(wheel.values[wheel.selectedIndex], '2013');
    expect(tester.takeException(), isNull);
  });
}

class _FailingAgePreferences extends AppPreferencesRepository {
  _FailingAgePreferences(super.db);
  bool fail = true;
  @override
  Future<void> setPassedAgeGate({required bool value}) async {
    if (fail) {
      fail = false;
      throw StateError('private details');
    }
    await super.setPassedAgeGate(value: value);
  }
}
