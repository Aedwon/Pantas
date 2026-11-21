import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'root has profile and the approved destinations without a back link',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        isAnonymousProvider.overrideWith((ref) async => true),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(Avatar), findsOneWidget);
    expect(find.text('Add your name'), findsOneWidget);
    expect(find.text('Not signed in'), findsOneWidget);
    final titles =
        tester.widgetList<ListRow>(find.byType(ListRow)).map((r) => r.title);
    expect(
      titles,
      containsAllInOrder([
        'Pantas Pro',
        'Your exam',
        'Practice',
        'Reminders',
        'Appearance',
        'About',
      ]),
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Exam date'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('a child has no Reminders row', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setAgeGroup('child');
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        isAnonymousProvider.overrideWith((ref) async => false),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Your exam'), findsOneWidget);
    expect(find.text('Reminders'), findsNothing);
  });

  for (final (group, shown) in [
    ('child', true),
    ('minor', false),
    ('adult', false),
  ]) {
    testWidgets('For parents ${shown ? 'shows' : 'is hidden'} on $group',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setAgeGroup(group);
      await tester.pumpAppWithProviders(
        const SettingsHomePage(),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          userSettingsProvider
              .overrideWith((ref) async => UserSettings.defaults()),
          isAnonymousProvider.overrideWith((ref) async => false),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('For parents'), shown ? findsOneWidget : findsNothing);
      expect(
        find.text('This account is managed by a parent or guardian.'),
        shown ? findsOneWidget : findsNothing,
      );
      // The Switch Child row is a later task's.
      expect(find.text('Switch Child'), findsNothing);
    });
  }

  testWidgets('the For parents row opens the For parents page',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await AppPreferencesRepository(db).setAgeGroup('child');
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SettingsHomePage()),
        GoRoute(
          path: '/settings/parents',
          builder: (_, __) => const Text('parents page'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithProviders(
      Router<Object>(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        isAnonymousProvider.overrideWith((ref) async => false),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('For parents'));
    await tester.pumpAndSettle();
    expect(find.text('parents page'), findsOneWidget);
  });

  test('Pro root value names the owned plan', () {
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.yearly)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(entitlementProvider.future).then((_) {
      expect(container.read(proRowValueProvider), 'Yearly');
    });
  });
}
