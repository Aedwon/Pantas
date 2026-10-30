import {createHmac} from 'node:crypto';
import {defineSecret} from 'firebase-functions/params';
import {FieldValue, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertFreshAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {claimsFromInputs, entitlementWrite, readEntitlementInputs, type EntitlementInputs} from './entitlementInputs.js';
import {DAY_MS, TRIAL_DAYS, TRIAL_PRODUCT, type Grant} from './grants.js';
import {copyEntitlementClaims} from './revenuecatClaims.js';

export const trialIdentityKey = defineSecret('TRIAL_IDENTITY_HMAC_KEY');

/** Only Firebase-verified token identities are used, never caller data. */
export function identityMarkers(auth: Parameters<typeof assertNamedUser>[0], db: Firestore) {
  const key = trialIdentityKey.value();
  if (!key) throw new HttpsError('failed-precondition', 'Trial eligibility is unavailable.');
  const provider = auth?.token.firebase?.sign_in_provider;
  const identities = auth?.token.firebase?.identities as Record<string, unknown> | undefined;
  const providerUids = provider ? identities?.[provider] : undefined;
  if (!provider || provider === 'anonymous' || provider === 'custom' ||
      !Array.isArray(providerUids) || providerUids.length === 0) {
    throw new HttpsError('failed-precondition', 'A verified sign-in identity is required.');
  }
  const values = providerUids.filter((value): value is string => typeof value === 'string' && value.length > 0)
    .map(value => JSON.stringify(['provider', provider, value]));
  if (auth?.token.email_verified === true && typeof auth.token.email === 'string') {
    values.push(JSON.stringify(['email', auth.token.email.toLowerCase()]));
  }
  if (values.length === 0) throw new HttpsError('failed-precondition', 'A verified sign-in identity is required.');
  return [...new Set(values)].map(value => db.doc(`trialUsedIdentities/${createHmac('sha256', key).update(value).digest('hex')}`));
}

export type TrialDeps = {db: Firestore; auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  allow?: (uid: string) => Promise<boolean>; now?: () => number};

/** Both discovery and trial creation use the same complete purchase history. */
function neverHadPro(inputs: EntitlementInputs): boolean {
  const facts = inputs.record.get('facts') as {sources?: unknown[]; purchases?: unknown[]} | undefined;
  return inputs.grants.size === 0 && inputs.passes.length === 0 && inputs.record.get('pro') !== true &&
    Number(inputs.record.get('proUntil') ?? 0) <= 0 &&
    (facts?.sources?.length ?? 0) === 0 && (facts?.purchases?.length ?? 0) === 0;
}

/** Read-only eligibility. The creation transaction checks again before granting. */
export async function trialEligible(auth: Parameters<typeof assertNamedUser>[0], db: Firestore): Promise<boolean> {
  if (!auth || auth.token.firebase?.sign_in_provider === 'anonymous') return false;
  const identities = identityMarkers(auth, db);
  return db.runTransaction(async transaction => {
    const used = await transaction.getAll(...identities);
    const marker = await transaction.get(db.doc(`users/${auth.uid}/server/trial`));
    const inputs = await readEntitlementInputs(transaction, db, auth.uid);
    return !marker.exists && used.every(row => !row.exists) && neverHadPro(inputs);
  });
}

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
  const identities = identityMarkers(auth, deps.db);
  const trial = deps.db.doc(`users/${uid}/server/trial`);
  const result = await deps.db.runTransaction(async transaction => {
    const used = await transaction.getAll(...identities);
    const marker = await transaction.get(trial);
    const inputs = await readEntitlementInputs(transaction, deps.db, uid);
    if (marker.exists || used.some(row => row.exists)) throw new HttpsError('failed-precondition', 'The free trial was already used.');
    if (!neverHadPro(inputs)) {
      throw new HttpsError('failed-precondition', 'The free trial is only for accounts that never had Pro.');
    }
    const grant: Grant = {source: 'trial', product: TRIAL_PRODUCT, tier: 'civilService',
      startsAt: now, endsAt: now + TRIAL_DAYS * DAY_MS, state: 'active', createdAt: now};
    const grants = new Map(inputs.grants).set('trial', grant);
    transaction.set(trial, {usedAt: now, grantId: 'trial'});
    for (const ref of identities) transaction.set(ref, {used: true});
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
  {region: 'asia-southeast1', enforceAppCheck: true, consumeAppCheckToken: true, secrets: [trialIdentityKey]},
  request => {
    assertFreshAppCheck(request);
    return startTrial(request.auth, {db: getFirestore(), auth: getAuth()});
  });
