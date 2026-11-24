import {randomUUID, createHash} from 'node:crypto';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {getFirestore, type DocumentReference, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';
import {HttpsError} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {paymentSecrets, secret} from './_secrets.js';
import {GUARDIAN_DOCUMENT_VERSIONS} from './guardianConsent.js';
import {allowAtMost} from './_limits.js';
import type {Grant} from './grants.js';
import {grantDocId} from './paymongoGrants.js';
import {httpPaymongoClient, type PaymongoClient, type PaymongoPayment} from './paymongoClient.js';
import {fulfillPaidSession} from './paymongoWebhook.js';
import {priceCentavos, webProduct} from './paymongoPolicy.js';
import {examCatalog, sittingFor, type CatalogExam, type Sitting} from './revenuecatPasses.js';
import {timed} from './_timed.js';
import {serviceAccountEmail} from './serviceAccounts.js';

const CHECKOUTS_PER_WINDOW = 10;
const WINDOW_MS = 10 * 60_000;
// A `creating` reservation younger than this belongs to a live attempt. Once it lapses the
// next attempt takes it over, so a crash that skips the reset cannot strand the account.
const CREATING_LEASE_MS = 2 * 60_000;
// Method values confirmed in PayMongo's docs. Add more (for example dob) through
// PAYMONGO_PAYMENT_METHODS once the merchant account has them enabled.
const DEFAULT_METHODS = ['card', 'qrph'];
// A payment older than this with no grant has missed its webhook; the checkout call completes it.
const HEAL_AFTER_MS = 10 * 60_000;

const NAMES: Record<string, string> = {
  pantas_cs_weekly: 'Pantas Pro, Civil Service, 1 week',
  pantas_cs_monthly: 'Pantas Pro, Civil Service, 1 month',
  pantas_cs_yearly: 'Pantas Pro, Civil Service, 1 year',
  pantas_pass_cse_pro: 'Pantas Pro, CSE Professional pass',
  pantas_pass_cse_sub: 'Pantas Pro, CSE Subprofessional pass',
};

export type CheckoutDeps = {client: PaymongoClient; db: Firestore; origin: string; methods: string[];
  /** Needed to finish a paid session whose webhook never granted. Without it the call only reports the delay. */
  auth?: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  allow?: (uid: string) => Promise<boolean>; catalog?: CatalogExam[]; now?: () => number};

/**
 * An account the server knows as a minor can only buy with a parent or guardian's confirmation
 * of the current Terms. The device's age group only drives the screen; this check is the control.
 * Returns what to record on the checkout (nothing for an adult). Runs before any reservation write.
 */
async function guardianAttestation(db: Firestore, uid: string, data: unknown, now: number):
  Promise<{attestedAt?: number; termsVersion?: string}> {
  const consent = (await db.doc(`users/${uid}/server/guardianConsent`).get()).data();
  if (consent?.ageGroup !== 'minor') return {};
  const given = (data as {guardianAttestation?: {termsVersion?: unknown} | null} | null)?.guardianAttestation?.termsVersion;
  if (given !== GUARDIAN_DOCUMENT_VERSIONS.terms) {
    throw new HttpsError('failed-precondition', 'A parent or guardian must confirm this purchase.',
      {reason: 'guardian-attestation-required'});
  }
  return {attestedAt: now, termsVersion: given};
}

export async function createCheckout(auth: Parameters<typeof assertNamedUser>[0], data: unknown,
  deps: CheckoutDeps): Promise<{checkoutUrl: string; sessionId: string; reference: string}> {
  const uid = assertNamedUser(auth);
  const requested = (data as {product?: unknown} | null)?.product;
  const product = typeof requested === 'string' ? webProduct(requested) : undefined;
  if (!product) throw new HttpsError('invalid-argument', 'This product is not sold on the web.');
  const now = (deps.now ?? Date.now)();
  const attestation = await guardianAttestation(deps.db, uid, data, now);
  const allowed = await (deps.allow ?? (id => allowAtMost(id, 'paymongoCheckout', CHECKOUTS_PER_WINDOW, WINDOW_MS)))(uid);
  if (!allowed) throw new HttpsError('resource-exhausted', 'Too many checkout attempts. Try again later.');
  let sitting: Sitting | undefined;
  if (product.prepaid.unit === 'sitting') {
    sitting = product.examId ? sittingFor(deps.catalog ?? examCatalog, product.examId, now) : undefined;
    if (!product.examId || !sitting) {
      throw new HttpsError('failed-precondition', 'No exam date is published for this pass yet.');
    }
    const rows = await deps.db.collection(`users/${uid}/grants`).get();
    if (rows.docs.some(d => {
      const grant = d.data() as Grant;
      return grant.product === product.id && grant.state === 'active' && grant.endsAt > now;
    })) throw new HttpsError('already-exists', 'This pass is already active.');
  }
  const key = createHash('sha256').update(JSON.stringify([product.id, sitting?.firstDay ?? null])).digest('hex');
  const pending = deps.db.doc(`users/${uid}/pendingCheckouts/${key}`);
  const referenceNumber = randomUUID();
  const order = deps.db.doc(`paymongoOrders/${referenceNumber}`);
  const amountCentavos = priceCentavos(product);
  const binding = {uid, product: product.id, createdAt: now, amountCentavos, ...attestation,
    ...(sitting ? {examId: product.examId, sitting} : {})};
  // A minor's current confirmation must reach the records an open session is paid against.
  const reuse = async (open: Record<string, unknown>) => {
    if (attestation.attestedAt !== undefined) {
      const update = deps.db.batch();
      update.update(deps.db.doc(`paymongoCheckouts/${open.sessionId as string}`), attestation);
      update.update(deps.db.doc(`paymongoOrders/${open.reference as string}`), attestation);
      await update.commit();
    }
    return {checkoutUrl: open.checkoutUrl as string, sessionId: open.sessionId as string, reference: open.reference as string};
  };
  if (sitting) {
    // A pass retried after its sitting changed looks under every sitting key. An open, unpaid session is
    // returned: the payer pays the price and sitting it shows, and a pass paid after its sitting is
    // refunded by the late-pass rule. An expired or paid session is replaced as usual.
    for (const other of (await deps.db.collection(`users/${uid}/pendingCheckouts`).where('product', '==', product.id).get()).docs) {
      if (other.id === key || other.get('state') !== 'open' || typeof other.get('sessionId') !== 'string') continue;
      if (await earlierSessionVerdict(deps, uid, other.get('sessionId') as string, now) === 'reuse') {
        return reuse({sessionId: other.get('sessionId'), reference: other.get('reference'), checkoutUrl: other.get('checkoutUrl')});
      }
    }
  }
  const reserved = await deps.db.runTransaction(async transaction => {
    const [previous, deletion] = await transaction.getAll(pending, deps.db.doc(`accountDeletions/${uid}`));
    if (deletion.exists) throw new HttpsError('failed-precondition', 'This account is closed.');
    if (previous.exists) {
      const data = previous.data()!;
      const lapsed = data.state === 'creating' && !(now - Number(data.createdAt) < CREATING_LEASE_MS);
      if (!lapsed) return data;
      transaction.set(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
      transaction.create(order, binding);
      return null;
    }
    transaction.create(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
    transaction.create(order, binding);
    return null;
  });
  if (reserved) {
    if (reserved.state !== 'open') throw new HttpsError('aborted', 'Checkout creation is pending. Try again later.');
    // An open, unpaid session is always reused, even if the price changed since it was created: the
    // payer pays the price the session shows, and the webhook checks the order's quoted amount.
    // Legacy orders without a quoted amount are moot: prod has test keys only and test grants are revoked at the live switch.
    if (await earlierSessionVerdict(deps, uid, reserved.sessionId as string, now) === 'reuse') return reuse(reserved);
    // Compare-and-swap: only one request can replace a completed or expired checkout.
    await deps.db.runTransaction(async transaction => {
      const [current, deletion] = await transaction.getAll(pending, deps.db.doc(`accountDeletions/${uid}`));
      if (deletion.exists) throw new HttpsError('failed-precondition', 'This account is closed.');
      if (current.get('reference') !== reserved.reference) throw new HttpsError('aborted', 'Checkout changed. Try again.');
      transaction.set(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
      transaction.create(order, binding);
    });
  }
  // From here this attempt owns the `creating` reservation under `referenceNumber`. Any failure
  // releases it at once, only if it is still ours. A lapsed lease covers a crash before the reset.
  // Sessions are never reconciled with PayMongo by reference: the customer receives the link only
  // after the final write succeeds, so a session this attempt loses (lost response, failed write,
  // superseded attempt) was never shown to anyone. PayMongo sessions do not expire on their own,
  // but if one were somehow paid, its order is kept and the webhook still grants Pro to the bound
  // account, so the customer is not charged without Pro. A new session under a new reference is
  // therefore safe.
  try {
    const session = await deps.client.createCheckoutSession({uid, product: product.id,
      name: NAMES[product.id] ?? product.id, amountCentavos,
      successUrl: `${deps.origin}/pro?checkout=success&ref=${referenceNumber}`, cancelUrl: `${deps.origin}/pro?checkout=cancelled&ref=${referenceNumber}`,
      paymentMethodTypes: deps.methods, referenceNumber});
    const result = {checkoutUrl: session.checkoutUrl, sessionId: session.id, reference: referenceNumber};
    // Guarded final write: a slow attempt must not overwrite a newer one. If the reservation is no
    // longer ours, this session is discarded and no link is returned.
    await deps.db.runTransaction(async transaction => {
      const [current, deletion] = await transaction.getAll(pending, deps.db.doc(`accountDeletions/${uid}`));
      if (deletion.exists) throw new HttpsError('failed-precondition', 'This account is closed.');
      if (current.get('state') !== 'creating' || current.get('reference') !== referenceNumber) {
        throw new HttpsError('aborted', 'Checkout creation was superseded. Try again.');
      }
      transaction.set(deps.db.doc(`paymongoCheckouts/${session.id}`), {...binding, reference: referenceNumber});
      transaction.update(order, {sessionId: session.id});
      transaction.set(pending, {...result, state: 'open', product: product.id, createdAt: now, amountCentavos});
    });
    return result;
  } catch (error) {
    await releaseReservation(deps.db, pending, referenceNumber);
    throw error;
  }
}

/**
 * What to do with a session an earlier attempt left open, for the same key or an earlier sitting.
 * Open and unpaid: reuse it. Unknown status: refuse, so a link that may still be payable is never
 * doubled. Paid without a grant: refuse as being confirmed, or heal it once it is older than
 * HEAL_AFTER_MS. Paid with a grant, or expired: the caller replaces it.
 */
async function earlierSessionVerdict(deps: CheckoutDeps, uid: string, sessionId: string, now: number): Promise<'reuse' | 'replace'> {
  const remote = await deps.client.getCheckoutSession(sessionId);
  const paidPayments = remote.payments.filter(p => p.status === 'paid');
  if (remote.status === 'active' && paidPayments.length === 0) return 'reuse';
  if (remote.status !== 'expired' && paidPayments.length === 0) {
    throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
  }
  // A paid session whose webhook has not granted yet must never lead to a second session: the
  // customer could pay twice. Keep the reservation so the webhook completes the grant.
  for (const payment of paidPayments) {
    const recorded = async () => (await deps.db.doc(`paymongoPayments/${grantDocId(payment.id)}`).get()).exists;
    if (!(await recorded()) && !(remote.metadata.uid === uid && await healPaidPayment(deps, sessionId, payment, now) && await recorded())) {
      logger.warn('Checkout replacement refused: previous session is paid and its grant is not processed yet');
      throw new HttpsError('failed-precondition', 'Your payment is being confirmed. Pro will appear shortly.');
    }
  }
  return 'replace';
}

/**
 * Completes the grant for a payment PayMongo reports paid that has no grant after HEAL_AFTER_MS,
 * through the same function the webhook uses. The session and payment are read from PayMongo, never
 * from the request. The event id `heal_<payment id>` makes a later real webhook a duplicate.
 */
async function healPaidPayment(deps: CheckoutDeps, sessionId: string, payment: PaymongoPayment, now: number): Promise<boolean> {
  if (!deps.auth || payment.paidAt === undefined || now - payment.paidAt <= HEAL_AFTER_MS) return false;
  try {
    const status = await fulfillPaidSession({db: deps.db, auth: deps.auth, client: deps.client, catalog: deps.catalog},
      `heal_${payment.id}`, sessionId, null, () => now);
    if (status === 200) logger.warn('Checkout completed a paid session whose webhook never granted', {paymentId: payment.id});
    return status === 200;
  } catch (error) {
    logger.error('Checkout could not complete a paid session', {paymentId: payment.id, error});
    return false;
  }
}

/** Deletes the reservation only while it is still `creating` under this attempt's reference. */
async function releaseReservation(db: Firestore, pending: DocumentReference, reference: string): Promise<void> {
  try {
    await db.runTransaction(async transaction => {
      const current = await transaction.get(pending);
      if (current.get('state') === 'creating' && current.get('reference') === reference) transaction.delete(pending);
    });
  } catch {
    // The lease lapses on its own; the original failure is the one to report.
  }
}

export const createPaymongoCheckout = onCall(
  {region: 'asia-southeast1', serviceAccount: serviceAccountEmail('pantas-payments'), enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck, secrets: [paymentSecrets]},
  timed('createPaymongoCheckout', request => {
    assertFreshAppCheck(request);
    return createCheckout(request.auth, request.data, {
      client: httpPaymongoClient(secret('PAYMONGO_SECRET_KEY')), db: getFirestore(), auth: getAuth(),
      origin: process.env.PANTAS_APP_ORIGIN ?? 'https://app.pantas.study',
      methods: process.env.PAYMONGO_PAYMENT_METHODS?.split(',').map(m => m.trim()).filter(Boolean) ?? DEFAULT_METHODS,
    });
  }));
