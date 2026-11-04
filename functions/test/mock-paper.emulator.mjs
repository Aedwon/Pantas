import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {randomUUID} from 'node:crypto';
import {getFirestore} from 'firebase-admin/firestore';
import {assemblePaper, beginMock, recordMock, readMock, changeMock, FREE_MOCK_WINDOW_MS} from '../lib/mock.js';
import {serveMockHistory, serveMockResults} from '../lib/mockReader.js';
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
const grantPro = uid => db.doc(`users/${uid}/grants/mock-pro`).set({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + 60 * DAY, state: 'active', createdAt: NOW - DAY});
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
  const done = await recordMock(named(uid), {mockId: first.mockId, answers: [answer(first.paper.sections[0].questions[0].id, true)], durationMs: 5 * MIN}, d(submitAt));
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
  await grantPro(uid);
  const first = await beginMock(pro(uid), {examId: EXAM}, d());
  await recordMock(pro(uid), {mockId: first.mockId, answers: [answer(first.paper.sections[0].questions[0].id, true)], durationMs: MIN}, d(NOW + MIN));
  const second = await beginMock(pro(uid), {examId: EXAM}, d(NOW + 2 * MIN));
  const firstIds = new Set(first.paper.sections.flatMap(s => s.questions.map(q => q.id)));
  assert.ok(second.paper.sections.flatMap(s => s.questions).every(q => !firstIds.has(q.id)));
});

test('Pro is unlimited and expired server coverage is Free', async () => {
  const uid = 'p-pro';
  await reset(uid);
  await grantPro(uid);
  for (let i = 0; i < 3; i++) {
    const out = await beginMock(pro(uid), {examId: EXAM}, d(NOW + i * MIN));
    await recordMock(pro(uid), {mockId: out.mockId, answers: [answer(out.paper.sections[0].questions[0].id, true)], durationMs: MIN}, d(NOW + i * MIN + 1));
  }
  assert.equal((await items(uid)).size, 3);
  await db.doc(`users/${uid}/grants/mock-pro`).update({endsAt: NOW});
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
  await grantPro(uid);
  const plain = await beginMock(pro(uid), {examId: EXAM}, d(NOW + 3 * MIN));
  assert.equal(await code(recordMock(pro(uid), {mockId: plain.mockId, answers: [], durationMs: MIN}, d(NOW + 4 * MIN))), 'invalid-argument');
  assert.equal(await code(recordMock(pro(uid), {mockId: plain.mockId, answers: [], durationMs: MIN, reason: 'strict-exit'}, d(NOW + 4 * MIN))), 'invalid-argument');
});

test('submitMock records once, is idempotent, and only the owner can submit', async () => {
  const uid = 'p-submit';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM}, d());
  const body = {mockId: out.mockId, answers: [answer(out.paper.sections[0].questions[0].id, false)], durationMs: 5};
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

test('a third paper avoids both of the last two completed papers', async () => {
  const uid = 'p-recent-two';
  await reset(uid);
  await grantPro(uid);
  const earlier = new Set();
  for (let i = 0; i < 2; i++) {
    const out = await beginMock(pro(uid), {examId: EXAM}, {...d(NOW + i * MIN), seed: () => i + 1});
    for (const section of out.paper.sections) for (const q of section.questions) earlier.add(q.id);
    await recordMock(pro(uid), {mockId: out.mockId, answers: [answer(out.paper.sections[0].questions[0].id, true)], durationMs: 1}, d(NOW + i * MIN + 1));
  }
  const third = await beginMock(pro(uid), {examId: EXAM}, {...d(NOW + 3 * MIN), seed: () => 3});
  assert.ok(third.paper.sections.flatMap(s => s.questions).every(q => !earlier.has(q.id)));
});

