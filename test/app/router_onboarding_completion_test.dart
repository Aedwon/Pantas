import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/paywall/paywall.dart';

import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
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

  testWidgets(
      'passedAgeGate = true, exam selected, onboardingComplete = false '
      '-> stay on onboarding', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AppPreferencesRepository(db).setCompletedOnboarding(value: false);

    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    final router = container.read(routerProvider);
    router.go('/onboarding');
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/onboarding',
    );
  });

  testWidgets(
      'passedAgeGate = true, exam selected, onboardingComplete = true '
      '-> leaves onboarding', (tester) async {
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');
    await AppPreferencesRepository(db).setCompletedOnboarding(value: true);
    await NotificationRationaleRepository(db).markShown();

    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    final router = container.read(routerProvider);
    router.go('/onboarding');
    await tester.pumpAndSettle();

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      '/home',
    );
  });

  testWidgets(
      'legacy install with selected exam but no onboarding_complete key '
      'is treated as complete', (tester) async {
    final repo = AppPreferencesRepository(db);
    await repo.setSelectedExamId('cse');

    expect(await repo.hasCompletedOnboarding(), isTrue);
  });
}
