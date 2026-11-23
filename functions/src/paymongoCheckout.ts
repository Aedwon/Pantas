import {randomUUID, createHash} from 'node:crypto';
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
import {httpPaymongoClient, type PaymongoClient} from './paymongoClient.js';
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

const NAMES: Record<string, string> = {
  pantas_cs_weekly: 'Pantas Pro, Civil Service, 1 week',
  pantas_cs_monthly: 'Pantas Pro, Civil Service, 1 month',
  pantas_cs_yearly: 'Pantas Pro, Civil Service, 1 year',
  pantas_pass_cse_pro: 'Pantas Pro, CSE Professional pass',
  pantas_pass_cse_sub: 'Pantas Pro, CSE Subprofessional pass',
};

export type CheckoutDeps = {client: PaymongoClient; db: Firestore; origin: string; methods: string[];
  allow?: (uid: string) => Promise<boolean>; catalog?: CatalogExam[]; now?: () => number};

/**
 * The ids of the two declaration wordings the web checkout shows beside Pay (legal lane, Nov 23
 * pass). The id is stored with each order, so the text the buyer saw can be found again later.
 * Keep equal to `checkoutDeclarationWording` in the app (a test compares them). A new wording
 * gets a new id, in the same release.
 */
export const CHECKOUT_DECLARATION_WORDING = {
  adult: 'checkout-adult-2026-11-23', guardian: 'checkout-guardian-2026-11-23',
} as const;

export type DeclarationKind = keyof typeof CHECKOUT_DECLARATION_WORDING;

/** What is stored on the order and the checkout record for every web purchase. */
export type CheckoutDeclaration = {kind: DeclarationKind; wordingVersion: string; termsVersion: string; at: number};

/**
 * Every web checkout carries a declaration (ruling D2, option C). An account with a confirmed
 * guardian must send the guardian wording. Every other account sends the adult wording: a
 * pending, declined or withdrawn request, or only the under-18 flag, no longer changes the
 * wording. The device's age group only drives the screen; this check is the control.
 * Runs before any reservation write. One read, as before.
 */
async function checkoutDeclaration(db: Firestore, uid: string, data: unknown, now: number):
  Promise<CheckoutDeclaration> {
  const consent = (await db.doc(`users/${uid}/server/guardianConsent`).get()).data();
  const kind: DeclarationKind = consent?.status === 'confirmed' && consent.ageGroup === 'minor' ? 'guardian' : 'adult';
  const given = (data as {declaration?: unknown} | null)?.declaration;
  const sent = given && typeof given === 'object' ? given as Record<string, unknown> : {};
  if (sent.kind !== kind || sent.wordingVersion !== CHECKOUT_DECLARATION_WORDING[kind] ||
      sent.termsVersion !== GUARDIAN_DOCUMENT_VERSIONS.terms) {
    throw new HttpsError('failed-precondition', 'Confirm the declaration to continue.',
      {reason: 'declaration-required', kind});
  }
  return {kind, wordingVersion: CHECKOUT_DECLARATION_WORDING[kind], termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms, at: now};
}

export async function createCheckout(auth: Parameters<typeof assertNamedUser>[0], data: unknown,
  deps: CheckoutDeps): Promise<{checkoutUrl: string; sessionId: string; reference: string}> {
  const uid = assertNamedUser(auth);
  const requested = (data as {product?: unknown} | null)?.product;
  const product = typeof requested === 'string' ? webProduct(requested) : undefined;
  if (!product) throw new HttpsError('invalid-argument', 'This product is not sold on the web.');
  const now = (deps.now ?? Date.now)();
  const declaration = await checkoutDeclaration(deps.db, uid, data, now);
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
  const binding = {uid, product: product.id, createdAt: now, declaration,
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
      // The declaration just made must reach the records this session is paid against.
      const update = deps.db.batch();
      update.update(deps.db.doc(`paymongoCheckouts/${reserved.sessionId as string}`), {declaration});
      update.update(deps.db.doc(`paymongoOrders/${reserved.reference as string}`), {declaration});
      await update.commit();
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
        reference: referenceNumber, declaration, ...(sitting ? {examId: product.examId, sitting} : {})});
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
  {region: 'asia-southeast1', serviceAccount: serviceAccountEmail('pantas-payments'), enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck, secrets: [paymentSecrets]},
  timed('createPaymongoCheckout', request => {
    assertFreshAppCheck(request);
    return createCheckout(request.auth, request.data, {
      client: httpPaymongoClient(secret('PAYMONGO_SECRET_KEY')), db: getFirestore(),
      origin: process.env.PANTAS_APP_ORIGIN ?? 'https://app.pantas.study',
      methods: process.env.PAYMONGO_PAYMENT_METHODS?.split(',').map(m => m.trim()).filter(Boolean) ?? DEFAULT_METHODS,
    });
  }));
