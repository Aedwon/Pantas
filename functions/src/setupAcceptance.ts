import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {timed} from './_timed.js';

/** The wording of the setup acceptance that names study records. */
export const SETUP_ACCEPTANCE_VERSION = '2026-11-09';

type AcceptanceRequest = Pick<CallableRequest, 'auth' | 'app' | 'data'>;

/** Records which acceptance wording a named account agreed to at setup, and when. */
export async function recordAcceptance(request: AcceptanceRequest, deps: {db: Firestore; now?: () => number}):
  Promise<{version: string}> {
  if (!request.app) throw new HttpsError('unauthenticated', 'App Check is required.');
  assertFreshAppCheck(request);
  const uid = assertNamedUser(request.auth);
  const version = (request.data as {version?: unknown} | null)?.version;
  if (version !== SETUP_ACCEPTANCE_VERSION) {
    throw new HttpsError('invalid-argument', 'Reload the app to review the current terms.');
  }
  await deps.db.doc(`users/${uid}/server/acceptance`).set({version, acceptedAt: (deps.now ?? Date.now)()}, {merge: true});
  return {version};
}

export const recordSetupAcceptance = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('recordSetupAcceptance', (request) => recordAcceptance(request, {db: getFirestore()})));
