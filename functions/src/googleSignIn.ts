import {assertSignInTargetActive} from './_accountAccess.js';
import {createHmac} from 'node:crypto';
import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {defineString} from 'firebase-functions/params';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {clientBucket} from './_clientAddress.js';
import {phDay} from './_phDate.js';
import {isSquatter, replaceSquatter, type SquatterAuth} from './_squatter.js';
import {key as signInKey, signInCodeKey} from './signInCode.js';
import {timed} from './_timed.js';

/**
 * Google sign-in for an address that already has an account.
 *
 * Firebase allows one account per email. A tester who first signed in with the email code has an
 * account with no Google link, so Firebase refuses their Google sign-in. This callable checks
 * Google's proof of the address and signs the person into that existing account, then links
 * Google to it so the next Google sign-in works directly. It never makes an account: an address
 * with no account signs in through Firebase itself.
 *
 * The proof is the Google ID token, checked with Google's tokeninfo endpoint. That is as strong
 * as the email code (both prove control of the inbox) and adds no dependency. It is accepted
 * only for addresses Google is authoritative for: gmail.com, googlemail.com, or the Workspace
 * domain named in the token's `hd` claim. Any other address uses the email code.
 */

/** The OAuth client id of the Firebase Google provider. Empty (staging, dev) means this path refuses. */
export const googleWebClientId = defineString('GOOGLE_WEB_CLIENT_ID', {default: ''});

const TOKENINFO_URL = 'https://oauth2.googleapis.com/tokeninfo';
const TOKENINFO_TIMEOUT_MS = 5_000;
const MAX_TOKEN_CHARS = 4096;
const EXCHANGES_PER_CALLER = 10;
const EXCHANGE_WINDOW_MS = 10 * 60_000;
/**
 * Abuse budget for the outbound tokeninfo call, sized for about 20 testers. Anonymous accounts are
 * free to make, so the per-caller limit alone cannot stop one machine that rotates them. Each
 * address gets 20 verifications per 10 minutes (kept as a keyed hash, like the email-code limit),
 * and the whole service gets 500 a day (Philippine day). Both are checked before Google is asked.
 */
export const EXCHANGES_PER_IP = 20;
export const EXCHANGES_PER_DAY = 500;
const DAY_RETENTION_MS = 3 * 24 * 3_600_000;
const GOOGLE_ISSUERS = new Set(['accounts.google.com', 'https://accounts.google.com']);
// Google is the authority for these domains, the same rule Firebase uses for trusted Google emails.
const GOOGLE_MAIL_DOMAINS = new Set(['gmail.com', 'googlemail.com']);
const CANNOT_SIGN_IN = "This account can't sign in. Write to support@pantas.study.";
const NOT_VERIFIED = 'Google could not confirm this sign-in.';

export type TokenInfoReply = {status: number; body: unknown};

export type GoogleSignInDeps = {
  auth: Pick<Auth, 'getUserByEmail' | 'getUserByProviderUid' | 'updateUser' | 'createCustomToken'> & SquatterAuth;
  /** The expected `aud` of the Google ID token. */
  clientId: string;
  /** Asks Google about an ID token. Tests pass a stand-in so they never reach Google. */
  fetchTokenInfo: (idToken: string) => Promise<TokenInfoReply>;
  /** Holds the per-IP and daily counters. */
  db: Firestore;
  /** The secret that keys the IP hash, so the address itself is never stored. */
  key: string;
  /** Deletes a replaced squatter and its data. Defaults to the account deletion path; tests stand in for it. */
  purge?: (uid: string) => Promise<void>;
  /** The most outbound verifications per Philippine day. Defaults to `EXCHANGES_PER_DAY`. */
  dailyCap?: number;
  now?: () => number;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
};

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'> & {
  rawRequest?: {ip?: string; headers?: Record<string, string | string[] | undefined>};
};

export {addressBucket, clientBucket} from './_clientAddress.js';

function assertCaller(request: Req): string {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  return request.auth.uid;
}

const millis = (value: unknown): number => (typeof value === 'number' ? value : 0);

