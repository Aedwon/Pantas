import {createHash, randomInt} from 'node:crypto';
import {getFirestore, type Firestore, type Transaction} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import {assertNamedUser} from './_audit.js';
import {allowAtMost} from './_limits.js';
import {checkAnswers, checkDuration, type Answer} from './_answers.js';
import {core} from './_core.js';
import {applyScope, loadCorpusCached, loadExamContent} from './_examContent.js';
import {customTrackRef, isCustomExamId, isStudyExamId} from './_customTrack.js';
import {mockCoverage} from './mockAccess.js';
import {checkPaperAnswers, recordMockAnswers} from './mockAnswers.js';
import {timed} from './_timed.js';
import {clockChanged, clockNow, endPartNow, mergePartAnswers, newPartClock, partsView, settleParts, startPartNow, submitParts,
  totalRemainingMs, usedTotalMs, type ClockRow, type PartsView, type Settled} from './_mockParts.js';

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

type MockView = {mockId: string; examId: string; examName?: string; startedAt: number; strict: boolean; limitMs: number;
  remainingMs: number; paused: boolean; paper: Paper; answers: Answer[]; parts?: PartsView};

type PartRow = FirebaseFirestore.DocumentData & ClockRow;
/** A by-part row with its clock replaced by the settled one. */
const settledRow = (row: FirebaseFirestore.DocumentData, clock: Settled): PartRow =>
  ({...row, parts: clock.parts, pausedAt: clock.pausedAt, pausedMs: clock.pausedMs});

function view(mockId: string, row: FirebaseFirestore.DocumentData, now: number): MockView {
  // A by-part row is always shown settled, so a client never reads a part that has already run out.
  const live = row.parts ? settledRow(row, settleParts(row as PartRow, now)) : row;
  return {
    mockId, examId: row.examId, ...(typeof row.examName === 'string' ? {examName: row.examName} : {}), startedAt: row.startedAt, strict: row.strict === true, limitMs: row.limitMs,
    remainingMs: row.parts ? totalRemainingMs(live as PartRow, now) : Math.max(0, Number(row.limitMs) - elapsedMs(row, now)), paused: typeof live.pausedAt === 'number',
    paper: row.paper, answers: row.answers ?? [], ...(row.parts ? {parts: partsView(live as PartRow, now)} : {}),
  };
}

type TimedOut = {mockId: string; endedBy: EndedBy; submittedAt: number; score: Score};

/** Submits a by-part mock whose last part ran out, at the moment it ran out, on the answers the server holds. */
async function finishByTime(transaction: Transaction, db: Firestore, uid: string, mockId: string,
  row: FirebaseFirestore.DocumentData, clock: Settled, now: number): Promise<TimedOut> {
  const submittedAt = Number(clock.finishedAt);
  const durationMs = usedTotalMs(settledRow(row, clock), now);
  const answers = (row.answers ?? []) as Answer[];
  const score = scoreOf(answers, row.paper);
  await recordMockAnswers(transaction, db, uid, mockId, {...row, submittedAt, durationMs}, now);
  transaction.update(mocks(db, uid).doc(mockId), {status: 'submitted', submittedAt, endedBy: 'time-out', durationMs,
    answerCount: answers.length, score, parts: clock.parts, pausedAt: clock.pausedAt, pausedMs: clock.pausedMs});
  return {mockId, endedBy: 'time-out', submittedAt, score};
}

/**
 * Ends a strict mock whose time ran out, scoring the saved answers. Submission is the moment time
 * ran out, so the Free allowance counts from then, not from the student's next visit. Does nothing
 * for a non-strict mock (the app ends it) or one with time left. A by-part mock of either kind is
 * settled instead: parts that ran out are closed at their exact moments, and the paper is submitted
 * when the last part runs out.
 */
