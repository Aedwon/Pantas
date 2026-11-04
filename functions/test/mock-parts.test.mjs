import assert from 'node:assert/strict';
import test from 'node:test';
import {
  STRICT_BREAK_MS, endPartNow, mergePartAnswers, newPartClock, partsView, settleParts, startPartNow, submitParts,
  totalRemainingMs, usedInPart, usedTotalMs, clockChanged, clockNow,
} from '../lib/_mockParts.js';

const SEC = 1000;
const MIN = 60 * SEC;
const T0 = 1_800_000_000_000;
const BREAK = STRICT_BREAK_MS;

const rowOf = (minutes, {strict = false, now = T0, pausedAt = null, pausedMs = 0} = {}) =>
  ({parts: newPartClock(minutes, now), strict, pausedAt, pausedMs});
const withState = (row, settled) => ({...row, parts: settled.parts, pausedAt: settled.pausedAt, pausedMs: settled.pausedMs});
const settledRow = (row, now) => withState(row, settleParts(row, now));

test('the strict break is 60 seconds', () => {
  assert.equal(BREAK, 60_000);
});

test('a new clock runs part 0 from now, with limits from minutes', () => {
  assert.deepEqual(newPartClock([30, 20, 10], T0), {
    limitsMs: [30 * MIN, 20 * MIN, 10 * MIN], index: 0, startedAt: T0, waitingSince: null, endedEarly: false, usedMs: [],
  });
});

for (const strict of [true, false]) {
  const mode = strict ? 'strict' : 'non-strict';

  test(`${mode}: a running part with time left changes nothing`, () => {
    const row = rowOf([30, 20], {strict});
    for (const now of [T0 - 5 * SEC, T0, T0 + 29 * MIN, T0 + 30 * MIN - 1]) {
      const out = settleParts(row, now);
      assert.deepEqual(out, {parts: row.parts, pausedAt: null, pausedMs: 0, finishedAt: null});
      assert.equal(clockChanged(row, out), false);
    }
  });

  test(`${mode}: the part closes at its exact moment, and the next part waits from that moment`, () => {
    const row = rowOf([30, 20], {strict});
    for (const now of [T0 + 30 * MIN, T0 + 30 * MIN + 1, T0 + 30 * MIN + BREAK - 1]) {
      const out = settleParts(row, now);
      assert.equal(out.finishedAt, null);
      assert.deepEqual(out.parts, {
        limitsMs: [30 * MIN, 20 * MIN], index: 1, startedAt: null, waitingSince: T0 + 30 * MIN, endedEarly: false, usedMs: [30 * MIN],
      });
      assert.equal(clockChanged(row, out), true);
    }
  });

  test(`${mode}: the last part closing finishes the paper at that exact moment`, () => {
    const row = settledRow(rowOf([10, 5], {strict}), T0 + 10 * MIN);
    const start = strict ? T0 + 10 * MIN + BREAK : T0 + 12 * MIN;
    const begun = strict ? row : {...row, parts: startPartNow(row.parts, start)};
    const out = settleParts(begun, start + 5 * MIN + 7 * 3600 * SEC);
    assert.equal(out.finishedAt, start + 5 * MIN);
    assert.deepEqual(out.parts.usedMs, [10 * MIN, 5 * MIN]);
    assert.equal(out.parts.startedAt, null);
    assert.equal(out.pausedAt, null);
    assert.equal(out.pausedMs, 0);
    // A second settle of the finished state gives the same moment.
    assert.deepEqual(settleParts(withState(begun, out), start + 9 * 3600 * SEC), out);
    // One millisecond early it is still running.
    assert.equal(settleParts(begun, start + 5 * MIN - 1).finishedAt, null);
  });
}

test('non-strict: a part closes at startedAt + pausedMs + limit, and paused time never counts', () => {
  const row = rowOf([30, 20], {pausedMs: 3 * MIN});
  assert.equal(settleParts(row, T0 + 33 * MIN - 1).parts.index, 0);
  const out = settleParts(row, T0 + 33 * MIN);
  assert.equal(out.parts.index, 1);
  assert.equal(out.parts.waitingSince, T0 + 33 * MIN);
  assert.deepEqual(out.parts.usedMs, [30 * MIN]);
  // The pause fields belong to the part that closed.
  assert.equal(out.pausedAt, null);
  assert.equal(out.pausedMs, 0);
});

