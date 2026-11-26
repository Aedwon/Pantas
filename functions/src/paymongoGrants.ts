import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {claimsFromInputs, nativeCoverageRows, entitlementWrite, readEntitlementInputs} from './entitlementInputs.js';
import {DAY_MS, TIER_ORDER, rewardStart, shortenedEnd, type Grant} from './grants.js';
import {addPrepaid, webProduct, type WebProduct} from './paymongoPolicy.js';
import {endOfSitting, sittingFor, type CatalogExam, type Sitting} from './revenuecatPasses.js';

const EVENT_KEEP_MS = 30 * DAY_MS;
export const grantDocId = (paymentId: string) => encodeURIComponent(paymentId);

const tierWide = (g: Grant) => !g.examId && g.source !== 'beta' && g.source !== 'beta_reward' &&
  webProduct(g.product)?.kind !== 'pass';

const anchorsPlan = (g: Grant, tier: Grant['tier'], now: number) =>
  g.state === 'active' && g.endsAt > now && tierWide(g) &&
  TIER_ORDER.indexOf(g.tier) >= TIER_ORDER.indexOf(tier);

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
    if (!anchorsPlan(grant, product.tier, now)) continue;
    startsAt = Math.max(startsAt, grant.endsAt);
  }
  return {startsAt, endsAt: addPrepaid(startsAt, product.prepaid)};
}

const stackable = (g: Grant): boolean => g.source === 'trial' ||
  (webProduct(g.product) !== undefined && webProduct(g.product)!.prepaid.unit !== 'sitting');

const fullEndOf = (g: Grant) => g.fullEndsAt ?? g.endsAt;
const refundedTotal = (g: Grant) => Object.values(g.refunds ?? {}).reduce((a, b) => a + b, 0);

export {shortenedEnd} from './grants.js';

const paidOf = (g: Grant) => g.paidAmount ?? (webProduct(g.product)?.webPricePhp ?? 0) * 100;
const followUpId = (paymentId: string) => `paymongoFollowUps/${grantDocId(paymentId)}__dispute`;
/** One follow-up per lost dispute, so a second dispute on the same payment never hides the first. */
const lostFollowUpId = (paymentId: string, disputeId: string) =>
  `paymongoFollowUps/${grantDocId(paymentId)}__lost_${encodeURIComponent(disputeId)}`;
/**
 * Every lost dispute goes to the owner (lead ruling, Nov 25, 2026), whatever the amounts and the order the
 * events came in. It carries only facts that cannot go stale: the dispute, and its amount when an event named
 * it. The owner reads the payment's refunds and chargeback in the PayMongo dashboard and closes it.
 */
const lostFollowUp = (paymentId: string, disputeId: string, disputedAmount: number | undefined, now: number) => ({
  paymentId, disputeId, status: 'pending', refundRequired: false, reason: 'disputeLost',
  disputedAmount: disputedAmount ?? null, createdAt: now});

/**
 * Milliseconds the grant ran in its current active spell, up to `until`. A refund that shortened the end into
 * the past (`accessCutAt`) cut access when it arrived, not at the shortened end, so the time before it counts.
 */
const spellCover = (g: Grant, until: number) =>
  Math.max(0, Math.min(until, Math.max(g.endsAt, g.accessCutAt ?? 0), fullEndOf(g)) - Math.max(g.startsAt, g.activeFrom ?? 0));

/**
 * Whole days of the paid length that the grant did not cover: its full term minus the time it was
 * active, summed over its active spells. A grant born revoked covered nothing. A revoked grant
 * without a recorded cover (older rows) is counted up to its revocation.
 */
export function unusedDaysOf(g: Grant, now: number): number {
  const covered = g.state === 'revoked' && g.coveredMs !== undefined ? g.coveredMs
    : (g.coveredMs ?? 0) + spellCover(g, g.state === 'revoked' ? g.revokedAt ?? now : now);
  return Math.max(0, Math.floor((fullEndOf(g) - g.startsAt - covered) / DAY_MS));
}

/** Ids of the grants and rewards a dispute moved earlier. */
const pulledBy = (grants: ReadonlyMap<string, Grant>, disputeId: string) =>
  [...grants].filter(([, g]) => g.disputeMoves?.[disputeId] !== undefined).map(([id]) => id).sort();

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
    g.tier === changed.tier && tierWide(g) && stackable(g) && g.startsAt > now && g.startsAt >= threshold)
    .sort((a, b) => a[1].startsAt - b[1].startsAt);
  const moving = new Set(movers.map(([id]) => id));
  let cursor = Math.max(now, nativeEnd);
  for (const [id, g] of out) {
    if (moving.has(id) || !anchorsPlan(g, changed.tier, now)) continue;
    cursor = Math.max(cursor, g.endsAt);
  }
  for (const [id, g] of movers) {
    const moved = startAt(g, cursor);
    out.set(id, moved);
    cursor = moved.endsAt;
  }
  return out;
}

/** The same paid length (and refunded share) starting at a new time. */
function startAt(g: Grant, start: number): Grant {
  const prepaid = webProduct(g.product)?.prepaid;
  const fullEnd = prepaid && prepaid.unit !== 'sitting' ? addPrepaid(start, prepaid)
    : start + (fullEndOf(g) - g.startsAt);
  const paid = g.paidAmount ?? (webProduct(g.product)?.webPricePhp ?? 0) * 100;
  const endsAt = shortenedEnd(start, fullEnd, refundedTotal(g), paid);
  return {...g, startsAt: start, endsAt, ...(g.fullEndsAt !== undefined || g.refunds ? {fullEndsAt: fullEnd} : {})};
}

