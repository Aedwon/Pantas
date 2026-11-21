import {createHmac, randomBytes, randomInt, timingSafeEqual} from 'node:crypto';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {phDay} from './_phDate.js';
import {appSecrets, secret} from './_secrets.js';
import {timed} from './_timed.js';
import {childrenOfHolder, holderForChild, type ChildLink} from './childLinks.js';
import {GUARDIAN_WINDOW_MS, guardianDailyCap, guardianMailFrom, maskEmail} from './guardianConsent.js';
import {mailerFor, type GuardianMailer, type GuardianMessage} from './guardianMail.js';
import {key as signInCodeKey} from './signInCode.js';

/**
 * The guardian code gate. A 6-digit code is mailed to the holder's email (never to the child) and
 * guards adding a child, the data copy, withdraw, delete, the sibling opt-in, and switching into a
 * child whose opt-in is off. Spec B2 rules 4a and 4b, legal draft section 7.
 *
 * One pending code per holder (`guardianCodes/{holderUid}`), stored only as a keyed hash that covers
 * holder, child and action. A new request for a different child or action replaces it, which cancels
 * the old one. A right code makes a short-lived single-use proof (`guardianCodeProofs/{id}`) that the
 * callable doing the guarded action consumes with `consumeGuardianProof`.
 */

export const GUARDIAN_CODE_ACTIONS = ['addChild', 'dataCopy', 'withdraw', 'delete', 'siblingOptIn', 'switchInto'] as const;
export type GuardianCodeAction = typeof GUARDIAN_CODE_ACTIONS[number];

/** Decision 9 item 6 is a proposal: this number may change. Counted per holder per UTC day. */
export const GUARDIAN_CODES_PER_HOLDER_PER_DAY = 10;
export const GUARDIAN_CODE_TTL_MS = 10 * 60_000;
export const GUARDIAN_PROOF_TTL_MS = 5 * 60_000;
export const GUARDIAN_CODE_RESEND_COOLDOWN_MS = 60_000;
export const GUARDIAN_CODE_MAX_WRONG_TRIES = 5;
const SENDS_PER_CALLER_PER_HOUR = 10;
const VERIFIES_PER_CALLER = 30;
const HOUR_MS = 3_600_000;
const DAY_MS = 86_400_000;
const PURGE_MARGIN_MS = DAY_MS;
/** The reason the client maps to "try again tomorrow" plus the data protection officer contact. */
export const DAILY_LIMIT_REASON = 'guardian-code-daily-limit';

/** The plain phrase for each action, used after "confirm" in the email. */
const PHRASES: Record<GuardianCodeAction, string> = {
  addChild: 'adding a child',
  dataCopy: 'a copy of the data',
  withdraw: 'withdrawing permission',
  delete: 'deleting the account',
  siblingOptIn: 'the sibling sign-in setting',
  switchInto: 'opening the account',
};
/** What stands in for the nickname when the action is about no child yet. */
const NO_CHILD_LABEL = 'your account';

export const hashGuardianCode = (key: string, holderUid: string, childId: string | null,
  action: string, code: string): string =>
  createHmac('sha256', key).update(['guardian-gate', holderUid, childId ?? '', action, code].join('\0')).digest('hex');

const sameHash = (stored: string, given: string): boolean => {
  const a = Buffer.from(stored, 'hex');
  const b = Buffer.from(given, 'hex');
  return a.length === 32 && a.length === b.length && timingSafeEqual(a, b);
};

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

/** The code email. Text from the legal draft, section 7. Every dynamic value is escaped before it enters the markup. */
export function guardianCodeMessage(input: {to: string; code: string; action: GuardianCodeAction; nickname?: string | null}):
  GuardianMessage {
  const label = input.nickname || NO_CHILD_LABEL;
  const lead = `Use this code to confirm ${PHRASES[input.action]} for ${label}: ${input.code}.`;
  const note = 'It works once and expires soon. If you did not ask for it, ignore this email.';
  const text = `${lead} ${note}`;
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"></head>` +
    `<body style="margin:0;padding:24px 16px;background:#FFFFFF;color:${ink};font-family:${font}">` +
    `<div style="max-width:560px;margin:0 auto">` +
    `<p style="margin:0 0 16px;font-size:16px;line-height:1.6">${escapeHtml(`Use this code to confirm ${PHRASES[input.action]} for ${label}:`)}</p>` +
    `<p style="margin:0 0 24px;font-size:36px;line-height:1.2;font-weight:700;letter-spacing:8px;color:${accent}">${escapeHtml(input.code)}</p>` +
    `<p style="margin:0;font-size:14px;line-height:1.6;color:${muted}">${escapeHtml(note)}</p>` +
    `</div></body></html>`;
  return {to: input.to, subject: `Pantas code for ${label}`, text, html};
}

