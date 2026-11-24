import {randomUUID, createHash} from 'node:crypto';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {getFirestore, type DocumentReference, type DocumentSnapshot, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';
import {HttpsError} from 'firebase-functions/v2/https';
import {accountClosed, onAccountCall as onCall} from './_accountAccess.js';
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

/** The records that decide the wording and whether the account may still buy. */
const accountRefs = (db: Firestore, uid: string) =>
  [db.doc(`accountDeletions/${uid}`), db.doc(`users/${uid}/server/guardianConsent`)] as const;

/**
 * Every web checkout carries a declaration (ruling D2, option C). An account with a confirmed
 * guardian must send the guardian wording. Every other account sends the adult wording: a
 * pending, declined or withdrawn request, or only the under-18 flag, no longer changes the
 * wording. A closed account buys nothing. The device's age group only drives the screen; this
 * check is the control. It is read twice (early, then inside each transaction that reserves or
 * finishes a checkout) so a consent or closure that lands mid-call is caught.
 */
function declarationFor(snaps: DocumentSnapshot[], data: unknown, now: number): CheckoutDeclaration {
  const [deletion, consent] = snaps;
  if (deletion.exists || consent.get('status') === 'withdrawn') throw accountClosed();
  const kind: DeclarationKind = consent.get('status') === 'confirmed' && consent.get('ageGroup') === 'minor' ? 'guardian' : 'adult';
  const given = (data as {declaration?: unknown} | null)?.declaration;
  const sent = given && typeof given === 'object' ? given as Record<string, unknown> : {};
  if (sent.kind !== kind || sent.wordingVersion !== CHECKOUT_DECLARATION_WORDING[kind] ||
      sent.termsVersion !== GUARDIAN_DOCUMENT_VERSIONS.terms) {
    throw new HttpsError('failed-precondition', 'Confirm the declaration to continue.',
      {reason: 'declaration-required', kind});
  }
  return {kind, wordingVersion: CHECKOUT_DECLARATION_WORDING[kind], termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms, at: now};
}

/** The buyer's payment for the session in question exists. No new link is issued. */
const alreadyPaid = () => new HttpsError('already-exists', 'Your payment was received. Pro will appear shortly.',
  {reason: 'already-paid'});

/** A stored declaration is reusable only when it says what the buyer must declare now. */
const sameDeclaration = (stored: unknown, now: CheckoutDeclaration): boolean => {
  const d = stored && typeof stored === 'object' ? stored as Record<string, unknown> : {};
  return d.kind === now.kind && d.wordingVersion === now.wordingVersion && d.termsVersion === now.termsVersion;
};

export async function createCheckout(auth: Parameters<typeof assertNamedUser>[0], data: unknown,
  deps: CheckoutDeps): Promise<{checkoutUrl: string; sessionId: string; reference: string}> {
  const uid = assertNamedUser(auth);
  const requested = (data as {product?: unknown} | null)?.product;
  const product = typeof requested === 'string' ? webProduct(requested) : undefined;
  if (!product) throw new HttpsError('invalid-argument', 'This product is not sold on the web.');
  const now = (deps.now ?? Date.now)();
  let declaration = declarationFor(await deps.db.getAll(...accountRefs(deps.db, uid)), data, now);
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
  // The quoted amount is stored on the order: the webhook checks the payment against it.
  const bindingFor = (d: CheckoutDeclaration) => ({uid, product: product.id, createdAt: now, amountCentavos, declaration: d,
    ...(sitting ? {examId: product.examId, sitting} : {})});
  if (sitting) {
    // A pass retried after its sitting changed looks under every sitting key. An open, unpaid session is
    // returned: the payer pays the price and sitting it shows, and a pass paid after its sitting is
    // refunded by the late-pass rule. An expired or paid session is replaced as usual.
    for (const other of (await deps.db.collection(`users/${uid}/pendingCheckouts`).where('product', '==', product.id).get()).docs) {
      if (other.id === key || other.get('state') !== 'open' || typeof other.get('sessionId') !== 'string') continue;
      const held = {sessionId: other.get('sessionId') as string, reference: other.get('reference') as string, checkoutUrl: other.get('checkoutUrl') as string};
      const stored = (await deps.db.doc(`paymongoOrders/${held.reference}`).get()).get('declaration');
      if (await sessionVerdict(deps, uid, held.sessionId, now, sameDeclaration(stored, declaration)) === 'reuse') {
        return reuseOpen(deps, other.ref, uid, data, now, held);
      }
    }
  }
  type Held = {state?: string; unissuedSessionId?: string; sessionId?: string; checkoutUrl?: string; reference?: string; matches: boolean};
  const reserved = await deps.db.runTransaction(async (transaction): Promise<Held | null> => {
    const [previous, ...account] = await transaction.getAll(pending, ...accountRefs(deps.db, uid));
    declaration = declarationFor(account, data, now);
    if (previous.exists) {
      const held = previous.data()!;
      const lapsed = held.state === 'creating' && !(now - Number(held.createdAt) < CREATING_LEASE_MS);
      if (!lapsed) {
        const stored = held.state === 'open' && typeof held.reference === 'string'
          ? (await transaction.get(deps.db.doc(`paymongoOrders/${held.reference}`))).get('declaration') : undefined;
        return {...held, matches: sameDeclaration(stored, declaration)} as Held;
      }
      transaction.set(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
      transaction.create(order, bindingFor(declaration));
      return null;
    }
    transaction.create(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
    transaction.create(order, bindingFor(declaration));
    return null;
  });
  if (reserved) {
    if (reserved.state === 'unissued') {
      // An earlier attempt made a session it could not hand out and could not expire. No new
      // link until that one is confirmed expired (or found paid).
      await settleUnissued(deps, pending, reserved.unissuedSessionId!);
      return createCheckout(auth, data, deps);
    }
    if (reserved.state !== 'open') throw new HttpsError('aborted', 'Checkout creation is pending. Try again later.');
    // An open, unpaid session is always reused, even if the price changed since it was created: the
    // payer pays the price the session shows, and the webhook checks the order's quoted amount.
    // Legacy orders without a quoted amount are moot: prod has test keys only and test grants are revoked at the live switch.
    // (A session whose declaration no longer matches is the one exception: it is expired and replaced.)
    if (await sessionVerdict(deps, uid, reserved.sessionId!, now, reserved.matches) === 'reuse') {
      return reuseOpen(deps, pending, uid, data, now, reserved as {sessionId: string; reference: string; checkoutUrl: string});
    }
    // Compare-and-swap: only one request can replace a completed or expired checkout.
    await deps.db.runTransaction(async transaction => {
      const [current, ...account] = await transaction.getAll(pending, ...accountRefs(deps.db, uid));
      declaration = declarationFor(account, data, now);
      if (current.get('reference') !== reserved.reference) throw new HttpsError('aborted', 'Checkout changed. Try again.');
      transaction.set(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
      transaction.create(order, bindingFor(declaration));
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
  let made: string | undefined;
  try {
    const session = await deps.client.createCheckoutSession({uid, product: product.id,
      name: NAMES[product.id] ?? product.id, amountCentavos,
      successUrl: `${deps.origin}/pro?checkout=success&ref=${referenceNumber}`, cancelUrl: `${deps.origin}/pro?checkout=cancelled&ref=${referenceNumber}`,
      paymentMethodTypes: deps.methods, referenceNumber});
    made = session.id;
    const result = {checkoutUrl: session.checkoutUrl, sessionId: session.id, reference: referenceNumber};
    // Guarded final write: a slow attempt must not overwrite a newer one. If the reservation is no
    // longer ours, this session is discarded and no link is returned.
    await deps.db.runTransaction(async transaction => {
      const [current, ...account] = await transaction.getAll(pending, ...accountRefs(deps.db, uid));
      if (current.get('state') !== 'creating' || current.get('reference') !== referenceNumber) {
        throw new HttpsError('aborted', 'Checkout creation was superseded. Try again.');
      }
      // Consent or closure may have changed while the session was made: no link then.
      declarationFor(account, data, now);
      transaction.set(deps.db.doc(`paymongoCheckouts/${session.id}`), {...bindingFor(declaration), reference: referenceNumber});
      transaction.update(order, {sessionId: session.id});
      transaction.set(pending, {...result, state: 'open', product: product.id, createdAt: now, amountCentavos});
    });
    return result;
  } catch (error) {
    if (made && !(await expireUnissued(deps, uid, made))) {
      // The unissued session may still be payable: keep it on the reservation so a retry
      // expires it first and makes no new link until then.
      await markUnissued(deps.db, pending, referenceNumber, product.id, made, now);
    } else {
      await releaseReservation(deps.db, pending, referenceNumber);
    }
    throw error;
  }
}

/**
 * One verdict for a session an earlier attempt left open, whether it sits under the same key or an
 * earlier sitting's key. Open and unpaid and `reusable`: reuse it. Open and unpaid but not reusable
 * (its declaration is out of date), or in an unknown status: expire it and read it again; a link that
 * may still be payable never leads to a second one. Paid without a grant: refuse as being confirmed,
 * or heal it once it is older than HEAL_AFTER_MS. Paid with a grant, or expired: the caller replaces it.
 */
async function sessionVerdict(deps: CheckoutDeps, uid: string, sessionId: string, now: number,
  reusable: boolean): Promise<'reuse' | 'replace'> {
  let remote = await deps.client.getCheckoutSession(sessionId);
  const paidAlready = remote.payments.some(p => p.status === 'paid');
  if (reusable && remote.status === 'active' && !paidAlready) return 'reuse';
  // Never two payable links. PayMongo checkout sessions do not expire on their own, so a session
  // that is to be replaced is expired first and read again. A refused expiry (400: already
  // paid, or a payment is pending or processing) or a failed one means the old link may still
  // be payable: no replacement is made, and the buyer can retry.
  if (remote.status !== 'expired' && !paidAlready) {
    try {
      await deps.client.expireCheckoutSession(sessionId);
      remote = await deps.client.getCheckoutSession(sessionId);
    } catch {
      logger.warn('Checkout replacement refused: the old session could not be expired', {reason: 'expire-failed'});
      throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
    }
  }
  // Paid only after the expiry attempt: the buyer paid the old link while we were replacing it.
  // That payment is theirs whether or not the webhook has granted it yet. No new link is issued
  // in this request; the app refreshes the entitlement. (A session already paid before this
  // request is handled below, so a later repeat purchase still works.)
  if (!paidAlready && remote.payments.some(p => p.status === 'paid')) throw alreadyPaid();
  // A paid session whose webhook has not granted yet must never lead to a second session: the
  // customer could pay twice. Keep the reservation so the webhook completes the grant.
  for (const payment of remote.payments.filter(p => p.status === 'paid')) {
    const recorded = async () => (await deps.db.doc(`paymongoPayments/${grantDocId(payment.id)}`).get()).exists;
    if (!(await recorded()) && !(remote.metadata?.uid === uid && await healPaidPayment(deps, sessionId, payment, now) && await recorded())) {
      logger.warn('Checkout replacement refused: previous session is paid and its grant is not processed yet', {reason: 'paid-ungranted'});
      throw new HttpsError('failed-precondition', 'Your payment is being confirmed. Pro will appear shortly.');
    }
  }
  // Replace only a session confirmed expired, or one that was paid and already granted.
  if (remote.status !== 'expired' && !remote.payments.some(p => p.status === 'paid')) {
    throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
  }
  return 'replace';
}

/**
 * Hands out an open session again. Payment and its webhook may have completed since the verdict.
 * Read the provider again, then decide inside a transaction that also reads the grant index and
 * the account state. A paid session, granted or not, gets no link: the app refreshes the entitlement.
 */
async function reuseOpen(deps: CheckoutDeps, pending: DocumentReference, uid: string, data: unknown, now: number,
  held: {sessionId: string; reference: string; checkoutUrl: string}): Promise<{checkoutUrl: string; sessionId: string; reference: string}> {
  const again = await deps.client.getCheckoutSession(held.sessionId);
  if (again.payments.some(p => p.status === 'paid')) throw alreadyPaid();
  await deps.db.runTransaction(async transaction => {
    const [current, ...account] = await transaction.getAll(pending, ...accountRefs(deps.db, uid));
    declarationFor(account, data, now);
    const grants = await transaction.get(deps.db.collection('paymongoPayments')
      .where('sessionId', '==', held.sessionId).limit(1));
    if (!grants.empty) throw alreadyPaid();
    if (current.get('reference') !== held.reference || current.get('state') !== 'open') {
      throw new HttpsError('aborted', 'Checkout changed. Try again.');
    }
  });
  return {checkoutUrl: held.checkoutUrl, sessionId: held.sessionId, reference: held.reference};
}

/**
 * A session was made but never handed out (consent changed, account closed, the final write
 * failed): expire it so no payable link exists that nobody holds. Best effort. If PayMongo will
 * not expire it, record a follow-up and log the reason code only (no account or session data).
 */
async function expireUnissued(deps: CheckoutDeps, uid: string, sessionId: string): Promise<boolean> {
  try {
    if (await deps.client.expireCheckoutSession(sessionId)) return true;
  } catch {
    // Handled below, the same as a refusal.
  }
  logger.warn('A checkout session that was never issued could not be expired', {reason: 'unissued-session-not-expired'});
  try {
    await deps.db.doc(`paymongoFollowUps/${encodeURIComponent(sessionId)}`).set({uid, sessionId,
      reason: 'unissuedSessionNotExpired', status: 'pending'});
  } catch {
    // The log line above is all that is left.
  }
  return false;
}

/** Keeps the reservation, now naming the session that could not be expired, only while it is still ours. */
async function markUnissued(db: Firestore, pending: DocumentReference, reference: string, productId: string,
  sessionId: string, now: number): Promise<void> {
  try {
    await db.runTransaction(async transaction => {
      const current = await transaction.get(pending);
      if (current.get('state') === 'creating' && current.get('reference') === reference) {
        transaction.set(pending, {state: 'unissued', reference, product: productId, createdAt: now, unissuedSessionId: sessionId});
      }
    });
  } catch {
    // The follow-up record names the session; the reservation lease lapses on its own.
  }
}

/**
 * Settles an unissued session left by a failed cleanup: expire it again and read it. Paid means
 * already paid. Only a confirmed-expired session clears the reservation; anything else is a
 * retryable refusal.
 */
async function settleUnissued(deps: CheckoutDeps, pending: DocumentReference, sessionId: string): Promise<void> {
  try {
    await deps.client.expireCheckoutSession(sessionId);
  } catch {
    // The re-read below decides.
  }
  let remote;
  try {
    remote = await deps.client.getCheckoutSession(sessionId);
  } catch {
    throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
  }
  if (remote.payments.some(p => p.status === 'paid')) throw alreadyPaid();
  if (remote.status !== 'expired') throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
  await deps.db.runTransaction(async transaction => {
    const current = await transaction.get(pending);
    if (current.get('state') === 'unissued' && current.get('unissuedSessionId') === sessionId) transaction.delete(pending);
  });
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
