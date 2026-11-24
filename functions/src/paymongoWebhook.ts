import {FieldValue, Timestamp, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {logger} from 'firebase-functions';
import {paymentSecrets, secret} from './_secrets.js';
import {onRequest} from 'firebase-functions/v2/https';
import {copyEntitlementClaims} from './revenuecatClaims.js';
import {isUnresolvedFirebaseIdentityError, requireExactRevenueCatRawBody} from './revenuecatPolicy.js';
import {examCatalog, type CatalogExam, type Sitting} from './revenuecatPasses.js';
import {commitPaymongoGrant, resolvePaymongoDispute, revokePaymongoPayment} from './paymongoGrants.js';
import {httpPaymongoClient, type PaymongoClient} from './paymongoClient.js';
import {normalizePaymongoEvent, priceCentavos, verifyPaymongoSignature, webProduct} from './paymongoPolicy.js';
import {WEBHOOK_MAX_INSTANCES} from './_options.js';
import {serviceAccountEmail} from './serviceAccounts.js';

const MAX_EVENTS_PER_MINUTE = 30;
const PAID = 'checkout_session.payment.paid';
// Refund names appear on two documentation pages: `refund.succeeded` (events page) and
// `payment.refunded` / `payment.refund.updated` (webhook resource page). All are handled.
const REVOKING = new Set(['refund.succeeded', 'payment.refunded', 'payment.refund.updated', 'dispute.created']);

export type PaymongoWebhookDeps = {db: Firestore; auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  client: PaymongoClient; signingSecret: string; livemode: boolean; catalog?: CatalogExam[]; now?: () => number};

const text = (v: unknown): string | null => typeof v === 'string' && v.length > 0 ? v : null;
const obj = (v: unknown): Record<string, unknown> =>
  v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : {};

async function audit(db: Firestore, uid: string | null, event: string, metadata: Record<string, unknown>) {
  // The audit record below keeps the detail. The log line names the event only.
  console.error('PayMongo webhook', {reason: event.replace(/^paymongo/, '').replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()});
  await db.collection('audit_logs').add({uid, event, timestamp: FieldValue.serverTimestamp(), metadata});
}

async function unfulfilled(db: Firestore, eventId: string, sessionId: string, reason: string,
  uid?: string, paymentId?: string): Promise<number> {
  await db.doc(`paymongoFollowUps/${encodeURIComponent(paymentId ?? sessionId)}`).set({
    eventId, sessionId, reason, status: 'pending', ...(uid ? {uid} : {}), ...(paymentId ? {paymentId} : {}),
  });
  return 500;
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
    if (event.type === 'dispute.resolved') {
      const paymentId = paymentIdOf(event.data);
      const disputeId = text(event.data.id);
      if (!paymentId || !disputeId) return 500;
      if (attributes.status !== 'won' && attributes.status !== 'lost') return 500;
      const uid = await resolvePaymongoDispute(deps.db, {eventId: event.id, paymentId,
        disputeId, won: attributes.status === 'won'}, now());
      if (uid) await copyIfPending(deps, uid);
      return 200;
    }
    if (REVOKING.has(event.type)) return await handleRevoke(event, attributes, deps, now);
    if (event.type !== PAID) return 200;
    const sessionId = text(event.data.id);
    if (!sessionId || event.data.type !== 'checkout_session') return 400;
    return await fulfillPaidSession(deps, event.id, sessionId, obj(attributes.metadata), now);
  } catch (error) {
    console.error('PayMongo reconciliation failed', {reason: 'reconciliation-failed'});
    const sessionId = text(event.data.id);
    if (event.type === PAID && event.data.type === 'checkout_session' && sessionId) {
      return unfulfilled(deps.db, event.id, sessionId, 'reconciliationFailed');
    }
    return 500;
  }
}

