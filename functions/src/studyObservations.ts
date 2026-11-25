import {enforceAppCheck} from './_appCheck.js';
import {FieldValue, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {allowAtMost} from './_limits.js';
import {checkTime} from './_answers.js';
import {computeRoadmap} from './roadmap.js';
import {timed} from './_timed.js';

export function assertStudyOwner(uid: string, body: Record<string, unknown>, required = true): void {
  if (body.expectedUid === undefined && !required) return;
  if (typeof body.expectedUid !== 'string' || !body.expectedUid) throw new HttpsError('invalid-argument', 'Send the original account.');
  if (body.expectedUid !== uid) throw new HttpsError('failed-precondition', 'Your account changed. Open this screen again.');
}
type Auth = {uid: string; token?: object} | undefined;
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
const MAX_BATCH_READS = 200;
const rateLimited = (deps: Deps, uid: string) =>
  (deps.allow ?? ((id, key) => allowAtMost(id, key, 600, 3600000)))(uid, 'recordLessonRead');
const validLessonId = (value: unknown): value is string =>
  typeof value === 'string' && !!value && value.length <= 128 && !value.includes('/');

/**
 * Records lesson reads. Two request shapes, one callable (a second function would add a
 * Cloud Run service, an image and keep-warm pings):
 *  - single, `{expectedUid, lessonId, readAt}`: what installed clients send. Unchanged:
 *    a bad item or unknown lesson throws, and the result is `{stored: boolean}`.
 *  - batch, `{expectedUid, reads: [{lessonId, readAt}, ...]}`, 1 to 200 items. Only a bad
 *    envelope throws. The result is `{stored, unchanged, rejected}`, each a list of indexes
 *    into `reads`, so the client maps every row back to its receipt:
 *      stored: written (new, or earlier than the stored read);
 *      unchanged: nothing to write (an equal or later read, or a duplicate of a lesson in the
 *        same batch whose earliest read was used);
 *      rejected: this item can never succeed (bad id, bad time, unknown lesson). It never
 *        fails the other items.
 *    One rate-limit tick, one transaction, one revision increment and one roadmap rebuild
 *    per call, however many items are stored.
 */
export async function writeLessonRead(auth: Auth, data: unknown, deps: Deps): Promise<{stored: boolean} | BatchResult> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw new HttpsError('invalid-argument', 'Send an object.');
  const body = data as Record<string, unknown>;
  assertStudyOwner(auth.uid, body);
  if (body.reads !== undefined) return writeLessonReadBatch(auth.uid, body.reads, deps);
  const now = (deps.now ?? Date.now)(), lessonId = body.lessonId;
  if (!validLessonId(lessonId)) throw new HttpsError('invalid-argument', 'Bad lesson id.');
  const readAt = checkTime(body.readAt, now, 'readAt');
  if (!await rateLimited(deps, auth.uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const stored = await deps.db.runTransaction(async tx => {
    const [lesson, previous] = await Promise.all([
      tx.get(deps.db.doc('content/lessons/items/' + lessonId)),
      tx.get(deps.db.doc('users/' + auth.uid + '/server/lessonReads/items/' + encodeURIComponent(lessonId))),
    ]);
    // Retired documents remain valid observations under their original id.
    if (!lesson.exists) throw new HttpsError('invalid-argument', 'Unknown lesson.');
    if (previous.exists && Number(previous.get('readAt')) <= readAt) return false;
    tx.set(previous.ref, {lessonId, readAt, receivedAt: now});
    tx.set(deps.db.doc('users/' + auth.uid + '/server/studyRevision'), {value: FieldValue.increment(1)}, {merge: true});
    return true;
  });
  if (stored) await rebuildRoadmap(deps, auth.uid, now);
  return {stored};
}
type BatchResult = {stored: number[]; unchanged: number[]; rejected: number[]};

async function rebuildRoadmap(deps: Deps, uid: string, now: number): Promise<void> {
  try { await computeRoadmap(deps.db, uid, false, now); }
  catch (error) { console.error('lesson roadmap rebuild failed', uid, error); }
}

async function writeLessonReadBatch(uid: string, reads: unknown, deps: Deps): Promise<BatchResult> {
  if (!Array.isArray(reads) || reads.length < 1 || reads.length > MAX_BATCH_READS) {
    throw new HttpsError('invalid-argument', `Send 1 to ${MAX_BATCH_READS} reads.`);
  }
  const now = (deps.now ?? Date.now)();
  if (!await rateLimited(deps, uid)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const rejected: number[] = [], unchanged: number[] = [];
  // One entry per lesson. A repeat of a lesson keeps the earliest read; the other index is "unchanged".
  const groups = new Map<string, {index: number; readAt: number; others: number[]}>();
  reads.forEach((item, index) => {
    try {
      if (!item || typeof item !== 'object' || Array.isArray(item)) throw new Error('bad item');
      const {lessonId, readAt: rawReadAt} = item as Record<string, unknown>;
      if (!validLessonId(lessonId)) throw new Error('bad lesson id');
      const readAt = checkTime(rawReadAt, now, 'readAt');
      const group = groups.get(lessonId);
      if (!group) groups.set(lessonId, {index, readAt, others: []});
      else if (readAt < group.readAt) { group.others.push(group.index); group.index = index; group.readAt = readAt; }
      else group.others.push(index);
    } catch { rejected.push(index); }
  });
  const ids = [...groups.keys()];
  const stored: number[] = [], storeRejected: number[] = [];
  if (ids.length > 0) {
    await deps.db.runTransaction(async tx => {
      // A retry of the transaction recomputes every list from the group table.
      stored.length = 0; unchanged.length = 0; storeRejected.length = 0;
      const docs = await tx.getAll(...ids.flatMap(id => [
        deps.db.doc('content/lessons/items/' + id),
        deps.db.doc('users/' + uid + '/server/lessonReads/items/' + encodeURIComponent(id)),
      ]));
      const outcome = new Map<string, 'stored' | 'unchanged' | 'rejected'>();
      ids.forEach((id, i) => {
        const [lesson, previous] = [docs[2 * i], docs[2 * i + 1]], group = groups.get(id)!;
        // Retired documents remain valid observations under their original id.
        if (!lesson.exists) { outcome.set(id, 'rejected'); return; }
        if (previous.exists && Number(previous.get('readAt')) <= group.readAt) { outcome.set(id, 'unchanged'); return; }
        tx.set(previous.ref, {lessonId: id, readAt: group.readAt, receivedAt: now});
        outcome.set(id, 'stored');
      });
      if ([...outcome.values()].includes('stored')) {
        tx.set(deps.db.doc('users/' + uid + '/server/studyRevision'), {value: FieldValue.increment(1)}, {merge: true});
      }
      for (const id of ids) {
        const group = groups.get(id)!, result = outcome.get(id)!;
        if (result === 'rejected') storeRejected.push(group.index, ...group.others);
        else {
          (result === 'stored' ? stored : unchanged).push(group.index);
          unchanged.push(...group.others);
        }
      }
    });
  }
  const allRejected = [...rejected, ...storeRejected];
  if (stored.length > 0) await rebuildRoadmap(deps, uid, now);
  const byIndex = (a: number, b: number) => a - b;
  return {stored: stored.sort(byIndex), unchanged: unchanged.sort(byIndex), rejected: allRejected.sort(byIndex)};
}
export const recordLessonRead = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('recordLessonRead', request => writeLessonRead(request.auth, request.data, {db: getFirestore()})));
