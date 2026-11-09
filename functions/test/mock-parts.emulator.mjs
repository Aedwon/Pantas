import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {randomUUID} from 'node:crypto';
import {getFirestore} from 'firebase-admin/firestore';
import {saveExamSettings} from '../lib/roadmap.js';
import {removeCustomTrack} from '../lib/customTracks.js';
import {fromDoc} from '../lib/_answerTotals.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {beginMock, changeMock, readMock, recordMock} from '../lib/mock.js';
import {serveMockAvailability, serveMockHistory, serveMockResults} from '../lib/mockReader.js';
import {STRICT_BREAK_MS} from '../lib/_mockParts.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const SEC = 1000;
const MIN = 60 * SEC;
const DAY = 86_400_000;
const T0 = Date.parse('2026-10-24T10:00:00+08:00');
const named = uid => ({uid, token: {firebase: {sign_in_provider: 'google.com'}}});
const deps = (at = T0) => ({db, now: () => at, allow: async () => true, seed: () => 11});
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const newId = () => `exam_custom_${randomUUID()}`;
const mockPath = (uid, id) => `users/${uid}/server/mocks/items/${id}`;
const rowOf = async (uid, id) => (await db.doc(mockPath(uid, id)).get()).data();
const refused = (promise, code, message) => assert.rejects(promise, e => e.code === code && (message === undefined || e.message === message));
const STRICT_REFUSAL = 'Strict mode does not allow this.';

// ---- a small corpus: two topics of 40 questions each ----
const ONE = 'topic_pt_one', TWO = 'topic_pt_two', BOTH = [ONE, TWO];
const questions = (prefix, count) => Array.from({length: count}, (_, i) => ({id: `${prefix}-${i}`}));
const lessons = (topic, prefix) => Array.from({length: 6}, (_, i) => ({id: `${prefix}-${i}`, topic, title: `Lesson ${prefix} ${i}`, ordering: i}));
const catalog = {
  index: {subjects: [{_id: 'subj_pt_a', name: 'Part Subject A', exam: 'exam_pt_a', ordering: 1}, {_id: 'subj_pt_b', name: 'Part Subject B', exam: 'exam_pt_b', ordering: 2}],
    topics: [{_id: ONE, name: 'One', subject: 'subj_pt_a', ordering: 1}, {_id: TWO, name: 'Two', subject: 'subj_pt_b', ordering: 1}], catalogs: ['exam_pt_a', 'exam_pt_b']},
  exam_pt_a: {id: 'exam_pt_a', lessons: lessons(ONE, 'lesson-pa'),
    sets: [{id: 'set-pt-one', topic: ONE, lesson: 'lesson-pa-0', exams: ['exam_pt_a'], questions: questions('p1', 40)}]},
  exam_pt_b: {id: 'exam_pt_b', lessons: lessons(TWO, 'lesson-pb'),
    sets: [{id: 'set-pt-two', topic: TWO, lesson: 'lesson-pb-0', exams: ['exam_pt_b'], questions: questions('p2', 40)}]},
};
test('seed the corpus', async () => {
  for (const [id, value] of Object.entries(catalog)) await db.doc(`content/catalog/items/${id}`).set({version: `pt-${id}`, payload: JSON.stringify(value)});
  clearExamContentCache();
});

// ---- tracks: three parts of 4 questions. Part 1 draws from One, part 2 from Two, part 3 from both ----
const MINUTES = [20, 15, 10];
const TOTAL = MINUTES.reduce((a, b) => a + b, 0);
const sections = (minutes = MINUTES) => minutes.map((m, i) => ({id: `section_${i + 1}`, name: `Part ${i + 1}`, questionCount: 4, suggestedMinutes: m,
  topicIds: i === 0 ? [ONE] : i === 1 ? [TWO] : BOTH}));
const blueprint = (minutes = MINUTES, over = {}) => ({sectionsJson: JSON.stringify(sections(minutes)), totalQuestions: 4 * minutes.length,
  totalMinutes: minutes.reduce((a, b) => a + b, 0), sectionsTimedSeparately: true, updatedAt: T0, ...over});

/** The real path: the track arrives through the settings save. */
const settingsInput = (uid, examId, extra = {}) => ({expectedUid: uid, examId, examDate: {precision: 'day', day: '2026-11-30'},
  studyDays: [1, 2, 3, 4, 5, 6, 7], assessmentCompleted: true, ...extra});
const saveTrack = (uid, examId, bp, at = T0) => saveExamSettings(named(uid), settingsInput(uid, examId, {customTrack: {name: 'Own exam', blueprint: bp}}), deps(at));

/** A direct write of the same document, for tests that do not need the settings path. */
async function directTrack(uid, {minutes = MINUTES, timed = true, name = 'Own exam'} = {}) {
  const examId = newId();
  const bp = blueprint(minutes, {sectionsTimedSeparately: timed});
  await db.doc(`users/${uid}/server/customTracks/items/${examId}`).set({examId, name, excludedTopicIds: [], excludedLessonIds: [], blueprint: bp, createdAt: T0, updatedAt: T0});
  return examId;
}
const idsIn = (out, part) => out.paper.sections[part].questions.map(q => q.id);
const answer = (questionId, correct = true, chosen = 'a', at = T0) => ({questionId, chosen, correct, answeredAt: at});
const blank = (questionId, at = T0) => ({questionId, chosen: null, correct: false, answeredAt: at});

/** Starts a fresh by-part mock for a new account. */
async function begin(uid, {strict = false, minutes = MINUTES, at = T0} = {}) {
  await reset(uid);
  const examId = await directTrack(uid, {minutes});
  const out = await beginMock(named(uid), {examId, strict}, deps(at));
  return {examId, out, id: out.mockId};
}
const act = (uid, id, action, at, extra = {}) => changeMock(named(uid), {mockId: id, action, ...extra}, deps(at));
const save = (uid, id, at, answers) => act(uid, id, 'save', at, {answers});
const submit = (uid, id, at, answers, extra = {}) => recordMock(named(uid), {mockId: id, answers, durationMs: 1, ...extra}, deps(at));
const look = (uid, at) => readMock(named(uid), {}, deps(at));
const keys = value => Object.keys(value).sort();
const clockOf = row => ({parts: row.parts, pausedAt: row.pausedAt, pausedMs: row.pausedMs});

