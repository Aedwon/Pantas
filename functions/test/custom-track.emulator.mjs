import '../lib/index.js';
import {readFileSync} from 'node:fs';
const TIERS = JSON.parse(readFileSync(new URL('../../content/exams/custom_subject_tiers.json', import.meta.url), 'utf8'));
/** Topic ids that make a custom exam Civil Service while any is kept. Excluding them all makes it Student. */
const GENERAL_INFORMATION = TIERS.subjects.find(s => s.name === 'General Information').topicIds;
// The fixture corpus uses made-up topic ids. A kept topic the table does not know prices at the top tier, so
// the fixture places its topics at Student, the same module instance the functions read.
import {customSubjectTiers} from '../lib/_customTrack.js';
for (const id of ['topic_alpha', 'topic_beta', 'topic_empty']) customSubjectTiers.topicTiers[id] = 'Student';
import assert from 'node:assert/strict';
import test from 'node:test';
import {randomUUID} from 'node:crypto';
import {getFirestore} from 'firebase-admin/firestore';
import {saveExamSettings, readStudyRoadmap, advanceStudyRoadmap, readStudyDay, readStudyWeek} from '../lib/roadmap.js';
import {readCustomTracks, removeCustomTrack} from '../lib/customTracks.js';
import {addSession, emptyTotals, fromDoc, toDoc} from '../lib/_answerTotals.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {recordSession} from '../lib/ingestSession.js';
import {readStudyInsights} from '../lib/studyInsights.js';
import {readSessionDiagnosis} from '../lib/sessionDiagnosis.js';
import {readCarryableCount} from '../lib/carryableCount.js';
import {beginMock, recordMock} from '../lib/mock.js';
import {serveMockAvailability, serveMockHistory, serveMockResults} from '../lib/mockReader.js';
import {blueprintItem, questionSetItems, writeContent} from '../lib/contentUpload.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const DAY = 86_400_000;
const NOW = Date.parse('2026-10-24T10:00:00+08:00');
const named = (uid, claims = {}) => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, ...claims}});
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const deps = (at = NOW) => ({db, now: () => at, allow: async () => true});
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const refused = async (promise, expectedCode, message) => {
  await assert.rejects(promise, e => e.code === expectedCode && (message === undefined || e.message === message));
};
const newId = () => `exam_custom_${randomUUID()}`;
const body = (uid, examId, extra = {}) => ({expectedUid: uid, examId, ...extra});
const trackPath = (uid, examId) => `users/${uid}/server/customTracks/items/${examId}`;
const track = async (uid, examId) => (await db.doc(trackPath(uid, examId)).get()).data();
const settingsOf = async uid => (await db.doc(`users/${uid}/server/settings`).get()).data();
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));

// ---- a small whole corpus: two exams' catalogs, one set shared by both, one lessonless-and-setless topic ----
const questions = (prefix, count) => Array.from({length: count}, (_, i) => ({id: `${prefix}-${i}`}));
const lessons = (topic, prefix) => Array.from({length: 6}, (_, i) => ({id: `${prefix}-${i}`, topic, title: `Lesson ${prefix} ${i}`, ordering: i}));
const setA = {id: 'set-a', topic: 'topic_alpha', lesson: 'lesson-a-0', exams: ['exam_a', 'exam_b'], questions: questions('qa', 12)};
const setB = {id: 'set-b', topic: 'topic_beta', lesson: 'lesson-b-0', exams: ['exam_b'], questions: questions('qb', 12)};
const subjectA = {_id: 'subj_a', name: 'Alpha Subject', exam: 'exam_a', ordering: 1};
const subjectB = {_id: 'subj_b', name: 'Beta Subject', exam: 'exam_b', ordering: 2};
const catalog = {
  index: {subjects: [subjectA, subjectB, {_id: 'subj_empty', name: 'Empty Subject', exam: 'exam_b', ordering: 3}],
    topics: [{_id: 'topic_alpha', name: 'Alpha', subject: 'subj_a', ordering: 1}, {_id: 'topic_beta', name: 'Beta', subject: 'subj_b', ordering: 1},
      {_id: 'topic_empty', name: 'Empty', subject: 'subj_empty', ordering: 1}], catalogs: ['exam_a', 'exam_b']},
  exam_a: {id: 'exam_a', lessons: lessons('topic_alpha', 'lesson-a'), sets: [setA]},
  exam_b: {id: 'exam_b', lessons: lessons('topic_beta', 'lesson-b'), sets: [setA, setB]},
};
const seedCorpus = async () => {
  for (const [id, value] of Object.entries(catalog)) {
    await db.doc(`content/catalog/items/${id}`).set({version: `v-${id}`, payload: JSON.stringify(value)});
  }
  clearExamContentCache();
};
const ALL_TOPICS = ['topic_alpha', 'topic_beta'];

const blueprint = (updatedAt = NOW, over = {}) => ({
  sectionsJson: JSON.stringify([{id: 'section_all', name: 'Everything', questionCount: 10, suggestedMinutes: 40, topicIds: ALL_TOPICS}]),
  totalQuestions: 10, totalMinutes: 40, sectionsTimedSeparately: false, updatedAt, ...over});
const settingsInput = (uid, examId, extra = {}) => ({expectedUid: uid, examId, examDate: {precision: 'day', day: '2026-11-30'},
  studyDays: [1, 2, 3, 4, 5, 6, 7], assessmentCompleted: true, ...extra});
const save = (uid, examId, extra = {}, at = NOW, auth = named(uid)) => saveExamSettings(auth, settingsInput(uid, examId, extra), deps(at));

test('seed corpus', seedCorpus);

// ---- setExamSettings -----------------------------------------------------------------------------------------
test('creating a custom exam stores settings and the track in one save, and plans without the legacy roadmap', async () => {
  const uid = 'ct-create', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: '  PUP CET  ', blueprint: blueprint()}, excludedTopicIds: ['topic_beta', 'topic_beta'], excludedLessonIds: ['lesson-a-0']});
  assert.deepEqual(await settingsOf(uid), {examId: id, examDate: {precision: 'day', day: '2026-11-30'}, studyDays: [1, 2, 3, 4, 5, 6, 7],
    assessmentCompleted: true, excludedLessonIds: ['lesson-a-0'], excludedTopicIds: ['topic_beta'], updatedAt: NOW});
  assert.deepEqual(await track(uid, id), {examId: id, name: 'PUP CET', excludedTopicIds: ['topic_beta'], excludedLessonIds: ['lesson-a-0'],
    blueprint: blueprint(), createdAt: NOW, updatedAt: NOW});
  assert.equal((await db.doc(`users/${uid}/server/roadmap`).get()).exists, false, 'a custom exam has no legacy roadmap');
  const today = (await db.doc(`users/${uid}/server/roadmapDays/items/${id}:2026-10-24`).get());
  assert.equal(today.exists, true, 'the plan is stored for the new exam');
});

