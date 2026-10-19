import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {beginMock, recordMock, readMock, changeMock, FREE_MOCK_WINDOW_MS} from '../lib/mock.js';
import {blueprintItem, questionSetItems, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const DAY = 86400000;
const MIN = 60000;
const NOW = Date.parse('2026-11-20T10:00:00+08:00');
const named = (uid, claims = {}) => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, ...claims}});
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const pro = uid => named(uid, {pro: true, proUntil: NOW + 60 * DAY});
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const d = (at = NOW) => ({db, now: () => at, allow: async () => true});
const EXAM = 'exam_cse_pro';
const answer = (questionId, correct, at = NOW) => ({questionId, chosen: 'a', correct, answeredAt: at});

const set = (topic, letter) => questionSetItems({
  meta: {subject: 's', topic, exams: ['cse-pro']},
  questions: Array.from({length: 10}, (_, i) => ({id: `${letter}${i}`, stem: 'x', choices: [{text: 'a', correct: true}, {text: 'b'}]})),
}, `mp/${topic}/u.yaml`).item;
const blueprint = blueprintItem({
  exam: EXAM, name: 'Practice paper', durationMinutes: 60, sectionalTiming: 'none',
  sections: [{id: 's1', name: 'Part one', questionCount: 6, suggestedMinutes: 60, topicIds: ['topic_cse_pro_ta', 'topic_cse_pro_tb'],
    topicWeights: {topic_cse_pro_ta: 0.5, topic_cse_pro_tb: 0.5}}],
});
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const items = uid => db.collection(`users/${uid}/server/mocks/items`).get();

test('seed content', async () => {
  await writeContent(db, [set('ta', 'a'), set('tb', 'b'), blueprint], [], {});
  clearExamContentCache();
});

test('startMock refuses anonymous and signed-out callers, unknown exams and exams with no blueprint', async () => {
  assert.equal(await code(beginMock(anon('p-anon'), {examId: EXAM}, d())), 'permission-denied');
  assert.equal(await code(beginMock(undefined, {examId: EXAM}, d())), 'unauthenticated');
  assert.equal(await code(beginMock(named('p-bad'), {examId: 'exam_nope'}, d())), 'invalid-argument');
  assert.equal(await code(beginMock(named('p-bad'), {}, d())), 'invalid-argument');
  assert.equal(await code(beginMock(named('p-bad'), {examId: 'exam_upcat'}, d())), 'failed-precondition');
});

test('the server assembles the paper from content and pins it in the mock record', async () => {
  const uid = 'p-pin';
  await reset(uid);
  const first = await beginMock(named(uid), {examId: EXAM}, d());
  assert.equal(first.resumed, false);
  assert.equal(first.limitMs, 60 * MIN);
  assert.equal(first.remainingMs, 60 * MIN);
  const ids = first.paper.sections.flatMap(s => s.questions.map(q => q.id));
  assert.equal(ids.length, 6);
  assert.equal(new Set(ids).size, 6);
  assert.ok(first.paper.sections[0].questions.every(q => /^qs-/.test(q.setId) && /^[ab]\d$/.test(q.id)));
  assert.equal(ids.filter(id => id.startsWith('a')).length, 3);
  const stored = (await db.doc(`users/${uid}/server/mocks/items/${first.mockId}`).get()).data();
  assert.deepEqual(stored.paper, first.paper);
  // A later start, even much later and from another call, returns the same paper and does not make a record.
  const again = await beginMock(named(uid), {examId: EXAM}, d(NOW + 3 * DAY));
  assert.equal(again.resumed, true);
  assert.equal(again.mockId, first.mockId);
  assert.deepEqual(again.paper, first.paper);
  assert.equal((await items(uid)).size, 1);
});

