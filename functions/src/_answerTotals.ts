import type {Firestore, Transaction} from 'firebase-admin/firestore';
import {phDay} from './_phDate.js';
import type {Answer} from './_answers.js';

/**
 * Running totals of a student's stored answers, so a roadmap rebuild reads one document instead of
 * every session. Server-only, at `users/{uid}/server/answerTotals`, written in the same transaction
 * that stores a session, so a replayed session never counts twice.
 *
 * It keeps exactly what the roadmap derives from the answers: per question, how many were answered
 * and how many correct; per Philippine day, how many of each question. Counts stay per question
 * (never pre-summed by topic or day) because the roadmap only counts questions the exam's current
 * content still has, and content changes.
 *
 * Both tables are stored as JSON text. The ids come from the app and are not checked against
 * content, so as map keys an odd id could fail the write, and thousands of map fields would hit
 * Firestore's index entry limit. A string field has neither problem.
 *
 * Version 2 also keeps, per question, its actual first completion time and which of the last 14
 * Philippine days it was completed on (a bitmask relative to one shared anchor day), so the roadmap can
 * judge today, the current week and a recent past day from this one document. Completion is the
 * session's actual finish time for an attributed session, and the real answer time for a legacy batch.
 * An attributed session counts all its answers on its actual start day, as the app's own per-day count
 * does; a legacy batch counts each answer on its own answer day. A time that was never stored is never
 * replaced by another one. A day older than the mask is read from the stored sessions instead.
 *
 * Bounds keep the document under 1 MiB however a client behaves (the real bank is about 3,200
 * questions; one student never sees more than that):
 * - MAX_QUESTIONS and MAX_ID_BYTES (serialized, escaped UTF-8 bytes) cap the question table.
 *   Ids beyond that are still counted in `answers` but get no row. A student of the real bank is
 *   nowhere near either.
 * - MAX_DAYS and MAX_DAY_PAIRS cap the day table; the oldest days are dropped first. The roadmap
 *   uses the day counts only for a median of answers per active day, which 400 recent active days
 *   (more than a year of exam prep) give to the same figure for any realistic student.
 */
export const MAX_QUESTIONS = 6000;
export const MAX_ID_BYTES = 150_000;
export const MAX_DAYS = 400;
export const MAX_DAY_PAIRS = 40_000;
export const MASK_DAYS = 14;
const MASK_ALL = (1 << MASK_DAYS) - 1;
const DAY_MS = 86_400_000;

export type Totals = {
  sessions: number; answers: number; prunedDays: number; idBytes: number;
  /** Insertion order is the row index that the day table refers to. */
  questions: Map<string, TotalsRow>;
  days: Map<string, Map<number, number>>;
  /** Philippine day that bit 0 of every row's mask stands for: the latest completion day ever seen. */
  anchorDay: string | null;
};
export type TotalsRow = {index: number; answered: number; correct: number;
  /** Earliest actual completion time of this question, in ms. */
  firstCompletedAt: number | null;
  /** Bit k is set when it was completed on `anchorDay` minus k days, for k below MASK_DAYS. */
  mask: number;
  /** Last three outcomes with a leading 1 bit; zero means no history. */
  recent: number;
  /** Latest wrong choice letter, or empty when correct or unrecognized. */
  lw: string};
/** What a session says about itself. Only an attributed session has it; a legacy batch does not. */
export type SessionTimes = {startedAt: number; finishedAt: number};

/** What the roadmap needs from the answers, for the questions the exam currently has. */
export type AnswerView = {
  history: {id: string; answered: number; recent: boolean[]; lastWrongChoiceId: string | null}[];
  scores: Record<string, {correct: number; answered: number}>;
  seenQuestionIds: string[];
  answeredPerActiveDay: number[];
  /** Any stored answer at all, even for questions the exam no longer has. */
  anyAnswers: boolean;
  sessions: number;
};

export const emptyTotals = (): Totals => ({sessions: 0, answers: 0, prunedDays: 0, idBytes: 0, questions: new Map(), days: new Map(), anchorDay: null});

const dayNumber = (day: string): number => Date.parse(`${day}T00:00:00Z`) / DAY_MS;

/** Records a completion on `phDay(at)`. The anchor only moves forward; an older day is kept while it fits. */
function markCompleted(totals: Totals, row: TotalsRow, at: number): void {
  if (row.firstCompletedAt === null || at < row.firstCompletedAt) row.firstCompletedAt = at;
  const day = phDay(at);
  if (totals.anchorDay === null) totals.anchorDay = day;
  const ahead = dayNumber(day) - dayNumber(totals.anchorDay);
  if (ahead > 0) {
    for (const each of totals.questions.values()) each.mask = ahead >= MASK_DAYS ? 0 : (each.mask << ahead) & MASK_ALL;
    totals.anchorDay = day;
  }
  const offset = dayNumber(totals.anchorDay) - dayNumber(day);
  if (offset < MASK_DAYS) row.mask |= 1 << offset;
}

