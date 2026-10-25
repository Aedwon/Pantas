import {randomInt} from 'node:crypto';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {checkAnswers, checkDuration, type Answer} from './_answers.js';
import {core} from './_core.js';
import {loadExamContent} from './_examContent.js';
import {mockCoverage} from './mockAccess.js';
import {checkPaperAnswers, recordMockAnswers} from './mockAnswers.js';
import {examCatalog} from './revenuecatPasses.js';

export {MAX_ANSWERS} from './_answers.js';

export const FREE_MOCK_WINDOW_MS = 30 * 86_400_000;
const mocks = (db: Firestore, uid: string) => db.collection(`users/${uid}/server/mocks/items`);

export type MockDeps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>;
  seed?: () => number};
type Auth = Parameters<typeof assertNamedUser>[0] & {token: {pro?: unknown; proUntil?: unknown}};

type PaperQuestion = {id: string; setId: string};
type Paper = {expectedQuestionCount: number; sections: {sectionId: string; name: string; questions: PaperQuestion[]}[]};
type Score = {correct: number; answered: number; total: number};
type EndedBy = 'student' | 'strict-exit' | 'time-out';

const allowDefault = (uid: string, key: string) => allowAtMost(uid, key, 30, 60 * 60_000);
const allowControl = (uid: string, key: string) => allowAtMost(uid, key, 600, 60 * 60_000);

const paperSize = (paper: Paper) => paper.sections.reduce((total, section) => total + section.questions.length, 0);
const scoreOf = (answers: Answer[], paper: Paper): Score => ({
  correct: answers.filter(answer => answer.chosen !== null && answer.correct).length,
  answered: answers.filter(answer => answer.chosen !== null).length,
  total: paperSize(paper),
});

/**
 * Milliseconds used. Strict mode never pauses, so the server start time alone decides. Non-strict
 * mode subtracts the recorded pauses, including one still open.
 */
function elapsedMs(row: FirebaseFirestore.DocumentData, now: number): number {
  const startedAt = Number(row.startedAt);
  if (row.strict === true) return Math.max(0, now - startedAt);
  const open = typeof row.pausedAt === 'number' ? Math.max(0, now - row.pausedAt) : 0;
  return Math.max(0, now - startedAt - Number(row.pausedMs ?? 0) - open);
}

type MockView = {mockId: string; examId: string; startedAt: number; strict: boolean; limitMs: number;
  remainingMs: number; paused: boolean; paper: Paper; answers: Answer[]};

function view(mockId: string, row: FirebaseFirestore.DocumentData, now: number): MockView {
  return {
    mockId, examId: row.examId, startedAt: row.startedAt, strict: row.strict === true, limitMs: row.limitMs,
    remainingMs: Math.max(0, Number(row.limitMs) - elapsedMs(row, now)), paused: typeof row.pausedAt === 'number',
    paper: row.paper, answers: row.answers ?? [],
  };
}

/**
 * Ends a strict mock whose time ran out, scoring the saved answers. Submission is the moment time
 * ran out, so the Free allowance counts from then, not from the student's next visit. Does nothing
 * for a non-strict mock (the app ends it) or one with time left.
 */
export async function endIfTimedOut(db: Firestore, uid: string, mockId: string, now: number):
  Promise<{mockId: string; endedBy: EndedBy; submittedAt: number; score: Score} | null> {
  return db.runTransaction(async (transaction) => {
    const ref = mocks(db, uid).doc(mockId);
    const snapshot = await transaction.get(ref);
    const row = snapshot.data();
    if (!row || row.status !== 'started' || row.strict !== true || elapsedMs(row, now) < Number(row.limitMs)) return null;
    const submittedAt = Number(row.startedAt) + Number(row.limitMs);
    const answers = (row.answers ?? []) as Answer[];
    const score = scoreOf(answers, row.paper);
    await recordMockAnswers(transaction, db, uid, mockId, {...row, submittedAt, durationMs: Number(row.limitMs)}, now);
    transaction.update(ref, {status: 'submitted', submittedAt, endedBy: 'time-out', durationMs: Number(row.limitMs),
      answerCount: answers.length, score});
    return {mockId, endedBy: 'time-out' as const, submittedAt, score};
  });
}

async function findOpen(db: Firestore, uid: string) {
  const open = await mocks(db, uid).where('status', '==', 'started').limit(1).get();
  return open.docs[0];
}

