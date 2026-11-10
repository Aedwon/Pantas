import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/welcome/welcome_handover.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

class _FakeHandover implements WelcomeHandover {
  _FakeHandover({required this.shownThisVisit, this.leaves = true});

  @override
  final bool shownThisVisit;

  /// False keeps the HTML screen up until [screenLeft] is called.
  final bool leaves;
  final List<bool> readyCalls = [];
  void Function()? screenLeft;

  @override
  void appReady({required bool holdForTap}) => readyCalls.add(holdForTap);

  @override
  void whenScreenLeft(void Function() callback) {
    if (leaves) {
      callback();
    } else {
      screenLeft = callback;
    }
  }
}

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpPage(
    WidgetTester tester,
    WelcomeHandover handover, {
    OnboardingProgress? progress,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          welcomeHandoverProvider.overrideWithValue(handover),
          onboardingProgressProvider
              .overrideWith((ref) async => progress ?? OnboardingProgress()),
          settingsRepositoryProvider
              .overrideWithValue(DriftSettingsRepository(db)),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('after the HTML Welcome screen onboarding opens at the age step',
      (tester) async {
    final handover = _FakeHandover(shownThisVisit: true);
    await pumpPage(tester, handover);

    expect(find.text('How old are you?'), findsOneWidget);
    expect(find.text('Welcome to Pantas'), findsNothing);
    expect(handover.readyCalls, [true]);
  });

  testWidgets('the age step slides in when the HTML Welcome screen leaves',
      (tester) async {
    final handover = _FakeHandover(shownThisVisit: true, leaves: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          welcomeHandoverProvider.overrideWithValue(handover),
          onboardingProgressProvider
              .overrideWith((ref) async => OnboardingProgress()),
          settingsRepositoryProvider
              .overrideWithValue(DriftSettingsRepository(db)),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Under the cover nothing of the age step or a second Welcome is drawn.
    expect(find.text('How old are you?'), findsNothing);
    expect(find.text('Welcome to Pantas'), findsNothing);

    handover.screenLeft!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final offset = find.byKey(const ValueKey('onboarding-incoming-offset'));
    expect(find.text('How old are you?'), findsOneWidget);
    expect(
      tester.widget<Transform>(offset).transform.getTranslation().x,
      greaterThan(0),
      reason: 'the step is still sliding in, as after Back and Get Started',
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Transform>(offset).transform.getTranslation().x,
      0,
    );
  });

  testWidgets('a resume past Welcome stays where it was and still hands over',
      (tester) async {
    final handover = _FakeHandover(shownThisVisit: true);
    await pumpPage(
      tester,
      handover,
      progress: OnboardingProgress(agePassed: true),
    );

    expect(find.text('Terms and Privacy'), findsOneWidget);
    expect(handover.readyCalls, [true]);
  });

  testWidgets('without the HTML screen Flutter draws its own Welcome',
      (tester) async {
    final handover = _FakeHandover(shownThisVisit: false);
    await pumpPage(tester, handover);

    expect(find.text('Welcome to Pantas'), findsOneWidget);
    expect(handover.readyCalls, isEmpty);
  });

  group('a return visit under the HTML splash (4P-2)', () {
    late VoidCallback? splashLeft;
    final welcomeFade = find.byKey(const ValueKey('welcome-after-splash'));

    setUp(() {
      splashLeft = null;
      final probe = splashProbe;
      final gone = splashGoneProbe;
      splashProbe = () => true;
      splashGoneProbe = (action) => splashLeft = action;
      addTearDown(() {
        splashProbe = probe;
        splashGoneProbe = gone;
      });
    });

    double fade(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find.descendant(
            of: welcomeFade,
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity
        .value;

    testWidgets('Welcome opens with no second logo launch and stays hidden',
        (tester) async {
      await pumpPage(tester, _FakeHandover(shownThisVisit: false));

      expect(
        find.byKey(const ValueKey('launch-page-fade')),
        findsNothing,
        reason: 'the splash already played the logo',
      );
      expect(find.text('Welcome to Pantas'), findsOneWidget);
      expect(fade(tester), 0, reason: 'the splash is still fading out');
      expect(splashLeft, isNotNull);
    });

    testWidgets('Welcome fades in once the splash has left', (tester) async {
      await pumpPage(tester, _FakeHandover(shownThisVisit: false));

      splashLeft!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(fade(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(fade(tester), 1);
    });
  });
}