// ---- the blueprint is saved the way the app does, then a full run in each mode ----

test('non-strict full run: parts close by time or by the student, answers stay with their part, and the results count them', async () => {
  const uid = 'pt-full', examId = newId();
  await reset(uid);
  await saveTrack(uid, examId, blueprint());
  const out = await beginMock(named(uid), {examId}, deps(T0));
  const id = out.mockId;
  assert.equal(out.resumed, false);
  assert.equal(out.limitMs, TOTAL * MIN);
  assert.equal(out.remainingMs, TOTAL * MIN);
  assert.deepEqual(out.parts, {index: 0, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 20 * MIN, waiting: false, endedEarly: false, startsInMs: null});
  assert.equal(out.paper.sections.length, 3);
  const [p1, p2, p3] = [0, 1, 2].map(i => idsIn(out, i));

  await save(uid, id, T0 + 5 * MIN, [answer(p1[0], true), answer(p1[1], false)]);

  // Part 1 timed out at minute 20. Nobody called, and the next read finds the part closed at that moment.
  const waiting = await look(uid, T0 + 25 * MIN);
  assert.equal(waiting.open, true);
  assert.deepEqual(waiting.parts, {index: 1, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 15 * MIN, waiting: true, endedEarly: false, startsInMs: null});
  assert.equal(waiting.remainingMs, 25 * MIN);
  assert.equal(waiting.answers.length, 2);
  assert.deepEqual(waiting.paper, out.paper);
  let row = await rowOf(uid, id);
  assert.equal(row.parts.waitingSince, T0 + 20 * MIN);
  assert.deepEqual(row.parts.usedMs, [20 * MIN]);

  // A late save for part 1 is dropped without an error.
  const late = await save(uid, id, T0 + 26 * MIN, [answer(p1[2], true), answer(p1[0], false, 'b')]);
  assert.deepEqual(late.answers, waiting.answers);
  // The wait has no clock.
  const days = await look(uid, T0 + 5 * DAY);
  assert.equal(days.parts.waiting, true);
  assert.equal(days.parts.remainingMs, 15 * MIN);

  const started = await act(uid, id, 'startPart', T0 + 30 * MIN);
  assert.equal(started.parts.waiting, false);
  assert.equal(started.parts.remainingMs, 15 * MIN);
  assert.equal((await rowOf(uid, id)).parts.startedAt, T0 + 30 * MIN);

  // Part 2: an answer for part 2 is taken, a changed answer for part 1 is not.
  const mixed = await save(uid, id, T0 + 32 * MIN, [answer(p2[0], true), answer(p1[0], false, 'b')]);
  assert.deepEqual(mixed.answers.map(a => [a.questionId, a.chosen, a.correct]), [[p1[0], 'a', true], [p1[1], 'a', false], [p2[0], 'a', true]]);

  // Pause, hours pass, resume. The pause is not part time.
  await act(uid, id, 'pause', T0 + 35 * MIN);
  const paused = await look(uid, T0 + 120 * MIN);
  assert.equal(paused.paused, true);
  assert.equal(paused.parts.remainingMs, 10 * MIN);
  const availability = await serveMockAvailability(named(uid), {examId}, deps(T0 + 120 * MIN));
  assert.equal(availability.status, 'in-progress');
  assert.equal(availability.open.paused, true);
  const resumed = await act(uid, id, 'resume', T0 + 120 * MIN);
  assert.equal(resumed.paused, false);
  assert.equal(resumed.parts.remainingMs, 10 * MIN);
  assert.equal((await look(uid, T0 + 123 * MIN)).parts.remainingMs, 7 * MIN);
  assert.equal((await serveMockAvailability(named(uid), {examId}, deps(T0 + 123 * MIN))).open.paused, false);

  // The student ends part 2 early: 125 - 30 - 85 minutes of pause = 10 minutes used.
  const ended = await act(uid, id, 'endPart', T0 + 125 * MIN);
  assert.deepEqual(ended.parts, {index: 2, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 10 * MIN, waiting: true, endedEarly: true, startsInMs: null});
  assert.equal(ended.remainingMs, 10 * MIN);
  row = await rowOf(uid, id);
  assert.deepEqual(row.parts.usedMs, [20 * MIN, 10 * MIN]);
  assert.equal(row.parts.waitingSince, T0 + 125 * MIN);
  assert.equal(row.pausedAt, null);
  assert.equal(row.pausedMs, 0);

  await act(uid, id, 'startPart', T0 + 130 * MIN);
  // The submit sends every question, with closed-part answers changed and a false duration. Part 3 is taken as sent.
  const done = await submit(uid, id, T0 + 132 * MIN,
    [answer(p1[0], false, 'z'), blank(p1[1]), answer(p2[0], false, 'z'), blank(p2[1]), answer(p3[0], true), blank(p3[1]), blank(p3[2]), blank(p3[3])], {durationMs: 999});
  assert.deepEqual(done, {mockId: id, status: 'submitted'});
  row = await rowOf(uid, id);
  assert.equal(row.status, 'submitted');
  assert.equal(row.endedBy, 'student');
  assert.equal(row.submittedAt, T0 + 132 * MIN);
  assert.equal(row.durationMs, 32 * MIN);
  assert.deepEqual(row.parts.usedMs, [20 * MIN, 10 * MIN, 2 * MIN]);
  assert.deepEqual(row.answers.filter(a => a.chosen !== null).map(a => [a.questionId, a.chosen, a.correct]),
    [[p1[0], 'a', true], [p1[1], 'a', false], [p2[0], 'a', true], [p3[0], 'a', true]]);
  assert.deepEqual(row.score, {correct: 3, answered: 4, total: 12});

  const results = await serveMockResults(named(uid), {mockId: id}, deps(T0 + 140 * MIN));
  assert.deepEqual(results.score, {correct: 3, answered: 4, wrong: 1, blank: 8, total: 12});
  assert.deepEqual(results.sections.map(s => [s.correct, s.wrong, s.blank]), [[1, 1, 2], [1, 0, 3], [1, 0, 3]]);
  assert.equal(results.durationMs, 32 * MIN);
  assert.equal(results.limitMs, TOTAL * MIN);
  const history = await serveMockHistory(named(uid), {}, deps(T0 + 140 * MIN));
  assert.deepEqual(history.items.map(i => [i.mockId, i.durationMs, i.endedBy]), [[id, 32 * MIN, 'student']]);

  // The totals hold only the kept answers.
  const totals = fromDoc((await db.doc(`users/${uid}/server/answerTotals`).get()).data());
  assert.equal(totals.answers, 4);
  assert.deepEqual([...totals.questions.keys()].sort(), [p1[0], p1[1], p2[0], p3[0]].sort());
  const session = (await db.doc(`users/${uid}/server/answers/items/mock:${id}`).get()).data();
  assert.equal(session.answerCount, 4);
  assert.equal(session.durationMs, 32 * MIN);
  assert.equal(session.finishedAt, T0 + 132 * MIN);
});

