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

const stackable = (g: Grant): boolean => g.source === 'trial' ||
  (webProduct(g.product) !== undefined && webProduct(g.product)!.prepaid.unit !== 'sitting');

/**
 * After a grant is revoked, later grants of the same account and tier that were stacked
 * behind it and have not started move earlier, in order, so the student is not covered
 * "now" through a gap that was paid for the revoked period. Each keeps its length.
 * Grants that already started, passes and other tiers never move.
 */
export function replanAfterRevoke(grants: ReadonlyMap<string, Grant>, revokedId: string,
  now: number): Map<string, Grant> {
  const out = new Map(grants);
  const revoked = out.get(revokedId);
  if (!revoked || !stackable(revoked)) return out;
  const movers = [...out].filter(([id, g]) => id !== revokedId && g.state === 'active' &&
    g.tier === revoked.tier && stackable(g) && g.startsAt > now && g.startsAt >= revoked.endsAt)
    .sort((a, b) => a[1].startsAt - b[1].startsAt);
  const moving = new Set(movers.map(([id]) => id));
  let cursor = now;
  for (const [id, g] of out) {
    if (moving.has(id) || id === revokedId || g.state !== 'active' || !stackable(g) ||
        g.startsAt > now || TIER_ORDER.indexOf(g.tier) < TIER_ORDER.indexOf(revoked.tier)) continue;
    cursor = Math.max(cursor, g.endsAt);
  }
  for (const [id, g] of movers) {
    const prepaid = webProduct(g.product)?.prepaid;
    const endsAt = prepaid && prepaid.unit !== 'sitting' ? addPrepaid(cursor, prepaid) : cursor + (g.endsAt - g.startsAt);
    out.set(id, {...g, startsAt: cursor, endsAt});
    cursor = endsAt;
  }
  return out;
}

export type GrantOutcome = 'granted' | 'duplicate' | 'noSitting' | 'bornRevoked';

export async function commitPaymongoGrant(db: Firestore, input: {uid: string; eventId: string;
  sessionId: string; paymentId: string; product: WebProduct}, now: number,
  catalog: CatalogExam[]): Promise<GrantOutcome> {
  const {uid, eventId, paymentId, product} = input;
  const event = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const tombstone = db.doc(`paymongoRevocations/${grantDocId(paymentId)}`);
  const grantRef = db.doc(`users/${uid}/grants/${grantDocId(paymentId)}`);
  return db.runTransaction(async transaction => {
    const [dedupe, paid, revokedEarly] = await transaction.getAll(event, payment, tombstone);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const version = Number(inputs.record.get('version') ?? 0);
    const seen = {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)};
    if (dedupe.exists) return 'duplicate';
    if (paid.exists) {transaction.set(event, seen); return 'duplicate';}
    const plan = planGrant(product, inputs.grants.values(), now, catalog);
    if (revokedEarly.exists) {
      // The refund or dispute arrived first: record the payment, but never grant access.
      const grant: Grant = {source: 'paymongo', product: product.id, tier: product.tier,
        startsAt: plan?.startsAt ?? now, endsAt: plan?.endsAt ?? now, paymentId, state: 'revoked', createdAt: now};
      transaction.set(grantRef, {...grant, revokedAt: now, revokedReason: revokedEarly.get('reason') ?? 'revoked'});
      transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
      transaction.set(event, seen);
      transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoGrantBornRevoked',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id}});
      return 'bornRevoked';
    }
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

/** Revokes the grant for a payment. If the payment is not known yet, keeps a tombstone. */
export async function revokePaymongoPayment(db: Firestore, input: {eventId: string; paymentId: string;
  reason: string}, now: number): Promise<{outcome: RevokeOutcome; uid?: string}> {
  const {eventId, paymentId} = input;
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const tombstone = db.doc(`paymongoRevocations/${grantDocId(paymentId)}`);
  return db.runTransaction(async transaction => {
    // The payment index and the tombstone are read and written in one transaction, so a
    // refund and a paid event for the same payment cannot both miss each other.
    const paid = await transaction.get(payment);
    const uid = paid.get('uid') as string | undefined;
    if (!paid.exists || typeof uid !== 'string') {
      const existing = await transaction.get(tombstone);
      if (!existing.exists) transaction.set(tombstone, {reason: input.reason, eventId, createdAt: now});
      return {outcome: 'unmatched' as const};
    }
    const event = db.doc(`webhookEvents/${eventId}/users/${uid}`);
    const dedupe = await transaction.get(event);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const id = grantDocId(paymentId);
    const grant = inputs.grants.get(id);
    const version = Number(inputs.record.get('version') ?? 0);
    const seen = {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)};
    if (dedupe.exists) return {outcome: 'duplicate' as const, uid};
    if (!grant || grant.state === 'revoked') {transaction.set(event, seen); return {outcome: 'duplicate' as const, uid};}
    const revoked = new Map(inputs.grants).set(id, {...grant, state: 'revoked'});
    const replanned = replanAfterRevoke(revoked, id, now);
    transaction.update(db.doc(`users/${uid}/grants/${id}`), {state: 'revoked', revokedAt: now, revokedReason: input.reason});
    for (const [otherId, other] of replanned) {
      const before = inputs.grants.get(otherId);
      if (otherId !== id && before && (before.startsAt !== other.startsAt || before.endsAt !== other.endsAt)) {
        transaction.update(db.doc(`users/${uid}/grants/${otherId}`), {startsAt: other.startsAt, endsAt: other.endsAt});
      }
    }
    transaction.set(event, {...seen, version: version + 1});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, replanned)), {merge: true});
    return {outcome: 'revoked' as const, uid};
  });
}
