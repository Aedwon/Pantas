import type {Firestore} from 'firebase-admin/firestore';

/**
 * Mirrors the entitlement the claims carry onto `users/{uid}/sync_state/current` (M4b), so sync rules
 * can refuse a refunded account at its next write instead of after a token lifetime. Written next to the
 * claims write in `copyEntitlementClaims`, the only place `setCustomUserClaims` is called.
 *
 * The write never creates the document: the app reads `sync_state/current` as the active generation
 * pointer and fails on one without it. A missing document means the account has not activated sync, so
 * there is nothing to mirror. A write whose version is older than the stored one is skipped.
 * Any error is thrown, so the claim copy stays pending and the repair job retries it.
 */
type Entitlement = {pro: boolean; proUntil: number; version: number};

/** The fields the mirror carries for an entitlement. A non-Pro entitlement mirrors 0. */
export const mirrorFields = (entitlement: Entitlement) => ({
  proUntil: entitlement.pro && Number.isFinite(entitlement.proUntil) ? entitlement.proUntil : 0,
  entitlementVersion: entitlement.version});

/** True when the stored mirror was written from a newer entitlement version than this one. */
export const mirrorIsNewer = (stored: unknown, version: number) =>
  typeof stored === 'number' && stored > version;

/** The write is a transaction so a stalled late writer cannot replace a newer mirror. */
export async function mirrorEntitlementToSync(db: Firestore, uid: string, entitlement: Entitlement): Promise<void> {
  const ref = db.doc(`users/${uid}/sync_state/current`);
  await db.runTransaction(async transaction => {
    const current = await transaction.get(ref);
    if (!current.exists || mirrorIsNewer(current.get('entitlementVersion'), entitlement.version)) return;
    transaction.update(ref, mirrorFields(entitlement));
  });
}