/**
 * Beta rewards queue per exam behind the paid coverage that covers that exam. When that coverage
 * shrinks, each queued reward moves earlier to the end of what still covers its exam, keeping its
 * length. With `only` it recomputes just those rewards, later or earlier, for a restored dispute win.
 */
function rechainRewards(grants: ReadonlyMap<string, Grant>, native: readonly Grant[], now: number,
  only?: ReadonlySet<string>): Map<string, Grant> {
  const out = new Map(grants);
  const cover = [...out.values()].filter(g => g.source !== 'beta' && g.source !== 'beta_reward').concat(native);
  for (const [id, g] of out) {
    if (g.source !== 'beta_reward' || g.state !== 'active' || !g.examId || (only ? !only.has(id) : g.startsAt <= now)) continue;
    const start = rewardStart(g.tier, g.examId, cover, now);
    if (only ? start === g.startsAt : start >= g.startsAt) continue;
    out.set(id, {...g, startsAt: start, endsAt: start + (g.endsAt - g.startsAt)});
  }
  return out;
}

/**
 * After native (store or promotional) coverage changes, web grants that were queued behind
 * coverage that no longer exists start earlier, in order: no later than the end of whatever
 * coverage is still live, and never later than before. Each keeps its paid length.
 */
export function reanchorQueued(grants: ReadonlyMap<string, Grant>, native: readonly Grant[],
  now: number): Map<string, Grant> {
  const out = new Map(grants);
  const movers = [...out].filter(([, g]) => g.state === 'active' && tierWide(g) && stackable(g) &&
    g.startsAt > now && g.endsAt > g.startsAt).sort((a, b) => a[1].startsAt - b[1].startsAt);
  const waiting = new Set(movers.map(([id]) => id));
  for (const [id, g] of movers) {
    let cursor = now;
    for (const row of native) if (anchorsPlan(row, g.tier, now)) cursor = Math.max(cursor, row.endsAt);
    for (const [otherId, other] of out) {
      if (otherId === id || waiting.has(otherId) || !anchorsPlan(other, g.tier, now)) continue;
      cursor = Math.max(cursor, other.endsAt);
    }
    if (cursor < g.startsAt) out.set(id, startAt(g, cursor));
    waiting.delete(id);
  }
  // A queued reward follows the same shrinking coverage, per exam.
  return rechainRewards(out, native, now);
}

/**
 * One-time repair for an account. Only move plans whose historical anchor moved or was exam-only.
 * An exam-only anchor that is live at the plan's start counts even when its end is later than the
 * plan's start: a postponed pass moved its end after the plan was queued at the old end. A plan
 * still moves only to the end of the tier-wide coverage that really precedes it. With `dryRun` it
 * counts and writes nothing.
 */
export function repairExamOnlyQueuedPlans(db: Firestore, uid: string, now = Date.now(),
  options: {dryRun?: boolean} = {}): Promise<number> {
  return db.runTransaction(async transaction => {
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const native = nativeCoverageRows(inputs, now);
    const original = [...native, ...inputs.grants.values()];
    const grants = new Map(inputs.grants);
    const affected = new Set<Grant>();
    const queued = [...inputs.grants].sort(([, a], [, b]) => a.startsAt - b.startsAt);
    for (const [id, grant] of queued) {
      if (grant.startsAt <= now || !anchorsPlan(grant, grant.tier, now) || !stackable(grant) ||
          !original.some(anchor => anchor.state === 'active' &&
          TIER_ORDER.indexOf(anchor.tier) >= TIER_ORDER.indexOf(grant.tier) &&
          ((anchor.endsAt === grant.startsAt && (affected.has(anchor) || !tierWide(anchor))) ||
            (!tierWide(anchor) && anchor.startsAt <= grant.startsAt && anchor.endsAt > grant.startsAt)))) continue;
      const prior = [...native, ...grants.values()].filter(row =>
        row.startsAt < grant.startsAt && anchorsPlan(row, grant.tier, now));
      const startsAt = Math.max(now, ...prior.map(row => row.endsAt));
      if (startsAt >= grant.startsAt) continue;
      const shift = startsAt - grant.startsAt;
      const moved = {...grant, startsAt, endsAt: grant.endsAt + shift,
        ...(grant.fullEndsAt === undefined ? {} : {fullEndsAt: grant.fullEndsAt + shift})};
      grants.set(id, moved);
      affected.add(grant);
      if (!options.dryRun) transaction.update(db.doc(`users/${uid}/grants/${id}`), {startsAt, endsAt: moved.endsAt,
        ...(moved.fullEndsAt === undefined ? {} : {fullEndsAt: moved.fullEndsAt})});
    }
    if (affected.size && !options.dryRun) {
      transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    }
    return affected.size;
  });
}

export const replanAfterRevoke = (grants: ReadonlyMap<string, Grant>, revokedId: string, now: number) =>
  replanBehind(grants, revokedId, grants.get(revokedId)?.endsAt ?? Infinity, now);

export type GrantOutcome = 'granted' | 'duplicate' | 'noSitting' | 'bornRevoked' | 'unusedDuplicate' | 'paidAfterSitting' | 'accountDeleted' | 'accountOpen';

type Resolutions = Record<string, 'won' | 'lost'>;

