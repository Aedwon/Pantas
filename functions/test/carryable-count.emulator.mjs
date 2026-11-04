import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {clearExamContentCache} from '../lib/_examContent.js';
import {addSession, emptyTotals, toDoc} from '../lib/_answerTotals.js';
import {readCarryableCount} from '../lib/carryableCount.js';
import {randomUUID} from 'node:crypto';
const db = getFirestore(), PRO = 'exam_cse_pro', SUB = 'exam_cse_sub';
const auth = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const deps = {db, allow: async () => true};
const code = async p => { try { await p; return 'ok'; } catch (e) { return e.code ?? String(e); } };
async function catalog(exam, questionIds) {
  const topic = {_id: 'topic-' + exam, name: 'Topic', subject: 'subject-' + exam, ordering: 0};
  await db.doc('content/catalog/items/' + exam).set({version: 'v1', payload: JSON.stringify({
    id: exam, subjects: [{_id: 'subject-' + exam, name: 'Subject', exam, ordering: 0}], topics: [topic], lessons: [],
    sets: [{id: 'set-' + exam, topic: topic._id, lesson: null, exams: [exam], questions: questionIds.map(id => ({id}))}]})});
}
async function seed(uid, answered) {
  clearExamContentCache();
  await db.recursiveDelete(db.doc('users/' + uid));
  await catalog(PRO, ['q1', 'q2', 'q3', 'q4']);
  await catalog(SUB, ['q2', 'q3', 'q5']);
  const totals = emptyTotals();
  addSession(totals, answered.map(questionId => ({questionId, chosen: 'a', correct: true, answeredAt: Date.now()})));
  await db.doc('users/' + uid + '/server/answerTotals').set(toDoc(totals));
}
test('counts answered questions the target exam also has, once each', async () => {
  const uid = 'carry-count';
  // q1 and q4 are Professional only, q2 and q3 are on both, q9 is on neither. q2 is answered twice.
  await seed(uid, ['q1', 'q2', 'q2', 'q3', 'q4', 'q9']);
  assert.deepEqual(await readCarryableCount(auth(uid), {expectedUid: uid, examId: SUB}, deps), {count: 2});
  assert.deepEqual(await readCarryableCount(auth(uid), {expectedUid: uid, examId: PRO}, deps), {count: 4});
});
test('a student with no answers has nothing to carry', async () => {
  const uid = 'carry-none';
  await seed(uid, []);
  assert.deepEqual(await readCarryableCount(auth(uid), {expectedUid: uid, examId: SUB}, deps), {count: 0});
});
test('refuses a missing sign-in, another account and an unknown exam', async () => {
  const uid = 'carry-refuse';
  await seed(uid, ['q2']);
  assert.equal(await code(readCarryableCount(undefined, {expectedUid: uid, examId: SUB}, deps)), 'unauthenticated');
  assert.equal(await code(readCarryableCount(auth(uid), {expectedUid: 'other', examId: SUB}, deps)), 'failed-precondition');
  assert.equal(await code(readCarryableCount(auth(uid), {expectedUid: uid, examId: 'exam_nope'}, deps)), 'invalid-argument');
});

// ---- a custom exam: the whole corpus, minus the exclusions of the target's own track ----
// Math has m1 and m2 (no lesson) and m3 (in lesson les-m). Language has l1 and l2.
const customId = () => 'exam_custom_' + randomUUID();
async function customCorpus() {
  const math = {_id: 'subj-math', name: 'Math', exam: 'exam_cx', ordering: 1}, lang = {_id: 'subj-lang', name: 'Language', exam: 'exam_cy', ordering: 2};
  const tMath = {_id: 'topic-math', name: 'Math', subject: 'subj-math', ordering: 1}, tLang = {_id: 'topic-lang', name: 'Language', subject: 'subj-lang', ordering: 1};
  const set = (id, topic, lesson, ids) => ({id, topic, lesson, exams: ['exam_cx', 'exam_cy'], questions: ids.map(q => ({id: q}))});
  const put = (id, value) => db.doc('content/catalog/items/' + id).set({version: 'v1', payload: JSON.stringify(value)});
  await put('index', {subjects: [math, lang], topics: [tMath, tLang], catalogs: ['exam_cx', 'exam_cy']});
  await put('exam_cx', {id: 'exam_cx', lessons: [{id: 'les-m', topic: 'topic-math', title: 'Lesson', ordering: 1}],
    sets: [set('set-math', 'topic-math', null, ['m1', 'm2']), set('set-math-lesson', 'topic-math', 'les-m', ['m3'])]});
  await put('exam_cy', {id: 'exam_cy', sets: [set('set-lang', 'topic-lang', null, ['l1', 'l2'])]});
  clearExamContentCache();
}
async function seedCustom(uid, answered) {
  await db.recursiveDelete(db.doc('users/' + uid));
  await customCorpus();
  const totals = emptyTotals();
  addSession(totals, answered.map(questionId => ({questionId, chosen: 'a', correct: true, answeredAt: Date.now()})));
  await db.doc('users/' + uid + '/server/answerTotals').set(toDoc(totals));
}
const putTrack = (uid, examId, excludedTopicIds, excludedLessonIds) => db.doc(`users/${uid}/server/customTracks/items/${examId}`)
  .set({examId, name: null, excludedTopicIds, excludedLessonIds, blueprint: null, createdAt: 1, updatedAt: 1});
