/** All beta windows use Philippine dates (UTC+8, no daylight saving). */
export const BETA_DAYS = Array.from({length: 7}, (_, i) => `2026-11-${String(9 + i).padStart(2, '0')}`);
export const SURVEY_OPENS_AT = Date.parse('2026-11-15T00:00:00+08:00');
export const SURVEY_CLOSES_AT = Date.parse('2026-11-23T00:00:00+08:00');
export const ACTIVATION_DEADLINE = Date.parse('2028-01-01T00:00:00+08:00');
export const manilaDate = (ms: number): string => new Date(ms + 8 * 60 * 60_000).toISOString().slice(0, 10);
export const isBetaDay = (ms: number): boolean => BETA_DAYS.includes(manilaDate(ms));
export const isSurveyOpen = (ms: number): boolean => ms >= SURVEY_OPENS_AT && ms < SURVEY_CLOSES_AT;

import {timed} from './_timed.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {getAuth, type Auth} from 'firebase-admin/auth';
import {getStorage} from 'firebase-admin/storage';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {examCatalog} from './revenuecatPasses.js';
import type {PriceTier} from './revenuecatCoverage.js';
import type {Grant} from './grants.js';
import {claimsFromInputs, entitlementWrite, nativeCoverageRows, readEntitlementInputs} from './entitlementInputs.js';
import {copyEntitlementClaims} from './revenuecatClaims.js';
import {selectedBetaApplication} from './betaAccess.js';

type Request = Pick<CallableRequest, 'auth' | 'app' | 'data'>;
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string) => Promise<boolean>;
  auth?: Pick<Auth, 'getUser' | 'setCustomUserClaims'>;
  metadata?: (path: string) => Promise<{contentType?: string; size?: string | number}>};