/**
 * Completes the grant for one paid checkout session. The webhook calls it for each
 * `checkout_session.payment.paid` event, with the event's own metadata as `claimed`. A checkout call
 * calls it to finish a payment whose event never granted, with `claimed` null and a `heal_` event id.
 * Either way the session and its payment are read from PayMongo here, never taken from the caller.
 * Returns the HTTP status the webhook answers with; 200 means handled.
 */
export async function fulfillPaidSession(deps: Pick<PaymongoWebhookDeps, 'db' | 'auth' | 'client' | 'catalog'>,
  eventId: string, sessionId: string, claimed: Record<string, unknown> | null, now: () => number): Promise<number> {
  // The event body grants nothing: the session is read again from PayMongo.
  const session = await deps.client.getCheckoutSession(sessionId);
  const uid = session.metadata.uid, productId = session.metadata.product;
  if (!uid || !productId || uid.includes('/') || uid.length > 128 ||
      (claimed !== null && (claimed.uid !== uid || claimed.product !== productId))) {
    await audit(deps.db, null, 'paymongoMetadataMismatch', {eventId, sessionId});
    return unfulfilled(deps.db, eventId, sessionId, 'metadataMismatch');
  }
  const product = webProduct(productId);
  if (!product) {
    await audit(deps.db, uid, 'paymongoUnknownProduct', {eventId, sessionId, productId});
    return unfulfilled(deps.db, eventId, sessionId, 'unknownProduct', uid);
  }
  const paid = session.payments.filter(p => p.status === 'paid');
  // PayMongo may report the payment a moment after the event: retry rather than lose it.
  if (paid.length === 0) return unfulfilled(deps.db, eventId, sessionId, 'paymentNotYetPaid', uid);
  const reference = session.metadata.reference;
  const checkoutPath = reference && /^[0-9a-f-]{36}$/.test(reference)
    ? `paymongoOrders/${reference}` : `paymongoCheckouts/${sessionId}`;
  const checkout = await deps.db.doc(checkoutPath).get();
  const paidAt = paid[0].paidAt;
  const validPayment = paid.length === 1 && !!paid[0].id && paid[0].currency === 'PHP' &&
    Number.isSafeInteger(paid[0].amount) && paid[0].amount > 0;
  // A deleted account's refund task refunds what the payer actually paid, so it uses PayMongo's amount, not the quote.
  const refundIfDeleted = async () => (await commitPaymongoGrant(deps.db, {uid, eventId, sessionId,
    paymentId: paid[0].id, paidAmount: paid[0].amount, product, paidAt: paidAt ?? 0, deletionOnly: true},
  now(), deps.catalog ?? examCatalog)) === 'accountDeleted';
  if (validPayment && (await deps.db.doc(`accountDeletions/${uid}`).get()).exists && await refundIfDeleted()) return 200;
  const quotedAmount = checkout.get('amountCentavos') ?? priceCentavos(product);
  if (!validPayment || paid[0].amount !== quotedAmount) {
    await audit(deps.db, uid, 'paymongoAmountMismatch', {eventId, sessionId, productId,
      payments: paid.map(p => ({id: p.id, amount: p.amount, currency: p.currency}))});
    return unfulfilled(deps.db, eventId, sessionId, 'amountMismatch', uid, paid[0]?.id);
  }
  const bound = checkout.exists && checkout.get('uid') === uid && checkout.get('product') === productId &&
    (!checkout.get('sessionId') || checkout.get('sessionId') === sessionId);
  if (!bound || !Number.isSafeInteger(paidAt) || paidAt! <= 0 || paidAt! > now() || paidAt! < Math.floor(Number(checkout.get('createdAt')) / 1000) * 1000) {
    await deps.db.doc(`paymongoFollowUps/${encodeURIComponent(paid[0].id)}`).set({uid, sessionId,
      paymentId: paid[0].id, eventId, reason: 'unverifiedCheckoutOrPaymentTime', status: 'pending'});
    return 500;
  }
  try { await deps.auth.getUser(uid); }
  catch (error) {
    if (!isUnresolvedFirebaseIdentityError(error)) throw error;
    if (await refundIfDeleted()) return 200;
    await audit(deps.db, uid, 'paymongoPaidUnknownAccount', {eventId, sessionId, paymentId: paid[0].id});
    return unfulfilled(deps.db, eventId, sessionId, 'unknownAccount', uid, paid[0].id);
  }
  const duplicate = await deps.db.doc(`webhookEvents/${eventId}/users/${uid}`).get();
  if (!duplicate.exists) {
    if (!await withinRate(deps.db, uid, now())) {
      await unfulfilled(deps.db, eventId, sessionId, 'rateLimited', uid, paid[0].id);
      return 429;
    }
    const outcome = await commitPaymongoGrant(deps.db, {uid, eventId, sessionId,
      paymentId: paid[0].id, paidAmount: paid[0].amount, product, paidAt: paidAt!, sitting: checkout.get('sitting') as Sitting | undefined}, now(), deps.catalog ?? examCatalog);
    if (outcome === 'noSitting') return 500;
    if (outcome === 'accountDeleted') return 200;
  }
  const sessionFollowUp = deps.db.doc(`paymongoFollowUps/${encodeURIComponent(sessionId)}`);
  if ((await sessionFollowUp.get()).exists) await sessionFollowUp.update({status: 'resolved'});
  await copyIfPending(deps, uid);
  // A session made before declarations existed can still be paid. Access is granted and the
  // claims copied above, so a failed flag write never delays it. The order is flagged once for
  // manual follow-up; only a reason code is logged.
  if (!checkout.get('declaration') && typeof checkout.get('attestedAt') !== 'number' &&
      checkout.get('declarationMissing') !== true) {
    try {
      await deps.db.doc(checkoutPath).update({declarationMissing: true});
      logger.warn('Paid checkout has no declaration', {reason: 'declaration-missing'});
    } catch {
      logger.warn('Could not flag a paid checkout with no declaration', {reason: 'declaration-flag-failed'});
    }
  }
  return 200;
}