/**
 * Counts one session's answers. Call `prune` after the last one. Pass `session` for an attributed
 * session; leave it out for a legacy batch, which uses each answer's own time.
 */
export function addSession(totals: Totals, answers: Answer[], session?: SessionTimes): void {
  totals.sessions += 1;
  for (const answer of answers) {
    totals.answers += 1;
    let row = totals.questions.get(answer.questionId);
    if (!row) {
      const bytes = Buffer.byteLength(JSON.stringify(answer.questionId));
      if (totals.questions.size >= MAX_QUESTIONS || totals.idBytes + bytes > MAX_ID_BYTES) continue;
      row = {index: totals.questions.size, answered: 0, correct: 0, firstCompletedAt: null, mask: 0, recent: 0, lw: ''};
      totals.questions.set(answer.questionId, row);
      totals.idBytes += bytes;
    }
    // Live history follows ingest order; a late retry lands last.
    row.recent = row.recent < 8 ? ((row.recent || 1) << 1) | Number(answer.correct) :
      8 | ((row.recent << 1) & 7) | Number(answer.correct);
    const prefix = `${answer.questionId}_`;
    const letter = answer.chosen?.startsWith(prefix) ? answer.chosen.slice(prefix.length) : '';
    row.lw = !answer.correct && /^[a-f]$/.test(letter) ? letter : '';
    row.answered += 1;
    if (answer.correct) row.correct += 1;
    // A time that was never stored makes no count and no completion; one is never invented for it.
    const countedAt = session ? session.startedAt : answer.answeredAt;
    const completedAt = session ? session.finishedAt : answer.answeredAt;
    if (countedAt !== undefined) {
      const day = phDay(countedAt);
      let counts = totals.days.get(day);
      if (!counts) totals.days.set(day, counts = new Map());
      counts.set(row.index, (counts.get(row.index) ?? 0) + 1);
    }
    if (completedAt !== undefined) markCompleted(totals, row, completedAt);
  }
}

/**
 * The questions completed on a Philippine day. `covered` is false only when that day is older than
 * the mask keeps; the caller then reads the stored sessions. A day after the anchor is covered and empty.
 */
export function completedOn(totals: Totals, day: string): {covered: boolean; ids: Set<string>} {
  const ids = new Set<string>();
  if (totals.anchorDay === null || dayNumber(day) > dayNumber(totals.anchorDay)) return {covered: true, ids};
  const offset = dayNumber(totals.anchorDay) - dayNumber(day);
  if (offset >= MASK_DAYS) return {covered: false, ids};
  for (const [id, row] of totals.questions) if (row.mask & (1 << offset)) ids.add(id);
  return {covered: true, ids};
}

/** The questions whose actual first completion is before `endMs`. */
export function firstCompletedBefore(totals: Totals, endMs: number): Set<string> {
  const ids = new Set<string>();
  for (const [id, row] of totals.questions) if (row.firstCompletedAt !== null && row.firstCompletedAt < endMs) ids.add(id);
  return ids;
}

/** Drops the oldest days beyond the bounds. */
export function prune(totals: Totals): void {
  let pairs = 0;
  for (const counts of totals.days.values()) pairs += counts.size;
  if (totals.days.size <= MAX_DAYS && pairs <= MAX_DAY_PAIRS) return;
  for (const day of [...totals.days.keys()].sort()) {
    if (totals.days.size <= MAX_DAYS && pairs <= MAX_DAY_PAIRS) break;
    pairs -= totals.days.get(day)!.size;
    totals.days.delete(day);
    totals.prunedDays += 1;
  }
}

/** The roadmap's answer inputs, counting only questions in `topicOf` (question id to topic id). */
export function viewOf(totals: Totals, topicOf: Map<string, string>): AnswerView {
  const scores: AnswerView['scores'] = {};
  const history: AnswerView['history'] = [];
  const seen: string[] = [];
  const scopedByIndex: boolean[] = [];
  for (const [id, row] of totals.questions) {
    const topic = topicOf.get(id);
    scopedByIndex[row.index] = topic !== undefined;
    if (topic === undefined) continue;
    seen.push(id);
    const recent: boolean[] = [];
    for (let bits = row.recent; bits > 1; bits >>= 1) recent.unshift((bits & 1) === 1);
    if (row.answered > 0) history.push({id, answered: row.answered, recent,
      lastWrongChoiceId: row.lw ? `${id}_${row.lw}` : null});
    const score = (scores[topic] ??= {correct: 0, answered: 0});
    score.answered += row.answered;
    score.correct += row.correct;
  }
  const perDay: number[] = [];
  for (const counts of totals.days.values()) {
    let sum = 0;
    for (const [index, count] of counts) if (scopedByIndex[index]) sum += count;
    if (sum > 0) perDay.push(sum);
  }
  return {history, scores, seenQuestionIds: seen.sort(), answeredPerActiveDay: perDay, anyAnswers: totals.answers > 0, sessions: totals.sessions};
}

