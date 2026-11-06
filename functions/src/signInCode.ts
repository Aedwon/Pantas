import {createHash, createHmac, randomBytes, randomInt, timingSafeEqual} from 'node:crypto';
import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {defineInt, defineSecret} from 'firebase-functions/params';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {canonicalEmail} from './_email.js';
import {phDay} from './_phDate.js';
import {guardianMailFrom, guardianMailKey} from './guardianConsent.js';
import {mailerFor, type GuardianMailer, type GuardianMessage} from './guardianMail.js';

/**
 * Email code sign-in for the web beta. Firebase Auth has no email one-time code,
 * so two callables do it: one mails a six-digit code, the other checks it and
 * returns a custom token for the client to sign in with.
 *
 * Every request makes its own challenge (`signInChallenges/{id}`) with a random id that only the
 * requesting user can verify, so other people's requests and guesses cannot spoil it. The code is
 * stored only as a keyed hash. The per-mailbox document (`signInCodes/{hash of the canonical
 * address}`) holds only the send limits and the list of open challenges.
 */

export const signInCodeKey = defineSecret('SIGN_IN_CODE_KEY');
/**
 * Most sign-in emails per Philippine day, in two buckets so strangers cannot use up the places that
 * selected beta testers and existing accounts need. Resend Free allows 100 a day across all mail.
 */
export const signInOpenCap = defineInt('SIGN_IN_DAILY_SEND_CAP', {default: 60});
export const signInReservedCap = defineInt('SIGN_IN_DAILY_RESERVED_CAP', {default: 40});

export const CODE_TTL_MS = 10 * 60_000;
export const RESEND_COOLDOWN_MS = 60_000;
export const SENDS_PER_EMAIL_PER_HOUR = 5;
export const SENDS_PER_CALLER_PER_HOUR = 10;
export const MAX_WRONG_TRIES = 5;
export const VERIFIES_PER_CALLER = 30;
export const SENDS_PER_IP_PER_HOUR = 10;
const HOUR_MS = 3_600_000;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

export function normalizeEmail(value: unknown): string {
  const email = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (!email || email.length > 254 || !EMAIL_PATTERN.test(email)) {
    throw new HttpsError('invalid-argument', 'Enter a valid email address.');
  }
  return email;
}

/** One document per mailbox: aliases such as `a+x@` and `a.b@gmail.com` share it, and so share its limits. */
export const codeDocId = (email: string): string => createHash('sha256').update(canonicalEmail(email)).digest('hex');
export const hashCode = (key: string, email: string, code: string): string =>
  createHmac('sha256', key).update(`${email}:${code}`).digest('hex');

const millis = (value: unknown): number => {
  if (typeof value === 'number') return value;
  if (value instanceof Date) return value.getTime();
  const toMillis = (value as {toMillis?: unknown} | null | undefined)?.toMillis;
  return typeof toMillis === 'function' ? Number(toMillis.call(value)) : 0;
};

const escapeHtml = (value: string): string =>
  value.replace(/[&<>"']/g, c => (
    {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c] as string));

const ink = '#1D1D1F';
const muted = '#6E6E73';
const accent = '#0B7A68';
const font = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

/** The sign-in code email. Every dynamic value is escaped before it enters the markup. */
export function signInCodeMessage(input: {to: string; code: string}): GuardianMessage {
  const heading = 'Your sign-in code';
  const note = "It expires in 10 minutes. If you didn't try to sign in to Pantas, ignore this email.";
  const text = [heading, input.code, note].join('\n\n');
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"></head>` +
    `<body style="margin:0;padding:24px 16px;background:#FFFFFF;color:${ink};font-family:${font}">` +
    `<div style="max-width:560px;margin:0 auto">` +
    `<h1 style="margin:0 0 20px;font-size:24px;line-height:1.25;color:${ink}">${escapeHtml(heading)}</h1>` +
    `<p style="margin:0 0 24px;font-size:36px;line-height:1.2;font-weight:700;letter-spacing:8px;color:${accent}">${escapeHtml(input.code)}</p>` +
    `<p style="margin:0;font-size:14px;line-height:1.6;color:${muted}">${escapeHtml(note)}</p>` +
    `</div></body></html>`;
  return {to: input.to, subject: `${input.code} is your Pantas sign-in code`, text, html};
}