test('non-strict: a closed pause plus an open one still stops the count', () => {
  const row = rowOf([30, 20], {pausedMs: 3 * MIN, pausedAt: T0 + 10 * MIN});
  const out = settleParts(row, T0 + 40 * 24 * 3600 * SEC);
  assert.equal(out.finishedAt, null);
  assert.deepEqual(out.parts, row.parts);
  assert.equal(out.pausedAt, T0 + 10 * MIN);
  assert.equal(out.pausedMs, 3 * MIN);
  const view = partsView(withState(row, out), T0 + 40 * 24 * 3600 * SEC);
  assert.equal(view.remainingMs, 30 * MIN - 7 * MIN);
});

test('non-strict: a pause that spans the would-be deadline moves it by the whole pause', () => {
  // Limit 10 minutes. Paused at minute 5 and resumed at minute 100: 95 minutes of pause.
  const paused = {...rowOf([10, 10]), pausedAt: T0 + 5 * MIN};
  assert.equal(settleParts(paused, T0 + 50 * MIN).parts.index, 0);
  const resumed = {...paused, pausedAt: null, pausedMs: 95 * MIN};
  assert.equal(settleParts(resumed, T0 + 104 * MIN).parts.index, 0);
  assert.equal(settleParts(resumed, T0 + 105 * MIN - 1).parts.index, 0);
  const out = settleParts(resumed, T0 + 105 * MIN);
  assert.equal(out.parts.index, 1);
  assert.equal(out.parts.waitingSince, T0 + 105 * MIN);
  assert.deepEqual(out.parts.usedMs, [10 * MIN]);
});

test('non-strict: a waiting part never starts by itself, however long it waits', () => {
  const closed = settledRow(rowOf([10, 10, 10]), T0 + 10 * MIN);
  for (const days of [1, 30, 4000]) {
    const out = settleParts(closed, T0 + days * 86_400 * SEC);
    assert.deepEqual(out, {parts: closed.parts, pausedAt: null, pausedMs: 0, finishedAt: null});
    assert.equal(clockChanged(closed, out), false);
  }
});

test('strict: the next part starts at exactly waitingSince + the break', () => {
  const closed = settledRow(rowOf([10, 10], {strict: true}), T0 + 10 * MIN);
  const edge = T0 + 10 * MIN + BREAK;
  assert.equal(settleParts(closed, edge - 1).parts.startedAt, null);
  for (const now of [edge, edge + 1, edge + 5 * MIN]) {
    const out = settleParts(closed, now);
    assert.equal(out.parts.startedAt, edge);
    assert.equal(out.parts.waitingSince, null);
    assert.equal(out.parts.index, 1);
    assert.equal(out.finishedAt, null);
  }
});

test('strict: three parts, nobody calls for hours, every part closes at its exact moment', () => {
  const row = rowOf([20, 15, 10], {strict: true});
  const closes = [T0 + 20 * MIN, T0 + 20 * MIN + BREAK + 15 * MIN, T0 + 20 * MIN + BREAK + 15 * MIN + BREAK + 10 * MIN];
  const out = settleParts(row, T0 + 9 * 3600 * SEC);
  assert.equal(out.finishedAt, closes[2]);
  assert.deepEqual(out.parts.usedMs, [20 * MIN, 15 * MIN, 10 * MIN]);
  // Stopping partway: one millisecond before each moment, and on it.
  assert.deepEqual(settleParts(row, closes[0] - 1).parts.usedMs, []);
  const mid = settleParts(row, closes[0] + BREAK + 3 * MIN);
  assert.equal(mid.parts.index, 1);
  assert.equal(mid.parts.startedAt, closes[0] + BREAK);
  assert.deepEqual(mid.parts.usedMs, [20 * MIN]);
  const second = settleParts(row, closes[1]);
  assert.equal(second.parts.index, 2);
  assert.equal(second.parts.waitingSince, closes[1]);
  assert.deepEqual(second.parts.usedMs, [20 * MIN, 15 * MIN]);
  assert.equal(settleParts(row, closes[2] - 1).finishedAt, null);
  assert.equal(settleParts(row, closes[2]).finishedAt, closes[2]);
});

test('non-strict: a chain stops at the first wait, however late the call', () => {
  const row = rowOf([20, 15, 10]);
  const out = settleParts(row, T0 + 9 * 3600 * SEC);
  assert.equal(out.finishedAt, null);
  assert.equal(out.parts.index, 1);
  assert.equal(out.parts.startedAt, null);
  assert.equal(out.parts.waitingSince, T0 + 20 * MIN);
  assert.deepEqual(out.parts.usedMs, [20 * MIN]);
  assert.equal(out.parts.endedEarly, false);
});

