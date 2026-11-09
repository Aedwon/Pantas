import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {clearExamContentCache} from '../lib/_examContent.js';
import {readStudyInsights} from '../lib/studyInsights.js';
import {readStudyRoadmap, saveExamSettings, checkSettings} from '../lib/roadmap.js';
import {emptyTotals, toDoc} from '../lib/_answerTotals.js';
import {mockCoverage} from '../lib/mockAccess.js';
import {randomUUID} from 'node:crypto';

// A student answered on Sub-Professional (SUB), then switched to Professional (PRO).
// s1 and s2 are on both exams, a1 is Sub only, b1 is Pro only.
const db = getFirestore(), NOW = Date.parse('2026-10-24T10:00:00+08:00'), DAY = 86_400_000;
const PRO = 'exam_cse_pro', SUB = 'exam_cse_sub';
const auth = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const deps = () => ({db, now: () => NOW, allow: async () => true});
const body = uid => ({expectedUid: uid, examId: PRO});
const code = async p => { try { await p; return 'ok'; } catch (e) { return e.code ?? String(e); } };
async function catalog(exam, questionIds) {
  const numerical = {_id: 'topic_cse_pro_arithmetic_number_sense', name: 'Arithmetic & Number Sense', subject: 'subject-' + exam, ordering: 1};
  const topic = {_id: 'topic_cse_pro_vocabulary', name: 'Vocabulary', subject: 'subject-' + exam, ordering: 0};
  await db.doc('content/catalog/items/' + exam).set({version: 'v1', payload: JSON.stringify({
    id: exam, subjects: [{_id: 'subject-' + exam, name: 'Subject ' + exam, exam, ordering: 0}], topics: [topic, numerical], lessons: [],
    sets: [{id: 'set-' + exam, topic: topic._id, lesson: null, exams: [exam], questions: questionIds.filter(id => id !== 'b1').map(id => ({id}))},
      {id: 'numerical-' + exam, topic: numerical._id, lesson: null, exams: [exam], questions: questionIds.filter(id => id === 'b1').map(id => ({id}))}]})});
}
const session = (id, examId, origin, answers) => ({sessionId: id, examId, origin, startedAt: NOW - 2000, finishedAt: NOW - 1000,
  durationMs: 1000, answers: answers.map(([questionId, correct]) => ({questionId, chosen: questionId + '_a', correct, answeredAt: NOW - 1500}))});
async function seed(uid, flag) {
  clearExamContentCache();
  await db.recursiveDelete(db.doc('users/' + uid));
  await catalog(PRO, ['s1', 's2', 'b1']);
  await catalog(SUB, ['a1', 's1', 's2']);
  await db.doc('users/' + uid + '/server/settings').set({examId: PRO, examDate: null, studyDays: [1, 2, 3, 4, 5, 6, 7],
    assessmentCompleted: true, updatedAt: NOW, ...(flag === undefined ? {} : {carryOverProgress: flag})});
  await db.doc('users/' + uid + '/server/answerTotals').set(toDoc(emptyTotals()));
  const items = db.collection('users/' + uid + '/server/answers/items');
  await items.doc('sub-quiz').set(session('sub-quiz', SUB, 'drill', [['a1', true], ['s1', true], ['s2', false]]));
  await items.doc('sub-mock').set(session('sub-mock', SUB, 'mock', [['s1', true], ['s2', true]]));
  await items.doc('pro-quiz').set(session('pro-quiz', PRO, 'drill', [['b1', true]]));
}
// Carry-over on: (30 * 1/2 verbal + 30 * 1/1 numerical) / 60 = 0.75.
// Carry-over off: only numerical has answers, so (30 * 1/1) / 30 = 1.
const overall = r => r.performance.overall;

test('carry-over on counts Sub answers on questions Pro also has, and not Sub-only or mock work', async () => {
  const uid = 'carry-fig-on';
  await seed(uid, true);
  const r = await readStudyInsights(auth(uid), body(uid), deps());
  // s1 right, s2 wrong from the Sub quiz; b1 right under Pro. a1 is not in Pro's pool. The Sub mock is not carried.
  assert.deepEqual(overall(r), {correct: 2, answered: 3, accuracy: .75});
  assert.deepEqual(r.performance.subjects.map(s => [s.id, s.correct, s.answered]), [['verbal_ability', 1, 2], ['numerical_ability', 1, 1]]);
});

