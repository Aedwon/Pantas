import type {Answer} from './_answers.js';

// Product choice awaiting the founder's confirmation. It is not shown to students as a figure.
export const STRICT_BREAK_MS = 60_000;

/**
 * The clock of a mock whose parts are timed one by one. `index` is the part running or waiting to start,
 * and `usedMs` holds one entry per closed part. A part that has closed is never reopened. When the last
 * part closes, `usedMs` is full, `startedAt` is null and `waitingSince` is the moment the paper ended.
 * `endedEarly` says whether the previous part was closed by the student.
 */
export type PartClock = {limitsMs: number[]; index: number; startedAt: number | null; waitingSince: number | null;
  endedEarly: boolean; usedMs: number[]};
export type ClockRow = {parts: PartClock; strict?: unknown; pausedAt?: unknown; pausedMs?: unknown};
export type Settled = {parts: PartClock; pausedAt: number | null; pausedMs: number; finishedAt: number | null};
export type PartsView = {index: number; limitsMs: number[]; remainingMs: number; waiting: boolean; endedEarly: boolean;
  startsInMs: number | null};
type PaperShape = {sections: {questions: {id: string}[]}[]};

const sum = (values: number[]) => values.reduce((total, value) => total + value, 0);
const between = (value: number, low: number, high: number) => Math.min(high, Math.max(low, value));
const isFinished = (parts: PartClock) => parts.usedMs.length === parts.limitsMs.length;

/** A strict clock has no pauses at all, whatever the row holds. */
function pauses(row: ClockRow): {pausedAt: number | null; pausedMs: number} {
  if (row.strict === true) return {pausedAt: null, pausedMs: 0};
  return {pausedAt: typeof row.pausedAt === 'number' ? row.pausedAt : null,
    pausedMs: typeof row.pausedMs === 'number' ? row.pausedMs : 0};
}

/** Part 0 running from `now`, with each limit taken from the minutes the student set. */
export function newPartClock(sectionMinutes: number[], now: number): PartClock {
  return {limitsMs: sectionMinutes.map(minutes => minutes * 60_000), index: 0, startedAt: now, waitingSince: null,
    endedEarly: false, usedMs: []};
}

/**
 * Brings a by-part clock up to `now`. Each part closes at its exact moment, never at `now`: a strict part
 * at `startedAt + limit`, a non-strict part at `startedAt + pausedMs + limit`, and a part that is paused
 * never closes. A strict part that waits starts at `waitingSince` plus the break; a non-strict one never
 * starts by itself. The result depends only on the row and the final `now`, so settling twice, or in two
 * steps, gives the same state. `finishedAt` is the moment the last part closed.
 */
export function settleParts(row: ClockRow, now: number): Settled {
  const strict = row.strict === true;
  const {limitsMs} = row.parts;
  const usedMs = [...row.parts.usedMs];
  let {index, startedAt, waitingSince, endedEarly} = row.parts;
  let {pausedAt, pausedMs} = pauses(row);
  const done = (finishedAt: number | null): Settled => ({
    parts: {limitsMs: [...limitsMs], index, startedAt, waitingSince, endedEarly, usedMs}, pausedAt, pausedMs, finishedAt});
  for (;;) {
    if (usedMs.length === limitsMs.length) return done(waitingSince ?? now);
    if (startedAt === null) {
      if (!strict || waitingSince === null || now < waitingSince + STRICT_BREAK_MS) return done(null);
      startedAt = waitingSince + STRICT_BREAK_MS;
      waitingSince = null;
      continue;
    }
    if (pausedAt !== null) return done(null);
    const closesAt = startedAt + pausedMs + limitsMs[index]!;
    if (now < closesAt) return done(null);
    usedMs.push(limitsMs[index]!);
    endedEarly = false;
    pausedMs = 0;
    waitingSince = closesAt;
    startedAt = null;
    if (index < limitsMs.length - 1) index += 1;
  }
}

/** True when settling moved the clock or the pause fields, so the row needs writing. */
export function clockChanged(row: ClockRow, settled: Settled): boolean {
  const before = row.parts, after = settled.parts, was = pauses(row);
  const same = (a: number[], b: number[]) => a.length === b.length && a.every((value, i) => value === b[i]);
  return was.pausedAt !== settled.pausedAt || was.pausedMs !== settled.pausedMs || before.index !== after.index ||
    before.startedAt !== after.startedAt || before.waitingSince !== after.waitingSince ||
    before.endedEarly !== after.endedEarly || !same(before.usedMs, after.usedMs) || !same(before.limitsMs, after.limitsMs);
}

