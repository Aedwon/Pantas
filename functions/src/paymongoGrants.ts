import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {claimsFromInputs, nativeCoverageRows, entitlementWrite, readEntitlementInputs} from './entitlementInputs.js';
import {DAY_MS, TIER_ORDER, shortenedEnd, type Grant} from './grants.js';
import {addPrepaid, webProduct, type WebProduct} from './paymongoPolicy.js';
import {endOfSitting, sittingFor, type CatalogExam, type Sitting} from './revenuecatPasses.js';

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
    startsAt = Math.max(startsAt, grant.endsAt);
  }
  return {startsAt, endsAt: addPrepaid(startsAt, product.prepaid)};
}

const stackable = (g: Grant): boolean => g.source === 'trial' ||
  (webProduct(g.product) !== undefined && webProduct(g.product)!.prepaid.unit !== 'sitting');

const fullEndOf = (g: Grant) => g.fullEndsAt ?? g.endsAt;
const refundedTotal = (g: Grant) => Object.values(g.refunds ?? {}).reduce((a, b) => a + b, 0);

export {shortenedEnd} from './grants.js';

/**
 * Adds one refund to a grant. The same refund id twice is a no-op (returns the same
 * object). Refunds reaching the amount paid revoke it. A grant that already ended only
 * records the refund.
 */
export function applyRefund(grant: Grant, refundId: string, amount: number, now: number): Grant {
  if (grant.refunds && refundId in grant.refunds) return grant;
  const paid = grant.paidAmount ?? (webProduct(grant.product)?.webPricePhp ?? 0) * 100;
  const refunds = {...grant.refunds, [refundId]: amount};
  const total = Object.values(refunds).reduce((a, b) => a + b, 0);
  if (paid <= 0 || total >= paid) return {...grant, refunds, state: 'revoked'};
  if (grant.endsAt <= now) return {...grant, refunds};
  return {...grant, refunds, fullEndsAt: fullEndOf(grant),
    endsAt: shortenedEnd(grant.startsAt, fullEndOf(grant), total, paid)};
}

/**
 * After a grant is revoked or shortened, later grants of the same account and tier that
 * were stacked behind its old end and have not started move earlier, in order, so the
 * student is not covered "now" through a gap. Each keeps its length (and its own
 * refunded share). Grants that already started, passes and other tiers never move.
 */
function replanBehind(grants: ReadonlyMap<string, Grant>, changedId: string, threshold: number,
  now: number, nativeEnd = now): Map<string, Grant> {
  const out = new Map(grants);
  const changed = out.get(changedId);
  if (!changed || !stackable(changed)) return out;
  const movers = [...out].filter(([id, g]) => id !== changedId && g.state === 'active' &&
    g.tier === changed.tier && stackable(g) && g.startsAt > now && g.startsAt >= threshold)
    .sort((a, b) => a[1].startsAt - b[1].startsAt);
  const moving = new Set(movers.map(([id]) => id));
  let cursor = Math.max(now, nativeEnd);
  for (const [id, g] of out) {
    if (moving.has(id) || g.state !== 'active' ||
        (id !== changedId && g.startsAt > now) ||
        TIER_ORDER.indexOf(g.tier) < TIER_ORDER.indexOf(changed.tier)) continue;
    cursor = Math.max(cursor, g.endsAt);
  }
  for (const [id, g] of movers) {
    const prepaid = webProduct(g.product)?.prepaid;
    const fullEnd = prepaid && prepaid.unit !== 'sitting' ? addPrepaid(cursor, prepaid)
      : cursor + (fullEndOf(g) - g.startsAt);
    const paid = g.paidAmount ?? (webProduct(g.product)?.webPricePhp ?? 0) * 100;
    const endsAt = shortenedEnd(cursor, fullEnd, refundedTotal(g), paid);
    out.set(id, {...g, startsAt: cursor, endsAt, ...(g.fullEndsAt !== undefined || g.refunds ? {fullEndsAt: fullEnd} : {})});
    cursor = endsAt;
  }
  return out;
}

export const replanAfterRevoke = (grants: ReadonlyMap<string, Grant>, revokedId: string, now: number) =>
  replanBehind(grants, revokedId, grants.get(revokedId)?.endsAt ?? Infinity, now);

export type GrantOutcome = 'granted' | 'duplicate' | 'noSitting' | 'bornRevoked' | 'unusedDuplicate';

