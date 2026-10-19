import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {build, saveExamSettings, serveRoadmap} from '../lib/roadmap.js';
import {recordSession} from '../lib/ingestSession.js';
import {blueprintItem, lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {phDay} from '../lib/_phDate.js';

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

// Running totals. The reference is the full scan that build() used before totals existed.
const legacyView = (db2, uid, counter) => async topicOf => {
  const answers = [];
  let sessions = 0;
  const snapshot = await db2.collection(`users/${uid}/server/answers/items`).select('answers').get();
  if (counter) counter.n += snapshot.size;
  for (const doc of snapshot.docs) {
    sessions += 1;
    answers.push(...doc.get('answers'));
  }
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
  return {scores, seenQuestionIds: [...new Set(scoped.map(a => a.questionId))].sort(), answeredPerActiveDay: [...perDay.values()],
    anyAnswers: answers.length > 0, sessions};
};
const totalsDoc = uid => db.doc(`users/${uid}/server/answerTotals`);
const sameRoadmap = async (uid, at, proTier = false, label = '') => {
  const settingsRow = (await db.doc(`users/${uid}/server/settings`).get()).data();
  const viaScan = await build(db, uid, settingsRow, proTier, at, legacyView(db, uid));
  const viaTotals = await build(db, uid, settingsRow, proTier, at);
  assert.deepEqual(viaTotals, viaScan, label);
  return viaTotals;
};
const day = n => NOW + n * DAY;

test('totals: the roadmap from running totals equals the full scan over days, replays and a content change', async () => {
  const uid = 'r-totals';
  await reset(uid);
  await saveExamSettings(anon(uid), settings({assessmentCompleted: undefined}), d());
  assert.equal((await totalsDoc(uid).get()).exists, true, 'settings save builds an empty totals document');
  await sameRoadmap(uid, NOW, false, 'no sessions');
  await recordSession(anon(uid), batch('sess-t-0001', ['a0', 'a1', 'b0'], day(0)), d(day(0)));
  await recordSession(anon(uid), {...batch('sess-t-0002', ['a1', 'a2', 'a2'], day(1)), answers: [
    {questionId: 'a1', chosen: 'b', correct: false, answeredAt: day(1) - 1}, {questionId: 'a2', chosen: 'a', correct: true, answeredAt: day(1) - 2},
    {questionId: 'ghost', chosen: 'a', correct: true, answeredAt: day(1) - 3}]}, d(day(1)));
  await recordSession(anon(uid), batch('sess-t-0003', ['b1', 'b2', 'b3', 'a5'], day(3)), d(day(3)));
  const before = (await totalsDoc(uid).get()).data();
  assert.equal(before.sessions, 3);
  const replay = await recordSession(anon(uid), batch('sess-t-0002', ['a9', 'a9', 'a9'], day(4)), d(day(4)));
  assert.equal(replay.stored, false);
  assert.deepEqual((await totalsDoc(uid).get()).data(), before, 'a replay changes no total');
  const full = await sameRoadmap(uid, day(4), true, 'three sessions');
  assert.equal(full.sessions, 3);
  // Content change: question a1 leaves the exam. Scores, seen ids and day counts must follow.
  const trimmed = questionSetItems({meta: {subject: 's', topic: 'ta', exams: ['dost-sei']},
    questions: Array.from({length: 12}, (_, i) => ({id: `a${i}`, stem: 'x', choices: [{text: 'a', correct: true}, {text: 'b'}]})).filter(q => q.id !== 'a1')}, 'rm/ta/u.yaml').item;
  try {
    await writeContent(db, [trimmed], [], {});
    clearExamContentCache();
    await sameRoadmap(uid, day(4), true, 'question a1 removed');
  } finally {
    await writeContent(db, [set('ta', 'a')], [], {});
    clearExamContentCache();
  }
  await sameRoadmap(uid, day(4), false, 'content restored');
});

test('totals: a rebuild reads one totals document and no session documents', async () => {
  const uid = 'r-reads';
  await reset(uid);
  await saveExamSettings(anon(uid), settings(), d());
  for (let n = 0; n < 5; n += 1) await recordSession(anon(uid), batch(`sess-rd-000${n}`, [`a${n}`, `b${n}`], day(n)), d(day(n)));
  const settingsRow = (await db.doc(`users/${uid}/server/settings`).get()).data();
  const counter = {n: 0};
  await build(db, uid, settingsRow, false, day(5), legacyView(db, uid, counter));
  const scanReads = counter.n;
  let totalsReads = 0;
  let itemReads = 0;
  const counting = new Proxy(db, {get(target, prop) {
    const value = target[prop];
    if (prop === 'doc') return path => {
      const ref = target.doc(path);
      return path.endsWith('/server/answerTotals') ? new Proxy(ref, {get: (r, p) => p === 'get' ? async () => {totalsReads += 1; return r.get();} : typeof r[p] === 'function' ? r[p].bind(r) : r[p]}) : ref;
    };
    if (prop === 'collection') return path => {
      const ref = target.collection(path);
      return path.endsWith('/server/answers/items') ? new Proxy(ref, {get: (r, p) => p === 'select' || p === 'get' ? () => {itemReads += 1; return r[p]();} : typeof r[p] === 'function' ? r[p].bind(r) : r[p]}) : ref;
    };
    return typeof value === 'function' ? value.bind(target) : value;
  }});
  await build(counting, uid, settingsRow, false, day(5));
  console.log(`answer reads per rebuild with 5 sessions: scan ${scanReads}, totals ${totalsReads} (item collection reads: ${itemReads})`);
  assert.equal(scanReads, 5);
  assert.equal(totalsReads, 1);
  assert.equal(itemReads, 0);
});

test('totals: an account from before this change is backfilled once, by a rebuild or by its next session', async () => {
  for (const via of ['rebuild', 'session']) {
    const uid = `r-backfill-${via}`;
    await reset(uid);
    await db.doc(`users/${uid}/server/settings`).set({examId: EXAM, examDate: {precision: 'day', day: '2027-02-15'}, studyDays: [1, 2, 3, 4, 5, 6, 7], updatedAt: NOW});
    await db.doc(`users/${uid}/server/answers/items/sess-old-0001`).set({sessionId: 'sess-old-0001', answers: batch('x', ['a0', 'a1', 'zz'], day(0)).answers});
    await db.doc(`users/${uid}/server/answers/items/sess-old-0002`).set({sessionId: 'sess-old-0002', answers: batch('x', ['b0', 'a1'], day(2)).answers});
    assert.equal((await totalsDoc(uid).get()).exists, false);
    if (via === 'rebuild') {
      const out = await serveRoadmap(named(uid), {}, d(day(3)));
      assert.equal(out.state, 'planning');
      assert.equal((await totalsDoc(uid).get()).get('sessions'), 2);
    } else {
      assert.equal((await recordSession(anon(uid), batch('sess-new-0003', ['a2'], day(3)), d(day(3)))).stored, true);
      assert.equal((await totalsDoc(uid).get()).get('sessions'), 3);
      assert.equal((await totalsDoc(uid).get()).get('answers'), 6);
    }
    await sameRoadmap(uid, day(3), true, via);
    assert.equal((await stored(uid)).answerSessions, via === 'rebuild' ? 2 : 3);
  }
});
