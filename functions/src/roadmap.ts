import {createHash} from 'node:crypto';
import {FieldPath, getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {core} from './_core.js';
import {loadExamContent, loadStudyContent} from './_examContent.js';
import {phDay, phStamp} from './_phDate.js';
import {hasLiveProClaim} from './_pro.js';
import {examCatalog} from './revenuecatPasses.js';
import {completedOn, firstCompletedBefore, loadTotals, sessionTimesOf, totalsIn, viewOf, type AnswerView, type Totals, totalsRef} from './_answerTotals.js';
import {dueReviewInputs} from './serverReviews.js';
import {assertStudyOwner} from './studyObservations.js';
import {mockCoverage} from './mockAccess.js';
import {readStudyInsights} from './studyInsights.js';

/**
 * Where the exam date and study days live on the server. The app keeps them in its own settings, so
 * it sends them here whenever they change. Only the server reads this document.
 */
export type ExamSettings = {
  examId: string;
  examDate: null | {precision: 'day'; day: string} | {precision: 'month'; year: number; month: number};
  studyDays: number[];
  assessmentCompleted?: boolean;
  excludedTopicIds?: string[];
};

type Auth = {uid: string; token: object} | undefined;
export type RoadmapDeps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};

type Roadmap = {
  state: string; today: Record<string, unknown>; examDay: string | null; reviewOnlyFrom: string | null; mockDay: string | null;
  weeksAhead: unknown[]; topicOrder: string[]; changes: unknown[]; backlogCapped: boolean; cycleDetected: boolean;
};

const DAY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
const bad = (message: string) => new HttpsError('invalid-argument', message);
const settingsRef = (db: Firestore, uid: string) => db.doc(`users/${uid}/server/settings`);
const roadmapRef = (db: Firestore, uid: string) => db.doc(`users/${uid}/server/roadmap`);
const allowDefault = (uid: string, key: string) => allowAtMost(uid, key, 600, 3_600_000);