export async function commitPaymongoGrant(db: Firestore, input: {uid: string; eventId: string;
  sessionId: string; paymentId: string; paidAmount: number; product: WebProduct; paidAt: number; sitting?: Sitting}, now: number,
  catalog: CatalogExam[]): Promise<GrantOutcome> {
  const {uid, eventId, paymentId, product} = input;
  const grantEventRef = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const tombstone = db.doc(`paymongoRevocations/${grantDocId(paymentId)}`);
  const grantRef = db.doc(`users/${uid}/grants/${grantDocId(paymentId)}`);
  return db.runTransaction(async transaction => {
    const [dedupe, paid, revokedEarly] = await transaction.getAll(grantEventRef, payment, tombstone);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const version = Number(inputs.record.get('version') ?? 0);
    if (dedupe.exists) return 'duplicate';
    if (paid.exists) {transaction.set(grantEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)}); return 'duplicate';}
    const plan = product.prepaid.unit === 'sitting'
      ? (input.sitting ? {startsAt: input.paidAt, endsAt: endOfSitting(input.sitting)} : null)
      : planGrant(product, [...inputs.grants.values(), ...nativeCoverageRows(inputs, input.paidAt)], input.paidAt, catalog);
    const binding = {paidAt: input.paidAt, ...(input.sitting ? {sitting: input.sitting, examId: product.examId!} : {})};
    const followUp = db.doc(`paymongoFollowUps/${grantDocId(paymentId)}`);
    const priorFollowUp = await transaction.get(followUp);
    const duplicatePass = product.kind === 'pass' && input.sitting ?
      [...inputs.grants, ...nativeCoverageRows(inputs, input.paidAt).map((g, i): [string, Grant] => [`native_${i}`, g])].find(([, g]) => g.product === product.id && g.state === 'active' &&
        (g.sitting?.firstDay === input.sitting!.firstDay ||
          (plan !== null && g.startsAt <= input.paidAt && g.endsAt >= plan.endsAt))) : undefined;
    // A refund or dispute that arrived first is carried in the tombstone: the grant is born
    // revoked (dispute or refunds covering the payment) or already shortened.
    const early = revokedEarly.exists ? revokedEarly.data() as {refunds?: Record<string, number>;
      disputed?: boolean; reason?: string; disputeId?: string} : undefined;
    const earlyRefunds = Object.values(early?.refunds ?? {}).reduce((a, b) => a + b, 0);
    if (early && (early.disputed || earlyRefunds >= input.paidAmount)) {
      const grant: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
        startsAt: plan?.startsAt ?? now, endsAt: plan?.endsAt ?? now, paymentId, paidAmount: input.paidAmount,
        refunds: early.refunds ?? {}, state: 'revoked', createdAt: now};
      transaction.set(grantRef, {...grant, revokedAt: now, revokedReason: early.reason ?? 'revoked',
        ...(early.disputeId ? {disputeId: early.disputeId} : {})});
      transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
      transaction.set(grantEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
      transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoGrantBornRevoked',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id}});
      return 'bornRevoked';
    }
    if (!plan) {
      // Money arrived but no published sitting fixes the pass end. Keep the evidence.
      transaction.set(followUp, {uid, eventId, sessionId: input.sessionId, paymentId, product: product.id, paidAt: input.paidAt, reason: 'missingCheckoutSitting', status: 'pending'});
      transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoPassNoPublishedSitting',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id}});
      return 'noSitting';
    }
    if (duplicatePass) {
      const unused: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
        startsAt: input.paidAt, endsAt: input.paidAt, paymentId, paidAmount: input.paidAmount,
        state: 'revoked', createdAt: now, unusedDuplicateOf: duplicatePass[0]};
      transaction.set(grantRef, unused);
      transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
      transaction.set(followUp, {uid, paymentId, product: product.id, sessionId: input.sessionId,
        reason: 'unusedDuplicatePass', status: 'pending', refundRequired: true, activeGrantId: duplicatePass[0]});
      transaction.set(grantEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
      return 'unusedDuplicate';
    }
    if (priorFollowUp.exists) transaction.update(followUp, {status: 'resolved'});
    const grant: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
      startsAt: plan.startsAt, endsAt: plan.endsAt, paymentId, paidAmount: input.paidAmount,
      refunds: {}, fullEndsAt: plan.endsAt, state: 'active', createdAt: now};
    if (early && earlyRefunds > 0) {
      grant.refunds = early.refunds ?? {};
      grant.endsAt = shortenedEnd(plan.startsAt, plan.endsAt, earlyRefunds, input.paidAmount);
      transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoGrantBornShortened',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id, refunded: earlyRefunds}});
    }
    const grants = new Map(inputs.grants).set(grantDocId(paymentId), grant);
    transaction.set(grantRef, grant);
    transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
    transaction.set(grantEventRef, {eventId, version: version + 1, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    return 'granted';
  });
}

export type RevokeOutcome = 'revoked' | 'duplicate' | 'unmatched';

