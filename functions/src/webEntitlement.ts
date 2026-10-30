import {betaProUntil} from './betaPro.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertNamedUser} from './_audit.js';
import {nativeCoverageRows, readEntitlementInputs} from './entitlementInputs.js';

/** Owner-bound combined coverage. Never exposes RevenueCat facts or provider identifiers. */
export async function webEntitlement(auth: Parameters<typeof assertNamedUser>[0], db: Firestore, at = Date.now()) {
  if (!auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  return db.runTransaction(async transaction => {
    const inputs = await readEntitlementInputs(transaction, db, auth.uid);
    return {betaProUntil: betaProUntil(at), grants: [...inputs.grants.values(), ...nativeCoverageRows(inputs, at)].map(row => ({
      examId: row.examId ?? null, source: row.source, product: row.product, tier: row.tier, state: row.state,
      startsAt: row.startsAt, endsAt: row.endsAt,
    }))};
  });
}
export const getWebEntitlement = onCall({region: 'asia-southeast1', enforceAppCheck: true},
  request => {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
    if (request.data?.uid !== request.auth.uid) {
      throw new HttpsError('permission-denied', 'The account changed. Try again.');
    }
    return webEntitlement(request.auth, getFirestore());
  });
