import {FieldPath, getFirestore, type Firestore, type Transaction} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {mockCoverage} from './mockAccess.js';
import {examCatalog} from './revenuecatPasses.js';
import {assemblePaper, endIfTimedOut, FREE_MOCK_WINDOW_MS} from './mock.js';
import type {Answer} from './_answers.js';
import {recordMockAnswers} from './mockAnswers.js';

type Auth = Parameters<typeof assertNamedUser>[0];
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
type Row = FirebaseFirestore.DocumentData;
const collection = (db: Firestore, uid: string) => db.collection(`users/${uid}/server/mocks/items`);
const bad = (message: string) => new HttpsError('invalid-argument', message);
const broken = () => new HttpsError('failed-precondition', 'Saved mock results are not available.');
const ID = /^[A-Za-z0-9]{10,40}$/;
function mockId(value: unknown): string {
  if (typeof value !== 'string' || !ID.test(value)) throw bad('Bad mock id.');
  return value;
}
function exam(value: unknown): string {
  if (typeof value !== 'string' || !examCatalog.some(e => e.id === value)) throw bad('Unknown exam.');
  return value;
}
function object(data: unknown): Row {
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw bad('Send an object.');
  return data as Row;
}
async function caller(auth: Auth, deps: Deps, key: string) {
  const uid = assertNamedUser(auth);
  if (!await (deps.allow ?? ((id, action) => allowAtMost(id, action, 600, 3600000)))(uid, key)) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  return {uid, now: (deps.now ?? Date.now)()};
}
function count(answers: Answer[], ids: string[]) {
  const selected = answers.filter(a => ids.includes(a.questionId) && a.chosen !== null);
  const correct = selected.filter(a => a.correct).length;
  return {correct, answered: selected.length, wrong: selected.length - correct, blank: ids.length - selected.length, total: ids.length};
}
function summary(id: string, row: Row, proCovered: boolean, now: number, accessRecheckAt: number | null) {
  if (row.status !== 'submitted' || !Number.isSafeInteger(row.submittedAt) || row.submittedAt <= 0 ||
      !Number.isSafeInteger(row.startedAt) || !Number.isSafeInteger(row.durationMs) || row.durationMs < 0 ||
      !Number.isSafeInteger(row.limitMs) || row.limitMs <= 0 ||
      !['student', 'strict-exit', 'time-out'].includes(row.endedBy) || !Array.isArray(row.paper?.sections) || !Array.isArray(row.answers)) throw broken();
  const sections = row.paper.sections as {sectionId: string; name: string; questions: {id: string; setId: string}[]}[];
  if (sections.some(s => !s || typeof s.sectionId !== 'string' || !s.sectionId || typeof s.name !== 'string' ||
      !Array.isArray(s.questions) || s.questions.some(q => !q || typeof q.id !== 'string' || !q.id || typeof q.setId !== 'string' || !q.setId)) ||
      new Set(sections.map(s => s.sectionId)).size !== sections.length) throw broken();
  const ids = sections.flatMap(s => s.questions.map(q => q.id));
  const answers = row.answers as Answer[];
  if (!ids.length || new Set(ids).size !== ids.length || ids.some(id => typeof id !== 'string' || !id) ||
      new Set(answers.map(a => a.questionId)).size !== answers.length ||
      answers.some(a => !ids.includes(a.questionId) || typeof a.correct !== 'boolean' ||
        (a.chosen !== null && typeof a.chosen !== 'string'))) throw broken();
  const reviewUntil = row.submittedAt + FREE_MOCK_WINDOW_MS;
  return {serverNow: now, accessRecheckAt, mockId: id, examId: row.examId as string, startedAt: row.startedAt as number, submittedAt: row.submittedAt as number,
    endedBy: row.endedBy as string, strict: row.strict === true, limitMs: row.limitMs as number, durationMs: row.durationMs as number,
    score: count(answers, ids), sections: sections.map(s => ({sectionId: s.sectionId, name: s.name, ...count(answers, s.questions.map(q => q.id))})),
    canReview: proCovered || now < reviewUntil, proCovered, reviewUntil};
}

export async function serveMockResults(auth: Auth, data: unknown, deps: Deps) {
  const {uid, now} = await caller(auth, deps, 'getMockResults');
  const id = mockId(object(data).mockId);
  return deps.db.runTransaction(async transaction => {
    const snapshot = await transaction.get(collection(deps.db, uid).doc(id));
    if (!snapshot.exists) throw new HttpsError('not-found', 'Mock not found.');
    const row = snapshot.data()!;
    const access = await mockCoverage(transaction, deps.db, uid, now);
    const result = summary(id, row, access.coversExam(row.examId), now, access.recheckAt);
    await recordMockAnswers(transaction, deps.db, uid, id, row, now);
    return {...result, ...(result.canReview ? {paper: row.paper, answers: row.answers} : {}),
      ...(result.proCovered ? {notes: row.reviewNotes ?? {}} : {})};
  });
}

