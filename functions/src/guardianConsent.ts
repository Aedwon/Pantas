import {createHmac, randomBytes} from 'node:crypto';
import {defineInt, defineSecret, defineString} from 'firebase-functions/params';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {FieldPath, getFirestore, type DocumentReference, type DocumentSnapshot, type Firestore, type Query, type QueryDocumentSnapshot} from 'firebase-admin/firestore';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {onSchedule} from 'firebase-functions/v2/scheduler';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {deleteUserData} from './deleteUserData.js';
import {guardianMessage, mailerFor, type GuardianMailer} from './guardianMail.js';
import {timed} from './_timed.js';
import {trialIdentityKey} from './webTrial.js';

/**
 * Guardian consent for students under 18.
 *
 * The server owns the status. A client can only ask for a link, read the
 * status, or (as the guardian, with the link) answer. Nothing here stores the
 * link token or the guardian email in the clear: both are kept as keyed hashes,
 * plus a masked address the student's screen can show. The link is one use,
 * expires after seven days, and opening it changes nothing.
 */

export const guardianHmacKey = defineSecret('GUARDIAN_HMAC_KEY');
export const guardianMailKey = defineSecret('GUARDIAN_MAIL_API_KEY');
export const guardianMailFrom = defineString('GUARDIAN_MAIL_FROM', {default: ''});
export const guardianLinkOrigin = defineString('GUARDIAN_LINK_ORIGIN', {default: ''});
/** Most guardian emails the whole service sends per Philippine day. */
export const guardianDailyCap = defineInt('GUARDIAN_DAILY_SEND_CAP', {default: 500});

export const GUARDIAN_WINDOW_MS = 7 * 86_400_000;
const DAY_MS = 86_400_000;

// These identify the published documents and the confirmation page wording.
export const GUARDIAN_DOCUMENT_VERSIONS = {
  privacy: '2026-11-10', terms: '2026-11-10', teens: '2026-11-10',
} as const;
export const GUARDIAN_NOTICE_WORDING_VERSION = '2026-11-11';
/** The version of the line the age step shows above the birth-year field. */
export const AGE_CHECK_NOTICE_VERSION = '2026-11-09';

// Engineering limits, not figures shown to a student.
export const SEND_LIMIT = {perStudent: 5, perStudentWindowMs: DAY_MS, gapMs: 30_000,
  perGuardianEmail: 3, perGuardianEmailWindowMs: DAY_MS} as const;
export const ANSWER_LIMIT = {max: 30, windowMs: 10 * 60_000} as const;

export type ConsentStatus = 'pending' | 'confirmed' | 'declined' | 'withdrawn';
export type PublicStatus = ConsentStatus | 'expired' | 'none';

export type ConsentDeps = {
  db: Firestore;
  key: string;
  mailer: GuardianMailer;
  linkOrigin: string;
  dailyCap?: number;
  /** Error-level alert sink. Defaults to the error log. */
  alert?: (message: string) => void;
  now?: () => number;
  token?: () => string;
  /** Makes the manage tokens. Separate from `token` so a test can pin both. */
  manageToken?: () => string;
  /** Needed only by a withdrawal. */
  auth?: Pick<Auth, 'getUser' | 'deleteUser' | 'updateUser' | 'revokeRefreshTokens'>;
  allow?: (uid: string, key: string, max: number, windowMs: number) => Promise<boolean>;
};

type AppRequest = Pick<CallableRequest, 'auth' | 'app' | 'data'>;

export const hashValue = (key: string, purpose: 'token' | 'email', value: string): string =>
  createHmac('sha256', key).update(`${purpose}\0${value}`).digest('hex');

export const newToken = (): string => randomBytes(32).toString('hex');

const EMAIL = /^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?\.[A-Za-z]{2,63}$/;
export const validEmail = (value: unknown): value is string =>
  typeof value === 'string' && value.length <= 254 && EMAIL.test(value);

/** "maria@gmail.com" becomes "m***@g***.com". */
export function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  const labels = domain.split('.');
  return `${local[0]}***@${domain[0]}***.${labels[labels.length - 1]}`;
}

