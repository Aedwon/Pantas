import {getAuth, type Auth} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {timed} from './_timed.js';
import {holderForChild} from './childLinks.js';

/** The beta opens at Nov 9, 2026, 12:00 a.m. in the Philippines (UTC+8, no daylight saving). */
export const BETA_START = Date.parse('2026-11-09T00:00:00+08:00');

type HolderLookup = Pick<Auth, 'getUser'>;

/**
 * A linked child is an emailless custom-token user. Its beta selection is its holder's: the holder's
 * verified email, read from the holder's Auth record, is checked the way the holder's own token is.
 * An unlinked emailless user has no email and is never selected.
 */
async function holderEmail(auth: NonNullable<CallableRequest['auth']>, db: Firestore, lookup?: HolderLookup):
  Promise<string | null> {
  if (auth.token.firebase?.sign_in_provider !== 'custom') return null;
  const holderUid = await holderForChild(db, auth.uid);
  if (!holderUid) return null;
  try {
    const holder = await (lookup ?? getAuth()).getUser(holderUid);
    return holder.emailVerified === true && typeof holder.email === 'string' ? holder.email : null;
  } catch (error) {
    if ((error as {code?: string} | null)?.code === 'auth/user-not-found') return null;
    throw error;
  }
}

/** Application IDs are opaque Worker generations. Match the stored email field. */
async function selectedApplications(auth: CallableRequest['auth'], db: Firestore, lookup?: HolderLookup) {
  if (!auth || auth.token.firebase?.sign_in_provider === 'anonymous') return [];
  const verified = auth.token.email_verified === true && typeof auth.token.email === 'string' ? auth.token.email : null;
  const raw = verified ?? await holderEmail(auth, db, lookup);
  if (raw === null) return [];
  const email = raw.trim().toLowerCase();
  if (!email) return [];
  const applications = await db.collection('betaApplications').where('email', '==', email).get();
  return applications.docs.filter(application => application.get('selected') === true);
}

export async function selectedBetaApplication(auth: CallableRequest['auth'], db: Firestore, lookup?: HolderLookup): Promise<boolean> {
  return (await selectedApplications(auth, db, lookup)).length > 0;
}

export async function checkBetaAccess(request: Pick<CallableRequest, 'auth' | 'app'>,
  deps: {db: Firestore; auth?: HolderLookup; allow?: (uid: string) => Promise<boolean>; now?: () => number}) {
  if (!request.app || !request.auth) throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  assertFreshAppCheck(request);
  if (!await (deps.allow ?? (uid => allowAtMost(uid, 'betaAccess', 30, 10 * 60_000)))(request.auth.uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const applications = await selectedApplications(request.auth, deps.db, deps.auth);
  const selected = applications.length > 0;
  // Owner test accounts and the early-access list skip the wait before the start.
  const skipsWait = applications.some(application =>
    application.get('ownerTest') === true || application.get('earlyAccess') === true);
  return selected && !skipsWait && (deps.now ?? Date.now)() < BETA_START
    ? {selected, waitUntil: BETA_START} : {selected};
}

export const getBetaAccess = onCall({region:'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck},
  timed('getBetaAccess', request => {
    assertFreshAppCheck(request);
    return checkBetaAccess(request, {db:getFirestore()});
  }));
