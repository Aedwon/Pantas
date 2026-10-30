import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  _FakeHandover({required this.shownThisVisit});

  @override
  final bool shownThisVisit;
  final List<bool> readyCalls = [];

  @override
  void appReady({required bool holdForTap}) => readyCalls.add(holdForTap);
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

    expect(find.text('When were you born?'), findsOneWidget);
    expect(find.text('Welcome to Pantas'), findsNothing);
    expect(handover.readyCalls, [true]);
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
}
