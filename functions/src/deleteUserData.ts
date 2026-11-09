import type {Auth} from 'firebase-admin/auth';
import type {Firestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';
import {writeAuditLog, type assertNamedUser} from './_audit.js';
import {deleteGuardianRecords} from './guardianConsent.js';
import {retirePublicId} from './publicId.js';
import {clearPassOwnership} from './revenuecatPasses.js';
import {identityMarkers, identityMarkersForUser} from './webTrial.js';

/** Why an account was deleted. Kept on the guardian evidence marker. */
export type DeletionReason = 'user_request' | 'guardian_withdrawal' | 'inactive_24_months';

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

  // The Firebase Auth identity is deleted last so any failed data cleanup
  // leaves the account recoverable for a retry.
  await auth.deleteUser(uid);
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
  const checkouts = await db.collection('paymongoCheckouts').where('uid', '==', uid).get();
  const attested = checkouts.docs.filter((doc) => typeof doc.get('attestedAt') === 'number');
  if (answers.empty && attested.length === 0) return;
  const batch = db.batch();
  for (const doc of attested) {
    batch.set(evidence.collection('purchases').doc(doc.id), {
      attestedAt: doc.get('attestedAt'), termsVersion: doc.get('termsVersion') ?? null,
      reference: doc.get('reference') ?? null, product: doc.get('product') ?? null,
    });
  }
  // A retry keeps the first deletion time, so the record does not drift later.
  const existing = (await evidence.get()).get('accountDeletedAt');
  if (typeof existing !== 'number') batch.set(evidence, {accountDeletedAt: now, reason}, {merge: true});
  await batch.commit();
}
