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
  String yearText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;
  Future<void> typeYear(WidgetTester tester, String year) async {
    await tester.enterText(find.byType(TextField), year);
    await tester.pump();
  }

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
        expect(yearText(tester), '2012');
        await typeYear(tester, '2014');
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

  testWidgets('the phone step buttons name themselves for a screen reader',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    final buttons = find.byType(IconButton);
    expect(tester.getSemantics(buttons.at(0)).tooltip, 'Earlier year');
    expect(tester.getSemantics(buttons.at(1)).tooltip, 'Next year');
    handle.dispose();
  });

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
    await typeYear(tester, '2000');
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
      await typeYear(tester, year);
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
    await typeYear(tester, '2000');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    expect(passed, 0);
    expect(yearText(tester), '2000');
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('the blocked state fades in as one frame', (tester) async {
    await pump(tester, disableAnimations: false);
    await typeYear(tester, '2014');
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
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(yearText(tester), '2013');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(yearText(tester), '2011');
    expect(tester.takeException(), isNull);
  });
  Future<void> pumpFramed(
    WidgetTester tester, {
    required bool wide,
    int year = 2026,
  }) async {
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
                  currentYear: year,
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

  group('wide: the range hint under the year field', () {
    Future<void> type(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    testWidgets('shows for a complete year outside the range', (tester) async {
      await pumpFramed(tester, wide: true);
      await type(tester, '1925');
      expect(find.text('Enter a year from 1926 to 2026.'), findsOneWidget);
      await type(tester, '2027');
      expect(find.text('Enter a year from 1926 to 2026.'), findsOneWidget);
    });

    testWidgets('is quiet in range and while the year is incomplete',
        (tester) async {
      await pumpFramed(tester, wide: true);
      for (final text in ['2012', '1926', '2026', '19', '', '2']) {
        await type(tester, text);
        expect(
          find.textContaining('Enter a year from'),
          findsNothing,
          reason: text,
        );
      }
    });

    testWidgets('takes its range from the current year, not fixed numbers',
        (tester) async {
      await pumpFramed(tester, wide: true, year: 2027);
      await type(tester, '1926');
      expect(find.text('Enter a year from 1927 to 2027.'), findsOneWidget);
      await type(tester, '2027');
      expect(find.textContaining('Enter a year from'), findsNothing);
    });

    testWidgets('Continue keeps its place when the hint appears and goes',
        (tester) async {
      await pumpFramed(tester, wide: true);
      final continueButton = find.text('Continue');
      await type(tester, '1926');
      final steady = tester.getTopLeft(continueButton).dy;
      for (final text in ['1900', '2027', '0000', '19', '2026']) {
        await type(tester, text);
        expect(tester.getTopLeft(continueButton).dy, steady, reason: text);
      }
    });

    testWidgets('the YEAR label sits 4 px in from the field, as NAME does',
        (tester) async {
      await pumpFramed(tester, wide: true);
      expect(
        tester.getTopLeft(find.text('YEAR')).dx,
        tester.getTopLeft(find.byType(TextField)).dx + 4,
      );
    });

    testWidgets('is drawn on the phone too', (tester) async {
      await pumpFramed(tester, wide: false);
      await type(tester, '1925');
      expect(find.text('Enter a year from 1926 to 2026.'), findsOneWidget);
      final continueButton = tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Continue'),
      );
      expect(continueButton.onPressed, isNull);
      await type(tester, '2000');
      expect(find.textContaining('Enter a year from'), findsNothing);
    });
  });

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

  // 6U-2: Back from Terms showed 2012 again, and Continue then sent an adult
  // to the guardian screen.
  testWidgets('phone: Back to the year step shows the year the student chose',
      (tester) async {
    final shown = ValueNotifier<bool>(true);
    addTearDown(shown.dispose);
    var passed = 0;
    await pumpAccessibilitySurface(
      tester,
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: ValueListenableBuilder<bool>(
          valueListenable: shown,
          builder: (_, on, __) => on
              ? OnboardingAgeGateStep(
                  currentYear: 2026,
                  onAgeGatePassed: () => passed++,
                  onGuardianNeeded: () => fail('an adult needs no guardian'),
                )
              : const SizedBox(),
        ),
      ),
      viewportSize: const Size(390, 844),
    );
    expect(yearText(tester), '2012');
    await typeYear(tester, '2006');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 1);

    shown.value = false;
    await tester.pump();
    shown.value = true;
    await tester.pump();
    expect(yearText(tester), '2006');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 2);
  });

  testWidgets('a new visit starts on the default year', (tester) async {
    await pump(tester);
    expect(yearText(tester), '2012');
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