const count = (uid, examId) => readCarryableCount(auth(uid), {expectedUid: uid, examId}, deps);

test('a custom target with no track counts every answered question in the corpus, once each', async () => {
  const uid = 'carry-cus-none', id = customId();
  // zz9 is on no catalog. m1 is answered twice.
  await seedCustom(uid, ['m1', 'm1', 'm3', 'l1', 'zz9']);
  assert.deepEqual(await count(uid, id), {count: 3});
  assert.equal((await db.doc(`users/${uid}/server/customTracks/items/${id}`).get()).exists, false, 'a count creates nothing');
});

test('a custom target takes away the topics and lessons its own track excludes', async () => {
  const uid = 'carry-cus-track', id = customId();
  await seedCustom(uid, ['m1', 'm3', 'l1', 'zz9']);
  await putTrack(uid, id, [], []);
  assert.deepEqual(await count(uid, id), {count: 3});
  await putTrack(uid, id, ['topic-lang'], []);
  assert.deepEqual(await count(uid, id), {count: 2});
  await putTrack(uid, id, [], ['les-m']);
  assert.deepEqual(await count(uid, id), {count: 2});
  await putTrack(uid, id, ['topic-math'], ['les-m']);
  assert.deepEqual(await count(uid, id), {count: 1});
  await putTrack(uid, id, ['topic-math', 'topic-lang'], []);
  assert.deepEqual(await count(uid, id), {count: 0});
});

test('the custom target need not be the current exam, and the count is the same for any caller who owns the totals', async () => {
  const uid = 'carry-cus-current', id = customId(), other = customId();
  await seedCustom(uid, ['m1', 'l1', 'l2']);
  await putTrack(uid, id, ['topic-lang'], []);
  await db.doc(`users/${uid}/server/settings`).set({examId: PRO, examDate: null, studyDays: [1], updatedAt: 1});
  assert.deepEqual(await count(uid, id), {count: 1});
  assert.deepEqual(await count(uid, other), {count: 3}, 'another id of this account has no track, so no exclusions');
});

test('a malformed custom id is Unknown exam, and the other refusals hold for a custom id', async () => {
  const uid = 'carry-cus-refuse';
  await seedCustom(uid, ['m1']);
  for (const examId of ['exam_custom', 'exam_custom_' + randomUUID().toUpperCase(), 'exam_custom_' + randomUUID() + '/x']) {
    await assert.rejects(count(uid, examId), e => e.code === 'invalid-argument' && e.message === 'Unknown exam.');
  }
  const id = customId();
  assert.equal(await code(readCarryableCount(undefined, {expectedUid: uid, examId: id}, deps)), 'unauthenticated');
  assert.equal(await code(readCarryableCount(auth(uid), {expectedUid: 'other', examId: id}, deps)), 'failed-precondition');
  assert.equal(await code(readCarryableCount(auth(uid), {examId: id}, deps)), 'invalid-argument');
  assert.equal(await code(readCarryableCount(auth(uid), {expectedUid: uid, examId: id}, {...deps, allow: async () => false})), 'resource-exhausted');
});

test('custom corpus cleanup', async () => {
  for (const id of ['index', 'exam_cx', 'exam_cy']) await db.doc('content/catalog/items/' + id).delete();
  clearExamContentCache();
});
