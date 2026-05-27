import 'package:cse_cet_reviewer/core/auth/auth_user.dart';
import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_home_page.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('home renders Preferences Account About in order',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(db, anonymous: true),
    );

    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    await tester.drag(find.byType(SettingsHomePage), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('ABOUT'), findsOneWidget);
  });

  testWidgets('anonymous user shows signed in anonymously account subtitle',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(db, anonymous: true),
    );

    expect(find.text('Signed in anonymously'), findsOneWidget);
  });

  testWidgets('named user shows email account subtitle', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(
        db,
        user: const AuthUser(
          uid: 'u1',
          email: 'aerol@example.com',
          displayName: 'Aerol',
        ),
      ),
    );

    expect(find.text('aerol@example.com'), findsOneWidget);
  });

  testWidgets('subscription row reflects free and pro entitlement states',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(subscriptionSubtitle: 'Pro · Yearly'),
      overrides: _overrides(
        db,
        anonymous: true,
      ),
    );

    expect(find.text('Pro · Yearly'), findsOneWidget);
  });

  testWidgets('backup row reflects saved syncing and failed summaries',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(
        db,
        user:
            const AuthUser(uid: 'u1', email: 'a@example.com', displayName: ''),
        syncStatus: const Syncing(pendingCount: 3),
      ),
    );
    expect(find.text('Backing up... 3 items'), findsOneWidget);
  });

  testWidgets('theme chips update theme provider', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(db, anonymous: true),
    );

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      await DriftSettingsRepository(db).readThemePreference(),
      ThemePreference.dark,
    );
  });

  testWidgets('strict mock and help improve app switches call actions',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: _overrides(db, anonymous: true),
    );

    await tester.tap(find.text('Strict mock mode'));
    await tester.tap(find.text('Help improve the app'));
    await tester.pumpAndSettle();

    final settings = await DriftSettingsRepository(db).readUserSettings();
    expect(settings.strictMockMode, isTrue);
    expect(settings.helpImproveApp, isFalse);
  });
}

List<Override> _overrides(
  AppDatabase db, {
  bool anonymous = false,
  AuthUser? user,
  SyncStatus? syncStatus,
}) {
  final effectiveSyncStatus = syncStatus ??
      SyncOk(
        lastSyncedAt: DateTime(2026, 5, 22),
        pendingCount: 0,
      );
  return [
    appDatabaseProvider.overrideWithValue(db),
    currentUserProvider.overrideWith((ref) async => user),
    isAnonymousProvider.overrideWith((ref) async => anonymous),
    syncStatusProvider.overrideWith((ref) => Stream.value(effectiveSyncStatus)),
  ];
}
