import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/value_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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
    VoidCallback? guardianNeeded,
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
            onGuardianNeeded: guardianNeeded,
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
        expect(
          find.text("Sorry, this app isn't available for users under 13."),
          findsOneWidget,
        );
        expect(
          find.text('Entered the wrong year? Email contact@pantas.study.'),
          findsOneWidget,
        );
        expect(find.byType(ValueWheel), findsNothing);
        expect(find.text('Try a Different Year'), findsNothing);
        expect(find.byType(PantasButton), findsNothing);
        expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
        expect(await AppPreferencesRepository(db).blockedMinimumAge(), 13);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the block survives a reload', (tester) async {
    await AppPreferencesRepository(db).setBlockedMinimumAge(13);
    await pump(tester);
    await tester.pumpAndSettle();
    expect(find.text("Pantas isn't available yet"), findsOneWidget);
    expect(find.byType(ValueWheel), findsNothing);
    expect(find.text('Try a Different Year'), findsNothing);
  });

  testWidgets('the blocked age comes from the stored setting', (tester) async {
    await AppPreferencesRepository(db).setBlockedMinimumAge(11);
    await pump(tester);
    await tester.pumpAndSettle();
    expect(
      find.text("Sorry, this app isn't available for users under 11."),
      findsOneWidget,
    );
  });

  testWidgets('an adult year passes the gate and stores only the group',
      (tester) async {
    var passed = 0;
    var guardian = 0;
    await pump(
      tester,
      passed: () => passed++,
      guardianNeeded: () => guardian++,
    );
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2000'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(guardian, 0);
    final repo = AppPreferencesRepository(db);
    expect(await repo.hasPassedAgeGate(), isTrue);
    expect(await repo.ageGroup(), 'adult');
    expect(
      (await db.select(db.devicePrefs).get()).any((row) => row.value == '2000'),
      isFalse,
    );
  });

  for (final year in ['2013', '2009', '2008']) {
    testWidgets('$year is a minor: the gate stays shut and a guardian is asked',
        (tester) async {
      var passed = 0;
      var guardian = 0;
      await pump(
        tester,
        passed: () => passed++,
        guardianNeeded: () => guardian++,
      );
      final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
      wheel.onSelected(wheel.values.indexOf(year));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(passed, 0);
      expect(guardian, 1);
      final repo = AppPreferencesRepository(db);
      expect(await repo.hasPassedAgeGate(), isFalse);
      expect(await repo.ageGroup(), 'minor');
      expect(
        (await db.select(db.devicePrefs).get()).any((row) => row.value == year),
        isFalse,
        reason: 'no birth year is stored',
      );
    });
  }

  testWidgets('failed age save keeps the year and retries the same write',
      (tester) async {
    var passed = 0;
    await pump(
      tester,
      passed: () => passed++,
      preferences: _FailingAgePreferences(db),
    );
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2000'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    expect(passed, 0);
    final retained = tester.widget<ValueWheel>(find.byType(ValueWheel));
    expect(retained.values[retained.selectedIndex], '2000');
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('the blocked state fades in as one frame', (tester) async {
    await pump(tester, disableAnimations: false);
    final wheel = tester.widget<ValueWheel>(find.byType(ValueWheel));
    wheel.onSelected(wheel.values.indexOf('2014'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump();
    final fade = find
        .ancestor(
          of: find.text("Pantas isn't available yet"),
          matching: find.byType(Opacity),
        )
        .last;
    expect(fade, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<Opacity>(fade).opacity, closeTo(.802403, .002));
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
  Future<void> pumpFramed(WidgetTester tester, {required bool wide}) async {
    debugWebPlatformOverride = wide ? true : null;
    addTearDown(() => debugWebPlatformOverride = null);
    final size = wide ? const Size(1440, 900) : const Size(390, 844);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: Scaffold(
              body: _FrameHost(
                child: OnboardingAgeGateStep(
                  currentYear: 2026,
                  onAgeGatePassed: () {},
                  onBack: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('wide: the year field has focus as the step opens',
      (tester) async {
    await pumpFramed(tester, wide: true);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    await tester.enterText(find.byType(TextField), '1999');
    expect(find.text('1999'), findsOneWidget);
  });

  testWidgets('phone: the under-age block has no Back, as on wide web',
      (tester) async {
    await AppPreferencesRepository(db).setBlockedMinimumAge(13);
    await pumpFramed(tester, wide: false);
    expect(find.text("Pantas isn't available yet"), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('phone: the year step keeps its Back', (tester) async {
    await pumpFramed(tester, wide: false);
    expect(find.text('When were you born?'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });
}

class _FrameHost extends StatefulWidget {
  const _FrameHost({required this.child});
  final Widget child;
  @override
  State<_FrameHost> createState() => _FrameHostState();
}

class _FrameHostState extends State<_FrameHost> {
  final _controller = OnboardingFrameController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingFrame(
        controller: _controller,
        enabled: true,
        resetToken: 'age',
        child: widget.child,
      );
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