test('strict full run: no pause or early end, the break runs out by itself, and the last part ends the paper at its exact moment', async () => {
  const uid = 'pt-strict-full', examId = newId();
  await reset(uid);
  await saveTrack(uid, examId, blueprint());
  const out = await beginMock(named(uid), {examId, strict: true}, deps(T0));
  const id = out.mockId;
  const [p1, p2, p3] = [0, 1, 2].map(i => idsIn(out, i));
  const before = clockOf(await rowOf(uid, id));
  for (const action of ['pause', 'resume', 'discard', 'endPart']) {
    await refused(act(uid, id, action, T0 + MIN), 'failed-precondition', STRICT_REFUSAL);
  }
  assert.deepEqual(clockOf(await rowOf(uid, id)), before);

  await save(uid, id, T0 + 3 * MIN, [answer(p1[0], true), answer(p1[1], false)]);
  const edge = await look(uid, T0 + 20 * MIN - 1);
  assert.equal(edge.parts.remainingMs, 1);
  assert.equal(edge.parts.waiting, false);
  // The break starts at minute 20 and runs 60 seconds.
  const waiting = await look(uid, T0 + 20 * MIN);
  assert.deepEqual(waiting.parts, {index: 1, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 15 * MIN, waiting: true, endedEarly: false, startsInMs: STRICT_BREAK_MS});
  assert.equal((await look(uid, T0 + 20 * MIN + 30 * SEC)).parts.startsInMs, STRICT_BREAK_MS - 30 * SEC);
  await refused(act(uid, id, 'pause', T0 + 20 * MIN + 31 * SEC), 'failed-precondition', STRICT_REFUSAL);
  // Nothing from the client is taken while waiting.
  const drop = await save(uid, id, T0 + 20 * MIN + 40 * SEC, [answer(p2[0], true)]);
  assert.equal(drop.answers.length, 2);
  const second = await look(uid, T0 + 22 * MIN);
  assert.deepEqual(second.parts, {index: 1, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 14 * MIN, waiting: false, endedEarly: false, startsInMs: null});
  assert.equal((await rowOf(uid, id)).parts.startedAt, T0 + 21 * MIN);

  // Part 3 runs from minute 37 to 47 (part 2 ends at 36, then the break).
  await save(uid, id, T0 + 40 * MIN, [answer(p3[0], true)]);
  assert.equal((await rowOf(uid, id)).parts.startedAt, T0 + 37 * MIN);

  // Nobody calls for two days.
  const after = await look(uid, T0 + 2 * DAY);
  assert.equal(after.open, false);
  assert.deepEqual(after.ended, {mockId: id, endedBy: 'time-out', submittedAt: T0 + 47 * MIN, score: {correct: 2, answered: 3, total: 12}});
  const row = await rowOf(uid, id);
  assert.equal(row.status, 'submitted');
  assert.equal(row.submittedAt, T0 + 47 * MIN);
  assert.equal(row.durationMs, TOTAL * MIN);
  assert.deepEqual(row.parts.usedMs, MINUTES.map(m => m * MIN));
  assert.equal(row.pausedAt, null);
  assert.equal(row.pausedMs, 0);
  const totals = fromDoc((await db.doc(`users/${uid}/server/answerTotals`).get()).data());
  assert.equal(totals.answers, 3);
  assert.equal((await db.doc(`users/${uid}/server/answers/items/mock:${id}`).get()).get('finishedAt'), T0 + 47 * MIN);
  // The Free allowance counts from that moment, not from the visit.
  await refused(beginMock(named(uid), {examId}, deps(T0 + 47 * MIN + 30 * DAY - 1)), 'failed-precondition', 'Free accounts can take one mock every 30 days.');
  assert.equal((await beginMock(named(uid), {examId}, deps(T0 + 47 * MIN + 30 * DAY))).resumed, false);
});

test('strict: availability alone ends a mock whose last part ran out, and the cooldown counts from that moment', async () => {
  const uid = 'pt-strict-availability';
  const {examId, id} = await begin(uid, {strict: true});
  const out = await serveMockAvailability(named(uid), {examId}, deps(T0 + 3 * DAY));
  assert.equal(out.status, 'cooldown');
  assert.equal(out.nextEligibleAt, T0 + 47 * MIN + 30 * DAY);
  const row = await rowOf(uid, id);
  assert.equal(row.endedBy, 'time-out');
  assert.equal(row.submittedAt, T0 + 47 * MIN);
});

test('non-strict: a last part that ran out with no client call is ended on the next read as a time-out', async () => {
  const uid = 'pt-last-timeout';
  const {id, out} = await begin(uid);
  await save(uid, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]);
  assert.equal((await look(uid, T0 + 25 * MIN)).parts.waiting, true);
  await act(uid, id, 'startPart', T0 + 26 * MIN);
  assert.equal((await look(uid, T0 + 45 * MIN)).parts.waiting, true);
  await act(uid, id, 'startPart', T0 + 50 * MIN);
  // Part 3 ends at minute 60. Nothing is called for three days.
  const after = await look(uid, T0 + 3 * DAY);
  assert.equal(after.open, false);
  assert.equal(after.ended.endedBy, 'time-out');
  assert.equal(after.ended.submittedAt, T0 + 60 * MIN);
  const row = await rowOf(uid, id);
  assert.equal(row.durationMs, TOTAL * MIN);
  assert.deepEqual(row.parts.usedMs, MINUTES.map(m => m * MIN));
  assert.deepEqual(row.score, {correct: 1, answered: 1, total: 12});
});

