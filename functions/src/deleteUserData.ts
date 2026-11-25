import type {Auth} from 'firebase-admin/auth';
import {FieldValue, type DocumentSnapshot, type Firestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';
import {writeAuditLog, type assertNamedUser} from './_audit.js';
import {deleteGuardianRecords} from './guardianConsent.js';
import {retirePublicId} from './publicId.js';
import {webProduct} from './paymongoPolicy.js';
import {clearPassOwnership} from './revenuecatPasses.js';
import {skipsMarkerWrite, trialMarker} from './trialMarker.js';
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

const owesRefund = (doc: {get(field: string): unknown}) => doc.get('status') === 'pending' && doc.get('refundRequired') === true;

/**
 * Rewrites a refund task with only the fields below: no uid, product, exam or other personal
 * detail. The paid amount and refunds come from the grant when it still exists. The task and the
 * grant are read and the task is written in one transaction, so a refund that commits at the same
 * time either lands in the copy or makes this transaction retry; no refund is overwritten.
 */
async function keepRefundTask(db: Firestore, ref: FirebaseFirestore.DocumentReference, now: number,
  grantRef?: FirebaseFirestore.DocumentReference): Promise<boolean> {
  return db.runTransaction(async transaction => {
    const doc = await transaction.get(ref);
    if (!doc.exists || !owesRefund(doc)) return false;
    const grant = grantRef ? (await transaction.get(grantRef)).data() as {paidAmount?: unknown; refunds?: unknown} | undefined : undefined;
    const refunds = {...(grant?.refunds as Record<string, number> | undefined),
      ...(doc.get('refunds') as Record<string, number> | undefined)};
    const price = webProduct(doc.get('product'))?.webPricePhp;
    const paidAmount = doc.get('paidAmount') ?? grant?.paidAmount ?? (price ? price * 100 : undefined);
    const fields: Record<string, unknown> = {paymentId: doc.get('paymentId') ?? doc.id,
      sessionId: doc.get('sessionId'), eventId: doc.get('eventId'),
      paidAmount: typeof paidAmount === 'number' && Number.isFinite(paidAmount) ? paidAmount : undefined,
      refunds: Object.keys(refunds).length ? refunds : undefined, reason: doc.get('reason'),
      status: 'pending', refundRequired: true, createdAt: doc.get('createdAt') ?? now};
    for (const key of Object.keys(fields)) if (fields[key] === undefined) delete fields[key];
    transaction.set(ref, fields);
    return true;
  });
}

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
  const attempt = await db.runTransaction(async transaction => {
    const earlier = await transaction.get(task);
    // A custom token can recreate a deleted Auth UID with a renewable session.
    // An empty document permanently closes that UID, without retaining task data.
    if (earlier.exists && Object.keys(earlier.data() ?? {}).length === 0) return null;
    if (typeof earlier.get('closedUntil') === 'number') {
      transaction.set(task, {}); // Upgrade a legacy expiring marker without reopening access.
      return null;
    }
    // Each attempt moves the next retry back, so a task that keeps failing goes to the end of the
    // queue and cannot starve newer ones.
    // Recorded once: a retry keeps the first attempt's time, so it never counts as a later start.
    const firstAt = typeof earlier.get('startedAt') === 'number' ? earlier.get('startedAt') as number : now;
    transaction.set(task, {reason: earlier.get('reason') ?? reason, startedAt: firstAt,
      nextRetryAt: now + DELETION_RETRY_MS, attempts: FieldValue.increment(1),
      // Every caller's reason is kept, so a withdrawal or a user's own request is never mistaken for
      // an inactivity deletion that may be called off.
      reasons: FieldValue.arrayUnion(reason)}, {merge: true});
    return {firstAt, destructiveAt: earlier.get('destructiveAt') ?? now};
  });
  if (attempt === null) return;
  const {firstAt, destructiveAt} = attempt;

  // Older trials have only an account-local record. Preserve eligibility before
  // deleting that record, including when an earlier deletion attempt is retried.
  const trial = await userRef.collection('server').doc('trial').get();
  if (trial.exists) {
    // The code expires 730 days after the trial's own start (D7), not after this deletion. An old
    // record without a start time counts from the first deletion attempt. A code already past its
    // expiry is not written: the TTL policy may have removed it, and a new one would only be deleted again.
    const usedAt = trial.get('usedAt');
    const startedAt = typeof usedAt === 'number' && Number.isFinite(usedAt) ? usedAt : firstAt;
    const markers = options.requestAuth
      ? identityMarkers(options.requestAuth, db)
      : identityMarkersForUser(await auth.getUser(uid), db);
    // A code's expiry only moves later, never earlier, so a deletion cannot free a code sooner than
    // the trial that set it. A code with no expiry yet (an old one) is filled in.
    const row = trialMarker(startedAt);
    await db.runTransaction(async transaction => {
      const current = markers.length ? await transaction.getAll(...markers) : [];
      current.forEach((existing, i) => {
        if (skipsMarkerWrite(existing, row, now)) return;
        transaction.set(markers[i], row);
      });
    });
  }
  await keepGuardianEvidence(db, uid, reason, now);
  await writeAuditLog({uid, event: 'accountDeleted', metadata: {reason}});
  // From here on the account loses data, so a stalled deletion must be finished, never called off.
  await task.set({destructiveAt}, {merge: true});
  await retirePublicId(db, uid);
  await deleteGuardianRecords(db, uid);
  // A refund still owed is written first, with the paid amount and the refunds so far, so the
  // grant ledger can go without losing it. A stop partway leaves the task complete and uid-free.
  for (const doc of (await db.collection('paymongoFollowUps').where('uid', '==', uid).get()).docs) {
    if (!owesRefund(doc)) continue;
    await keepRefundTask(db, doc.ref, now, userRef.collection('grants').doc(doc.id));
  }
  // Close pending checkout reservations with the rest of the user tree. The PayMongo
  // client cannot expire hosted links. A payment on one still reaches the refund queue.
  await db.recursiveDelete(userRef);
  await clearPassOwnership(db, uid);
  // The payment-to-account index keeps one minimal record per payment, with no uid, so a later
  // redelivery of a fulfilled payment is a duplicate and opens no refund task. Checkout and order
  // records are cut down the same way. A follow-up that
  // still owes a refund keeps its payment details without the uid; every other follow-up goes.
  for (const collection of ['paymongoPayments', 'paymongoOrders', 'paymongoCheckouts', 'paymongoFollowUps']) {
    const rows = await db.collection(collection).where('uid', '==', uid).get();
    await Promise.all(rows.docs.map((doc) => {
      if (collection === 'paymongoPayments') return doc.ref.set({accountDeleted: true, deletedAt: now});
      // A checkout link stays payable after deletion. Its record keeps only the quote, so a payment on
      // it reaches the webhook's closed-account path and becomes a refund task.
      if (collection === 'paymongoCheckouts' || collection === 'paymongoOrders') {
        const quote = doc.get('amountCentavos');
        return doc.ref.set({accountDeleted: true, deletedAt: now, product: doc.get('product') ?? null,
          ...(typeof quote === 'number' ? {amountCentavos: quote} : {})});
      }
      // A task closed since the read is no longer owed and goes with the rest.
      if (collection === 'paymongoFollowUps' && owesRefund(doc)) {
        return keepRefundTask(db, doc.ref, now).then(kept => kept ? undefined : doc.ref.delete());
      }
      return doc.ref.delete();
    }));
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

  // Question reports hold what the student wrote and name the account. The counts that limit them
  // sit in the user tree and went with it.
  const reports = await db.collection('questionReports').where('accountId', '==', uid).get();
  await Promise.all(reports.docs.map((doc) => doc.ref.delete()));

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

type EvidencePurchase = Record<string, unknown>;

/**
 * What a purchase record keeps as ten-year evidence, or null when it is not guardian evidence.
 * Only a guardian-kind declaration qualifies (legal lane, Nov 23 pass: adult declarations are not
 * kept). A record from before declarations existed carries `attestedAt` and was guardian-only by
 * construction. It has no wording id, so that field is null: every copy has the same five fields.
 */
function guardianPurchase(doc: DocumentSnapshot, reference: unknown): EvidencePurchase | null {
  const declaration = doc.get('declaration');
  if (declaration && typeof declaration === 'object') {
    if (declaration.kind !== 'guardian' || typeof declaration.at !== 'number') return null;
    return {attestedAt: declaration.at, termsVersion: declaration.termsVersion ?? null,
      wordingVersion: declaration.wordingVersion ?? null, reference, product: doc.get('product') ?? null};
  }
  if (typeof doc.get('attestedAt') !== 'number') return null;
  return {attestedAt: doc.get('attestedAt'), termsVersion: doc.get('termsVersion') ?? null, wordingVersion: null, reference,
    product: doc.get('product') ?? null};
}

/**
 * Marks the deletion in the guardian evidence and copies each guardian-declared purchase there,
 * before the user tree and the payment index go. Only an account with such evidence gets a marker,
 * so an adult with none leaves nothing behind. The copy holds the declaration time, the Terms
 * version, the wording id, our own reference and the product: no email, name or payment details.
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
  const purchases = new Map<string, {id: string; fields: EvidencePurchase}>();
  for (const doc of checkouts.docs) {
    const reference = doc.get('reference') ?? null;
    const fields = guardianPurchase(doc, reference);
    if (fields) purchases.set(reference ?? `checkout-${doc.id}`, {id: doc.id, fields});
  }
  for (const doc of orders.docs) {
    if (purchases.has(doc.id)) continue;
    const fields = guardianPurchase(doc, doc.id);
    if (fields) purchases.set(doc.id, {id: `order-${doc.id}`, fields});
  }
  if (answers.empty && purchases.size === 0) return;
  const batch = db.batch();
  for (const {id, fields} of purchases.values()) batch.set(evidence.collection('purchases').doc(id), fields);
  // A retry keeps the first deletion time, so the record does not drift later.
  const existing = (await evidence.get()).get('accountDeletedAt');
  if (typeof existing !== 'number') batch.set(evidence, {accountDeletedAt: now, reason}, {merge: true});
  await batch.commit();
}