const invalid = (message: string): never => {throw new HttpsError('invalid-argument', message);};
const object = (value: unknown): Record<string, unknown> => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return invalid('Send a valid request.');
  return value as Record<string, unknown>;
};
function caller(request: Request): string {
  if (!request.app) throw new HttpsError('unauthenticated', 'App Check is required.');
  assertFreshAppCheck(request);
  return assertNamedUser(request.auth);
}
async function guard(request: Request, deps: Deps, uid: string, key: string, max: number, window = 86_400_000) {
  if (!await (deps.allow ?? (id => allowAtMost(id, key, max, window)))(uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  if (!await selectedBetaApplication(request.auth, deps.db)) {
    throw new HttpsError('permission-denied', 'This account is not on the beta list.');
  }
}
const options = {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck};
const types = ['image/png', 'image/jpeg', 'image/webp'];
export const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
function optionalText(data: Record<string, unknown>, key: string, max: number): Record<string, string> {
  const value = data[key];
  if (value === undefined) return {};
  if (typeof value !== 'string' || value.length > max) return invalid(`Invalid ${key}.`);
  return {[key]: value};
}
export async function sendFeedback(request: Request, deps: Deps) {
  const uid = caller(request), data = object(request.data);
  const {feedbackId, attachments} = data;
  if (typeof feedbackId !== 'string' || !/^[A-Za-z0-9]{20,32}$/.test(feedbackId)) invalid('Invalid feedback ID.');
  if (typeof data.text !== 'string' || data.text.trim().length > 4000) invalid('Feedback must be at most 4000 characters.');
  if (!Array.isArray(attachments) || attachments.length > 3) invalid('Attach at most 3 images.');
  const text = (data.text as string).trim();
  const images = (attachments as unknown[]).map(value => {
    const image = object(value);
    if (typeof image.path !== 'string' || ![0, 1, 2].some(i => image.path === `betaFeedback/${uid}/${feedbackId}/${i}`) ||
        typeof image.contentType !== 'string' || !types.includes(image.contentType)) invalid('Invalid image attachment.');
    return {path: image.path as string, contentType: image.contentType as string};
  });
  if (new Set(images.map(image => image.path)).size !== images.length) invalid('Each image must have its own path.');
  if (!text && !images.length) invalid('Write feedback or attach an image.');
  const context = {...optionalText(data, 'userAgent', 300), ...optionalText(data, 'appVersion', 40)};
  if (data.examId !== undefined && typeof data.examId !== 'string') invalid('Invalid exam ID.');
  await guard(request, deps, uid, 'betaFeedback', 40);
  const ref = deps.db.doc(`users/${uid}/betaFeedback/${feedbackId}`);
  return deps.db.runTransaction(async tx => {
    const previous = await tx.get(ref);
    if (previous.exists) return {feedbackId: feedbackId as string, createdAt: previous.get('createdAt') as number};
    const checked = await Promise.all(images.map(async image => {
      let metadata;
      try {
        metadata = await (deps.metadata ?? (async path => {
          const [row] = await getStorage().bucket().file(path).getMetadata();
          return row;
        }))(image.path);
      } catch (error) {
        if ((error as {code?: unknown}).code === 404) return invalid('An attached image is missing.');
        throw error;
      }
      const size = Number(metadata.size);
      if (metadata.contentType !== image.contentType || !Number.isSafeInteger(size) || size < 0 || size > MAX_IMAGE_BYTES) {
        invalid('An attached image has an invalid type or size.');
      }
      return {...image, size};
    }));
    const createdAt = (deps.now ?? Date.now)();
    tx.set(ref, {text, attachments: checked, createdAt, ...context,
      ...(data.examId === undefined ? {} : {examId: data.examId})});
    return {feedbackId: feedbackId as string, createdAt};
  });
}
export const sendBetaFeedback = onCall(options, timed('sendBetaFeedback', request => sendFeedback(request, {db: getFirestore()})));

type RewardState = {days?: string[]; surveyAt?: number; activatedAt?: number; grantId?: string;
  rewardStartsAt?: number; rewardEndsAt?: number; exams?: number};
const validDays = (state: RewardState): string[] => [...new Set(state.days ?? [])].filter(day => BETA_DAYS.includes(day)).sort();
const eligible = (state: RewardState, now: number): boolean => validDays(state).length >= 5 &&
  state.surveyAt !== undefined && state.activatedAt === undefined && now < ACTIVATION_DEADLINE;
function emptyInput(request: Request) {
  if (Object.keys(object(request.data)).length) invalid('Send an empty request.');
}
export async function recordDay(request: Request, deps: Deps) {
  const uid = caller(request), data = object(request.data);
  if (data.kind !== 'plan' && data.kind !== 'restDay') invalid('Choose a plan or rest day.');
  await guard(request, deps, uid, 'betaDay', 20);
  const ref = deps.db.doc(`users/${uid}/betaReward/state`);
  return deps.db.runTransaction(async tx => {
    const state = (await tx.get(ref)).data() as RewardState | undefined ?? {};
    const days = validDays(state), now = (deps.now ?? Date.now)();
    if (!isBetaDay(now)) return {recorded: false, reason: 'outside' as const, days};
    const day = manilaDate(now), recorded = !days.includes(day);
    if (recorded) {days.push(day); days.sort(); tx.set(ref, {days}, {merge: true});}
    return {recorded, days};
  });
}
export async function rewardStatus(request: Request, deps: Deps) {
  const uid = caller(request); emptyInput(request);
  await guard(request, deps, uid, 'betaRewardStatus', 120, 10 * 60_000);
  if (deps.auth) await refreshRewardClaims(deps.db, deps.auth, uid, (deps.now ?? Date.now)());
  return deps.db.runTransaction(async tx => {
    const state = (await tx.get(deps.db.doc(`users/${uid}/betaReward/state`))).data() as RewardState | undefined ?? {};
    return {days: validDays(state), betaDays: BETA_DAYS, surveyOpensAt: SURVEY_OPENS_AT, surveyClosesAt: SURVEY_CLOSES_AT,
      surveySubmitted: state.surveyAt !== undefined, eligible: eligible(state, (deps.now ?? Date.now)()),
      activatedAt: state.activatedAt ?? null, rewardStartsAt: state.rewardStartsAt ?? null,
      rewardEndsAt: state.rewardEndsAt ?? null, activationDeadline: ACTIVATION_DEADLINE};
  });
}
export const recordBetaDay = onCall(options, timed('recordBetaDay', request => recordDay(request, {db: getFirestore()})));
export const getBetaReward = onCall(options, timed('getBetaReward', request => rewardStatus(request, {db: getFirestore(), auth: getAuth()})));

export async function submitSurvey(request: Request, deps: Deps) {
  const uid = caller(request), data = object(request.data), answers = object(data.answers);
  const {usage, ease, usefulness, continue: keep, recommend, improve, other} = answers;
  const integer = (v: unknown, low: number, high: number) => typeof v === 'number' && Number.isInteger(v) && v >= low && v <= high;
  if (typeof usage !== 'string' || !['every_day', 'most_days', 'few_days', 'once'].includes(usage) ||
      !integer(ease, 1, 5) || !integer(usefulness, 1, 5) || typeof keep !== 'string' || !['yes', 'maybe', 'no'].includes(keep) ||
      !integer(recommend, 0, 10) || typeof improve !== 'string' || !improve.trim() || improve.trim().length > 2000 ||
      (other !== undefined && (typeof other !== 'string' || other.length > 2000))) invalid('Answer each survey question.');
  await guard(request, deps, uid, 'betaSurvey', 20);
  const survey = deps.db.doc(`users/${uid}/betaReward/survey`), state = deps.db.doc(`users/${uid}/betaReward/state`);
  return deps.db.runTransaction(async tx => {
    const previous = await tx.get(survey), submittedAt = (deps.now ?? Date.now)();
    if (!isSurveyOpen(submittedAt)) throw new HttpsError('failed-precondition', 'The survey is not open.');
    if (previous.exists) throw new HttpsError('already-exists', 'Your survey was already sent.');
    tx.set(survey, {answers: {usage, ease, usefulness, continue: keep, recommend, improve: (improve as string).trim(),
      ...(other === undefined ? {} : {other: (other as string).trim()})}, submittedAt});
    tx.set(state, {surveyAt: submittedAt}, {merge: true});
    return {submittedAt};
  });
}
export const submitBetaSurvey = onCall(options, timed('submitBetaSurvey', request => submitSurvey(request, {db: getFirestore()})));

/** One calendar year in Manila, with leap day clamped to February 28. */
export function calendarYearEnd(start: number): number {
  const local = new Date(start + 8 * 60 * 60_000), month = local.getUTCMonth();
  local.setUTCFullYear(local.getUTCFullYear() + 1);
  if (local.getUTCMonth() !== month) local.setUTCDate(0);
  return local.getTime() - 8 * 60 * 60_000;
}

/** Queued rewards need fresh claims when their start arrives. Both discovery callables use this. */
export async function refreshRewardClaims(db: Firestore, auth: Pick<Auth, 'getUser' | 'setCustomUserClaims'>,
  uid: string, at: number) {
  await db.runTransaction(async tx => {
    const inputs = await readEntitlementInputs(tx, db, uid);
    if (![...inputs.grants.values()].some(g => g.source === 'beta_reward')) return;
    const claims = claimsFromInputs(inputs, at);
    if (inputs.record.get('pro') !== claims.pro || inputs.record.get('proUntil') !== claims.proUntil) {
      tx.set(inputs.record.ref, entitlementWrite(inputs, claims), {merge: true});
    }
  });
  await copyEntitlementClaims(db, auth, uid);
}

export async function activateReward(request: Request, deps: Deps) {
  const uid = caller(request); emptyInput(request);
  await guard(request, deps, uid, 'betaRewardActivate', 20);
  const result = await deps.db.runTransaction(async tx => {
    const ref = deps.db.doc(`users/${uid}/betaReward/state`);
    const state = (await tx.get(ref)).data() as RewardState | undefined ?? {};
    if (state.activatedAt !== undefined) return {startsAt: state.rewardStartsAt!, endsAt: state.rewardEndsAt!, exams: state.exams!};
    const now = (deps.now ?? Date.now)();
    if (now >= ACTIVATION_DEADLINE) throw new HttpsError('failed-precondition', 'The activation deadline has passed.');
    if (validDays(state).length < 5) throw new HttpsError('failed-precondition', 'Finish 5 beta days first.');
    if (state.surveyAt === undefined) throw new HttpsError('failed-precondition', 'Send the survey first.');
    const inputs = await readEntitlementInputs(tx, deps.db, uid);
    const existing = [...inputs.grants.values(), ...nativeCoverageRows(inputs, now)]
      .filter(g => g.source !== 'beta' && g.source !== 'beta_reward');
    const tiers: Record<string, PriceTier> = {'Student': 'student', 'Civil Service': 'civilService', 'Licensure': 'licensure', 'PSHS-NCE': 'nce'};
    const grants = new Map(inputs.grants);
    let startsAt = Infinity, endsAt = 0;
    // Exams added after activation need a separate grant policy.
    for (const exam of examCatalog) {
      const tier = tiers[(exam as typeof exam & {priceTier: string}).priceTier];
      if (!tier) throw new Error(`Unknown catalog tier for ${exam.id}`);
      let start = now;
      for (const row of existing) {
        if (row.state !== 'active' || row.startsAt > now || row.endsAt <= now) continue;
        const covered = row.examId ? row.examId === exam.id :
          row.tier === 'nce' ? tier === 'nce' : tier !== 'nce' &&
          ['student', 'civilService', 'licensure'].indexOf(row.tier) >= ['student', 'civilService', 'licensure'].indexOf(tier);
        if (covered) start = Math.max(start, row.endsAt);
      }
      const grant: Grant = {source: 'beta_reward', product: 'beta_reward', tier, examId: exam.id,
        startsAt: start, endsAt: calendarYearEnd(start), state: 'active', createdAt: now};
      grants.set(`beta_reward_${exam.id}`, grant);
      startsAt = Math.min(startsAt, start); endsAt = Math.max(endsAt, grant.endsAt);
    }
    for (const [id, grant] of grants) if (grant.source === 'beta_reward') tx.set(deps.db.doc(`users/${uid}/grants/${id}`), grant);
    tx.set(ref, {activatedAt: now, rewardStartsAt: startsAt, rewardEndsAt: endsAt, exams: examCatalog.length}, {merge: true});
    tx.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, now, grants)), {merge: true});
    return {startsAt, endsAt, exams: examCatalog.length};
  });
  if (deps.auth) await refreshRewardClaims(deps.db, deps.auth, uid, (deps.now ?? Date.now)());
  return result;
}
export const activateBetaReward = onCall(options, timed('activateBetaReward', request => activateReward(request, {db: getFirestore(), auth: getAuth()})));
