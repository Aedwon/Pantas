import {HttpsError} from 'firebase-functions/v2/https';

export const MAX_ANSWERS = 300;
export const MAX_ID_LENGTH = 128;
const MIN_TIME = Date.UTC(2020, 0, 1);
const DAY_MS = 86_400_000;

export type Answer = {questionId: string; chosen: string | null; correct: boolean; answeredAt: number};

const bad = (message: string) => new HttpsError('invalid-argument', message);

export function checkTime(value: unknown, now: number, name: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < MIN_TIME || value > now + DAY_MS) {
    throw bad(`${name} is not a valid time.`);
  }
  return Math.trunc(value);
}

/** Validates and copies each answer, dropping unknown fields so nothing else is stored. */
export function checkAnswers(value: unknown, now: number): Answer[] {
  if (!Array.isArray(value) || value.length < 1 || value.length > MAX_ANSWERS) {
    throw bad(`Send 1 to ${MAX_ANSWERS} answers.`);
  }
  return value.map((raw): Answer => {
    const row = raw as Record<string, unknown> | null;
    if (!row || typeof row !== 'object') throw bad('Each answer must be an object.');
    const {questionId, chosen, correct} = row;
    if (typeof questionId !== 'string' || questionId.length < 1 || questionId.length > MAX_ID_LENGTH) throw bad('Bad question id.');
    if (chosen !== null && (typeof chosen !== 'string' || chosen.length > 64)) throw bad('Bad chosen option.');
    if (typeof correct !== 'boolean') throw bad('Correctness must be true or false.');
    return {questionId, chosen: chosen as string | null, correct, answeredAt: checkTime(row.answeredAt, now, 'answeredAt')};
  });
}

export function checkDuration(value: unknown): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < 0 || value > DAY_MS) throw bad('Bad duration.');
  return Math.trunc(value);
}