test('per-exam recency survives two newer submissions for another exam', async () => {
  const uid = 'p-recent-exam'; await reset(uid); await grantPro(uid);
  const first = await beginMock(pro(uid), {examId: EXAM}, {...d(), seed: () => 1});
  await recordMock(pro(uid), {mockId: first.mockId, answers: [answer(first.paper.sections[0].questions[0].id, true)], durationMs: 1}, d(NOW + 1));
  for (let i = 0; i < 2; i++) await db.doc(`users/${uid}/server/mocks/items/OtherPaper00000${i}`).set({
    examId: 'exam_cse_sub', status: 'submitted', submittedAt: NOW + 10 + i,
    paper: {sections: [{questions: [{id: 'foreign'}]}]},
  });
  const next = await beginMock(pro(uid), {examId: EXAM}, {...d(NOW + MIN), seed: () => 1});
  const old = new Set(first.paper.sections.flatMap(s => s.questions.map(q => q.id)));
  assert.ok(next.paper.sections.flatMap(s => s.questions).every(q => !old.has(q.id)));
});

test('save and submit reject duplicate/foreign identities before altering a pinned paper', async () => {
  const uid = 'p-answer-membership'; await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM}, d());
  const good = answer(out.paper.sections[0].questions[0].id, true);
  for (const invalid of [[good, good], [answer('foreign', true)]]) {
    assert.equal(await code(changeMock(named(uid), {mockId: out.mockId, action: 'save', answers: invalid}, d())), 'invalid-argument');
    assert.equal(await code(recordMock(named(uid), {mockId: out.mockId, answers: invalid, durationMs: 1}, d())), 'invalid-argument');
  }
  const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.equal(row.status, 'started'); assert.deepEqual(row.answers, []);
});

// ---- listed regression: the keys of every listed response and row stay exactly as they were ----
const keys = value => Object.keys(value).sort();

test('listed exam: the startMock response and the stored row keep their exact keys, and no examName appears', async () => {
  const uid = 'p-keys';
  await reset(uid);
  const out = await beginMock(named(uid), {examId: EXAM}, d());
  assert.deepEqual(keys(out), ['answers', 'examId', 'limitMs', 'mockId', 'paper', 'paused', 'remainingMs', 'resumed', 'startedAt', 'strict']);
  const open = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.deepEqual(keys(open), ['answers', 'examId', 'limitMs', 'paper', 'pausedAt', 'pausedMs', 'seed', 'startedAt', 'status', 'strict']);
  assert.deepEqual(keys((await readMock(named(uid), {}, d(NOW + MIN)))).filter(k => k !== 'open'), ['answers', 'examId', 'limitMs', 'mockId', 'paper', 'paused', 'remainingMs', 'startedAt', 'strict']);
  await recordMock(named(uid), {mockId: out.mockId, answers: [answer(out.paper.sections[0].questions[0].id, true)], durationMs: MIN}, d(NOW + MIN));
  const done = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.deepEqual(keys(done), ['answerCount', 'answers', 'durationMs', 'endedBy', 'examId', 'limitMs', 'paper', 'pausedAt', 'pausedMs', 'score', 'seed', 'startedAt', 'status', 'strict', 'submittedAt']);
  const results = await serveMockResults(named(uid), {mockId: out.mockId}, d(NOW + 2 * MIN));
  assert.deepEqual(keys(results), ['accessRecheckAt', 'answers', 'canReview', 'durationMs', 'endedBy', 'examId', 'limitMs', 'mockId', 'paper', 'proCovered', 'reviewUntil', 'score', 'sections', 'serverNow', 'startedAt', 'strict', 'submittedAt']);
  const history = await serveMockHistory(named(uid), {}, d(NOW + 2 * MIN));
  assert.deepEqual(keys(history.items[0]), ['accessRecheckAt', 'canReview', 'durationMs', 'endedBy', 'examId', 'limitMs', 'mockId', 'proCovered', 'reviewUntil', 'score', 'sections', 'serverNow', 'startedAt', 'strict', 'submittedAt']);
});