test('a strict row ignores pausedAt and pausedMs entirely', () => {
  const clean = rowOf([10, 10], {strict: true});
  const odd = rowOf([10, 10], {strict: true, pausedAt: T0 + 2 * MIN, pausedMs: 7 * MIN});
  for (const now of [T0 + 5 * MIN, T0 + 10 * MIN, T0 + 10 * MIN + BREAK, T0 + 5 * 3600 * SEC]) {
    assert.deepEqual(settleParts(odd, now), settleParts(clean, now));
  }
  assert.equal(partsView(odd, T0 + 4 * MIN).remainingMs, 6 * MIN);
  assert.equal(usedTotalMs(odd, T0 + 4 * MIN), 4 * MIN);
});

test('closing a part by time sets endedEarly false even after an early end', () => {
  let row = rowOf([10, 10, 10]);
  row = {...row, parts: endPartNow(row, T0 + 2 * MIN)};
  assert.equal(row.parts.endedEarly, true);
  row = {...row, parts: startPartNow(row.parts, T0 + 3 * MIN)};
  assert.equal(row.parts.endedEarly, true);
  const out = settleParts(row, T0 + 13 * MIN);
  assert.equal(out.parts.endedEarly, false);
  assert.equal(out.parts.index, 2);
});

test('a clock reading before the part started changes nothing', () => {
  const row = rowOf([10, 10], {strict: true});
  assert.deepEqual(settleParts(row, T0 - 3 * 3600 * SEC), {parts: row.parts, pausedAt: null, pausedMs: 0, finishedAt: null});
  assert.equal(partsView(row, T0 - 3 * 3600 * SEC).remainingMs, 10 * MIN);
});

// ---- views ----

test('view: running part, remaining counts down, never below 0 and never above the limit', () => {
  const row = rowOf([30, 20]);
  assert.deepEqual(partsView(row, T0 + 12 * MIN), {
    index: 0, limitsMs: [30 * MIN, 20 * MIN], remainingMs: 18 * MIN, waiting: false, endedEarly: false, startsInMs: null,
  });
  assert.equal(partsView(row, T0 + 3 * 24 * 3600 * SEC).remainingMs, 0);
  assert.equal(partsView(row, T0 - 4 * MIN).remainingMs, 30 * MIN);
  // A non-strict paused part shows the time left when it was paused.
  const paused = {...row, pausedAt: T0 + 12 * MIN};
  assert.equal(partsView(paused, T0 + 50 * MIN).remainingMs, 18 * MIN);
});

test('view: waiting shows the full limit; only strict has a start time', () => {
  const plain = settledRow(rowOf([30, 20]), T0 + 30 * MIN);
  assert.deepEqual(partsView(plain, T0 + 40 * MIN), {
    index: 1, limitsMs: [30 * MIN, 20 * MIN], remainingMs: 20 * MIN, waiting: true, endedEarly: false, startsInMs: null,
  });
  const strict = settledRow(rowOf([30, 20], {strict: true}), T0 + 30 * MIN);
  const view = partsView(strict, T0 + 30 * MIN + 15 * SEC);
  assert.equal(view.waiting, true);
  assert.equal(view.remainingMs, 20 * MIN);
  assert.equal(view.startsInMs, BREAK - 15 * SEC);
  assert.equal(partsView(strict, T0 + 30 * MIN).startsInMs, BREAK);
  // Running strict has no start time.
  assert.equal(partsView(rowOf([30, 20], {strict: true}), T0 + MIN).startsInMs, null);
});

test('view: the top remaining time adds the limits of every later part', () => {
  const row = rowOf([30, 20, 10]);
  assert.equal(totalRemainingMs(row, T0 + 12 * MIN), 18 * MIN + 30 * MIN);
  assert.equal(totalRemainingMs(row, T0), 60 * MIN);
  const waiting = settledRow(row, T0 + 30 * MIN);
  assert.equal(totalRemainingMs(waiting, T0 + 31 * MIN), 20 * MIN + 10 * MIN);
  assert.equal(totalRemainingMs(row, T0 + 99 * 3600 * SEC), 30 * MIN);
});

