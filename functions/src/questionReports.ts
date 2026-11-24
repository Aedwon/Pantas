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
/**
 * The size of the largest valid request, computed from the field rules: a message of 1000 units of
 * 3 bytes each, an account id of 128 control characters (a Firebase uid may hold any character, and
 * JSON writes each control character as a 6-byte escape), the longest ids, the largest version.
 * Every valid request fits, and a request over this is refused before any field is looked at.
 */
export const MAX_REQUEST_BYTES = Buffer.byteLength(JSON.stringify({
  reportId: 'r'.repeat(64), accountId: '\u0001'.repeat(128), questionId: 'q'.repeat(128),
  questionVersion: Number.MAX_SAFE_INTEGER, examId: 'e'.repeat(64), message: '\u20ac'.repeat(MAX_REPORT_MESSAGE),
  build: 'b'.repeat(40),
}));

/**
 * Every report is deleted this long after the server received it, by a Firestore TTL policy on
 * the report's expiry field (firestore.indexes.json). The published period is "within 90 days of
 * receipt"; the five days of room cover the delay before Firestore removes an expired document.
 * The server makes the time. A client cannot send one.
 */
export const REPORT_RETENTION_DAYS = 85;

const LONE_SURROGATE = /[\ud800-\udbff](?![\udc00-\udfff])|(?<![\ud800-\udbff])[\udc00-\udfff]/;
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
  // No control characters but tab, line feed and carriage return, and no lone surrogates: JSON would
  // spend 6 bytes on each, and none belongs in a student's note.
  if (/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/.test(d.message as string) || LONE_SURROGATE.test(d.message as string)) bad('message');
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
 * The counters keep the ids they accepted (at most 20 for the day, 3 per question), so a retry is
 * known without reading the report, and a valid request over a limit is refused early.
 *
 * Firestore cost. Rejected before any read (bad input, wrong account, signed out): 0 reads, 0
 * writes. Every other request first reads the deletion marker and the consent (2 reads), so a
 * closed account is always told so, even when it is over the burst limit: a burst-limited request
 * costs those 2 reads. Over the daily limit or a question's limit: 4 reads in all. A retry of an
 * accepted report: 5 reads, 0 writes. A new report: 5 reads (marker, consent, day, question,
 * report) and 3 writes (the report and both counters).
 */
export async function storeQuestionReport(request: Pick<CallableRequest, 'auth' | 'data'>, deps: Deps) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const uid = request.auth.uid;
  const report = validateQuestionReport(request.data);
  if (report.accountId !== uid) {
    throw new HttpsError('failed-precondition', 'This report belongs to another account.', {reason: 'wrong-account'});
  }
  const reportRef = deps.db.doc(`questionReports/${reportDocId(uid, report.reportId)}`);
  const questionRef = deps.db.doc(`users/${uid}/questionReportCounts/${questionCounterId(report.questionId)}`);
  const dayRef = deps.db.doc(`users/${uid}/server/questionReportDay`);
  const ids = (value: unknown): string[] => Array.isArray(value) ? value.filter((id): id is string => typeof id === 'string') : [];
  let burstChecked = false;
  await deps.db.runTransaction(async tx => {
    // First, before any answer: a closed account gets that answer and nothing else, whatever its
    // burst limit, quota or retries would have said.
    const [deletion, consent] = await tx.getAll(deps.db.doc(`accountDeletions/${uid}`),
      deps.db.doc(`users/${uid}/server/guardianConsent`));
    if (deletion.exists || consent.get('status') === 'withdrawn') throw accountClosed();
    // Then the per-instance burst limit, once however often the transaction retries.
    if (!burstChecked) {
      burstChecked = true;
      if (!(deps.limiter ?? limiter).allow(uid, (deps.now ?? Date.now)())) {
        throw new HttpsError('resource-exhausted', 'Too many reports. Try again later.');
      }
    }
    const now = (deps.now ?? Date.now)(), today = manilaDate(now);
    const day = await tx.get(dayRef);
    const sameDay = day.get('day') === today;
    const dayIds = sameDay ? ids(day.get('ids')) : [];
    const dayCount = sameDay && typeof day.get('count') === 'number' ? day.get('count') as number : 0;
    const question = await tx.get(questionRef);
    const questionIds = ids(question.get('ids'));
    const asked = typeof question.get('count') === 'number' ? question.get('count') as number : 0;
    // A report accepted before is answered before any quota is looked at, so a retry of one whose
    // document has expired is acknowledged even when today's quota is full.
    const known = dayIds.includes(report.reportId) || questionIds.includes(report.reportId);
    if (known) {
      const stored = await tx.get(reportRef);
      if (stored.exists) {
        const same = stored.get('questionId') === report.questionId && stored.get('message') === report.message &&
          stored.get('examId') === report.examId && stored.get('questionVersion') === report.questionVersion;
        if (!same) throw new HttpsError('already-exists', 'This report id was used for another report.', {reason: 'report-id-reused'});
      }
      // The document may be gone (the TTL or the sweep removed it): answered, never rewritten.
      return;
    }
    if (dayCount >= MAX_PER_DAY) refuse('daily-limit', 'Too many reports today. Try again tomorrow.');
    if (asked >= MAX_PER_QUESTION) refuse('question-limit', 'This question already has the most reports allowed.');
    const stored = await tx.get(reportRef);
    if (stored.exists) throw new HttpsError('already-exists', 'This report id was used for another report.', {reason: 'report-id-reused'});
    tx.set(reportRef, {
      accountId: uid, questionId: report.questionId, questionVersion: report.questionVersion,
      examId: report.examId, message: report.message, build: report.build, createdAt: Timestamp.fromMillis(now),
      expireAt: Timestamp.fromMillis(now + REPORT_RETENTION_DAYS * 86_400_000),
    });
    tx.set(questionRef, {count: asked + 1, ids: [...questionIds, report.reportId]});
    tx.set(dayRef, {day: today, count: dayCount + 1, ids: [...dayIds, report.reportId]});
  });
  return {ok: true, reportId: report.reportId};
}

export const sendQuestionReport = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('sendQuestionReport', (request: CallableRequest) => storeQuestionReport(request, {db: getFirestore()})));
