import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {claimsFromInputs, entitlementWrite, readEntitlementInputs} from './entitlementInputs.js';
import {DAY_MS, TIER_ORDER, type Grant} from './grants.js';
import {addPrepaid, webProduct, type WebProduct} from './paymongoPolicy.js';
import {endOfSitting, sittingFor, type CatalogExam} from './revenuecatPasses.js';

const EVENT_KEEP_MS = 30 * DAY_MS;
export const grantDocId = (paymentId: string) => encodeURIComponent(paymentId);

/**
 * Prepaid extension: a paid grant starts at the later of now and the latest live end
 * of this account's grants at the same or a higher tier, so buying early wastes no
 * days. A pass is per exam: it ends at its sitting and never stacks.
 */
export function planGrant(product: WebProduct, existing: Iterable<Grant>, now: number,
  catalog: CatalogExam[]): {startsAt: number; endsAt: number} | null {
  if (product.prepaid.unit === 'sitting') {
    const sitting = product.examId ? sittingFor(catalog, product.examId, now) : undefined;
    return sitting ? {startsAt: now, endsAt: endOfSitting(sitting)} : null;
  }
  let startsAt = now;
  for (const grant of existing) {
    if (grant.state !== 'active' || grant.endsAt <= now) continue;
    if (TIER_ORDER.indexOf(grant.tier) < TIER_ORDER.indexOf(product.tier)) continue;
    if (webProduct(grant.product)?.prepaid.unit === 'sitting') continue;
    startsAt = Math.max(startsAt, grant.endsAt);
  }
  return {startsAt, endsAt: addPrepaid(startsAt, product.prepaid)};
}

export type GrantOutcome = 'granted' | 'duplicate' | 'noSitting';

export async function commitPaymongoGrant(db: Firestore, input: {uid: string; eventId: string;
  sessionId: string; paymentId: string; product: WebProduct}, now: number,
  catalog: CatalogExam[]): Promise<GrantOutcome> {
  const {uid, eventId, paymentId, product} = input;
  const event = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const grantRef = db.doc(`users/${uid}/grants/${grantDocId(paymentId)}`);
  return db.runTransaction(async transaction => {
    const [dedupe, paid] = await transaction.getAll(event, payment);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const version = Number(inputs.record.get('version') ?? 0);
    const seen = {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)};
    if (dedupe.exists) return 'duplicate';
    if (paid.exists) {transaction.set(event, seen); return 'duplicate';}
    const plan = planGrant(product, inputs.grants.values(), now, catalog);
    if (!plan) {
      // Money arrived but no published sitting fixes the pass end. Keep the evidence.
      transaction.set(event, seen);
      transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoPassNoPublishedSitting',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id}});
      return 'noSitting';
    }
    const grant: Grant = {source: 'paymongo', product: product.id, tier: product.tier,
      startsAt: plan.startsAt, endsAt: plan.endsAt, paymentId, state: 'active', createdAt: now};
    const grants = new Map(inputs.grants).set(grantDocId(paymentId), grant);
    transaction.set(grantRef, grant);
    transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
    transaction.set(event, {...seen, version: version + 1});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    return 'granted';
  });
}

export type RevokeOutcome = 'revoked' | 'duplicate' | 'unmatched';

export async function revokePaymongoPayment(db: Firestore, input: {eventId: string; paymentId: string;
  reason: string}, now: number): Promise<RevokeOutcome> {
  const {eventId, paymentId} = input;
  const payment = await db.doc(`paymongoPayments/${grantDocId(paymentId)}`).get();
  const uid = payment.get('uid') as string | undefined;
  if (!payment.exists || typeof uid !== 'string') return 'unmatched';
  const event = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  const grantRef = db.doc(`users/${uid}/grants/${grantDocId(paymentId)}`);
  return db.runTransaction(async transaction => {
    const dedupe = await transaction.get(event);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const grant = inputs.grants.get(grantDocId(paymentId));
    const version = Number(inputs.record.get('version') ?? 0);
    const seen = {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)};
    if (dedupe.exists) return 'duplicate';
    if (!grant || grant.state === 'revoked') {transaction.set(event, seen); return 'duplicate';}
    const grants = new Map(inputs.grants).set(grantDocId(paymentId), {...grant, state: 'revoked'});
    transaction.update(grantRef, {state: 'revoked', revokedAt: now, revokedReason: input.reason});
    transaction.set(event, {...seen, version: version + 1});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    return 'revoked';
  });
}
