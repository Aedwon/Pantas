import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';

void main() {
  test(
      'pending state hides the old account immediately '
      'during an account switch', () async {
    final account = StateProvider<AuthState>(
      (_) => const AuthState.anonymous(uid: 'account-a'),
    );
    final store = PendingPurchaseStore.inMemory();
    addTearDown(store.dispose);
    await store.save(
      PendingPurchase(
        uid: 'account-a',
        productId: 'pantas_pro_monthly',
        startedAt: DateTime.utc(2026, 10, 7),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        authStateProvider
            .overrideWith((ref) => Stream.value(ref.watch(account))),
        pendingPurchaseStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    container.listen(pendingPurchaseProvider, (_, __) {});
    await container.read(authStateProvider.future);
    await pumpEventQueue();
    expect(
      container.read(pendingPurchaseProvider).valueOrNull?.uid,
      'account-a',
    );
    container.read(account.notifier).state =
        const AuthState.anonymous(uid: 'account-b');
    expect(container.read(pendingPurchaseProvider).valueOrNull, isNull);
    await container.read(authStateProvider.future);
    await pumpEventQueue();
    expect(container.read(pendingPurchaseProvider).valueOrNull, isNull);
  });
}
