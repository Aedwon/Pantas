import assert from 'node:assert/strict';
import test from 'node:test';
import {MAX_DAYS, MAX_DAY_PAIRS, MAX_ID_BYTES, MAX_QUESTIONS, addSession, emptyTotals, fromDoc, prune, toDoc, viewOf} from '../lib/_answerTotals.js';
import {phDay} from '../lib/_phDate.js';

/** The full scan `build()` used before running totals existed, copied here as the reference. */
function legacy(sessions, topicOf) {
  const answers = sessions.flat();
  const scoped = answers.filter(answer => topicOf.has(answer.questionId));
  const scores = {};
  const perDay = new Map();
  for (const answer of scoped) {
    const score = (scores[topicOf.get(answer.questionId)] ??= {correct: 0, answered: 0});
    score.answered += 1;
    if (answer.correct) score.correct += 1;
    const day = phDay(answer.answeredAt);
    perDay.set(day, (perDay.get(day) ?? 0) + 1);
  }
  return {scores, seenQuestionIds: [...new Set(scoped.map(a => a.questionId))].sort(),
    answeredPerActiveDay: [...perDay.values()], anyAnswers: answers.length > 0, sessions: sessions.length};
}
const norm = view => ({...view, answeredPerActiveDay: [...view.answeredPerActiveDay].sort((a, b) => a - b)});
const viaTotals = (sessions, topicOf, roundTrip = true) => {
  let totals = emptyTotals();
  for (const session of sessions) {
    addSession(totals, session);
    prune(totals);
    if (roundTrip) totals = fromDoc(toDoc(totals));
  }
  return viewOf(totals, topicOf);
};
const same = (sessions, topicOf, label) => assert.deepEqual(norm(viaTotals(sessions, topicOf)), norm(legacy(sessions, topicOf)), label);

const T0 = Date.parse('2026-11-01T00:00:00+08:00');
const ans = (questionId, at, correct = true) => ({questionId, chosen: 'a', correct, answeredAt: at});
const topics = new Map([['a0', 'ta'], ['a1', 'ta'], ['a2', 'ta'], ['b0', 'tb'], ['b1', 'tb']]);

test('an account with no sessions has nothing', () => {
  same([], topics, 'empty');
  assert.equal(viewOf(emptyTotals(), topics).anyAnswers, false);
});

test('one session, several topics, right and wrong', () => {
  same([[ans('a0', T0), ans('a1', T0 + 1, false), ans('b0', T0 + 2)]], topics, 'single');
});

test('days split on the Philippine midnight, not UTC', () => {
  const lateUtc = Date.parse('2026-11-20T15:59:59Z');   // 23:59:59 in the Philippines
  same([[ans('a0', lateUtc), ans('a1', lateUtc + 1000), ans('b0', lateUtc + 2000)], [ans('a2', lateUtc + 3 * 3_600_000)]], topics, 'midnight');
  assert.deepEqual(norm(viaTotals([[ans('a0', lateUtc), ans('a1', lateUtc + 1000)]], topics)).answeredPerActiveDay, [1, 1]);
});

test('many days and sessions, repeated questions', () => {
  const sessions = [];
  for (let day = 0; day < 40; day += 1) {
    for (let s = 0; s < 1 + (day % 3); s += 1) {
      sessions.push(['a0', 'a1', 'a2', 'b0', 'b1'].slice(0, 1 + ((day + s) % 5)).map((id, i) => ans(id, T0 + day * 86_400_000 + s * 60_000 + i, (day + i) % 2 === 0)));
    }
  }
  same(sessions, topics, 'many');
});

test('answers outside the exam are ignored by scores and days but still make the account "answered"', () => {
  const sessions = [[ans('zz9', T0), ans('zz8', T0 + 1)]];
  same(sessions, topics, 'out of scope');
  const view = viaTotals(sessions, topics);
  assert.equal(view.anyAnswers, true);
  assert.deepEqual(view.scores, {});
  assert.deepEqual(view.answeredPerActiveDay, []);
});

