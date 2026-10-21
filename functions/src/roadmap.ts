import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {core} from './_core.js';
import {loadExamContent} from './_examContent.js';
import {phDay, phStamp} from './_phDate.js';
import {hasLiveProClaim} from './_pro.js';
import {examCatalog} from './revenuecatPasses.js';
import {loadTotals, viewOf, type AnswerView} from './_answerTotals.js';
import {dueReviewInputs} from './serverReviews.js';

/**
 * Where the exam date and study days live on the server. The app keeps them in its own settings, so
 * it sends them here whenever they change. Only the server reads this document.
 */
export type ExamSettings = {
  examId: string;
  examDate: null | {precision: 'day'; day: string} | {precision: 'month'; year: number; month: number};
  studyDays: number[];
  assessmentCompleted?: boolean;
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
  return {examId, examDate, studyDays: [...new Set(days)].sort((a, b) => a - b),
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
  return {roadmap, pro, today};
}

/** Stores the exam date, study days and the rest of the plan's settings, then rebuilds the roadmap. */
export async function saveExamSettings(auth: Auth, data: unknown, deps: RoadmapDeps): Promise<{stored: true}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  const settings = checkSettings(data);
  const now = (deps.now ?? Date.now)();
  if (!await (deps.allow ?? allowDefault)(auth.uid, 'saveExamSettings')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  await settingsRef(deps.db, auth.uid).set({...settings, updatedAt: now});
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
  request => serveRoadmap(request.auth, request.data, {db: getFirestore()}));
