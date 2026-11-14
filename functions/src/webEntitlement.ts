import {getAuth, type Auth} from 'firebase-admin/auth';
import {refreshRewardClaims} from './betaReward.js';
import {enforceAppCheck} from './_appCheck.js';
import {betaProUntil} from './betaPro.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertNamedUser} from './_audit.js';
import {nativeCoverageRows, readEntitlementInputs} from './entitlementInputs.js';
import {allowAtMost} from './_limits.js';
import {timed} from './_timed.js';

/** Owner-bound combined coverage. Never exposes RevenueCat facts or provider identifiers. */
export async function webEntitlement(auth: Parameters<typeof assertNamedUser>[0], db: Firestore, at = Date.now(),
  claimAuth?: Pick<Auth, 'getUser' | 'setCustomUserClaims'>) {
  if (!auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  if (claimAuth) await refreshRewardClaims(db, claimAuth, auth.uid, at);
  return db.runTransaction(async transaction => {
    const inputs = await readEntitlementInputs(transaction, db, auth.uid);
    return {betaProUntil: betaProUntil(at), grants: [...inputs.grants.values(), ...nativeCoverageRows(inputs, at)].map(row => ({
      examId: row.examId ?? null, source: row.source, product: row.product, tier: row.tier, state: row.state,
      startsAt: row.startsAt, endsAt: row.endsAt,
    }))};
  });
}
/**
 * The app reads this on start, on a refresh and after a checkout, a few times an hour at most.
 * 120 an hour is far above an honest heavy user and still stops a script from hammering the
 * entitlement transaction.
 */
export const WEB_ENTITLEMENT_PER_HOUR = 120;

export const getWebEntitlement = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('getWebEntitlement', async request => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
    if (request.data?.uid !== request.auth.uid) {
      throw new HttpsError('permission-denied', 'The account changed. Try again.');
    }
    if (!await allowAtMost(request.auth.uid, 'getWebEntitlement', WEB_ENTITLEMENT_PER_HOUR, 3_600_000)) {
      throw new HttpsError('resource-exhausted', 'Too many requests. Try again later.');
    }
    return webEntitlement(request.auth, getFirestore(), Date.now(), getAuth());
  }));