test('carry-over off counts only what was answered under the current exam', async () => {
  const uid = 'carry-fig-off';
  await seed(uid, false);
  const r = await readStudyInsights(auth(uid), body(uid), deps());
  assert.deepEqual(overall(r), {correct: 1, answered: 1, accuracy: 1});
});

test('a settings document with no flag counts as on', async () => {
  const uid = 'carry-fig-default';
  await seed(uid, undefined);
  assert.deepEqual(overall(await readStudyInsights(auth(uid), body(uid), deps())), {correct: 2, answered: 3, accuracy: .75});
});

test('flipping the flag changes the figures at once, in both directions, and loses nothing', async () => {
  const uid = 'carry-fig-flip';
  await seed(uid, true);
  assert.deepEqual(overall(await readStudyInsights(auth(uid), body(uid), deps())), {correct: 2, answered: 3, accuracy: .75});
  await db.doc('users/' + uid + '/server/settings').update({carryOverProgress: false});
  assert.deepEqual(overall(await readStudyInsights(auth(uid), body(uid), deps())), {correct: 1, answered: 1, accuracy: 1});
  await db.doc('users/' + uid + '/server/settings').update({carryOverProgress: true});
  assert.deepEqual(overall(await readStudyInsights(auth(uid), body(uid), deps())), {correct: 2, answered: 3, accuracy: .75});
});

test('the choice never changes today or any due date', async () => {
  const uid = 'carry-fig-schedule';
  const roadmap = async flag => {
    await seed(uid, flag);
    const out = await readStudyRoadmap(auth(uid), body(uid), deps());
    return {today: out.today, remaining: out.remaining};
  };
  assert.deepEqual(await roadmap(true), await roadmap(false));
});

test('the settings write stores the flag, rejects a non-boolean, and leaves it out when not sent', async () => {
  const uid = 'carry-fig-save';
  await seed(uid, true);
  const settings = {...body(uid), examDate: null, studyDays: [1, 2, 3]};
  assert.equal(checkSettings({...settings, carryOverProgress: false}).carryOverProgress, false);
  assert.equal('carryOverProgress' in checkSettings(settings), false);
  assert.equal(await code(saveExamSettings(auth(uid), {...settings, carryOverProgress: 'no'}, deps())), 'invalid-argument');
  assert.equal(await code(saveExamSettings(auth(uid), {...settings, carryOverProgress: false}, deps())), 'ok');
  assert.equal((await db.doc('users/' + uid + '/server/settings').get()).get('carryOverProgress'), false);
  assert.deepEqual(overall(await readStudyInsights(auth(uid), body(uid), deps())), {correct: 1, answered: 1, accuracy: 1});
});

test('carry-over weights rated areas without replacing raw answer counts', async () => {
  const uid = 'carry-fig-weighted';
  await seed(uid, true);
  const r = await readStudyInsights(auth(uid), body(uid), deps());
  // Verbal: 1/2 at weight 30. Numerical: 1/1 at weight 30.
  // (30 * 1/2 + 30 * 1/1) / (30 + 30) = 0.75, while raw counts stay 2/3.
  assert.deepEqual(overall(r), {correct: 2, answered: 3, accuracy: .75});
});

test('a listed exam keeps the same cache key as before custom exams, so no stored figure is lost', async () => {
  const uid = 'carry-fig-pin';
  await seed(uid, true);
  await db.doc('content/catalog/items/index').delete();
  clearExamContentCache();
  await readStudyInsights(auth(uid), body(uid), deps());
  assert.equal((await db.doc('users/' + uid + '/server/studyInsights').get()).get('sourceRevision'),
    '["exam_cse_pro","exam_cse_pro:v1",0,0,"2026-10-24",true,"topic-details-v3-unmet-requirements"]');
});