test('a content change that removes or moves a question gives the same view as a fresh scan', () => {
  const sessions = [[ans('a0', T0), ans('a1', T0 + 1), ans('b0', T0 + 2)], [ans('a1', T0 + 86_400_000), ans('a2', T0 + 86_400_001, false)], [ans('b1', T0 + 3 * 86_400_000)]];
  const before = new Map(topics);
  const removed = new Map(topics); removed.delete('a1');
  const moved = new Map(topics); moved.set('a2', 'tb');
  const gone = new Map([['b0', 'tb']]);
  let totals = emptyTotals();
  for (const session of sessions) addSession(totals, session);
  totals = fromDoc(toDoc(totals));
  for (const [label, map] of [['before', before], ['removed', removed], ['moved', moved], ['almost all gone', gone], ['none', new Map()]]) {
    assert.deepEqual(norm(viewOf(totals, map)), norm(legacy(sessions, map)), label);
  }
  // A day whose only answers were for the removed question disappears from the day counts.
  assert.deepEqual(viewOf(totals, new Map([['b1', 'tb']])).answeredPerActiveDay, [1]);
});

test('a seeded random history matches a fresh scan under three content versions', () => {
  let seed = 12345;
  const rand = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
  const ids = Array.from({length: 60}, (_, i) => `q${i}`);
  const sessions = Array.from({length: 120}, () => Array.from({length: 1 + Math.floor(rand() * 20)}, () =>
    ans(ids[Math.floor(rand() * ids.length)], T0 + Math.floor(rand() * 90) * 86_400_000 + Math.floor(rand() * 86_400_000), rand() < 0.6)));
  const version = keep => new Map(ids.filter(() => rand() < keep).map((id, i) => [id, `t${i % 4}`]));
  for (const keep of [1, 0.7, 0.2]) same(sessions, version(keep), `keep ${keep}`);
});

test('the day window keeps the most recent days and reports what it dropped', () => {
  const totals = emptyTotals();
  for (let day = 0; day < MAX_DAYS + 50; day += 1) addSession(totals, [ans('a0', T0 + day * 86_400_000)]);
  prune(totals);
  assert.equal(totals.days.size, MAX_DAYS);
  assert.equal(totals.prunedDays, 50);
  assert.equal(totals.sessions, MAX_DAYS + 50);
  assert.equal([...totals.days.keys()].sort()[0], phDay(T0 + 50 * 86_400_000));
  assert.equal(viewOf(totals, topics).scores.ta.answered, MAX_DAYS + 50);
});

test('the question table is capped, and the stored document stays under 1 MiB in the worst case', () => {
  const T = Date.parse('2026-11-01T00:00:00+08:00');
  // Two hostile shapes: the most rows (short ids) and the longest ids (fewest rows).
  for (const idLength of [24, 128]) {
    const totals = emptyTotals();
    const id = n => `${String(n).padStart(6, '0')}-`.padEnd(idLength, 'x');
    for (let n = 0; n < 40; n += 1) addSession(totals, Array.from({length: 300}, (_, i) => ans(id(n * 300 + i), T + n * 86_400_000)));
    assert.ok(totals.questions.size <= MAX_QUESTIONS);
    assert.ok(totals.idBytes <= MAX_ID_BYTES);
    assert.equal(totals.answers, 12_000);   // every answer still counts toward "answered"
    // Fill the day pairs to their cap, using the highest indexes and widest counts.
    const indexes = [...totals.questions.values()].map(row => row.index).reverse();
    for (let day = 0; day < MAX_DAYS; day += 1) {
      const map = new Map();
      for (const index of indexes) { if (map.size >= MAX_DAY_PAIRS / MAX_DAYS) break; map.set(index, 99_999); }
      totals.days.set(phDay(T + day * 86_400_000), map);
    }
    prune(totals);
    const doc = toDoc(totals);
    const bytes = Object.values(doc).reduce((sum, value) => sum + (typeof value === 'string' ? Buffer.byteLength(value) : 16), 0);
    assert.ok(bytes < 1_000_000, `worst case is ${bytes} bytes`);
    console.log(`worst case, ${totals.questions.size} rows of ${idLength}-byte ids: ${bytes} bytes`);
  }
});

test('a realistic heavy history is a small fraction of the limit', () => {
  const totals = emptyTotals();
  for (let day = 0; day < MAX_DAYS; day += 1) {
    addSession(totals, Array.from({length: 100}, (_, i) => ans(`cse-pro-verbal-${(day * 7 + i) % 3200}`, T0 + day * 86_400_000 + i)));
  }
  prune(totals);
  assert.equal(totals.prunedDays, 0);
  const doc = toDoc(totals);
  const bytes = Object.values(doc).reduce((sum, value) => sum + (typeof value === 'string' ? Buffer.byteLength(value) : 16), 0);
  console.log(`400 days at 100 answers a day over 3200 questions: ${bytes} bytes`);
  assert.ok(bytes < 700_000);
});
