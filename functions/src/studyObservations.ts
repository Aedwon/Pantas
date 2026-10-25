import {FieldValue, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {checkTime} from './_answers.js';
import {computeRoadmap} from './roadmap.js';

export function assertStudyOwner(uid: string, body: Record<string, unknown>, required = true): void {
  if (body.expectedUid === undefined && !required) return;
  if (typeof body.expectedUid !== 'string' || !body.expectedUid) throw new HttpsError('invalid-argument', 'Send the original account.');
  if (body.expectedUid !== uid) throw new HttpsError('failed-precondition', 'Your account changed. Open this screen again.');
}
type Auth = {uid: string; token?: object} | undefined;
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
export async function writeLessonRead(auth: Auth, data: unknown, deps: Deps): Promise<{stored: boolean}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw new HttpsError('invalid-argument', 'Send an object.');
  const body = data as Record<string, unknown>;
  assertStudyOwner(auth.uid, body);
  const now = (deps.now ?? Date.now)(), lessonId = body.lessonId;
  if (typeof lessonId !== 'string' || !lessonId || lessonId.length > 128 || lessonId.includes('/')) {
    throw new HttpsError('invalid-argument', 'Bad lesson id.');
  }
  const readAt = checkTime(body.readAt, now, 'readAt');
  if (!await (deps.allow ?? ((uid, key) => allowAtMost(uid, key, 600, 3600000)))(auth.uid, 'recordLessonRead')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const stored = await deps.db.runTransaction(async tx => {
    const [lesson, previous] = await Promise.all([
      tx.get(deps.db.doc('content/lessons/items/' + lessonId)),
      tx.get(deps.db.doc('users/' + auth.uid + '/server/lessonReads/items/' + encodeURIComponent(lessonId))),
    ]);
    if (!lesson.exists) throw new HttpsError('invalid-argument', 'Unknown lesson.');
    if (previous.exists && Number(previous.get('readAt')) <= readAt) return false;
    tx.set(previous.ref, {lessonId, readAt, receivedAt: now});
    tx.set(deps.db.doc('users/' + auth.uid + '/server/studyRevision'), {value: FieldValue.increment(1)}, {merge: true});
    return true;
  });
  if (stored) {
    try { await computeRoadmap(deps.db, auth.uid, false, now); }
    catch (error) { console.error('lesson roadmap rebuild failed', auth.uid, error); }
  }
  return {stored};
}
export const recordLessonRead = onCall({region: 'asia-southeast1', enforceAppCheck: true},
  request => writeLessonRead(request.auth, request.data, {db: getFirestore()}));
