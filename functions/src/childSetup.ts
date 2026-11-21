import {getAuth, type Auth} from 'firebase-admin/auth';
import {FieldValue, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {accountClosed, assertSignInTargetActive, onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {allowAtMost} from './_limits.js';
import {phDay} from './_phDate.js';
import {appSecrets, secret} from './_secrets.js';
import {timed} from './_timed.js';
import {childEntryPath, childLinkPath, childrenOfHolder, childrenPath, holderForChild} from './childLinks.js';
import {consumeGuardianProof} from './guardianCodeGate.js';
import {CHILD_DOCUMENT_VERSIONS, CHILD_NOTICE_VERSION, GUARDIAN_DOCUMENT_VERSIONS, GUARDIAN_TICK_TEXT_VERSIONS,
  GUARDIAN_WINDOW_MS, guardianDailyCap, guardianLinkOrigin, guardianMailFrom, maskEmail} from './guardianConsent.js';
import {expiryLabel, mailerFor, type GuardianMailer, type GuardianMessage} from './guardianMail.js';

/**
 * Holder and child accounts: the setup callable and the callables a child session uses.
 * Spec B2 rules 1, 4, 4a, 4d, 5, 6, 7 and 10; Decisions 5, 6, 9 and 10.
 *
 * The holder is the parent or guardian's named sign-in. It holds no study data (the server refuses study
 * and checkout on it). Each child is a separate emailless Firebase user linked to the holder through the
 * documents in `childLinks.ts`. The server issues a child's session as a custom token. Setup is closed
 * unless the server flag `CHILD_ACCOUNTS_OPEN` is `true` (Decision 9, item 9).
 */

export const CHILD_LIMIT = 5;
const HOLDER_PATH = (uid: string): string => `users/${uid}/server/holder`;
const CONSENT_PATH = (uid: string): string => `users/${uid}/server/guardianConsent`;
const NICKNAME_MAX = 30;
const SETUPS_PER_HOUR = 10;
const OPENS_PER_HOUR = 60;
const NICKNAMES_PER_HOUR = 20;
const HOUR_MS = 3_600_000;
const DAY_MS = 86_400_000;

/** The server flag. Read at call time so it is never frozen into a deploy. */
export const childAccountsOpen = (): boolean => process.env.CHILD_ACCOUNTS_OPEN === 'true';

export type SetupDeps = {
  db: Firestore;
  auth: Pick<Auth, 'getUser' | 'createUser' | 'setCustomUserClaims' | 'deleteUser' | 'createCustomToken'>;
  mailer: GuardianMailer;
  /** The app origin the receipt's delete link opens, such as `https://app.pantas.study`. */
  linkOrigin: string;
  /** Most guardian mails per Philippine day, shared with guardian consent mail and guardian codes. */
  dailyCap: number;
  now?: () => number;
  open?: () => boolean;
  allow?: (uid: string, bucket: string, max: number, windowMs: number) => Promise<boolean>;
};

type Req = Pick<CallableRequest, 'auth' | 'app' | 'data'>;

function assertCaller(request: Req): {uid: string; provider: string | undefined} {
  if (!request.auth || (enforceAppCheck && !request.app)) {
    throw new HttpsError('unauthenticated', 'Authentication and App Check are required.');
  }
  assertFreshAppCheck(request);
  const token = request.auth.token as {firebase?: {sign_in_provider?: string}} | undefined;
  return {uid: request.auth.uid, provider: token?.firebase?.sign_in_provider};
}

const notLinked = (): HttpsError => new HttpsError('permission-denied', 'This account is not linked to that child.',
  {reason: 'not-linked'});
const ID = /^[^/\s]{1,128}$/;

// ---------------------------------------------------------------- nickname

// eslint-disable-next-line no-control-regex
const CONTROL = /[\u0000-\u001f\u007f-\u009f]/;

/**
 * A nickname is stored on the server and goes into an email the parent reads, so it carries no markup,
 * address or link. The child picks it; it is never filled in from a profile.
 */
export function cleanNickname(value: unknown): string {
  const bad = (): HttpsError => new HttpsError('invalid-argument', 'Enter a nickname of 1 to 30 characters.',
    {reason: 'invalid-nickname'});
  if (typeof value !== 'string' || CONTROL.test(value)) throw bad();
  const trimmed = value.trim().replace(/ +/g, ' ');
  if ([...trimmed].length < 1 || [...trimmed].length > NICKNAME_MAX) throw bad();
  if (/[<>@\\]|:\/\/|\.\p{L}|www\./iu.test(trimmed)) throw bad();
  return trimmed;
}

// ------------------------------------------------------------ the receipt

const escapeHtml = (value: string): string =>
  value.replace(/[&<>"']/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c] as string));

const ink = '#1D1D1F';
const muted = '#6E6E73';
const accent = '#0B7A68';
const font = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

/**
 * The receipt to the holder, one per child. Words from the legal draft, section 6. The link only opens the
 * app's delete flow after sign-in; it carries no token that could delete by itself.
 */
export function childReceiptMessage(input: {to: string; nickname: string; date: string; noticeVersion: string;
  deleteLink: string}): GuardianMessage {
  const {nickname} = input;
  const body = `You set up a Pantas account for ${nickname} on ${input.date}. You accepted the Terms and agreed to the ` +
    `Child Notice (version ${input.noticeVersion}). If you want to delete ${nickname}'s account and data, use the button ` +
    'below. You can also do this in the app under "For parents." We send one email for each child.';
  const label = 'Delete account';
  const text = `Hi,\n\n${body}\n\n${label}: ${input.deleteLink}`;
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"></head>` +
    `<body style="margin:0;padding:24px 16px;background:#FFFFFF;color:${ink};font-family:${font}">` +
    `<div style="max-width:560px;margin:0 auto">` +
    `<p style="margin:0 0 16px;font-size:16px;line-height:1.6">Hi,</p>` +
    `<p style="margin:0 0 16px;font-size:16px;line-height:1.6">${escapeHtml(body)}</p>` +
    `<p style="margin:8px 0 24px"><a href="${escapeHtml(input.deleteLink)}" style="display:inline-block;padding:12px 24px;` +
    `border-radius:12px;background:${accent};color:#FFFFFF;font-size:16px;font-weight:600;text-decoration:none">${label}</a></p>` +
    `<p style="margin:0;font-size:13px;line-height:1.6;color:${muted}">${escapeHtml(input.deleteLink)}</p>` +
    `</div></body></html>`;
  return {to: input.to, subject: `Pantas account for ${nickname}`, text, html};
}

const millis = (value: unknown): number => {
  if (typeof value === 'number') return value;
  const toMillis = (value as {toMillis?: unknown} | null | undefined)?.toMillis;
  return typeof toMillis === 'function' ? Number(toMillis.call(value)) : 0;
};

/**
 * Sends the receipt for one child, once, when the child has a nickname. It never throws: the setup or the
 * nickname that called it has already succeeded. The slot is claimed in a transaction (receiptSentAt plus one
 * on the guardian daily counter that codes and consent mail also use) and given back if the mail fails, so a
 * failed or capped receipt is tried again at the next nickname change. There is no job that retries it.
 */
async function sendReceipt(deps: SetupDeps, holderUid: string, childUid: string): Promise<void> {
  const at = (deps.now ?? Date.now)();
  const day = phDay(at);
  const entryRef = deps.db.doc(childEntryPath(holderUid, childUid));
  const consentRef = deps.db.doc(CONSENT_PATH(childUid));
  const globalRef = deps.db.doc(`guardianLimits/global-${day}`);
  const cap = deps.dailyCap;
  try {
    const claim = await deps.db.runTransaction(async tx => {
      const [entry, consent, global] = await Promise.all([tx.get(entryRef), tx.get(consentRef), tx.get(globalRef)]);
      const nickname: unknown = entry.get('nickname');
      if (!entry.exists || entry.get('active') !== true || typeof nickname !== 'string' || nickname === '' ||
          entry.get('receiptSentAt') !== undefined) return {kind: 'skip' as const};
      const sentToday = Number(global.get('count') ?? 0);
      if (!Number.isFinite(cap) || cap < 1 || sentToday + 1 > cap) {
        const firstFull = global.get('fullLogged') !== true;
        if (firstFull) tx.set(globalRef, {fullLogged: true, purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS)}, {merge: true});
        return {kind: 'full' as const, firstFull};
      }
      const becameFull = sentToday + 1 >= cap && global.get('fullLogged') !== true;
      tx.set(globalRef, {count: sentToday + 1, purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS),
        ...(becameFull ? {fullLogged: true} : {})}, {merge: true});
      tx.update(entryRef, {receiptSentAt: at});
      const noticeVersion: unknown = consent.get('childNoticeVersion');
      return {kind: 'claimed' as const, nickname, becameFull, createdAt: millis(entry.get('createdAt')),
        noticeVersion: typeof noticeVersion === 'string' ? noticeVersion : CHILD_NOTICE_VERSION};
    });
    if (claim.kind === 'skip') return;
    if (claim.kind === 'full') {
      if (claim.firstFull) logger.error(`Mail cap full: guardian bucket, ${day}.`, {event: 'mail_cap_full', bucket: 'guardian', day, cap});
      return;
    }
    if (claim.becameFull) logger.error(`Mail cap full: guardian bucket, ${day}.`, {event: 'mail_cap_full', bucket: 'guardian', day, cap});
    try {
      const email = (await deps.auth.getUser(holderUid)).email;
      const origin = deps.linkOrigin.replace(/\/+$/, '');
      if (!email || !origin) throw new Error('no address or link origin');
      await deps.mailer.send(childReceiptMessage({to: email, nickname: claim.nickname,
        date: expiryLabel(claim.createdAt || at), noticeVersion: claim.noticeVersion,
        deleteLink: `${origin}/parents/delete?child=${encodeURIComponent(childUid)}`}));
    } catch (error) {
      logger.warn('Child receipt email failed', {message: error instanceof Error ? error.message : 'unknown'});
      await deps.db.runTransaction(async tx => {
        const global = await tx.get(globalRef);
        tx.update(entryRef, {receiptSentAt: FieldValue.delete()});
        if (global.exists) tx.set(globalRef, {count: Math.max(0, Number(global.get('count') ?? 0) - 1),
        purgeAt: new Date(at + DAY_MS + GUARDIAN_WINDOW_MS)}, {merge: true});
      });
    }
  } catch (error) {
    logger.warn('Child receipt not sent', {message: error instanceof Error ? error.message : 'unknown'});
  }
}

// ------------------------------------------------------------------ setup

const BENIGN_SERVER_DOCS = new Set(['holder', 'children', 'inactivity']);
const BENIGN_COLLECTIONS = new Set(['server', 'limits']);

/**
 * Whether a named account is already somebody's account: a profile, any study data or entitlement, or an
 * age record. Rate-limit counters, the sign-in time and the holder's own link documents do not count.
 * Anything this does not recognize as empty counts as data, so the refusal errs on the side of the
 * existing user.
 */
async function hasAccountData(db: Firestore, uid: string, claims: {[key: string]: unknown} | undefined): Promise<boolean> {
  if (claims && (claims.pro !== undefined || claims.proUntil !== undefined)) return true;
  const userRef = db.doc(`users/${uid}`);
  const root = await userRef.get();
  if (root.exists && Object.keys(root.data() ?? {}).some(key => key !== 'createdAt' && key !== 'lastSeenAt')) return true;
  if ((await db.doc(CONSENT_PATH(uid)).get()).exists) return true;
  const serverDocs = await userRef.collection('server').listDocuments();
  if (serverDocs.some(ref => !BENIGN_SERVER_DOCS.has(ref.id))) return true;
  for (const collection of await userRef.listCollections()) {
    if (BENIGN_COLLECTIONS.has(collection.id)) continue;
    if (!(await collection.limit(1).get()).empty) return true;
  }
  return false;
}

const stale = (): HttpsError => new HttpsError('failed-precondition', 'Reload to review the current terms.',
  {reason: 'stale-consent-text'});

export async function setupChild(request: Req, deps: SetupDeps): Promise<{childUid: string; customToken: string}> {
  const {uid, provider} = assertCaller(request);
  const now = (deps.now ?? Date.now)();
  if (!(deps.open ?? childAccountsOpen)()) {
    throw new HttpsError('failed-precondition', 'Child accounts are not open yet.', {reason: 'child-accounts-closed'});
  }
  const data = (request.data ?? {}) as Record<string, unknown>;
  if (data.tick1TextVersion !== GUARDIAN_TICK_TEXT_VERSIONS.tick1 || data.tick2TextVersion !== GUARDIAN_TICK_TEXT_VERSIONS.tick2 ||
      data.termsVersion !== GUARDIAN_DOCUMENT_VERSIONS.terms || data.childNoticeVersion !== CHILD_NOTICE_VERSION) throw stale();
  const nickname = data.nickname === undefined || data.nickname === null || data.nickname === '' ? '' : cleanNickname(data.nickname);

  // A named sign-in: not anonymous, not a child, with a verified email on the Auth record.
  const namedRequired = (): HttpsError => new HttpsError('permission-denied',
    'A parent or guardian must sign in with an email or Google.', {reason: 'named-sign-in-required'});
  if (provider === undefined || provider === 'anonymous') throw namedRequired();
  const childCaller = (): HttpsError =>
    new HttpsError('permission-denied', 'A child account cannot set up another account.', {reason: 'child-cannot-set-up'});
  if ((request.auth?.token as {ageGroup?: unknown} | undefined)?.ageGroup === 'child' ||
      await holderForChild(deps.db, uid) !== null) throw childCaller();
  const user = await deps.auth.getUser(uid).catch(() => null);
  if (!user) throw new HttpsError('unauthenticated', 'Authentication is required.');
  if (user.customClaims?.ageGroup === 'child') throw childCaller();
  if (!user.email || !user.emailVerified) throw namedRequired();
  if (!await (deps.allow ?? allowAtMost)(uid, 'setupChildAccount', SETUPS_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }

  // Classify the caller: an existing holder, or an empty named account that becomes one.
  const active = await childrenOfHolder(deps.db, uid);
  const holderExists = (await deps.db.doc(HOLDER_PATH(uid)).get()).exists;
  let needsProof = false;
  if (holderExists || active.length > 0) {
    if (active.length >= CHILD_LIMIT) throw childLimit();
    needsProof = active.length >= 1;
  } else if (await hasAccountData(deps.db, uid, user.customClaims)) {
    throw new HttpsError('failed-precondition', 'This email already has a Pantas account. Use another email.',
      {reason: 'email-has-account'});
  }
  // Every refusal above happens before the proof is used up.
  if (needsProof) await consumeGuardianProof(data.guardianProofId, uid, null, 'addChild', {db: deps.db, now: () => now});

  const child = await deps.auth.createUser({});
  const childUid = child.uid;
  try {
    await deps.auth.setCustomUserClaims(childUid, {ageGroup: 'child', holder: uid});
    const customToken = await deps.auth.createCustomToken(childUid);
    const holderRef = deps.db.doc(HOLDER_PATH(uid));
    await deps.db.runTransaction(async tx => {
      const [holder, items, deletion] = await Promise.all([tx.get(holderRef),
        tx.get(deps.db.collection(childrenPath(uid))), tx.get(deps.db.doc(`accountDeletions/${uid}`))]);
      if (deletion.exists) throw accountClosed();
      const count = items.docs.filter(row => row.get('active') === true).length;
      if (count >= CHILD_LIMIT) throw childLimit();
      // Another setup finished first on an account that had no children: this call holds no proof.
      if (!needsProof && count > 0) throw new HttpsError('aborted', 'Another setup was running. Try again.');
      if (!holder.exists) tx.set(holderRef, {createdAt: now});
      tx.set(deps.db.doc(childEntryPath(uid, childUid)),
        {childUid, nickname, active: true, siblingOpenWithoutCode: false, createdAt: now});
      tx.set(deps.db.doc(childLinkPath(childUid)), {holderUid: uid});
      // The record every existing gate reads as restricted. The client never writes it.
      tx.set(deps.db.doc(CONSENT_PATH(childUid)), {ageGroup: 'child', method: 'guardian_held', status: 'confirmed',
        holderUid: uid, decidedAt: now, sharingAllowed: false, termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms,
        childNoticeVersion: CHILD_NOTICE_VERSION});
      // Outside the user tree, so deletion keeps it. Holds no email, name or nickname.
      tx.set(deps.db.collection(`guardianConsentEvidence/${childUid}/responses`).doc(), {
        action: 'child_setup', ageGroup: 'child', method: 'guardian_held', holderUid: uid, childUid,
        link: {holderUid: uid, childUid}, documentVersions: CHILD_DOCUMENT_VERSIONS,
        tickTextVersions: {tick1: GUARDIAN_TICK_TEXT_VERSIONS.tick1, tick2: GUARDIAN_TICK_TEXT_VERSIONS.tick2},
        decidedAt: now});
    });
    if (nickname !== '') await sendReceipt(deps, uid, childUid);
    return {childUid, customToken};
  } catch (error) {
    // Nothing was committed, so the unused Auth user goes too. Leaving it would be an unlinked orphan.
    await deps.auth.deleteUser(childUid).catch(() => undefined);
    throw error;
  }
}

const childLimit = (): HttpsError => new HttpsError('failed-precondition',
  'You have reached 5 children on this email. Email support@pantas.study if you need more.', {reason: 'child-limit'});

// --------------------------------------------------------------- nickname

/** The child session names itself. The parent gets the receipt once there is a nickname to put in it. */
export async function setNickname(request: Req, deps: SetupDeps): Promise<{nickname: string}> {
  const {uid} = assertCaller(request);
  const data = (request.data ?? {}) as {childId?: unknown; nickname?: unknown};
  if (typeof data.childId !== 'string' || !ID.test(data.childId)) throw new HttpsError('invalid-argument', 'Name the child.');
  if (data.childId !== uid) throw notLinked();
  const holderUid = await holderForChild(deps.db, uid);
  if (!holderUid) throw notLinked();
  const nickname = cleanNickname(data.nickname);
  if (!await (deps.allow ?? allowAtMost)(uid, 'setChildNickname', NICKNAMES_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await deps.db.doc(childEntryPath(holderUid, uid)).update({nickname});
  await sendReceipt(deps, holderUid, uid);
  return {nickname};
}

// ------------------------------------------------------------------- list

export type ChildRow = {childUid: string; nickname: string; siblingOpenWithoutCode: boolean};

/** For the holder or any linked child. The full email never leaves the server. */
export async function listChildrenFor(request: Req, deps: Pick<SetupDeps, 'db' | 'auth'>):
  Promise<{children: ChildRow[]; maskedHolderEmail: string | null}> {
  const {uid} = assertCaller(request);
  const holderUid = await holderForChild(deps.db, uid) ?? uid;
  const rows = await childrenOfHolder(deps.db, holderUid);
  if (rows.length === 0) throw notLinked();
  const email = (await deps.auth.getUser(holderUid).catch(() => null))?.email;
  const children = rows.sort((a, b) => a.createdAt - b.createdAt || (a.childUid < b.childUid ? -1 : 1))
    .map(({childUid, nickname, siblingOpenWithoutCode}) => ({childUid, nickname, siblingOpenWithoutCode}));
  return {children, maskedHolderEmail: email ? maskEmail(email) : null};
}

// ------------------------------------------------------------------- open

/**
 * A session for one child. The holder just signed in with its email, so it needs no code. A sibling needs a
 * `switchInto` proof for that child unless the child's own opt-in is on. A child opening itself needs
 * nothing. The device drops the holder session and wipes local state before it uses the token.
 */
export async function openSession(request: Req, deps: Pick<SetupDeps, 'db' | 'auth' | 'now' | 'allow'>):
  Promise<{customToken: string}> {
  const {uid} = assertCaller(request);
  const data = (request.data ?? {}) as {childId?: unknown; guardianProofId?: unknown};
  if (typeof data.childId !== 'string' || !ID.test(data.childId)) throw new HttpsError('invalid-argument', 'Name the child.');
  const childId = data.childId;
  const holderUid = await holderForChild(deps.db, childId);
  if (!holderUid) throw notLinked();
  const isHolder = uid === holderUid;
  if (!isHolder && uid !== childId && await holderForChild(deps.db, uid) !== holderUid) throw notLinked();
  if (!await (deps.allow ?? allowAtMost)(uid, 'openChildSession', OPENS_PER_HOUR, HOUR_MS)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await assertSignInTargetActive(deps.db, childId, uid);
  if (!isHolder && uid !== childId) {
    const entry = await deps.db.doc(childEntryPath(holderUid, childId)).get();
    if (entry.get('siblingOpenWithoutCode') !== true) {
      await consumeGuardianProof(data.guardianProofId, holderUid, childId, 'switchInto',
        {db: deps.db, now: deps.now});
    }
  }
  try {
    return {customToken: await deps.auth.createCustomToken(childId)};
  } catch (error) {
    // Usually the runtime service account lacks the Service Account Token Creator role.
    logger.error('Could not create a custom token', {message: error instanceof Error ? error.message : 'unknown'});
    throw new HttpsError('unavailable', 'Sign-in is unavailable. Try again soon.');
  }
}

// ------------------------------------------------------------- deployment

function runtimeDeps(): SetupDeps {
  return {db: getFirestore(), auth: getAuth(), dailyCap: guardianDailyCap.value(),
    linkOrigin: process.env.FUNCTIONS_EMULATOR === 'true'
      ? (process.env.GUARDIAN_LINK_ORIGIN || 'http://localhost:7357') : guardianLinkOrigin.value(),
    mailer: {send: message => mailerFor(process.env,
      {apiKey: () => secret('GUARDIAN_MAIL_API_KEY'), from: () => guardianMailFrom.value()}).send(message)}};
}

export const setupChildAccount = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [appSecrets]}, timed('setupChildAccount', request => {
  assertFreshAppCheck(request);
  return setupChild(request, runtimeDeps());
}));

export const setChildNickname = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck, secrets: [appSecrets]}, timed('setChildNickname', request => {
  assertFreshAppCheck(request);
  return setNickname(request, runtimeDeps());
}));

export const listChildren = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('listChildren', request => listChildrenFor(request, runtimeDeps())));

export const openChildSession = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck,
  consumeAppCheckToken: enforceAppCheck}, timed('openChildSession', request => {
  assertFreshAppCheck(request);
  return openSession(request, runtimeDeps());
}));
