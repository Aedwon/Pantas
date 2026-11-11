import 'package:flutter/material.dart';
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
  String ageText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;
  Future<void> typeAge(WidgetTester tester, String age) async {
    await tester.enterText(find.byType(TextField), age);
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
        expect(find.text('How old are you?'), findsOneWidget);
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
        expect(ageText(tester), '17');
        await typeAge(tester, '12');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text("Pantas isn't available yet"), findsOneWidget);
        expect(
          find.text("Sorry, this app isn't available for users under 13."),
          findsOneWidget,
        );
        expect(
          find.text('Entered the wrong age? Email contact@pantas.study.'),
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

  testWidgets('18 passes the gate and stores only the group', (tester) async {
    var passed = 0;
    var guardian = 0;
    await pump(
      tester,
      passed: () => passed++,
      guardianNeeded: () => guardian++,
    );
    await typeAge(tester, '18');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(guardian, 0);
    final repo = AppPreferencesRepository(db);
    expect(await repo.hasPassedAgeGate(), isTrue);
    expect(await repo.ageGroup(), 'adult');
    expect(
      (await db.select(db.devicePrefs).get()).any((row) => row.value == '18'),
      isFalse,
    );
  });

  for (final age in ['13', '14', '17']) {
    testWidgets('$age is a minor: the gate stays shut and a guardian is asked',
        (tester) async {
      var passed = 0;
      var guardian = 0;
      await pump(
        tester,
        passed: () => passed++,
        guardianNeeded: () => guardian++,
      );
      await typeAge(tester, age);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(passed, 0);
      expect(guardian, 1);
      final repo = AppPreferencesRepository(db);
      expect(await repo.hasPassedAgeGate(), isFalse);
      expect(await repo.ageGroup(), 'minor');
      expect(
        (await db.select(db.devicePrefs).get()).any((row) => row.value == age),
        isFalse,
        reason: 'no age is stored',
      );
    });
  }

  testWidgets('failed age save keeps the age and retries the same write',
      (tester) async {
    var passed = 0;
    await pump(
      tester,
      passed: () => passed++,
      preferences: _FailingAgePreferences(db),
    );
    await typeAge(tester, '42');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
    expect(passed, 0);
    expect(ageText(tester), '42');
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(passed, 1);
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('the blocked state fades in as one frame', (tester) async {
    await pump(tester, disableAnimations: false);
    await typeAge(tester, '12');
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

  Future<void> pumpFramed(
    WidgetTester tester, {
    required bool wide,
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

  testWidgets('phone: the under-age block has no Back, as on wide web',
      (tester) async {
    await AppPreferencesRepository(db).setBlockedMinimumAge(13);
    await pumpFramed(tester, wide: false);
    expect(find.text("Pantas isn't available yet"), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('phone: the age step keeps its Back', (tester) async {
    await pumpFramed(tester, wide: false);
    expect(find.text('How old are you?'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  // 6U-2: Back from Terms showed the default again, and Continue then sent an
  // adult to the guardian screen.
  testWidgets('phone: Back to the age step shows the age the student chose',
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
                  onAgeGatePassed: () => passed++,
                  onGuardianNeeded: () => fail('an adult needs no guardian'),
                )
              : const SizedBox(),
        ),
      ),
      viewportSize: const Size(390, 844),
    );
    expect(ageText(tester), '17');
    await typeAge(tester, '42');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 1);

    shown.value = false;
    await tester.pump();
    shown.value = true;
    await tester.pump();
    expect(ageText(tester), '42');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(passed, 2);
  });

  testWidgets('a new visit starts on 17', (tester) async {
    await pump(tester);
    expect(ageText(tester), '17');
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
