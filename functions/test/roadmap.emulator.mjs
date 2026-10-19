import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {saveExamSettings, serveRoadmap} from '../lib/roadmap.js';
import {recordSession} from '../lib/ingestSession.js';
import {blueprintItem, lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const DAY = 86400000;
const NOW = Date.parse('2026-11-20T10:00:00+08:00');
const named = (uid, claims = {}) => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, ...claims}});
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const pro = uid => named(uid, {pro: true, proUntil: NOW + 60 * DAY});
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const d = (at = NOW, extra = {}) => ({db, now: () => at, allow: async () => true, ...extra});
const EXAM = 'exam_dost_sei';
const settings = (extra = {}) => ({examId: EXAM, examDate: {precision: 'day', day: '2027-02-15'}, studyDays: [1, 2, 3, 4, 5, 6, 7], assessmentCompleted: true, ...extra});

const set = (topic, letter) => questionSetItems({
  meta: {subject: 's', topic, exams: ['dost-sei']},
  questions: Array.from({length: 12}, (_, i) => ({id: `${letter}${i}`, stem: 'x', choices: [{text: 'a', correct: true}, {text: 'b'}]})),
}, `rm/${topic}/u.yaml`).item;
const lessons = ['ta', 'tb'].flatMap(topic => [1, 2, 3].map(n => lessonItem({_id: `lesson-rm-${topic}-${n}`, title: 'T', subject: 's', topic: `topic-${topic}`}, 'body')));
const blueprint = blueprintItem({exam: EXAM, name: 'P', durationMinutes: 60, sections: [{id: 's1', name: 'One', questionCount: 4, suggestedMinutes: 60,
  topicIds: ['topic_dost_sei_ta'], topicWeights: {topic_dost_sei_ta: 1}}]});
const batch = (id, ids, at = NOW) => ({sessionId: id, startedAt: at - 60000, finishedAt: at, durationMs: 60000,
  answers: ids.map(questionId => ({questionId, chosen: 'a', correct: true, answeredAt: at - 1000}))});
const stored = async uid => {
  const snapshot = await db.doc(`users/${uid}/server/roadmap`).get();
  return snapshot.exists ? {...snapshot.data(), roadmap: JSON.parse(snapshot.get('roadmapJson'))} : null;
};

test('seed content', async () => {
  await writeContent(db, [set('ta', 'a'), set('tb', 'b'), ...lessons, blueprint], [], {});
  clearExamContentCache();
});

test('saving exam settings validates the shape and stores it server-only', async () => {
  const uid = 'r-settings';
  await reset(uid);
  assert.equal(await code(saveExamSettings(undefined, settings(), d())), 'unauthenticated');
  for (const bad of [{}, settings({examId: 'exam_nope'}), settings({studyDays: []}), settings({studyDays: [0, 8]}),
    settings({examDate: {precision: 'day', day: '2027-13-40'}}), settings({examDate: {precision: 'month', year: 2027, month: 13}}),
    settings({examDate: 'tomorrow'}), settings({assessmentCompleted: 'yes'})]) {
    assert.equal(await code(saveExamSettings(named(uid), bad, d())), 'invalid-argument', JSON.stringify(bad));
  }
  assert.equal(await code(saveExamSettings(named(uid), settings({examDate: null}), d())), 'ok');
  assert.equal(await code(saveExamSettings(named(uid), settings({examDate: {precision: 'month', year: 2027, month: 3}}), d())), 'ok');
  assert.equal(await code(saveExamSettings(anon(uid), settings(), d())), 'ok');
  const row = (await db.doc(`users/${uid}/server/settings`).get()).data();
  assert.equal(row.examId, EXAM);
  assert.deepEqual(row.studyDays, [1, 2, 3, 4, 5, 6, 7]);
});