test('a non-strict discard clears the saved answers and keeps the same paper', async () => {
  const uid = 'p-discard';
  await reset(uid);
  const first = await beginMock(named(uid), {examId: EXAM}, d());
  const [q] = first.paper.sections[0].questions;
  await changeMock(named(uid), {mockId: first.mockId, action: 'save', answers: [answer(q.id, true)]}, d(NOW + MIN));
  assert.equal((await readMock(named(uid), {}, d(NOW + 2 * MIN))).answers.length, 1);
  const out = await changeMock(named(uid), {mockId: first.mockId, action: 'discard'}, d(NOW + 3 * MIN));
  assert.equal(out.answers.length, 0);
  const restart = await beginMock(named(uid), {examId: EXAM}, d(NOW + 4 * MIN));
  assert.equal(restart.mockId, first.mockId);
  assert.deepEqual(restart.paper, first.paper);
  assert.equal(restart.answers.length, 0);
  assert.equal((await readMock(named(uid), {}, d(NOW + 5 * MIN))).remainingMs, 58 * MIN);  // the discard at minute 3 restarted the clock
});

test('Free allowance counts only at submission, then the next mock opens 30 days later', async () => {
  const uid = 'p-free';
  await reset(uid);
  const first = await beginMock(named(uid), {examId: EXAM}, d());
  // Started but not submitted, 40 days on: it is still the open mock, no new allowance used.
  assert.equal((await beginMock(named(uid), {examId: EXAM}, d(NOW + 40 * DAY))).mockId, first.mockId);
  const submitAt = NOW + 41 * DAY;
  const done = await recordMock(named(uid), {mockId: first.mockId, answers: [answer('a0', true)], durationMs: 5 * MIN}, d(submitAt));
  assert.equal(done.status, 'submitted');
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(submitAt + 29 * DAY))), 'failed-precondition');
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(submitAt + FREE_MOCK_WINDOW_MS - 1))), 'failed-precondition');
  const next = await beginMock(named(uid), {examId: EXAM}, d(submitAt + FREE_MOCK_WINDOW_MS));
  assert.notEqual(next.mockId, first.mockId);
  assert.equal(next.resumed, false);
});

test('a second paper avoids the questions of the last submitted paper when the bank allows', async () => {
  const uid = 'p-recent';
  await reset(uid);
  const first = await beginMock(pro(uid), {examId: EXAM}, d());
  await recordMock(pro(uid), {mockId: first.mockId, answers: [answer('a0', true)], durationMs: MIN}, d(NOW + MIN));
  const second = await beginMock(pro(uid), {examId: EXAM}, d(NOW + 2 * MIN));
  const firstIds = new Set(first.paper.sections.flatMap(s => s.questions.map(q => q.id)));
  assert.ok(second.paper.sections.flatMap(s => s.questions).every(q => !firstIds.has(q.id)));
});

test('Pro is unlimited and an expired Pro claim is Free', async () => {
  const uid = 'p-pro';
  await reset(uid);
  for (let i = 0; i < 3; i++) {
    const out = await beginMock(pro(uid), {examId: EXAM}, d(NOW + i * MIN));
    await recordMock(pro(uid), {mockId: out.mockId, answers: [answer('a0', true)], durationMs: MIN}, d(NOW + i * MIN + 1));
  }
  assert.equal((await items(uid)).size, 3);
  assert.equal(await code(beginMock(named(uid, {pro: true, proUntil: NOW}), {examId: EXAM}, d(NOW + 10 * MIN))), 'failed-precondition');
});

test('strict mode: pause and discard are refused', async () => {
  const uid = 'p-strict-pause';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM, strict: true}, d());
  assert.equal(out.strict, true);
  for (const action of ['pause', 'resume', 'discard']) {
    assert.equal(await code(changeMock(named(uid), {mockId: out.mockId, action}, d(NOW + MIN))), 'failed-precondition', action);
  }
});

