import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {checkAnswers, checkDuration} from './_answers.js';
import {hasLiveProClaim} from './_pro.js';
import {examCatalog} from './revenuecatPasses.js';

export {MAX_ANSWERS} from './_answers.js';

export const FREE_MOCK_WINDOW_MS = 30 * 86_400_000;
const mocks = (db: Firestore, uid: string) => db.collection(`users/${uid}/server/mocks/items`);

export type MockDeps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
type Auth = Parameters<typeof assertNamedUser>[0] & {token: {pro?: unknown; proUntil?: unknown}};

const allowDefault = (uid: string, key: string) => allowAtMost(uid, key, 30, 60 * 60_000);

/**
 * Starts a mock. Needs a named account. Free: refused if the last mock that was not abandoned
 * started less than 30 days ago (rolling from that start). Pro: unlimited. Records the mock on
 * the server; building the paper on the server comes later.
 */
export async function beginMock(auth: Auth, data: unknown, deps: MockDeps):
  Promise<{mockId: string; examId: string; startedAt: number}> {
  const uid = assertNamedUser(auth);
  const examId = (data as {examId?: unknown} | null)?.examId;
  if (typeof examId !== 'string' || !examCatalog.some((exam) => exam.id === examId)) {
    throw new HttpsError('invalid-argument', 'Unknown exam.');
  }
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowDefault)(uid, 'startMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const unlimited = hasLiveProClaim(auth?.token, now);
  const ref = mocks(deps.db, uid).doc();
  await deps.db.runTransaction(async (transaction) => {
    if (!unlimited) {
      const recent = await transaction.get(mocks(deps.db, uid).where('startedAt', '>', now - FREE_MOCK_WINDOW_MS));
      if (recent.docs.some((doc) => doc.get('status') !== 'abandoned')) {
        throw new HttpsError('failed-precondition', 'Free accounts can start one mock every 30 days.');
      }
    }
    transaction.create(ref, {examId, status: 'started', startedAt: now});
  });
  return {mockId: ref.id, examId, startedAt: now};
}

/** Records a submission (or an abandon) once. A repeat call changes nothing. */
export async function recordMock(auth: Auth, data: unknown, deps: MockDeps): Promise<{mockId: string; status: string}> {
  const uid = assertNamedUser(auth);
  const body = data as {mockId?: unknown; answers?: unknown; durationMs?: unknown; abandoned?: unknown} | null;
  const mockId = body?.mockId;
  if (typeof mockId !== 'string' || !/^[A-Za-z0-9]{10,40}$/.test(mockId)) throw new HttpsError('invalid-argument', 'Bad mock id.');
  const now = (deps.now ?? Date.now)();
  const abandoned = body?.abandoned === true;
  const answers = abandoned ? undefined : checkAnswers(body?.answers, now);
  const durationMs = abandoned ? undefined : checkDuration(body?.durationMs);
  if (!await (deps.allow ?? allowDefault)(uid, 'submitMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const ref = mocks(deps.db, uid).doc(mockId);
  return deps.db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) throw new HttpsError('not-found', 'Mock not found.');
    const status = String(snapshot.get('status'));
    if (status !== 'started') return {mockId, status};
    transaction.update(ref, abandoned ? {status: 'abandoned', abandonedAt: now}
      : {status: 'submitted', submittedAt: now, durationMs, answers, answerCount: answers?.length});
    return {mockId, status: abandoned ? 'abandoned' : 'submitted'};
  });
}

export const startMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true, consumeAppCheckToken: true},
  request => beginMock(request.auth as Auth, request.data, {db: getFirestore()}));

export const submitMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => recordMock(request.auth as Auth, request.data, {db: getFirestore()}));