test('without settings there is no roadmap to serve', async () => {
  const uid = 'r-none';
  await reset(uid);
  const out = await serveRoadmap(named(uid), {}, d());
  assert.deepEqual(out, {tier: 'free', state: 'noSettings'});
});

test('storing a session recomputes the roadmap from stored answers, using the Philippine calendar day', async () => {
  const uid = 'r-ingest';
  await reset(uid);
  await saveExamSettings(anon(uid), settings(), d());
  const first = await stored(uid);
  assert.equal(first.roadmap.state, 'planning');
  assert.equal(first.roadmap.today.day, '2026-11-20');
  assert.deepEqual(first.roadmap.today.newQuestionIds, ['a0']);
  const lateUtc = Date.parse('2026-11-20T23:30:00Z');   // 07:30 on 21 November in the Philippines
  const out = await recordSession(anon(uid), batch('sess-r-0001', ['a0', 'a1', 'a2', 'b0'], lateUtc), d(lateUtc));
  assert.equal(out.stored, true);
  const after = await stored(uid);
  assert.equal(after.roadmap.today.day, '2026-11-21');
  assert.equal(after.answerSessions, 1);
  assert.ok(after.computedAt >= lateUtc);
  // Questions the student already answered are not offered as new.
  const offered = [...after.roadmap.today.newQuestionIds, ...after.roadmap.today.reviewQuestionIds];
  assert.ok(offered.length > 0);
  for (const id of ['a0', 'a1', 'a2', 'b0']) assert.equal(offered.includes(id), false, id);
  // A replay stores nothing new and changes nothing.
  const replay = await recordSession(anon(uid), batch('sess-r-0001', ['a3']), d(lateUtc + 1000));
  assert.equal(replay.stored, false);
  assert.equal((await stored(uid)).computedAt, after.computedAt);
});

test('a Free account gets Today only; a Pro account also gets Coming up and History', async () => {
  const uid = 'r-tier';
  await reset(uid);
  await saveExamSettings(named(uid), settings(), d());
  const free = await serveRoadmap(named(uid), {}, d());
  assert.equal(free.tier, 'free');
  assert.equal(free.state, 'planning');
  assert.equal(free.today.day, '2026-11-20');
  assert.deepEqual(Object.keys(free).sort(), ['backlogCapped', 'state', 'tier', 'today']);
  const text = JSON.stringify(free);
  for (const key of ['weeksAhead', 'changes', 'mockDay', 'topicOrder', 'reviewOnlyFrom', 'examDay', 'comingUp', 'history']) {
    assert.equal(text.includes(`"${key}"`), false, key);
  }
  const live = await serveRoadmap(pro(uid), {}, d());
  assert.equal(live.tier, 'pro');
  assert.deepEqual(live.today, free.today);
  assert.ok(Array.isArray(live.comingUp.weeksAhead) && live.comingUp.weeksAhead.length > 0);
  assert.equal(live.comingUp.examDay, '2027-02-15');
  assert.ok(Array.isArray(live.history.changes));
  // An expired Pro claim is Free.
  const expired = await serveRoadmap(named(uid, {pro: true, proUntil: NOW - 1}), {}, d());
  assert.equal(expired.tier, 'free');
  assert.equal('comingUp' in expired, false);
});

test('serving on a later Philippine day recomputes instead of returning yesterday', async () => {
  const uid = 'r-stale';
  await reset(uid);
  await saveExamSettings(named(uid), settings(), d());
  const next = await serveRoadmap(named(uid), {}, d(NOW + 2 * DAY));
  assert.equal(next.today.day, '2026-11-22');
  assert.equal((await stored(uid)).roadmap.today.day, '2026-11-22');
});

test('serving refuses signed-out callers and honours the rate limit', async () => {
  assert.equal(await code(serveRoadmap(undefined, {}, d())), 'unauthenticated');
  assert.equal(await code(serveRoadmap(named('r-lim'), {}, d(NOW, {allow: async () => false}))), 'resource-exhausted');
});