// ------------------------------------------------------------- shared

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'>;

export type GateDeps = {
  db: Firestore;
  auth: Pick<Auth, 'getUser'>;
  key: string;
  now?: () => number;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
  /** A new random 128-bit proof id as 32 hex characters. */
  proofId?: () => string;
};

export type SendDeps = GateDeps & {
  mailer: GuardianMailer;
  /** A whole number from 0 up to 999999. */
  random?: () => number;
  /** Most guardian mails (consent links and codes together) per Philippine day. */
  dailyCap?: number;
};

function assertCaller(request: Req): string {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  return request.auth.uid;
}

const ID = /^[^/\s]{1,128}$/;

function parseTarget(data: unknown): {action: GuardianCodeAction; childId: string | null} {
  const {action, childId} = (data ?? {}) as {action?: unknown; childId?: unknown};
  if (typeof action !== 'string' || !(GUARDIAN_CODE_ACTIONS as readonly string[]).includes(action)) {
    throw new HttpsError('invalid-argument', 'Unknown action.');
  }
  if (action === 'addChild') {
    if (childId !== undefined && childId !== null) throw new HttpsError('invalid-argument', 'Adding a child names no child.');
    return {action, childId: null};
  }
  if (typeof childId !== 'string' || !ID.test(childId)) throw new HttpsError('invalid-argument', 'Name the child.');
  return {action: action as GuardianCodeAction, childId};
}

const notLinked = (): HttpsError => new HttpsError('permission-denied', 'This account is not linked to that child.',
  {reason: 'not-linked'});

/**
 * The holder for this call, from the link. The caller is either the holder or a child linked to it.
 * The named child must be one of that holder's active children. Adding a child needs a holder that
 * already has one: the gate is entered inside a child's session.
 */
async function resolveHolder(db: Firestore, callerUid: string, childId: string | null):
  Promise<{holderUid: string; child: ChildLink | null}> {
  const holderUid = await holderForChild(db, callerUid) ?? callerUid;
  const children = await childrenOfHolder(db, holderUid);
  if (children.length === 0) throw notLinked();
  if (childId === null) return {holderUid, child: null};
  const child = children.find(row => row.childUid === childId);
  if (!child) throw notLinked();
  return {holderUid, child};
}

const codePath = (holderUid: string): string => `guardianCodes/${holderUid}`;
export async function cancelPendingGuardianCode(db: Firestore, holderUid: string): Promise<void> {
  await db.doc(codePath(holderUid)).delete();
}

const proofPath = (id: string): string => `guardianCodeProofs/${id}`;
const PROOF_ID = /^[0-9a-f]{32}$/;

const expired = (): HttpsError =>
  new HttpsError('not-found', 'That code has expired. Request a new one.', {reason: 'expired'});

// ---------------------------------------------------------------- request

type Slot =
  | {kind: 'cached'; seconds: number}
  | {kind: 'holderFull'}
  | {kind: 'dayFull'; firstFull: boolean}
  | {kind: 'stored'; code: string; becameFull: boolean};