/** The payment id sits in data.id when the payment is the resource, else in payment_id. */
export function paymentIdOf(data: Record<string, unknown>): string | null {
  const attributes = obj(data.attributes);
  if (data.type === 'payment') return text(data.id);
  return text(attributes.payment_id) ?? text(obj(attributes.payment).id) ??
    (text(data.id)?.startsWith('pay_') ? text(data.id) : null);
}

type RefundEntry = {id: string; amount: number | null; status: string | null};

const validAmount = (v: unknown): v is number => typeof v === 'number' && Number.isInteger(v) && v > 0;

/**
 * Refunds named by a refund or payment resource. A refund resource is one entry; a payment
 * resource lists its refunds, flat or under `attributes`. Missing amounts are left null.
 */
function refundsIn(type: string, data: Record<string, unknown>): RefundEntry[] {
  const attributes = obj(data.attributes);
  const entry = (id: unknown, a: Record<string, unknown>, fallback: string | null): RefundEntry | null => {
    const refundId = text(id);
    return refundId ? {id: refundId, amount: validAmount(a.amount) ? a.amount : null, status: text(a.status) ?? fallback} : null;
  };
  if (data.type === 'refund' || text(data.id)?.startsWith('ref_')) {
    const one = entry(data.id, attributes, type === 'refund.succeeded' ? 'succeeded' : null);
    return one ? [one] : [];
  }
  const list = Array.isArray(attributes.refunds) ? attributes.refunds : [];
  return list.flatMap(r => {
    const flat = obj(r);
    const merged = {...obj(flat.attributes), ...Object.fromEntries(Object.entries(flat).filter(([k]) => k !== 'attributes'))};
    const one = entry(flat.id, merged, null);
    return one ? [one] : [];
  });
}

