import {createHash, createHmac, randomInt, timingSafeEqual} from 'node:crypto';
import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {defineInt, defineSecret} from 'firebase-functions/params';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {phDay} from './_phDate.js';
import {guardianMailFrom, guardianMailKey} from './guardianConsent.js';
import {mailerFor, type GuardianMailer, type GuardianMessage} from './guardianMail.js';

/**
 * Email code sign-in for the web beta. Firebase Auth has no email one-time code,
 * so two callables do it: one mails a six-digit code, the other checks it and
 * returns a custom token for the client to sign in with.
 *
 * The code is stored only as a keyed hash. The email address is not stored at all:
 * the document id is the hash of the address. A spent, expired or locked code is
 * blanked, not deleted, so the send counters (cooldown and hourly cap) survive it.
 */

export const signInCodeKey = defineSecret('SIGN_IN_CODE_KEY');
/** Most sign-in emails the whole service sends per Philippine day. Resend Free allows 100 a day in all. */
export const signInDailyCap = defineInt('SIGN_IN_DAILY_SEND_CAP', {default: 80});

export const CODE_TTL_MS = 10 * 60_000;
export const RESEND_COOLDOWN_MS = 60_000;
export const SENDS_PER_EMAIL_PER_HOUR = 5;
export const SENDS_PER_CALLER_PER_HOUR = 10;
export const MAX_WRONG_TRIES = 5;
export const VERIFIES_PER_CALLER = 30;
const HOUR_MS = 3_600_000;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

export function normalizeEmail(value: unknown): string {
  const email = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (!email || email.length > 254 || !EMAIL_PATTERN.test(email)) {
    throw new HttpsError('invalid-argument', 'Enter a valid email address.');
  }
  return email;
}

export const codeDocId = (email: string): string => createHash('sha256').update(email).digest('hex');
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
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
  /** Most emails the whole service sends per Philippine day. */
  dailyCap?: number;
  alert?: (message: string) => void;
};

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'>;

function assertCaller(request: Req): string {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  return request.auth.uid;
}

type Slot = {kind: 'cooldown'; seconds: number} | {kind: 'capped'} | {kind: 'busy'} | {kind: 'stored'};

