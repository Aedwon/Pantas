enum SyncEntitlement { free, pro }

enum SyncEligibility { off, activating, eligible }

class SyncIdentity {
  const SyncIdentity({
    required this.uid,
    this.isAnonymous = false,
  });

  final String uid;
  final bool isAnonymous;
}

SyncEligibility evaluateSyncEligibility({
  required SyncIdentity identity,
  required SyncEntitlement entitlement,
  required bool hasFreshProClaim,
}) {
  if (identity.isAnonymous || entitlement != SyncEntitlement.pro) {
    return SyncEligibility.off;
  }
  if (!hasFreshProClaim) {
    return SyncEligibility.activating;
  }
  return SyncEligibility.eligible;
}
