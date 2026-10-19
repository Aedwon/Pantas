import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {addSession, backfill, fromDoc, prune, toDoc, totalsRef} from './_answerTotals.js';
import {checkAnswers, checkDuration, checkTime} from './_answers.js';
import {hasLiveProClaim} from './_pro.js';
import {computeRoadmap} from './roadmap.js';

export {MAX_ANSWERS} from './_answers.js';

/**
 * Per-account daily cap on finished sessions. A heavy day is about 10 to 20 sessions; 200 leaves
 * ten times that for retries after a flaky connection, and a replay of the same session is
 * harmless because it is de-duplicated.
 */
export const DAILY_SESSIONS = 200;
const SESSION_ID = /^[A-Za-z0-9_-]{8,64}$/;

export type IngestDeps = {db: Firestore; now?: () => number; dailySessions?: number};
type Auth = {uid: string; token?: object} | undefined;

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
    // The running totals change in this same transaction, so a replay (above) never counts twice.
    // An account from before the totals existed is built from its stored sessions first.
    const snapshot = await transaction.get(totalsRef(deps.db, auth.uid));
    const totals = snapshot.exists ? fromDoc(snapshot.data()) : await backfill(transaction, deps.db, auth.uid);
    addSession(totals, answers);
    prune(totals);
    transaction.set(totalsRef(deps.db, auth.uid), toDoc(totals));
    transaction.create(ref, {sessionId, startedAt, finishedAt, durationMs, answerCount: answers.length, answers, receivedAt: now});
    return true;
  });
  if (stored) {
    // The batch is already safe. A failed rebuild must not make the app retry or lose the answers;
    // the next batch, settings change or roadmap request rebuilds it.
    try {
      await computeRoadmap(deps.db, auth.uid, hasLiveProClaim(auth.token as {pro?: unknown; proUntil?: unknown} | undefined, now), now);
    } catch (error) {
      console.error('roadmap rebuild failed', auth.uid, error);
    }
  }
  return {sessionId, stored};
}

export const ingestSession = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => recordSession(request.auth, request.data, {db: getFirestore()}));