function validDay(value: unknown): value is string {
  if (typeof value !== 'string' || !DAY_PATTERN.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value;
}

export function checkSettings(data: unknown): ExamSettings {
  const body = data as Record<string, unknown> | null;
  const examId = body?.examId;
  if (typeof examId !== 'string' || !examCatalog.some(exam => exam.id === examId)) throw bad('Unknown exam.');
  const days = body?.studyDays;
  if (!Array.isArray(days) || days.length < 1 || days.length > 7
      || !days.every((day): day is number => Number.isInteger(day) && day >= 1 && day <= 7)) {
    throw bad('Study days must be 1 to 7 weekdays, Monday is 1.');
  }
  const raw = body?.examDate as Record<string, unknown> | null | undefined;
  let examDate: ExamSettings['examDate'] = null;
  if (raw !== null && raw !== undefined) {
    if (typeof raw !== 'object') throw bad('Bad exam date.');
    if (raw.precision === 'day' && validDay(raw.day)) examDate = {precision: 'day', day: raw.day};
    else if (raw.precision === 'month' && Number.isInteger(raw.year) && Number.isInteger(raw.month)
        && (raw.year as number) >= 2020 && (raw.year as number) <= 2100 && (raw.month as number) >= 1 && (raw.month as number) <= 12) {
      examDate = {precision: 'month', year: raw.year as number, month: raw.month as number};
    } else throw bad('Bad exam date.');
  }
  const assessed = body?.assessmentCompleted;
  if (assessed !== undefined && typeof assessed !== 'boolean') throw bad('Bad assessment flag.');
  const excluded = body?.excludedTopicIds;
  if (excluded !== undefined && (!Array.isArray(excluded) || excluded.length > 1000 ||
      excluded.some(id => typeof id !== 'string' || !id || id.length > 128))) throw bad('Bad excluded topics.');
  return {examId, examDate, ...(excluded === undefined ? {} : {excludedTopicIds: [...new Set(excluded as string[])].sort()}), studyDays: [...new Set(days)].sort((a, b) => a - b),
    ...(assessed === undefined ? {} : {assessmentCompleted: assessed})};
}

const examKey = (settings: ExamSettings) => `${settings.examId}|${JSON.stringify(settings.examDate)}`;

/**
 * Builds the roadmap inputs from what the server holds and runs the compiled Dart engine. Every
 * date goes in as a Philippine calendar value. Not on the server yet, so left empty: lesson read
 * times, review (spaced repetition) state and custom blueprints.
 */
export async function build(db: Firestore, uid: string, settings: ExamSettings, pro: boolean, now: number,
  view?: (topicOf: Map<string, string>) => Promise<AnswerView>) {
  const content = await loadExamContent(db, settings.examId, now);
  const topicOf = new Map(content.questions.map(question => [question.id, question.topicId]));
  // One read of the running totals. `view` lets a test supply the old full scan to compare against.
  const answers = await (view ? view(topicOf) : loadTotals(db, uid).then(totals => viewOf(totals, topicOf)));
  const sessions = answers.sessions;
  const blueprint = (await db.doc(`content/mocks/items/${settings.examId}`).get()).exists;
  const lastMock = await db.collection(`users/${uid}/server/mocks/items`).orderBy('submittedAt', 'desc').limit(1).get();
  const lastSubmittedAt = lastMock.docs[0]?.get('submittedAt') as number | undefined;
  const previous = await roadmapRef(db, uid).get();
  const sameExam = previous.exists && previous.get('examKey') === examKey(settings);
  const previousReviewOnly = sameExam
    ? (JSON.parse(String(previous.get('roadmapJson'))) as Roadmap).reviewOnlyFrom : null;
  const inputs = {
    today: phDay(now),
    examId: settings.examId,
    examDate: settings.examDate,
    topics: content.topics.map((topic, authoredIndex) => ({id: topic.id, authoredIndex, name: topic.name})),
    // Left out so the engine uses the app's own list of prerequisites.
    prerequisites: null,
    lessons: content.lessons.map(lesson => ({id: lesson.id, topicId: lesson.topicId, ordering: lesson.ordering, readAt: null})),
    questions: content.questions.map(q => ({id: q.id, topicId: q.topicId, lessonId: null, passageId: q.passageId})),
    seenQuestionIds: answers.seenQuestionIds,
    dueReviews: await dueReviewInputs(db, uid, now, new Set(content.questions.map(q => q.id))),
    scores: answers.scores,
    answeredPerActiveDay: answers.answeredPerActiveDay,
    mock: {examHasMock: blueprint, proIsActive: pro, lastSubmittedAt: lastSubmittedAt === undefined ? null : phStamp(lastSubmittedAt)},
    assessmentCompleted: settings.assessmentCompleted ?? answers.anyAnswers,
    contentRevision: 'server',
    anchoredReviewOnlyFrom: previousReviewOnly,
    studyDays: settings.studyDays,
    treatTodayAsStudyDay: false,
  };
  return {roadmap: JSON.parse(core().buildRoadmap(JSON.stringify(inputs))) as Roadmap, sessions};
}

/** Recomputes and stores the roadmap. Returns null when the account has no exam settings yet. */
export async function computeRoadmap(db: Firestore, uid: string, pro: boolean, now: number):
  Promise<{roadmap: Roadmap; pro: boolean; today: string} | null> {
  const snapshot = await settingsRef(db, uid).get();
  if (!snapshot.exists) return null;
  const settings = snapshot.data() as ExamSettings;
  const {roadmap, sessions} = await build(db, uid, settings, pro, now);
  const today = phDay(now);
  await roadmapRef(db, uid).set({computedAt: now, today, pro, examKey: examKey(settings), answerSessions: sessions,
    roadmapJson: JSON.stringify(roadmap)});
  // C7 catalogs identify accounts ready for the complete C10 derivation.
  // Old pre-catalog sessions keep their existing compatibility projection.
  if ((await db.doc('content/catalog/items/' + settings.examId).get()).exists) {
    const input={expectedUid:uid,examId:settings.examId};
    const deps={db,now:()=>now,allow:async()=>true};
    await readStudyRoadmap({uid},input,deps);
    await readStudyInsights({uid},input,deps);
  }
  return {roadmap, pro, today};
}

/** Stores the exam date, study days and the rest of the plan's settings, then rebuilds the roadmap. */
export async function saveExamSettings(auth: Auth, data: unknown, deps: RoadmapDeps): Promise<{stored: true}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const requestBody = studyObject(data);
  assertStudyOwner(auth.uid, requestBody, requestBody.expectedUid !== undefined || requestBody.excludedTopicIds !== undefined);
  const settings = checkSettings(data);
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowDefault)(auth.uid, 'saveExamSettings')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await deps.db.runTransaction(async tx=>{
    if (settings.excludedTopicIds !== undefined) {
      const content = await loadStudyContent(deps.db, settings.examId,tx);
      if (settings.excludedTopicIds.some(id => !content.topics.some(t => t.id === id)) ||
          content.topics.every(t => settings.excludedTopicIds!.includes(t.id))) throw bad('Choose at least one known topic.');
    }
    tx.set(settingsRef(deps.db, auth.uid),{...settings, updatedAt: now});
  });
  await computeRoadmap(deps.db, auth.uid, hasLiveProClaim(auth.token as {pro?: unknown; proUntil?: unknown}, now), now);
  return {stored: true};
}