/** One 10 minute window per caller address, stored under a keyed hash. Same shape as the email-code limit. */
async function allowIp(db: Firestore, key: string, bucket: string, at: number): Promise<boolean> {
  const ref = db.doc(`signInLimits/google-ip-${createHmac('sha256', key).update(`google-ip\0${bucket}`).digest('hex')}`);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    const startedAt = millis(snapshot.get('windowStartedAt'));
    const inWindow = startedAt > 0 && at - startedAt < EXCHANGE_WINDOW_MS;
    const count = inWindow ? Number(snapshot.get('count') ?? 0) : 0;
    if (count >= EXCHANGES_PER_IP) return false;
    transaction.set(ref, {windowStartedAt: inWindow ? startedAt : at, count: count + 1,
      purgeAt: new Date(at + 2 * EXCHANGE_WINDOW_MS)});
    return true;
  });
}

/** Takes one place from the day's budget of outbound verifications, or reports that it is spent. */
async function takeDailyPlace(db: Firestore, cap: number, at: number): Promise<boolean> {
  const ref = db.doc(`signInLimits/global-google-${phDay(at)}`);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    const used = Number(snapshot.get('count') ?? 0);
    if (!Number.isFinite(cap) || cap < 1 || used + 1 > cap) return false;
    transaction.set(ref, {count: used + 1, purgeAt: new Date(at + DAY_RETENTION_MS)}, {merge: true});
    return true;
  });
}

/** The real lookup. Failures surface as thrown errors, which the caller reports as unavailable. */
export async function fetchGoogleTokenInfo(idToken: string): Promise<TokenInfoReply> {
  const response = await fetch(`${TOKENINFO_URL}?id_token=${encodeURIComponent(idToken)}`,
    {signal: AbortSignal.timeout(TOKENINFO_TIMEOUT_MS)});
  return {status: response.status, body: await response.json().catch(() => null)};
}

const authCode = (error: unknown): string | undefined => (error as {code?: string} | null)?.code;

async function userOrNull(lookup: () => Promise<UserRecord>): Promise<UserRecord | null> {
  try {
    return await lookup();
  } catch (error) {
    if (authCode(error) === 'auth/user-not-found') return null;
    throw error;
  }
}

const text = (value: unknown): string => (typeof value === 'string' ? value : '');

/** Google vouches for an address only on its own mail domains, or on the Workspace domain it names in `hd`. */
function googleVouchesFor(email: string, hdClaim: unknown): boolean {
  const at = email.lastIndexOf('@');
  const domain = at > 0 ? email.slice(at + 1) : '';
  const hd = typeof hdClaim === 'string' ? hdClaim.toLowerCase() : '';
  return GOOGLE_MAIL_DOMAINS.has(domain) || (hd !== '' && hd === domain);
}

/**
 * A cheap local look at the ID token before any budget is spent: the payload is read without
 * checking the signature (tokeninfo still does that) and must name this client, a Google issuer, a
 * future expiry and an address Google vouches for. It only keeps junk away from the budgets.
 */
function plausibleIdToken(idToken: string, clientId: string, now: number): boolean {
  const parts = idToken.split('.');
  if (parts.length !== 3) return false;
  let payload: unknown;
  try {
    payload = JSON.parse(Buffer.from(parts[1]!, 'base64url').toString('utf8'));
  } catch {
    return false;
  }
  if (typeof payload !== 'object' || payload === null || Array.isArray(payload)) return false;
  const claims = payload as Record<string, unknown>;
  const exp = typeof claims.exp === 'number' || typeof claims.exp === 'string' ? Number(claims.exp) * 1000 : NaN;
  const email = text(claims.email).trim().toLowerCase();
  return claims.aud === clientId && GOOGLE_ISSUERS.has(text(claims.iss)) && exp > now &&
    email !== '' && googleVouchesFor(email, claims.hd);
}

/** The verified Google identity in an ID token, or a refusal. */
async function verifiedIdentity(idToken: string, deps: GoogleSignInDeps, now: number):
  Promise<{sub: string; email: string}> {
  let reply: TokenInfoReply;
  try {
    reply = await deps.fetchTokenInfo(idToken);
  } catch {
    // Nothing from the error is logged: it could carry the request address, which holds the token.
    logger.warn('Google token check failed');
    throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  }
  if (reply.status >= 429) throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  const info = reply.body;
  if (reply.status !== 200 || typeof info !== 'object' || info === null || Array.isArray(info)) {
    throw new HttpsError('permission-denied', NOT_VERIFIED);
  }
  const claims = info as Record<string, unknown>;
  const expiresAt = Number(text(claims.exp)) * 1000;
  const sub = text(claims.sub);
  const email = text(claims.email).trim().toLowerCase();
  // Any other verified address could belong to a mail host that someone else controls.
  if (!googleVouchesFor(email, claims.hd) || claims.aud !== deps.clientId || !GOOGLE_ISSUERS.has(text(claims.iss)) ||
      claims.email_verified !== 'true' || !(expiresAt > now) || !sub || !email) {
    throw new HttpsError('permission-denied', NOT_VERIFIED);
  }
  return {sub, email};
}

