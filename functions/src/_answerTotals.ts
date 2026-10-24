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
 * Bounds keep the document under 1 MiB however a client behaves (the real bank is about 3,200
 * questions; one student never sees more than that):
 * - MAX_QUESTIONS and MAX_ID_BYTES cap the question table; ids beyond that are still counted in
 *   `answers` but get no row. A student of the real bank is nowhere near either.
 * - MAX_DAYS and MAX_DAY_PAIRS cap the day table; the oldest days are dropped first. The roadmap
 *   uses the day counts only for a median of answers per active day, which 400 recent active days
 *   (more than a year of exam prep) give to the same figure for any realistic student.
 */
export const MAX_QUESTIONS = 6000;
export const MAX_ID_BYTES = 150_000;
export const MAX_DAYS = 400;
export const MAX_DAY_PAIRS = 40_000;

export type Totals = {
  sessions: number; answers: number; prunedDays: number; idBytes: number;
  /** Insertion order is the row index that the day table refers to. */
  questions: Map<string, {index: number; answered: number; correct: number}>;
  days: Map<string, Map<number, number>>;
};

/** What the roadmap needs from the answers, for the questions the exam currently has. */
export type AnswerView = {
  scores: Record<string, {correct: number; answered: number}>;
  seenQuestionIds: string[];
  answeredPerActiveDay: number[];
  /** Any stored answer at all, even for questions the exam no longer has. */
  anyAnswers: boolean;
  sessions: number;
};

export const emptyTotals = (): Totals => ({sessions: 0, answers: 0, prunedDays: 0, idBytes: 0, questions: new Map(), days: new Map()});

/** Counts one session's answers. Call `prune` after the last one. */
export function addSession(totals: Totals, answers: Answer[]): void {
  totals.sessions += 1;
  for (const answer of answers) {
    totals.answers += 1;
    let row = totals.questions.get(answer.questionId);
    if (!row) {
      const bytes = Buffer.byteLength(answer.questionId);
      if (totals.questions.size >= MAX_QUESTIONS || totals.idBytes + bytes > MAX_ID_BYTES) continue;
      row = {index: totals.questions.size, answered: 0, correct: 0};
      totals.questions.set(answer.questionId, row);
      totals.idBytes += bytes;
    }
    row.answered += 1;
    if (answer.correct) row.correct += 1;
    // An answer with no stored time makes no day count; a day is never invented for it.
    if (answer.answeredAt === undefined) continue;
    const day = phDay(answer.answeredAt);
    let counts = totals.days.get(day);
    if (!counts) totals.days.set(day, counts = new Map());
    counts.set(row.index, (counts.get(row.index) ?? 0) + 1);
  }
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
  const seen: string[] = [];
  const scopedByIndex: boolean[] = [];
  for (const [id, row] of totals.questions) {
    const topic = topicOf.get(id);
    scopedByIndex[row.index] = topic !== undefined;
    if (topic === undefined) continue;
    seen.push(id);
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
  return {scores, seenQuestionIds: seen.sort(), answeredPerActiveDay: perDay, anyAnswers: totals.answers > 0, sessions: totals.sessions};
}

export function toDoc(totals: Totals): Record<string, unknown> {
  return {
    version: 1, sessions: totals.sessions, answers: totals.answers, prunedDays: totals.prunedDays,
    questionsJson: JSON.stringify([...totals.questions].map(([id, row]) => [id, row.answered, row.correct])),
    daysJson: JSON.stringify([...totals.days].sort(([a], [b]) => (a < b ? -1 : 1)).map(([day, counts]) => [day, [...counts]])),
  };
}

export function fromDoc(data: Record<string, unknown> | undefined): Totals {
  const totals = emptyTotals();
  totals.sessions = Number(data?.sessions ?? 0);
  totals.answers = Number(data?.answers ?? 0);
  totals.prunedDays = Number(data?.prunedDays ?? 0);
  for (const [id, answered, correct] of JSON.parse(String(data?.questionsJson ?? '[]')) as [string, number, number][]) {
    totals.questions.set(id, {index: totals.questions.size, answered, correct});
    totals.idBytes += Buffer.byteLength(id);
  }
  for (const [day, counts] of JSON.parse(String(data?.daysJson ?? '[]')) as [string, [number, number][]][]) {
    totals.days.set(day, new Map(counts));
  }
  return totals;
}

export const totalsRef = (db: Firestore, uid: string) => db.doc(`users/${uid}/server/answerTotals`);

/** Builds the totals from the stored sessions, for accounts that predate this document. */
export async function backfill(tx: Transaction, db: Firestore, uid: string): Promise<Totals> {
  const totals = emptyTotals();
  for (const doc of (await tx.get(db.collection(`users/${uid}/server/answers/items`).select('answers'))).docs) {
    addSession(totals, doc.get('answers') as Answer[]);
  }
  prune(totals);
  return totals;
}

/** One document read. A missing document is built once from the stored sessions and saved. */
export async function loadTotals(db: Firestore, uid: string): Promise<Totals> {
  const snapshot = await totalsRef(db, uid).get();
  if (snapshot.exists) return fromDoc(snapshot.data());
  return db.runTransaction(async (tx) => {
    const again = await tx.get(totalsRef(db, uid));
    if (again.exists) return fromDoc(again.data());
    const totals = await backfill(tx, db, uid);
    tx.set(totalsRef(db, uid), toDoc(totals));
    return totals;
  });
}