export async function commitPaymongoGrant(db: Firestore, input: {uid: string; eventId: string;
  sessionId: string; paymentId: string; paidAmount: number; product: WebProduct; paidAt: number; sitting?: Sitting; deletionOnly?: boolean}, now: number,
  catalog: CatalogExam[]): Promise<GrantOutcome> {
  const {uid, eventId, paymentId, product} = input;
  const grantEventRef = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const tombstone = db.doc(`paymongoRevocations/${grantDocId(paymentId)}`);
  const grantRef = db.doc(`users/${uid}/grants/${grantDocId(paymentId)}`);
  let followUpReason: string | undefined;
  let disputeReason: string | undefined;
  let lostLogged = false;
  const outcome = await db.runTransaction(async transaction => {
    followUpReason = undefined;
    disputeReason = undefined;
    lostLogged = false;
    const [dedupe, paid, revokedEarly, deletion] = await transaction.getAll(
      grantEventRef, payment, tombstone, db.doc(`accountDeletions/${uid}`));
    if (deletion.exists) {
      if (!paid.exists && !dedupe.exists) {
        const followUp = db.doc(`paymongoFollowUps/${grantDocId(paymentId)}`);
        const prior = await transaction.get(followUp);
        const refunds = revokedEarly.get('refunds') as Record<string, number> | undefined;
        const total = Object.values(refunds ?? {}).reduce((sum, amount) => sum + amount, 0);
        // Keep only payment details so the deletion sweep cannot remove this refund task.
        if (prior.get('status') !== 'refunded' && total < input.paidAmount) {
          followUpReason = 'accountDeleted';
          transaction.set(followUp, {
            eventId, paymentId, sessionId: input.sessionId, paidAmount: input.paidAmount,
            reason: 'accountDeleted', status: 'pending', refundRequired: true,
          });
        }
      }
      return 'accountDeleted';
    }
    if (input.deletionOnly) return 'accountOpen';
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const version = Number(inputs.record.get('version') ?? 0);
    if (dedupe.exists) return 'duplicate';
    if (paid.exists) {transaction.set(grantEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)}); return 'duplicate';}
    // A postponement saved after this checkout bound its sitting moves the payment too.
    let sitting = input.sitting;
    let firstDay = sitting?.firstDay;
    const visited = new Set<string>();
    for (let hop = 0; firstDay && product.examId && hop < 8; hop++) {
      if (visited.has(firstDay)) break;
      visited.add(firstDay);
      const move = await transaction.get(db.doc(`paymongoSittingMoves/${product.examId}:${firstDay}`));
      const to: unknown = move.exists ? move.get('to') : undefined;
      if (typeof to !== 'string' || visited.has(to)) break;
      firstDay = to;
      const target = catalog.find(e => e.id === product.examId)?.publishedSittings
        .find(s => s.firstDay === to && s.sourceUrl.length > 0);
      if (target) sitting = target;
    }
    const sittingEnd = sitting ? endOfSitting(sitting) : undefined;
    // A pass first fulfilled after its sitting cannot be used.
    const late = product.prepaid.unit === 'sitting' && sittingEnd !== undefined && (input.paidAt > sittingEnd || now > sittingEnd);
    const plan = product.prepaid.unit === 'sitting'
      ? (sittingEnd !== undefined ? {startsAt: Math.min(input.paidAt, sittingEnd), endsAt: sittingEnd} : null)
      : planGrant(product, [...inputs.grants.values(), ...nativeCoverageRows(inputs, input.paidAt)], input.paidAt, catalog);
    const binding = {paidAt: input.paidAt, ...(sitting ? {sitting, examId: product.examId!} : {})};
    const followUp = db.doc(`paymongoFollowUps/${grantDocId(paymentId)}`);
    const priorFollowUp = await transaction.get(followUp);
    const disputeFollowUpRef = db.doc(followUpId(paymentId));
    const priorDisputeFollowUp = await transaction.get(disputeFollowUpRef);
    const tombstoneLost = revokedEarly.exists ? Object.entries((revokedEarly.get('resolutions') as Resolutions | undefined) ?? {})
      .filter(([, v]) => v === 'lost').map(([k]) => k) : [];
    const lostSnaps = await Promise.all(tombstoneLost.map(d => transaction.get(db.doc(lostFollowUpId(paymentId, d)))));
    const duplicatePass = product.kind === 'pass' && sitting ?
      [...inputs.grants, ...nativeCoverageRows(inputs, input.paidAt).map((g, i): [string, Grant] => [`native_${i}`, g])].find(([, g]) => g.product === product.id && g.state === 'active' && g.endsAt > input.paidAt &&
        (g.sitting?.firstDay === sitting!.firstDay ||
          (plan !== null && g.startsAt <= input.paidAt && g.endsAt >= plan.endsAt))) : undefined;
    // A refund or dispute that arrived first is carried in the tombstone: the grant is born
    // revoked (live dispute or refunds covering the payment) or already shortened. A dispute
    // already won is ignored; one already lost stays revoked and resolved.
    const early = revokedEarly.exists ? revokedEarly.data() as {refunds?: Record<string, number>;
      disputed?: boolean; reason?: string; disputeId?: string; disputedAmount?: number; resolutions?: Resolutions;
      disputedAmounts?: Record<string, number>} : undefined;
    const earlyRefunds = Object.values(early?.refunds ?? {}).reduce((a, b) => a + b, 0);
    const outcome = early?.disputeId ? early.resolutions?.[early.disputeId] : undefined;
    const resolved = Object.entries(early?.resolutions ?? {});
    const lostId = resolved.find(([, v]) => v === 'lost')?.[0];
    const wonId = resolved.find(([, v]) => v === 'won')?.[0];
    // Any dispute resolution recorded on the tombstone counts as a dispute, even when its opening never arrived.
    const disputeLive = (early?.disputed === true && outcome !== 'won') || lostId !== undefined;
    // A dispute won before the payment was known, with refunds: the same mixed case, so the grant is born
    // revoked (as the open dispute would have left it) and the owner gets the one follow-up.
    const mixedWon = wonId !== undefined && earlyRefunds > 0;
    const tiedId = early?.disputeId ?? lostId ?? wonId;
    const refundOwed = !!(duplicatePass || late) && earlyRefunds < input.paidAmount;
    const unusable = duplicatePass ? {reason: 'unusedDuplicatePass'}
      : late ? {reason: 'paidAfterSitting'} : undefined;
    const flagRefund = () => {followUpReason = unusable!.reason; transaction.set(followUp, {uid, paymentId, product: product.id, sessionId: input.sessionId,
      reason: unusable!.reason, status: 'pending', refundRequired: true, paidAmount: input.paidAmount,
      ...(duplicatePass ? {activeGrantId: duplicatePass[0]} : {})});};
    if (early && (disputeLive || mixedWon || earlyRefunds >= input.paidAmount)) {
      const grant: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
        startsAt: plan?.startsAt ?? now, endsAt: plan?.endsAt ?? now, paymentId, paidAmount: input.paidAmount,
        refunds: early.refunds ?? {}, state: 'revoked', createdAt: now, coveredMs: 0,
        ...(refundOwed && duplicatePass ? {unusedDuplicateOf: duplicatePass[0]} : {}),
        ...(refundOwed && late ? {unusableReason: 'paidAfterSitting'} : {})};
      transaction.set(grantRef, {...grant, revokedAt: now, revokedReason: early.reason ?? 'revoked',
        ...(tiedId ? {disputeId: tiedId} : {}),
        ...(disputeLive && !lostId && early.disputeId ? {revokingDisputeId: early.disputeId} : {}),
        ...(lostId !== undefined || mixedWon ? {disputeResolved: true} : {})});
      if (refundOwed) flagRefund();
      if (mixedWon && !priorDisputeFollowUp.exists) {
        disputeReason = 'disputeWithRefund';
        // The mixed case belongs to the won dispute, even when another dispute was lost later.
        transaction.set(disputeFollowUpRef, {paymentId, disputeId: wonId ?? tiedId ?? null, status: 'pending', refundRequired: false,
          reason: disputeReason, paidAmount: input.paidAmount, refundedTotal: earlyRefunds,
          unusedDays: unusedDaysOf({...grant, revokedAt: now}, now), pulled: [], createdAt: now});
      }
      // A loss normally wrote its own follow-up when it arrived; one that has none gets it now.
      tombstoneLost.forEach((d, i) => {
        if (lostSnaps[i].exists) return;
        lostLogged = true;
        transaction.set(db.doc(lostFollowUpId(paymentId, d)),
          lostFollowUp(paymentId, d, early.disputedAmounts?.[d], now));
      });
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
    if (unusable) {
      const unused: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
        startsAt: Math.min(input.paidAt, plan.endsAt), endsAt: Math.min(input.paidAt, plan.endsAt), paymentId,
        paidAmount: input.paidAmount, state: 'revoked', createdAt: now,
        // A partial refund that arrived first counts toward the balance still owed.
        ...(early?.refunds ? {refunds: early.refunds} : {}),
        ...(duplicatePass ? {unusedDuplicateOf: duplicatePass[0]} : {unusableReason: unusable.reason})};
      transaction.set(grantRef, unused);
      transaction.set(payment, {uid, grantId: grantDocId(paymentId), sessionId: input.sessionId, createdAt: now});
      flagRefund();
      transaction.set(grantEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
      if (late) transaction.create(db.collection('audit_logs').doc(), {uid, event: 'paymongoPaidAfterSitting',
        timestamp: FieldValue.serverTimestamp(), metadata: {paymentId, product: product.id}});
      return late && !duplicatePass ? 'paidAfterSitting' : 'unusedDuplicate';
    }
    if (priorFollowUp.exists) transaction.update(followUp, {status: 'resolved'});
    const grant: Grant = {...binding, source: 'paymongo', product: product.id, tier: product.tier,
      startsAt: plan.startsAt, endsAt: plan.endsAt, paymentId, paidAmount: input.paidAmount,
      refunds: {}, fullEndsAt: plan.endsAt, state: 'active', createdAt: now,
      ...(early?.disputed && outcome === 'won' ? {disputeId: early.disputeId, disputeResolved: true} : {})};
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
  // One ERROR line, payment id only, for a log-based alert. Logged once, after the commit.
  if (followUpReason) console.error(`payment follow-up created ${followUpReason}`, {paymentId});
  if (disputeReason) console.error(`payment follow-up created ${disputeReason}`, {paymentId});
  if (lostLogged) console.error('payment follow-up created disputeLost', {paymentId});
  return outcome;
}