test('the between-parts block carries the clock, the paper and the answers', async () => {
  for (const strict of [false, true]) {
    const uid = `pt-block-${strict}`;
    const {id, out} = await begin(uid, {strict});
    await save(uid, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]);
    if (!strict) await act(uid, id, 'endPart', T0 + 5 * MIN);
    const at = strict ? T0 + 20 * MIN + 10 * SEC : T0 + 6 * MIN;
    const view = await look(uid, at);
    assert.deepEqual(keys(view.parts), ['endedEarly', 'index', 'limitsMs', 'remainingMs', 'startsInMs', 'waiting']);
    assert.deepEqual(view.parts, {index: 1, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 15 * MIN, waiting: true, endedEarly: !strict,
      startsInMs: strict ? STRICT_BREAK_MS - 10 * SEC : null});
    assert.equal(view.remainingMs, 25 * MIN);
    assert.deepEqual(view.paper, out.paper);
    assert.equal(view.answers.length, 1);
    assert.deepEqual(keys(view), ['answers', 'examId', 'examName', 'limitMs', 'mockId', 'open', 'paper', 'parts', 'paused', 'remainingMs', 'startedAt', 'strict']);
  }
});

test('startMock on an open by-part mock returns it through the same view, whatever the strict flag says', async () => {
  for (const first of [false, true]) {
    const uid = `pt-restart-${first}`;
    const {examId, out, id} = await begin(uid, {strict: first});
    await save(uid, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]);
    const before = await rowOf(uid, id);
    const again = await beginMock(named(uid), {examId, strict: !first}, deps(T0 + 2 * MIN));
    assert.equal(again.resumed, true);
    assert.equal(again.mockId, id);
    assert.equal(again.strict, first);
    assert.equal(again.parts.remainingMs, 18 * MIN);
    assert.deepEqual(await rowOf(uid, id), before);
    assert.equal((await db.collection(`users/${uid}/server/mocks/items`).get()).size, 1);
  }
});

// ---- what the client can never do ----

test('abuse: repeating startPart never restarts a clock', async () => {
  const uid = 'pt-repeat-start';
  const {id} = await begin(uid);
  await act(uid, id, 'endPart', T0 + 5 * MIN);
  await act(uid, id, 'startPart', T0 + 30 * MIN);
  const first = await rowOf(uid, id);
  assert.equal(first.parts.startedAt, T0 + 30 * MIN);
  for (const at of [T0 + 31 * MIN, T0 + 40 * MIN]) await act(uid, id, 'startPart', at);
  assert.deepEqual(await rowOf(uid, id), first);
  assert.equal((await look(uid, T0 + 40 * MIN)).parts.remainingMs, 5 * MIN);
});

test('abuse: startPart while a part is running changes nothing', async () => {
  const uid = 'pt-start-running';
  const {id} = await begin(uid);
  const before = await rowOf(uid, id);
  const out = await act(uid, id, 'startPart', T0 + 5 * MIN);
  assert.deepEqual(await rowOf(uid, id), before);
  assert.equal(out.parts.remainingMs, 15 * MIN);
});

test('abuse: strict startPart in the break only shortens it, and a repeat changes nothing', async () => {
  const uid = 'pt-strict-start';
  const {id} = await begin(uid, {strict: true});
  await look(uid, T0 + 20 * MIN);
  const started = await act(uid, id, 'startPart', T0 + 20 * MIN + 10 * SEC);
  assert.equal(started.parts.waiting, false);
  assert.equal((await rowOf(uid, id)).parts.startedAt, T0 + 20 * MIN + 10 * SEC);
  const stored = await rowOf(uid, id);
  await act(uid, id, 'startPart', T0 + 20 * MIN + 20 * SEC);
  assert.deepEqual(await rowOf(uid, id), stored);
  assert.equal((await look(uid, T0 + 20 * MIN + 10 * SEC + 15 * MIN)).parts.waiting, true);
});

for (const [label, durationMs] of [['zero', 0], ['one day', DAY], ['one millisecond', 1]]) {
  test(`abuse: a sent duration of ${label} is never stored; the server counts its own time`, async () => {
    const uid = `pt-duration-${durationMs}`;
    const {id, out} = await begin(uid);
    await submit(uid, id, T0 + 7 * MIN, [answer(idsIn(out, 0)[0], true)], {durationMs});
    const row = await rowOf(uid, id);
    assert.equal(row.durationMs, 7 * MIN);
    assert.deepEqual(row.parts.usedMs, [7 * MIN]);
  });
}

test('abuse: a negative or oversized duration is refused and nothing is stored', async () => {
  const uid = 'pt-duration-bad';
  const {id, out} = await begin(uid);
  for (const durationMs of [-1, -DAY, DAY + 1, 'x', null]) {
    await refused(submit(uid, id, T0 + 7 * MIN, [answer(idsIn(out, 0)[0], true)], {durationMs}), 'invalid-argument');
  }
  assert.equal((await rowOf(uid, id)).status, 'started');
});

test('abuse: an answeredAt in the past does not get a late answer accepted', async () => {
  const uid = 'pt-answered-at';
  const {id, out} = await begin(uid);
  const [p1] = [idsIn(out, 0)];
  await look(uid, T0 + 25 * MIN);
  const before = await rowOf(uid, id);
  const sent = await save(uid, id, T0 + 26 * MIN, [answer(p1[0], true, 'a', T0 + MIN), {...answer(p1[1], true, 'a', Date.UTC(2020, 0, 2)), responseMs: 5}]);
  assert.equal(sent.answers.length, 0);
  assert.deepEqual(await rowOf(uid, id), before);
});

test('abuse: a save after the close changes nothing', async () => {
  const uid = 'pt-late-save';
  const {id, out} = await begin(uid);
  await save(uid, id, T0 + 10 * MIN, [answer(idsIn(out, 0)[0], true)]);
  await look(uid, T0 + 21 * MIN);
  const before = await rowOf(uid, id);
  const after = await save(uid, id, T0 + 22 * MIN, [answer(idsIn(out, 0)[0], false, 'b'), answer(idsIn(out, 0)[1], true)]);
  assert.deepEqual(after.answers, before.answers);
  assert.deepEqual(await rowOf(uid, id), before);
});