type Served = {tier: 'free' | 'pro'; state: string; today?: Record<string, unknown>; backlogCapped?: boolean;
  comingUp?: Record<string, unknown>; history?: Record<string, unknown>};

/**
 * Returns the stored roadmap, cut to the tier. Free: Today. Pro: Today, Coming up and History.
 * The Pro parts are never in a Free response. A stored roadmap from an earlier Philippine day, or
 * built for the other tier, is rebuilt first.
 */
export async function serveRoadmap(auth: Auth, _data: unknown, deps: RoadmapDeps): Promise<Served> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowDefault)(auth.uid, 'getRoadmap')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const pro = hasLiveProClaim(auth.token as {pro?: unknown; proUntil?: unknown}, now);
  const tier = pro ? 'pro' : 'free';
  const [stored, currentTotals] = await Promise.all([roadmapRef(deps.db, auth.uid).get(), loadTotals(deps.db, auth.uid)]);
  let roadmap: Roadmap;
  if (stored.exists && stored.get('today') === phDay(now) && stored.get('pro') === pro && stored.get('answerSessions') === currentTotals.sessions) {
    roadmap = JSON.parse(String(stored.get('roadmapJson'))) as Roadmap;
  } else {
    const fresh = await computeRoadmap(deps.db, auth.uid, pro, now);
    if (!fresh) return {tier, state: 'noSettings'};
    roadmap = fresh.roadmap;
  }
  const out: Served = {tier, state: roadmap.state, today: roadmap.today, backlogCapped: roadmap.backlogCapped};
  if (pro) {
    out.comingUp = {examDay: roadmap.examDay, reviewOnlyFrom: roadmap.reviewOnlyFrom, mockDay: roadmap.mockDay,
      weeksAhead: roadmap.weeksAhead, topicOrder: roadmap.topicOrder};
    out.history = {changes: roadmap.changes};
  }
  return out;
}

export const setExamSettings = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => saveExamSettings(request.auth, request.data, {db: getFirestore()}));

export const getRoadmap = onCall(
  {region: 'asia-southeast1', enforceAppCheck: true},
  request => readStudyRoadmap(request.auth, request.data, {db: getFirestore()}));

type StudyBody = Record<string, any>;
type StudyAuth = {uid: string; token?: object} | undefined;
type StudyPlan = {day: string; lessonIds: string[]; reviewQuestionIds: string[]; newQuestionIds: string[];
  isMockDay: boolean; isRestDay: boolean; advancedIds: string[]};
type StudyState = {snapshot: StudyBody; today: StudyPlan; remaining: StudyPlan; originalDone: boolean;
  canAdvance: boolean; roadmap: Roadmap; changes: StudyBody[]};
const studyDays = (db: Firestore, uid: string) => db.collection('users/' + uid + '/server/roadmapDays/items');
const studyHistory = (db: Firestore, uid: string) => db.collection('users/' + uid + '/server/roadmapHistory/items');
const studyDayId = (examId: string, day: string) => examId + ':' + day;
function studyObject(data: unknown): StudyBody {
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw bad('Send an object.');
  return data as StudyBody;
}
async function studyCaller(auth: StudyAuth, data: unknown, deps: RoadmapDeps, key: string) {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const body = studyObject(data);
  assertStudyOwner(auth.uid, body);
  if (typeof body.examId !== 'string' || !examCatalog.some(e => e.id === body.examId)) throw bad('Unknown exam.');
  if (!await (deps.allow ?? allowDefault)(auth.uid, key)) throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  return {uid: auth.uid, body, now: (deps.now ?? Date.now)()};
}
const runCoreState = (input: StudyBody) => JSON.parse(core().roadmapState(JSON.stringify(input))) as StudyState;
const emptyPlan = (day: string): StudyPlan => ({day, lessonIds: [], reviewQuestionIds: [], newQuestionIds: [],
  isMockDay: false, isRestDay: false, advancedIds: []});
