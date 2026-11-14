import {assertSignInTargetActive} from './_accountAccess.js';
import {createHash, createHmac, randomBytes, randomInt, timingSafeEqual} from 'node:crypto';
import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {defineInt, defineSecret} from 'firebase-functions/params';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {clientBucket} from './_clientAddress.js';
import {allowAtMost} from './_limits.js';
import {canonicalEmail} from './_email.js';
import {phDay} from './_phDate.js';
import {guardianMailFrom, guardianMailKey} from './guardianConsent.js';
import {mailerFor, type GuardianMailer, type GuardianMessage} from './guardianMail.js';
import {isSquatter, replaceSquatter, type SquatterAuth} from './_squatter.js';
import {timed} from './_timed.js';

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
/** A challenge is useless once its code has expired. `purgeAt` (the TTL field) leaves a day of margin. */
const CHALLENGE_PURGE_MS = CODE_TTL_MS + 24 * 3_600_000;
export const RESEND_COOLDOWN_MS = 60_000;
export const SENDS_PER_EMAIL_PER_HOUR = 5;
export const SENDS_PER_CALLER_PER_HOUR = 10;
export const MAX_WRONG_TRIES = 5;
export const VERIFIES_PER_CALLER = 30;
export const SENDS_PER_IP_PER_HOUR = 10;
/** Most codes mailed to one mailbox per Philippine day, however many people ask for it. */
export const SENDS_PER_MAILBOX_PER_DAY = 10;
/** Challenges for one mailbox that may reach the too-many-tries state in a Philippine day before sends stop. */
export const LOCKED_CHALLENGES_PER_MAILBOX_PER_DAY = 3;
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
  /** The secret code of a stand-in challenge: a whole number from 0 up to 999999. Never mailed. */
  standInCode?: () => number;
  /** A new random 128-bit challenge id as 32 hex characters. */
  challengeId?: () => string;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
  /** Finds an existing account by address, so a returning user draws on the reserved bucket. */
  auth?: Pick<Auth, 'getUserByEmail'>;
  /** Daily caps: the open bucket for everyone, the reserved one for selected beta applicants and existing accounts. */
  openCap?: number;
  reservedCap?: number;
  alert?: (message: string) => void;
  /** Waits on a held-back send so it takes about as long as a real one. */
  pad?: () => Promise<void>;
};

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'> & {
  rawRequest?: {ip?: string; headers?: Record<string, string | string[] | undefined>};
};

function assertCaller(request: Req): string {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  return request.auth.uid;
}

/**
 * One hour window per client address bucket (see `clientBucket`), kept as a keyed hash so the address
 * itself is never stored. Anonymous accounts are free to make, so the per-user limit alone cannot stop
 * one machine.
 */