test('abuse: answering a later part early changes nothing', async () => {
  const uid = 'pt-early-answer';
  const {id, out} = await begin(uid);
  const out1 = await save(uid, id, T0 + 2 * MIN, [answer(idsIn(out, 1)[0], true), answer(idsIn(out, 2)[0], true)]);
  assert.deepEqual(out1.answers, []);
  // A mixed save keeps only the running part's answer.
  const out2 = await save(uid, id, T0 + 3 * MIN, [answer(idsIn(out, 0)[0], true), answer(idsIn(out, 2)[0], true)]);
  assert.deepEqual(out2.answers.map(a => a.questionId), [idsIn(out, 0)[0]]);
  // The same holds on submit.
  await submit(uid, id, T0 + 4 * MIN, [answer(idsIn(out, 0)[0], true), answer(idsIn(out, 1)[0], true), answer(idsIn(out, 2)[0], true)]);
  assert.deepEqual((await rowOf(uid, id)).answers.map(a => a.questionId), [idsIn(out, 0)[0]]);
});

test('abuse: a submit that changes closed-part answers keeps the stored ones', async () => {
  const uid = 'pt-submit-closed';
  const {id, out} = await begin(uid);
  const [p1, p2] = [idsIn(out, 0), idsIn(out, 1)];
  await save(uid, id, T0 + 2 * MIN, [answer(p1[0], true), answer(p1[1], false)]);
  await act(uid, id, 'endPart', T0 + 3 * MIN);
  await act(uid, id, 'startPart', T0 + 4 * MIN);
  await submit(uid, id, T0 + 6 * MIN, [answer(p1[0], false, 'z'), blank(p1[1]), answer(p1[2], true), answer(p2[0], true)]);
  const row = await rowOf(uid, id);
  assert.deepEqual(row.answers.map(a => [a.questionId, a.chosen, a.correct]), [[p1[0], 'a', true], [p1[1], 'a', false], [p2[0], 'a', true]]);
  assert.deepEqual(row.score, {correct: 2, answered: 3, total: 12});
});

test('abuse: a submit while a part waits takes no answers from the client and counts only used time', async () => {
  const uid = 'pt-submit-waiting';
  const {id, out} = await begin(uid);
  await save(uid, id, T0 + 2 * MIN, [answer(idsIn(out, 0)[0], true)]);
  await act(uid, id, 'endPart', T0 + 3 * MIN);
  await submit(uid, id, T0 + 9 * DAY, [answer(idsIn(out, 1)[0], true), answer(idsIn(out, 0)[1], true)], {durationMs: 1});
  const row = await rowOf(uid, id);
  assert.deepEqual(row.answers.map(a => a.questionId), [idsIn(out, 0)[0]]);
  assert.equal(row.durationMs, 3 * MIN);
  assert.equal(row.submittedAt, T0 + 9 * DAY);
});

test('abuse: a different strict flag on a second startMock changes nothing', async () => {
  const uid = 'pt-flag';
  const {examId, id} = await begin(uid);
  const before = await rowOf(uid, id);
  const again = await beginMock(named(uid), {examId, strict: true}, deps(T0 + MIN));
  assert.equal(again.strict, false);
  assert.equal(again.mockId, id);
  assert.deepEqual(await rowOf(uid, id), before);
  await act(uid, id, 'pause', T0 + 2 * MIN);
  assert.equal((await rowOf(uid, id)).pausedAt, T0 + 2 * MIN);
});

test('abuse: strict pause and discard are refused and the clock does not move', async () => {
  const uid = 'pt-strict-refuse';
  const {id, out} = await begin(uid, {strict: true});
  await save(uid, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]);
  const before = await rowOf(uid, id);
  for (const action of ['pause', 'resume', 'discard', 'endPart']) {
    await refused(act(uid, id, action, T0 + 2 * MIN), 'failed-precondition', STRICT_REFUSAL);
  }
  assert.deepEqual(await rowOf(uid, id), before);
  assert.equal((await look(uid, T0 + 5 * MIN)).parts.remainingMs, 15 * MIN);
});

test('abuse: pausing while a strict part waits is refused', async () => {
  const uid = 'pt-strict-wait-pause';
  const {id} = await begin(uid, {strict: true});
  await look(uid, T0 + 20 * MIN);
  const before = await rowOf(uid, id);
  await refused(act(uid, id, 'pause', T0 + 20 * MIN + 5 * SEC), 'failed-precondition', STRICT_REFUSAL);
  assert.deepEqual(await rowOf(uid, id), before);
  assert.equal((await look(uid, T0 + 20 * MIN + 20 * SEC)).parts.startsInMs, STRICT_BREAK_MS - 20 * SEC);
});

test('abuse: a strict row holding a pause somehow ignores it', async () => {
  const uid = 'pt-strict-stale-pause';
  const {id} = await begin(uid, {strict: true});
  await db.doc(mockPath(uid, id)).update({pausedAt: T0 + MIN, pausedMs: 10 * MIN});
  const out = await look(uid, T0 + 20 * MIN);
  assert.equal(out.parts.waiting, true);
  assert.equal(out.paused, false);
  assert.equal((await rowOf(uid, id)).parts.waitingSince, T0 + 20 * MIN);
});

test('abuse: resume with no pause changes nothing, and pause while waiting changes nothing', async () => {
  const uid = 'pt-resume-none';
  const {id} = await begin(uid);
  const before = await rowOf(uid, id);
  await act(uid, id, 'resume', T0 + 5 * MIN);
  assert.deepEqual(await rowOf(uid, id), before);
  await act(uid, id, 'endPart', T0 + 6 * MIN);
  const waiting = await rowOf(uid, id);
  const out = await act(uid, id, 'pause', T0 + 7 * MIN);
  assert.equal(out.paused, false);
  assert.deepEqual(await rowOf(uid, id), waiting);
  await act(uid, id, 'resume', T0 + 8 * MIN);
  assert.deepEqual(await rowOf(uid, id), waiting);
});