export async function sendGuardianCode(request: Req, deps: SendDeps):
  Promise<{maskedEmail: string; resendAfterSeconds: number; expiresInSeconds: number}> {
  const uid = assertCaller(request);
  const {action, childId} = parseTarget(request.data);
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  const {holderUid, child} = await resolveHolder(deps.db, uid, childId);
  if (!await allow(uid, 'guardianCodeSend', SENDS_PER_CALLER_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many codes requested. Try again later.');
  }
  let email: string | undefined;
  try {
    email = (await deps.auth.getUser(holderUid)).email;
  } catch (error) {
    logger.warn('Guardian code holder lookup failed', {message: error instanceof Error ? error.message : 'unknown'});
  }
  if (!email) throw new HttpsError('failed-precondition', 'No email is on file for this parent or guardian.');
  const maskedEmail = maskEmail(email);

  const cap = deps.dailyCap ?? 500;
  const at = now();
  const utcDay = new Date(at).toISOString().slice(0, 10);
  const day = phDay(at);
  const codeRef = deps.db.doc(codePath(holderUid));
  const holderDayRef = deps.db.doc(`guardianCodeLimits/${holderUid}-${utcDay}`);
  // The same counter guardian consent mail uses, so there is one daily cap for all guardian mail.
  const globalRef = deps.db.doc(`guardianLimits/global-${day}`);
  const random = deps.random ?? (() => randomInt(0, 1_000_000));

  const reservationId = randomBytes(16).toString('hex');
  const slot = await deps.db.runTransaction<Slot>(async tx => {
    const [pending, holderDay, global] = await Promise.all([tx.get(codeRef), tx.get(holderDayRef), tx.get(globalRef)]);
    const sentAt = millis(pending.get('sentAt'));
    // The same code asked for again inside a minute: no new mail, and the true wait.
    if (pending.exists && pending.get('action') === action && (pending.get('childId') ?? null) === childId &&
        sentAt > 0 && at - sentAt < GUARDIAN_CODE_RESEND_COOLDOWN_MS && millis(pending.get('expiresAt')) > at) {
      return {kind: 'cached', seconds: Math.ceil((GUARDIAN_CODE_RESEND_COOLDOWN_MS - (at - sentAt)) / 1000)};
    }
    const holderCount = Number(holderDay.get('count') ?? 0);
    if (holderCount >= GUARDIAN_CODES_PER_HOLDER_PER_DAY) return {kind: 'holderFull'};
    const sentToday = Number(global.get('count') ?? 0);
    if (!Number.isFinite(cap) || cap < 1 || sentToday + 1 > cap) {
      const firstFull = global.get('fullLogged') !== true;
      if (firstFull) tx.set(globalRef, {fullLogged: true, purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS)}, {merge: true});
      return {kind: 'dayFull', firstFull};
    }
    const becameFull = sentToday + 1 >= cap && global.get('fullLogged') !== true;
    const code = String(random()).padStart(6, '0');
    tx.set(globalRef, {count: sentToday + 1, purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS),
      ...(becameFull ? {fullLogged: true} : {})}, {merge: true});
    tx.set(holderDayRef, {count: holderCount + 1, purgeAt: new Date(at + DAY_MS + PURGE_MARGIN_MS)});
    // Replacing the document is what cancels a pending code for another child or action.
    tx.set(codeRef, {holderUid, childId, action, reservationId, codeHash: hashGuardianCode(deps.key, holderUid, childId, action, code),
      attempts: 0, sentAt: at, expiresAt: new Date(at + GUARDIAN_CODE_TTL_MS),
      purgeAt: new Date(at + GUARDIAN_CODE_TTL_MS + PURGE_MARGIN_MS)});
    return {kind: 'stored', code, becameFull};
  });

  const reply = {maskedEmail, resendAfterSeconds: GUARDIAN_CODE_RESEND_COOLDOWN_MS / 1000,
    expiresInSeconds: GUARDIAN_CODE_TTL_MS / 1000};
  if (slot.kind === 'cached') return {...reply, resendAfterSeconds: slot.seconds};
  if (slot.kind === 'holderFull') {
    logger.warn('Guardian code daily limit reached for a holder', {holder: holderUid.slice(0, 6)});
    throw dailyLimit();
  }
  if (slot.kind === 'dayFull') {
    if (slot.firstFull) logger.error(`Mail cap full: guardian bucket, ${day}.`, {event: 'mail_cap_full', bucket: 'guardian', day, cap});
    throw dailyLimit();
  }
  if (slot.becameFull) logger.error(`Mail cap full: guardian bucket, ${day}.`, {event: 'mail_cap_full', bucket: 'guardian', day, cap});

  try {
    await deps.mailer.send(guardianCodeMessage({to: email, code: slot.code, action, nickname: child?.nickname}));
  } catch (error) {
    logger.warn('Guardian code email failed', {message: error instanceof Error ? error.message : 'unknown'});
    // Remove the unsent code and give both places back, so a failing mailer cannot use up a cap.
    await deps.db.runTransaction(async tx => {
      const [global, holderDay, pending] = await Promise.all([tx.get(globalRef), tx.get(holderDayRef), tx.get(codeRef)]);
      if (pending.get('reservationId') === reservationId) tx.delete(codeRef);
      if (global.exists) tx.set(globalRef, {count: Math.max(0, Number(global.get('count') ?? 0) - 1),
        purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS)}, {merge: true});
      if (holderDay.exists) tx.set(holderDayRef, {count: Math.max(0, Number(holderDay.get('count') ?? 0) - 1),
        purgeAt: new Date(at + DAY_MS + PURGE_MARGIN_MS)});
    });
    throw new HttpsError('unavailable', 'We could not send the email. Try again soon.');
  }
  return reply;
}

const dailyLimit = (): HttpsError =>
  new HttpsError('resource-exhausted', 'Too many codes today. Try again tomorrow.', {reason: DAILY_LIMIT_REASON});

// ----------------------------------------------------------------- verify

type Outcome =
  | {kind: 'ok'; proof: string}
  | {kind: 'expired'}
  | {kind: 'tooManyTries'}
  | {kind: 'wrong'; triesLeft: number};