test('a later save keeps createdAt, overwrites the name only when sent and never clears what is absent', async () => {
  const uid = 'ct-update', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'First', blueprint: blueprint(NOW)}});
  await save(uid, id, {customTrack: {name: 'Second'}}, NOW + 1000);
  let stored = await track(uid, id);
  assert.equal(stored.name, 'Second');
  assert.deepEqual(stored.blueprint, blueprint(NOW), 'a save without a blueprint keeps it');
  assert.equal(stored.createdAt, NOW);
  assert.equal(stored.updatedAt, NOW + 1000);
  await save(uid, id, {}, NOW + 2000);
  stored = await track(uid, id);
  assert.equal(stored.name, 'Second', 'a save with no block keeps the name');
  assert.deepEqual(stored.blueprint, blueprint(NOW), 'a save with no block keeps the blueprint');
  await save(uid, id, {customTrack: {name: '   '}}, NOW + 3000);
  assert.equal((await track(uid, id)).name, 'Second', 'a blank name is not a rename');
  assert.equal((await track(uid, id)).createdAt, NOW);
});

test('a save with no block at all creates the track, as a cached client does when it recovers', async () => {
  const uid = 'ct-no-block', id = newId();
  await reset(uid);
  await save(uid, id);
  assert.deepEqual(await track(uid, id), {examId: id, name: null, excludedTopicIds: [], excludedLessonIds: [], blueprint: null, createdAt: NOW, updatedAt: NOW});
  const stored = await settingsOf(uid);
  assert.deepEqual(stored.excludedTopicIds, [], 'the scope is always written, so a later read needs no fallback');
});

test('the name is trimmed and cut to 80 characters, never refused', async () => {
  const uid = 'ct-name', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: ` ${'n'.repeat(120)} `}});
  assert.equal((await track(uid, id)).name, 'n'.repeat(80));
});

test('the newest blueprint wins: an older one is ignored, an equal or newer one replaces', async () => {
  const uid = 'ct-newest', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW, {totalMinutes: 40})}});
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW - 1, {totalMinutes: 99})}}, NOW + 1000);
  assert.equal((await track(uid, id)).blueprint.totalMinutes, 40, 'older than the stored one');
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW + 5, {totalMinutes: 55})}}, NOW + 2000);
  assert.equal((await track(uid, id)).blueprint.totalMinutes, 55);
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW + 5, {totalMinutes: 60})}}, NOW + 3000);
  assert.equal((await track(uid, id)).blueprint.totalMinutes, 60, 'not older, so it replaces');
});

test('unknown excluded ids are dropped from settings and from the track', async () => {
  const uid = 'ct-drop', id = newId();
  await reset(uid);
  await save(uid, id, {excludedTopicIds: ['topic_beta', 'topic_empty', 'topic_not_in_any_catalog'], excludedLessonIds: ['lesson-a-0', 'lesson-a-2', 'lesson-b-0', 'lesson-gone']});
  assert.deepEqual((await settingsOf(uid)).excludedTopicIds, ['topic_beta']);
  assert.deepEqual((await settingsOf(uid)).excludedLessonIds, ['lesson-a-0', 'lesson-b-0']);
  assert.deepEqual((await track(uid, id)).excludedTopicIds, ['topic_beta']);
  assert.deepEqual((await track(uid, id)).excludedLessonIds, ['lesson-a-0', 'lesson-b-0']);
});

test('a save that leaves no known topic is refused and stores nothing', async () => {
  const uid = 'ct-all-excluded', id = newId();
  await reset(uid);
  const message = 'Choose at least one known topic.';
  await refused(save(uid, id, {excludedTopicIds: ALL_TOPICS}), 'invalid-argument', message);
  await refused(save(uid, id, {excludedTopicIds: [...ALL_TOPICS, 'topic_empty']}), 'invalid-argument', message);
  assert.equal((await db.doc(`users/${uid}/server/settings`).get()).exists, false);
  assert.equal((await db.doc(trackPath(uid, id)).get()).exists, false);
  await save(uid, id, {excludedTopicIds: ['topic_alpha']});
  await refused(save(uid, id, {excludedTopicIds: ALL_TOPICS, customTrack: {name: 'Changed'}}), 'invalid-argument', message);
  assert.equal((await track(uid, id)).name, null, 'a refused save changes nothing');
});

test('the 51st track is refused, and an existing one can still be saved at the cap', async () => {
  const uid = 'ct-cap';
  await reset(uid);
  const batch = db.batch(), ids = Array.from({length: 49}, newId);
  for (const [i, id] of ids.entries()) batch.set(db.doc(trackPath(uid, id)), {examId: id, name: `T${i}`, excludedTopicIds: [], excludedLessonIds: [], blueprint: null, createdAt: i, updatedAt: i});
  await batch.commit();
  const fiftieth = newId();
  await save(uid, fiftieth, {customTrack: {name: 'Fiftieth'}});
  await refused(save(uid, newId(), {customTrack: {name: 'Fifty first'}}), 'resource-exhausted');
  await save(uid, ids[0], {customTrack: {name: 'Renamed'}}, NOW + 1000);
  assert.equal((await track(uid, ids[0])).name, 'Renamed');
  assert.equal((await db.collection(`users/${uid}/server/customTracks/items`).get()).size, 50);
  await reset(uid);
});

test('a malformed id and the bare id are Unknown exam, and nothing is written', async () => {
  const uid = 'ct-malformed';
  await reset(uid);
  const uuid = randomUUID();
  for (const examId of ['exam_custom', 'exam_custom_', `exam_custom_${uuid.toUpperCase()}`, `exam_custom_${uuid.replace(/^(.{14})4/, '$11')}`,
    `exam_custom_${uuid}x`, `exam_custom_${uuid}/x`, `exam_nope`]) {
    await refused(save(uid, examId), 'invalid-argument', 'Unknown exam.');
    await refused(readStudyRoadmap(named(uid), body(uid, examId), deps()), 'invalid-argument', 'Unknown exam.');
    await refused(advanceStudyRoadmap(named(uid), body(uid, examId, {requestId: 'advance-00001', expectedDay: '2026-10-24', expectedRevision: 'r'}), deps()), 'invalid-argument', 'Unknown exam.');
    await refused(readStudyDay(named(uid), body(uid, examId, {date: '2026-10-24'}), deps()), 'invalid-argument', 'Unknown exam.');
    await refused(readStudyWeek(named(uid), body(uid, examId, {start: '2026-10-18'}), deps()), 'invalid-argument', 'Unknown exam.');
    await refused(removeCustomTrack(named(uid), body(uid, examId), deps()), 'invalid-argument', 'Unknown exam.');
  }
  assert.equal((await db.collection(`users/${uid}/server/customTracks/items`).get()).size, 0);
  assert.equal((await db.doc(`users/${uid}/server/settings`).get()).exists, false);
});