test('abuse: endPart is refused while waiting and on the last part, and a paused part can be ended', async () => {
  const uid = 'pt-endpart';
  const {id} = await begin(uid);
  await act(uid, id, 'pause', T0 + 4 * MIN);
  const ended = await act(uid, id, 'endPart', T0 + 60 * MIN);
  assert.equal(ended.paused, false);
  const row = await rowOf(uid, id);
  assert.deepEqual(row.parts.usedMs, [4 * MIN]);
  assert.equal(row.pausedAt, null);
  assert.equal(row.pausedMs, 0);
  await refused(act(uid, id, 'endPart', T0 + 61 * MIN), 'failed-precondition', 'No part is running.');
  await act(uid, id, 'startPart', T0 + 62 * MIN);
  await act(uid, id, 'endPart', T0 + 63 * MIN);
  await act(uid, id, 'startPart', T0 + 64 * MIN);
  const before = await rowOf(uid, id);
  await refused(act(uid, id, 'endPart', T0 + 65 * MIN), 'failed-precondition', 'This is the last part. Submit the mock instead.');
  assert.deepEqual(await rowOf(uid, id), before);
});

test('abuse: no time field from the client reaches the clock', async () => {
  const junk = {now: 1, clientNow: 5, serverNow: 9, startedAt: 7, elapsedMs: 0, usedMs: [0, 0], index: 2, pausedAt: 0, pausedMs: -5,
    remainingMs: 1e12, limitMs: 1e12, parts: {index: 2, startedAt: 1, usedMs: [0, 0]}, waitingSince: 0, endedEarly: false};
  const run = async (uid, extra, answeredAt, durationMs) => {
    const {id, out} = await begin(uid);
    const [p1, p2] = [0, 1].map(i => idsIn(out, i));
    await changeMock(named(uid), {mockId: id, action: 'save', answers: [{...answer(p1[0], true, 'a', answeredAt), responseMs: 7}], ...extra}, deps(T0 + 2 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'save', answers: [answer(p1[1], false, 'a', answeredAt)], ...extra}, deps(T0 + 3 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'pause', ...extra}, deps(T0 + 4 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'resume', ...extra}, deps(T0 + 9 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'endPart', ...extra}, deps(T0 + 10 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'startPart', ...extra}, deps(T0 + 11 * MIN));
    await changeMock(named(uid), {mockId: id, action: 'save', answers: [answer(p2[0], true, 'a', answeredAt)], ...extra}, deps(T0 + 12 * MIN));
    const mid = await rowOf(uid, id);
    await recordMock(named(uid), {mockId: id, answers: [answer(p2[0], true, 'a', answeredAt), blank(p2[1])], durationMs, ...extra}, deps(T0 + 15 * MIN));
    const row = await rowOf(uid, id);
    return {mid: clockOf(mid), parts: row.parts, durationMs: row.durationMs, submittedAt: row.submittedAt, score: row.score,
      answers: row.answers.map(a => [a.questionId.slice(0, 2), a.chosen, a.correct])};
  };
  const clean = await run('pt-junk-clean', {}, T0, 123456);
  const rigged = await run('pt-junk-rigged', junk, Date.UTC(2020, 0, 2), DAY);
  assert.deepEqual(rigged, clean);
  // Part 1 used 10 minutes less a 5 minute pause, part 2 used the 4 minutes from its start to the submit.
  assert.equal(clean.durationMs, 9 * MIN);
});

test('abuse: a blueprint saved mid-mock does not change the open mock', async () => {
  const uid = 'pt-blueprint', examId = newId();
  await reset(uid);
  await saveTrack(uid, examId, blueprint());
  const out = await beginMock(named(uid), {examId}, deps(T0));
  const before = await rowOf(uid, out.mockId);
  await saveTrack(uid, examId, blueprint([5, 5, 5], {updatedAt: T0 + MIN}), T0 + 2 * MIN);
  await saveTrack(uid, examId, blueprint([30, 30], {sectionsTimedSeparately: false, totalMinutes: 400, updatedAt: T0 + 2 * MIN}), T0 + 3 * MIN);
  const view = await look(uid, T0 + 10 * MIN);
  assert.equal(view.limitMs, TOTAL * MIN);
  assert.deepEqual(view.parts.limitsMs, MINUTES.map(m => m * MIN));
  assert.equal(view.parts.remainingMs, 10 * MIN);
  assert.deepEqual((await rowOf(uid, out.mockId)).parts.limitsMs, before.parts.limitsMs);
  assert.deepEqual((await rowOf(uid, out.mockId)).paper, before.paper);
});

test('abuse: a track deleted mid-mock does not stop the mock', async () => {
  const uid = 'pt-deleted';
  const {examId, id, out} = await begin(uid);
  await removeCustomTrack(named(uid), {expectedUid: uid, examId}, deps(T0 + MIN));
  assert.equal((await db.doc(`users/${uid}/server/customTracks/items/${examId}`).get()).exists, false);
  await save(uid, id, T0 + 2 * MIN, [answer(idsIn(out, 0)[0], true)]);
  await act(uid, id, 'endPart', T0 + 3 * MIN);
  const view = await look(uid, T0 + 4 * MIN);
  assert.equal(view.open, true);
  assert.equal(view.examName, 'Own exam');
  await submit(uid, id, T0 + 5 * MIN, [answer(idsIn(out, 1)[0], true)]);
  assert.equal((await rowOf(uid, id)).status, 'submitted');
  assert.equal((await serveMockResults(named(uid), {mockId: id}, deps(T0 + 6 * MIN))).examName, 'Own exam');
});