export async function sendSignInCode(request: Req, deps: RequestDeps): Promise<{resendAfterSeconds: number}> {
  const uid = assertCaller(request);
  const email = normalizeEmail((request.data as {email?: unknown} | undefined)?.email);
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'signInCodeSend', SENDS_PER_CALLER_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many codes requested. Try again later.');
  }

  const code = String((deps.random ?? (() => randomInt(0, 1_000_000)))()).padStart(6, '0');
  const codeHash = hashCode(deps.key, email, code);
  const ref = deps.db.doc(`signInCodes/${codeDocId(email)}`);
  const at = now();
  const cap = deps.dailyCap ?? 80;
  const dayRef = deps.db.doc(`signInLimits/global-${phDay(at)}`);

  const slot = await deps.db.runTransaction<Slot>(async transaction => {
    const [snapshot, day] = await Promise.all([transaction.get(ref), transaction.get(dayRef)]);
    const sentAt = millis(snapshot.get('sentAt'));
    if (sentAt > 0) {
      const elapsed = at - sentAt;
      if (elapsed < RESEND_COOLDOWN_MS) {
        const left = Math.min(RESEND_COOLDOWN_MS, RESEND_COOLDOWN_MS - Math.max(elapsed, 0));
        return {kind: 'cooldown', seconds: Math.ceil(left / 1000)};
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
        `Sign-in emails reached 80% of the daily cap (${sentToday + 1} of ${cap}).`);
    }
    transaction.set(ref, {
      codeHash,
      expiresAt: new Date(at + CODE_TTL_MS),
      attempts: 0,
      sentAt: at,
      windowStartedAt: inWindow ? windowStartedAt : at,
      sendCount: sendCount + 1,
      // Lets an optional Firestore TTL policy remove idle documents after the window has closed.
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
  if (slot.kind === 'cooldown') return {resendAfterSeconds: slot.seconds};

  try {
    await deps.mailer.send(signInCodeMessage({to: email, code}));
  } catch (error) {
    logger.warn('Sign-in code email failed', {message: error instanceof Error ? error.message : 'unknown'});
    await clearCode(deps.db, ref, codeHash, dayRef);
    throw new HttpsError('unavailable', 'We could not send the email. Try again soon.');
  }
  return {resendAfterSeconds: RESEND_COOLDOWN_MS / 1000};
}

/** Blank the code but keep the send counters. Only touches the code this call stored. */
async function clearCode(db: Firestore, ref: ReturnType<Firestore['doc']>, codeHash: string,
  dayRef: ReturnType<Firestore['doc']>): Promise<void> {
  await db.runTransaction(async transaction => {
    const [snapshot, day] = await Promise.all([transaction.get(ref), transaction.get(dayRef)]);
    if (snapshot.get('codeHash') === codeHash) {
      transaction.set(ref, {codeHash: null, expiresAt: null, attempts: 0}, {merge: true});
    }
    // Give the place back, so a failing mailer cannot use up the day's cap.
    const sentToday = Number(day.get('count') ?? 0);
    if (sentToday > 0) transaction.set(dayRef, {count: sentToday - 1}, {merge: true});
  });
}

// ----------------------------------------------------------------- verify

export type VerifyDeps = {
  db: Firestore;
  auth: Pick<Auth, 'getUserByEmail' | 'createUser' | 'updateUser' | 'createCustomToken'>;
  key: string;
  now?: () => number;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
};

type Outcome =
  | {kind: 'ok'}
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

/** The uid to sign the caller in as. See the contract in the report: this mirrors the app's link-or-switch rule. */
async function accountFor(request: Req, email: string, auth: VerifyDeps['auth']): Promise<string> {
  let user = await findUser(auth, email);
  if (!user && request.auth?.token.firebase?.sign_in_provider === 'anonymous') {
    // Upgrade the caller's anonymous user in place, so its uid and data are kept.
    try {
      await auth.updateUser(request.auth.uid, {email, emailVerified: true});
      return request.auth.uid;
    } catch (error) {
      const code = authCode(error);
      if (code === 'auth/email-already-exists') user = await findUser(auth, email);
      else if (code !== 'auth/user-not-found') throw error;
    }
  }
  if (user) {
    if (user.disabled) throw new HttpsError('permission-denied', 'This account is disabled.');
    if (!user.emailVerified) await auth.updateUser(user.uid, {emailVerified: true});
    return user.uid;
  }
  return (await auth.createUser({email, emailVerified: true})).uid;
}

export async function checkSignInCode(request: Req, deps: VerifyDeps): Promise<{token: string}> {
  const uid = assertCaller(request);
  const data = (request.data ?? {}) as {email?: unknown; code?: unknown};
  const email = normalizeEmail(data.email);
  if (typeof data.code !== 'string' || !/^\d{6}$/.test(data.code)) {
    throw new HttpsError('invalid-argument', 'Enter the 6-digit code.');
  }
  const code = data.code;
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'signInCodeVerify', VERIFIES_PER_CALLER, 10 * 60_000)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  const ref = deps.db.doc(`signInCodes/${codeDocId(email)}`);
  const given = hashCode(deps.key, email, code);
  const outcome = await deps.db.runTransaction<Outcome>(async transaction => {
    const snapshot = await transaction.get(ref);
    const stored: unknown = snapshot.get('codeHash');
    const expiresAt = millis(snapshot.get('expiresAt'));
    const blank = {codeHash: null, expiresAt: null, attempts: 0};
    if (typeof stored !== 'string' || expiresAt <= 0) return {kind: 'expired'};
    if (expiresAt <= now()) {
      transaction.set(ref, blank, {merge: true});
      return {kind: 'expired'};
    }
    const attempts = Number(snapshot.get('attempts') ?? 0);
    if (attempts >= MAX_WRONG_TRIES) return {kind: 'tooManyTries'};
    if (sameHash(stored, given)) {
      transaction.set(ref, blank, {merge: true});
      return {kind: 'ok'};
    }
    const next = attempts + 1;
    transaction.set(ref, next >= MAX_WRONG_TRIES ? blank : {attempts: next}, {merge: true});
    return {kind: 'wrong', triesLeft: MAX_WRONG_TRIES - next};
  });

  if (outcome.kind === 'expired') {
    throw new HttpsError('not-found', 'That code has expired. Request a new one.', {reason: 'expired'});
  }
  if (outcome.kind === 'tooManyTries') {
    throw new HttpsError('resource-exhausted', 'Too many wrong tries. Request a new code.', {reason: 'tooManyTries'});
  }
  if (outcome.kind === 'wrong') {
    throw new HttpsError('invalid-argument', 'That code is not right.',
      {reason: 'wrong', triesLeft: outcome.triesLeft});
  }

  const accountUid = await accountFor(request, email, deps.auth);
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
  return sendSignInCode(request, {db: getFirestore(), key: key(), dailyCap: signInDailyCap.value(),
    mailer: {send: message => mailerFor(process.env,
      {apiKey: () => guardianMailKey.value(), from: () => guardianMailFrom.value()}).send(message)}});
});

export const verifySignInCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [signInCodeKey]}, request => {
  assertFreshAppCheck(request);
  return checkSignInCode(request, {db: getFirestore(), auth: getAuth(), key: key()});
});