test('a custom save names its owner, and the block and blueprint are checked', async () => {
  const uid = 'ct-checks', id = newId();
  await reset(uid);
  const {expectedUid, ...withoutOwner} = settingsInput(uid, id);
  await refused(saveExamSettings(named(uid), withoutOwner, deps()), 'invalid-argument', 'Send the original account.');
  await refused(save(uid, id, {expectedUid: 'someone-else'}), 'failed-precondition', 'Your account changed. Open this screen again.');
  await refused(save(uid, id, {customTrack: 'name'}), 'invalid-argument', 'Bad custom exam.');
  await refused(save(uid, id, {customTrack: {name: 7}}), 'invalid-argument', 'Bad custom exam.');
  await refused(save(uid, id, {customTrack: {blueprint: blueprint(NOW, {totalQuestions: 9})}}), 'invalid-argument', 'Bad mock setup.');
  await refused(save(uid, id, {customTrack: {blueprint: blueprint(NOW + 2 * DAY)}}), 'invalid-argument', 'Bad mock setup.');
  assert.equal((await db.doc(`users/${uid}/server/settings`).get()).exists, false);
  assert.equal((await db.doc(trackPath(uid, id)).get()).exists, false);
  await refused(saveExamSettings(null, settingsInput(uid, id), deps()), 'unauthenticated');
});

test('an anonymous account can save a custom exam', async () => {
  const uid = 'ct-anon', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'Anon'}}, NOW, anon(uid));
  assert.equal((await track(uid, id)).name, 'Anon');
});

test('content that cannot be read stops the save before anything is stored', async () => {
  const uid = 'ct-unavailable', id = newId();
  await reset(uid);
  await db.doc('content/catalog/items/exam_b').delete();
  clearExamContentCache();
  try {
    await refused(save(uid, id), 'unavailable');
    assert.equal((await db.doc(`users/${uid}/server/settings`).get()).exists, false);
    assert.equal((await db.doc(trackPath(uid, id)).get()).exists, false);
  } finally {
    await seedCorpus();
  }
});

// ---- getRoadmap and the plan ------------------------------------------------------------------------------------
test('a Free custom response has no comingUp or history, even with a Pro claim and a pass for CSE', async () => {
  const uid = 'ct-free', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'Mine', blueprint: blueprint()}});
  const claimed = named(uid, {pro: true, proUntil: NOW + 100 * DAY});
  // A pass belongs to one listed exam, so it never covers a custom exam. A claim alone is never read.
  await db.doc(`users/${uid}/grants/trial`).set({source: 'paymongo', product: 'pantas_pass_cse_pro', tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + 30 * DAY, state: 'active', createdAt: NOW - DAY});
  for (const auth of [named(uid), claimed, anon(uid)]) {
    const view = await readStudyRoadmap(auth, body(uid, id), deps());
    assert.equal(view.examId, id);
    assert.equal(view.proCovered, false);
    assert.equal(view.tier, 'free');
    assert.equal('comingUp' in view, false);
    assert.equal('history' in view, false);
    assert.ok(view.today.lessonIds.length + view.today.newQuestionIds.length > 0, 'the plan comes from the corpus');
  }
  // Clean up the grant.
  await db.doc(`users/${uid}/grants/trial`).delete();
});

const grantOf = (uid, product, tier) => db.doc(`users/${uid}/grants/ct-tier`).set({source: 'paymongo', product, tier, startsAt: NOW - DAY, endsAt: NOW + 60 * DAY, state: 'active', createdAt: NOW - DAY});
const settingsDoc = uid => db.doc(`users/${uid}/server/settings`);

test('a custom plan is Pro when the account plan reaches the exam tier, and the tier follows the kept subjects', async () => {
  const uid = 'ct-tier-plan', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'Mine', blueprint: blueprint()}});
  const view = () => readStudyRoadmap(named(uid), body(uid, id), deps());
  // Nothing is excluded, so every subject is kept, which is Civil Service.
  await grantOf(uid, 'pantas_pro_monthly', 'student');
  let read = await view();
  assert.equal(read.proCovered, false);
  assert.equal('comingUp' in read, false);
  // Excluding every General Information topic leaves only Student subjects.
  await settingsDoc(uid).update({excludedTopicIds: GENERAL_INFORMATION});
  read = await view();
  assert.equal(read.proCovered, true);
  assert.equal(read.tier, 'pro');
  assert.ok('comingUp' in read && 'history' in read);
  // Adding it back removes them on the next read.
  await settingsDoc(uid).update({excludedTopicIds: []});
  read = await view();
  assert.equal(read.proCovered, false);
  assert.equal('comingUp' in read, false);
  assert.equal('history' in read, false);
  // Civil Service Pro covers either tier, and so does a Civil Service trial.
  await grantOf(uid, 'pantas_cs_monthly', 'civilService');
  assert.equal((await view()).proCovered, true);
  await settingsDoc(uid).update({excludedTopicIds: GENERAL_INFORMATION});
  assert.equal((await view()).proCovered, true);
  await db.doc(`users/${uid}/grants/ct-tier`).set({source: 'trial', product: 'web_trial', tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + 30 * DAY, state: 'active', createdAt: NOW - DAY});
  assert.equal((await view()).proCovered, true);
});

test('a request field cannot set the tier: the server reads its own exclusions', async () => {
  const uid = 'ct-tier-field', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'Mine', blueprint: blueprint()}});
  await grantOf(uid, 'pantas_pro_monthly', 'student');
  for (const extra of [{priceTier: 'Student'}, {tier: 'student'}, {excludedTopicIds: GENERAL_INFORMATION}, {customTier: 'student'}]) {
    assert.equal((await readStudyRoadmap(named(uid), body(uid, id, extra), deps())).proCovered, false, JSON.stringify(extra));
  }
});

test('getCustomTracks returns a computed priceTier, from settings while active and from the track otherwise', async () => {
  const uid = 'ct-tier-list', a = newId(), b = newId();
  await reset(uid);
  await save(uid, a, {customTrack: {name: 'A'}}, NOW);
  await save(uid, b, {customTrack: {name: 'B'}}, NOW + 1000);
  // A client-sent value is never stored or returned.
  await db.doc(trackPath(uid, a)).update({excludedTopicIds: GENERAL_INFORMATION, priceTier: 'Licensure'});
  await settingsDoc(uid).update({excludedTopicIds: []});
  let result = await readCustomTracks(named(uid), {expectedUid: uid}, deps());
  assert.deepEqual(result.tracks.map(t => [t.examId, t.priceTier]), [[b, 'Civil Service'], [a, 'Student']]);
  await settingsDoc(uid).update({excludedTopicIds: GENERAL_INFORMATION});
  result = await readCustomTracks(named(uid), {expectedUid: uid}, deps());
  assert.equal(result.tracks.find(t => t.examId === b).priceTier, 'Student', 'the active exam follows settings');
});

test('a Student custom exam is covered by a Student plan and not by a pass or a beta grant', async () => {
  const uid = 'ct-tier-pass', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'Mine', blueprint: blueprint()}});
  await settingsDoc(uid).update({excludedTopicIds: GENERAL_INFORMATION});
  const view = () => readStudyRoadmap(named(uid), body(uid, id), deps());
  for (const [source, product, tier, examId] of [['paymongo', 'pantas_pass_cse_pro', 'civilService'],
    ['beta', 'beta_exam_cse_pro', 'civilService', 'exam_cse_pro'], ['beta_reward', 'beta_reward', 'civilService', 'exam_cse_pro']]) {
    await db.doc(`users/${uid}/grants/ct-tier`).set({source, product, tier, ...(examId ? {examId} : {}), startsAt: NOW - DAY, endsAt: NOW + 60 * DAY, state: 'active', createdAt: NOW - DAY});
    assert.equal((await view()).proCovered, false, `${source} grants are exam-specific`);
  }
  await grantOf(uid, 'pantas_pro_monthly', 'student');
  assert.equal((await view()).proCovered, true);
});

