import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

/// Browser Back on the web arrives at the router as an address change. Every
/// onboarding step shares /onboarding, so Back landed on the page before it,
/// the router sent it straight back, and nothing seemed to happen (3M-6).
void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await DriftSettingsRepository(db).recordPolicyAcceptance();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
  });

  tearDown(() async {
    forgetStartLocation();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester, {required bool web}) async {
    await DriftSettingsRepository(db).recordPolicyAcceptance();
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
          onboardingWebProvider.overrideWithValue(web),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  String pathOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(App)))
          .read(routerProvider)
          .routeInformationProvider
          .value
          .uri
          .path;

  // The router gets the same thing from the browser's Back button: an address
  // outside onboarding while the onboarding page is open.
  Future<void> browserBack(WidgetTester tester) async {
    ProviderScope.containerOf(tester.element(find.byType(App)))
        .read(routerProvider)
        .go('/home');
    await tester.pumpAndSettle();
  }

  testWidgets('browser Back goes to the previous step, one step per press',
      (tester) async {
    // Resume lands on the exam picker: age and terms are done.
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await pumpApp(tester, web: true);
    expect(find.byType(ExamPickerScreen), findsOneWidget);

    await browserBack(tester);
    expect(pathOf(tester), '/onboarding');
    expect(find.byType(OnboardingConsentStep), findsOneWidget);
    expect(find.byType(ExamPickerScreen), findsNothing);

    await browserBack(tester);
    expect(pathOf(tester), '/onboarding');
    expect(find.byType(OnboardingAgeGateStep), findsOneWidget);
    expect(find.byType(OnboardingConsentStep), findsNothing);
  });

  testWidgets('the phone app ignores it: no browser history there',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await pumpApp(tester, web: false);
    expect(find.byType(ExamPickerScreen), findsOneWidget);
    await browserBack(tester);
    expect(find.byType(ExamPickerScreen), findsOneWidget);
  });
}
