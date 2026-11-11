import {enforceAppCheck} from './_appCheck.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {allowAtMost} from './_limits.js';
import {MAX_CUSTOM_TRACKS, customTier, customTrackRef, isCustomExamId, tierDisplayName} from './_customTrack.js';
import {assertStudyOwner} from './studyObservations.js';
import {timed} from './_timed.js';

type Auth = {uid: string; token?: object} | undefined;
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
const allowDefault = (uid: string, key: string) => allowAtMost(uid, key, 600, 3_600_000);

async function caller(auth: Auth, data: unknown, deps: Deps, key: string) {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw new HttpsError('invalid-argument', 'Send an object.');
  const body = data as Record<string, unknown>;
  assertStudyOwner(auth.uid, body);
  return {uid: auth.uid, body, allowed: async () => {
    if (!await (deps.allow ?? allowDefault)(auth.uid, key)) throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }};
}

/** The signed-in student's own custom exams, newest first, and which exam is active now. There is no uid or path input. */
export async function readCustomTracks(auth: Auth, data: unknown, deps: Deps) {
  const {uid, allowed} = await caller(auth, data, deps, 'getCustomTracks');
  await allowed();
  const [settings, rows] = await Promise.all([
    deps.db.doc(`users/${uid}/server/settings`).get(),
    deps.db.collection(`users/${uid}/server/customTracks/items`).orderBy('createdAt', 'desc').limit(MAX_CUSTOM_TRACKS).get(),
  ]);
  const active = settings.get('examId');
  return {activeExamId: typeof active === 'string' ? active : null, tracks: rows.docs.map(row => ({
    examId: row.id, name: row.get('name') ?? null, excludedTopicIds: row.get('excludedTopicIds') ?? [],
    // Table alone: this read loads no corpus, so a topic the table does not know cannot be seen here.
    // Computed here from the server's own exclusions (settings while active, else the track), never stored or read from a request.
    priceTier: tierDisplayName(customTier((row.id === active ? settings.get('excludedTopicIds') : row.get('excludedTopicIds')) ?? [])),
    excludedLessonIds: row.get('excludedLessonIds') ?? [], blueprint: row.get('blueprint') ?? null,
    createdAt: row.get('createdAt'), updatedAt: row.get('updatedAt')}))};
}

/**
 * Removes one custom exam's track document. Answers, reviews and mocks stay: narrowing and removal never
 * purge study data, and that data belongs to the account. Removing a track that is gone is not an error.
 */
export async function removeCustomTrack(auth: Auth, data: unknown, deps: Deps): Promise<{deleted: true}> {
  const {uid, body, allowed} = await caller(auth, data, deps, 'deleteCustomTrack');
  const examId = body.examId;
  if (!isCustomExamId(examId)) throw new HttpsError('invalid-argument', 'Unknown exam.');
  await allowed();
  await deps.db.runTransaction(async tx => {
    const settings = await tx.get(deps.db.doc(`users/${uid}/server/settings`));
    if (settings.get('examId') === examId) {
      throw new HttpsError('failed-precondition', 'This is your current exam. Switch to another exam first.');
    }
    tx.delete(customTrackRef(deps.db, uid, examId));
  });
  return {deleted: true};
}

export const getCustomTracks = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('getCustomTracks', request => readCustomTracks(request.auth, request.data, {db: getFirestore()})));
export const deleteCustomTrack = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('deleteCustomTrack', request => removeCustomTrack(request.auth, request.data, {db: getFirestore()})));