export function toDoc(totals: Totals): Record<string, unknown> {
  return {
    version: 3, sessions: totals.sessions, answers: totals.answers, prunedDays: totals.prunedDays, anchorDay: totals.anchorDay,
    questionsJson: JSON.stringify([...totals.questions].map(([id, row]) => [id, row.answered, row.correct, row.firstCompletedAt, row.mask, row.recent, row.lw])),
    daysJson: JSON.stringify([...totals.days].sort(([a], [b]) => (a < b ? -1 : 1)).map(([day, counts]) => [day, [...counts]])),
  };
}

/** A stored document written before version 3 has no recent history and is rebuilt from the sessions. */
export const needsBackfill = (data: Record<string, unknown> | undefined): boolean => data?.version !== 3;

export function fromDoc(data: Record<string, unknown> | undefined): Totals {
  const totals = emptyTotals();
  totals.sessions = Number(data?.sessions ?? 0);
  totals.answers = Number(data?.answers ?? 0);
  totals.prunedDays = Number(data?.prunedDays ?? 0);
  totals.anchorDay = typeof data?.anchorDay === 'string' ? data.anchorDay : null;
  for (const [id, answered, correct, firstCompletedAt, mask, recent, lw] of JSON.parse(String(data?.questionsJson ?? '[]')) as
      [string, number, number, number | null | undefined, number | undefined, number | undefined, string | undefined][]) {
    totals.questions.set(id, {index: totals.questions.size, answered, correct, firstCompletedAt: firstCompletedAt ?? null, mask: mask ?? 0, recent: recent ?? 0, lw: lw ?? ''});
    totals.idBytes += Buffer.byteLength(JSON.stringify(id));
  }
  for (const [day, counts] of JSON.parse(String(data?.daysJson ?? '[]')) as [string, [number, number][]][]) {
    totals.days.set(day, new Map(counts));
  }
  return totals;
}

export const totalsRef = (db: Firestore, uid: string) => db.doc(`users/${uid}/server/answerTotals`);

/** The times an attributed stored session reports about itself; a legacy one reports none. */
export function sessionTimesOf(row: {get(field: string): unknown}): SessionTimes | undefined {
  if (typeof row.get('examId') !== 'string' || typeof row.get('origin') !== 'string') return undefined;
  const startedAt = Number(row.get('startedAt')), finishedAt = Number(row.get('finishedAt'));
  return Number.isFinite(startedAt) && Number.isFinite(finishedAt) ? {startedAt, finishedAt} : undefined;
}

/**
 * Builds the totals from the stored sessions, for an account with no totals document or one from
 * before version 3. Each stored session is counted once, exactly as its own ingest counted it.
 */
export async function backfill(tx: Transaction, db: Firestore, uid: string): Promise<Totals> {
  const totals = emptyTotals();
  const rows = (await tx.get(db.collection(`users/${uid}/server/answers/items`).select('answers', 'examId', 'origin', 'startedAt', 'finishedAt'))).docs;
  rows.sort((a, b) => Number(a.get('finishedAt') ?? 0) - Number(b.get('finishedAt') ?? 0));
  for (const doc of rows) addSession(totals, doc.get('answers') as Answer[], sessionTimesOf(doc));
  prune(totals);
  return totals;
}

/** The totals in this transaction: the stored document, or one rebuilt from the sessions when it is older. */
export async function totalsIn(tx: Transaction, db: Firestore, uid: string,
  snapshot: FirebaseFirestore.DocumentSnapshot): Promise<Totals> {
  return snapshot.exists && !needsBackfill(snapshot.data()) ? fromDoc(snapshot.data()) : backfill(tx, db, uid);
}

/** One document read. A missing or older document is rebuilt once from the stored sessions and saved. */
export async function loadTotals(db: Firestore, uid: string): Promise<Totals> {
  const snapshot = await totalsRef(db, uid).get();
  if (snapshot.exists && !needsBackfill(snapshot.data())) return fromDoc(snapshot.data());
  return db.runTransaction(async (tx) => {
    const again = await tx.get(totalsRef(db, uid));
    if (again.exists && !needsBackfill(again.data())) return fromDoc(again.data());
    const totals = await backfill(tx, db, uid);
    tx.set(totalsRef(db, uid), toDoc(totals));
    return totals;
  });
}