test('abuse: calls at the same moment leave a consistent row', async () => {
  // A part waiting: two starts and an end race. Only starts can win.
  const waitingUid = 'pt-race-waiting';
  const a = await begin(waitingUid);
  await act(waitingUid, a.id, 'endPart', T0 + 2 * MIN);
  const raced = await Promise.allSettled([act(waitingUid, a.id, 'startPart', T0 + 5 * MIN), act(waitingUid, a.id, 'startPart', T0 + 5 * MIN),
    act(waitingUid, a.id, 'endPart', T0 + 5 * MIN)]);
  assert.deepEqual(raced.slice(0, 2).map(r => r.status), ['fulfilled', 'fulfilled']);
  let row = await rowOf(waitingUid, a.id);
  assert.equal(row.status, 'started');
  assert.equal(row.parts.usedMs.length, row.parts.index);
  assert.equal((row.parts.startedAt === null) !== (row.parts.waitingSince === null), true);
  assert.equal(row.parts.usedMs[0], 2 * MIN);
  if (raced[2].status === 'rejected') {
    // The end came first and found nothing running; the starts then ran.
    assert.equal(row.parts.index, 1);
    assert.equal(row.parts.startedAt, T0 + 5 * MIN);
  } else {
    // The end came after a start and closed part 2 at once, with nothing used.
    assert.equal(row.parts.index, 2);
    assert.deepEqual(row.parts.usedMs, [2 * MIN, 0]);
    assert.equal(row.parts.waitingSince, T0 + 5 * MIN);
  }

  // A part running: two ends and a start race. At most one end closes part 1, and the clock is whole either way.
  const runningUid = 'pt-race-running';
  const b = await begin(runningUid);
  const both = await Promise.allSettled([act(runningUid, b.id, 'endPart', T0 + 7 * MIN), act(runningUid, b.id, 'endPart', T0 + 7 * MIN),
    act(runningUid, b.id, 'startPart', T0 + 7 * MIN)]);
  assert.ok(both.filter(r => r.status === 'fulfilled').length >= 2);
  row = await rowOf(runningUid, b.id);
  assert.equal(row.status, 'started');
  assert.equal(row.parts.usedMs.length, row.parts.index);
  assert.equal(row.parts.usedMs[0], 7 * MIN);
  if (row.parts.index === 2) assert.equal(row.parts.usedMs[1], 0);
  assert.ok(row.parts.index === 1 || row.parts.index === 2);
  assert.equal((row.parts.startedAt === null) !== (row.parts.waitingSince === null), true);
});

// ---- a request that waited is stamped at the clock's own time, never before its last event ----

test('a held pause with a stale time cannot pause before part 2 started, so it adds no time to it', async () => {
  const uid = 'pt-stale-pause';
  const {id} = await begin(uid);
  const t10 = T0 + 10 * SEC;
  let held = false;
  // The hook runs after the call read its time and before its transaction: part 1 ends and part 2 starts meanwhile.
  const slow = {...deps(t10), now: () => t10, allow: async () => {
    if (!held) {
      held = true;
      await act(uid, id, 'endPart', T0 + 20 * SEC);
      await act(uid, id, 'startPart', T0 + 30 * SEC);
    }
    return true;
  }};
  const paused = await changeMock(named(uid), {mockId: id, action: 'pause'}, slow);
  assert.equal(held, true);
  assert.equal(paused.paused, true);
  assert.equal((await rowOf(uid, id)).pausedAt, T0 + 30 * SEC);
  const resumed = await act(uid, id, 'resume', T0 + 40 * SEC);
  assert.equal(resumed.paused, false);
  const row = await rowOf(uid, id);
  assert.equal(row.parts.startedAt, T0 + 30 * SEC);
  const truePause = 10 * SEC;
  assert.ok(row.pausedMs <= truePause, `pausedMs ${row.pausedMs}`);
  assert.ok(row.parts.startedAt + row.pausedMs + MINUTES[1] * MIN <= row.parts.startedAt + MINUTES[1] * MIN + truePause);
  assert.equal(resumed.parts.remainingMs, MINUTES[1] * MIN - (T0 + 40 * SEC - (T0 + 30 * SEC)) + row.pausedMs);
});

test('a held submit with a stale time is stamped after the answer it includes, and counts the time the server counts', async () => {
  const uid = 'pt-stale-submit';
  const {id, out} = await begin(uid, {strict: true, minutes: [1, 1]});
  const p2 = idsIn(out, 1);
  const live = {value: T0 + 10 * SEC};
  let reads = 0, held = false;
  // The first read of the clock is old, every later one is current.
  const slow = {...deps(), now: () => (reads++ === 0 ? T0 + 10 * SEC : live.value), allow: async () => {
    if (!held) {
      held = true;
      await act(uid, id, 'startPart', T0 + MIN);
      await save(uid, id, T0 + MIN + 10 * SEC, [answer(p2[0], true, 'a', T0 + MIN + 10 * SEC)]);
      live.value = T0 + MIN + 20 * SEC;
    }
    return true;
  }};
  const done = await recordMock(named(uid), {mockId: id, answers: [answer(p2[0], true, 'a', T0 + MIN + 10 * SEC)], durationMs: 1}, slow);
  assert.equal(done.status, 'submitted');
  const row = await rowOf(uid, id);
  assert.equal(row.endedBy, 'student');
  assert.ok(row.submittedAt >= T0 + MIN + 10 * SEC, 'not before the answer it holds');
  assert.equal(row.submittedAt, T0 + MIN + 20 * SEC);
  assert.equal(row.durationMs, MIN + 20 * SEC, 'part 1 in full, plus what part 2 used until then');
  assert.deepEqual(row.answers.map(a => a.questionId), [p2[0]]);
  const session = (await db.doc(`users/${uid}/server/answers/items/mock:${id}`).get()).data();
  assert.equal(session.finishedAt, row.submittedAt);
  assert.equal(session.durationMs, row.durationMs);
  assert.ok(session.finishedAt >= session.answers[0].answeredAt);
});

