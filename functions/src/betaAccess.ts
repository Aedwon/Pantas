import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';

/** Application IDs are opaque Worker generations. Match the stored email field. */
export async function selectedBetaApplication(auth: CallableRequest['auth'], db: Firestore): Promise<boolean> {
  if (!auth || auth.token.firebase?.sign_in_provider === 'anonymous' ||
      auth.token.email_verified !== true || typeof auth.token.email !== 'string') return false;
  const email = auth.token.email.trim().toLowerCase();
  if (!email) return false;
  const applications = await db.collection('betaApplications').where('email', '==', email).get();
  return applications.docs.some(application => application.get('selected') === true);
}

export async function checkBetaAccess(request: Pick<CallableRequest, 'auth' | 'app'>,
  deps: {db: Firestore; allow?: (uid: string) => Promise<boolean>}) {
  if (!request.app || !request.auth) throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  assertFreshAppCheck(request);
  if (!await (deps.allow ?? (uid => allowAtMost(uid, 'betaAccess', 30, 10 * 60_000)))(request.auth.uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  return {selected: await selectedBetaApplication(request.auth, deps.db)};
}

export const getBetaAccess = onCall({region:'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck},
  request => {
    assertFreshAppCheck(request);
    return checkBetaAccess(request, {db:getFirestore()});
  });