export async function assemblePaper(db: Firestore, uid: string, examId: string, now: number, seed: number):
  Promise<{paper: Paper; limitMs: number}> {
  const blueprint = await db.doc(`content/mocks/items/${examId}`).get();
  if (!blueprint.exists) throw new HttpsError('failed-precondition', 'This exam has no mock yet.');
  const content = await loadExamContent(db, examId, now);
  const poolsByTopic: Record<string, string[]> = {};
  const passageSetsByTopic: Record<string, Record<string, string[]>> = {};
  const setOf = new Map<string, string>();
  for (const question of content.questions) {
    (poolsByTopic[question.topicId] ??= []).push(question.id);
    setOf.set(question.id, question.setId);
    if (question.passageId) ((passageSetsByTopic[question.topicId] ??= {})[question.passageId] ??= []).push(question.id);
  }
  // Avoid both of the student's last two submitted papers when the bank has enough others.
  const last = await mocks(db, uid).where('examId', '==', examId).where('submittedAt', '>', 0).orderBy('submittedAt', 'desc').limit(2).get();
  const recent = last.docs.flatMap(doc => ((doc.get('paper') as Paper | undefined)?.sections ?? []).flatMap(s => s.questions.map(q => q.id)));
  let sampled: {expectedQuestionCount: number; sections: {sectionId: string; name: string; questionIds: string[]}[]};
  try {
    sampled = JSON.parse(core().sampleMock(JSON.stringify({
      sectionsJson: blueprint.get('sectionsJson'), poolsByTopic, passageSetsByTopic,
      recentlySampledQuestionIds: recent, seed,
    })));
  } catch {
    throw new HttpsError('failed-precondition', 'There are not enough questions for this mock yet.');
  }
  const paper: Paper = {
    expectedQuestionCount: sampled.expectedQuestionCount,
    sections: sampled.sections.map(section => ({sectionId: section.sectionId, name: section.name,
      questions: section.questionIds.map(id => ({id, setId: setOf.get(id) ?? ''}))})),
  };
  return {paper, limitMs: Number(blueprint.get('durationMinutes')) * 60_000};
}

/**
 * Starts a mock, or returns the one already open. Needs a named account. The server assembles the
 * paper from content with the compiled Dart sampler and pins it in the mock record: any later
 * start returns the same paper until the mock is submitted. A Free account is refused only after a
 * submission (by the student, a strict early end or a time-out) less than 30 days ago. Pro is unlimited.
 */
export async function beginMock(auth: Auth, data: unknown, deps: MockDeps): Promise<MockView & {resumed: boolean}> {
  const uid = assertNamedUser(auth);
  const body = data as {examId?: unknown; strict?: unknown} | null;
  const examId = body?.examId;
  if (typeof examId !== 'string' || !examCatalog.some((exam) => exam.id === examId)) {
    throw new HttpsError('invalid-argument', 'Unknown exam.');
  }
  const strict = body?.strict === true;
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowDefault)(uid, 'startMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const open = await findOpen(deps.db, uid);
  if (open) {
    await endIfTimedOut(deps.db, uid, open.id, now);
    const fresh = await open.ref.get();
    if (fresh.get('status') === 'started') return {...view(fresh.id, fresh.data()!, now), resumed: true};
  }
  const ref = mocks(deps.db, uid).doc();
  const seed = (deps.seed ?? (() => randomInt(0, 2 ** 32)))();
  const {paper, limitMs} = await assemblePaper(deps.db, uid, examId, now, seed);
  return deps.db.runTransaction(async (transaction) => {
    // Another start may have created the mock while this paper was assembled; that one wins.
    const raced = await transaction.get(mocks(deps.db, uid).where('status', '==', 'started').limit(1));
    if (raced.docs[0]) return {...view(raced.docs[0].id, raced.docs[0].data(), now), resumed: true};
    const access = await mockCoverage(transaction, deps.db, uid, now);
    if (!access.coversExam(examId)) {
      const recent = await transaction.get(mocks(deps.db, uid).where('submittedAt', '>', now - FREE_MOCK_WINDOW_MS));
      if (recent.docs.some((doc) => doc.get('status') === 'submitted')) {
        throw new HttpsError('failed-precondition', 'Free accounts can take one mock every 30 days.');
      }
    }
    const row = {examId, status: 'started', startedAt: now, strict, limitMs, seed, paper, answers: [] as Answer[],
      pausedMs: 0, pausedAt: null};
    transaction.create(ref, row);
    return {...view(ref.id, row, now), resumed: false};
  });
}

/** The open mock with its clock, or none. A strict mock that ran out is ended and scored first. */
export async function readMock(auth: Auth, _data: unknown, deps: MockDeps):
  Promise<{open: true} & MockView | {open: false; ended?: {mockId: string; endedBy: EndedBy; submittedAt: number; score: Score}}> {
  const uid = assertNamedUser(auth);
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowControl)(uid, 'readMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const open = await findOpen(deps.db, uid);
  if (!open) return {open: false};
  const ended = await endIfTimedOut(deps.db, uid, open.id, now);
  if (ended) return {open: false, ended};
  // Another request may have finalized after the open query but before this transaction.
  const fresh = await open.ref.get();
  const row = fresh.data();
  if (!row) return {open: false};
  if (row.status === 'submitted') return {open: false, ended: {mockId: fresh.id,
    endedBy: row.endedBy as EndedBy, submittedAt: Number(row.submittedAt), score: row.score as Score}};
  return {open: true, ...view(fresh.id, row, now)};
}

