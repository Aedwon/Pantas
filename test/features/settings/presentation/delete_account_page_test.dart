import 'dart:async';

import 'package:pantas/app/router.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  test('named delete cancels notifications before AuthRepository.deleteAccount',
      () async {
    final log = <String>[];

    await deleteAccountFromSettings(
      isAnonymous: false,
      cancelNotifications: () async => log.add('cancelAll'),
      deleteNamedAccount: () async => log.add('deleteAccount'),
      wipeAnonymousData: () async => log.add('wipeAnonymousData'),
    );

    expect(log, ['cancelAll', 'deleteAccount']);
  });

  test('anonymous delete cancels notifications before local wipe', () async {
    final log = <String>[];

    await deleteAccountFromSettings(
      isAnonymous: true,
      cancelNotifications: () async => log.add('cancelAll'),
      deleteNamedAccount: () async => log.add('deleteAccount'),
      wipeAnonymousData: () async => log.add('wipeAnonymousData'),
    );

    expect(log, ['cancelAll', 'wipeAnonymousData']);
    expect(log, isNot(contains('deleteAccount')));
  });

  testWidgets('delete button shows loading while request is in flight',
      (tester) async {
    final completer = Completer<void>();

    await tester.pumpApp(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () => completer.future,
      ),
    );

    await tester.tap(find.text('Yes, delete my account'));
    await tester.pump();

    expect(find.text('Deleting...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('delete failure shows retry and DPO fallback', (tester) async {
    await tester.pumpApp(
      DeleteAccountPage(
        isAnonymous: false,
        entitlement: const SettingsEntitlementSnapshot.free(),
        dpoEmail: defaultLegalContact.dpoEmail,
        onDelete: () async => throw StateError('backend unavailable'),
      ),
    );

    await tester.tap(find.text('Yes, delete my account'));
    await tester.pumpAndSettle();

    expect(find.text('Try again'), findsOneWidget);
    expect(find.textContaining(defaultLegalContact.dpoEmail), findsOneWidget);
  });
}
