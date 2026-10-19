import {FieldValue, Timestamp, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {defineSecret} from 'firebase-functions/params';
import {onRequest} from 'firebase-functions/v2/https';
import {copyEntitlementClaims} from './revenuecatClaims.js';
import {isUnresolvedFirebaseIdentityError, requireExactRevenueCatRawBody} from './revenuecatPolicy.js';
import {examCatalog, type CatalogExam} from './revenuecatPasses.js';
import {commitPaymongoGrant, revokePaymongoPayment} from './paymongoGrants.js';
import {httpPaymongoClient, type PaymongoClient} from './paymongoClient.js';
import {normalizePaymongoEvent, priceCentavos, verifyPaymongoSignature, webProduct} from './paymongoPolicy.js';

const secretKey = defineSecret('PAYMONGO_SECRET_KEY');
const webhookSecret = defineSecret('PAYMONGO_WEBHOOK_SECRET');
const MAX_EVENTS_PER_MINUTE = 30;
const PAID = 'checkout_session.payment.paid';
const REVOKING = new Set(['refund.succeeded', 'dispute.created']);

export type PaymongoWebhookDeps = {db: Firestore; auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  client: PaymongoClient; signingSecret: string; livemode: boolean; catalog?: CatalogExam[]; now?: () => number};

const text = (v: unknown): string | null => typeof v === 'string' && v.length > 0 ? v : null;
const obj = (v: unknown): Record<string, unknown> =>
  v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : {};

async function audit(db: Firestore, uid: string | null, event: string, metadata: Record<string, unknown>) {
  console.error('PayMongo webhook', {event, uid, ...metadata});
  await db.collection('audit_logs').add({uid, event, timestamp: FieldValue.serverTimestamp(), metadata});
}

/** 401 bad signature, 400 malformed, 200 handled or ignored, 429/500 so PayMongo retries. */
export async function handlePaymongoWebhook(rawBody: unknown, signature: string,
  deps: PaymongoWebhookDeps): Promise<number> {
  const now = deps.now ?? Date.now;
  const raw = requireExactRevenueCatRawBody(rawBody);
  if (!raw || !verifyPaymongoSignature(raw, signature, deps.signingSecret, deps.livemode, now())) return 401;
  let body: unknown;
  try { body = JSON.parse(raw.toString('utf8')); } catch { return 400; }
  const event = normalizePaymongoEvent(body);
  if (!event) return 400;
  // A test event never reaches a live project, and the reverse.
  if (event.livemode !== deps.livemode) return 200;
  const attributes = obj(event.data.attributes);
  try {
    if (REVOKING.has(event.type)) return await handleRevoke(event, attributes, deps, now);
    if (event.type !== PAID) return 200;
    const sessionId = text(event.data.id);
    if (!sessionId || event.data.type !== 'checkout_session') return 400;
    // The event body grants nothing: the session is read again from PayMongo.
    const session = await deps.client.getCheckoutSession(sessionId);
    const uid = session.metadata.uid, productId = session.metadata.product;
    const claimed = obj(attributes.metadata);
    if (!uid || !productId || uid.includes('/') || uid.length > 128 ||
        claimed.uid !== uid || claimed.product !== productId) {
      await audit(deps.db, null, 'paymongoMetadataMismatch', {eventId: event.id, sessionId});
      return 200;
    }
    const product = webProduct(productId);
    if (!product) {
      await audit(deps.db, uid, 'paymongoUnknownProduct', {eventId: event.id, sessionId, productId});
      return 200;
    }
    const paid = session.payments.filter(p => p.status === 'paid');
    // PayMongo may report the payment a moment after the event: retry rather than lose it.
    if (paid.length === 0) return 500;
    if (paid.length !== 1 || !paid[0].id || paid[0].currency !== 'PHP' || paid[0].amount !== priceCentavos(product)) {
      await audit(deps.db, uid, 'paymongoAmountMismatch', {eventId: event.id, sessionId, productId,
        payments: paid.map(p => ({id: p.id, amount: p.amount, currency: p.currency}))});
      return 200;
    }
    try { await deps.auth.getUser(uid); }
    catch (error) {
      if (!isUnresolvedFirebaseIdentityError(error)) throw error;
      await audit(deps.db, uid, 'paymongoPaidUnknownAccount', {eventId: event.id, sessionId, paymentId: paid[0].id});
      return 200;
    }
    const duplicate = await deps.db.doc(`webhookEvents/${event.id}/users/${uid}`).get();
    if (!duplicate.exists) {
      if (!await withinRate(deps.db, uid, now())) return 429;
      const outcome = await commitPaymongoGrant(deps.db, {uid, eventId: event.id, sessionId,
        paymentId: paid[0].id, product}, now(), deps.catalog ?? examCatalog);
      if (outcome === 'noSitting') console.error('PayMongo pass paid without a published sitting', {uid, sessionId});
    }
    await copyIfPending(deps, uid);
    return 200;
  } catch (error) {
    console.error('PayMongo reconciliation failed', {eventId: event.id, error});
    return 500;
  }
}

async function handleRevoke(event: {id: string; type: string; data: Record<string, unknown>},
  attributes: Record<string, unknown>, deps: PaymongoWebhookDeps, now: () => number): Promise<number> {
  // The resource names its payment in payment_id (UNCONFIRMED in PayMongo's sample payloads).
  const paymentId = text(attributes.payment_id) ?? text(obj(attributes.payment).id);
  if (!paymentId) {
    await audit(deps.db, null, 'paymongoRevokeWithoutPayment', {eventId: event.id, type: event.type});
    return 200;
  }
  const outcome = await revokePaymongoPayment(deps.db, {eventId: event.id, paymentId, reason: event.type}, now());
  if (outcome === 'unmatched') {
    await audit(deps.db, null, 'paymongoRevokeUnmatched', {eventId: event.id, paymentId});
    return 200;
  }
  const uid = (await deps.db.doc(`paymongoPayments/${encodeURIComponent(paymentId)}`).get()).get('uid') as string;
  await copyIfPending(deps, uid);
  return 200;
}

async function withinRate(db: Firestore, uid: string, at: number): Promise<boolean> {
  const rate = db.doc(`webhookRateLimits/${uid}_${Math.floor(at / 60_000)}`);
  return db.runTransaction(async transaction => {
    const count = Number((await transaction.get(rate)).get('count') ?? 0);
    if (count >= MAX_EVENTS_PER_MINUTE) return false;
    transaction.set(rate, {uid, count: count + 1, expireAt: Timestamp.fromMillis(at + 3_600_000)});
    return true;
  });
}

async function copyIfPending(deps: PaymongoWebhookDeps, uid: string) {
  const current = await deps.db.doc(`users/${uid}/server/entitlement`).get();
  if (current.get('claimsPending') === true || current.get('claimsVersion') !== current.get('version')) {
    await copyEntitlementClaims(deps.db, deps.auth, uid);
  }
}

export const paymongoWebhook = onRequest({region: 'asia-southeast1', secrets: [secretKey, webhookSecret]},
  async (req, res) => {
    if (req.method !== 'POST') {res.status(405).json({ok: false}); return;}
    const key = secretKey.value();
    const status = await handlePaymongoWebhook(req.rawBody, req.header('paymongo-signature') ?? '', {
      db: getFirestore(), auth: getAuth(), client: httpPaymongoClient(key),
      signingSecret: webhookSecret.value(), livemode: key.startsWith('sk_live_'),
    });
    res.status(status).json({ok: status === 200});
  });