const DAY_MS = 86_400_000;
const dayStart = (day: string) => Date.parse(day + 'T00:00:00+08:00');
/**
 * The questions completed on a past Philippine day. The totals' mask answers for the last 14 days; an
 * older day is read from the stored sessions themselves, so pruned data is never mistaken for missed.
 * A session counts on its actual finish day, a legacy batch on each answer's own day.
 */
async function completedOnDay(tx: FirebaseFirestore.Transaction, db: Firestore, uid: string, totals: Totals, day: string) {
  const masked = completedOn(totals, day);
  if (masked.covered) return masked.ids;
  const start = dayStart(day), end = start + DAY_MS, ids = new Set<string>();
  // A legacy answer can be older than its session's finish by up to a day, so look one day further.
  const rows = await tx.get(db.collection('users/' + uid + '/server/answers/items')
    .where('finishedAt', '>=', start).where('finishedAt', '<', end + DAY_MS)
    .select('answers', 'examId', 'origin', 'startedAt', 'finishedAt'));
  for (const doc of rows.docs) {
    const answers = doc.get('answers') as {questionId: string; answeredAt?: number}[];
    if (sessionTimesOf(doc)) {
      const finished = Number(doc.get('finishedAt'));
      if (finished >= start && finished < end) for (const a of answers) ids.add(a.questionId);
    } else for (const a of answers) if (a.answeredAt !== undefined && a.answeredAt >= start && a.answeredAt < end) ids.add(a.questionId);
  }
  return ids;
}
/** What the stored snapshot of `day` looks like given the real observations through the end of that day. */
function historicalView(context: Awaited<ReturnType<typeof studyContext>>, stored: FirebaseFirestore.DocumentSnapshot,
  day: string, reviewedToday: Set<string>) {
  const snapshot = JSON.parse(String(stored.get('snapshotJson')));
  const end = dayStart(day) + DAY_MS;
  return runCoreState({operation:'snapshotView',snapshot,completion:{
    readLessonIds:context.reads.docs.filter(d=>Number(d.get('readAt'))<end).map(d=>String(d.get('lessonId'))),
    seenQuestionIds:[...firstCompletedBefore(context.totals, end)],reviewedTodayIds:[...reviewedToday]}});
}
function revisionOf(settings: StudyBody, contentRevision: string, totals: Totals, readRows: FirebaseFirestore.QuerySnapshot) {
  return createHash('sha256').update(JSON.stringify([settings, contentRevision, totals.sessions,
    readRows.docs.map(d => [d.id, d.get('readAt')])])).digest('hex');
}
async function studyContext(tx: FirebaseFirestore.Transaction, db: Firestore, uid: string, examId: string, now: number) {
  const settings = await tx.get(settingsRef(db, uid));
  if (!settings.exists) throw new HttpsError('failed-precondition', 'Set your exam first.');
  const config = settings.data() as ExamSettings;
  if (config.examId !== examId) throw new HttpsError('failed-precondition', 'Your exam changed. Open this screen again.');
  const [allContent, totalDoc, reads, reviews, mocks, access, previousDays, blueprint] = await Promise.all([
    loadStudyContent(db, examId, tx), tx.get(totalsRef(db, uid)),
    tx.get(db.collection('users/' + uid + '/server/lessonReads/items')),
    tx.get(db.collection('users/' + uid + '/server/reviews/items')),
    tx.get(db.collection('users/' + uid + '/server/mocks/items').where('submittedAt', '>', 0)),
    mockCoverage(tx, db, uid, now),
    tx.get(studyDays(db, uid).where('examId', '==', examId).orderBy('day', 'desc').limit(14)),
    tx.get(db.doc('content/mocks/items/' + examId)),
  ]);
  const excluded = new Set(config.excludedTopicIds ?? []);
  const includedTopics = new Set(allContent.topics.filter(t => !excluded.has(t.id)).map(t => t.id));
  const content = {...allContent,topics:allContent.topics.filter(t => includedTopics.has(t.id)),
    lessons:allContent.lessons.filter(l => includedTopics.has(l.topicId)),
    questions:allContent.questions.filter(q => includedTopics.has(q.topicId))};
  const totals = await totalsIn(tx, db, uid, totalDoc), topicOf = new Map(content.questions.map(q => [q.id, q.topicId]));
  const answerView = viewOf(totals, topicOf), today = phDay(now);
  const sameDay = previousDays.docs.find(d => d.get('day') === today);
  const priorRow = sameDay ?? previousDays.docs.find(d => d.get('day') < today);
  const prior = priorRow ? JSON.parse(String(priorRow.get('snapshotJson'))) : null;
  const sameDate = prior?.digest ? JSON.parse(prior.digest).examDate === examDateKey(config) : false;
  const stateRows = reviews.docs.map(d => JSON.parse(String(d.get('stateJson'))));
  const endOfToday = Date.parse(today + 'T00:00:00+08:00') + 86400000;
  const dueStates = stateRows.filter(s => topicOf.has(s.questionId) && Date.parse(s.due) < endOfToday);
  const due = dueStates.length ? JSON.parse(core().dueReviews(JSON.stringify({now, states: dueStates}))) as
    {id: string; due: number; retrievability: number}[] : [];
  const relevantMocks = mocks.docs.filter(d => d.get('examId') === examId);
  const lastMock = relevantMocks.reduce<number | null>((a,d) => Math.max(a ?? 0, Number(d.get('submittedAt'))), null);
  const pro = access.coversExam(examId);
  const inputs = {
    today, examId, examDate: config.examDate, studyDays: config.studyDays, treatTodayAsStudyDay: false,
    topics: content.topics.map((t, i) => ({id: t.id, name: t.name, authoredIndex: i})), prerequisites: null,
    lessons: content.lessons.map(l => ({...l, readAt: reads.docs.find(d => d.get('lessonId') === l.id)?.get('readAt') == null
      ? null : phStamp(Number(reads.docs.find(d => d.get('lessonId') === l.id)!.get('readAt')))})),
    questions: content.questions, seenQuestionIds: answerView.seenQuestionIds,
    dueReviews: due.map(r => ({...r, due: phStamp(r.due)})),
    scores: answerView.scores, answeredPerActiveDay: answerView.answeredPerActiveDay,
    mock: {examHasMock: blueprint.exists, proIsActive: pro, lastSubmittedAt: lastMock === null ? null : phStamp(lastMock)},
    assessmentCompleted: config.assessmentCompleted ?? answerView.anyAnswers,
    contentRevision: content.revision, anchoredReviewOnlyFrom: sameDate ? prior?.reviewOnlyFrom ?? null : null,
  };
  const digest = JSON.stringify({examId, examDate: examDateKey(config), scope: content.topics.map(t => t.id).sort(),
    content: content.revision, assessed: inputs.assessmentCompleted, mocks: relevantMocks.length,
    studyDays: config.studyDays.join(',')});
  const readIds = reads.docs.map(d => String(d.get('lessonId')));
  const completion = {readLessonIds: readIds, seenQuestionIds: answerView.seenQuestionIds, reviewedTodayIds: [...completedOn(totals, today).ids]};
  const priorDay: string = priorRow?.get('day') ?? today;
  const priorCompletion = {...completion, reviewedTodayIds: priorDay === today ? completion.reviewedTodayIds
    : [...await completedOnDay(tx, db, uid, totals, priorDay)]};
  const input = {inputs, completion, priorCompletion, snapshot: prior, digest, now: phStamp(now), operation: 'read'};
  const state = runCoreState(input);
  return {config, content, totals, reads, reviews, mocks, access, pro, today, inputs, input, state,
    revision: revisionOf(settings.data()!, content.revision, totals, reads), previousDays};
}
function examDateKey(config: ExamSettings) {
  if (!config.examDate) return '';
  return config.examDate.precision === 'day' ? config.examDate.day + ':day'
    : config.examDate.year + '-' + String(config.examDate.month).padStart(2, '0') + '-01:month';
}
function saveStudyState(tx: FirebaseFirestore.Transaction, db: Firestore, uid: string, examId: string,
  context: Awaited<ReturnType<typeof studyContext>>, state: StudyState, now: number) {
  const ref = studyDays(db, uid).doc(studyDayId(examId, context.today));
  const old = context.previousDays.docs.find(d => d.id === ref.id);
  const json = JSON.stringify(state.snapshot);
  const revision = createHash('sha256').update(context.revision + json).digest('hex');
  if (old?.get('snapshotJson') !== json || old?.get('completionRevision') !== context.revision) {
    tx.set(ref, {examId, day: context.today, snapshotJson: json, stateJson: JSON.stringify(state),
      revision, completionRevision: context.revision, updatedAt: now});
    for (let i = 0; i < state.changes.length; i++) {
      const change = state.changes[i];
      const id = createHash('sha256').update(examId + json + JSON.stringify(change) + i).digest('hex');
      tx.set(studyHistory(db, uid).doc(id), {examId, occurredAt: Date.parse(String(change.occurredAt) + '+08:00'),
        changeJson: JSON.stringify(change)});
    }
  }
  return revision;
}
function publicToday(context: Awaited<ReturnType<typeof studyContext>>, state: StudyState, revision: string, now: number) {
  const membership = new Set([...state.today.lessonIds, ...state.today.newQuestionIds, ...state.today.reviewQuestionIds]);
  const actualTopics = new Set([
    ...context.content.lessons.filter(l => membership.has(l.id)).map(l => l.topicId),
    ...context.content.questions.filter(q => membership.has(q.id)).map(q => q.topicId),
  ]);
  const sunday = new Date(context.today + 'T00:00:00Z'); sunday.setUTCDate(sunday.getUTCDate() - sunday.getUTCDay());
  const weekDays = Array.from({length: 7}, (_, i) => {
    const day = new Date(sunday.getTime() + i * 86400000).toISOString().slice(0,10);
    if (day > context.today) return {day, state: 'unknown'};
    if (day === context.today) return {day, state: 'today', plan: state.today, remaining: state.remaining};
    const stored = context.previousDays.docs.find(d => d.get('day') === day);
    if (!stored) return {day, state: 'unknown'};
    const masked = completedOn(context.totals, day);
    // A day of this week is always within the mask; if it ever is not, say unknown rather than guess.
    if (!masked.covered) return {day, state: 'unknown'};
    const previous = historicalView(context,stored,day,masked.ids);
    const original = previous.today.lessonIds.length + previous.today.newQuestionIds.length + previous.today.reviewQuestionIds.length;
    const remaining = previous.remaining.lessonIds.length + previous.remaining.newQuestionIds.length + previous.remaining.reviewQuestionIds.length;
    return {day, state: previous.today.isRestDay ? 'rest' : remaining === 0 ? 'done' : remaining === original ? 'missed' : 'partial',
      plan: previous.today, remaining: previous.remaining};
  });
  return {examId: context.config.examId, serverNow: now, accessRecheckAt: context.access.recheckAt,
    proCovered: context.pro, tier: context.pro ? 'pro' : 'free', state: state.snapshot.state, revision,
    today: state.today, remaining: state.remaining, originalDone: state.originalDone, canAdvance: state.canAdvance,
    todayTopicOrder: (state.snapshot.head as string[]).filter(id => actualTopics.has(id)), weekDays,
    backlogCapped: state.roadmap.backlogCapped,
    ...(context.pro ? {comingUp: {examDay: state.roadmap.examDay, reviewOnlyFrom: state.roadmap.reviewOnlyFrom,
      mockDay: state.roadmap.mockDay, weeksAhead: state.roadmap.weeksAhead, topicOrder: state.roadmap.topicOrder}} : {})};
}
async function historyPage(tx: FirebaseFirestore.Transaction, db: Firestore, uid: string, examId: string, body: StudyBody, state: StudyState) {
  const limit = body.historyLimit ?? 5;
  if (!Number.isInteger(limit) || limit < 1 || limit > 100) throw bad('Bad history limit.');
  let query = studyHistory(db, uid).where('examId','==',examId).orderBy('occurredAt','desc').orderBy(FieldPath.documentId(),'desc');
  if (body.historyBefore != null) {
    const cursor = studyObject(body.historyBefore);
    if (!Number.isSafeInteger(cursor.occurredAt) || typeof cursor.id !== 'string' || !/^[0-9a-f]{64}$/.test(cursor.id)) throw bad('Bad history cursor.');
    query = query.startAfter(cursor.occurredAt, cursor.id);
  }
  const rows = await tx.get(query.limit(limit + 1));
  const candidates = rows.docs.map(d => ({id:d.id,occurredAt:Number(d.get('occurredAt')),change:JSON.parse(String(d.get('changeJson')))}));
  for(let i=0;i<state.changes.length;i++){
    const change=state.changes[i];
    const id=createHash('sha256').update(examId+JSON.stringify(state.snapshot)+JSON.stringify(change)+i).digest('hex');
    const occurredAt=Date.parse(String(change.occurredAt)+'+08:00');
    const cursor=body.historyBefore;
    if(!cursor || occurredAt<cursor.occurredAt || occurredAt===cursor.occurredAt && id<cursor.id){
      if(!candidates.some(c=>c.id===id))candidates.push({id,occurredAt,change});
    }
  }
  candidates.sort((a,b)=>b.occurredAt-a.occurredAt || (a.id<b.id?1:a.id>b.id?-1:0));
  const page=candidates.slice(0,limit),last=page.at(-1);
  return {changes:page.map(c=>({id:c.id,...c.change})),
    next:candidates.length>limit&&last?{occurredAt:last.occurredAt,id:last.id}:null};
}
export async function readStudyRoadmap(auth: StudyAuth, data: unknown, deps: RoadmapDeps) {
  const {uid, body, now} = await studyCaller(auth, data, deps, 'getRoadmap');
  await loadTotals(deps.db, uid);
  return deps.db.runTransaction(async tx => {
    const context = await studyContext(tx, deps.db, uid, body.examId, now);
    const history = context.pro ? await historyPage(tx, deps.db, uid, body.examId, body,context.state) : undefined;
    const revision = saveStudyState(tx, deps.db, uid, body.examId, context, context.state, now);
    return {...publicToday(context, context.state, revision, now), ...(history ? {history} : {})};
  });
}
export async function advanceStudyRoadmap(auth: StudyAuth, data: unknown, deps: RoadmapDeps) {
  const {uid, body, now} = await studyCaller(auth, data, deps, 'advanceRoadmap');
  if (typeof body.requestId !== 'string' || !/^[A-Za-z0-9_-]{8,128}$/.test(body.requestId) ||
      !validDay(body.expectedDay) || typeof body.expectedRevision !== 'string') throw bad('Bad advance request.');
  const requestRef = deps.db.doc('users/' + uid + '/server/roadmapAdvances/items/' + body.requestId);
  return deps.db.runTransaction(async tx => {
    const saved = await tx.get(requestRef);
    if (saved.exists) {
      if (saved.get('examId') !== body.examId || saved.get('expectedRevision') !== body.expectedRevision ||
          saved.get('expectedDay') !== body.expectedDay) throw new HttpsError('failed-precondition','This advance request changed.');
      // Recheck current access before returning an immutable previous response.
      const [access,settings] = await Promise.all([mockCoverage(tx, deps.db, uid, now),tx.get(settingsRef(deps.db,uid))]);
      if(settings.get('examId')!==body.examId)throw new HttpsError('failed-precondition','Your exam changed. Open this screen again.');
      const original = JSON.parse(String(saved.get('responseJson')));
      if (!access.coversExam(body.examId)) { delete original.comingUp; delete original.history; original.proCovered=false;original.tier='free'; }
      return {...original,serverNow:now,accessRecheckAt:access.recheckAt};
    }
    const context = await studyContext(tx, deps.db, uid, body.examId, now);
    const current = context.previousDays.docs.find(d => d.get('day') === context.today);
    if (body.expectedDay !== context.today || current?.get('revision') !== body.expectedRevision ||
        createHash('sha256').update(context.revision + JSON.stringify(context.state.snapshot)).digest('hex') !== body.expectedRevision) {
      throw new HttpsError('failed-precondition','Your plan changed. Open it again.');
    }
    if (!context.state.originalDone || !context.state.canAdvance) throw new HttpsError('failed-precondition','There is nothing to advance yet.');
    const state = runCoreState({...context.input,operation:'advance'});
    const revision = saveStudyState(tx, deps.db, uid, body.examId, context, state, now);
    const response = publicToday(context,state,revision,now);
    tx.create(requestRef,{examId:body.examId,expectedDay:body.expectedDay,expectedRevision:body.expectedRevision,responseJson:JSON.stringify(response)});
    return response;
  });
}
type Context = Awaited<ReturnType<typeof studyContext>>;
/**
 * One day as the server knows it. All reads happen here; the caller saves today's snapshot afterwards,
 * because a transaction may not read after it writes. A Free account gets no future payload: a single
 * future day is refused, and `lockFuture` turns it into an empty locked entry for a week view.
 */