test('a change that finds the time already up submits the mock at that exact moment, then reports it finished', async () => {
  const uid = 'pt-late-finish';
  const {id, out} = await begin(uid, {strict: true});
  const p1 = idsIn(out, 0);
  await save(uid, id, T0 + MIN, [answer(p1[0], true, 'a', T0 + MIN)]);
  const live = {value: T0 + 10 * SEC};
  let reads = 0, held = false;
  // The call read an early time. While it waits, two days pass, so its own transaction finds the paper over.
  const slow = {...deps(), now: () => (reads++ === 0 ? T0 + 10 * SEC : live.value), allow: async () => {
    if (!held) { held = true; live.value = T0 + 2 * DAY; }
    return true;
  }};
  await refused(changeMock(named(uid), {mockId: id, action: 'save', answers: [answer(p1[1], false, 'a', T0 + 2 * MIN)]}, slow), 'failed-precondition', 'This mock is already finished.');
  assert.equal(held, true);
  const row = await rowOf(uid, id);
  assert.equal(row.status, 'submitted');
  assert.equal(row.endedBy, 'time-out');
  assert.equal(row.submittedAt, T0 + 47 * MIN);
  assert.equal(row.durationMs, TOTAL * MIN);
  assert.deepEqual(row.answers.map(a => a.questionId), [p1[0]], 'the refused save took nothing');
  const session = (await db.doc(`users/${uid}/server/answers/items/mock:${id}`).get()).data();
  assert.equal(session.finishedAt, T0 + 47 * MIN);
  assert.equal(session.answerCount, 1);
  assert.equal(fromDoc((await db.doc(`users/${uid}/server/answerTotals`).get()).data()).answers, 1);
  assert.deepEqual(await look(uid, T0 + 2 * DAY), {open: false});
});

test('abuse: another account sees no by-part mock', async () => {
  const owner = 'pt-owner', stranger = 'pt-stranger';
  await reset(stranger);
  const {id, out} = await begin(owner);
  // The new actions answer the same for another account's id and for no mock at all, so they reveal nothing.
  await refused(act(stranger, id, 'startPart', T0 + MIN), 'invalid-argument', 'Unknown action.');
  await refused(act(stranger, id, 'endPart', T0 + MIN), 'invalid-argument', 'Unknown action.');
  await refused(act(stranger, id, 'save', T0 + MIN, {answers: [answer(idsIn(out, 0)[0], true)]}), 'not-found');
  await refused(submit(stranger, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]), 'not-found');
  assert.deepEqual(await look(stranger, T0 + MIN), {open: false});
  assert.equal((await rowOf(owner, id)).status, 'started');
});

// ---- discard, and papers that are not by-part ----

test('non-strict discard goes back to part 0, with the answers gone and the same paper', async () => {
  const uid = 'pt-discard';
  const {id, out} = await begin(uid);
  await save(uid, id, T0 + MIN, [answer(idsIn(out, 0)[0], true)]);
  await act(uid, id, 'endPart', T0 + 5 * MIN);
  await act(uid, id, 'startPart', T0 + 6 * MIN);
  await act(uid, id, 'pause', T0 + 8 * MIN);
  const view = await act(uid, id, 'discard', T0 + 30 * MIN);
  assert.deepEqual(view.answers, []);
  assert.deepEqual(view.paper, out.paper);
  assert.deepEqual(view.parts, {index: 0, limitsMs: MINUTES.map(m => m * MIN), remainingMs: 20 * MIN, waiting: false, endedEarly: false, startsInMs: null});
  assert.equal(view.paused, false);
  assert.equal(view.remainingMs, TOTAL * MIN);
  const row = await rowOf(uid, id);
  assert.deepEqual(row.parts, {limitsMs: MINUTES.map(m => m * MIN), index: 0, startedAt: T0 + 30 * MIN, waitingSince: null, endedEarly: false, usedMs: []});
  assert.equal(row.startedAt, T0 + 30 * MIN);
  assert.equal(row.pausedAt, null);
  assert.equal(row.pausedMs, 0);
  assert.equal(row.limitMs, TOTAL * MIN);
  // Discard also works while a part waits.
  await look(uid, T0 + 55 * MIN);
  const again = await act(uid, id, 'discard', T0 + 100 * MIN);
  assert.equal(again.parts.index, 0);
  assert.equal(again.parts.waiting, false);
});

test('a one-clock paper has no parts key anywhere: a one-section timed paper and a two-section paper not timed apart', async () => {
  for (const [uid, opts] of [['pt-one-section', {minutes: [30], timed: true}], ['pt-two-one-clock', {minutes: [20, 15], timed: false}]]) {
    await reset(uid);
    const examId = await directTrack(uid, opts);
    const out = await beginMock(named(uid), {examId}, deps(T0));
    assert.equal('parts' in out, false, uid);
    assert.deepEqual(keys(out), ['answers', 'examId', 'examName', 'limitMs', 'mockId', 'paper', 'paused', 'remainingMs', 'resumed', 'startedAt', 'strict']);
    assert.equal(out.limitMs, opts.minutes.reduce((a, b) => a + b, 0) * MIN);
    assert.equal('parts' in await rowOf(uid, out.mockId), false);
    assert.equal('parts' in await look(uid, T0 + MIN), false);
    assert.equal('parts' in await act(uid, out.mockId, 'pause', T0 + 2 * MIN), false);
    assert.equal('parts' in await act(uid, out.mockId, 'resume', T0 + 3 * MIN), false);
    for (const action of ['startPart', 'endPart']) {
      await refused(act(uid, out.mockId, action, T0 + 4 * MIN), 'invalid-argument', 'Unknown action.');
    }
    assert.equal('parts' in await rowOf(uid, out.mockId), false);
    // Today's logic: not strict, so the server never ends it however late.
    const late = await look(uid, T0 + 9 * DAY);
    assert.equal(late.open, true);
    assert.equal(late.remainingMs, 0);
  }
});

test('a by-part row is read by the results reader as any other', async () => {
  const uid = 'pt-reader';
  const {id, out, examId} = await begin(uid);
  await submit(uid, id, T0 + 3 * MIN, [answer(idsIn(out, 0)[0], true)]);
  const results = await serveMockResults(named(uid), {mockId: id}, deps(T0 + 4 * MIN));
  assert.deepEqual(keys(results), ['accessRecheckAt', 'answers', 'canReview', 'durationMs', 'endedBy', 'examId', 'examName', 'limitMs', 'mockId', 'paper', 'proCovered', 'reviewUntil', 'score', 'sections', 'serverNow', 'startedAt', 'strict', 'submittedAt']);
  assert.equal(results.durationMs, 3 * MIN);
  const availability = await serveMockAvailability(named(uid), {examId}, deps(T0 + 5 * MIN));
  assert.equal(availability.status, 'cooldown');
  assert.equal(availability.lastMockId, id);
});
