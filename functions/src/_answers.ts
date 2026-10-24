import {HttpsError} from 'firebase-functions/v2/https';
import {ID_PATTERN} from './content.js';

export const MAX_ANSWERS = 300;
export const MAX_ID_LENGTH = 128;
const MIN_TIME = Date.UTC(2020, 0, 1);
const DAY_MS = 86_400_000;

export type Answer = {questionId: string; chosen: string | null; correct: boolean; answeredAt?: number;
  responseMs?: number; questionVersion?: number};

const bad = (message: string) => new HttpsError('invalid-argument', message);

export function checkTime(value: unknown, now: number, name: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < MIN_TIME || value > now + DAY_MS) {
    throw bad(`${name} is not a valid time.`);
  }
  return Math.trunc(value);
}

/**
 * Validates and copies each answer, dropping unknown fields so nothing else is stored. An
 * attributed batch (exam and origin sent) may leave `answeredAt` out, because the app does not
 * store a per-answer time; it stays absent and is never replaced by the session's times. A sent
 * `answeredAt` is always validated. Legacy batches must still carry it.
 */
export function checkAnswers(value: unknown, now: number, attributed = false): Answer[] {
  if (!Array.isArray(value) || value.length < 1 || value.length > MAX_ANSWERS) {
    throw bad(`Send 1 to ${MAX_ANSWERS} answers.`);
  }
  return value.map((raw): Answer => {
    const row = raw as Record<string, unknown> | null;
    if (!row || typeof row !== 'object') throw bad('Each answer must be an object.');
    const {questionId, chosen, correct} = row;
    if (typeof questionId !== 'string' || !ID_PATTERN.test(questionId) || questionId.length > MAX_ID_LENGTH) throw bad('Bad question id.');
    if (chosen !== null && (typeof chosen !== 'string' || chosen.length > 64)) throw bad('Bad chosen option.');
    if (typeof correct !== 'boolean') throw bad('Correctness must be true or false.');
    if (row.responseMs !== undefined && (!Number.isSafeInteger(row.responseMs) || (row.responseMs as number) < 0 ||
        (row.responseMs as number) > DAY_MS)) throw bad('Bad answer time.');
    if (row.questionVersion !== undefined && (!Number.isSafeInteger(row.questionVersion) ||
        (row.questionVersion as number) < 1)) throw bad('Bad question version.');
    return {questionId, chosen: chosen as string | null, correct,
      ...(attributed && row.answeredAt === undefined ? {} : {answeredAt: checkTime(row.answeredAt, now, 'answeredAt')}),
      ...(row.responseMs === undefined ? {} : {responseMs: row.responseMs as number}),
      ...(row.questionVersion === undefined ? {} : {questionVersion: row.questionVersion as number})};
  });
}

export function checkDuration(value: unknown): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < 0 || value > DAY_MS) throw bad('Bad duration.');
  return Math.trunc(value);
}