test('used time: closed parts plus the running part, pauses excluded', () => {
  const row = {...rowOf([30, 20, 10]), parts: {...rowOf([30, 20, 10]).parts, index: 1, startedAt: T0 + 40 * MIN, usedMs: [25 * MIN]}, pausedMs: 2 * MIN};
  assert.equal(usedInPart(row, T0 + 50 * MIN), 8 * MIN);
  assert.equal(usedTotalMs(row, T0 + 50 * MIN), 33 * MIN);
  const open = {...row, pausedAt: T0 + 45 * MIN};
  assert.equal(usedInPart(open, T0 + 90 * MIN), 3 * MIN);
  // Never more than the part's limit, and nothing while waiting.
  assert.equal(usedInPart(row, T0 + 99 * 3600 * SEC), 20 * MIN);
  const waiting = settledRow(rowOf([30, 20]), T0 + 30 * MIN);
  assert.equal(usedInPart(waiting, T0 + 50 * MIN), 0);
  assert.equal(usedTotalMs(waiting, T0 + 50 * MIN), 30 * MIN);
});

// ---- starting and ending a part ----

test('startPartNow starts a waiting part at the later of now and the wait start', () => {
  const closed = settledRow(rowOf([10, 10]), T0 + 10 * MIN);
  const started = startPartNow(closed.parts, T0 + 25 * MIN);
  assert.equal(started.startedAt, T0 + 25 * MIN);
  assert.equal(started.waitingSince, null);
  assert.equal(started.index, 1);
  assert.equal(startPartNow(closed.parts, T0 + 9 * MIN).startedAt, T0 + 10 * MIN);
  // Starting a running part changes nothing.
  assert.deepEqual(startPartNow(started, T0 + 40 * MIN), started);
});

test('endPartNow closes the running part at now, early, excluding pauses', () => {
  const row = {...rowOf([30, 20, 10]), pausedMs: 4 * MIN};
  const out = endPartNow(row, T0 + 20 * MIN);
  assert.deepEqual(out, {limitsMs: [30 * MIN, 20 * MIN, 10 * MIN], index: 1, startedAt: null, waitingSince: T0 + 20 * MIN,
    endedEarly: true, usedMs: [16 * MIN]});
  // An open pause is closed first: its time is not used time.
  const paused = {...rowOf([30, 20, 10]), pausedMs: 4 * MIN, pausedAt: T0 + 14 * MIN};
  assert.deepEqual(endPartNow(paused, T0 + 3 * 3600 * SEC).usedMs, [10 * MIN]);
});

test('submitParts closes the running part where it is, without moving on', () => {
  const mid = {...rowOf([30, 20, 10]), pausedMs: MIN};
  const out = submitParts(mid, T0 + 11 * MIN);
  assert.deepEqual(out.usedMs, [10 * MIN]);
  assert.equal(out.startedAt, null);
  assert.equal(out.index, 0);
  assert.equal(out.waitingSince, T0 + 11 * MIN);
  const waiting = settledRow(rowOf([30, 20]), T0 + 30 * MIN);
  assert.deepEqual(submitParts(waiting, T0 + 31 * MIN), waiting.parts);
});

// ---- answers ----

const paper = {sections: [
  {questions: [{id: 'a1'}, {id: 'a2'}, {id: 'a3'}]},
  {questions: [{id: 'b1'}, {id: 'b2'}]},
  {questions: [{id: 'c1'}, {id: 'c2'}]},
]};
const ans = (questionId, chosen = 'x', correct = true, answeredAt = T0) => ({questionId, chosen, correct, answeredAt});
const clockAt = (index, running) => ({limitsMs: [MIN, MIN, MIN], index, startedAt: running ? T0 : null, waitingSince: running ? null : T0,
  endedEarly: false, usedMs: Array.from({length: index}, () => MIN)});

test('merge: the running part takes sent answers; a stored answer not resent stays', () => {
  const stored = [ans('a1', 'old'), ans('b1', 'old'), ans('b2', 'keep')];
  const out = mergePartAnswers(stored, [ans('b1', 'new', false)], paper, clockAt(1, true));
  assert.deepEqual(out, [ans('a1', 'old'), ans('b1', 'new', false), ans('b2', 'keep')]);
});

test('merge: closed parts keep stored answers whatever is sent, and a late answer is dropped', () => {
  const stored = [ans('a1', 'kept')];
  const out = mergePartAnswers(stored, [ans('a1', 'changed', false, T0 - 5 * MIN), ans('a2', 'late')], paper, clockAt(1, true));
  assert.deepEqual(out, [ans('a1', 'kept')]);
});

