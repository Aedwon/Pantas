import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/app/router.dart';
import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/notifications/application/notifications_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
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
    expect(find.text('Build your study plan'), findsOneWidget);
  });

  testWidgets(
      'age gate passed, needs selection → boot lands on onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });

  testWidgets('age gate passed, valid selection → boot lands on home',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await NotificationRationaleRepository(db).markShown();
    await pumpApp(tester);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Choose your exam'), findsNothing);
  });

  testWidgets('completed onboarding can continue to notification rationale',
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

    expect(find.text("I'll be your coach."), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/notifications/rationale',
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

    expect(find.text('Mock setup'), findsOneWidget);
  });

  testWidgets('/paywall route builds real paywall page', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Home').first),
    );
    final router = container.read(routerProvider);
    router.go('/paywall?returnTo=/plan');
    await tester.pumpAndSettle();

    expect(find.text('Try Pro'), findsOneWidget);
    expect(
      find.textContaining('You need a connection to subscribe'),
      findsOneWidget,
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

  testWidgets('free user opening Pro dossier route redirects to paywall',
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

    expect(find.text('Try Pro'), findsOneWidget);
  });

  testWidgets('pro user opening Pro dossier route reaches placeholder',
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

    expect(find.text('Pro dossier: mock_1'), findsOneWidget);
  });

  testWidgets('age gate passed, invalid persisted exam id → onboarding picker',
      (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('removed-exam');
    await pumpApp(tester);
    expect(find.text('Choose your exam'), findsOneWidget);
  });
}