/** Time used in the running part: pauses excluded, never below 0 or above the limit. Zero when none runs. */
export function usedInPart(row: ClockRow, now: number): number {
  const {parts} = row;
  if (parts.startedAt === null || isFinished(parts)) return 0;
  const {pausedAt, pausedMs} = pauses(row);
  const open = pausedAt === null ? 0 : Math.max(0, now - pausedAt);
  return between(now - parts.startedAt - pausedMs - open, 0, parts.limitsMs[parts.index]!);
}

export const usedTotalMs = (row: ClockRow, now: number): number => sum(row.parts.usedMs) + usedInPart(row, now);

/** The block the client reads, for a row already settled at `now`. */
export function partsView(row: ClockRow, now: number): PartsView {
  const {parts} = row;
  const limit = parts.limitsMs[parts.index]!;
  const finished = isFinished(parts);
  const waiting = !finished && parts.startedAt === null;
  const remainingMs = finished ? 0 : waiting ? limit : limit - usedInPart(row, now);
  const startsInMs = row.strict === true && waiting && parts.waitingSince !== null
    ? between(parts.waitingSince + STRICT_BREAK_MS - now, 0, STRICT_BREAK_MS) : null;
  return {index: parts.index, limitsMs: [...parts.limitsMs], remainingMs, waiting, endedEarly: parts.endedEarly, startsInMs};
}

/** What is left in the running part plus the limit of every later part. */
export const totalRemainingMs = (row: ClockRow, now: number): number =>
  partsView(row, now).remainingMs + sum(row.parts.limitsMs.slice(row.parts.index + 1));

/** Starts the waiting part. A part that is running is returned unchanged, so a repeat can never restart it. */
export function startPartNow(parts: PartClock, now: number): PartClock {
  if (parts.startedAt !== null || isFinished(parts)) return parts;
  return {...parts, startedAt: Math.max(now, parts.waitingSince ?? now), waitingSince: null};
}

/** Closes the running part at `now` as ended by the student, and the next part waits. Pauses are not used time. */
export function endPartNow(row: ClockRow, now: number): PartClock {
  const {parts} = row;
  const closedAt = Math.max(now, parts.startedAt ?? now);
  return {...parts, index: Math.min(parts.index + 1, parts.limitsMs.length - 1), startedAt: null, waitingSince: closedAt,
    endedEarly: true, usedMs: [...parts.usedMs, usedInPart(row, now)]};
}

/** Closes the running part at `now` for a submission. The index stays, and a waiting clock is returned as it is. */
export function submitParts(row: ClockRow, now: number): PartClock {
  const {parts} = row;
  if (parts.startedAt === null) return parts;
  return {...parts, startedAt: null, waitingSince: Math.max(now, parts.startedAt), usedMs: [...parts.usedMs, usedInPart(row, now)]};
}

/**
 * The answers to keep. Closed parts keep what is stored. The running part keeps what is stored, and each
 * sent answer replaces the stored one for the same question; a stored answer that was not sent stays.
 * Later parts keep nothing, and while a part waits nothing sent is taken. The result is in paper order.
 */
export function mergePartAnswers(stored: Answer[], sent: Answer[], paper: PaperShape, parts: PartClock): Answer[] {
  const partOf = new Map<string, number>();
  paper.sections.forEach((section, part) => section.questions.forEach(question => partOf.set(question.id, part)));
  const closed = parts.usedMs.length;
  const running = parts.startedAt === null || closed === parts.limitsMs.length ? -1 : parts.index;
  const kept = new Map<string, Answer>();
  for (const answer of stored) {
    const part = partOf.get(answer.questionId);
    if (part !== undefined && (part < closed || part === running)) kept.set(answer.questionId, answer);
  }
  for (const answer of sent) if (partOf.get(answer.questionId) === running) kept.set(answer.questionId, answer);
  return paper.sections.flatMap(section => section.questions.flatMap(question => kept.get(question.id) ?? []));
}
