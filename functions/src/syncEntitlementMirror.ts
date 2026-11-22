import type {Firestore} from 'firebase-admin/firestore';

/**
 * Mirrors the entitlement the claims carry onto `users/{uid}/sync_state/current` (M4b), so sync rules
 * can refuse a refunded account at its next write instead of after a token lifetime. Written next to the
 * claims write in `copyEntitlementClaims`, the only place `setCustomUserClaims` is called.
 *
 * `update` never creates the document: the app reads `sync_state/current` as the active generation
 * pointer and fails on one without it. A missing document means the account has not activated sync, so
 * there is nothing to mirror and no read is spent finding out (the failed update is the check).
 * Any other error is thrown, so the claim copy stays pending and the repair job retries it.
 */
export async function mirrorEntitlementToSync(db: Firestore, uid: string,
  entitlement: {pro: boolean; proUntil: number; version: number}): Promise<void> {
  const proUntil = entitlement.pro && Number.isFinite(entitlement.proUntil) ? entitlement.proUntil : 0;
  try {
    await db.doc(`users/${uid}/sync_state/current`).update({proUntil, entitlementVersion: entitlement.version});
  } catch (error) {
    if ((error as {code?: unknown}).code === 5) return; // NOT_FOUND
    throw error;
  }
}