test('the plan uses the whole corpus and the excluded topics in settings', async () => {
  const uid = 'ct-scope', id = newId();
  await reset(uid);
  await save(uid, id, {excludedTopicIds: ['topic_alpha']});
  const view = await readStudyRoadmap(named(uid), body(uid, id), deps());
  const all = [...view.today.newQuestionIds, ...view.remaining.newQuestionIds];
  assert.ok(all.length > 0);
  assert.equal(all.some(q => q.startsWith('qa-')), false, 'the excluded topic stays out');
  assert.equal(view.today.lessonIds.some(l => l.startsWith('lesson-a-')), false);
  assert.deepEqual(view.todayTopicOrder, ['topic_beta']);
  await save(uid, id, {excludedTopicIds: []}, NOW + 1000);
  const wide = await readStudyRoadmap(named(uid), body(uid, id), deps(NOW + 1000));
  assert.ok(wide.todayTopicOrder.includes('topic_alpha'), 'a topic from the other exam\'s catalog is in the plan');
});

test('with no track or settings, CSE to custom asks to set the exam first; with a track it says the exam changed', async () => {
  const uid = 'ct-switch', id = newId(), other = newId();
  await reset(uid);
  await refused(readStudyRoadmap(named(uid), body(uid, id), deps()), 'failed-precondition', 'Set your exam first.');
  await db.doc(`users/${uid}/server/settings`).set({examId: 'exam_cse_pro', examDate: null, studyDays: [1], updatedAt: NOW});
  for (const run of [
    () => readStudyRoadmap(named(uid), body(uid, id), deps()),
    () => advanceStudyRoadmap(named(uid), body(uid, id, {requestId: 'advance-00002', expectedDay: '2026-10-24', expectedRevision: 'r'}), deps()),
    () => readStudyDay(named(uid), body(uid, id, {date: '2026-10-24'}), deps()),
    () => readStudyWeek(named(uid), body(uid, id, {start: '2026-10-18'}), deps()),
  ]) await refused(run(), 'failed-precondition', 'Set your exam first.');
  // A track exists for this id, then the student moves to another exam.
  await save(uid, id);
  await save(uid, other, {}, NOW + 1000);
  await refused(readStudyRoadmap(named(uid), body(uid, id), deps(NOW + 2000)), 'failed-precondition', 'Your exam changed. Open this screen again.');
  await refused(readStudyDay(named(uid), body(uid, id, {date: '2026-10-24'}), deps(NOW + 2000)), 'failed-precondition', 'Your exam changed. Open this screen again.');
  // And the listed exam does not know about the custom one.
  await refused(readStudyRoadmap(named(uid), body(uid, 'exam_cse_pro'), deps(NOW + 2000)), 'failed-precondition', 'Your exam changed. Open this screen again.');
});

// ---- a save whose rebuild meets a newer save --------------------------------------------------------------------
/** The same database, except that before the `nth` transaction it runs `before`. The save's own transaction is the first. */
function racing(nth, before) {
  let calls = 0, fired = false;
  const proxy = new Proxy(db, {get(target, key) {
    if (key === 'runTransaction') return async (...args) => {
      calls += 1;
      if (calls === nth) { fired = true; await before(); }
      return target.runTransaction(...args);
    };
    const value = Reflect.get(target, key, target);
    return typeof value === 'function' ? value.bind(target) : value;
  }});
  return {db: proxy, fired: () => fired};
}

for (const [nth, which] of [[3, 'plan'], [4, 'insights']]) {
  test(`a save whose ${which} rebuild finds a newer save naming another exam still succeeds, and its track is stored`, async () => {
    const uid = `ct-race-${which}`, id = newId(), other = newId();
    await reset(uid);
    const raced = racing(nth, () => db.doc(`users/${uid}/server/settings`).set({examId: other, examDate: null, studyDays: [1], updatedAt: NOW + 1}));
    const out = await saveExamSettings(named(uid), settingsInput(uid, id, {customTrack: {name: 'First', blueprint: blueprint()}}), {...deps(), db: raced.db});
    assert.equal(raced.fired(), true);
    assert.deepEqual(out, {stored: true});
    assert.equal((await track(uid, id)).name, 'First');
    assert.equal((await settingsOf(uid)).examId, other, 'the newer save is untouched');
  });
}

test('a rebuild that fails for any other reason still fails the save', async () => {
  const uid = 'ct-race-other', id = newId();
  await reset(uid);
  const refusal = Object.assign(new Error('unavailable'), {code: 'unavailable'});
  const raced = racing(3, async () => { throw refusal; });
  await assert.rejects(saveExamSettings(named(uid), settingsInput(uid, id, {customTrack: {name: 'First', blueprint: blueprint()}}), {...deps(), db: raced.db}), error => error === refusal);
  assert.equal((await track(uid, id)).name, 'First', 'the save itself had committed');
});

const storedDay = async (uid, id, day = '2026-10-24') => (await db.doc(`users/${uid}/server/roadmapDays/items/${id}:${day}`).get());

test('a track with a blueprint has a mock, one without does not, and its length comes from the blueprint', async () => {
  const uid = 'ct-mock', id = newId(), near = {examDate: {precision: 'day', day: '2026-10-27'}};
  await reset(uid);
  await save(uid, id, near);
  let view = await readStudyRoadmap(named(uid), body(uid, id), deps());
  assert.equal(view.homeExtras.mockDurationMinutes, null);
  assert.equal(JSON.parse((await storedDay(uid, id)).get('stateJson')).roadmap.mockDay, null);
  await save(uid, id, {...near, customTrack: {blueprint: blueprint(NOW + 10, {totalMinutes: 75})}}, NOW + 1000);
  view = await readStudyRoadmap(named(uid), body(uid, id), deps(NOW + 1000));
  assert.equal(view.homeExtras.mockDurationMinutes, 75);
  assert.notEqual(JSON.parse((await storedDay(uid, id)).get('stateJson')).roadmap.mockDay, null, 'a blueprint makes a mock day');
});

test('a new blueprint time changes the stored plan digest, an older one or none does not', async () => {
  const uid = 'ct-digest', id = newId();
  await reset(uid);
  const digestAfter = async at => {
    await readStudyRoadmap(named(uid), body(uid, id), deps(at));
    return JSON.parse((await storedDay(uid, id)).get('snapshotJson')).digest;
  };
  const stamp = digest => JSON.parse(digest).content.split('|customBlueprint:')[1];
  await save(uid, id);
  const none = await digestAfter(NOW);
  assert.equal(stamp(none), undefined, 'no blueprint, nothing added');
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW + 1)}}, NOW + 1000);
  const first = await digestAfter(NOW + 1000);
  assert.equal(stamp(first), String(NOW + 1));
  assert.notEqual(first, none);
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW + 2)}}, NOW + 2000);
  const second = await digestAfter(NOW + 2000);
  assert.equal(stamp(second), String(NOW + 2));
  assert.notEqual(second, first);
  await save(uid, id, {customTrack: {blueprint: blueprint(NOW)}}, NOW + 3000);
  assert.equal(await digestAfter(NOW + 3000), second, 'an older blueprint is ignored, so the digest holds');
  await save(uid, id, {}, NOW + 4000);
  assert.equal(await digestAfter(NOW + 4000), second, 'an absent block never clears it');
});