test('merge: later parts are dropped, with or without stored answers', () => {
  const out = mergePartAnswers([], [ans('a1'), ans('b1'), ans('c1')], paper, clockAt(1, true));
  assert.deepEqual(out, [ans('b1')]);
  const first = mergePartAnswers([ans('a1', 'k')], [ans('a2'), ans('b2'), ans('c2')], paper, clockAt(0, true));
  assert.deepEqual(first, [ans('a1', 'k'), ans('a2')]);
});

test('merge: while waiting nothing from the client is taken', () => {
  const stored = [ans('a1', 'kept'), ans('a3', 'kept')];
  const out = mergePartAnswers(stored, [ans('a1', 'no'), ans('a2'), ans('b1'), ans('c1')], paper, clockAt(1, false));
  assert.deepEqual(out, stored);
  assert.deepEqual(mergePartAnswers([], [ans('a1'), ans('b1')], paper, clockAt(1, false)), []);
});

test('merge: a sent blank in the running part replaces a stored answer', () => {
  const out = mergePartAnswers([ans('b1', 'x')], [{questionId: 'b1', chosen: null, correct: false, answeredAt: T0}], paper, clockAt(1, true));
  assert.deepEqual(out, [{questionId: 'b1', chosen: null, correct: false, answeredAt: T0}]);
});

test('merge: the result follows paper order, whatever order the answers arrive in', () => {
  const stored = [ans('b2', 's'), ans('a3', 's'), ans('a1', 's')];
  const out = mergePartAnswers(stored, [ans('b1', 'n')], paper, clockAt(1, true));
  assert.deepEqual(out.map(a => a.questionId), ['a1', 'a3', 'b1', 'b2']);
});

test('merge: an id off the paper is dropped, and stored answers of a part that has not opened are not carried', () => {
  const out = mergePartAnswers([ans('zz'), ans('c1')], [ans('yy'), ans('a1')], paper, clockAt(1, true));
  assert.deepEqual(out, []);
});

test('merge: a finished clock keeps every stored answer and takes none', () => {
  const finished = {...clockAt(2, true), index: 2, startedAt: null, waitingSince: T0, usedMs: [MIN, MIN, MIN]};
  const stored = [ans('a1'), ans('b2'), ans('c1')];
  assert.deepEqual(mergePartAnswers(stored, [ans('c2')], paper, finished), stored);
});

// ---- generated timelines ----

function rng(seed) {
  let s = seed >>> 0;
  return n => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return (s >>> 8) % n; };
}

test('property: settling twice, or in two steps, gives the same result as settling once', () => {
  let finishedRuns = 0, waitingRuns = 0, pausedRuns = 0;
  for (let seed = 1; seed <= 600; seed++) {
    const r = rng(seed * 7919);
    const strict = r(2) === 1;
    const minutes = Array.from({length: 2 + r(4)}, () => 1 + r(25));
    let row = {parts: newPartClock(minutes, T0), strict, pausedAt: null, pausedMs: 0};
    const limitTotal = row.parts.limitsMs.reduce((a, b) => a + b, 0);
    let t = T0;
    for (let step = 0; step < 30; step++) {
      t += r(3) === 0 ? 0 : r(45 * MIN);
      const once = settleParts(row, t);
      // Settling the settled row at the same moment changes nothing.
      assert.deepEqual(settleParts(withState(row, once), t), once, `seed ${seed} step ${step}: idempotent`);
      // Two steps through any earlier moment give the same state as one.
      const mid = t - r(1 + t - T0);
      const viaMid = settleParts(withState(row, settleParts(row, mid)), t);
      assert.deepEqual(viaMid, once, `seed ${seed} step ${step}: composes`);
      // Bounds on the settled state.
      const next = withState(row, once);
      const p = once.parts;
      assert.ok(p.usedMs.every((used, i) => used >= 0 && used <= p.limitsMs[i]));
      assert.ok(usedTotalMs(next, t) <= limitTotal);
      const view = partsView(next, t);
      assert.ok(view.remainingMs >= 0 && view.remainingMs <= p.limitsMs[p.index]);
      assert.ok(totalRemainingMs(next, t) <= limitTotal);
      if (once.finishedAt !== null) {
        finishedRuns++;
        assert.ok(once.finishedAt <= t);
        assert.equal(usedTotalMs(next, t), p.usedMs.reduce((a, b) => a + b, 0));
        break;
      }
      assert.equal(p.usedMs.length, p.index);
      if (view.waiting) waitingRuns++;
      if (once.pausedAt !== null) pausedRuns++;
      row = next;
      // The student does something at this moment.
      const running = p.startedAt !== null;
      const op = r(6);
      if (!running && op < 3) row = {...row, parts: startPartNow(p, t)};
      else if (!strict && running && op === 3 && row.pausedAt === null) row = {...row, pausedAt: t};
      else if (!strict && running && op === 4 && row.pausedAt !== null) row = {...row, pausedAt: null, pausedMs: row.pausedMs + Math.max(0, t - row.pausedAt)};
      else if (!strict && running && op === 5 && p.index < p.limitsMs.length - 1) row = {...row, parts: endPartNow(row, t), pausedAt: null, pausedMs: 0};
    }
  }
  assert.ok(finishedRuns > 50 && waitingRuns > 200 && pausedRuns > 50, `coverage ${finishedRuns} ${waitingRuns} ${pausedRuns}`);
});