export type RevokeOutcome = 'revoked' | 'duplicate' | 'unmatched';

/**
 * Applies a dispute (whole grant revoked) or refunds (shortened in proportion, revoked
 * once refunds cover the payment). If the payment is not known yet, a tombstone keeps the
 * dispute flag and the cumulative refunds for the grant created later.
 */
export async function revokePaymongoPayment(db: Firestore, input: {eventId: string; paymentId: string;
  reason: string; dispute?: boolean; disputeId?: string; disputeLost?: boolean; disputedAmount?: number;
  refunds?: {id: string; amount: number}[]}, now: number):
  Promise<{outcome: RevokeOutcome; uid?: string}> {
  const {eventId, paymentId} = input;
  let disputeReason: string | undefined;
  let lostLogged = false;
  const payment = db.doc(`paymongoPayments/${grantDocId(paymentId)}`);
  const tombstone = db.doc(`paymongoRevocations/${grantDocId(paymentId)}`);
  const followUp = db.doc(`paymongoFollowUps/${grantDocId(paymentId)}`);
  const disputeFollowUp = db.doc(followUpId(paymentId));
  const result = await db.runTransaction(async transaction => {
    disputeReason = undefined;
    lostLogged = false;
    // The payment index and the tombstone are read and written in one transaction, so a
    // refund and a paid event for the same payment cannot both miss each other.
    const lostRef = input.dispute && input.disputeId ? db.doc(lostFollowUpId(paymentId, input.disputeId)) : null;
    const [paid, follow, disputeFollow, lostSnap] = await transaction.getAll(payment, followUp, disputeFollowUp,
      ...(lostRef ? [lostRef] : []));
    // A loss writes its own follow-up once; an opening that names the amount later adds it.
    const noteLoss = (tombstoneAmount: unknown) => {
      if (!lostRef || !lostSnap) return;
      if (input.disputeLost && !lostSnap.exists) {
        lostLogged = true;
        const known = input.disputedAmount ?? (typeof tombstoneAmount === 'number' ? tombstoneAmount : undefined);
        transaction.set(lostRef, lostFollowUp(paymentId, input.disputeId!, known, now));
      } else if (input.disputedAmount !== undefined && lostSnap.exists &&
          lostSnap.get('status') === 'pending' && lostSnap.get('disputedAmount') == null) {
        transaction.update(lostRef, {disputedAmount: input.disputedAmount});
      }
    };
    // Records the refunds on the refund task and closes it when they reach the amount paid.
    const noteRefunds = (refunds: Record<string, number>, paidAmount: unknown) => {
      if (follow.get('status') !== 'pending' || follow.get('refundRequired') !== true) return;
      const total = Object.values(refunds).reduce((sum, amount) => sum + amount, 0);
      const closed = typeof paidAmount === 'number' && paidAmount > 0 && total >= paidAmount;
      transaction.update(followUp, {refunds, ...(closed ? {status: 'refunded'} : {})});
    };
    const closeRefund = (total: number, paidAmount: unknown) => {
      if (follow.get('status') === 'pending' && follow.get('refundRequired') === true &&
          typeof paidAmount === 'number' && paidAmount > 0 && total >= paidAmount) {
        transaction.update(followUp, {status: 'refunded'});
      }
    };
    const uid = paid.get('uid') as string | undefined;
    const unmatched = async () => {
      const existing = await transaction.get(tombstone);
      const refunds = {...(existing.get('refunds') as Record<string, number> | undefined)};
      for (const r of input.refunds ?? []) if (!(r.id in refunds)) refunds[r.id] = r.amount;
      const resolutions = input.disputeLost && input.disputeId
        ? {...existing.get('resolutions') as Resolutions | undefined, [input.disputeId]: 'lost'}
        : existing.get('resolutions') as Resolutions | undefined;
      transaction.set(tombstone, {reason: existing.get('reason') ?? input.reason, eventId: existing.get('eventId') ?? eventId,
        createdAt: existing.get('createdAt') ?? now, refunds, ...(resolutions ? {resolutions} : {}),
        ...(input.disputeId ?? existing.get('disputeId') ? {disputeId: input.disputeId ?? existing.get('disputeId')} : {}),
        ...(input.disputedAmount !== undefined || existing.get('disputedAmount') !== undefined
          ? {disputedAmount: input.disputedAmount ?? existing.get('disputedAmount')} : {}),
        // Each dispute's own amount, kept through every rewrite of the tombstone.
        ...(existing.get('disputedAmounts') !== undefined || (input.disputeId && input.disputedAmount !== undefined)
          ? {disputedAmounts: {...existing.get('disputedAmounts') as Record<string, number> | undefined,
            ...(input.disputeId && input.disputedAmount !== undefined ? {[input.disputeId]: input.disputedAmount} : {})}} : {}),
        disputed: existing.get('disputed') === true || input.dispute === true});
      // Refunds copied onto the task when the account was deleted count toward the balance.
      const counted = {...(follow.get('refunds') as Record<string, number> | undefined), ...refunds};
      noteRefunds(counted, follow.get('paidAmount'));
      // The tombstone's amount belongs to this dispute only when the tombstone names it.
      noteLoss((existing.get('disputedAmounts') as Record<string, number> | undefined)?.[input.disputeId ?? '']);
      return {outcome: 'unmatched' as const};
    };
    if (!paid.exists || typeof uid !== 'string') return unmatched();
    const revokeEventRef = db.doc(`webhookEvents/${eventId}/users/${uid}`);
    const dedupe = await transaction.get(revokeEventRef);
    // What the tombstone already knows: a resolution that arrived before this dispute.created, and the
    // amount of a lost dispute for a refund that comes later.
    const earlier = await transaction.get(tombstone);
    const earlierResolutions = earlier.get('resolutions') as Resolutions | undefined;
    const recorded = input.disputeLost ? 'lost' : input.dispute && input.disputeId
      ? earlierResolutions?.[input.disputeId] : undefined;
    const inputs = await readEntitlementInputs(transaction, db, uid);
    const id = grantDocId(paymentId);
    const grant = inputs.grants.get(id);
    const version = Number(inputs.record.get('version') ?? 0);
    if (dedupe.exists) return {outcome: 'duplicate' as const, uid};
    // While the account is being deleted, every refund also goes onto the refund task, because
    // deletion removes the grant and the refund recorded on it.
    const deleting = (await transaction.get(db.doc(`accountDeletions/${uid}`))).exists;
    // Deletion removed the grant but has not yet cleared the index uid: the refund counts like a no-uid one.
    if (!grant && deleting) return unmatched();
    // Every opening is kept on the tombstone, whatever state the grant is in.
    if (input.dispute && input.disputeId) {
      transaction.set(tombstone, {createdAt: earlier.get('createdAt') ?? now, disputed: true, disputeId: input.disputeId,
        ...(input.disputedAmount !== undefined ? {disputedAmount: input.disputedAmount, disputedAmounts: {
          ...earlier.get('disputedAmounts') as Record<string, number> | undefined, [input.disputeId]: input.disputedAmount}} : {}),
        ...(input.disputeLost ? {resolutions: {...earlierResolutions, [input.disputeId]: 'lost'}} : {})}, {merge: true});
    }
    const grantRef = db.doc(`users/${uid}/grants/${id}`);
    const markPlain = () => transaction.set(revokeEventRef, {eventId, version, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
    const writeDisputeFollowUp = (reason: string, g: Grant, refunded: number, pulled: string[]) => {
      disputeReason = reason;
      transaction.set(disputeFollowUp, {paymentId, disputeId: input.disputeId ?? null, status: 'pending',
        refundRequired: false, reason, paidAmount: paidOf(g), refundedTotal: refunded,
        unusedDays: unusedDaysOf({...g, revokedAt: g.revokedAt ?? now}, now), pulled, createdAt: now});
    };
    noteLoss((earlier.get('disputedAmounts') as Record<string, number> | undefined)?.[input.disputeId ?? '']);
    if (!grant) {markPlain(); return {outcome: 'duplicate' as const, uid};}
    if (grant.state !== 'active' && input.dispute) {
      // The grant is already revoked (a full refund, an earlier dispute, an admin). Its dispute is still
      // recorded, so a later win or loss finds it; a win with refunds is the mixed case and is reported.
      const tied = grant.disputeId === input.disputeId;
      const resolved = recorded !== undefined;
      if (input.disputeId && (!grant.disputeId || (grant.disputeResolved && !tied) || (tied && resolved && !grant.disputeResolved))) {
        transaction.update(grantRef, {disputeId: input.disputeId, disputeResolved: resolved});
      }
      const refunds = {...(earlier.get('refunds') as Record<string, number> | undefined), ...grant.refunds};
      const refunded = Object.values(refunds).reduce((a, b) => a + b, 0);
      if (recorded === 'won' && refunded > 0 && !disputeFollow.exists && !(tied && grant.disputeResolved)) {
        writeDisputeFollowUp('disputeWithRefund', grant, refunded, pulledBy(inputs.grants, input.disputeId ?? ''));
      }
      markPlain();
      return {outcome: 'duplicate' as const, uid};
    }
    // A win recorded before the tombstone existed: the grant is active with this dispute resolved.
    const legacyWin = input.dispute && !input.disputeLost && grant.state === 'active' &&
      grant.disputeId === input.disputeId && grant.disputeResolved === true;
    // A win that arrived before its opening, on a grant that already has refunds: the mixed case. The
    // grant is revoked as the open dispute would leave it, and it is never restored.
    const mixedWon = recorded === 'won' && refundedTotal(grant) > 0 && !legacyWin;
    if ((recorded === 'won' && !mixedWon) || legacyWin) {
      // Already won: the grant is never revoked. Only the dispute is noted on it, and the win is kept.
      transaction.update(grantRef, {disputeId: input.disputeId, disputeResolved: true});
      if (legacyWin && recorded !== 'won') {
        transaction.set(tombstone, {createdAt: earlier.get('createdAt') ?? now,
          resolutions: {...earlierResolutions, [input.disputeId!]: 'won'}}, {merge: true});
      }
      markPlain();
      return {outcome: 'duplicate' as const, uid};
    }
    let next: Grant = input.dispute ? {...grant, state: 'revoked'} : grant;
    for (const r of input.refunds ?? []) next = applyRefund(next, r.id, r.amount, now);
    // A refund that cuts the end into the past stops access now, not at the shortened end.
    if (next.state === 'active' && next.endsAt < grant.endsAt && next.endsAt <= now) next = {...next, accessCutAt: now};
    // Revoked from active: what it covered so far is fixed, so unused days count only its active time.
    if (grant.state === 'active' && next.state === 'revoked') {
      next = {...next, coveredMs: (grant.coveredMs ?? 0) + spellCover({...grant, accessCutAt: next.accessCutAt ?? grant.accessCutAt}, now)};
    }
    if (input.refunds?.length) {
      if (deleting) noteRefunds({...(follow.get('refunds') as Record<string, number> | undefined), ...next.refunds},
        follow.get('paidAmount') ?? next.paidAmount);
      else closeRefund(refundedTotal(next), next.paidAmount);
    }
    if (next === grant) {markPlain(); return {outcome: 'duplicate' as const, uid};}
    const changed = new Map(inputs.grants).set(id, next);
    const native = nativeCoverageRows(inputs, now);
    const shrunk = next.state === 'revoked' || next.endsAt !== grant.endsAt;
    const replanned = shrunk
      ? rechainRewards(replanBehind(changed, id, grant.endsAt, now, Math.max(now, ...native.filter(g => anchorsPlan(g, grant.tier, now)).map(g => g.endsAt))), native, now) : changed;
    const ref = (gid: string) => db.doc(`users/${uid}/grants/${gid}`);
    transaction.update(ref(id), {state: next.state, endsAt: next.endsAt, refunds: next.refunds ?? {},
      ...(next.fullEndsAt !== undefined ? {fullEndsAt: next.fullEndsAt} : {}),
      ...(next.coveredMs !== grant.coveredMs ? {coveredMs: next.coveredMs} : {}),
      ...(next.accessCutAt !== grant.accessCutAt ? {accessCutAt: next.accessCutAt} : {}),
      ...(input.dispute && input.disputeId ? {disputeId: input.disputeId, disputeResolved: recorded !== undefined} : {}),
      // Only the dispute whose opening revoked an active grant can restore it.
      ...(input.dispute && input.disputeId && grant.state === 'active' ? {revokingDisputeId: input.disputeId} : {}),
      ...(next.state === 'revoked' ? {revokedAt: grant.revokedAt ?? now, revokedReason: grant.revokedReason ?? input.reason} : {})});
    const pulled: string[] = [];
    for (const [otherId, other] of replanned) {
      const before = inputs.grants.get(otherId);
      if (otherId !== id && before && (before.startsAt !== other.startsAt || before.endsAt !== other.endsAt)) {
        pulled.push(otherId);
        const moves = input.dispute && input.disputeId && recorded !== 'lost' ? {disputeMoves: {...before.disputeMoves,
          [input.disputeId]: {startsAt: before.startsAt, endsAt: before.endsAt,
            movedStartsAt: other.startsAt, movedEndsAt: other.endsAt}}} : {};
        transaction.update(ref(otherId), {startsAt: other.startsAt, endsAt: other.endsAt,
          ...(other.fullEndsAt !== undefined ? {fullEndsAt: other.fullEndsAt} : {}), ...moves});
      }
    }
    if (!disputeFollow.exists && !disputeReason) {
      if (mixedWon) writeDisputeFollowUp('disputeWithRefund', next, refundedTotal(next), pulled.sort());
    }
    transaction.set(revokeEventRef, {eventId, version: version + 1, expireAt: Timestamp.fromMillis(now + EVENT_KEEP_MS)});
    transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, replanned)), {merge: true});
    return {outcome: 'revoked' as const, uid};
  });
  if (disputeReason) console.error(`payment follow-up created ${disputeReason}`, {paymentId});
  if (lostLogged) console.error('payment follow-up created disputeLost', {paymentId});
  return result;
}