// ---------------------------------------------------------------- request

export type RequestDeps = {
  db: Firestore;
  key: string;
  mailer: GuardianMailer;
  now?: () => number;
  /** A whole number from 0 up to 999999. */
  random?: () => number;
  /** A new random 128-bit challenge id as 32 hex characters. */
  challengeId?: () => string;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
  /** Used to tell an existing account from a stranger, for the reserved daily bucket. */
  auth: Pick<Auth, 'getUserByEmail'>;
  /** Daily caps: the open bucket for strangers, the reserved one for beta testers and existing accounts. */
  openCap?: number;
  reservedCap?: number;
  alert?: (message: string) => void;
};

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'> & {rawRequest?: {ip?: string}};

function assertCaller(request: Req): string {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  return request.auth.uid;
}

/**
 * One hour window per caller IP, kept as a keyed hash so the address itself is never stored.
 * Anonymous accounts are free to make, so the per-user limit alone cannot stop one machine.
 */
async function allowIp(db: Firestore, key: string, ip: string, at: number): Promise<boolean> {
  const ref = db.doc(`signInLimits/ip-${createHmac('sha256', key).update(`ip\0${ip}`).digest('hex')}`);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    const startedAt = millis(snapshot.get('windowStartedAt'));
    const inWindow = startedAt > 0 && at - startedAt < HOUR_MS;
    const count = inWindow ? Number(snapshot.get('count') ?? 0) : 0;
    if (count >= SENDS_PER_IP_PER_HOUR) return false;
    transaction.set(ref, {windowStartedAt: inWindow ? startedAt : at, count: count + 1,
      purgeAt: new Date(at + 2 * HOUR_MS)});
    return true;
  });
}

/**
 * Selected beta applicants and existing accounts draw on the reserved daily bucket. Callers never see
 * which bucket they used: the reply and the cap-hit error are the same for both.
 */
async function reservedBucket(deps: RequestDeps, email: string): Promise<boolean> {
  try {
    const applications = await deps.db.collection('betaApplications').where('email', '==', email).get();
    if (applications.docs.some(application => application.get('selected') === true)) return true;
    await deps.auth.getUserByEmail(email);
    return true;
  } catch (error) {
    if (authCode(error) !== 'auth/user-not-found') {
      logger.warn('Sign-in bucket lookup failed', {message: error instanceof Error ? error.message : 'unknown'});
    }
    return false;
  }
}

type Slot =
  | {kind: 'cooldown'; seconds: number; challengeId?: string}
  | {kind: 'capped'} | {kind: 'busy'} | {kind: 'stored'};

type Open = {id: string; exp: number};
const openList = (value: unknown): Open[] => (Array.isArray(value) ? value : [])
  .filter((row): row is Open => typeof row?.id === 'string' && typeof row?.exp === 'number');

const challengePath = (id: string): string => `signInChallenges/${id}`;
const CHALLENGE_ID = /^[0-9a-f]{32}$/;

/**
 * Each request makes its own challenge, so another person's request or wrong guesses cannot spoil
 * yours. The per-mailbox document keeps only the limits and the list of open challenges.
 */
