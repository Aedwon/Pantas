import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {clearExamContentCache} from '../lib/_examContent.js';
import {readStudyInsights} from '../lib/studyInsights.js';
import {readStudyRoadmap, saveExamSettings, checkSettings} from '../lib/roadmap.js';
import {emptyTotals, toDoc} from '../lib/_answerTotals.js';

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
