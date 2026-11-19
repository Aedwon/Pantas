import {randomUUID, createHash} from 'node:crypto';
import {getFirestore, type DocumentReference, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';
import {HttpsError} from 'firebase-functions/v2/https';
import {assertAccountActive, onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {holderForChild} from './childLinks.js';
import {isRestrictedAgeGroup} from './ageGroup.js';
import {paymentSecrets, secret} from './_secrets.js';
import {GUARDIAN_DOCUMENT_VERSIONS} from './guardianConsent.js';
import {allowAtMost} from './_limits.js';
import type {Grant} from './grants.js';
import {grantDocId} from './paymongoGrants.js';
import {httpPaymongoClient, type PaymongoClient} from './paymongoClient.js';
import {priceCentavos, webProduct} from './paymongoPolicy.js';
import {examCatalog, sittingFor, type CatalogExam, type Sitting} from './revenuecatPasses.js';
import {timed} from './_timed.js';

export const CHECKOUT_BOX_TEXT_VERSION = '2026-11-20';
const PSHS_NCE_EXAM = 'exam_pshs_nce';

const CHECKOUTS_PER_WINDOW = 10;
const WINDOW_MS = 10 * 60_000;
// A `creating` reservation younger than this belongs to a live attempt. Once it lapses the
// next attempt takes it over, so a crash that skips the reset cannot strand the account.
const CREATING_LEASE_MS = 2 * 60_000;
// Method values confirmed in PayMongo's docs. Add more (for example dob) through
// PAYMONGO_PAYMENT_METHODS once the merchant account has them enabled.
const DEFAULT_METHODS = ['card', 'qrph'];

const NAMES: Record<string, string> = {
  pantas_cs_weekly: 'Pantas Pro, Civil Service, 1 week',
  pantas_cs_monthly: 'Pantas Pro, Civil Service, 1 month',
  pantas_cs_yearly: 'Pantas Pro, Civil Service, 1 year',
  pantas_pass_cse_pro: 'Pantas Pro, CSE Professional pass',
  pantas_pass_cse_sub: 'Pantas Pro, CSE Subprofessional pass',
};

export type CheckoutDeps = {client: PaymongoClient; db: Firestore; origin: string; methods: string[];
  allow?: (uid: string) => Promise<boolean>; catalog?: CatalogExam[]; now?: () => number;
  productFor?: typeof webProduct};

// PSHS requires its own declaration. Other products keep the existing guardian Terms check.
function guardianAttestation(restricted: boolean, pshs: boolean, data: unknown, now: number):
  {attestedAt?: number; termsVersion?: string; checkoutBoxTextVersion?: string} {
  if (pshs) {
    const version = (data as {checkoutBoxTextVersion?: unknown} | null)?.checkoutBoxTextVersion;
    if (version !== CHECKOUT_BOX_TEXT_VERSION) {
      throw new HttpsError('failed-precondition', 'Confirm the current checkout declaration.',
        {reason: 'stale-checkout-box'});
    }
    return {attestedAt: now, termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms, checkoutBoxTextVersion: version};
  }
  if (!restricted) return {};
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
  // The parent or guardian's own sign-in holds no study data and buys nothing. A pass is bought inside the
  // child's session, so it belongs to that child (under-13 build, spec B2 rule 4).
  if ((await deps.db.doc(`users/${uid}/server/holder`).get()).exists) {
    throw new HttpsError('permission-denied', 'This sign-in is for a parent or guardian. Open your child\'s account to buy.',
      {reason: 'holder-cannot-buy'});
  }
  const requested = (data as {product?: unknown} | null)?.product;
  const product = typeof requested === 'string' ? (deps.productFor ?? webProduct)(requested) : undefined;
  const consent = (await deps.db.doc(`users/${uid}/server/guardianConsent`).get()).data();
  const claims = auth?.token as {ageGroup?: unknown; holder?: unknown} | undefined;
  const child = claims?.ageGroup === 'child' || consent?.ageGroup === 'child';
  const pshs = product?.examId === PSHS_NCE_EXAM;
  if (child && !pshs) {
    throw new HttpsError('permission-denied', 'This account can buy only the PSHS-NCE pass.',
      {reason: 'child-product'});
  }
  if (!product) throw new HttpsError('invalid-argument', 'This product is not sold on the web.');
  const now = (deps.now ?? Date.now)();
  const restricted = (consent !== undefined && isRestrictedAgeGroup(consent.ageGroup))
    || (claims?.ageGroup !== undefined && isRestrictedAgeGroup(claims.ageGroup));
  const attestation = guardianAttestation(restricted, pshs, data, now);
  if (child) {
    const holder = await holderForChild(deps.db, uid);
    if (!holder || (claims?.ageGroup === 'child' && claims.holder !== holder)) {
      throw new HttpsError('permission-denied', 'This child account is not linked.', {reason: 'not-linked'});
    }
    await assertAccountActive(deps.db, uid);
    await assertAccountActive(deps.db, holder);
  }
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
  const binding = {uid, product: product.id, createdAt: now, ...attestation,
    ...(sitting ? {examId: product.examId, sitting} : {})};
  const reserved = await deps.db.runTransaction(async transaction => {
    const previous = await transaction.get(pending);
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
    const remote = await deps.client.getCheckoutSession(reserved.sessionId as string);
    if (remote.status === 'active' && !remote.payments.some(p => p.status === 'paid')) {
      // Save the current confirmation on both records for the reused session.
      if (attestation.attestedAt !== undefined) {
        const update = deps.db.batch();
        update.update(deps.db.doc(`paymongoCheckouts/${reserved.sessionId as string}`), attestation);
        update.update(deps.db.doc(`paymongoOrders/${reserved.reference as string}`), attestation);
        await update.commit();
      }
      return {checkoutUrl: reserved.checkoutUrl as string, sessionId: reserved.sessionId as string, reference: reserved.reference as string};
    }
    if (remote.status !== 'expired' && !remote.payments.some(p => p.status === 'paid')) {
      throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
    }
    // A paid session whose webhook has not granted yet must never lead to a second session: the
    // customer could pay twice. Keep the reservation so the webhook completes the grant.
    for (const payment of remote.payments.filter(p => p.status === 'paid')) {
      if (!(await deps.db.doc(`paymongoPayments/${grantDocId(payment.id)}`).get()).exists) {
        logger.warn('Checkout replacement refused: previous session is paid and its grant is not processed yet');
        throw new HttpsError('failed-precondition', 'Your payment is being confirmed. Pro will appear shortly.');
      }
    }
    // Compare-and-swap: only one request can replace a completed/expired checkout.
    await deps.db.runTransaction(async transaction => {
      const current = await transaction.get(pending);
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
      name: NAMES[product.id] ?? product.id, amountCentavos: priceCentavos(product),
      successUrl: `${deps.origin}/pro?checkout=success&ref=${referenceNumber}`, cancelUrl: `${deps.origin}/pro?checkout=cancelled&ref=${referenceNumber}`,
      paymentMethodTypes: deps.methods, referenceNumber});
    const result = {checkoutUrl: session.checkoutUrl, sessionId: session.id, reference: referenceNumber};
    // Guarded final write: a slow attempt must not overwrite a newer one. If the reservation is no
    // longer ours, this session is discarded and no link is returned.
    await deps.db.runTransaction(async transaction => {
      const current = await transaction.get(pending);
      if (current.get('state') !== 'creating' || current.get('reference') !== referenceNumber) {
        throw new HttpsError('aborted', 'Checkout creation was superseded. Try again.');
      }
      transaction.set(deps.db.doc(`paymongoCheckouts/${session.id}`), {uid, product: product.id, createdAt: now,
        reference: referenceNumber, ...attestation, ...(sitting ? {examId: product.examId, sitting} : {})});
      transaction.update(order, {sessionId: session.id});
      transaction.set(pending, {...result, state: 'open', product: product.id, createdAt: now});
    });
    return result;
  } catch (error) {
    await releaseReservation(deps.db, pending, referenceNumber);
    throw error;
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
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck, secrets: [paymentSecrets]},
  timed('createPaymongoCheckout', request => {
    assertFreshAppCheck(request);
    return createCheckout(request.auth, request.data, {
      client: httpPaymongoClient(secret('PAYMONGO_SECRET_KEY')), db: getFirestore(),
      origin: process.env.PANTAS_APP_ORIGIN ?? 'https://app.pantas.study',
      methods: process.env.PAYMONGO_PAYMENT_METHODS?.split(',').map(m => m.trim()).filter(Boolean) ?? DEFAULT_METHODS,
    });
  }));