export async function sendSignInCode(request: Req, deps: RequestDeps):
  Promise<{challengeId?: string; resendAfterSeconds: number}> {
  const uid = assertCaller(request);
  const email = normalizeEmail((request.data as {email?: unknown} | undefined)?.email);
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'signInCodeSend', SENDS_PER_CALLER_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many codes requested. Try again later.');
  }

  const ip = request.rawRequest?.ip;
  if (ip && !await allowIp(deps.db, deps.key, ip, now())) {
    throw new HttpsError('resource-exhausted', 'Too many codes requested. Try again later.');
  }

  const reserved = await reservedBucket(deps, email);
  const cap = (reserved ? deps.reservedCap : deps.openCap) ?? (reserved ? 40 : 60);
  const bucket = reserved ? 'reserved' : 'open';
  const code = String((deps.random ?? (() => randomInt(0, 1_000_000)))()).padStart(6, '0');
  const codeHash = hashCode(deps.key, email, code);
  const emailKey = codeDocId(email);
  const challengeId = (deps.challengeId ?? (() => randomBytes(16).toString('hex')))();
  const limitRef = deps.db.doc(`signInCodes/${emailKey}`);
  const challengeRef = deps.db.doc(challengePath(challengeId));
  const at = now();
  const dayRef = deps.db.doc(`signInLimits/global-${bucket}-${phDay(at)}`);

  const slot = await deps.db.runTransaction<Slot>(async transaction => {
    const [snapshot, day] = await Promise.all([transaction.get(limitRef), transaction.get(dayRef)]);
    const sentAt = millis(snapshot.get('sentAt'));
    if (sentAt > 0) {
      const elapsed = at - sentAt;
      if (elapsed < RESEND_COOLDOWN_MS) {
        const left = Math.min(RESEND_COOLDOWN_MS, RESEND_COOLDOWN_MS - Math.max(elapsed, 0));
        // Only the person who asked for the latest code is told its challenge.
        const latest: unknown = snapshot.get('lastChallengeId');
        const mine = snapshot.get('lastRequesterUid') === uid && typeof latest === 'string';
        return {kind: 'cooldown', seconds: Math.ceil(left / 1000), ...(mine ? {challengeId: latest as string} : {})};
      }
    }
    const windowStartedAt = millis(snapshot.get('windowStartedAt'));
    const inWindow = windowStartedAt > 0 && at - windowStartedAt < HOUR_MS;
    const sendCount = inWindow ? Number(snapshot.get('sendCount') ?? 0) : 0;
    if (sendCount >= SENDS_PER_EMAIL_PER_HOUR) return {kind: 'capped'};
    const sentToday = Number(day.get('count') ?? 0);
    if (!Number.isFinite(cap) || cap < 1 || sentToday + 1 > cap) return {kind: 'busy'};
    transaction.set(dayRef, {count: sentToday + 1, purgeAt: new Date(at + 3 * 24 * HOUR_MS)});
    const threshold = Math.ceil(cap * 0.8);
    if (sentToday < threshold && sentToday + 1 >= threshold) {
      (deps.alert ?? ((m: string) => console.error(m)))(
        `Sign-in emails (${bucket} bucket) reached 80% of the daily cap (${sentToday + 1} of ${cap}).`);
    }
    transaction.set(challengeRef, {
      emailKey, email, codeHash, requesterUid: uid, attempts: 0,
      // Also the field for an optional Firestore TTL policy.
      expiresAt: new Date(at + CODE_TTL_MS),
    });
    transaction.set(limitRef, {
      sentAt: at,
      windowStartedAt: inWindow ? windowStartedAt : at,
      sendCount: sendCount + 1,
      lastChallengeId: challengeId,
      lastRequesterUid: uid,
      open: [...openList(snapshot.get('open')).filter(row => row.exp > at), {id: challengeId, exp: at + CODE_TTL_MS}],
      purgeAt: new Date(at + 2 * HOUR_MS),
    });
    return {kind: 'stored'};
  });

  if (slot.kind === 'capped') {
    throw new HttpsError('resource-exhausted', 'Too many codes for this email. Try again later.');
  }
  if (slot.kind === 'busy') {
    throw new HttpsError('resource-exhausted', 'Sign-in emails are busy right now. Try again later.');
  }
  if (slot.kind === 'cooldown') {
    return {...(slot.challengeId ? {challengeId: slot.challengeId} : {}), resendAfterSeconds: slot.seconds};
  }

  try {
    await deps.mailer.send(signInCodeMessage({to: email, code}));
  } catch (error) {
    logger.warn('Sign-in code email failed', {message: error instanceof Error ? error.message : 'unknown'});
    await dropChallenge(deps.db, limitRef, challengeRef, challengeId, dayRef);
    throw new HttpsError('unavailable', 'We could not send the email. Try again soon.');
  }
  return {challengeId, resendAfterSeconds: RESEND_COOLDOWN_MS / 1000};
}