// ---- a custom exam: the whole corpus, filtered by the ticked subjects ----
// Math has m1 to m3 and Language has l1 and l2, in two catalogs. The student answered under Professional (carried)
// and under the custom exam (own). m1 and l1 were answered under Professional, m3 in a Professional mock, which is never carried.
const CUSTOM = 'exam_custom_' + randomUUID();
const customAuth = (uid, token = {firebase: {sign_in_provider: 'anonymous'}}) => ({uid, token});
const customBody = uid => ({expectedUid: uid, examId: CUSTOM});
async function customCorpus() {
  const math = {_id: 'subj-math', name: 'Math', exam: 'exam_cx', ordering: 1}, lang = {_id: 'subj-lang', name: 'Language', exam: 'exam_cy', ordering: 2};
  const tMath = {_id: 'topic-math', name: 'Math topic', subject: 'subj-math', ordering: 1}, tLang = {_id: 'topic-lang', name: 'Language topic', subject: 'subj-lang', ordering: 1};
  const set = (id, topic, ids) => ({id, topic, lesson: null, exams: ['exam_cx', 'exam_cy'], questions: ids.map(q => ({id: q}))});
  const put = (id, value) => db.doc('content/catalog/items/' + id).set({version: 'v1', payload: JSON.stringify(value)});
  await put('index', {subjects: [math, lang], topics: [tMath, tLang], catalogs: ['exam_cx', 'exam_cy']});
  await put('exam_cx', {id: 'exam_cx', sets: [set('set-math', 'topic-math', ['m1', 'm2', 'm3'])]});
  await put('exam_cy', {id: 'exam_cy', sets: [set('set-lang', 'topic-lang', ['l1', 'l2'])]});
  clearExamContentCache();
}
async function seedCustom(uid, {carry, excluded = []} = {}) {
  await db.recursiveDelete(db.doc('users/' + uid));
  await customCorpus();
  await db.doc('users/' + uid + '/server/settings').set({examId: CUSTOM, examDate: null, studyDays: [1, 2, 3, 4, 5, 6, 7], assessmentCompleted: true,
    updatedAt: NOW, excludedTopicIds: excluded, excludedLessonIds: [], ...(carry === undefined ? {} : {carryOverProgress: carry})});
  await db.doc('users/' + uid + '/server/answerTotals').set(toDoc(emptyTotals()));
  const items = db.collection('users/' + uid + '/server/answers/items');
  // zz9 is not in the corpus: a phone's bundle can hold ids the catalog lacks.
  await items.doc('pro-quiz').set(session('pro-quiz', PRO, 'drill', [['m1', true], ['l1', false], ['zz9', true]]));
  await items.doc('pro-mock').set(session('pro-mock', PRO, 'mock', [['m3', true]]));
  await items.doc('own-quiz').set(session('own-quiz', CUSTOM, 'drill', [['m2', false], ['l2', true]]));
}
const bySubject = r => r.performance.subjects.map(s => [s.id, s.correct, s.answered]);
const storedKey = async uid => (await db.doc('users/' + uid + '/server/studyInsights').get()).get('sourceRevision');

test('a custom exam counts a carried answer only in a ticked subject, and never a mock or an id outside the corpus', async () => {
  const uid = 'carry-cus-on';
  await seedCustom(uid, {carry: true});
  const all = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.deepEqual(overall(all), {correct: 2, answered: 4});
  assert.deepEqual(bySubject(all), [['subj-math', 1, 2], ['subj-lang', 1, 2]]);
  await seedCustom(uid, {carry: true, excluded: ['topic-lang']});
  const math = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.deepEqual(overall(math), {correct: 1, answered: 2}, 'the carried and the own Language answers are both hidden');
  assert.deepEqual(bySubject(math), [['subj-math', 1, 2]]);
});

test('a custom exam with carry-over off counts only its own sessions', async () => {
  const uid = 'carry-cus-off';
  await seedCustom(uid, {carry: false});
  const r = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.deepEqual(overall(r), {correct: 1, answered: 2});
  await seedCustom(uid, {carry: false, excluded: ['topic-math']});
  assert.deepEqual(overall(await readStudyInsights(customAuth(uid), customBody(uid), deps())), {correct: 1, answered: 1});
  await seedCustom(uid, undefined);
  assert.deepEqual(overall(await readStudyInsights(customAuth(uid), customBody(uid), deps())), {correct: 2, answered: 4}, 'no flag counts as on');
});