// ---- advance, day, week ------------------------------------------------------------------------------------------
async function readyToAdvance(uid, id) {
  await reset(uid);
  await save(uid, id);
  const first = await readStudyRoadmap(named(uid), body(uid, id), deps());
  for (const lessonId of first.today.lessonIds) await db.doc(`users/${uid}/server/lessonReads/items/${lessonId}`).set({lessonId, readAt: NOW});
  const ref = db.doc(`users/${uid}/server/answerTotals`), totals = (await ref.get()).exists ? fromDoc((await ref.get()).data()) : emptyTotals();
  addSession(totals, [...first.today.newQuestionIds, ...first.today.reviewQuestionIds].map(questionId => ({questionId, chosen: `${questionId}_a`, correct: true, answeredAt: NOW})));
  await ref.set(toDoc(totals));
  const ready = await readStudyRoadmap(named(uid), body(uid, id), deps());
  assert.equal(ready.originalDone, true);
  assert.equal(ready.canAdvance, true);
  return body(uid, id, {expectedDay: ready.today.day, expectedRevision: ready.revision});
}

test('advance works on a custom id once, replays the same answer, and refuses a changed or foreign request', async () => {
  const uid = 'ct-advance', id = newId();
  const request = {...await readyToAdvance(uid, id), requestId: 'advance-custom-1'};
  const result = await advanceStudyRoadmap(named(uid), request, deps());
  assert.equal(result.examId, id);
  assert.ok(result.today.advancedIds.length > 0);
  assert.equal(result.tier, 'free');
  for (const field of ['comingUp', 'history']) assert.equal(field in result, false);
  assert.deepEqual((await advanceStudyRoadmap(named(uid), request, deps())).today, result.today);
  await refused(advanceStudyRoadmap(named(uid), {...request, expectedRevision: 'different'}, deps()), 'failed-precondition', 'This advance request changed.');
  await refused(advanceStudyRoadmap(named(uid), {...request, expectedUid: 'other'}, deps()), 'failed-precondition', 'Your account changed. Open this screen again.');
  // After the student moves to another exam, a replay is refused rather than returned.
  await save(uid, newId(), {}, NOW + 1000);
  await refused(advanceStudyRoadmap(named(uid), request, deps(NOW + 1000)), 'failed-precondition', 'Your exam changed. Open this screen again.');
});

test('a custom Free day read locks the future, reads the past and today', async () => {
  const uid = 'ct-days', id = newId(), thursday = Date.parse('2026-10-22T10:00:00+08:00');
  await reset(uid);
  await save(uid, id, {}, thursday - DAY);
  await readStudyRoadmap(named(uid), body(uid, id), deps(thursday - DAY));
  const week = await readStudyWeek(named(uid), body(uid, id, {start: '2026-10-18'}), deps(thursday));
  assert.equal(week.examId, id);
  assert.equal(week.proCovered, false);
  assert.deepEqual(week.days.map(d => d.kind), ['unknown', 'unknown', 'unknown', 'past', 'today', 'locked', 'locked']);
  assert.ok(week.days[3].plan, 'the past day is real data');
  for (const day of week.days.slice(5)) {assert.equal('plan' in day, false); assert.equal('remaining' in day, false);}
  assert.equal((await readStudyDay(named(uid), body(uid, id, {date: '2026-10-21'}), deps(thursday))).kind, 'past');
  assert.equal((await readStudyDay(named(uid), body(uid, id, {date: '2026-10-22'}), deps(thursday))).kind, 'today');
  await refused(readStudyDay(named(uid), body(uid, id, {date: '2026-10-25'}), deps(thursday)), 'permission-denied');
  await refused(readStudyWeek(named(uid), body(uid, id, {start: '2026-10-19'}), deps(thursday)), 'invalid-argument');
});

// ---- getCustomTracks and deleteCustomTrack --------------------------------------------------------------------------
test('getCustomTracks returns only the caller\'s tracks, newest first, with the active exam', async () => {
  const uid = 'ct-list', other = 'ct-list-other', a = newId(), b = newId(), c = newId();
  await reset(uid); await reset(other);
  assert.deepEqual(await readCustomTracks(named(uid), {expectedUid: uid}, deps()), {activeExamId: null, tracks: []});
  await save(uid, a, {customTrack: {name: 'A', blueprint: blueprint(NOW, {sectionsTimedSeparately: false})}}, NOW);
  await save(uid, b, {customTrack: {name: 'B', blueprint: blueprint(NOW, {
    sectionsJson: JSON.stringify([{id: 'section_1', name: 'One', questionCount: 5, suggestedMinutes: 20, topicIds: ['topic_alpha']},
      {id: 'section_2', name: 'Two', questionCount: 5, suggestedMinutes: 20, topicIds: ['topic_beta']}]), sectionsTimedSeparately: true})}}, NOW + 1000);
  await save(other, c, {customTrack: {name: 'Not mine'}}, NOW + 2000);
  const result = await readCustomTracks(anon(uid), {expectedUid: uid}, deps());
  assert.equal(result.activeExamId, b);
  assert.deepEqual(result.tracks.map(t => t.examId), [b, a]);
  assert.deepEqual(result.tracks.map(t => t.name), ['B', 'A']);
  assert.equal(result.tracks[0].blueprint.sectionsTimedSeparately, true, 'returned as stored');
  assert.equal(result.tracks[1].blueprint.sectionsTimedSeparately, false, 'returned as stored');
  assert.deepEqual(Object.keys(result.tracks[0]).sort(), ['blueprint', 'createdAt', 'examId', 'excludedLessonIds', 'excludedTopicIds', 'name', 'priceTier', 'updatedAt']);
  assert.deepEqual((await readCustomTracks(named(other), {expectedUid: other}, deps())).tracks.map(t => t.name), ['Not mine']);
  await db.doc(`users/${uid}/server/settings`).update({examId: 'exam_cse_pro'});
  assert.equal((await readCustomTracks(named(uid), {expectedUid: uid}, deps())).activeExamId, 'exam_cse_pro');
});

