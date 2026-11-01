import {enforceAppCheck} from './_appCheck.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {loadTotals} from './_answerTotals.js';
import {loadStudyContent} from './_examContent.js';
import {allowAtMost} from './_limits.js';
import {examCatalog} from './revenuecatPasses.js';
import {assertStudyOwner} from './studyObservations.js';

type Auth = {uid: string; token?: object} | undefined;
type Deps = {db: Firestore; allow?: (uid: string, key: string) => Promise<boolean>};

/**
 * How many questions the student has answered, in any exam, that the requested exam also has. It
 * is the figure the carry-over prompt prints, measured from the stored answers and nothing else.
 * It reads the same answer totals the roadmap uses, so it counts a question once however many
 * times or in which exam it was answered. The exam does not have to be the current exam: the
 * prompt asks right after the switch, and this changes nothing.
 */
export async function readCarryableCount(auth: Auth, data: unknown, deps: Deps): Promise<{count: number}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw new HttpsError('invalid-argument', 'Send an object.');
  const body = data as Record<string, unknown>;
  assertStudyOwner(auth.uid, body);
  const examId = body.examId;
  if (typeof examId !== 'string' || !examCatalog.some(e => e.id === examId)) throw new HttpsError('invalid-argument', 'Unknown exam.');
  if (!await (deps.allow ?? ((uid, key) => allowAtMost(uid, key, 600, 3_600_000)))(auth.uid, 'getCarryableCount')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const [content, totals] = await Promise.all([loadStudyContent(deps.db, examId), loadTotals(deps.db, auth.uid)]);
  const inExam = new Set(content.questions.map(q => q.id));
  let count = 0;
  for (const [id, row] of totals.questions) if (row.answered > 0 && inExam.has(id)) count += 1;
  return {count};
}

export const getCarryableCount = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  request => readCarryableCount(request.auth, request.data, {db: getFirestore()}));