test('non-strict mode: pauses are recorded and move the clock; it is never ended by the server', async () => {
  const uid = 'p-pause';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM}, d());
  await changeMock(named(uid), {mockId: out.mockId, action: 'pause'}, d(NOW + 10 * MIN));
  assert.equal((await readMock(named(uid), {}, d(NOW + 30 * MIN))).remainingMs, 50 * MIN);
  await changeMock(named(uid), {mockId: out.mockId, action: 'resume'}, d(NOW + 40 * MIN));
  assert.equal((await readMock(named(uid), {}, d(NOW + 45 * MIN))).remainingMs, 45 * MIN);
  const late = await readMock(named(uid), {}, d(NOW + 5 * DAY));
  assert.equal(late.open, true);
  assert.equal(late.remainingMs, 0);
  assert.equal((await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).get('status'), 'started');
});

test('strict mode: time that ran out is ended and scored on the next contact, and it counts', async () => {
  const uid = 'p-timeout';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM, strict: true}, d());
  const [q1, q2] = out.paper.sections[0].questions;
  await changeMock(named(uid), {mockId: out.mockId, action: 'save', answers: [answer(q1.id, true), answer(q2.id, false)]}, d(NOW + 5 * MIN));
  const before = await readMock(named(uid), {}, d(NOW + 59 * MIN));
  assert.equal(before.open, true);
  assert.equal(before.remainingMs, MIN);
  const after = await readMock(named(uid), {}, d(NOW + 3 * DAY));
  assert.equal(after.open, false);
  assert.equal(after.ended.mockId, out.mockId);
  assert.equal(after.ended.endedBy, 'time-out');
  assert.deepEqual(after.ended.score, {correct: 1, answered: 2, total: 6});
  const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.equal(row.status, 'submitted');
  assert.equal(row.submittedAt, NOW + 60 * MIN);
  // The allowance counts from the moment time ran out.
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(NOW + 60 * MIN + 29 * DAY))), 'failed-precondition');
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(NOW + 60 * MIN + 30 * DAY))), 'ok');
});

test('starting after a strict time-out ends and scores the old mock, then applies the Free allowance', async () => {
  const uid = 'p-timeout-start';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM, strict: true}, d());
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(NOW + 2 * DAY))), 'failed-precondition');
  assert.equal((await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).get('endedBy'), 'time-out');
});

test('strict early end counts as a submission and may have no answers', async () => {
  const uid = 'p-strict-exit';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM, strict: true}, d());
  const done = await recordMock(named(uid), {mockId: out.mockId, answers: [], durationMs: MIN, reason: 'strict-exit'}, d(NOW + MIN));
  assert.equal(done.status, 'submitted');
  assert.equal((await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).get('endedBy'), 'strict-exit');
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, d(NOW + 2 * MIN))), 'failed-precondition');
  // A student submit without answers, or an early end on a non-strict mock, is invalid.
  const plain = await beginMock(pro(uid), {examId: EXAM}, d(NOW + 3 * MIN));
  assert.equal(await code(recordMock(pro(uid), {mockId: plain.mockId, answers: [], durationMs: MIN}, d(NOW + 4 * MIN))), 'invalid-argument');
  assert.equal(await code(recordMock(pro(uid), {mockId: plain.mockId, answers: [], durationMs: MIN, reason: 'strict-exit'}, d(NOW + 4 * MIN))), 'invalid-argument');
});

test('submitMock records once, is idempotent, and only the owner can submit', async () => {
  const uid = 'p-submit';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM}, d());
  const body = {mockId: out.mockId, answers: [answer('a0', false)], durationMs: 5};
  assert.equal(await code(recordMock(named('p-intruder'), body, d())), 'not-found');
  await recordMock(named(uid), body, d(NOW + 1000));
  await recordMock(named(uid), {...body, durationMs: 999}, d(NOW + 2000));
  const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.equal(row.status, 'submitted');
  assert.equal(row.submittedAt, NOW + 1000);
  assert.equal(row.durationMs, 5);
  assert.deepEqual(row.score, {correct: 0, answered: 1, total: 6});
});

test('startMock honours the rate limit', async () => {
  const uid = 'p-limit';
  await reset(uid);
  assert.equal(await code(beginMock(named(uid), {examId: EXAM}, {db, now: () => NOW, allow: async () => false})), 'resource-exhausted');
});