test('property: a strict paper nobody touches follows the exact timetable', () => {
  for (let seed = 1; seed <= 300; seed++) {
    const r = rng(seed * 104729);
    const minutes = Array.from({length: 2 + r(5)}, () => 1 + r(40));
    const row = rowOf(minutes, {strict: true});
    const limits = row.parts.limitsMs;
    const starts = [], ends = [];
    let at = T0;
    for (const limit of limits) { starts.push(at); at += limit; ends.push(at); at += BREAK; }
    const now = T0 + r(minutes.reduce((a, b) => a + b, 0) * MIN + limits.length * BREAK + 20 * MIN);
    const out = settleParts(row, now);
    const closed = ends.filter(end => end <= now).length;
    if (closed === limits.length) {
      assert.equal(out.finishedAt, ends.at(-1));
      assert.deepEqual(out.parts.usedMs, limits);
      continue;
    }
    assert.equal(out.finishedAt, null);
    assert.deepEqual(out.parts.usedMs, limits.slice(0, closed));
    assert.equal(out.parts.index, closed);
    if (now >= ends[closed - 1] + BREAK || closed === 0) {
      assert.equal(out.parts.startedAt, starts[closed]);
    } else {
      assert.equal(out.parts.startedAt, null);
      assert.equal(out.parts.waitingSince, ends[closed - 1]);
    }
  }
});

test('clockNow is never before the last event on the clock', () => {
  const running = rowOf([30, 20], {now: T0});
  assert.equal(clockNow(running, T0 + 5 * SEC), T0 + 5 * SEC, 'a request after every event keeps its own time');
  assert.equal(clockNow(running, T0 - 5 * SEC), T0, 'a request older than the part start is lifted to it');
  const waiting = withState(rowOf([30, 20]), settleParts(rowOf([30, 20]), T0 + 30 * MIN));
  assert.equal(waiting.parts.startedAt, null);
  assert.equal(clockNow(waiting, T0), T0 + 30 * MIN, 'a request older than the wait is lifted to it');
  assert.equal(clockNow(waiting, T0 + 31 * MIN), T0 + 31 * MIN);
  const paused = rowOf([30, 20], {pausedAt: T0 + 10 * MIN, pausedMs: 0});
  assert.equal(clockNow(paused, T0 + MIN), T0 + 10 * MIN, 'a non-strict pause is an event too');
  assert.equal(clockNow(paused, T0 + 11 * MIN), T0 + 11 * MIN);
});

test('clockNow ignores a pause on a strict row and a pause that is not a number', () => {
  assert.equal(clockNow(rowOf([30, 20], {strict: true, pausedAt: T0 + 10 * MIN}), T0 + MIN), T0 + MIN);
  assert.equal(clockNow({...rowOf([30, 20]), pausedAt: 'x'}, T0 + MIN), T0 + MIN);
  assert.equal(clockNow({...rowOf([30, 20]), pausedAt: undefined}, T0 + MIN), T0 + MIN);
});

test('clockNow of a finished clock is lifted to the moment the paper ended', () => {
  const row = rowOf([10, 5]);
  const settled = withState(row, settleParts(row, T0 + 10 * MIN));
  const begun = {...settled, parts: startPartNow(settled.parts, T0 + 12 * MIN)};
  const done = withState(begun, settleParts(begun, T0 + 17 * MIN));
  assert.equal(done.parts.waitingSince, T0 + 17 * MIN);
  assert.equal(clockNow(done, T0 + MIN), T0 + 17 * MIN);
});
