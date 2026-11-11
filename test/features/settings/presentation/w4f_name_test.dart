import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/settings.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

final _routes = Provider(settingsRoutes);
void main() {
  testWidgets('Name saves when going back, and clearing removes it',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);
    await repo.updateName('Aerol');
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/settings/account',
      routes: container.read(_routes),
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/settings/account/name'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect((await repo.readUserSettings()).name, isNull);
  });
}
