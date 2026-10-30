import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

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
    await seedContentExam(
      contentDb,
      examId: 'upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
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

  testWidgets('missing server and local settings opens the exam step',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AppPreferencesRepository(db).setCompletedOnboarding(value: true);
    await pumpApp(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(App)));
    container.read(studyNeedsExamSettingsProvider.notifier).state = true;
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/onboarding',
    );
    expect(find.text('Which exam are you taking?'), findsOneWidget);
  });

  testWidgets('age gate not passed → boot lands on onboarding welcome',
      (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome to Pantas'), findsOneWidget);
  });

  testWidgets(
      'age gate passed, needs selection → boot lands on onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await pumpApp(tester);
    expect(find.text('Which exam are you taking?'), findsOneWidget);
  });

  testWidgets('age gate passed, valid selection → boot lands on home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await NotificationRationaleRepository(db).markShown();
    await pumpApp(tester);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Which exam are you taking?'), findsNothing);
  });

  testWidgets('completed onboarding goes home without a rationale gate',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/onboarding');
    await tester.pumpAndSettle();

    expect(find.text("I'll be your coach."), findsNothing);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/home',
    );
  });

  testWidgets('router accepts mock setup route', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/quiz/mock/setup?examId=cse');
    await tester.pumpAndSettle();

    // This asserted the text of a placeholder until the route began building
    // the real page. What the test is for is that the router accepts the
    // route, so it names the page rather than a string inside it.
    expect(find.byType(MockSetupRoute), findsOneWidget);
  });

  testWidgets('the Settings Pro page remains reachable', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/settings/pro');
    await tester.pumpAndSettle();

    expect(find.byType(ProPage), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/settings/pro',
    );
  });

  testWidgets('/pro checkout path redirects with every query parameter',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/pro?checkout=success&ref=x&tag=one&tag=two');
    await tester.pumpAndSettle();

    expect(find.byType(ProPage), findsOneWidget);
    final uri = router.routerDelegate.currentConfiguration.uri;
    expect(uri.path, '/settings/pro');
    expect(uri.queryParametersAll, {
      'checkout': ['success'],
      'ref': ['x'],
      'tag': ['one', 'two'],
    });
  });

  testWidgets('/settings renders Settings home', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/settings');
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.byType(PantasPage), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(PantasPage),
        matching: find.byType(AppShell),
      ),
      findsOneWidget,
    );

    router.go('/settings');
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/settings',
    );
    expect(find.text('Practice'), findsOneWidget);
  });

  testWidgets('settings detail routes build', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);

    router.go('/settings/account');
    await tester.pumpAndSettle();
    expect(find.text('Pantas ID'), findsOneWidget);

    router.go('/settings/backup');
    await tester.pumpAndSettle();
    expect(find.text('Backup'), findsWidgets);

    router.go('/settings/about');
    await tester.pumpAndSettle();
    expect(find.text('Pantas'), findsOneWidget);

    router.go('/settings/pro');
    await tester.pumpAndSettle();
    expect(find.text('PANTAS PRO'), findsOneWidget);
  });

  testWidgets('/legal/privacy route builds real legal page', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await NotificationRationaleRepository(db).markShown();
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/legal/privacy');
    await tester.pumpAndSettle();

    expect(find.text('Privacy policy'), findsWidgets);
    expect(find.text('Your rights'), findsOneWidget);
    expect(find.textContaining('Legal: privacy'), findsNothing);
  });

  testWidgets('age gate passed, invalid persisted exam id → onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('removed-exam');
    await pumpApp(tester);
    expect(find.text('Which exam are you taking?'), findsOneWidget);
  });
}