test('narrowing hides figures at once, with the answers kept, and ticking the subject again restores them', async () => {
  const uid = 'carry-cus-narrow';
  await seedCustom(uid, {carry: true});
  const settings = db.doc('users/' + uid + '/server/settings');
  const wide = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  const wideKey = await storedKey(uid);
  await settings.update({excludedTopicIds: ['topic-lang']});
  // Same day, same sessions, same observation count: only the stored cache key can tell the two apart.
  const narrow = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.deepEqual(overall(narrow), {correct: 1, answered: 2});
  assert.notEqual(await storedKey(uid), wideKey, 'the excluded lists are part of the cache key');
  assert.notEqual(narrow.revision, wide.revision);
  await settings.update({excludedTopicIds: []});
  const again = await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.deepEqual(overall(again), {correct: 2, answered: 4});
  assert.equal(await storedKey(uid), wideKey);
  assert.equal(again.revision, wide.revision);
  await settings.update({excludedLessonIds: ['no-such-lesson']});
  await readStudyInsights(customAuth(uid), customBody(uid), deps());
  assert.notEqual(await storedKey(uid), wideKey, 'a lesson list change is a new key too');
  assert.equal((await db.collection('users/' + uid + '/server/answers/items').get()).size, 3, 'narrowing deletes no session');
});

test('a custom response is Free depth only, even with a paid grant for a listed exam and a live Pro claim', async () => {
  const uid = 'carry-cus-free';
  await seedCustom(uid, {carry: true});
  await db.doc('users/' + uid + '/grants/paid').set({source: 'paymongo', product: 'pantas_pass_cse_pro', tier: 'civilService',
    startsAt: NOW - DAY, endsAt: NOW + DAY, state: 'active', createdAt: NOW - DAY});
  assert.equal((await db.runTransaction(tx => mockCoverage(tx, db, uid, NOW))).coversExam(PRO), true, 'the grant does cover Professional');
  for (const token of [{firebase: {sign_in_provider: 'google.com'}}, {pro: true, proUntil: NOW + DAY, firebase: {sign_in_provider: 'google.com'}}]) {
    const r = await readStudyInsights(customAuth(uid, token), customBody(uid), deps());
    assert.equal(r.proCovered, false);
    assert.equal(r.trialEndsAt, null);
    for (const field of ['tendencies', 'whenYouWork']) assert.equal(field in r, false, field);
    for (const field of ['topics', 'lessons', 'topicDetails']) assert.equal(field in r.performance, false, field);
    assert.deepEqual(Object.keys(r.performance).sort(), ['lessonLevelAvailable', 'overall', 'subjects']);
  }
});

test('a custom exam with no settings asks to set the exam first, and one named by other settings says it changed', async () => {
  const uid = 'carry-cus-settings';
  await seedCustom(uid, {carry: true});
  await db.doc('users/' + uid + '/server/settings').update({examId: PRO});
  assert.equal(await code(readStudyInsights(customAuth(uid), customBody(uid), deps())), 'failed-precondition');
  await assert.rejects(readStudyInsights(customAuth(uid), customBody(uid), deps()), e => e.message === 'Your exam changed. Open this screen again.');
  await db.doc('users/' + uid + '/server/settings').delete();
  await assert.rejects(readStudyInsights(customAuth(uid), customBody(uid), deps()), e => e.code === 'failed-precondition' && e.message === 'Set your exam first.');
  // A listed exam keeps its tolerance: no settings is not an error.
  await seed(uid, true);
  await db.doc('users/' + uid + '/server/settings').delete();
  assert.equal(await code(readStudyInsights(auth(uid), body(uid), deps())), 'ok');
});

test('a malformed custom id is still Unknown exam', async () => {
  const uid = 'carry-cus-bad';
  for (const examId of ['exam_custom', 'exam_custom_' + randomUUID().toUpperCase(), 'exam_custom_' + randomUUID() + 'x']) {
    await assert.rejects(readStudyInsights(customAuth(uid), {expectedUid: uid, examId}, deps()), e => e.code === 'invalid-argument' && e.message === 'Unknown exam.');
  }
});

test('custom corpus cleanup', async () => {
  for (const id of ['index', 'exam_cx', 'exam_cy']) await db.doc('content/catalog/items/' + id).delete();
  clearExamContentCache();
});