// Names go into the email body, so they carry no digits, links or addresses.
const NAME = /^[\p{L}][\p{L}\p{M} '.\u2019-]*$/u;

function cleanName(value: unknown, required: boolean): string | null {
  if (value === undefined || value === null || value === '') {
    if (required) throw new HttpsError('invalid-argument', 'A name is required.');
    return null;
  }
  // eslint-disable-next-line no-control-regex
  const clean = typeof value === 'string' && !/[\u0000-\u001f\u007f-\u009f]/.test(value);
  const trimmed = clean ? (value as string).trim().replace(/ +/g, ' ') : '';
  // A dot followed by a letter reads as a web address, so it is refused.
  if (trimmed.length === 0 || trimmed.length > 40 || !NAME.test(trimmed) || /\.\p{L}/u.test(trimmed)) {
    throw new HttpsError('invalid-argument', 'Enter a valid name.');
  }
  return trimmed;
}

function requireCaller(request: AppRequest): string {
  if (!request.app) throw new HttpsError('unauthenticated', 'App Check is required.');
  assertFreshAppCheck(request);
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  return request.auth.uid;
}

const consentRef = (db: Firestore, uid: string) => db.doc(`users/${uid}/server/guardianConsent`);
const tokenRef = (db: Firestore, hash: string) => db.doc(`guardianTokens/${hash}`);

function publicStatus(data: FirebaseFirestore.DocumentData | undefined, now: number): PublicStatus {
  // A trimmed record holds only the age group: no request is open.
  if (!data || typeof data.status !== 'string') return 'none';
  if (data.status === 'pending' && now >= data.expiresAt) return 'expired';
  return data.status as PublicStatus;
}

export type StatusResult = {status: PublicStatus; maskedEmail: string | null; expiresAt: number | null;
  sharingAllowed: boolean; ageGroup: 'minor' | 'adult' | null};

/** Reads the caller's own status. Expiry is worked out here, never trusted from the client. */
export async function getStatus(request: AppRequest, deps: ConsentDeps): Promise<StatusResult> {
  const uid = requireCaller(request);
  const now = (deps.now ?? Date.now)();
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'guardianStatus', 60, 10 * 60_000)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const data = (await consentRef(deps.db, uid).get()).data();
  const status = publicStatus(data, now);
  return {status, maskedEmail: data?.maskedEmail ?? null, expiresAt: data?.expiresAt ?? null,
    sharingAllowed: data?.sharingAllowed === true,
    ageGroup: data?.ageGroup === 'minor' || data?.ageGroup === 'adult' ? data.ageGroup : null};
}

/**
 * Sends a fresh link. The same call serves the first send, Resend and Change
 * Email: it revokes any earlier link, so only the newest one can ever work.
 */