test('listed exam: no parts anywhere, startPart and endPart are unknown, the server still never ends a non-strict mock, and the sent duration is stored', async () => {
  const listedKeys = ['answers', 'examId', 'limitMs', 'mockId', 'paper', 'paused', 'remainingMs', 'startedAt', 'strict'];
  for (const strict of [false, true]) {
    const uid = `p-listed-parts-${strict}`;
    await reset(uid);
    const out = await beginMock(named(uid), {examId: EXAM, strict}, d());
    assert.equal('parts' in out, false);
    assert.equal('parts' in (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data(), false);
    for (const action of ['startPart', 'endPart']) {
      await assert.rejects(changeMock(named(uid), {mockId: out.mockId, action}, d(NOW + MIN)), e => e.code === 'invalid-argument' && e.message === 'Unknown action.', `${strict} ${action}`);
    }
    // Any other unknown name is refused exactly as before.
    await assert.rejects(changeMock(named(uid), {mockId: out.mockId, action: 'skipPart'}, d(NOW + MIN)), e => e.code === 'invalid-argument' && e.message === 'Unknown action.');
    const saved = await changeMock(named(uid), {mockId: out.mockId, action: 'save', answers: [answer(out.paper.sections[0].questions[0].id, true)]}, d(NOW + MIN));
    assert.deepEqual(keys(saved), listedKeys);
    assert.equal('parts' in await readMock(named(uid), {}, d(NOW + 2 * MIN)), false);
    if (!strict) {
      assert.deepEqual(keys(await changeMock(named(uid), {mockId: out.mockId, action: 'pause'}, d(NOW + 3 * MIN))), listedKeys);
      assert.deepEqual(keys(await changeMock(named(uid), {mockId: out.mockId, action: 'resume'}, d(NOW + 4 * MIN))), listedKeys);
      // A day past the limit, the server still does not end it.
      const late = await readMock(named(uid), {}, d(NOW + DAY));
      assert.equal(late.open, true);
      assert.equal(late.remainingMs, 0);
      assert.equal('parts' in late, false);
    }
    // The sent duration is stored as sent, whatever the clock says.
    const at = strict ? NOW + 10 * MIN : NOW + 90 * MIN;
    await recordMock(named(uid), {mockId: out.mockId, answers: [answer(out.paper.sections[0].questions[0].id, true)], durationMs: 7 * MIN}, d(at));
    const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
    assert.equal(row.durationMs, 7 * MIN);
    assert.equal('parts' in row, false);
    assert.deepEqual(keys(row), ['answerCount', 'answers', 'durationMs', 'endedBy', 'examId', 'limitMs', 'paper', 'pausedAt', 'pausedMs', 'score', 'seed', 'startedAt', 'status', 'strict', 'submittedAt']);
  }
});

// ---- custom exams: a corpus with the real topic sizes ----
const CE = {vl: 'topic_mp_verbal_logic', di: 'topic_mp_data_interp', al: 'topic_mp_algebra', cs: 'topic_mp_comprehension'};
const ALL = [CE.vl, CE.di, CE.al, CE.cs];
const free = (prefix, count) => Array.from({length: count}, (_, i) => ({id: `${prefix}-${i}`}));
const cset = (id, topic, questions) => ({id, topic, lesson: null, exams: ['exam_mp_a'], language: 'en', questions});
const passageSets = Array.from({length: 32}, (_, p) => cset(`set-cs-${p}`, CE.cs,
  Array.from({length: 5}, (_, i) => ({id: `cs-${p * 5 + i}`, passage: `cs-p${p}`}))));
const corpus = {
  index: {
    subjects: [{_id: 'subj_mp_reasoning', name: 'Reasoning', exam: 'exam_mp_a', ordering: 1}, {_id: 'subj_mp_math', name: 'Mathematics', exam: 'exam_mp_a', ordering: 2},
      {_id: 'subj_mp_reading', name: 'Reading Comprehension', exam: 'exam_mp_b', ordering: 3}],
    topics: [{_id: CE.vl, name: 'Verbal Logic', subject: 'subj_mp_reasoning', ordering: 1}, {_id: CE.di, name: 'Data Interpretation', subject: 'subj_mp_reasoning', ordering: 2},
      {_id: CE.al, name: 'Algebra', subject: 'subj_mp_math', ordering: 1}, {_id: CE.cs, name: 'Comprehension Skills', subject: 'subj_mp_reading', ordering: 1}],
    catalogs: ['exam_mp_a', 'exam_mp_b']},
  exam_mp_a: {id: 'exam_mp_a', sets: [cset('set-vl', CE.vl, free('vl', 20)), cset('set-di', CE.di, free('di', 40)),
    cset('set-al-0', CE.al, free('al0', 60)), cset('set-al-1', CE.al, free('al1', 60))]},
  exam_mp_b: {id: 'exam_mp_b', sets: passageSets},
};
const sec = (id, name, questionCount, suggestedMinutes, topicIds) => ({id, name, questionCount, suggestedMinutes, topicIds});
async function makeTrack(uid, sections, {name = 'PUP CET', timed = false, minutes, excluded = [], settings} = {}) {
  const examId = `exam_custom_${randomUUID()}`;
  const totalQuestions = sections.reduce((n, s) => n + s.questionCount, 0);
  const totalMinutes = minutes ?? sections.reduce((n, s) => n + s.suggestedMinutes, 0);
  await db.doc(`users/${uid}/server/customTracks/items/${examId}`).set({examId, name, excludedTopicIds: excluded, excludedLessonIds: [],
    blueprint: {sectionsJson: JSON.stringify(sections), totalQuestions, totalMinutes, sectionsTimedSeparately: timed, updatedAt: NOW}, createdAt: NOW, updatedAt: NOW});
  if (settings) await db.doc(`users/${uid}/server/settings`).set({examId: settings.examId ?? examId, excludedTopicIds: settings.excluded ?? [], excludedLessonIds: [], studyDays: [1, 2, 3, 4, 5, 6, 7], updatedAt: NOW});
  return examId;
}
const idsOf = out => out.paper.sections.flatMap(s => s.questions.map(q => q.id));
const countIn = (ids, prefix) => ids.filter(id => id.startsWith(prefix)).length;
const sectionIds = (out, index) => out.paper.sections[index].questions.map(q => q.id);
const noMock = async promise => assert.rejects(promise, e => e.code === 'failed-precondition' && e.message === 'This exam has no mock yet.');
const notEnough = async promise => assert.rejects(promise, e => e.code === 'failed-precondition' && e.message === 'There are not enough questions for this mock yet.');

test('seed the custom corpus', async () => {
  for (const [id, value] of Object.entries(corpus)) await db.doc(`content/catalog/items/${id}`).set({version: `mp-${id}`, payload: JSON.stringify(value)});
  clearExamContentCache();
});

test('a malformed custom id is Unknown exam, and a custom id with no track has no mock', async () => {
  const uid = 'p-c-unknown';
  await reset(uid);
  for (const examId of ['exam_custom', 'exam_custom_x', `exam_custom_${randomUUID().toUpperCase()}`]) {
    await assert.rejects(beginMock(named(uid), {examId}, d()), e => e.code === 'invalid-argument' && e.message === 'Unknown exam.');
  }
  await noMock(beginMock(named(uid), {examId: `exam_custom_${randomUUID()}`}, d()));
  const bare = `exam_custom_${randomUUID()}`;
  await db.doc(`users/${uid}/server/customTracks/items/${bare}`).set({examId: bare, name: 'No plan', excludedTopicIds: [], excludedLessonIds: [], blueprint: null, createdAt: NOW, updatedAt: NOW});
  await noMock(beginMock(named(uid), {examId: bare}, d()));
  assert.equal((await items(uid)).size, 0);
});

test('two overlapping all-topic parts: exact count in each, no question twice, the student\'s order kept', async () => {
  const uid = 'p-c-overlap';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_1', 'Part A', 40, 30, ALL), sec('section_2', 'Part B', 50, 40, ALL)]);
  const out = await beginMock(named(uid), {examId}, d());
  assert.deepEqual(out.paper.sections.map(s => [s.sectionId, s.name, s.questions.length]), [['section_1', 'Part A', 40], ['section_2', 'Part B', 50]]);
  assert.equal(out.paper.expectedQuestionCount, 90);
  const ids = idsOf(out);
  assert.equal(new Set(ids).size, 90);
  assert.equal(out.limitMs, 70 * MIN);
  assert.equal(out.remainingMs, 70 * MIN);
  assert.equal(out.examId, examId);
  assert.ok(out.paper.sections.every(s => s.questions.every(q => /^set-(vl|di|al-[01]|cs-\d+)$/.test(q.setId))));
  // The set comes from the corpus: every comprehension question sits in the set of its own passage.
  for (const q of out.paper.sections.flatMap(s => s.questions).filter(q => q.id.startsWith('cs-'))) {
    assert.equal(q.setId, `set-cs-${Math.floor(Number(q.id.slice(3)) / 5)}`);
  }
});

test('a subject part is filled before an all-topic part, even when the student lists it last', async () => {
  const uid = 'p-c-narrow';
  await reset(uid);
  // Verbal logic holds exactly 20. Taken second, the wide part would already have used some of them.
  const examId = await makeTrack(uid, [sec('section_all', 'Everything', 60, 40, [CE.vl, CE.di, CE.al]), sec('section_1', 'Verbal logic', 20, 15, [CE.vl])]);
  const out = await beginMock(named(uid), {examId}, d());
  assert.deepEqual(out.paper.sections.map(s => s.sectionId), ['section_all', 'section_1']);
  assert.equal(countIn(sectionIds(out, 1), 'vl-'), 20);
  assert.equal(countIn(sectionIds(out, 0), 'vl-'), 0);
  assert.equal(sectionIds(out, 0).length, 60);
  assert.equal(new Set(idsOf(out)).size, 80);
});

test('a small topic fills through proportional weights and never over its size', async () => {
  const uid = 'p-c-small';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_all', 'Mixed', 60, 40, [CE.vl, CE.al])]);
  const out = await beginMock(named(uid), {examId}, d());
  const ids = idsOf(out);
  assert.equal(ids.length, 60);
  assert.equal(new Set(ids).size, 60);
  assert.ok(countIn(ids, 'vl-') >= 8 && countIn(ids, 'vl-') <= 10, `verbal logic got ${countIn(ids, 'vl-')}`);
  // A section larger than the small topic's equal share still fills.
  const heavy = await makeTrack(uid, [sec('section_all', 'Heavy', 130, 60, [CE.vl, CE.al])]);
  const big = await assemblePaper(db, uid, heavy, NOW, 3);
  const bigIds = big.paper.sections[0].questions.map(q => q.id);
  assert.equal(bigIds.length, 130);
  assert.equal(new Set(bigIds).size, 130);
  assert.ok(countIn(bigIds, 'vl-') <= 20);
});

test('an all-passage topic tops up to the exact count, with partial passages only as the last resort', async () => {
  const uid = 'p-c-passage';
  await reset(uid);
  for (const count of [3, 12, 17, 160]) {
    const examId = await makeTrack(uid, [sec('section_1', 'Reading', count, 30, [CE.cs])]);
    const {paper} = await assemblePaper(db, uid, examId, NOW, count);
    const ids = paper.sections[0].questions.map(q => q.id);
    assert.equal(ids.length, count, `count ${count}`);
    assert.equal(new Set(ids).size, count);
    assert.ok(ids.every(id => id.startsWith('cs-')));
  }
  // A passage topic beside free-standing ones: free-standing questions fill the gap before any partial passage.
  const mixed = await makeTrack(uid, [sec('section_1', 'Mixed', 13, 30, [CE.cs, CE.vl])]);
  const {paper} = await assemblePaper(db, uid, mixed, NOW, 9);
  const ids = paper.sections[0].questions.map(q => q.id);
  assert.equal(ids.length, 13);
  const byPassage = new Map();
  for (const id of ids.filter(i => i.startsWith('cs-'))) byPassage.set(Math.floor(Number(id.slice(3)) / 5), (byPassage.get(Math.floor(Number(id.slice(3)) / 5)) ?? 0) + 1);
  assert.ok([...byPassage.values()].every(n => n === 5), 'passages stay whole when free-standing questions can fill the rest');
});

test('the paper is refused when the union cannot fill a section, and nothing is stored', async () => {
  const uid = 'p-c-short';
  await reset(uid);
  const small = await makeTrack(uid, [sec('section_1', 'Too many', 21, 20, [CE.vl])]);
  await notEnough(beginMock(named(uid), {examId: small}, d()));
  const later = await makeTrack(uid, [sec('section_1', 'First', 15, 20, [CE.vl]), sec('section_2', 'Second', 10, 20, [CE.vl])]);
  await notEnough(beginMock(named(uid), {examId: later}, d()));
  // An unknown topic id gives nothing to draw from.
  const none = await makeTrack(uid, [sec('section_1', 'Nothing', 1, 5, ['topic_not_there'])]);
  await notEnough(beginMock(named(uid), {examId: none}, d()));
  assert.equal((await items(uid)).size, 0);
});

test('a topic the student excluded never reaches the paper, by the settings list or by the track\'s own copy', async () => {
  const uid = 'p-c-excluded';
  await reset(uid);
  // Active exam: settings are authoritative, the track copy is ignored.
  const active = await makeTrack(uid, [sec('section_all', 'Everything', 100, 60, ALL)], {excluded: [CE.al], settings: {excluded: [CE.cs, CE.di]}});
  let ids = (await assemblePaper(db, uid, active, NOW, 1)).paper.sections[0].questions.map(q => q.id);
  assert.equal(ids.length, 100);
  assert.deepEqual([countIn(ids, 'cs-'), countIn(ids, 'di-')], [0, 0]);
  assert.ok(countIn(ids, 'al0-') + countIn(ids, 'al1-') > 0);
  // Another exam is active: the track's own snapshot decides.
  const other = await makeTrack(uid, [sec('section_all', 'Everything', 60, 60, ALL)], {excluded: [CE.al, CE.cs], settings: {examId: 'exam_cse_pro', excluded: [CE.vl]}});
  ids = (await assemblePaper(db, uid, other, NOW, 1)).paper.sections[0].questions.map(q => q.id);
  assert.equal(ids.length, 60);
  assert.equal(countIn(ids, 'al'), 0);
  assert.equal(countIn(ids, 'cs-'), 0);
  assert.equal(countIn(ids, 'vl-'), 20);
  assert.equal(countIn(ids, 'di-'), 40);
  // Narrowing below the blueprint refuses the paper rather than drawing from an excluded topic.
  const tight = await makeTrack(uid, [sec('section_all', 'Everything', 61, 60, ALL)], {excluded: [CE.al, CE.cs]});
  await notEnough(assemblePaper(db, uid, tight, NOW, 1));
});

test('starting again returns the open custom mock and its pinned paper, whichever track asks', async () => {
  const uid = 'p-c-reuse';
  await reset(uid);
  const first = await makeTrack(uid, [sec('section_1', 'One', 10, 20, ALL)], {name: 'First'});
  const second = await makeTrack(uid, [sec('section_1', 'One', 12, 20, ALL)], {name: 'Second'});
  const out = await beginMock(named(uid), {examId: first}, d());
  assert.equal(out.resumed, false);
  const again = await beginMock(named(uid), {examId: first}, d(NOW + DAY));
  assert.equal(again.resumed, true);
  assert.equal(again.mockId, out.mockId);
  assert.deepEqual(again.paper, out.paper);
  const other = await beginMock(named(uid), {examId: second}, d(NOW + DAY));
  assert.equal(other.mockId, out.mockId);
  assert.equal(other.examId, first);
  assert.equal((await items(uid)).size, 1);
});

test('a custom mock keeps the track name in its row and its view, and nothing else new', async () => {
  const uid = 'p-c-name';
  await reset(uid);
  await reset('p-c-name-2');
  const examId = await makeTrack(uid, [sec('section_1', 'One', 10, 20, ALL)], {name: 'PUP CET'});
  const out = await beginMock(named(uid), {examId}, d());
  assert.equal(out.examName, 'PUP CET');
  assert.deepEqual(keys(out), ['answers', 'examId', 'examName', 'limitMs', 'mockId', 'paper', 'paused', 'remainingMs', 'resumed', 'startedAt', 'strict']);
  const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.equal(row.examName, 'PUP CET');
  assert.deepEqual(keys(row), ['answers', 'examId', 'examName', 'limitMs', 'paper', 'pausedAt', 'pausedMs', 'seed', 'startedAt', 'status', 'strict']);
  assert.equal((await readMock(named(uid), {}, d(NOW + MIN))).examName, 'PUP CET');
  assert.equal((await changeMock(named(uid), {mockId: out.mockId, action: 'pause'}, d(NOW + MIN))).examName, 'PUP CET');
  // A track with no name writes no key at all.
  const unnamed = await makeTrack('p-c-name-2', [sec('section_1', 'One', 10, 20, ALL)], {name: null});
  const plain = await beginMock(named('p-c-name-2'), {examId: unnamed}, d());
  assert.equal('examName' in plain, false);
  assert.equal('examName' in (await db.doc(`users/p-c-name-2/server/mocks/items/${plain.mockId}`).get()).data(), false);
  await reset('p-c-name-2');
});

test('a full one-clock custom run: start, save, submit, then results and history read it', async () => {
  const uid = 'p-c-run';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_1', 'Part A', 30, 30, ALL), sec('section_2', 'Part B', 30, 30, ALL)], {name: 'PUP CET'});
  const out = await beginMock(named(uid), {examId, strict: true}, d());
  assert.equal(out.limitMs, 60 * MIN);
  const ids = idsOf(out);
  await changeMock(named(uid), {mockId: out.mockId, action: 'save', answers: ids.slice(0, 5).map(id => answer(id, true))}, d(NOW + 5 * MIN));
  const done = await recordMock(named(uid), {mockId: out.mockId, answers: ids.slice(0, 10).map((id, i) => answer(id, i < 7)), durationMs: 20 * MIN}, d(NOW + 20 * MIN));
  assert.equal(done.status, 'submitted');
  const row = (await db.doc(`users/${uid}/server/mocks/items/${out.mockId}`).get()).data();
  assert.deepEqual(row.paper, out.paper, 'the pinned paper is what was served');
  assert.deepEqual(row.score, {correct: 7, answered: 10, total: 60});
  const results = await serveMockResults(named(uid), {mockId: out.mockId}, d(NOW + 21 * MIN));
  assert.equal(results.examName, 'PUP CET');
  assert.equal(results.examId, examId);
  assert.equal(results.canReview, true);
  assert.equal(results.proCovered, false);
  assert.deepEqual(results.score, {correct: 7, answered: 10, wrong: 3, blank: 50, total: 60});
  assert.deepEqual(results.sections.map(s => [s.sectionId, s.total]), [['section_1', 30], ['section_2', 30]]);
  const history = await serveMockHistory(named(uid), {}, d(NOW + 21 * MIN));
  assert.deepEqual(history.items.map(i => [i.mockId, i.examId, i.examName]), [[out.mockId, examId, 'PUP CET']]);
  // A Free account is now inside its window, for any exam.
  const next = await makeTrack(uid, [sec('section_1', 'One', 10, 20, ALL)]);
  await assert.rejects(beginMock(named(uid), {examId: next}, d(NOW + 22 * MIN)), e => e.code === 'failed-precondition' && e.message === 'Free accounts can take one mock every 30 days.');
});

test('a paper depends only on the seed: same seed same paper, another seed another paper', async () => {
  const uid = 'p-c-seed';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_1', 'Part A', 40, 30, ALL), sec('section_2', 'Part B', 40, 30, [CE.vl, CE.di, CE.al])]);
  const a = await assemblePaper(db, uid, examId, NOW, 12345);
  const b = await assemblePaper(db, uid, examId, NOW + DAY, 12345);
  const c = await assemblePaper(db, uid, examId, NOW, 12346);
  assert.deepEqual(a, b);
  assert.notDeepEqual(a.paper, c.paper);
  // The same plan on another account gives the same paper for the same seed.
  const other = 'p-c-seed-2';
  await reset(other);
  const copy = await makeTrack(other, [sec('section_1', 'Part A', 40, 30, ALL), sec('section_2', 'Part B', 40, 30, [CE.vl, CE.di, CE.al])]);
  assert.deepEqual((await assemblePaper(db, other, copy, NOW, 12345)).paper, a.paper);
  await reset(other);
});

test('a paper of 300 questions, the cap, fills exactly with no repeat', async () => {
  const uid = 'p-c-cap';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_1', 'Everything', 300, 240, ALL)]);
  const out = await beginMock(named(uid), {examId}, d());
  const ids = idsOf(out);
  assert.equal(ids.length, 300);
  assert.equal(new Set(ids).size, 300);
  assert.equal(out.paper.expectedQuestionCount, 300);
  const split = await makeTrack(uid, [sec('section_1', 'A', 150, 100, ALL), sec('section_2', 'B', 150, 100, ALL)]);
  const two = await assemblePaper(db, uid, split, NOW, 7);
  assert.equal(new Set(two.paper.sections.flatMap(s => s.questions.map(q => q.id))).size, 300);
});

test('the last two submitted papers for this exam are avoided when the corpus allows', async () => {
  const uid = 'p-c-recent';
  await reset(uid);
  const examId = await makeTrack(uid, [sec('section_1', 'One', 60, 60, ALL)]);
  const seen = new Set();
  for (let i = 0; i < 2; i++) {
    const {paper} = await assemblePaper(db, uid, examId, NOW, i + 1);
    for (const q of paper.sections[0].questions) seen.add(q.id);
    await db.doc(`users/${uid}/server/mocks/items/Earlier0000000${i}`).set({examId, status: 'submitted', submittedAt: NOW + i, paper});
  }
  // Another exam's newer papers do not push these out of view.
  for (let i = 0; i < 2; i++) await db.doc(`users/${uid}/server/mocks/items/OtherExam000000${i}`).set({examId: EXAM, status: 'submitted', submittedAt: NOW + 10 + i, paper: {sections: [{questions: [{id: 'foreign'}]}]}});
  const third = (await assemblePaper(db, uid, examId, NOW + DAY, 3)).paper.sections[0].questions.map(q => q.id);
  assert.equal(third.length, 60);
  assert.ok(third.every(id => !seen.has(id)), 'the new paper repeats nothing from the last two');
});

test('sectionMinutes follows the paper order only when the plan times its parts separately', async () => {
  const uid = 'p-c-minutes';
  await reset(uid);
  const parts = [sec('section_1', 'Wide', 30, 30, ALL), sec('section_2', 'Narrow', 10, 20, [CE.vl])];
  const timed = await makeTrack(uid, parts, {timed: true});
  const t = await assemblePaper(db, uid, timed, NOW, 1);
  assert.deepEqual(t.sectionMinutes, [30, 20]);
  assert.equal(t.limitMs, 50 * MIN);
  assert.deepEqual(t.paper.sections.map(s => s.sectionId), ['section_1', 'section_2']);
  const one = await makeTrack(uid, parts, {timed: false, minutes: 45});
  const o = await assemblePaper(db, uid, one, NOW, 1);
  assert.equal(o.sectionMinutes, null);
  assert.equal(o.limitMs, 45 * MIN);
  const listed = await assemblePaper(db, uid, EXAM, NOW, 1);
  assert.equal(listed.sectionMinutes, null);
  assert.deepEqual(keys(listed), ['limitMs', 'paper', 'sectionMinutes']);
});

test('another account sees no mock for this account\'s custom id', async () => {
  const owner = 'p-c-owner', stranger = 'p-c-stranger';
  await reset(owner);
  await reset(stranger);
  const examId = await makeTrack(owner, [sec('section_1', 'One', 10, 20, ALL)]);
  await noMock(beginMock(named(stranger), {examId}, d()));
  const out = await beginMock(named(owner), {examId}, d());
  await recordMock(named(owner), {mockId: out.mockId, answers: [answer(idsOf(out)[0], true)], durationMs: MIN}, d(NOW + MIN));
  await assert.rejects(serveMockResults(named(stranger), {mockId: out.mockId}, d(NOW + 2 * MIN)), e => e.code === 'not-found');
  assert.deepEqual((await serveMockHistory(named(stranger), {}, d(NOW + 2 * MIN))).items, []);
  assert.equal((await items(stranger)).size, 0);
});