/**
 * After a dispute win, rebuilds the whole same-tier chain of tier-wide plans: every live plan of
 * the tier (the restored one included) plus any plan this dispute moved. A plan this dispute
 * moved that still has exactly its moved schedule uses its pre-dispute start and length; any
 * other uses its current schedule. The chain is sorted by intended start (then createdAt, id).
 * A plan that is already running keeps the later of the cursor and its start; a queued plan goes
 * at the later of the cursor and the end of coverage outside the chain (higher tiers, native
 * rows, or now). Every plan keeps its length. Exam-only rows never move and never join the chain.
 * Returns a new map; unchanged grants keep their identity.
 */
export function rechainAfterWin(grants: ReadonlyMap<string, Grant>, restoredId: string,
  disputeId: string, now: number, native: readonly Grant[] = []): Map<string, Grant> {
  const out = new Map(grants);
  const restored = grants.get(restoredId);
  if (!restored) return out;
  const intended = (g: Grant) => {
    const move = g.disputeMoves?.[disputeId];
    return move && g.startsAt === move.movedStartsAt && g.endsAt === move.movedEndsAt
      ? {start: move.startsAt, length: move.endsAt - move.startsAt}
      : {start: g.startsAt, length: g.endsAt - g.startsAt};
  };
  const chain = [...grants].filter(([id, g]) => g.state === 'active' && tierWide(g) && stackable(g) &&
    g.tier === restored.tier && (id === restoredId || g.endsAt > now || g.disputeMoves?.[disputeId] !== undefined))
    .map(([id, g]) => ({id, g, ...intended(g)}))
    .sort((a, b) => a.start - b.start || a.g.createdAt - b.g.createdAt || (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  const inChain = new Set(chain.map(row => row.id));
  let anchorEnd = now;
  for (const [id, g] of grants) {
    if (!inChain.has(id) && anchorsPlan(g, restored.tier, now)) anchorEnd = Math.max(anchorEnd, g.endsAt);
  }
  for (const row of native) if (anchorsPlan(row, restored.tier, now)) anchorEnd = Math.max(anchorEnd, row.endsAt);
  let cursor = -Infinity;
  for (const {id, g, start: wanted, length} of chain) {
    const start = Math.max(cursor, wanted <= now ? wanted : anchorEnd);
    const {[disputeId]: _gone, ...rest} = g.disputeMoves ?? {};
    const {disputeMoves: _old, ...bare} = g;
    // A plan with its natural length takes the length its product gives at the new start (a calendar
    // month changes days); one cut by a later change keeps that cut length.
    const natural = startAt(g, wanted).endsAt - wanted === length;
    const placed: Grant = {...(natural ? startAt(bare, start) : {...bare, startsAt: start, endsAt: start + length,
      ...(g.fullEndsAt === undefined ? {} : {fullEndsAt: g.fullEndsAt + (start - g.startsAt)})}),
      ...(Object.keys(rest).length ? {disputeMoves: rest} : {})};
    const same = placed.startsAt === g.startsAt && placed.endsAt === g.endsAt &&
      placed.fullEndsAt === g.fullEndsAt && g.disputeMoves?.[disputeId] === undefined;
    if (!same) out.set(id, placed);
    cursor = placed.endsAt;
  }
  return out;
}

/**
 * A win restores only this dispute's revocation, without buying any extra time. A grant that has
 * both this dispute and any refund is never restored or re-planned: the win is recorded, the dispute
 * is marked resolved, the grant stays as it is, and one follow-up for the owner records what is left
 * to settle by hand. A resolution that arrives before the payment is known, or before its
 * dispute.created, is recorded in the payment's tombstone so the later event applies the final outcome.
 */
export async function resolvePaymongoDispute(db: Firestore, input: {eventId: string;
  paymentId: string; disputeId: string; won: boolean; disputedAmount?: number}, now: number): Promise<string | undefined> {
  if (!input.won) {
    const result = await revokePaymongoPayment(db, {...input, reason: 'dispute.created',
      dispute: true, disputeLost: true}, now);
    return result.uid;
  }
  let created = false;
  const uid = await db.runTransaction(async transaction => {
    created = false;
    const tombstone = db.doc(`paymongoRevocations/${grantDocId(input.paymentId)}`);
    const followUp = db.doc(followUpId(input.paymentId));
    const [paid, existing, priorFollowUp] = await transaction.getAll(
      db.doc(`paymongoPayments/${grantDocId(input.paymentId)}`), tombstone, followUp);
    const uid = paid.get('uid') as string | undefined;
    const record = () => transaction.set(tombstone, {createdAt: existing.get('createdAt') ?? now,
      resolutions: {...(existing.get('resolutions') as Resolutions | undefined),
        [input.disputeId]: input.won ? 'won' : 'lost'}}, {merge: true});
    if (!uid) {record(); return undefined;}
    const inputs = await readEntitlementInputs(transaction, db, uid);
    // The win is kept in the tombstone whatever the grant looks like, so an opening event that
    // arrives later, even after its dedupe marker expired, never revokes. Written after every read.
    record();
    const id = grantDocId(input.paymentId);
    const grant = inputs.grants.get(id);
    if (grant?.state === 'active' && grant.disputeId !== input.disputeId) return uid;
    if (!grant || grant.state !== 'revoked' || grant.disputeId !== input.disputeId || grant.disputeResolved) return uid;
    const refunds = {...(existing.get('refunds') as Record<string, number> | undefined), ...grant.refunds};
    const refunded = Object.values(refunds).reduce((a, b) => a + b, 0);
    if (refunded > 0) {
      // Dispute and refund on one grant, in either order: nothing is restored or moved.
      transaction.update(db.doc(`users/${uid}/grants/${id}`), {disputeResolved: true});
      if (!priorFollowUp.exists) {
        created = true;
        transaction.set(followUp, {paymentId: input.paymentId, disputeId: input.disputeId, status: 'pending',
          refundRequired: false, reason: 'disputeWithRefund', paidAmount: paidOf(grant), refundedTotal: refunded,
          unusedDays: unusedDaysOf(grant, now), pulled: pulledBy(inputs.grants, input.disputeId), createdAt: now});
      }
      return uid;
    }
    // Only a revocation left by the dispute itself is undone (a later admin revocation stays). A grant that
    // any dispute on this payment has lost stays revoked: a win of a later dispute never gives it back.
    const lostBefore = Object.values((existing.get('resolutions') as Resolutions | undefined) ?? {}).includes('lost');
    // Grants revoked before this branch lack revokingDisputeId and so are never restored. Prod has only ever run test
    // keys, so no such grant exists.
    if (grant.revokedReason !== 'dispute.created' || lostBefore || grant.revokingDisputeId !== input.disputeId) return uid;
    const restore = paidOf(grant) > 0 && !grant.unusedDuplicateOf && !grant.unusableReason;
    const next: Grant = {...grant, disputeResolved: true, ...(restore ? {state: 'active', activeFrom: now} : {})};
    transaction.update(db.doc(`users/${uid}/grants/${id}`), {disputeResolved: true,
      ...(restore ? {state: 'active', activeFrom: now, revokedReason: FieldValue.delete(), revokedAt: FieldValue.delete()} : {})});
    if (restore) {
      const grants = new Map(inputs.grants).set(id, next);
      const native = nativeCoverageRows(inputs, now);
      if (stackable(grant) && tierWide(grant)) {
        // Re-chain the same-tier plans behind the restored grant (see rechainAfterWin).
        const rechained = rechainAfterWin(grants, id, input.disputeId, now, native);
        for (const [otherId, placed] of rechained) {
          const row = grants.get(otherId)!;
          if (placed === row) continue;
          grants.set(otherId, placed);
          transaction.update(db.doc(`users/${uid}/grants/${otherId}`), {
            startsAt: placed.startsAt, endsAt: placed.endsAt,
            ...(placed.fullEndsAt === undefined ? {} : {fullEndsAt: placed.fullEndsAt}),
            ...(row.disputeMoves?.[input.disputeId] === undefined ? {}
              : {disputeMoves: placed.disputeMoves ? placed.disputeMoves : FieldValue.delete()}),
          });
        }
      }
      // Rewards this dispute pulled earlier go back behind the restored coverage.
      const pulled = new Set([...grants].filter(([, row]) => row.source === 'beta_reward' && row.state === 'active' &&
        row.disputeMoves?.[input.disputeId] !== undefined).map(([rewardId]) => rewardId));
      for (const [rewardId, row] of rechainRewards(grants, native, now, pulled)) {
        if (!pulled.has(rewardId)) continue;
        const move = row.disputeMoves![input.disputeId];
        const again = grants.get(rewardId)!.startsAt !== move.movedStartsAt || grants.get(rewardId)!.endsAt !== move.movedEndsAt;
        const length = again ? row.endsAt - row.startsAt : move.endsAt - move.startsAt;
        const rest = {...row.disputeMoves};
        delete rest[input.disputeId];
        const placed = {...row, endsAt: row.startsAt + length};
        grants.set(rewardId, placed);
        transaction.update(db.doc(`users/${uid}/grants/${rewardId}`), {startsAt: placed.startsAt, endsAt: placed.endsAt,
          disputeMoves: Object.keys(rest).length ? rest : FieldValue.delete()});
      }
      transaction.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    }
    return uid;
  });
  if (created) console.error('payment follow-up created disputeWithRefund', {paymentId: input.paymentId});
  return uid;
}