/** Delete the challenge this call made. The send counters stay, but the cap place goes back. */
async function dropChallenge(db: Firestore, limitRef: ReturnType<Firestore['doc']>,
  challengeRef: ReturnType<Firestore['doc']>, challengeId: string, dayRef: ReturnType<Firestore['doc']>): Promise<void> {
  await db.runTransaction(async transaction => {
    const [limit, day] = await Promise.all([transaction.get(limitRef), transaction.get(dayRef)]);
    transaction.delete(challengeRef);
    transaction.set(limitRef, {
      open: openList(limit.get('open')).filter(row => row.id !== challengeId),
      ...(limit.get('lastChallengeId') === challengeId ? {lastChallengeId: null, lastRequesterUid: null} : {}),
    }, {merge: true});
    const sentToday = Number(day.get('count') ?? 0);
    if (sentToday > 0) transaction.set(dayRef, {count: sentToday - 1}, {merge: true});
  });
}

// ----------------------------------------------------------------- verify

export type VerifyDeps = {
  db: Firestore;
  auth: Pick<Auth, 'getUser' | 'getUserByEmail' | 'createUser' | 'updateUser' | 'createCustomToken' | 'revokeRefreshTokens'>;
  key: string;
  now?: () => number;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
};

type Outcome =
  | {kind: 'ok'; email: string}
  | {kind: 'expired'}
  | {kind: 'tooManyTries'}
  | {kind: 'wrong'; triesLeft: number};

const sameHash = (stored: string, given: string): boolean => {
  const a = Buffer.from(stored, 'hex');
  const b = Buffer.from(given, 'hex');
  return a.length === 32 && a.length === b.length && timingSafeEqual(a, b);
};

const authCode = (error: unknown): string | undefined => (error as {code?: string} | null)?.code;

async function findUser(auth: VerifyDeps['auth'], email: string): Promise<UserRecord | null> {
  try {
    return await auth.getUserByEmail(email);
  } catch (error) {
    if (authCode(error) === 'auth/user-not-found') return null;
    throw error;
  }
}

/**
 * An anonymous ID token can outlive the anonymous user: the same uid may have gained an email or a
 * provider since. Upgrade in place only if the record is still truly anonymous, and only once per uid.
 */
async function upgradableAnonymous(request: Req, deps: VerifyDeps, at: number): Promise<boolean> {
  if (request.auth?.token.firebase?.sign_in_provider !== 'anonymous') return false;
  const uid = request.auth.uid;
  let record: UserRecord;
  try {
    record = await deps.auth.getUser(uid);
  } catch (error) {
    if (authCode(error) === 'auth/user-not-found') return false;
    throw error;
  }
  if (record.email || record.phoneNumber || record.disabled || (record.providerData ?? []).length > 0) return false;
  const lock = deps.db.doc(`signInUpgrades/${uid}`);
  return deps.db.runTransaction(async transaction => {
    if ((await transaction.get(lock)).exists) return false;
    transaction.set(lock, {createdAt: at, purgeAt: new Date(at + 24 * HOUR_MS)});
    return true;
  });
}

async function accountFor(request: Req, email: string, deps: VerifyDeps, at: number): Promise<string> {
  const auth = deps.auth;
  let user = await findUser(auth, email);
  if (!user && await upgradableAnonymous(request, deps, at)) {
    // Upgrade the caller's anonymous user in place, so its uid and data are kept.
    const uid = request.auth!.uid;
    try {
      await auth.updateUser(uid, {email, emailVerified: true});
      return uid;
    } catch (error) {
      // Let a later attempt try again unless another account took the address.
      const code = authCode(error);
      if (code !== 'auth/email-already-exists') await deps.db.doc(`signInUpgrades/${uid}`).delete();
      if (code === 'auth/email-already-exists') user = await findUser(auth, email);
      else if (code !== 'auth/user-not-found') throw error;
    }
  }
  if (user) {
    if (user.disabled) throw new HttpsError('permission-denied', 'This account is disabled.');
    if (!user.emailVerified) {
      // Anyone could have registered this address with a password before its owner proved it.
      // Drop that password and every session it opened, then mark the address verified.
      const unlink = (user.providerData ?? []).some(info => info.providerId === 'password');
      await auth.updateUser(user.uid, unlink ? {emailVerified: true, providersToUnlink: ['password']} : {emailVerified: true});
      await auth.revokeRefreshTokens(user.uid);
    }
    return user.uid;
  }
  return (await auth.createUser({email, emailVerified: true})).uid;
}

