import type {Auth} from 'firebase-admin/auth';
import {FieldValue, type Firestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';
import {writeAuditLog, type assertNamedUser} from './_audit.js';
import {deleteGuardianRecords} from './guardianConsent.js';
import {retirePublicId} from './publicId.js';
import {clearPassOwnership} from './revenuecatPasses.js';
import {identityMarkers, identityMarkersForUser} from './webTrial.js';

/** A pending deletion is retried by the daily run once this long has passed since its last attempt. */
export const DELETION_RETRY_MS = 3_600_000;

/** Why an account was deleted. Kept on the guardian evidence marker. */
/** `unclaimed_address` is an account someone registered with an address they do not own. */
export type DeletionReason = 'user_request' | 'guardian_withdrawal' | 'inactive_24_months' | 'unclaimed_address';

export type DeletionOptions = {
  /** The caller's own token, when the user asked. Server jobs omit it and the Auth record is read. */
  requestAuth?: Parameters<typeof assertNamedUser>[0];
  now?: () => number;
};

/**
 * Deletes everything held for one account, then the Auth user last so that a failed cleanup leaves
 * the account recoverable for a retry. The callable, a guardian withdrawal and the inactivity job
 * all use this one path. It does no authorization: each caller proves its own right first.
 */
export async function deleteUserData(
  db: Firestore,
  auth: Pick<Auth, 'getUser' | 'deleteUser'>,
  uid: string,
  reason: DeletionReason,
  options: DeletionOptions = {},
): Promise<void> {
  const now = (options.now ?? Date.now)();
  const userRef = db.collection('users').doc(uid);

  // A durable task outside the user tree, written before anything is removed. If a later step fails,
  // the daily job finishes the deletion from this record, with no guardian link or caller needed.
  // The first reason and start time stay, so a retry does not look like a new request.
  const task = db.doc(`accountDeletions/${uid}`);
  const earlier = await task.get();
  // A custom token can recreate a deleted Auth UID with a renewable session.
  // An empty document permanently closes that UID, without retaining task data.
  if (earlier.exists && Object.keys(earlier.data() ?? {}).length === 0) return;
  if (typeof earlier.get('closedUntil') === 'number') {
    await task.set({}); // Upgrade a legacy expiring marker without reopening access.
    return;
  }
  // Each attempt moves the next retry back, so a task that keeps failing goes to the end of the
  // queue and cannot starve newer ones.
  await task.set({reason: earlier.get('reason') ?? reason, startedAt: earlier.get('startedAt') ?? now,
    nextRetryAt: now + DELETION_RETRY_MS, attempts: FieldValue.increment(1),
    // Every caller's reason is kept, so a withdrawal or a user's own request is never mistaken for
    // an inactivity deletion that may be called off.
    reasons: FieldValue.arrayUnion(reason)}, {merge: true});

  // Older trials have only an account-local record. Preserve eligibility before
  // deleting that record, including when an earlier deletion attempt is retried.
  if ((await userRef.collection('server').doc('trial').get()).exists) {
    const markers = options.requestAuth
      ? identityMarkers(options.requestAuth, db)
      : identityMarkersForUser(await auth.getUser(uid), db);
    const batch = db.batch();
    for (const marker of markers) batch.set(marker, {used: true});
    await batch.commit();
  }
  await keepGuardianEvidence(db, uid, reason, now);
  await writeAuditLog({uid, event: 'accountDeleted', metadata: {reason}});
  // From here on the account loses data, so a stalled deletion must be finished, never called off.
  await task.set({destructiveAt: earlier.get('destructiveAt') ?? now}, {merge: true});
  await retirePublicId(db, uid);
  await deleteGuardianRecords(db, uid);
  await db.recursiveDelete(userRef);
  await clearPassOwnership(db, uid);
  // The payment-to-account index is account data; the grant ledger went with the user tree.
  for (const collection of ['paymongoPayments', 'paymongoOrders', 'paymongoCheckouts', 'paymongoFollowUps']) {
    const payments = await db.collection(collection).where('uid', '==', uid).get();
    await Promise.all(payments.docs.map((doc) => doc.ref.delete()));
  }
  // trialUsedIdentities contains only keyed hashes and deliberately survives deletion.

  // Purge hosted Wrapped cards: top-level docs + their storage objects
  // (landing-page spec §5.2).
  const sharedCards = await db
    .collection('wrapped_shares')
    .where('ownerUid', '==', uid)
    .get();
  await Promise.all(sharedCards.docs.map((doc) => doc.ref.delete()));
  await getStorage()
    .bucket()
    .deleteFiles({ prefix: `wrapped/${uid}/` });

  // Removing objects also invalidates previously issued bearer download URLs.
  await getStorage().bucket().deleteFiles({prefix: `betaFeedback/${uid}/`});

  // The Firebase Auth identity is deleted last so any failed data cleanup
  // leaves the account recoverable for a retry. An identity that is already gone
  // means an earlier attempt got this far, so the rest of the cleanup still counts as done.
  try {
    await auth.deleteUser(uid);
  } catch (error) {
    if ((error as {code?: string} | null)?.code !== 'auth/user-not-found') throw error;
  }
  // Replace all task metadata. Only the UID in the document ID remains, forever.
  // No nextRetryAt: completed tombstones never enter the scheduled retry queue.
  await task.set({});
}

/**
 * Marks the deletion in the guardian evidence and copies each guardian-attested purchase there,
 * before the user tree and the payment index go. Only an account with such evidence gets a marker,
 * so an adult with none leaves nothing behind. The copy holds the attestation time, the Terms
 * version, our own reference and the product: no email, name or payment details.
 */
async function keepGuardianEvidence(db: Firestore, uid: string, reason: DeletionReason, now: number): Promise<void> {
  const evidence = db.doc(`guardianConsentEvidence/${uid}`);
  const answers = await evidence.collection('responses').limit(1).get();
  const [checkouts, orders] = await Promise.all([
    db.collection('paymongoCheckouts').where('uid', '==', uid).get(),
    db.collection('paymongoOrders').where('uid', '==', uid).get(),
  ]);
  // One purchase document per payment reference. A checkout wins over its order because its id is
  // the stable one; an order whose checkout record was never written (the last step of checkout
  // failed, yet the payment can still be fulfilled from the order) is kept under its own id.
  const purchases = new Map<string, {id: string; attestedAt: unknown; termsVersion: unknown; reference: unknown; product: unknown}>();
  for (const doc of checkouts.docs) {
    if (typeof doc.get('attestedAt') !== 'number') continue;
    purchases.set(doc.get('reference') ?? `checkout-${doc.id}`, {id: doc.id, attestedAt: doc.get('attestedAt'),
      termsVersion: doc.get('termsVersion') ?? null, reference: doc.get('reference') ?? null, product: doc.get('product') ?? null});
  }
  for (const doc of orders.docs) {
    if (typeof doc.get('attestedAt') !== 'number' || purchases.has(doc.id)) continue;
    purchases.set(doc.id, {id: `order-${doc.id}`, attestedAt: doc.get('attestedAt'),
      termsVersion: doc.get('termsVersion') ?? null, reference: doc.id, product: doc.get('product') ?? null});
  }
  if (answers.empty && purchases.size === 0) return;
  const batch = db.batch();
  for (const {id, ...fields} of purchases.values()) batch.set(evidence.collection('purchases').doc(id), fields);
  // A retry keeps the first deletion time, so the record does not drift later.
  const existing = (await evidence.get()).get('accountDeletedAt');
  if (typeof existing !== 'number') batch.set(evidence, {accountDeletedAt: now, reason}, {merge: true});
  await batch.commit();
}