export async function serveMockAvailability(auth: Auth, data: unknown, deps: Deps) {
  const {uid, now} = await caller(auth, deps, 'getMockAvailability');
  const body = object(data);
  const examId = exam(body.examId);
  if (body.includeSetup !== undefined && typeof body.includeSetup !== 'boolean') throw bad('Bad setup preview flag.');
  const open = await collection(deps.db, uid).where('status', '==', 'started').limit(1).get();
  if (open.docs[0]) await endIfTimedOut(deps.db, uid, open.docs[0].id, now);
  const result = await deps.db.runTransaction(async transaction => {
    const [active, last, lastExam, blueprint, access] = await Promise.all([
      transaction.get(collection(deps.db, uid).where('status', '==', 'started').limit(1)),
      transaction.get(collection(deps.db, uid).where('submittedAt', '>', 0).orderBy('submittedAt', 'desc').limit(1)),
      transaction.get(collection(deps.db, uid).where('examId', '==', examId).where('submittedAt', '>', 0).orderBy('submittedAt', 'desc').limit(1)),
      transaction.get(deps.db.doc(`content/mocks/items/${examId}`)), mockCoverage(transaction, deps.db, uid, now),
    ]);
    const previous = last.docs[0];
    const proCovered = access.coversExam(examId);
    const nextEligibleAt = proCovered || !previous ? null : Number(previous.get('submittedAt')) + FREE_MOCK_WINDOW_MS;
    const lastForExam = lastExam.docs[0];
    const running = active.docs[0];
    return {examId, serverNow: now, accessRecheckAt: access.recheckAt, proCovered, nextEligibleAt, lastMockId: lastForExam?.id ?? null,
      status: running ? 'in-progress' : !blueprint.exists ? 'no-blueprint' : nextEligibleAt !== null && now < nextEligibleAt ? 'cooldown' : 'available',
      ...(running ? {open: {mockId: running.id, examId: running.get('examId') as string, paused: typeof running.get('pausedAt') === 'number'}} : {})};
  });
  if (body.includeSetup === true && result.status === 'available') {
    const {paper} = await assemblePaper(deps.db, uid, examId, now, 0);
    return {...result, setup: {expectedQuestionCount: paper.expectedQuestionCount,
      questionCount: paper.sections.reduce((count, section) => count + section.questions.length, 0)}};
  }
  return result;
}

export async function serveMockHistory(auth: Auth, data: unknown, deps: Deps) {
  const {uid, now} = await caller(auth, deps, 'getMockHistory');
  const body = object(data);
  const limit = body.limit ?? 30;
  if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw bad('Send a limit from 1 to 100.');
  let query = collection(deps.db, uid).where('submittedAt', '>', 0).orderBy('submittedAt', 'desc').orderBy(FieldPath.documentId(), 'desc');
  if (body.before !== undefined && body.before !== null) {
    const before = object(body.before);
    if (!Number.isSafeInteger(before.submittedAt) || before.submittedAt <= 0) throw bad('Bad history cursor.');
    query = query.startAfter(before.submittedAt, mockId(before.mockId));
  }
  return deps.db.runTransaction(async transaction => {
    const [rows, access] = await Promise.all([transaction.get(query.limit(limit + 1)), mockCoverage(transaction, deps.db, uid, now)]);
    const page = rows.docs.slice(0, limit);
    const last = page.at(-1);
    return {items: page.map(d => summary(d.id, d.data(), access.coversExam(d.get('examId')), now, access.recheckAt)),
      next: rows.size > limit && last ? {submittedAt: last.get('submittedAt') as number, mockId: last.id} : null};
  });
}

export async function writeMockReview(auth: Auth, data: unknown, deps: Deps) {
  const {uid, now} = await caller(auth, deps, 'updateMockReview');
  const body = object(data), id = mockId(body.mockId), questionId = body.questionId;
  if (typeof questionId !== 'string' || !questionId || questionId.length > 128) throw bad('Bad question id.');
  const missReason = body.missReason ?? null, blankReason = body.blankReason ?? null, reasonNote = body.reasonNote ?? null;
  if ((missReason !== null && !['misread', 'slipped', 'unknown', 'other'].includes(missReason)) ||
      (blankReason !== null && !['ranOutOfTime', 'skippedToReturn', 'didNotKnow', 'other'].includes(blankReason)) ||
      (reasonNote !== null && (typeof reasonNote !== 'string' || reasonNote.length > 4000))) throw bad('Bad review note.');
  return deps.db.runTransaction(async transaction => {
    const snapshot = await transaction.get(collection(deps.db, uid).doc(id));
    if (!snapshot.exists) throw new HttpsError('not-found', 'Mock not found.');
    const row = snapshot.data()!;
    const access = await mockCoverage(transaction, deps.db, uid, now);
    const result = summary(id, row, access.coversExam(row.examId), now, access.recheckAt);
    if (!result.proCovered) throw new HttpsError('permission-denied', 'Pro is required for notes.');
    if (!row.paper.sections.some((s: {questions: {id: string}[]}) => s.questions.some(q => q.id === questionId))) throw bad('Question is not on this paper.');
    // Replace one question atomically without interpreting dots in a content id as field paths.
    transaction.update(snapshot.ref, new FieldPath('reviewNotes', questionId), {missReason, blankReason, reasonNote});
    return {stored: true};
  });
}

const options = {region: 'asia-southeast1', enforceAppCheck: true};
export const getMockAvailability = onCall(options, request => serveMockAvailability(request.auth, request.data, {db: getFirestore()}));
export const getMockResults = onCall(options, request => serveMockResults(request.auth, request.data, {db: getFirestore()}));
export const getMockHistory = onCall(options, request => serveMockHistory(request.auth, request.data, {db: getFirestore()}));
export const updateMockReview = onCall({...options, consumeAppCheckToken: true}, request => writeMockReview(request.auth, request.data, {db: getFirestore()}));
