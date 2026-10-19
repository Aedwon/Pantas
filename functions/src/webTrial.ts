import {FieldValue, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {claimsFromInputs, entitlementWrite, readEntitlementInputs} from './entitlementInputs.js';
import {DAY_MS, TRIAL_DAYS, TRIAL_PRODUCT, type Grant} from './grants.js';
import {copyEntitlementClaims} from './revenuecatClaims.js';

export type TrialDeps = {db: Firestore; auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  allow?: (uid: string) => Promise<boolean>; now?: () => number};

/**
 * One 7-day trial per account, Civil Service tier. Refused for anonymous accounts, an
 * account with a trial record, and any account that ever held a paid grant, a
 * subscription, a pass or a purchase.
 */
export async function startTrial(auth: Parameters<typeof assertNamedUser>[0], deps: TrialDeps):
  Promise<{startsAt: number; endsAt: number}> {
  const uid = assertNamedUser(auth);
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? (id => allowAtMost(id, 'webTrial', 5, 60 * 60_000)))(uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const trial = deps.db.doc(`users/${uid}/server/trial`);
  const result = await deps.db.runTransaction(async transaction => {
    const marker = await transaction.get(trial);
    const inputs = await readEntitlementInputs(transaction, deps.db, uid);
    if (marker.exists) throw new HttpsError('failed-precondition', 'The free trial was already used.');
    const facts = inputs.record.get('facts') as {sources?: unknown[]; purchases?: unknown[]} | undefined;
    if (inputs.grants.size > 0 || inputs.passes.length > 0 || inputs.record.get('pro') === true ||
        Number(inputs.record.get('proUntil') ?? 0) > 0 ||
        (facts?.sources?.length ?? 0) > 0 || (facts?.purchases?.length ?? 0) > 0) {
      throw new HttpsError('failed-precondition', 'The free trial is only for accounts that never had Pro.');
    }
    const grant: Grant = {source: 'trial', product: TRIAL_PRODUCT, tier: 'civilService',
      startsAt: now, endsAt: now + TRIAL_DAYS * DAY_MS, state: 'active', createdAt: now};
    const grants = new Map(inputs.grants).set('trial', grant);
    transaction.set(trial, {usedAt: now, grantId: 'trial'});
    transaction.set(deps.db.doc(`users/${uid}/grants/trial`), grant);
    transaction.set(inputs.record.ref, {...entitlementWrite(inputs, claimsFromInputs(inputs, now, grants))}, {merge: true});
    transaction.create(deps.db.collection('audit_logs').doc(), {uid, event: 'webTrialStarted',
      timestamp: FieldValue.serverTimestamp(), metadata: {endsAt: grant.endsAt}});
    return {startsAt: grant.startsAt, endsAt: grant.endsAt};
  });
  // The trial is committed. If the Auth copy fails, the hourly repair job retries it.
  try { await copyEntitlementClaims(deps.db, deps.auth, uid); }
  catch (error) { console.error('Trial claim copy failed; repair job will retry', {uid, error}); }
  return result;
}

export const startWebTrial = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true, consumeAppCheckToken: true},
  request => startTrial(request.auth, {db: getFirestore(), auth: getAuth()}));
