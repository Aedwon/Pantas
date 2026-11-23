import {getFirestore, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {enforceAppCheck} from './_appCheck.js';
import {RateLimiter} from './clientTelemetry.js';
import {ID_PATTERN} from './content.js';
import {manilaDate} from './betaReward.js';
import {timed} from './_timed.js';

/**
 * A student's report on one question. Stored in `questionReports`, which no client can read or
 * write (firestore.rules). The counts that enforce the limits sit in the account's server-only
 * `server/questionReportCounts` document, so the limits need no query and the counts leave with
 * the account.
 *
 * The limits equal the app's: 3 reports per question for the life of the account, and 20 per
 * account per day. The day is the Manila calendar day, because the server cannot know a device's.
 */
export const MAX_REPORT_MESSAGE = 1000;
export const MAX_PER_QUESTION = 3;
export const MAX_PER_DAY = 20;

const REPORT_ID = /^[A-Za-z0-9_-]{16,64}$/;
const BUILD = /^[A-Za-z0-9._-]{1,40}$/;
const KEYS = ['reportId', 'questionId', 'questionVersion', 'examId', 'message', 'build'];

export interface QuestionReportInput {
  reportId: string;
  questionId: string;
  /** Null only for a report queued on a phone before the app sent versions. */
  questionVersion: number | null;
  /** Null only for a report queued on a phone before the app sent exams. */
  examId: string | null;
  message: string;
  build: string;
}

const bad = (what: string): never => {
  throw new HttpsError('invalid-argument', `Invalid report: ${what}.`);
};

/** Throws `invalid-argument` unless `data` is a valid report. Returns a clean copy. */
export function validateQuestionReport(data: unknown): QuestionReportInput {
  if (typeof data !== 'object' || data === null || Array.isArray(data)) return bad('the request must be an object');
  const d = data as Record<string, unknown>;
  if (Object.keys(d).some(key => !KEYS.includes(key))) bad('unknown field');
  if (typeof d.reportId !== 'string' || !REPORT_ID.test(d.reportId)) bad('reportId');
  if (typeof d.questionId !== 'string' || d.questionId.length > 128 || !ID_PATTERN.test(d.questionId)) bad('questionId');
  if (d.questionVersion !== undefined && (!Number.isSafeInteger(d.questionVersion) || (d.questionVersion as number) < 1)) {
    bad('questionVersion');
  }
  if (d.examId !== undefined && (typeof d.examId !== 'string' || d.examId.length > 64 || !ID_PATTERN.test(d.examId))) bad('examId');
  const message = typeof d.message === 'string' ? d.message.trim() : '';
  if (message.length < 1 || message.length > MAX_REPORT_MESSAGE) bad('message');
  if (typeof d.build !== 'string' || !BUILD.test(d.build)) bad('build');
  return {
    reportId: d.reportId as string,
    questionId: d.questionId as string,
    questionVersion: (d.questionVersion as number | undefined) ?? null,
    examId: (d.examId as string | undefined) ?? null,
    message,
    build: d.build as string,
  };
}

const refuse = (reason: 'question-limit' | 'daily-limit', message: string): never => {
  throw new HttpsError('resource-exhausted', message, {reason});
};

type Counts = {perQuestion?: Record<string, number>; day?: string; dayCount?: number};
type Deps = {db: Firestore; now?: () => number; limiter?: RateLimiter};
const limiter = new RateLimiter(30);

/**
 * Stores one report. A retry with the same report id changes nothing and succeeds, so the app can
 * send until it hears back. Cost of a new report: 2 reads (the report, then the counts) and 2
 * writes (the report and the counts). A retry costs 1 read.
 */
export async function storeQuestionReport(request: Pick<CallableRequest, 'auth' | 'data'>, deps: Deps) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const uid = request.auth.uid;
  const report = validateQuestionReport(request.data);
  if (!(deps.limiter ?? limiter).allow(uid, (deps.now ?? Date.now)())) {
    throw new HttpsError('resource-exhausted', 'Too many reports. Try again later.');
  }
  const reportRef = deps.db.doc(`questionReports/${uid}_${report.reportId}`);
  const countsRef = deps.db.doc(`users/${uid}/server/questionReportCounts`);
  await deps.db.runTransaction(async tx => {
    if ((await tx.get(reportRef)).exists) return;
    const counts = ((await tx.get(countsRef)).data() ?? {}) as Counts;
    const now = (deps.now ?? Date.now)(), today = manilaDate(now);
    const perQuestion = {...counts.perQuestion};
    if ((perQuestion[report.questionId] ?? 0) >= MAX_PER_QUESTION) {
      refuse('question-limit', 'This question already has the most reports allowed.');
    }
    const dayCount = counts.day === today ? counts.dayCount ?? 0 : 0;
    if (dayCount >= MAX_PER_DAY) refuse('daily-limit', 'Too many reports today. Try again tomorrow.');
    perQuestion[report.questionId] = (perQuestion[report.questionId] ?? 0) + 1;
    tx.set(reportRef, {
      accountId: uid, questionId: report.questionId, questionVersion: report.questionVersion,
      examId: report.examId, message: report.message, build: report.build, createdAt: Timestamp.fromMillis(now),
    });
    tx.set(countsRef, {perQuestion, day: today, dayCount: dayCount + 1});
  });
  return {ok: true, reportId: report.reportId};
}

export const sendQuestionReport = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('sendQuestionReport', (request: CallableRequest) => storeQuestionReport(request, {db: getFirestore()})));
