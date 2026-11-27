import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';

import '../../../helpers/in_memory_database.dart';

// Backlog C15 (staging, Nov 26): each exam switch showed Free for 150 to 300 ms
// before Pro. The switch refreshes the app preferences, which rebuilt the
// payment gateway; the new one started empty. The preferences object only
// holds the one database the app opens at startup, so the payment helpers keep
// it and the gateway is not rebuilt.
Map<String, dynamic> _monthly() => {
      'source': 'paymongo',
      'product': 'pantas_cs_monthly',
      'tier': 'civilService',
      'startsAt': DateTime.utc(2026).millisecondsSinceEpoch,
      'endsAt': DateTime.utc(2030).millisecondsSinceEpoch,
      'state': 'active',
      'createdAt': DateTime.utc(2026).millisecondsSinceEpoch,
    };

void main() {
  late ProviderContainer container;

  setUp(() {
    final db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        paymentsOnWebProvider.overrideWithValue(false),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  test('an exam switch keeps the same payment gateway and its helpers', () {
    final gateway = container.read(revenueCatGatewayProvider);
    final state = container.read(paymentEntitlementStateProvider);
    final clock = container.read(trustedClockProvider);
    final pending = container.read(pendingPurchaseStoreProvider);

    // What the exam page does after an exam change.
    container
      ..invalidate(appPreferencesRepositoryProvider)
      ..invalidate(activeExamFocusProvider);

    expect(
      identical(container.read(revenueCatGatewayProvider), gateway),
      isTrue,
    );
    expect(
      identical(container.read(paymentEntitlementStateProvider), state),
      isTrue,
    );
    expect(identical(container.read(trustedClockProvider), clock), isTrue);
    expect(
      identical(container.read(pendingPurchaseStoreProvider), pending),
      isTrue,
    );
  });

  test('an account switch after an exam switch reads the new account only',
      () async {
    final gateway = WebPaymentGateway(
      callable: (_, __) async => null,
      readGrants: (uid) async => uid == 'paid-account' ? [_monthly()] : [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
      entitlementState: container.read(paymentEntitlementStateProvider),
    );
    await gateway.logIn('paid-account');
    expect(gateway.cachedEntitlement?.proIsActive, isTrue);

    container.invalidate(appPreferencesRepositoryProvider);
    await gateway.clearIdentity();
    await gateway.logIn('free-account');

    expect(gateway.cachedEntitlement?.proIsActive ?? false, isFalse);
  });
}