test('getCustomTracks returns at most 50 rows and refuses a wrong or missing owner', async () => {
  const uid = 'ct-list-limit';
  await reset(uid);
  const batch = db.batch();
  for (let i = 0; i < 52; i++) {
    const id = newId();
    batch.set(db.doc(trackPath(uid, id)), {examId: id, name: `T${i}`, excludedTopicIds: [], excludedLessonIds: [], blueprint: null, createdAt: i, updatedAt: i});
  }
  await batch.commit();
  const result = await readCustomTracks(named(uid), {expectedUid: uid}, deps());
  assert.equal(result.tracks.length, 50);
  assert.equal(result.tracks[0].name, 'T51');
  assert.equal(result.tracks[49].name, 'T2');
  await refused(readCustomTracks(named(uid), {expectedUid: 'other'}, deps()), 'failed-precondition', 'Your account changed. Open this screen again.');
  await refused(readCustomTracks(named(uid), {}, deps()), 'invalid-argument', 'Send the original account.');
  await refused(readCustomTracks(named(uid), null, deps()), 'invalid-argument');
  await refused(readCustomTracks(null, {expectedUid: uid}, deps()), 'unauthenticated');
  await refused(readCustomTracks(named(uid), {expectedUid: uid}, {...deps(), allow: async () => false}), 'resource-exhausted');
  await reset(uid);
});

test('deleteCustomTrack removes the row, is idempotent, refuses the active exam and keeps study data', async () => {
  const uid = 'ct-delete', active = newId(), spare = newId();
  await reset(uid);
  await save(uid, spare, {customTrack: {name: 'Spare'}});
  await readStudyRoadmap(named(uid), body(uid, spare), deps());
  await db.doc(`users/${uid}/server/lessonReads/items/lesson-a-0`).set({lessonId: 'lesson-a-0', readAt: NOW});
  await db.doc(`users/${uid}/server/answers/items/s1`).set({sessionId: 's1', examId: spare, answers: []});
  await save(uid, active, {customTrack: {name: 'Active'}}, NOW + 1000);
  await refused(removeCustomTrack(named(uid), body(uid, active), deps()), 'failed-precondition');
  assert.equal((await db.doc(trackPath(uid, active)).get()).exists, true);
  assert.deepEqual(await removeCustomTrack(named(uid), body(uid, spare), deps()), {deleted: true});
  assert.equal((await db.doc(trackPath(uid, spare)).get()).exists, false);
  assert.deepEqual(await removeCustomTrack(anon(uid), body(uid, spare), deps()), {deleted: true}, 'a second delete is not an error');
  assert.deepEqual(await removeCustomTrack(named(uid), body(uid, newId()), deps()), {deleted: true}, 'nor is a track that never existed');
  for (const path of [`users/${uid}/server/lessonReads/items/lesson-a-0`, `users/${uid}/server/answers/items/s1`, `users/${uid}/server/roadmapDays/items/${spare}:2026-10-24`]) {
    assert.equal((await db.doc(path).get()).exists, true, path);
  }
  assert.deepEqual((await readCustomTracks(named(uid), {expectedUid: uid}, deps())).tracks.map(t => t.name), ['Active']);
  await refused(removeCustomTrack(named(uid), body(uid, spare, {expectedUid: 'other'}), deps()), 'failed-precondition', 'Your account changed. Open this screen again.');
  await refused(removeCustomTrack(named(uid), {examId: spare}, deps()), 'invalid-argument', 'Send the original account.');
  await refused(removeCustomTrack(null, body(uid, spare), deps()), 'unauthenticated');
  await refused(removeCustomTrack(named(uid), body(uid, 'exam_cse_pro'), deps()), 'invalid-argument', 'Unknown exam.');
});

// ---- security -------------------------------------------------------------------------------------------------------
test('another account cannot read or change a track or plan through any callable or id', async () => {
  const a = 'ct-sec-a', b = 'ct-sec-b', id = newId();
  await reset(a); await reset(b);
  await save(a, id, {customTrack: {name: 'Secret name', blueprint: blueprint()}, excludedTopicIds: ['topic_beta']});
  await readStudyRoadmap(named(a), body(a, id), deps());
  const before = JSON.stringify(await track(a, id));
  const plan = JSON.stringify((await storedDay(a, id)).data());
  // B has no settings, so A's id resolves to nothing.
  for (const run of [
    () => readStudyRoadmap(named(b), body(b, id), deps()),
    () => advanceStudyRoadmap(named(b), body(b, id, {requestId: 'advance-sec-01', expectedDay: '2026-10-24', expectedRevision: 'r'}), deps()),
    () => readStudyDay(named(b), body(b, id, {date: '2026-10-24'}), deps()),
    () => readStudyWeek(named(b), body(b, id, {start: '2026-10-18'}), deps()),
  ]) await refused(run(), 'failed-precondition', 'Set your exam first.');
  assert.deepEqual((await readCustomTracks(named(b), {expectedUid: b}, deps())).tracks, []);
  assert.deepEqual(await removeCustomTrack(named(b), body(b, id), deps()), {deleted: true});
  assert.equal(JSON.stringify(await track(a, id)), before, 'B deleting A\'s id removed nothing of A');
  // B saving A's id creates a document under B only.
  await save(b, id, {customTrack: {name: 'B own'}});
  assert.equal((await track(b, id)).name, 'B own');
  assert.equal(JSON.stringify(await track(a, id)), before);
  assert.equal(JSON.stringify((await storedDay(a, id)).data()), plan);
  assert.equal(JSON.stringify(await readCustomTracks(named(a), {expectedUid: a}, deps()).then(r => r.tracks.map(t => t.name))), JSON.stringify(['Secret name']));
  // Naming A as the owner is refused on every callable.
  for (const run of [
    () => readStudyRoadmap(named(b), body(a, id), deps()),
    () => advanceStudyRoadmap(named(b), body(a, id, {requestId: 'advance-sec-02', expectedDay: '2026-10-24', expectedRevision: 'r'}), deps()),
    () => readStudyDay(named(b), body(a, id, {date: '2026-10-24'}), deps()),
    () => readStudyWeek(named(b), body(a, id, {start: '2026-10-18'}), deps()),
    () => save(a, id, {}, NOW, named(b)),
    () => readCustomTracks(named(b), {expectedUid: a}, deps()),
    () => removeCustomTrack(named(b), body(a, id), deps()),
  ]) await refused(run(), 'failed-precondition', 'Your account changed. Open this screen again.');
  assert.equal(JSON.stringify(await track(a, id)), before);
  assert.equal((await db.doc(trackPath(a, id)).get()).exists, true);
});

test('a call that sends no scope keeps the track scope, in the settings too', async () => {
  const uid = 'ct-keep-scope', id = newId();
  await reset(uid);
  await save(uid, id, {excludedTopicIds: ['topic_beta']});
  await save(uid, id);
  assert.deepEqual((await settingsOf(uid)).excludedTopicIds, ['topic_beta']);
  assert.deepEqual((await track(uid, id)).excludedTopicIds, ['topic_beta']);
});

