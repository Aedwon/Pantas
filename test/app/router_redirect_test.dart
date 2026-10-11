import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/back_chevron.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
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
  }

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

  testWidgets('/paywall redirects to the Settings Pro page', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/paywall?returnTo=/plan');
    await tester.pumpAndSettle();

    expect(find.byType(ProPage), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/settings/pro',
    );
  });

  testWidgets('/settings renders Settings home; /more redirects there',
      (tester) async {
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
    expect(find.text('How you practice'), findsOneWidget);
    expect(find.byType(SettingsBar), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(SettingsBar),
        matching: find.byType(AppShell),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(SettingsBar),
        matching: find.byType(BackChevron),
      ),
      findsNothing,
    );

    router.go('/more');
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/settings',
    );
    expect(find.text('How you practice'), findsOneWidget);
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
    expect(find.text('Account'), findsWidgets);

    router.go('/settings/backup');
    await tester.pumpAndSettle();
    expect(find.text('Backup'), findsWidgets);

    router.go('/settings/about');
    await tester.pumpAndSettle();
    expect(find.text('About'), findsWidgets);

    // The old path is kept as a redirect, so a link from an older build still
    // lands somewhere real. The page itself is now named Pro.
    router.go('/settings/subscription');
    await tester.pumpAndSettle();
    expect(find.text('Pro'), findsWidgets);
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

    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.textContaining('RA 10173'), findsWidgets);
    expect(find.textContaining('Legal: privacy'), findsNothing);
  });

  testWidgets('free user opening retired dossier route redirects home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/plan/dossier/mock_1');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });

  testWidgets('pro user opening retired dossier route also redirects home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          entitlementProvider.overrideWith(
            (_) => Stream.value(
              const Entitlement(plan: EntitlementPlan.monthly),
            ),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/plan/dossier/mock_1');
    await tester.pumpAndSettle();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });

  testWidgets('every other retired route reaches its living destination',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.text('Home').first));
    final router = container.read(routerProvider);
    for (final entry in <String, String>{
      '/progress': '/home',
      '/progress/how-you-work': '/home',
      '/progress/your-record': '/home',
      '/mock-exam': '/home',
      '/notifications/rationale': '/home',
      '/review': '/quiz',
      '/quiz/results/old-attempt': '/quiz',
    }.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        entry.value,
        reason: entry.key,
      );
    }
  });

  testWidgets('age gate passed, invalid persisted exam id → onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('removed-exam');
    await pumpApp(tester);
    expect(find.text('Which exam are you taking?'), findsOneWidget);
  });
}
