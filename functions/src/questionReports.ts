import {getFirestore, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {accountClosed} from './_accountAccess.js';
import {enforceAppCheck} from './_appCheck.js';
import {RateLimiter} from './clientTelemetry.js';
import {ID_PATTERN} from './content.js';
import {manilaDate} from './betaReward.js';
import {timed} from './_timed.js';

/**
 * A student's report on one question. Stored in `questionReports`, which no client can read or
 * write (firestore.rules). The counts that enforce the limits are small documents in the account's
 * own tree (one per question, one for the day), so they need no query, cannot grow one document
 * without bound, and leave with the account.
 *
 * The limits equal the app's: 3 reports per question for the life of the account, and 20 per
 * account per day. The day is the Manila calendar day, because the server cannot know a device's.
 *
 * Order of work, so a rejected request costs no Firestore quota: sign-in, input checks, the
 * account the report was made under, the per-instance burst limit, and only then the transaction.
 * The account-closed check runs inside that transaction, so a report cannot commit after deletion
 * cleanup has started. It does not use the shared `onAccountCall` wrapper, which reads two
 * documents before any input check.
 */
export const MAX_REPORT_MESSAGE = 1000;
export const MAX_PER_QUESTION = 3;
export const MAX_PER_DAY = 20;
export const MAX_REQUEST_BYTES = 4096;

const REPORT_ID = /^[A-Za-z0-9_-]{16,64}$/;
const BUILD = /^[A-Za-z0-9._-]{1,40}$/;
const KEYS = ['reportId', 'accountId', 'questionId', 'questionVersion', 'examId', 'message', 'build'];

export interface QuestionReportInput {
  reportId: string;
  /** The account the app made the report under. It must be the signed-in account. */
  accountId: string;
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
  const names = Object.keys(d);
  if (names.length > KEYS.length || names.some(key => !KEYS.includes(key))) bad('unknown field');
  if (Buffer.byteLength(JSON.stringify(d)) > MAX_REQUEST_BYTES) bad('request too large');
  if (typeof d.reportId !== 'string' || !REPORT_ID.test(d.reportId)) bad('reportId');
  if (typeof d.accountId !== 'string' || d.accountId.length < 1 || d.accountId.length > 128) bad('accountId');
  if (typeof d.questionId !== 'string' || d.questionId.length > 128 || !ID_PATTERN.test(d.questionId)) bad('questionId');
  if (d.questionVersion !== undefined && (!Number.isSafeInteger(d.questionVersion) || (d.questionVersion as number) < 1)) {
    bad('questionVersion');
  }
  if (d.examId !== undefined && (typeof d.examId !== 'string' || d.examId.length > 64 || !ID_PATTERN.test(d.examId))) bad('examId');
  // The raw length is checked first: trimming must not let padding hide the size.
  if (typeof d.message !== 'string' || d.message.length > MAX_REPORT_MESSAGE) bad('message');
  const message = (d.message as string).trim();
  if (message.length < 1) bad('message');
  if (typeof d.build !== 'string' || !BUILD.test(d.build)) bad('build');
  return {
    reportId: d.reportId as string,
    accountId: d.accountId as string,
    questionId: d.questionId as string,
    questionVersion: (d.questionVersion as number | undefined) ?? null,
    examId: (d.examId as string | undefined) ?? null,
    message,
    build: d.build as string,
  };
}

/**
 * The stored key: the uid encoded without `.`, a dot, then the report id, which has no dot. Two
 * different (uid, id) pairs can never give the same key, whatever characters a custom uid holds.
 */
export const reportDocId = (uid: string, reportId: string): string =>
  `${Buffer.from(uid).toString('base64url')}.${reportId}`;

/** A counter document id for one question id: encoded, so no id can name an inherited property. */
export const questionCounterId = (questionId: string): string => `q${Buffer.from(questionId).toString('base64url')}`;

const refuse = (reason: 'question-limit' | 'daily-limit', message: string): never => {
  throw new HttpsError('resource-exhausted', message, {reason});
};

type Deps = {db: Firestore; now?: () => number; limiter?: RateLimiter};
const limiter = new RateLimiter(30);

/**
 * Stores one report. A retry with the same report id and the same content changes nothing and
 * succeeds, so the app can send until it hears back; the same id with other content is refused.
 *
 * Firestore cost. A rejected request (bad input, wrong account, signed out, over the burst
 * limit): 0 reads, 0 writes. A retry of a stored report: 3 reads, 0 writes. A new report: 5 reads
 * (deletion marker, consent, the report, the question counter, the day counter) and 3 writes (the
 * report and both counters). A report over a limit: 5 reads, 0 writes.
 */
export async function storeQuestionReport(request: Pick<CallableRequest, 'auth' | 'data'>, deps: Deps) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const uid = request.auth.uid;
  const report = validateQuestionReport(request.data);
  if (report.accountId !== uid) {
    throw new HttpsError('failed-precondition', 'This report belongs to another account.', {reason: 'wrong-account'});
  }
  if (!(deps.limiter ?? limiter).allow(uid, (deps.now ?? Date.now)())) {
    throw new HttpsError('resource-exhausted', 'Too many reports. Try again later.');
  }
  const reportRef = deps.db.doc(`questionReports/${reportDocId(uid, report.reportId)}`);
  const questionRef = deps.db.doc(`users/${uid}/questionReportCounts/${questionCounterId(report.questionId)}`);
  const dayRef = deps.db.doc(`users/${uid}/server/questionReportDay`);
  await deps.db.runTransaction(async tx => {
    const [deletion, consent] = await tx.getAll(deps.db.doc(`accountDeletions/${uid}`),
      deps.db.doc(`users/${uid}/server/guardianConsent`));
    if (deletion.exists || consent.get('status') === 'withdrawn') throw accountClosed();
    const stored = await tx.get(reportRef);
    if (stored.exists) {
      const same = stored.get('questionId') === report.questionId && stored.get('message') === report.message &&
        stored.get('examId') === report.examId && stored.get('questionVersion') === report.questionVersion;
      if (!same) throw new HttpsError('already-exists', 'This report id was used for another report.', {reason: 'report-id-reused'});
      return;
    }
    const [question, day] = await tx.getAll(questionRef, dayRef);
    const now = (deps.now ?? Date.now)(), today = manilaDate(now);
    const asked = typeof question.get('count') === 'number' ? question.get('count') as number : 0;
    if (asked >= MAX_PER_QUESTION) refuse('question-limit', 'This question already has the most reports allowed.');
    const dayCount = day.get('day') === today && typeof day.get('count') === 'number' ? day.get('count') as number : 0;
    if (dayCount >= MAX_PER_DAY) refuse('daily-limit', 'Too many reports today. Try again tomorrow.');
    tx.set(reportRef, {
      accountId: uid, questionId: report.questionId, questionVersion: report.questionVersion,
      examId: report.examId, message: report.message, build: report.build, createdAt: Timestamp.fromMillis(now),
    });
    tx.set(questionRef, {count: asked + 1});
    tx.set(dayRef, {day: today, count: dayCount + 1});
  });
  return {ok: true, reportId: report.reportId};
}

export const sendQuestionReport = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('sendQuestionReport', (request: CallableRequest) => storeQuestionReport(request, {db: getFirestore()})));