export async function checkGuardianCode(request: Req, deps: GateDeps):
  Promise<{proof: string; expiresInSeconds: number}> {
  const uid = assertCaller(request);
  const {action, childId} = parseTarget(request.data);
  const code = (request.data as {code?: unknown}).code;
  if (typeof code !== 'string' || !/^\d{6}$/.test(code)) throw new HttpsError('invalid-argument', 'Enter the 6-digit code.');
  const now = deps.now ?? Date.now;
  const allow = deps.allow ?? allowAtMost;
  const {holderUid} = await resolveHolder(deps.db, uid, childId);
  if (!await allow(uid, 'guardianCodeVerify', VERIFIES_PER_CALLER, 10 * 60_000)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const codeRef = deps.db.doc(codePath(holderUid));
  const proof = (deps.proofId ?? (() => randomBytes(16).toString('hex')))();
  const at = now();

  const outcome = await deps.db.runTransaction<Outcome>(async tx => {
    const snapshot = await tx.get(codeRef);
    const stored: unknown = snapshot.get('codeHash');
    // A code for another child or action is not this one: it is not found, and no try is spent.
    if (typeof stored !== 'string' || snapshot.get('action') !== action ||
        (snapshot.get('childId') ?? null) !== childId || snapshot.get('holderUid') !== holderUid) return {kind: 'expired'};
    if (millis(snapshot.get('expiresAt')) <= at) {
      tx.delete(codeRef);
      return {kind: 'expired'};
    }
    const attempts = Number(snapshot.get('attempts') ?? 0);
    if (attempts >= GUARDIAN_CODE_MAX_WRONG_TRIES) return {kind: 'tooManyTries'};
    if (sameHash(stored, hashGuardianCode(deps.key, holderUid, childId, action, code))) {
      tx.delete(codeRef);
      tx.set(deps.db.doc(proofPath(proof)), {holderUid, childId, action,
        expiresAt: new Date(at + GUARDIAN_PROOF_TTL_MS), purgeAt: new Date(at + GUARDIAN_PROOF_TTL_MS + PURGE_MARGIN_MS)});
      return {kind: 'ok', proof};
    }
    tx.set(codeRef, {attempts: attempts + 1}, {merge: true});
    return {kind: 'wrong', triesLeft: GUARDIAN_CODE_MAX_WRONG_TRIES - attempts - 1};
  });

  if (outcome.kind === 'expired') throw expired();
  if (outcome.kind === 'tooManyTries') {
    throw new HttpsError('resource-exhausted', 'Too many wrong tries. Request a new code.', {reason: 'tooManyTries'});
  }
  if (outcome.kind === 'wrong') {
    throw new HttpsError('invalid-argument', 'That code is not right.', {reason: 'wrong', triesLeft: outcome.triesLeft});
  }
  return {proof: outcome.proof, expiresInSeconds: GUARDIAN_PROOF_TTL_MS / 1000};
}

// ------------------------------------------------------------------ proof

const proofInvalid = (): HttpsError =>
  new HttpsError('permission-denied', 'Confirm with a new code.', {reason: 'guardian-proof-invalid'});

/**
 * Uses a proof up. Called by the callable that does the guarded action (open child session, withdraw,
 * delete, sibling opt-in), with the holder and child it resolved itself and the action it performs.
 * A proof for another holder, child or action, or an expired or used one, is refused. A mismatch does not
 * use the proof up. `childId` is null for `addChild`.
 */
export async function consumeGuardianProof(proofId: unknown, holderUid: string, childId: string | null,
  action: GuardianCodeAction, deps: {db?: Firestore; now?: () => number} = {}): Promise<void> {
  if (typeof proofId !== 'string' || !PROOF_ID.test(proofId)) throw proofInvalid();
  const db = deps.db ?? getFirestore();
  const at = (deps.now ?? Date.now)();
  const ref = db.doc(proofPath(proofId));
  const ok = await db.runTransaction(async tx => {
    const snapshot = await tx.get(ref);
    if (!snapshot.exists) return false;
    if (millis(snapshot.get('expiresAt')) <= at) {
      tx.delete(ref);
      return false;
    }
    if (snapshot.get('holderUid') !== holderUid || (snapshot.get('childId') ?? null) !== childId ||
        snapshot.get('action') !== action) return false;
    tx.delete(ref);
    return true;
  });
  if (!ok) throw proofInvalid();
}

// ------------------------------------------------------------- deployment

export const requestGuardianCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [appSecrets]}, timed('requestGuardianCode', request => {
  assertFreshAppCheck(request);
  return sendGuardianCode(request, {db: getFirestore(), auth: getAuth(), key: signInCodeKey(),
    dailyCap: guardianDailyCap.value(),
    mailer: {send: message => mailerFor(process.env,
      {apiKey: () => secret('GUARDIAN_MAIL_API_KEY'), from: () => guardianMailFrom.value()}).send(message)}});
}));

export const verifyGuardianCode = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [appSecrets]}, timed('verifyGuardianCode', request => {
  assertFreshAppCheck(request);
  return checkGuardianCode(request, {db: getFirestore(), auth: getAuth(), key: signInCodeKey()});
}));