test('another account cannot read or change sessions, insights, diagnosis or the carry count with this account\'s id', async () => {
  const a = 'ct-sec2-a', b = 'ct-sec2-b', id = newId(), sid = 'sec-session-a1';
  await reset(a); await reset(b);
  const session = (uid, questions, correct, over = {}) => ({expectedUid: uid, sessionId: sid, examId: id, origin: 'drill', startedAt: NOW - 2000, finishedAt: NOW - 1000,
    durationMs: 1000, answers: questions.map(questionId => ({questionId, chosen: questionId + '_a', correct, answeredAt: NOW - 1500})), ...over});
  const ask = (uid, extra = {}) => ({expectedUid: uid, examId: id, ...extra});
  const doc = async path => JSON.stringify((await db.doc(path).get()).data() ?? null);
  const treeOf = async uid => [await doc(`users/${uid}/server/answers/items/${sid}`), await doc(`users/${uid}/server/answerTotals`),
    await doc(`users/${uid}/server/studyInsights`), await doc(trackPath(uid, id))];
  // A has a track that leaves Beta out, a session in both topics, and figures of its own.
  await save(a, id, {customTrack: {name: 'Secret name'}, excludedTopicIds: ['topic_beta']});
  await recordSession(named(a), session(a, ['qa-0', 'qb-0'], true), deps());
  const aInsights = await readStudyInsights(named(a), ask(a), deps());
  assert.deepEqual(aInsights.performance.overall, {correct: 1, answered: 1, accuracy: 1});
  assert.deepEqual(await readCarryableCount(named(a), ask(a), deps()), {count: 1});
  const aTree = await treeOf(a);
  // B has nothing yet, so A's id resolves to nothing of A's.
  await refused(readStudyInsights(named(b), ask(b), deps()), 'failed-precondition', 'Set your exam first.');
  assert.deepEqual(await readSessionDiagnosis(named(b), ask(b, {sessionId: sid}), deps()), {status: 'pending'});
  assert.deepEqual(await readCarryableCount(named(b), ask(b), deps()), {count: 0});
  // B stores a session under the same session id and exam id. It lands in B's tree, and A's does not move.
  assert.equal((await recordSession(named(b), session(b, ['qb-1'], false), deps())).stored, true);
  assert.deepEqual(await treeOf(a), aTree, 'nothing of A changed');
  assert.equal(JSON.parse((await doc(`users/${b}/server/answers/items/${sid}`))).answers[0].questionId, 'qb-1');
  assert.equal((await db.doc(trackPath(b, id)).get()).exists, false, 'storing a session makes no track');
  // A's exclusions are not applied to B: B has no track for this id, so B's own answer in Beta counts.
  assert.deepEqual(await readCarryableCount(named(b), ask(b), deps()), {count: 1});
  // With B's session stored and no settings, the diagnosis names B's tree and reaches no further.
  await refused(readSessionDiagnosis(named(b), ask(b, {sessionId: sid}), deps()), 'failed-precondition', 'Your exam changed. Open this screen again.');
  // With B's own settings the same ids answer from B's data alone.
  await save(b, id, {});
  const bInsights = await readStudyInsights(named(b), ask(b), deps());
  assert.deepEqual(bInsights.performance.overall, {correct: 0, answered: 1, accuracy: 0}, 'B\'s figures, not A\'s');
  const bDiagnosis = await readSessionDiagnosis(named(b), ask(b, {sessionId: sid}), deps());
  assert.deepEqual(bDiagnosis, {status: 'ok', tier: 'free', tracedCount: 0});
  assert.deepEqual(await treeOf(a), aTree, 'still nothing of A changed');
  assert.equal((await readStudyInsights(named(a), ask(a), deps())).revision, aInsights.revision);
  // Naming A as the owner is refused on all four, and writes nothing.
  for (const run of [
    () => recordSession(named(b), session(a, ['qa-1'], true, {sessionId: 'sec-session-a2'}), deps()),
    () => readStudyInsights(named(b), ask(a), deps()),
    () => readSessionDiagnosis(named(b), ask(a, {sessionId: sid}), deps()),
    () => readCarryableCount(named(b), ask(a), deps()),
  ]) await refused(run(), 'failed-precondition', 'Your account changed. Open this screen again.');
  assert.equal((await db.doc(`users/${a}/server/answers/items/sec-session-a2`).get()).exists, false);
  assert.deepEqual(await treeOf(a), aTree);
});

// ---- the mock: saved through setExamSettings, started and read back -----------------------------------------------------
const MOCK_NOW = Date.parse('2026-11-20T10:00:00+08:00');
const MIN = 60_000;
const mockDeps = (at = MOCK_NOW) => ({db, now: () => at, allow: async () => true, seed: () => 11});
const CHOSEN = (questionId, correct, at = MOCK_NOW) => ({questionId, chosen: 'a', correct, answeredAt: at});
const idsIn = out => out.paper.sections.flatMap(s => s.questions.map(q => q.id));
const seedCse = async () => {
  await writeContent(db, [questionSetItems({meta: {subject: 's', topic: 'ctown', exams: ['cse-pro']},
    questions: Array.from({length: 10}, (_, i) => ({id: `ct-cse-${i}`, stem: 'x', choices: [{text: 'a', correct: true}, {text: 'b'}]}))}, 'ct/ctown/u.yaml').item,
  blueprintItem({exam: 'exam_cse_pro', name: 'Paper', durationMinutes: 60, sectionalTiming: 'none',
    sections: [{id: 's1', name: 'Part one', questionCount: 4, suggestedMinutes: 60, topicIds: ['topic_cse_pro_ctown'], topicWeights: {topic_cse_pro_ctown: 1}}]})], [], {});
  clearExamContentCache();
};
const paidCse = uid => db.doc(`users/${uid}/grants/ct-paid`).set({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService',
  startsAt: MOCK_NOW - DAY, endsAt: MOCK_NOW + 60 * DAY, state: 'active', createdAt: MOCK_NOW - DAY});
const submittedCse = (uid, at) => db.doc(`users/${uid}/server/mocks/items/CseMock0000001`).set({examId: 'exam_cse_pro', status: 'submitted', startedAt: at - MIN, submittedAt: at,
  endedBy: 'student', strict: false, limitMs: 60 * MIN, durationMs: MIN, paper: {sections: [{sectionId: 's1', name: 'Part one', questions: [{id: 'ct-cse-0', setId: 'set'}]}]}, answers: []});
const COOLDOWN = 'Free accounts can take one mock every 30 days.';
const startRefused = async (promise, message) => assert.rejects(promise, e => e.code === 'failed-precondition' && e.message === message);

test('a saved custom exam starts a mock with its name, and the name survives a rename and a deleted track', async () => {
  await seedCorpus();
  const uid = 'ct-m-name', first = newId(), second = newId();
  await reset(uid);
  await save(uid, first, {customTrack: {name: 'PUP CET', blueprint: blueprint(MOCK_NOW, {})}}, MOCK_NOW);
  const out = await beginMock(named(uid), {examId: first}, mockDeps());
  assert.equal(out.examName, 'PUP CET');
  assert.equal(idsIn(out).length, 10);
  assert.equal(new Set(idsIn(out)).size, 10);
  assert.equal(out.limitMs, 40 * MIN);
  await recordMock(named(uid), {mockId: out.mockId, answers: [CHOSEN(idsIn(out)[0], true)], durationMs: MIN}, mockDeps(MOCK_NOW + MIN));
  await save(uid, first, {customTrack: {name: 'Renamed'}}, MOCK_NOW + 2 * MIN);
  assert.equal((await track(uid, first)).name, 'Renamed');
  assert.equal((await serveMockResults(named(uid), {mockId: out.mockId}, mockDeps(MOCK_NOW + 3 * MIN))).examName, 'PUP CET');
  await save(uid, second, {customTrack: {name: 'Second'}}, MOCK_NOW + 4 * MIN);
  assert.deepEqual(await removeCustomTrack(named(uid), body(uid, first), mockDeps(MOCK_NOW + 5 * MIN)), {deleted: true});
  const results = await serveMockResults(named(uid), {mockId: out.mockId}, mockDeps(MOCK_NOW + 6 * MIN));
  assert.equal(results.examName, 'PUP CET');
  assert.equal(results.examId, first);
  assert.deepEqual((await serveMockHistory(named(uid), {}, mockDeps(MOCK_NOW + 6 * MIN))).items.map(i => [i.examId, i.examName]), [[first, 'PUP CET']]);
  // The track is gone, so the exam has no mock to start again.
  assert.equal((await serveMockAvailability(named(uid), {examId: first}, mockDeps(MOCK_NOW + 7 * MIN))).status, 'no-blueprint');
});

