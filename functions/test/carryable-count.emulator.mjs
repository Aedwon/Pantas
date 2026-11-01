import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {clearExamContentCache} from '../lib/_examContent.js';
import {addSession, emptyTotals, toDoc} from '../lib/_answerTotals.js';
import {readCarryableCount} from '../lib/carryableCount.js';
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