const expired = (): HttpsError =>
  new HttpsError('not-found', 'That code has expired. Request a new one.', {reason: 'expired'});

export async function checkSignInCode(request: Req, deps: VerifyDeps): Promise<{token: string}> {
  const uid = assertCaller(request);
  const data = (request.data ?? {}) as {challengeId?: unknown; code?: unknown};
  if (typeof data.code !== 'string' || !/^\d{6}$/.test(data.code)) {
    throw new HttpsError('invalid-argument', 'Enter the 6-digit code.');
  }
  const code = data.code;
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'signInCodeVerify', VERIFIES_PER_CALLER, 10 * 60_000)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  // A malformed id is never turned into a path. It fails like an unknown challenge.
  if (typeof data.challengeId !== 'string' || !CHALLENGE_ID.test(data.challengeId)) throw expired();

  const ref = deps.db.doc(challengePath(data.challengeId));
  const outcome = await deps.db.runTransaction<Outcome>(async transaction => {
    const snapshot = await transaction.get(ref);
    const stored: unknown = snapshot.get('codeHash');
    const email: unknown = snapshot.get('email');
    const emailKey: unknown = snapshot.get('emailKey');
    const expiresAt = millis(snapshot.get('expiresAt'));
    // Unknown, consumed and someone else's challenges all look the same.
    if (typeof stored !== 'string' || typeof email !== 'string' || typeof emailKey !== 'string' ||
        snapshot.get('requesterUid') !== uid) return {kind: 'expired'};
    if (expiresAt <= now()) {
      transaction.delete(ref);
      return {kind: 'expired'};
    }
    const attempts = Number(snapshot.get('attempts') ?? 0);
    if (attempts >= MAX_WRONG_TRIES) return {kind: 'tooManyTries'};
    if (sameHash(stored, hashCode(deps.key, email, code))) {
      // Read the list of open challenges before writing, then close every one of them.
      const limitRef = deps.db.doc(`signInCodes/${emailKey}`);
      const open = openList((await transaction.get(limitRef)).get('open'));
      transaction.delete(ref);
      for (const row of open) if (row.id !== data.challengeId) transaction.delete(deps.db.doc(challengePath(row.id)));
      transaction.set(limitRef, {open: []}, {merge: true});
      return {kind: 'ok', email};
    }
    const next = attempts + 1;
    transaction.set(ref, {attempts: next}, {merge: true});
    return {kind: 'wrong', triesLeft: MAX_WRONG_TRIES - next};
  });

  if (outcome.kind === 'expired') throw expired();
  if (outcome.kind === 'tooManyTries') {
    throw new HttpsError('resource-exhausted', 'Too many wrong tries. Request a new code.', {reason: 'tooManyTries'});
  }
  if (outcome.kind === 'wrong') {
    throw new HttpsError('invalid-argument', 'That code is not right.',
      {reason: 'wrong', triesLeft: outcome.triesLeft});
  }

  const accountUid = await accountFor(request, outcome.email, deps, now());
  try {
    return {token: await deps.auth.createCustomToken(accountUid)};
  } catch (error) {
    // Usually the runtime service account lacks the Service Account Token Creator role.
    logger.error('Could not create a custom token', {message: error instanceof Error ? error.message : 'unknown'});
    throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  }
}

// ------------------------------------------------------------- deployment

function key(): string {
  const emulator = process.env.FUNCTIONS_EMULATOR === 'true';
  const value = signInCodeKey.value() || (emulator ? 'sign-in-code-emulator-only-key' : '');
  if (!value) throw new HttpsError('failed-precondition', 'Sign-in codes are not configured.');
  return value;
}

export const requestSignInCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey, guardianMailKey]}, request => {
  assertFreshAppCheck(request);
  return sendSignInCode(request, {db: getFirestore(), auth: getAuth(), key: key(),
    openCap: signInOpenCap.value(), reservedCap: signInReservedCap.value(),
    mailer: {send: message => mailerFor(process.env,
      {apiKey: () => guardianMailKey.value(), from: () => guardianMailFrom.value()}).send(message)}});
});

export const verifySignInCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey]}, request => {
  assertFreshAppCheck(request);
  return checkSignInCode(request, {db: getFirestore(), auth: getAuth(), key: key()});
});