async function dayView(tx: FirebaseFirestore.Transaction, db: Firestore, uid: string, context: Context, examId: string,
  date: string, lockFuture: boolean): Promise<Record<string, unknown>> {
  if (date > context.today) {
    if (!context.pro) {
      if (lockFuture) return {date, kind: 'locked'};
      throw new HttpsError('permission-denied', 'Pro is required to view future dates.');
    }
    const result = runCoreState({...context.input, operation: 'future', date, scheduledToday: context.state.today.lessonIds}) as unknown as {plan: StudyPlan};
    return {date, kind: 'future', state: context.state.snapshot.state, plan: result.plan};
  }
  if (date === context.today) {
    return {date, kind: 'today', state: context.state.snapshot.state, plan: context.state.today,
      remaining: context.state.remaining, originalDone: context.state.originalDone};
  }
  const saved = await tx.get(studyDays(db, uid).doc(studyDayId(examId, date)));
  if (!saved.exists) return {date, kind: 'unknown', state: 'unknown'};
  const reviewed = await completedOnDay(tx, db, uid, context.totals, date);
  const state = historicalView(context, saved, date, reviewed);
  return {date, kind: 'past', state: JSON.parse(String(saved.get('snapshotJson'))).state, plan: state.today,
    remaining: state.remaining, originalDone: state.originalDone};
}
export async function readStudyDay(auth: StudyAuth, data: unknown, deps: RoadmapDeps) {
  const {uid, body, now} = await studyCaller(auth,data,deps,'getRoadmapDay');
  if (!validDay(body.date)) throw bad('Bad day.');
  await loadTotals(deps.db,uid);
  return deps.db.runTransaction(async tx => {
    const context = await studyContext(tx,deps.db,uid,body.examId,now);
    const view = await dayView(tx, deps.db, uid, context, body.examId, body.date, false);
    if (view.kind === 'today') saveStudyState(tx,deps.db,uid,body.examId,context,context.state,now);
    return {examId:body.examId,serverNow:now,accessRecheckAt:context.access.recheckAt,proCovered:context.pro,...view};
  });
}
/** A Sunday-first week in one read. Free sees past and today as real data and future days as locked. */
export async function readStudyWeek(auth: StudyAuth, data: unknown, deps: RoadmapDeps) {
  const {uid, body, now} = await studyCaller(auth,data,deps,'getRoadmapWeek');
  if (!validDay(body.start) || new Date(body.start+'T00:00:00Z').getUTCDay() !== 0) throw bad('Send a Sunday week start.');
  await loadTotals(deps.db,uid);
  return deps.db.runTransaction(async tx => {
    const context = await studyContext(tx,deps.db,uid,body.examId,now);
    const days: Record<string, unknown>[] = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date(Date.parse(body.start + 'T00:00:00Z') + i * DAY_MS).toISOString().slice(0, 10);
      days.push(await dayView(tx, deps.db, uid, context, body.examId, date, true));
    }
    if (days.some(d => d.kind === 'today')) saveStudyState(tx,deps.db,uid,body.examId,context,context.state,now);
    return {examId:body.examId,serverNow:now,accessRecheckAt:context.access.recheckAt,proCovered:context.pro,start:body.start,days};
  });
}
export const advanceRoadmap=onCall({region:'asia-southeast1',enforceAppCheck:true},r=>advanceStudyRoadmap(r.auth,r.data,{db:getFirestore()}));
export const getRoadmapDay=onCall({region:'asia-southeast1',enforceAppCheck:true},r=>readStudyDay(r.auth,r.data,{db:getFirestore()}));
export const getRoadmapWeek=onCall({region:'asia-southeast1',enforceAppCheck:true},r=>readStudyWeek(r.auth,r.data,{db:getFirestore()}));
