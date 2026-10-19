import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {checkAnswers, checkDuration, checkTime} from './_answers.js';

export {MAX_ANSWERS} from './_answers.js';

/**
 * Per-account daily cap on finished sessions. A heavy day is about 10 to 20 sessions; 200 leaves
 * ten times that for retries after a flaky connection, and a replay of the same session is
 * harmless because it is de-duplicated.
 */
export const DAILY_SESSIONS = 200;
const SESSION_ID = /^[A-Za-z0-9_-]{8,64}$/;

export type IngestDeps = {db: Firestore; now?: () => number; dailySessions?: number};
type Auth = {uid: string} | undefined;

export async function recordSession(auth: Auth, data: unknown, deps: IngestDeps): Promise<{sessionId: string; stored: boolean}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const now = (deps.now ?? Date.now)();
  const body = data as Record<string, unknown> | null;
  const sessionId = body?.sessionId;
  if (typeof sessionId !== 'string' || !SESSION_ID.test(sessionId)) throw new HttpsError('invalid-argument', 'Bad session id.');
  const answers = checkAnswers(body?.answers, now);
  const startedAt = checkTime(body?.startedAt, now, 'startedAt');
  const finishedAt = checkTime(body?.finishedAt, now, 'finishedAt');
  if (finishedAt < startedAt) throw new HttpsError('invalid-argument', 'finishedAt is before startedAt.');
  const durationMs = checkDuration(body?.durationMs);
  if (!await allowAtMost(auth.uid, 'ingestSession', deps.dailySessions ?? DAILY_SESSIONS, 86_400_000)) {
    throw new HttpsError('resource-exhausted', 'Daily session limit reached. Try again tomorrow.');
  }
  const ref = deps.db.doc(`users/${auth.uid}/server/answers/items/${sessionId}`);
  const stored = await deps.db.runTransaction(async (transaction) => {
    if ((await transaction.get(ref)).exists) return false;
    transaction.create(ref, {sessionId, startedAt, finishedAt, durationMs, answerCount: answers.length, answers, receivedAt: now});
    return true;
  });
  return {sessionId, stored};
}

export const ingestSession = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => recordSession(request.auth, request.data, {db: getFirestore()}));