/**
 * Applies a dispute (whole grant revoked) or refunds (shortened in proportion, revoked
 * once refunds cover the payment). If the payment is not known yet, a tombstone keeps the
 * dispute flag and the cumulative refunds for the grant created later.
 */
export async function revokePaymongoPayment(db: Firestore, input: {eventId: string; paymentId: string;
  reason: string; dispute?: boolean; disputeId?: string; refunds?: {id: string; amount: number}[]}, now: number):
  Promise<{outcome: RevokeOutcome; uid?: string}> {
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
      const refunds = {...(existing.get('refunds') as Record<string, number> | undefined)};
      for (const r of input.refunds ?? []) if (!(r.id in refunds)) refunds[r.id] = r.amount;
      transaction.set(tombstone, {reason: existing.get('reason') ?? input.reason, eventId: existing.get('eventId') ?? eventId,
        createdAt: existing.get('createdAt') ?? now, refunds,
        ...(input.disputeId ? {disputeId: input.disputeId} : {}), disputed: existing.get('disputed') === true || input.dispute === true});
      return {outcome: 'unmatched' as const};
    }
    const revokeEventRef = db.doc(`webhookEvents/${eventId}/users/${uid}`);
    const dedupe = await transaction.get(revokeEventRef);
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const id = grantDocId(paymentId);
    const grant = inputs.grants.get(id);
    const version = Number(inputs.record.get('version') ?? 0);
    if (dedupe.exists) return {outcome: 'duplicate' as const, uid};
    if (!grant || (grant.state !== 'active' && input.dispute)) {transaction.set(revokeEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)}); return {outcome: 'duplicate' as const, uid};}
    let next: Grant = input.dispute ? {...grant, state: 'revoked'} : grant;
    for (const r of input.refunds ?? []) next = applyRefund(next, r.id, r.amount, now);
    if (next === grant) {transaction.set(revokeEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)}); return {outcome: 'duplicate' as const, uid};}
    const changed = new Map(inputs.grants).set(id, next);
    const replanned = next.state === 'revoked' || next.endsAt !== grant.endsAt
      ? replanBehind(changed, id, grant.endsAt, now, Math.max(now, ...nativeCoverageRows(inputs, now).filter(g => TIER_ORDER.indexOf(g.tier) >= TIER_ORDER.indexOf(grant.tier)).map(g => g.endsAt))) : changed;
    const ref = (gid: string) => db.doc(`users/${uid}/grants/${gid}`);
    transaction.update(ref(id), {state: next.state, endsAt: next.endsAt, refunds: next.refunds ?? {},
      ...(next.fullEndsAt !== undefined ? {fullEndsAt: next.fullEndsAt} : {}),
      ...(input.dispute && input.disputeId ? {disputeId: input.disputeId, disputeResolved: false} : {}),
      ...(next.state === 'revoked' ? {revokedAt: now, revokedReason: grant.revokedReason ?? input.reason} : {})});
    for (const [otherId, other] of replanned) {
      const before = inputs.grants.get(otherId);
      if (otherId !== id && before && (before.startsAt !== other.startsAt || before.endsAt !== other.endsAt)) {
        transaction.update(ref(otherId), {startsAt: other.startsAt, endsAt: other.endsAt,
          ...(other.fullEndsAt !== undefined ? {fullEndsAt: other.fullEndsAt} : {})});
      }
    }
    transaction.set(revokeEventRef, {eventId, version: version + 1, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, replanned)), {merge: true});
    return {outcome: 'revoked' as const, uid};
  });
}

/** A win restores only this dispute's revocation, without buying any extra time. */
export async function resolvePaymongoDispute(db: Firestore, input: {eventId: string;
  paymentId: string; disputeId: string; won: boolean}, now: number): Promise<string | undefined> {
  return db.runTransaction(async transaction => {
    const paid = await transaction.get(db.doc(`paymongoPayments/${grantDocId(input.paymentId)}`));
    const uid = paid.get('uid') as string | undefined;
    if (!uid) return undefined;
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const id = grantDocId(input.paymentId);
    const grant = inputs.grants.get(id);
    if (!grant || grant.state !== 'revoked' || grant.revokedReason !== 'dispute.created' ||
        grant.disputeId !== input.disputeId || grant.disputeResolved) return uid;
    const restore = input.won && refundedTotal(grant) === 0 && !grant.unusedDuplicateOf;
    const next: Grant = {...grant, disputeResolved: true, ...(restore ? {state: 'active'} : {})};
    transaction.update(db.doc(`users/${uid}/grants/${id}`), {disputeResolved: true,
      ...(restore ? {state: 'active', revokedReason: FieldValue.delete(), revokedAt: FieldValue.delete()} : {})});
    if (restore) {
      const grants = new Map(inputs.grants).set(id, next);
      transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    }
    return uid;
  });
}
