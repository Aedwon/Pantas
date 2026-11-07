import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';

/** The beta opens at Nov 9, 2026, 12:00 a.m. in the Philippines (UTC+8, no daylight saving). */
export const BETA_START = Date.parse('2026-11-09T00:00:00+08:00');

/** Application IDs are opaque Worker generations. Match the stored email field. */
async function selectedApplications(auth: CallableRequest['auth'], db: Firestore) {
  if (!auth || auth.token.firebase?.sign_in_provider === 'anonymous' ||
      auth.token.email_verified !== true || typeof auth.token.email !== 'string') return [];
  const email = auth.token.email.trim().toLowerCase();
  if (!email) return [];
  const applications = await db.collection('betaApplications').where('email', '==', email).get();
  return applications.docs.filter(application => application.get('selected') === true);
}

export async function selectedBetaApplication(auth: CallableRequest['auth'], db: Firestore): Promise<boolean> {
  return (await selectedApplications(auth, db)).length > 0;
}

export async function checkBetaAccess(request: Pick<CallableRequest, 'auth' | 'app'>,
  deps: {db: Firestore; allow?: (uid: string) => Promise<boolean>; now?: () => number}) {
  if (!request.app || !request.auth) throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  assertFreshAppCheck(request);
  if (!await (deps.allow ?? (uid => allowAtMost(uid, 'betaAccess', 30, 10 * 60_000)))(request.auth.uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const applications = await selectedApplications(request.auth, deps.db);
  const selected = applications.length > 0;
  // Owner test accounts and the early-access list skip the wait before the start.
  const skipsWait = applications.some(application =>
    application.get('ownerTest') === true || application.get('earlyAccess') === true);
  return selected && !skipsWait && (deps.now ?? Date.now)() < BETA_START
    ? {selected, waitUntil: BETA_START} : {selected};
}

export const getBetaAccess = onCall({region:'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck},
  request => {
    assertFreshAppCheck(request);
    return checkBetaAccess(request, {db:getFirestore()});
  });