export async function endIfTimedOut(db: Firestore, uid: string, mockId: string, now: number):
  Promise<TimedOut | null> {
  return db.runTransaction(async (transaction) => {
    const ref = mocks(db, uid).doc(mockId);
    const snapshot = await transaction.get(ref);
    const row = snapshot.data();
    if (row && row.status === 'started' && row.parts) {
      const clock = settleParts(row as PartRow, now);
      if (clock.finishedAt !== null) return finishByTime(transaction, db, uid, mockId, row, clock, now);
      if (clockChanged(row as PartRow, clock)) transaction.update(ref, {parts: clock.parts, pausedAt: clock.pausedAt, pausedMs: clock.pausedMs});
      return null;
    }
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

type Assembled = {paper: Paper; limitMs: number; sectionMinutes: number[] | null};
const notEnough = () => new HttpsError('failed-precondition', 'There are not enough questions for this mock yet.');

/** The ids of the student's last two submitted papers for this exam, which a new paper avoids. */
async function recentQuestionIds(db: Firestore, uid: string, examId: string): Promise<string[]> {
  const last = await mocks(db, uid).where('examId', '==', examId).where('submittedAt', '>', 0).orderBy('submittedAt', 'desc').limit(2).get();
  return last.docs.flatMap(doc => ((doc.get('paper') as Paper | undefined)?.sections ?? []).flatMap(s => s.questions.map(q => q.id)));
}

export async function assemblePaper(db: Firestore, uid: string, examId: string, now: number, seed: number): Promise<Assembled> {
  if (isCustomExamId(examId)) return assembleCustomPaper(db, uid, examId, now, seed);
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
  const recent = await recentQuestionIds(db, uid, examId);
  let sampled: {expectedQuestionCount: number; sections: {sectionId: string; name: string; questionIds: string[]}[]};
  try {
    sampled = JSON.parse(core().sampleMock(JSON.stringify({
      sectionsJson: blueprint.get('sectionsJson'), poolsByTopic, passageSetsByTopic,
      recentlySampledQuestionIds: recent, seed,
    })));
  } catch {
    throw notEnough();
  }
  const paper: Paper = {
    expectedQuestionCount: sampled.expectedQuestionCount,
    sections: sampled.sections.map(section => ({sectionId: section.sectionId, name: section.name,
      questions: section.questionIds.map(id => ({id, setId: setOf.get(id) ?? ''}))})),
  };
  return {paper, limitMs: Number(blueprint.get('durationMinutes')) * 60_000, sectionMinutes: null};
}

type CustomSection = {id: string; name: string; questionCount: number; suggestedMinutes: number; topicIds: string[]};
type Question = {id: string; setId: string; passageId: string | null};

/**
 * A student's own paper, drawn from the whole corpus minus the topics they switched off. Sections are
 * filled narrowest first, so a subject part is never left short by a wider part that listed it earlier.
 * No question appears twice on the paper. The compiled sampler is called once per section over the
 * questions still unused, with topic weights set to each topic's share of them, so it is never asked
 * for more than a topic holds. What it cannot place (a small topic, or whole passages that do not fit)
 * is topped up from the same topics, free-standing questions first and partial passages last.
 */
async function assembleCustomPaper(db: Firestore, uid: string, examId: string, now: number, seed: number): Promise<Assembled> {
  const [track, settings] = await Promise.all([customTrackRef(db, uid, examId).get(), db.doc(`users/${uid}/server/settings`).get()]);
  const plan = track.get('blueprint') as {sectionsJson?: unknown; totalMinutes?: unknown; sectionsTimedSeparately?: unknown} | null | undefined;
  if (!track.exists || typeof plan?.sectionsJson !== 'string') throw new HttpsError('failed-precondition', 'This exam has no mock yet.');
  let sections: CustomSection[];
  try { sections = JSON.parse(plan.sectionsJson); } catch { sections = []; }
  if (!Array.isArray(sections) || sections.length === 0) throw new HttpsError('failed-precondition', 'This exam has no mock yet.');
  // The active exam keeps its scope in the settings. Any other custom exam falls back to its own copy.
  const scope = settings.get('examId') === examId ? settings : track;
  const content = applyScope(await loadCorpusCached(db, now), scope.get('excludedTopicIds') ?? [], scope.get('excludedLessonIds') ?? []);
  const byTopic = new Map<string, Question[]>();
  const setOf = new Map<string, string>();
  for (const q of content.questions) {
    if (byTopic.has(q.topicId)) byTopic.get(q.topicId)!.push(q); else byTopic.set(q.topicId, [q]);
    setOf.set(q.id, q.setId);
  }
  const recent = await recentQuestionIds(db, uid, examId);
  const recentIds = new Set(recent);
  const order = sections.map((section, index) => ({section, index, topics: [...new Set(section.topicIds)].filter(topic => byTopic.has(topic))}))
    .sort((a, b) => a.topics.length - b.topics.length || a.index - b.index);
  const used = new Set<string>();
  const filled: string[][] = [];
  for (const [position, {section, index, topics}] of order.entries()) {
    const unused = new Map<string, Question[]>();
    for (const topic of topics) {
      const rest = byTopic.get(topic)!.filter(q => !used.has(q.id));
      if (rest.length > 0) unused.set(topic, rest);
    }
    const available = [...unused.values()].reduce((total, rest) => total + rest.length, 0);
    if (available < section.questionCount) throw notEnough();
    const sectionSeed = (seed + position) % 2 ** 32;
    const poolsByTopic: Record<string, string[]> = {};
    const passageSetsByTopic: Record<string, Record<string, string[]>> = {};
    const topicWeights: Record<string, number> = {};
    for (const [topic, rest] of unused) {
      poolsByTopic[topic] = rest.map(q => q.id);
      topicWeights[topic] = rest.length / available;
      for (const q of rest) if (q.passageId) ((passageSetsByTopic[topic] ??= {})[q.passageId] ??= []).push(q.id);
    }
    let picked: string[] = [];
    try {
      picked = JSON.parse(core().sampleMock(JSON.stringify({
        sectionsJson: JSON.stringify([{id: section.id, name: section.name, questionCount: section.questionCount,
          suggestedMinutes: section.suggestedMinutes, topicIds: [...unused.keys()], topicWeights}]),
        poolsByTopic, passageSetsByTopic, recentlySampledQuestionIds: recent, seed: sectionSeed,
      }))).sections[0].questionIds;
    } catch (error) {
      // Only passages too big for the section can leave it empty, and the top-up below fills it.
      if (!String(error).startsWith('MockSamplingException')) throw error;
    }
    if (picked.length < section.questionCount) {
      const taken = new Set(picked);
      const hashOf = (id: string) => createHash('sha256').update(`${sectionSeed}${id}`).digest('hex');
      const rest = [...unused.values()].flat().filter(q => !taken.has(q.id)).map(q => ({q, hash: hashOf(q.id)}))
        .sort((a, b) => Number(a.q.passageId !== null) - Number(b.q.passageId !== null) ||
          Number(recentIds.has(a.q.id)) - Number(recentIds.has(b.q.id)) || (a.hash < b.hash ? -1 : a.hash > b.hash ? 1 : 0));
      picked = [...picked, ...rest.slice(0, section.questionCount - picked.length).map(({q}) => q.id)];
    }
    for (const id of picked) used.add(id);
    filled[index] = picked;
  }
  const paper: Paper = {
    expectedQuestionCount: filled.reduce((total, ids) => total + ids.length, 0),
    sections: sections.map((section, index) => ({sectionId: section.id, name: section.name,
      questions: filled[index]!.map(id => ({id, setId: setOf.get(id) ?? ''}))})),
  };
  return {paper, limitMs: Number(plan.totalMinutes) * 60_000,
    sectionMinutes: plan.sectionsTimedSeparately === true ? sections.map(section => section.suggestedMinutes) : null};
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
  if (!isStudyExamId(examId)) throw new HttpsError('invalid-argument', 'Unknown exam.');
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
  const assembled = await assemblePaper(deps.db, uid, examId, now, seed);
  const {paper} = assembled;
  // Two or more parts timed one by one get a clock of their own, pinned here. Nothing in it comes from the client.
  const parts = assembled.sectionMinutes !== null && assembled.sectionMinutes.length >= 2 ? newPartClock(assembled.sectionMinutes, now) : null;
  const limitMs = parts ? parts.limitsMs.reduce((total, limit) => total + limit, 0) : assembled.limitMs;
  // A custom mock keeps the track's name, so a renamed or removed track still reads correctly in Record.
  const examName = isCustomExamId(examId) ? (await customTrackRef(deps.db, uid, examId).get()).get('name') : undefined;
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
      pausedMs: 0, pausedAt: null, ...(typeof examName === 'string' ? {examName} : {}), ...(parts ? {parts} : {})};
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
 * What a by-part action changes, on a row already settled at `now`. Only the running part can take
 * answers or be paused. A repeated `startPart` changes nothing, so it can never restart a clock.
 */
function changePart(action: string, answers: Answer[] | undefined, row: PartRow, now: number): Record<string, unknown> {
  const running = row.parts.startedAt !== null;
  if (action === 'save') {
    checkPaperAnswers(answers!, row.paper);
    return {answers: mergePartAnswers(row.answers ?? [], answers!, row.paper, row.parts)};
  }
  if (action === 'pause') return running && typeof row.pausedAt !== 'number' ? {pausedAt: now} : {};
  if (action === 'resume') {
    return running && typeof row.pausedAt === 'number' ? {pausedAt: null, pausedMs: Number(row.pausedMs ?? 0) + Math.max(0, now - row.pausedAt)} : {};
  }
  if (action === 'startPart') return running ? {} : {parts: startPartNow(row.parts, now)};
  if (action === 'endPart') {
    if (!running) throw new HttpsError('failed-precondition', 'No part is running.');
    if (row.parts.index === row.parts.limitsMs.length - 1) throw new HttpsError('failed-precondition', 'This is the last part. Submit the mock instead.');
    return {parts: endPartNow(row, now), pausedAt: null, pausedMs: 0};
  }
  return {answers: [], startedAt: now, pausedAt: null, pausedMs: 0, parts: newPartClock((row.parts.limitsMs as number[]).map(limit => limit / 60_000), now)};
}

/**
 * Changes the open mock: `save` replaces the saved answers; `pause` and `resume` record a pause
 * (non-strict only); `discard` clears the answers and restarts the clock but keeps the paper
 * (non-strict only). Strict mode allows only `save`. A by-part mock settles its clock first, and
 * also takes `startPart` (any mode) and `endPart` (non-strict only); `save` keeps only the running
 * part's answers.
 */
export async function changeMock(auth: Auth, data: unknown, deps: MockDeps): Promise<MockView> {
  const uid = assertNamedUser(auth);
  const body = data as {mockId?: unknown; action?: unknown; answers?: unknown} | null;
  const mockId = body?.mockId;
  if (typeof mockId !== 'string' || !/^[A-Za-z0-9]{10,40}$/.test(mockId)) throw new HttpsError('invalid-argument', 'Bad mock id.');
  const action = body?.action;
  if (action !== 'save' && action !== 'pause' && action !== 'resume' && action !== 'discard' && action !== 'startPart' && action !== 'endPart') {
    throw new HttpsError('invalid-argument', 'Unknown action.');
  }
  // The new actions belong to by-part mocks only. Any other row answers as it did before they existed, and
  // is not settled, ended or rate limited by them.
  if (action === 'startPart' || action === 'endPart') {
    if (!(await mocks(deps.db, uid).doc(mockId).get()).get('parts')) throw new HttpsError('invalid-argument', 'Unknown action.');
  }
  const now = (deps.now ?? Date.now)();
  const answers = action === 'save' ? checkAnswers(body?.answers, now) : undefined;
  if (!await (deps.allow ?? allowControl)(uid, 'changeMock')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await endIfTimedOut(deps.db, uid, mockId, now);
  const ref = mocks(deps.db, uid).doc(mockId);
  const changed = await deps.db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const row = snapshot.data();
    if (!row) throw new HttpsError('not-found', 'Mock not found.');
    if (row.status !== 'started') throw new HttpsError('failed-precondition', 'This mock is already finished.');
    // The request may have waited since `now` was read, so a by-part row is stamped at the clock's own time.
    const at = row.parts ? clockNow(row as PartRow, (deps.now ?? Date.now)()) : now;
    const clock = row.parts ? settleParts(row as PartRow, at) : null;
    // The pre-step above has settled this row. Time can run out here only through a call that raced this one.
    // The submission must commit, so the error is thrown after the transaction returns, not inside it.
    if (clock && clock.finishedAt !== null) {
      await finishByTime(transaction, deps.db, uid, mockId, row, clock, at);
      return 'finished' as const;
    }
    if (action !== 'save' && !(clock && action === 'startPart') && row.strict === true) throw new HttpsError('failed-precondition', 'Strict mode does not allow this.');
    if (clock) {
      const live = settledRow(row, clock);
      const change = changePart(action, answers, live, at);
      const update = {...(clockChanged(row as PartRow, clock) ? {parts: clock.parts, pausedAt: clock.pausedAt, pausedMs: clock.pausedMs} : {}), ...change};
      if (Object.keys(update).length > 0) transaction.update(ref, update);
      return view(mockId, {...live, ...change}, at);
    }
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
  if (changed === 'finished') throw new HttpsError('failed-precondition', 'This mock is already finished.');
  return changed;
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
    // The request may have waited since `now` was read, so a by-part row is stamped at the clock's own time.
    const at = snapshot.get('parts') ? clockNow(snapshot.data() as PartRow, (deps.now ?? Date.now)()) : now;
    if (status !== 'started') {
      if (status === 'submitted') await recordMockAnswers(transaction, deps.db, uid, mockId, snapshot.data()!, at);
      return {mockId, status};
    }
    const row = snapshot.data()!;
    const clock = row.parts ? settleParts(row as PartRow, at) : null;
    if (clock && clock.finishedAt !== null) {
      await finishByTime(transaction, deps.db, uid, mockId, row, clock, at);
      return {mockId, status: 'submitted'};
    }
    checkPaperAnswers(answers, snapshot.get('paper'));
    if (early && snapshot.get('strict') !== true) throw new HttpsError('invalid-argument', 'Only a strict mock ends early.');
    // A by-part mock keeps closed parts as stored, and counts its own time: the sent duration is only checked.
    const live = clock ? settledRow(row, clock) : null;
    const kept = live ? mergePartAnswers(row.answers ?? [], answers, row.paper, live.parts) : answers;
    const spent = live ? usedTotalMs(live, at) : durationMs;
    const closing = live ? {parts: submitParts(live, at), pausedAt: null, pausedMs: 0} : {};
    await recordMockAnswers(transaction, deps.db, uid, mockId, {...snapshot.data(), submittedAt: at, durationMs: spent, answers: kept}, at);
    transaction.update(ref, {status: 'submitted', submittedAt: at, endedBy: early ? 'strict-exit' : 'student', durationMs: spent,
      answers: kept, answerCount: kept.length, score: scoreOf(kept, snapshot.get('paper')), ...closing});
    return {mockId, status: 'submitted'};
  });
}

export const startMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck, consumeAppCheckToken: enforceAppCheck},
  timed('startMock', request => {
    assertFreshAppCheck(request);
    return beginMock(request.auth as Auth, request.data, {db: getFirestore()});
  }));

export const getMockPaper = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('getMockPaper', request => readMock(request.auth as Auth, request.data, {db: getFirestore()})));

export const controlMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('controlMock', request => changeMock(request.auth as Auth, request.data, {db: getFirestore()})));

export const submitMock = onCall(
  {region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('submitMock', request => recordMock(request.auth as Auth, request.data, {db: getFirestore()})));