async function allowIp(db: Firestore, key: string, bucket: string, at: number): Promise<boolean> {
  const ref = db.doc(`signInLimits/ip-${createHmac('sha256', key).update(`ip\0${bucket}`).digest('hex')}`);
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
 * An address on a selected beta application, or one that already belongs to a verified, enabled
 * account, draws on the reserved daily bucket. Strangers filling the open bucket then cannot block
 * returning users. Both lookups always run, so the time taken does not show which one matched, and
 * callers never see which bucket they used: the reply is the same for both.
 */
async function reservedBucket(deps: RequestDeps, email: string): Promise<boolean> {
  const betaTester = async (): Promise<boolean> => {
    const applications = await deps.db.collection('betaApplications').where('email', '==', email).get();
    return applications.docs.some(application => application.get('selected') === true);
  };
  const returningUser = async (): Promise<boolean> => {
    if (!deps.auth) return false;
    try {
      const user = await deps.auth.getUserByEmail(email);
      return user.emailVerified === true && user.disabled !== true;
    } catch (error) {
      if ((error as {code?: string} | null)?.code === 'auth/user-not-found') return false;
      throw error;
    }
  };
  const [beta, returning] = await Promise.all([betaTester(), returningUser()].map(lookup => lookup.catch((error: unknown) => {
    logger.warn('Sign-in bucket lookup failed', {message: error instanceof Error ? error.message : 'unknown'});
    return false;
  })));
  return beta || returning;
}

type Suppressed = 'cooldown' | 'hourlyCap' | 'dailyCap' | 'mailboxDailyCap' | 'mailboxLocked';
type Slot =
  | {kind: 'cached'; seconds: number; challengeId: string}
  | {kind: 'suppressed'; reason: Suppressed; firstFull: boolean}
  | {kind: 'stored'; becameFull: boolean};

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

  // The caller can choose the left of X-Forwarded-For, so only its right-most entry counts. A call
  // with no address falls into one shared bucket: a missing address never skips the limit.
  if (!await allowIp(deps.db, deps.key, clientBucket(request), now())) {
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
  // One entry per caller and mailbox, so asking again returns the same challenge and the true wait.
  const cacheRef = deps.db.doc(`signInRequests/${createHash('sha256').update(`${uid}:${emailKey}`).digest('hex')}`);
  const challengeRef = deps.db.doc(challengePath(challengeId));
  const at = now();
  const day = phDay(at);
  const dayRef = deps.db.doc(`signInLimits/global-${bucket}-${day}`);
  // Counts for one mailbox over one Philippine day: codes mailed, and challenges that ran out of tries.
  const mailboxDayRef = deps.db.doc(mailboxDayPath(emailKey, day));

  // Whatever the recipient's state, the caller sees a real-looking send. When delivery is held back
  // for a reason that depends on the recipient, a challenge with no code stands in for it, so the
  // reply cannot be used to learn who is signed up, selected, or recently emailed.
  const slot = await deps.db.runTransaction<Slot>(async transaction => {
    const [cached, snapshot, dayDoc, mailboxDay] = await Promise.all(
      [transaction.get(cacheRef), transaction.get(limitRef), transaction.get(dayRef), transaction.get(mailboxDayRef)]);
    const askedAt = millis(cached.get('sentAt'));
    const askedId: unknown = cached.get('challengeId');
    if (askedAt > 0 && typeof askedId === 'string' && at - askedAt < RESEND_COOLDOWN_MS) {
      const left = Math.min(RESEND_COOLDOWN_MS, RESEND_COOLDOWN_MS - Math.max(at - askedAt, 0));
      return {kind: 'cached', seconds: Math.ceil(left / 1000), challengeId: askedId};
    }
    transaction.set(cacheRef, {challengeId, sentAt: at, purgeAt: new Date(at + 2 * HOUR_MS)});
    // A stand-in has a secret code that nobody is sent. It behaves like a real challenge for wrong
    // guesses, lockout and expiry, and even its own code never signs anyone in.
    const decoy = (reason: Suppressed, firstFull = false): Slot => {
      const secret = String((deps.standInCode ?? (() => randomInt(0, 1_000_000)))()).padStart(6, '0');
      transaction.set(challengeRef, {emailKey, email, codeHash: hashCode(deps.key, email, secret), standIn: true,
        requesterUid: uid, attempts: 0, expiresAt: new Date(at + CODE_TTL_MS),
        purgeAt: new Date(at + CHALLENGE_PURGE_MS)});
      return {kind: 'suppressed', reason, firstFull};
    };
    const sentAt = millis(snapshot.get('sentAt'));
    if (sentAt > 0 && at - sentAt < RESEND_COOLDOWN_MS) return decoy('cooldown');
    const windowStartedAt = millis(snapshot.get('windowStartedAt'));
    const inWindow = windowStartedAt > 0 && at - windowStartedAt < HOUR_MS;
    const sendCount = inWindow ? Number(snapshot.get('sendCount') ?? 0) : 0;
    if (sendCount >= SENDS_PER_EMAIL_PER_HOUR) return decoy('hourlyCap');
    // These two depend on the recipient too, so they look like every other held-back send.
    if (Number(mailboxDay.get('locked') ?? 0) >= LOCKED_CHALLENGES_PER_MAILBOX_PER_DAY) return decoy('mailboxLocked');
    if (Number(mailboxDay.get('sent') ?? 0) >= SENDS_PER_MAILBOX_PER_DAY) return decoy('mailboxDailyCap');
    const sentToday = Number(dayDoc.get('count') ?? 0);
    if (!Number.isFinite(cap) || cap < 1 || sentToday + 1 > cap) {
      const firstFull = dayDoc.get('fullLogged') !== true;
      // A day document made only by this write still needs its TTL field.
      if (firstFull) transaction.set(dayRef, {fullLogged: true, purgeAt: new Date(at + 3 * 24 * HOUR_MS)}, {merge: true});
      return decoy('dailyCap', firstFull);
    }
    // The send that reaches the cap is the moment the bucket becomes full, and the one that logs it.
    const becameFull = sentToday + 1 >= cap && dayDoc.get('fullLogged') !== true;
    transaction.set(dayRef, {count: sentToday + 1, purgeAt: new Date(at + 3 * 24 * HOUR_MS),
      ...(becameFull ? {fullLogged: true} : {})}, {merge: true});
    transaction.set(mailboxDayRef, {sent: Number(mailboxDay.get('sent') ?? 0) + 1,
      purgeAt: new Date(at + 3 * 24 * HOUR_MS)}, {merge: true});
    const threshold = Math.ceil(cap * 0.8);
    if (sentToday < threshold && sentToday + 1 >= threshold) {
      (deps.alert ?? ((m: string) => console.error(m)))(
        `Sign-in emails (${bucket} bucket) reached 80% of the daily cap (${sentToday + 1} of ${cap}).`);
    }
    transaction.set(challengeRef, {
      emailKey, email, codeHash, requesterUid: uid, attempts: 0,
      expiresAt: new Date(at + CODE_TTL_MS),
      // The field for the Firestore TTL policy on this collection.
      purgeAt: new Date(at + CHALLENGE_PURGE_MS),
    });
    transaction.set(limitRef, {
      sentAt: at,
      windowStartedAt: inWindow ? windowStartedAt : at,
      sendCount: sendCount + 1,
      open: [...openList(snapshot.get('open')).filter(row => row.exp > at), {id: challengeId, exp: at + CODE_TTL_MS}],
      purgeAt: new Date(at + 2 * HOUR_MS),
    });
    return {kind: 'stored', becameFull};
  });

  if (slot.kind === 'cached') return {challengeId: slot.challengeId, resendAfterSeconds: slot.seconds};
  if (slot.kind === 'suppressed') {
    // Logged without the address: the first eight characters of the mailbox key are enough to correlate.
    logger.warn('Sign-in code held back', {reason: slot.reason, bucket, emailKey: emailKey.slice(0, 8)});
    if (slot.reason === 'dailyCap' && slot.firstFull) logFull(bucket, day, cap);
    await deps.pad?.();
    return {challengeId, resendAfterSeconds: RESEND_COOLDOWN_MS / 1000};
  }
  if (slot.becameFull) logFull(bucket, day, cap);

  try {
    await deps.mailer.send(signInCodeMessage({to: email, code}));
  } catch (error) {
    logger.warn('Sign-in code email failed', {message: error instanceof Error ? error.message : 'unknown'});
    await dropChallenge(deps.db, limitRef, challengeRef, challengeId, dayRef, cacheRef);
    throw new HttpsError('unavailable', 'We could not send the email. Try again soon.');
  }
  return {challengeId, resendAfterSeconds: RESEND_COOLDOWN_MS / 1000};
}

/**
 * One ERROR line the first time a daily bucket is full, for a log-based alert. Match on the field
 * `event="mail_cap_full"`, or on the text `Mail cap full: sign-in`. (The logger puts `Error: ` and a
 * stack trace around an ERROR message, so match on a substring, not the start.)
 */
function logFull(bucket: 'open' | 'reserved', day: string, cap: number): void {
  logger.error(`Mail cap full: sign-in ${bucket} bucket, ${day}.`, {event: 'mail_cap_full', bucket, day, cap});
}

const mailboxDayPath = (emailKey: string, day: string): string => `signInLimits/mailbox-${emailKey}-${day}`;

/** Delete the challenge this call made. The send counters stay, but the cap place goes back. */
async function dropChallenge(db: Firestore, limitRef: ReturnType<Firestore['doc']>,
  challengeRef: ReturnType<Firestore['doc']>, challengeId: string, dayRef: ReturnType<Firestore['doc']>,
  cacheRef: ReturnType<Firestore['doc']>): Promise<void> {
  await db.runTransaction(async transaction => {
    const [limit, day] = await Promise.all([transaction.get(limitRef), transaction.get(dayRef)]);
    transaction.delete(challengeRef);
    transaction.delete(cacheRef);
    transaction.set(limitRef, {open: openList(limit.get('open')).filter(row => row.id !== challengeId)}, {merge: true});
    const sentToday = Number(day.get('count') ?? 0);
    if (sentToday > 0) transaction.set(dayRef, {count: sentToday - 1}, {merge: true});
  });
}

// ----------------------------------------------------------------- verify

export type VerifyDeps = {
  db: Firestore;
  auth: Pick<Auth, 'getUserByEmail' | 'createUser' | 'createCustomToken'> & SquatterAuth;
  key: string;
  now?: () => number;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
  /** Deletes a replaced squatter and its data. Defaults to the account deletion path; tests stand in for it. */
  purge?: (uid: string) => Promise<void>;
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

const CANNOT_SIGN_IN = "This account can't sign in. Write to support@pantas.study.";

/**
 * The uid to sign in as: the account that already has this address, or a new one. The caller's
 * own (anonymous) uid is never reused, so the client switches accounts. The caller has just proved
 * they own the address, so an unverified account that only holds a password is a squatter, made by
 * someone who registered the address through Identity Toolkit. It is replaced (see `replaceSquatter`)
 * and the address then gets a new verified account. Any other existing account is never modified:
 * a verified one is signed in, and a disabled one, or an unverified one with another provider, is refused.
 */
async function accountFor(email: string, deps: VerifyDeps): Promise<string> {
  const {auth} = deps;
  // Two sign-ins can race, and the squatter can register again between our delete and our create.
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const user = await findUser(auth, email);
    if (user) {
      if (!isSquatter(user)) {
        if (user.disabled || !user.emailVerified) throw new HttpsError('permission-denied', CANNOT_SIGN_IN);
        return user.uid;
      }
      await replaceSquatter(deps.db, auth, user, deps.purge);
    }
    try {
      return (await auth.createUser({email, emailVerified: true})).uid;
    } catch (error) {
      // Another sign-in created it first, or the address was registered again. Look again.
      if (authCode(error) !== 'auth/email-already-exists') throw error;
    }
  }
  throw new HttpsError('permission-denied', CANNOT_SIGN_IN);
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
    // A stand-in can never succeed, even with its own secret code: that counts as a wrong guess.
    const matches = sameHash(stored, hashCode(deps.key, email, code));
    if (matches && snapshot.get('standIn') !== true) {
      // Read the list of open challenges before writing, then close every one of them.
      const limitRef = deps.db.doc(`signInCodes/${emailKey}`);
      const open = openList((await transaction.get(limitRef)).get('open'));
      transaction.delete(ref);
      for (const row of open) if (row.id !== data.challengeId) transaction.delete(deps.db.doc(challengePath(row.id)));
      transaction.set(limitRef, {open: []}, {merge: true});
      return {kind: 'ok', email};
    }
    const next = attempts + 1;
    if (next === MAX_WRONG_TRIES) {
      // This challenge has now run out of tries. Enough of them in one day hold back the mailbox.
      const mailboxDayRef = deps.db.doc(mailboxDayPath(emailKey, phDay(now())));
      const locked = Number((await transaction.get(mailboxDayRef)).get('locked') ?? 0);
      transaction.set(mailboxDayRef, {locked: locked + 1, purgeAt: new Date(now() + 3 * 24 * HOUR_MS)}, {merge: true});
    }
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

  const accountUid = await accountFor(outcome.email, deps);
  await assertSignInTargetActive(deps.db, accountUid, uid);
  try {
    return {token: await deps.auth.createCustomToken(accountUid)};
  } catch (error) {
    // Usually the runtime service account lacks the Service Account Token Creator role.
    logger.error('Could not create a custom token', {message: error instanceof Error ? error.message : 'unknown'});
    throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  }
}

// ------------------------------------------------------------- deployment

export function key(): string {
  const emulator = process.env.FUNCTIONS_EMULATOR === 'true';
  const value = signInCodeKey.value() || (emulator ? 'sign-in-code-emulator-only-key' : '');
  if (!value) throw new HttpsError('failed-precondition', 'Sign-in codes are not configured.');
  return value;
}

export const requestSignInCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey, guardianMailKey]}, timed('requestSignInCode', request => {
  assertFreshAppCheck(request);
  return sendSignInCode(request, {db: getFirestore(), auth: getAuth(), key: key(),
    openCap: signInOpenCap.value(), reservedCap: signInReservedCap.value(),
    // A held-back send skips the mail provider; match its usual 250 to 700 ms.
    pad: () => new Promise(resolve => setTimeout(resolve, 250 + randomInt(0, 450))),
    mailer: {send: message => mailerFor(process.env,
      {apiKey: () => guardianMailKey.value(), from: () => guardianMailFrom.value()}).send(message)}});
}));

export const verifySignInCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey]}, timed('verifySignInCode', request => {
  assertFreshAppCheck(request);
  return checkSignInCode(request, {db: getFirestore(), auth: getAuth(), key: key()});
}));