/**
 * Changes the open mock: `save` replaces the saved answers; `pause` and `resume` record a pause
 * (non-strict only); `discard` clears the answers and restarts the clock but keeps the paper
 * (non-strict only). Strict mode allows only `save`.
 */
export async function changeMock(auth: Auth, data: unknown, deps: MockDeps): Promise<MockView> {
  const uid = assertNamedUser(auth);
  const body = data as {mockId?: unknown; action?: unknown; answers?: unknown} | null;
  const mockId = body?.mockId;
  if (typeof mockId !== 'string' || !/^[A-Za-z0-9]{10,40}$/.test(mockId)) throw new HttpsError('invalid-argument', 'Bad mock id.');
  const action = body?.action;
  if (action !== 'save' && action !== 'pause' && action !== 'resume' && action !== 'discard') {
    throw new HttpsError('invalid-argument', 'Unknown action.');
  }
  const now = (deps.now ?? Date.now)();
  const answers = action === 'save' ? checkAnswers(body?.answers, now) : undefined;
  if (!await (deps.allow ?? allowControl)(uid, 'changeMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await endIfTimedOut(deps.db, uid, mockId, now);
  const ref = mocks(deps.db, uid).doc(mockId);
  return deps.db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const row = snapshot.data();
    if (!row) throw new HttpsError('not-found', 'Mock not found.');
    if (row.status !== 'started') throw new HttpsError('failed-precondition', 'This mock is already finished.');
    if (action !== 'save' && row.strict === true) throw new HttpsError('failed-precondition', 'Strict mode does not allow this.');
    let update: Record<string, unknown> = {};
    if (action === 'save') {
      checkPaperAnswers(answers!, row.paper);
      update = {answers};
    }
    else if (action === 'pause') { if (typeof row.pausedAt !== 'number') update = {pausedAt: now}; }
    else if (action === 'resume') {
      if (typeof row.pausedAt === 'number') update = {pausedAt: null, pausedMs: Number(row.pausedMs ?? 0) + Math.max(0, now - row.pausedAt)};
    } else update = {answers: [], startedAt: now, pausedAt: null, pausedMs: 0};
    transaction.update(ref, update);
    return view(mockId, {...row, ...update}, now);
  });
}

/**
 * Records a submission once; a repeat call changes nothing. `reason` is `student` (default; needs
 * answers) or `strict-exit` (a strict mock the student left; answers may be empty).
 */
export async function recordMock(auth: Auth, data: unknown, deps: MockDeps): Promise<{mockId: string; status: string}> {
  const uid = assertNamedUser(auth);
  const body = data as {mockId?: unknown; answers?: unknown; durationMs?: unknown; reason?: unknown} | null;
  const mockId = body?.mockId;
  if (typeof mockId !== 'string' || !/^[A-Za-z0-9]{10,40}$/.test(mockId)) throw new HttpsError('invalid-argument', 'Bad mock id.');
  const reason = body?.reason ?? 'student';
  if (reason !== 'student' && reason !== 'strict-exit') throw new HttpsError('invalid-argument', 'Unknown reason.');
  const now = (deps.now ?? Date.now)();
  const early = reason === 'strict-exit';
  const answers = early && Array.isArray(body?.answers) && body.answers.length === 0 ? [] : checkAnswers(body?.answers, now);
  const durationMs = checkDuration(body?.durationMs);
  if (!await (deps.allow ?? allowDefault)(uid, 'submitMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await endIfTimedOut(deps.db, uid, mockId, now);
  const ref = mocks(deps.db, uid).doc(mockId);
  return deps.db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) throw new HttpsError('not-found', 'Mock not found.');
    const status = String(snapshot.get('status'));
    if (status !== 'started') {
      if (status === 'submitted') await recordMockAnswers(transaction, deps.db, uid, mockId, snapshot.data()!, now);
      return {mockId, status};
    }
    checkPaperAnswers(answers, snapshot.get('paper'));
    if (early && snapshot.get('strict') !== true) throw new HttpsError('invalid-argument', 'Only a strict mock ends early.');
    await recordMockAnswers(transaction, deps.db, uid, mockId, {...snapshot.data(), submittedAt: now, durationMs, answers}, now);
    transaction.update(ref, {status: 'submitted', submittedAt: now, endedBy: early ? 'strict-exit' : 'student', durationMs,
      answers, answerCount: answers.length, score: scoreOf(answers, snapshot.get('paper'))});
    return {mockId, status: 'submitted'};
  });
}

export const startMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true, consumeAppCheckToken: true},
  request => beginMock(request.auth as Auth, request.data, {db: getFirestore()}));

export const getMockPaper = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => readMock(request.auth as Auth, request.data, {db: getFirestore()}));

export const controlMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => changeMock(request.auth as Auth, request.data, {db: getFirestore()}));

export const submitMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => recordMock(request.auth as Auth, request.data, {db: getFirestore()}));
