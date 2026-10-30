import {enforceAppCheck} from './_appCheck.js';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {core} from './_core.js';
import {allowAtMost} from './_limits.js';
import {fromDoc, totalsRef, viewOf} from './_answerTotals.js';
import type {Answer} from './_answers.js';
import {ID_PATTERN} from './content.js';
import {loadStudyContent, loadGapTags} from './_examContent.js';
import {mockCoverage} from './mockAccess.js';
import {phDay, phStamp} from './_phDate.js';
import {examCatalog} from './revenuecatPasses.js';
import type {ExamSettings} from './roadmap.js';
import {assertStudyOwner} from './studyObservations.js';

type Auth = {uid: string; token?: object} | undefined;
type Deps = {db: Firestore; now?: () => number; allow?: (uid: string, key: string) => Promise<boolean>};
const MAX_REVIEW_READS = 300;

/** One session, with current exam coverage. No session collection query or totals backfill. */
export async function readSessionDiagnosis(auth: Auth, data: unknown, deps: Deps) {
  if (!auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
  if (!data || typeof data !== 'object' || Array.isArray(data)) throw new HttpsError('invalid-argument', 'Send an object.');
  const body = data as Record<string, unknown>;
  assertStudyOwner(auth.uid, body);
  const {examId, sessionId} = body;
  if (typeof examId !== 'string' || !examCatalog.some(e => e.id === examId)) throw new HttpsError('invalid-argument', 'Unknown exam.');
  if (typeof sessionId !== 'string' || sessionId.length > 128 || !ID_PATTERN.test(sessionId)) throw new HttpsError('invalid-argument', 'Bad session id.');
  if (!await (deps.allow ?? ((uid, key) => allowAtMost(uid, key, 600, 3_600_000)))(auth.uid, 'getSessionDiagnosis')) {
    throw new HttpsError('resource-exhausted', 'Too many attempts. Try again later.');
  }
  const {db} = deps, uid = auth.uid, now = (deps.now ?? Date.now)();
  return db.runTransaction(async tx => {
    const session = await tx.get(db.doc(`users/${uid}/server/answers/items/${sessionId}`));
    if (!session.exists) return {status: 'pending' as const};
    if (session.get('examId') !== examId) throw new HttpsError('failed-precondition', 'This session belongs to another exam.');
    const [totalDoc, reads, settings, catalog, access] = await Promise.all([
      tx.get(totalsRef(db, uid)), tx.get(db.collection(`users/${uid}/server/lessonReads/items`)),
      tx.get(db.doc(`users/${uid}/server/settings`)), loadStudyContent(db, examId, tx), mockCoverage(tx, db, uid, now),
    ]);
    if (!settings.exists || settings.get('examId') !== examId) throw new HttpsError('failed-precondition', 'Your exam changed. Open this screen again.');
    const gapTags = await loadGapTags(db, now);
    const config = settings.data() as ExamSettings;
    const topics = catalog.topics.filter(t => !config.excludedTopicIds?.includes(t.id));
    const topicIds = new Set(topics.map(t => t.id));
    const lessons = catalog.lessons.filter(l => topicIds.has(l.topicId) && !config.excludedLessonIds?.includes(l.id));
    const lessonIds = new Set(lessons.map(l => l.id));
    const questions = catalog.questions.filter(q => topicIds.has(q.topicId) && (q.lessonId === null || lessonIds.has(q.lessonId)));
    const questionOf = new Map(questions.map(q => [q.id, q]));
    const links = new Map(lessons.map(l => [l.id, l.prerequisites.filter(p => lessonIds.has(p.lesson))]));
    const tags = Object.fromEntries(Object.entries(gapTags).filter(([, lesson]) => lessonIds.has(lesson)));
    const answers = session.get('answers') as Answer[];
    const involved = new Set<string>();
    const includeLesson = (id: string): void => {
      if (involved.has(id) || !lessonIds.has(id)) return;
      involved.add(id);
      for (const link of links.get(id) ?? []) if (link.strength === 'required') includeLesson(link.lesson);
    };
    for (const answer of answers) {
      const lesson = questionOf.get(answer.questionId)?.lessonId;
      if (!lesson) continue;
      includeLesson(lesson);
      if (!answer.correct && answer.chosen && tags[answer.chosen]) includeLesson(tags[answer.chosen]);
    }
    const reviewIds = questions.filter(q => q.lessonId !== null && involved.has(q.lessonId)).map(q => q.id);
    if (reviewIds.length > MAX_REVIEW_READS) throw new HttpsError('resource-exhausted', 'This session covers too many questions to diagnose.');
    const reviewDocs = reviewIds.length ? await tx.getAll(...reviewIds.map(id => db.doc(`users/${uid}/server/reviews/items/${encodeURIComponent(id)}`))) : [];
    const states = reviewDocs.filter(d => d.exists).map(d => JSON.parse(String(d.get('stateJson'))));
    const recallRows = states.length ? JSON.parse(core().dueReviews(JSON.stringify({now, states}))) as {id: string; retrievability: number}[] : [];
    const pro = access.coversExam(examId), notes: Record<string, string> = {};
    if (pro) {
      const misses = answers.filter(a => !a.correct && a.chosen && questionOf.has(a.questionId));
      const setIds = [...new Set(misses.map(a => questionOf.get(a.questionId)!.setId))];
      const documents = setIds.length ? await tx.getAll(...setIds.map(id => db.doc('contentPro/' + id))) : [];
      const bySet = new Map(documents.filter(d => d.exists).map(d => [d.id, JSON.parse(String(d.get('payload'))) as Record<string, (string | null)[]>]));
      for (const answer of misses) {
        const chosen = answer.chosen!, prefix = answer.questionId + '_';
        const letter = chosen.startsWith(prefix) ? chosen.slice(prefix.length) : '';
        if (!/^[a-f]$/.test(letter)) continue;
        const note = bySet.get(questionOf.get(answer.questionId)!.setId)?.[answer.questionId]?.[letter.charCodeAt(0) - 97];
        if (typeof note === 'string') notes[chosen] = note;
      }
    }
    // Read totals as stored. The ingest/roadmap migration owns the one-time backfill.
    const view = viewOf(fromDoc(totalDoc.data()), new Map(questions.map(q => [q.id, q.topicId])));
    const readAt = new Map(reads.docs.map(d => [String(d.get('lessonId')), Number(d.get('readAt'))]));
    const inputs = {
      today: phDay(now), examId, examDate: config.examDate, studyDays: config.studyDays, treatTodayAsStudyDay: false,
      topics: topics.map((t, authoredIndex) => ({...t, authoredIndex})),
      lessons: lessons.map(l => ({...l, readAt: readAt.has(l.id) ? phStamp(readAt.get(l.id)!) : null})), questions,
      lessonLinks: Object.fromEntries(links), history: view.history,
      recall: Object.fromEntries(recallRows.map(r => [r.id, r.retrievability])), gapTags: tags,
      seenQuestionIds: view.seenQuestionIds, dueReviews: [], scores: view.scores, answeredPerActiveDay: view.answeredPerActiveDay,
      mock: {examHasMock: false, proIsActive: pro, lastSubmittedAt: null}, assessmentCompleted: true, contentRevision: catalog.revision,
    };
    const diagnosis = JSON.parse(core().sessionDiagnosis(JSON.stringify({inputs, session: {sessionId, answers},
      ...(pro ? {notes} : {}), includeDetail: pro}))) as {tracedCount: number; traced?: unknown[]; withinLesson?: unknown[]};
    // Always construct Free from a whitelist, even if a future codec returns detail.
    if (!pro) return {status: 'ok' as const, tier: 'free' as const, tracedCount: diagnosis.tracedCount};
    return {status: 'ok' as const, tier: 'pro' as const, tracedCount: diagnosis.tracedCount,
      traced: diagnosis.traced, withinLesson: diagnosis.withinLesson};
  });
}
export const getSessionDiagnosis = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  request => readSessionDiagnosis(request.auth, request.data, {db: getFirestore()}));
