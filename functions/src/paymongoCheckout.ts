import {randomUUID, createHash} from 'node:crypto';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {defineSecret} from 'firebase-functions/params';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import type {Grant} from './grants.js';
import {httpPaymongoClient, type PaymongoClient} from './paymongoClient.js';
import {priceCentavos, webProduct} from './paymongoPolicy.js';
import {examCatalog, sittingFor, type CatalogExam, type Sitting} from './revenuecatPasses.js';

const secretKey = defineSecret('PAYMONGO_SECRET_KEY');
const CHECKOUTS_PER_WINDOW = 10;
const WINDOW_MS = 10 * 60_000;
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

export async function createCheckout(auth: Parameters<typeof assertNamedUser>[0], data: unknown,
  deps: CheckoutDeps): Promise<{checkoutUrl: string; sessionId: string; reference: string}> {
  const uid = assertNamedUser(auth);
  const requested = (data as {product?: unknown} | null)?.product;
  const product = typeof requested === 'string' ? webProduct(requested) : undefined;
  if (!product) throw new HttpsError('invalid-argument', 'This product is not sold on the web.');
  const now = (deps.now ?? Date.now)();
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
  const binding = {uid, product: product.id, createdAt: now, ...(sitting ? {examId: product.examId, sitting} : {})};
  const reserved = await deps.db.runTransaction(async transaction => {
    const previous = await transaction.get(pending);
    if (previous.exists) return previous.data()!;
    transaction.create(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
    transaction.create(order, binding);
    return null;
  });
  if (reserved) {
    if (reserved.state !== 'open') throw new HttpsError('aborted', 'Checkout creation is pending. Try again later.');
    const remote = await deps.client.getCheckoutSession(reserved.sessionId as string);
    if (remote.status === 'active' && !remote.payments.some(p => p.status === 'paid')) {
      return {checkoutUrl: reserved.checkoutUrl as string, sessionId: reserved.sessionId as string, reference: reserved.reference as string};
    }
    if (remote.status !== 'expired' && !remote.payments.some(p => p.status === 'paid')) {
      throw new HttpsError('unavailable', 'Checkout status is unavailable. Try again later.');
    }
    // Compare-and-swap: only one request can replace a completed/expired checkout.
    await deps.db.runTransaction(async transaction => {
      const current = await transaction.get(pending);
      if (current.get('reference') !== reserved.reference) throw new HttpsError('aborted', 'Checkout changed. Try again.');
      transaction.set(pending, {state: 'creating', reference: referenceNumber, product: product.id, createdAt: now});
      transaction.create(order, binding);
    });
  }
  const session = await deps.client.createCheckoutSession({uid, product: product.id,
    name: NAMES[product.id] ?? product.id, amountCentavos: priceCentavos(product),
    successUrl: `${deps.origin}/pro?checkout=success&ref=${referenceNumber}`, cancelUrl: `${deps.origin}/pro?checkout=cancelled&ref=${referenceNumber}`,
    paymentMethodTypes: deps.methods, referenceNumber});
  const result = {checkoutUrl: session.checkoutUrl, sessionId: session.id, reference: referenceNumber};
  const batch = deps.db.batch();
  batch.set(deps.db.doc(`paymongoCheckouts/${session.id}`), {uid, product: product.id, createdAt: now,
    ...(sitting ? {examId: product.examId, sitting} : {})});
  batch.update(order, {sessionId: session.id});
  batch.set(pending, {...result, state: 'open', product: product.id, createdAt: now});
  await batch.commit();
  return result;
}

export const createPaymongoCheckout = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck, secrets: [secretKey]},
  request => {
    assertFreshAppCheck(request);
    return createCheckout(request.auth, request.data, {
      client: httpPaymongoClient(secretKey.value()), db: getFirestore(),
      origin: process.env.PANTAS_APP_ORIGIN ?? 'https://app.pantas.study',
      methods: process.env.PAYMONGO_PAYMENT_METHODS?.split(',').map(m => m.trim()).filter(Boolean) ?? DEFAULT_METHODS,
    });
  });