export async function sendLink(request: AppRequest, deps: ConsentDeps): Promise<{expiresAt: number; maskedEmail: string}> {
  const uid = requireCaller(request);
  const data = (request.data ?? {}) as Record<string, unknown>;
  const guardianName = cleanName(data.guardianName, true) as string;
  const rawEmail = typeof data.guardianEmail === 'string' ? data.guardianEmail.trim().toLowerCase() : '';
  if (!validEmail(rawEmail)) throw new HttpsError('invalid-argument', 'Enter a valid email.');
  const ownEmail = (request.auth?.token as {email?: string} | undefined)?.email;
  if (ownEmail && ownEmail.toLowerCase() === rawEmail) {
    throw new HttpsError('invalid-argument', 'Use your parent or guardian\'s own email.');
  }
  const noticeVersion = data.ageCheckNoticeVersion;
  if (noticeVersion !== undefined && noticeVersion !== AGE_CHECK_NOTICE_VERSION) {
    throw new HttpsError('invalid-argument', 'Reload the app to review the current age check notice.');
  }
  const now = (deps.now ?? Date.now)();
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'guardianSend', SEND_LIMIT.perStudent, SEND_LIMIT.perStudentWindowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const emailHash = hashValue(deps.key, 'email', rawEmail);
  const token = (deps.token ?? newToken)();
  const tokenHash = hashValue(deps.key, 'token', token);
  const manageToken = (deps.manageToken ?? newToken)();
  const manageHash = hashValue(deps.key, 'token', manageToken);
  const expiresAt = now + GUARDIAN_WINDOW_MS;
  const maskedEmail = maskEmail(rawEmail);
  const consent = consentRef(deps.db, uid);
  const emailLimit = deps.db.doc(`guardianLimits/${emailHash}`);
  const cap = deps.dailyCap ?? 500;
  if (!Number.isFinite(cap) || cap < 1) throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  const day = new Intl.DateTimeFormat('en-CA', {timeZone: 'Asia/Manila'}).format(now);
  const globalLimit = deps.db.doc(`guardianLimits/global-${day}`);

  await deps.db.runTransaction(async (tx) => {
    const [current, limit, global, openManage] = await Promise.all([tx.get(consent), tx.get(emailLimit), tx.get(globalLimit),
      tx.get(deps.db.collection('guardianTokens').where('uid', '==', uid).where('kind', '==', 'manage').where('state', '==', 'open'))]);
    const before = current.data();
    if (before?.status === 'confirmed') {
      throw new HttpsError('failed-precondition', 'Already confirmed.');
    }
    // An adult has no guardian. A new request would turn the record back into a minor.
    if (before?.ageGroup === 'adult') {
      throw new HttpsError('failed-precondition', 'This account is already an adult account.');
    }
    if (typeof before?.sentAt === 'number' && now - before.sentAt < SEND_LIMIT.gapMs) {
      throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
    }
    const startedAt = limit.get('windowStartedAt') as number | undefined;
    const inWindow = typeof startedAt === 'number' && now - startedAt < SEND_LIMIT.perGuardianEmailWindowMs;
    const count = inWindow ? (limit.get('count') as number) : 0;
    if (count + 1 > SEND_LIMIT.perGuardianEmail) {
      throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
    }
    const sentToday = (global.get('count') as number | undefined) ?? 0;
    // The last 20% of the cap is kept for a student sending again to the
    // address already on file, so throwaway accounts cannot lock them out.
    const resend = before?.emailHash === emailHash;
    const ceiling = resend ? cap : Math.floor(cap * 0.8);
    if (sentToday + 1 > ceiling) throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
    tx.set(globalLimit, {count: sentToday + 1, cleanupAt: now + DAY_MS + GUARDIAN_WINDOW_MS});
    const threshold = Math.ceil(cap * 0.8);
    if (sentToday < threshold && sentToday + 1 >= threshold) {
      (deps.alert ?? ((m: string) => console.error(m)))(
        `Guardian emails reached 80% of the daily cap (${sentToday + 1} of ${cap}).`);
    }
    tx.set(emailLimit, {windowStartedAt: inWindow ? startedAt : now, count: count + 1, cleanupAt: expiresAt});
    if (typeof before?.tokenHash === 'string') {
      tx.set(tokenRef(deps.db, before.tokenHash), {state: 'revoked', revokedAt: now}, {merge: true});
    }
    tx.set(tokenRef(deps.db, tokenHash), {uid, state: 'open', createdAt: now, expiresAt});
    // Only the newest email's manage link works. The manage token has no expiry of its own.
    for (const earlier of openManage.docs) tx.set(earlier.ref, {state: 'revoked', revokedAt: now}, {merge: true});
    tx.set(tokenRef(deps.db, manageHash), {kind: 'manage', uid, state: 'open', createdAt: now});
    tx.set(consent, {
      status: 'pending', ageGroup: 'minor', emailHash, maskedEmail, tokenHash,
      createdAt: before?.createdAt ?? now, sentAt: now, expiresAt,
      ...(noticeVersion === undefined ? {} : {ageCheckNoticeVersion: noticeVersion}),
    });
  });

  const origin = deps.linkOrigin.replace(/\/$/, '');
  const link = `${origin}/guardian?token=${token}`;
  const manageLink = `${origin}/guardian/manage?token=${manageToken}`;
  try {
    await deps.mailer.send(guardianMessage({guardianName, guardianEmail: rawEmail, link, manageLink, expiresAt}));
  } catch (error) {
    // The student can retry. The unsent link stays valid only for this window.
    console.error('Guardian mail failed', {uid, error: String(error)});
    // Give the place back so a failing mailer cannot use up the cap.
    await deps.db.runTransaction(async (tx) => {
      const count = ((await tx.get(globalLimit)).get('count') as number | undefined) ?? 0;
      tx.set(globalLimit, {count: Math.max(0, count - 1)});
    });
    throw new HttpsError('unavailable', 'The email could not be sent. Try again.');
  }
  return {expiresAt, maskedEmail};
}