export async function checkGoogleSignIn(request: Req, deps: GoogleSignInDeps): Promise<{token: string}> {
  const uid = assertCaller(request);
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'googleExchange', EXCHANGES_PER_CALLER, EXCHANGE_WINDOW_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const data: unknown = request.data;
  const keys = typeof data === 'object' && data !== null && !Array.isArray(data) ? Object.keys(data) : [];
  const idToken = keys.length === 1 ? (data as {idToken?: unknown}).idToken : undefined;
  if (typeof idToken !== 'string' || idToken.length === 0 || idToken.length > MAX_TOKEN_CHARS) {
    throw new HttpsError('invalid-argument', 'Google sign-in needs one ID token.');
  }
  if (!deps.clientId) throw new HttpsError('failed-precondition', 'Google sign-in is not configured.');

  // Both budgets are spent before Google is asked, and only by calls that would ask: a token that
  // is plainly junk is refused first and costs nothing.
  const at = (deps.now ?? Date.now)();
  if (!plausibleIdToken(idToken, deps.clientId, at)) throw new HttpsError('permission-denied', NOT_VERIFIED);
  if (!await allowIp(deps.db, deps.key, clientBucket(request), at)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  if (!await takeDailyPlace(deps.db, deps.dailyCap ?? EXCHANGES_PER_DAY, at)) {
    logger.warn('Google sign-in: the daily budget of verifications is spent.');
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const {sub, email} = await verifiedIdentity(idToken, deps, at);

  // A new address never needs this path: Firebase signs it in directly.
  let user = await userOrNull(() => deps.auth.getUserByEmail(email));
  // The caller has just proved they own the address, so an unverified password-only account on it is
  // a squatter's. It is replaced, and the address is then new: the answer is the one for a new
  // address, and the client's next Google sign-in goes to Firebase directly and makes the account.
  if (user && isSquatter(user)) {
    await replaceSquatter(deps.db, deps.auth, user, deps.purge);
    user = null;
  }
  if (!user) throw new HttpsError('permission-denied', NOT_VERIFIED);
  await assertSignInTargetActive(deps.db, user.uid, uid);
  // An existing account is never modified beyond the Google link. A disabled account, or an
  // unverified one that holds another provider as well as a password, is refused.
  if (user.disabled || !user.emailVerified) throw new HttpsError('permission-denied', CANNOT_SIGN_IN);
  if (text(user.email).trim().toLowerCase() !== email) throw new HttpsError('permission-denied', NOT_VERIFIED);

  const holder = await userOrNull(() => deps.auth.getUserByProviderUid('google.com', sub));
  if (holder && holder.uid !== user.uid) throw new HttpsError('permission-denied', NOT_VERIFIED);
  const linked = user.providerData.find(provider => provider.providerId === 'google.com');
  // The same address behind a different Google identity is not the same person.
  if (linked && linked.uid !== sub) throw new HttpsError('permission-denied', NOT_VERIFIED);
  if (!linked) {
    try {
      await deps.auth.updateUser(user.uid, {providerToLink: {providerId: 'google.com', uid: sub, email}});
    } catch (error) {
      // Another sign-in linked this Google identity first.
      if (authCode(error) === 'auth/uid-already-exists' || authCode(error) === 'auth/email-already-exists') {
        throw new HttpsError('permission-denied', NOT_VERIFIED);
      }
      throw error;
    }
  }

  try {
    return {token: await deps.auth.createCustomToken(user.uid)};
  } catch (error) {
    // Usually the runtime service account lacks the Service Account Token Creator role.
    logger.error('Could not create a custom token', {message: error instanceof Error ? error.message : 'unknown'});
    throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  }
}

export const exchangeGoogleSignIn = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey]}, timed('exchangeGoogleSignIn', request => {
  assertFreshAppCheck(request);
  return checkGoogleSignIn(request, {auth: getAuth(), db: getFirestore(), key: signInKey(), clientId: googleWebClientId.value(),
    fetchTokenInfo: fetchGoogleTokenInfo});
}));
