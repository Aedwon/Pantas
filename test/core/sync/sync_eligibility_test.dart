import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';

void main() {
  test('anonymous Pro remains off even with server claim', () {
    expect(
      evaluateSyncEligibility(
        identity: const SyncIdentity(uid: 'anon-1', isAnonymous: true),
        entitlement: SyncEntitlement.pro,
        hasFreshProClaim: true,
      ),
      SyncEligibility.off,
    );
  });

  test('named Free remains off even with stale true server claim', () {
    expect(
      evaluateSyncEligibility(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.free,
        hasFreshProClaim: true,
      ),
      SyncEligibility.off,
    );
  });

  test('named RevenueCat Pro without refreshed claim is activating', () {
    expect(
      evaluateSyncEligibility(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.pro,
        hasFreshProClaim: false,
      ),
      SyncEligibility.activating,
    );
  });

  test('named Pro with refreshed claim is eligible', () {
    expect(
      evaluateSyncEligibility(
        identity: const SyncIdentity(uid: 'user-1'),
        entitlement: SyncEntitlement.pro,
        hasFreshProClaim: true,
      ),
      SyncEligibility.eligible,
    );
  });
}