test('Free cooldown: a CSE mock blocks a custom start, and a custom mock blocks CSE and every other custom track', async () => {
  await seedCorpus();
  await seedCse();
  const cseFirst = 'ct-m-cse-first', customFirst = 'ct-m-custom-first';
  await reset(cseFirst); await reset(customFirst);
  const a = newId(), b = newId(), c = newId();
  // CSE inside 30 days blocks a custom start, and the day it ends the start works.
  await save(cseFirst, a, {customTrack: {name: 'A', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  await submittedCse(cseFirst, MOCK_NOW - 5 * DAY);
  await startRefused(beginMock(named(cseFirst), {examId: a}, mockDeps()), COOLDOWN);
  await startRefused(beginMock(named(cseFirst), {examId: a}, mockDeps(MOCK_NOW - 5 * DAY + 30 * DAY - 1)), COOLDOWN);
  assert.equal((await serveMockAvailability(named(cseFirst), {examId: a}, mockDeps())).status, 'cooldown');
  assert.equal((await beginMock(named(cseFirst), {examId: a}, mockDeps(MOCK_NOW - 5 * DAY + 30 * DAY))).resumed, false);
  // A custom mock blocks a CSE start and a second and third track, which are not a way around the window.
  await save(customFirst, a, {customTrack: {name: 'A', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  await save(customFirst, b, {customTrack: {name: 'B', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  await save(customFirst, c, {customTrack: {name: 'C', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  const out = await beginMock(named(customFirst), {examId: a}, mockDeps());
  await recordMock(named(customFirst), {mockId: out.mockId, answers: [CHOSEN(idsIn(out)[0], true)], durationMs: MIN}, mockDeps(MOCK_NOW + MIN));
  for (const examId of [b, c, a, 'exam_cse_pro']) {
    await startRefused(beginMock(named(customFirst), {examId}, mockDeps(MOCK_NOW + DAY)), COOLDOWN);
  }
  for (const examId of [b, c]) {
    const state = await serveMockAvailability(named(customFirst), {examId}, mockDeps(MOCK_NOW + DAY));
    assert.equal(state.status, 'cooldown');
    assert.equal(state.nextEligibleAt, MOCK_NOW + MIN + 30 * DAY);
  }
  assert.equal((await beginMock(named(customFirst), {examId: b}, mockDeps(MOCK_NOW + MIN + 30 * DAY))).resumed, false);
});

test('a Civil Service plan opens CSE and a custom mock inside the 30 days; a CSE pass opens only CSE', async () => {
  await seedCorpus();
  await seedCse();
  const uid = 'ct-m-paid', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'A', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  await submittedCse(uid, MOCK_NOW - 5 * DAY);
  const claims = {pro: true, proUntil: MOCK_NOW + 60 * DAY};
  // A pass belongs to one listed exam, so a custom exam stays on the Free window.
  await db.doc(`users/${uid}/grants/ct-pass`).set({source: 'paymongo', product: 'pantas_pass_cse_pro', tier: 'civilService',
    startsAt: MOCK_NOW - DAY, endsAt: MOCK_NOW + 60 * DAY, state: 'active', createdAt: MOCK_NOW - DAY});
  await startRefused(beginMock(named(uid, claims), {examId: id}, mockDeps()), COOLDOWN);
  const state = await serveMockAvailability(named(uid, claims), {examId: id}, mockDeps());
  assert.equal(state.status, 'cooldown');
  assert.equal(state.proCovered, false);
  await db.doc(`users/${uid}/grants/ct-pass`).delete();
  // The monthly Civil Service plan reaches a custom exam that keeps every subject.
  await paidCse(uid);
  const covered = await serveMockAvailability(named(uid, claims), {examId: id}, mockDeps());
  assert.equal(covered.status, 'available');
  assert.equal(covered.proCovered, true);
  const custom = await beginMock(named(uid, claims), {examId: id}, mockDeps());
  assert.equal(custom.resumed, false);
  assert.equal('examName' in custom, true, 'a custom mock has a name');
});

test('a Student plan opens a custom mock only while General Information is not kept', async () => {
  await seedCorpus();
  await seedCse();
  const uid = 'ct-m-student', id = newId();
  await reset(uid);
  await save(uid, id, {customTrack: {name: 'A', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  await submittedCse(uid, MOCK_NOW - 5 * DAY);
  await db.doc(`users/${uid}/grants/ct-student`).set({source: 'paymongo', product: 'pantas_pro_monthly', tier: 'student',
    startsAt: MOCK_NOW - DAY, endsAt: MOCK_NOW + 60 * DAY, state: 'active', createdAt: MOCK_NOW - DAY});
  await startRefused(beginMock(named(uid), {examId: id}, mockDeps()), COOLDOWN);
  assert.equal((await serveMockAvailability(named(uid), {examId: id}, mockDeps())).proCovered, false);
  await db.doc(`users/${uid}/server/settings`).update({excludedTopicIds: GENERAL_INFORMATION});
  assert.equal((await serveMockAvailability(named(uid), {examId: id}, mockDeps())).status, 'available');
  assert.equal((await beginMock(named(uid), {examId: id}, mockDeps())).resumed, false);
});

test('another account cannot start, read or list this account\'s custom mock', async () => {
  await seedCorpus();
  const a = 'ct-m-sec-a', b = 'ct-m-sec-b', id = newId();
  await reset(a); await reset(b);
  await save(a, id, {customTrack: {name: 'Secret', blueprint: blueprint(MOCK_NOW)}}, MOCK_NOW);
  const out = await beginMock(named(a), {examId: id}, mockDeps());
  await assert.rejects(beginMock(named(b), {examId: id}, mockDeps()), e => e.code === 'failed-precondition' && e.message === 'This exam has no mock yet.');
  assert.equal((await serveMockAvailability(named(b), {examId: id}, mockDeps())).status, 'no-blueprint');
  await assert.rejects(serveMockResults(named(b), {mockId: out.mockId}, mockDeps()), e => e.code === 'not-found');
  assert.deepEqual((await serveMockHistory(named(b), {}, mockDeps())).items, []);
  assert.equal((await db.collection(`users/${b}/server/mocks/items`).get()).size, 0);
});