export type RequestResult =
  | {state: 'open'; expiresAt: number}
  | {state: 'used' | 'expired' | 'unknown'};

async function lookup(deps: ConsentDeps, token: unknown, now: number) {
  if (typeof token !== 'string' || !/^[a-f0-9]{64}$/.test(token)) return {state: 'unknown' as const};
  const hash = hashValue(deps.key, 'token', token);
  const row = (await tokenRef(deps.db, hash).get()).data();
  if (!row) return {state: 'unknown' as const};
  if (row.kind === 'manage') return {state: 'unknown' as const};
  if (row.state === 'used') return {state: 'used' as const};
  if (row.state !== 'open') return {state: 'unknown' as const};
  if (now >= row.expiresAt) return {state: 'expired' as const};
  return {state: 'open' as const, hash, uid: row.uid as string, expiresAt: row.expiresAt as number};
}

function requireVisitor(request: AppRequest): string {
  // A guardian is usually signed out of Pantas. The app signs every visitor in
  // anonymously, and that session is only used to meter requests.
  return requireCaller(request);
}

/** The guardian page. Read only: opening the link never confirms anything. */
export async function readRequest(request: AppRequest, deps: ConsentDeps): Promise<RequestResult> {
  const visitor = requireVisitor(request);
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(visitor, 'guardianAnswer', ANSWER_LIMIT.max, ANSWER_LIMIT.windowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const now = (deps.now ?? Date.now)();
  const found = await lookup(deps, (request.data as {token?: unknown} | null)?.token, now);
  if (found.state !== 'open') return {state: found.state};
  const consent = (await consentRef(deps.db, found.uid).get()).data();
  if (consent?.status !== 'pending') return {state: 'used'};
  return {state: 'open', expiresAt: found.expiresAt};
}

export type AnswerResult =
  | {state: 'confirmed'; manageToken: string}
  | {state: 'declined' | 'used' | 'expired' | 'unknown'};

/** Confirms or declines. The link works once, and confirming needs the agreement box. */
export async function answerRequest(request: AppRequest, deps: ConsentDeps): Promise<AnswerResult> {
  const visitor = requireVisitor(request);
  const data = (request.data ?? {}) as {
    token?: unknown; decision?: unknown; agreed?: unknown;
    documentVersions?: unknown; noticeWordingVersion?: unknown; allowSharing?: unknown;
  };
  if (data.decision !== 'confirm' && data.decision !== 'decline') {
    throw new HttpsError('invalid-argument', 'Choose confirm or decline.');
  }
  if (data.decision === 'confirm' && data.agreed !== true) {
    throw new HttpsError('failed-precondition', 'Agreement is required.');
  }
  if (data.allowSharing !== undefined && typeof data.allowSharing !== 'boolean') {
    throw new HttpsError('invalid-argument', 'Sharing must be on or off.');
  }
  const allowSharing = data.allowSharing === true;
  const versions = data.documentVersions;
  if (!versions || typeof versions !== 'object' || Array.isArray(versions) ||
      Object.entries(GUARDIAN_DOCUMENT_VERSIONS).some(([id, version]) =>
        (versions as Record<string, unknown>)[id] !== version) ||
      data.noticeWordingVersion !== GUARDIAN_NOTICE_WORDING_VERSION) {
    throw new HttpsError('failed-precondition', 'Reload the page to review the current terms.');
  }
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(visitor, 'guardianAnswer', ANSWER_LIMIT.max, ANSWER_LIMIT.windowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const now = (deps.now ?? Date.now)();
  const decision = data.decision;
  if (typeof data.token !== 'string' || !/^[a-f0-9]{64}$/.test(data.token)) return {state: 'unknown'};
  const hash = hashValue(deps.key, 'token', data.token);
  // The page's own manage link, handed back once. The email carries a separate one that stays valid.
  const manageToken = (deps.manageToken ?? newToken)();
  return deps.db.runTransaction(async (tx): Promise<AnswerResult> => {
    const row = (await tx.get(tokenRef(deps.db, hash))).data();
    if (!row || row.kind === 'manage') return {state: 'unknown'};
    if (row.state === 'used') return {state: 'used'};
    if (row.state !== 'open') return {state: 'unknown'};
    if (now >= row.expiresAt) return {state: 'expired'};
    const consent = consentRef(deps.db, row.uid as string);
    const current = (await tx.get(consent)).data();
    if (current?.status !== 'pending' || current.tokenHash !== hash) return {state: 'used'};
    const status: ConsentStatus = decision === 'confirm' ? 'confirmed' : 'declined';
    tx.set(tokenRef(deps.db, hash), {state: 'used', usedAt: now}, {merge: true});
    tx.set(consent, {status, decidedAt: now, ...(decision === 'confirm' ? {sharingAllowed: allowSharing} : {})}, {merge: true});
    // Separate from the user tree so deletion keeps only the response evidence.
    // Never copy the contact, email hash, masked address, or study answers here.
    tx.set(deps.db.doc(`guardianConsentEvidence/${row.uid}/responses/${hash}`), {
      documentVersions: GUARDIAN_DOCUMENT_VERSIONS,
      noticeWordingVersion: GUARDIAN_NOTICE_WORDING_VERSION,
      action: decision, agreed: data.agreed === true, decidedAt: now,
      ...(decision === 'confirm' ? {sharingAllowed: allowSharing} : {}),
    });
    if (decision !== 'confirm') return {state: 'declined'};
    tx.set(tokenRef(deps.db, hashValue(deps.key, 'token', manageToken)),
      {kind: 'manage', uid: row.uid as string, state: 'open', createdAt: now});
    return {state: 'confirmed', manageToken};
  });
}

export type ManageResult =
  | {state: 'active'; sharingAllowed: boolean}
  | {state: 'not_confirmed' | 'unknown'};

type ManageView =
  | {state: 'active'; uid: string; sharingAllowed: boolean}
  // A withdrawal was recorded but the account is not fully gone yet. Only a withdrawal retry may use it.
  | {state: 'withdrawn'; uid: string}
  | {state: 'not_confirmed' | 'unknown'};

const unknown = {state: 'unknown'} as const;

/** What a manage token can do right now. `get` is a plain read or a transaction read. */
async function manageView(get: (ref: DocumentReference) => Promise<DocumentSnapshot>, deps: ConsentDeps,
  token: unknown): Promise<ManageView> {
  if (typeof token !== 'string' || !/^[a-f0-9]{64}$/.test(token)) return unknown;
  const row = (await get(tokenRef(deps.db, hashValue(deps.key, 'token', token)))).data();
  // A manage token has no expiry. Revoked, deleted and confirm-kind rows all read as unknown.
  if (!row || row.kind !== 'manage' || row.state !== 'open' || typeof row.uid !== 'string') return unknown;
  const uid = row.uid;
  const consent = (await get(consentRef(deps.db, uid))).data();
  if (!consent || consent.ageGroup === 'adult') return unknown;
  if (consent.status === 'confirmed') return {state: 'active', uid, sharingAllowed: consent.sharingAllowed === true};
  if (consent.status === 'withdrawn') return {state: 'withdrawn', uid};
  if (consent.status === 'pending' || consent.status === 'declined') return {state: 'not_confirmed'};
  return unknown;
}

const publicManage = (view: ManageView): ManageResult =>
  view.state === 'active' ? {state: 'active', sharingAllowed: view.sharingAllowed}
    : view.state === 'not_confirmed' ? {state: 'not_confirmed'} : unknown;

async function manageVisitor(request: AppRequest, deps: ConsentDeps): Promise<void> {
  const visitor = requireVisitor(request);
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(visitor, 'guardianAnswer', ANSWER_LIMIT.max, ANSWER_LIMIT.windowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
}

/** Evidence of one guardian action, kept outside the user tree. Holds no contact data. */
const evidenceEntry = (db: Firestore, uid: string, action: string, decidedAt: number) =>
  ({ref: db.collection(`guardianConsentEvidence/${uid}/responses`).doc(),
    data: {action, decidedAt, documentVersions: GUARDIAN_DOCUMENT_VERSIONS,
      noticeWordingVersion: GUARDIAN_NOTICE_WORDING_VERSION}});

/** The manage page. Read only. */
export async function readManage(request: AppRequest, deps: ConsentDeps): Promise<ManageResult> {
  await manageVisitor(request, deps);
  const view = await manageView(ref => ref.get(), deps, (request.data as {token?: unknown} | null)?.token);
  return publicManage(view);
}

/** Turns optional usage sharing on or off for the student, and records the change. */
export async function setSharing(request: AppRequest, deps: ConsentDeps): Promise<ManageResult> {
  const visitor = requireVisitor(request);
  const data = (request.data ?? {}) as {token?: unknown; allowed?: unknown};
  if (typeof data.allowed !== 'boolean') throw new HttpsError('invalid-argument', 'Sharing must be on or off.');
  const allowed = data.allowed;
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(visitor, 'guardianAnswer', ANSWER_LIMIT.max, ANSWER_LIMIT.windowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const now = (deps.now ?? Date.now)();
  return deps.db.runTransaction(async (tx): Promise<ManageResult> => {
    const view = await manageView(ref => tx.get(ref), deps, data.token);
    if (view.state !== 'active') return publicManage(view);
    tx.set(consentRef(deps.db, view.uid), {sharingAllowed: allowed}, {merge: true});
    const entry = evidenceEntry(deps.db, view.uid, allowed ? 'sharing_on' : 'sharing_off', now);
    tx.set(entry.ref, entry.data);
    return {state: 'active', sharingAllowed: allowed};
  });
}

/**
 * Closes the student's account at the guardian's request: records the withdrawal, signs the
 * student out, then deletes the account the same way the delete button does. If a step fails,
 * the same link finishes the job, because the recorded status lets a retry through.
 */
export async function withdraw(request: AppRequest, deps: ConsentDeps): Promise<{state: 'withdrawn' | 'not_confirmed' | 'unknown'}> {
  await manageVisitor(request, deps);
  if (!deps.auth) throw new Error('A withdrawal needs the Auth service.');
  const now = (deps.now ?? Date.now)();
  const token = (request.data as {token?: unknown} | null)?.token;
  const view = await deps.db.runTransaction(async (tx): Promise<ManageView> => {
    const found = await manageView(ref => tx.get(ref), deps, token);
    if (found.state === 'active') {
      tx.set(consentRef(deps.db, found.uid), {status: 'withdrawn', withdrawnAt: now}, {merge: true});
      const entry = evidenceEntry(deps.db, found.uid, 'withdraw', now);
      tx.set(entry.ref, entry.data);
    }
    return found;
  });
  if (view.state !== 'active' && view.state !== 'withdrawn') return publicManage(view) as {state: 'not_confirmed' | 'unknown'};
  await deps.auth.updateUser(view.uid, {disabled: true});
  await deps.auth.revokeRefreshTokens(view.uid);
  await deleteUserData(deps.db, deps.auth, view.uid, 'guardian_withdrawal', {now: deps.now});
  return {state: 'withdrawn'};
}

const ADULT_LIMIT = {max: 5, windowMs: 60 * 60_000} as const;

/**
 * The student says they are 18 now. Only a minor can switch, and only once. It ends the guardian's
 * manage links, because a guardian has no say over an adult. The server never learns the birth year.
 */
export async function markAdult(request: AppRequest, deps: ConsentDeps): Promise<{state: 'adult'}> {
  const uid = requireCaller(request);
  const allow = deps.allow ?? allowAtMost;
  if (!await allow(uid, 'guardianAdult', ADULT_LIMIT.max, ADULT_LIMIT.windowMs)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const now = (deps.now ?? Date.now)();
  const consent = consentRef(deps.db, uid);
  return deps.db.runTransaction(async (tx): Promise<{state: 'adult'}> => {
    const [current, openManage] = await Promise.all([tx.get(consent),
      tx.get(deps.db.collection('guardianTokens').where('uid', '==', uid).where('kind', '==', 'manage').where('state', '==', 'open'))]);
    const data = current.data();
    // The server never knew a minor, so there is nothing to switch and nothing to write.
    if (!data) return {state: 'adult'};
    if (data.ageGroup !== 'minor' || data.adultSince !== undefined) {
      throw new HttpsError('failed-precondition', 'Already switched.');
    }
    for (const row of openManage.docs) tx.set(row.ref, {state: 'revoked', revokedAt: now}, {merge: true});
    tx.set(consent, {ageGroup: 'adult', adultSince: now}, {merge: true});
    const entry = evidenceEntry(deps.db, uid, 'became_adult', now);
    tx.set(entry.ref, {action: entry.data.action, decidedAt: now});
    return {state: 'adult'};
  });
}

/** Removes every link pointing at a deleted account. Evidence has a separate lifetime. */
export async function deleteGuardianRecords(db: Firestore, uid: string): Promise<void> {
  const links = await db.collection('guardianTokens').where('uid', '==', uid).get();
  for (const link of links.docs) await link.ref.delete();
}

/** Visits bounded pages, including records created before cleanup was introduced. */
async function visitGuardianRows(query: Query, visit: (row: QueryDocumentSnapshot) => Promise<void>): Promise<void> {
  let cursor: QueryDocumentSnapshot | undefined;
  while (true) {
    const page = await (cursor ? query.startAfter(cursor) : query).limit(200).get();
    if (page.empty) return;
    for (const row of page.docs) await visit(row);
    if (page.size < 200) return;
    cursor = page.docs[page.docs.length - 1];
  }
}

// What survives the trim of a confirmed record. Everything else is contact data.
const KEPT_CONSENT_FIELDS = ['status', 'ageGroup', 'decidedAt', 'sharingAllowed', 'adultSince', 'ageCheckNoticeVersion'];

/** Deletes due contacts and links. Transactions recheck sends and answers that raced the scan. */
export async function purgeGuardianRecords(db: Firestore, now: number): Promise<void> {
  await visitGuardianRows(db.collection('guardianTokens').orderBy(FieldPath.documentId()), async (row) => {
    await db.runTransaction(async (tx) => {
      const data = (await tx.get(row.ref)).data();
      if (!data) return;
      // A manage link has no expiry. It goes when the account goes or when it is revoked.
      if (data.kind === 'manage' && data.state === 'open') return;
      // A later resend must not extend the lifetime of an already used link.
      const eventAt = data.usedAt ?? data.revokedAt;
      if (data.state === 'revoked' && typeof eventAt !== 'number') {
        // Legacy revoked links have no event date and no remaining use.
        tx.delete(row.ref);
        return;
      }
      const due = data.state === 'open' ? data.expiresAt
        : typeof eventAt === 'number' ? eventAt + GUARDIAN_WINDOW_MS
          : typeof data.expiresAt === 'number' ? data.expiresAt + GUARDIAN_WINDOW_MS : null;
      if (typeof due === 'number' && now >= due) tx.delete(row.ref);
    });
  });
  await visitGuardianRows(db.collectionGroup('server').orderBy(FieldPath.documentId()), async (row) => {
    if (row.id !== 'guardianConsent') return;
    await db.runTransaction(async (tx) => {
      const data = (await tx.get(row.ref)).data();
      if (!data) return;
      // A withdrawal in progress stays untouched, whatever its age: the deletion still needs it.
      if (data.status === 'withdrawn') return;
      const due = data.status === 'pending' ? data.expiresAt
        : typeof data.decidedAt === 'number' ? data.decidedAt + GUARDIAN_WINDOW_MS : null;
      if (typeof due !== 'number' || now < due) return;
      if (data.status === 'confirmed') {
        if (Object.keys(data).every((key) => KEPT_CONSENT_FIELDS.includes(key))) return;
        // Keep the gate status, the age group, the sharing choice and the minimum confirmation
        // facts, without contact data (email hash, masked address, link hash, send and expiry times).
        const kept = Object.fromEntries(KEPT_CONSENT_FIELDS.filter((key) => data[key] !== undefined).map((key) => [key, data[key]]));
        tx.set(row.ref, {...kept, ageGroup: data.ageGroup ?? 'minor'});
      } else {
        // An unanswered or declined request loses its contact data and status, but the server
        // must still know the account is under 18: checkout's guardian box depends on it.
        tx.set(row.ref, {ageGroup: data.ageGroup ?? 'minor'});
      }
    });
  });
  await visitGuardianRows(db.collection('guardianLimits').orderBy(FieldPath.documentId()), async (row) => {
    await db.runTransaction(async (tx) => {
      const data = (await tx.get(row.ref)).data();
      if (!data) return;
      // Legacy daily counters contain no date field, but their ID names the day.
      const day = /^global-(\d{4}-\d{2}-\d{2})$/.exec(row.id)?.[1];
      const start = data.windowStartedAt ?? (day ? Date.parse(`${day}T00:00:00+08:00`) : null);
      const due = data.cleanupAt ?? (typeof start === 'number'
        ? start + GUARDIAN_WINDOW_MS + (day ? DAY_MS : 0) : null);
      if (typeof due === 'number' && now >= due) tx.delete(row.ref);
    });
  });
}

export const purgeOldGuardianRecords = onSchedule(
  {schedule: 'every 60 minutes', timeZone: 'Asia/Manila', region: 'asia-southeast1'},
  async () => purgeGuardianRecords(getFirestore(), Date.now()),
);

function runtimeDeps(): ConsentDeps {
  const linkOrigin = process.env.FUNCTIONS_EMULATOR === 'true'
    ? (process.env.GUARDIAN_LINK_ORIGIN || 'http://localhost:7357')
    : guardianLinkOrigin.value();
  return {
    db: getFirestore(),
    // Emulator only: a fixed key so a local run needs no secret file.
    key: process.env.FUNCTIONS_EMULATOR === 'true'
      ? (guardianHmacKey.value() || 'guardian-emulator-only-key') : guardianHmacKey.value(),
    // Built on first send, so reading or answering a link never needs mail settings.
    mailer: {send: (message) => mailerFor(process.env,
      {apiKey: () => guardianMailKey.value(), from: () => guardianMailFrom.value()}).send(message)},
    linkOrigin,
    dailyCap: guardianDailyCap.value(),
    auth: getAuth(),
  };
}

const readOptions = {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, secrets: [guardianHmacKey]};

export const sendGuardianLink = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck,
  secrets: [guardianHmacKey, guardianMailKey]}, timed('sendGuardianLink', (request) => {
  assertFreshAppCheck(request);
  return sendLink(request, runtimeDeps());
}));

export const answerGuardianRequest = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck,
  secrets: [guardianHmacKey, guardianMailKey]}, timed('answerGuardianRequest', (request) => {
  assertFreshAppCheck(request);
  return answerRequest(request, runtimeDeps());
}));

export const getGuardianStatus = onCall(readOptions, timed('getGuardianStatus', (request) => getStatus(request, runtimeDeps())));

export const getGuardianRequest = onCall(readOptions, timed('getGuardianRequest', (request) => readRequest(request, runtimeDeps())));

export const getGuardianManage = onCall(readOptions, timed('getGuardianManage', (request) => readManage(request, runtimeDeps())));

export const setGuardianSharing = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck,
  secrets: [guardianHmacKey]}, timed('setGuardianSharing', (request) => {
  assertFreshAppCheck(request);
  return setSharing(request, runtimeDeps());
}));

export const withdrawGuardianPermission = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck,
  secrets: [guardianHmacKey, trialIdentityKey]}, timed('withdrawGuardianPermission', (request) => {
  assertFreshAppCheck(request);
  return withdraw(request, runtimeDeps());
}));

export const markGuardianAdult = onCall(readOptions, timed('markGuardianAdult', (request) => markAdult(request, runtimeDeps())));