async function handleRevoke(event: {id: string; type: string; data: Record<string, unknown>},
  attributes: Record<string, unknown>, deps: PaymongoWebhookDeps, now: () => number): Promise<number> {
  void attributes;
  const paymentId = paymentIdOf(event.data);
  if (!paymentId) {
    // Fail so PayMongo retries and the log alerts; never guess which grant to revoke.
    await audit(deps.db, null, 'paymongoRevokeWithoutPayment', {eventId: event.id, type: event.type});
    return 500;
  }
  let outcome;
  if (event.type === 'dispute.created') {
    outcome = await revokePaymongoPayment(deps.db, {eventId: event.id, paymentId, reason: event.type, dispute: true, disputeId: text(event.data.id) ?? undefined}, now());
  } else {
    const entries = refundsIn(event.type, event.data);
    if (entries.length === 0) {
      await audit(deps.db, null, 'paymongoRefundAmountUnverified', {eventId: event.id, type: event.type, paymentId,
        why: 'no refund named in the event'});
      return 500;
    }
    const refunds: {id: string; amount: number}[] = [];
    for (const entry of entries) {
      if (entry.status !== null && entry.status !== 'succeeded') continue;
      if (entry.status === 'succeeded' && entry.amount !== null) {refunds.push({id: entry.id, amount: entry.amount}); continue;}
      // The event does not settle this refund: read it from PayMongo and trust only that.
      const fresh = await deps.client.getRefund(entry.id).catch(() => null);
      if (!fresh || fresh.id !== entry.id || fresh.paymentId !== paymentId || !validAmount(fresh.amount)) {
        await audit(deps.db, null, 'paymongoRefundAmountUnverified', {eventId: event.id, type: event.type, paymentId,
          refundId: entry.id, why: fresh ? 'refund read does not match the payment or amount' : 'refund read failed'});
        return 500;
      }
      if (fresh.status === 'succeeded') refunds.push({id: entry.id, amount: fresh.amount});
      else if (event.type === 'refund.succeeded') {
        await audit(deps.db, null, 'paymongoRefundAmountUnverified', {eventId: event.id, type: event.type, paymentId,
          refundId: entry.id, why: `PayMongo reports status ${fresh.status}`});
        return 500;
      }
    }
    // payment.refund.updated also fires for refunds that are not finished.
    if (refunds.length === 0) return 200;
    outcome = await revokePaymongoPayment(deps.db, {eventId: event.id, paymentId, reason: event.type, refunds}, now());
  }
  if (outcome.outcome === 'unmatched') {
    // Kept as a tombstone: the grant created by a later paid event starts revoked or shortened.
    await audit(deps.db, null, 'paymongoRevokeBeforePayment', {eventId: event.id, paymentId});
    return 200;
  }
  if (outcome.uid) await copyIfPending(deps, outcome.uid);
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

async function copyIfPending(deps: Pick<PaymongoWebhookDeps, 'db' | 'auth'>, uid: string) {
  const current = await deps.db.doc(`users/${uid}/server/entitlement`).get();
  if (current.get('claimsPending') === true || current.get('claimsVersion') !== current.get('version')) {
    await copyEntitlementClaims(deps.db, deps.auth, uid);
  }
}

export const paymongoWebhook = onRequest({region: 'asia-southeast1', serviceAccount: serviceAccountEmail('pantas-payments'), maxInstances: WEBHOOK_MAX_INSTANCES, secrets: [paymentSecrets]},
  async (req, res) => {
    if (req.method !== 'POST') {res.status(405).json({ok: false}); return;}
    const key = secret('PAYMONGO_SECRET_KEY');
    const status = await handlePaymongoWebhook(req.rawBody, req.header('paymongo-signature') ?? '', {
      db: getFirestore(), auth: getAuth(), client: httpPaymongoClient(key),
      signingSecret: secret('PAYMONGO_WEBHOOK_SECRET'), livemode: key.startsWith('sk_live_'),
    });
    res.status(status).json({ok: status === 200});
  });
