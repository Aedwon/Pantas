import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {serveContent} from '../lib/content.js';
import {recordSession, MAX_ANSWERS} from '../lib/ingestSession.js';
import {lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const DAY = 86400000;
const NOW = Date.parse('2026-11-20T10:00:00+08:00');
const named = (uid, claims = {}) => ({uid, token: {firebase: {sign_in_provider: 'google.com'}, ...claims}});
const anon = (uid, claims = {}) => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}, ...claims}});
const pro = uid => named(uid, {pro: true, proUntil: NOW + DAY});
const expiredPro = uid => named(uid, {pro: true, proUntil: NOW - 1});
const code = async promise => {try {await promise; return 'ok';} catch (e) {assert.equal(typeof e.code, 'string', String(e)); return e.code;}};
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const deps = (extra = {}) => ({db, now: () => NOW, ...extra});

const lesson = lessonItem({_id: 'lesson-t1', title: 'T', summary: 'S', subject: 's', topic: 't', estimatedMinutes: 4}, '## Body');
const qset = questionSetItems({
  meta: {subject: 's', topic: 't', subtopic: 'u', exams: ['cse-pro']},
  questions: [{id: 'q1', stem: 'x', explanation: 'E', choices: [{text: 'a', correct: true}, {text: 'b', rationale: 'NOTE-B'}]}],
}, 's/t/u.yaml');

test('upload writes server-only documents, is idempotent, and a dry run writes nothing', async () => {
  // Only this file's own documents: other files seed their own content at the same time.
  for (const path of ['content/lessons/items/lesson-t1', `content/questions/items/${qset.item.id}`, `contentPro/${qset.item.id}`]) await db.doc(path).delete();
  const items = [lesson, qset.item];
  const pros = [qset.pro];
  const dry = await writeContent(db, items, pros, {dryRun: true});
  assert.deepEqual(dry.counts, {create: 2, update: 0, unchanged: 0});
  assert.equal((await db.doc('content/lessons/items/lesson-t1').get()).exists, false);
  const first = await writeContent(db, items, pros, {});
  assert.deepEqual(first.counts, {create: 2, update: 0, unchanged: 0});
  assert.equal((await db.doc(`content/questions/items/${qset.item.id}`).get()).get('version'), qset.item.data.version);
  assert.equal((await db.doc(`contentPro/${qset.item.id}`).get()).exists, true);
  const again = await writeContent(db, items, pros, {});
  assert.deepEqual(again.counts, {create: 0, update: 0, unchanged: 2});
});

test('a Free account gets no Pro fields; an anonymous account is allowed', async () => {
  for (const auth of [named('c-free'), anon('c-anon')]) {
    const out = await serveContent(auth, {kind: 'questions', ids: [qset.item.id], knownVersions: {}}, deps({allow: async () => true}));
    const entry = out.items[qset.item.id];
    assert.equal(entry.status, 'ok');
    assert.equal(out.tier, 'free');
    assert.equal(JSON.stringify(entry).includes('NOTE-B'), false);
    assert.equal(entry.data.questions[0].explanation, 'E');
  }
});

test('a Pro account gets wrong-choice notes; an expired Pro claim is treated as Free', async () => {
  const live = await serveContent(pro('c-pro'), {kind: 'questions', ids: [qset.item.id], knownVersions: {}}, deps({allow: async () => true}));
  assert.equal(live.tier, 'pro');
  assert.equal(live.items[qset.item.id].data.questions[0].choices[1].rationale, 'NOTE-B');
  for (const auth of [expiredPro('c-exp'), named('c-flag', {pro: true}), named('c-false', {pro: false, proUntil: NOW + DAY})]) {
    const out = await serveContent(auth, {kind: 'questions', ids: [qset.item.id], knownVersions: {}}, deps({allow: async () => true}));
    assert.equal(out.tier, 'free');
    assert.equal(JSON.stringify(out).includes('NOTE-B'), false);
  }
});

test('a matching known version returns unchanged; a Free version does not satisfy a Pro caller', async () => {
  const free = await serveContent(named('c-v'), {kind: 'questions', ids: [qset.item.id], knownVersions: {}}, deps({allow: async () => true}));
  const v = free.items[qset.item.id].version;
  const same = await serveContent(named('c-v'), {kind: 'questions', ids: [qset.item.id], knownVersions: {[qset.item.id]: v}}, deps({allow: async () => true}));
  assert.deepEqual(same.items[qset.item.id], {status: 'unchanged', version: v});
  const upgraded = await serveContent(pro('c-v'), {kind: 'questions', ids: [qset.item.id], knownVersions: {[qset.item.id]: v}}, deps({allow: async () => true}));
  assert.equal(upgraded.items[qset.item.id].status, 'ok');
  const stale = await serveContent(named('c-v'), {kind: 'lessons', ids: ['lesson-t1', 'lesson-nope'], knownVersions: {'lesson-t1': 'old'}}, deps({allow: async () => true}));
  assert.equal(stale.items['lesson-t1'].status, 'ok');
  assert.equal(stale.items['lesson-t1'].data.body, '## Body');
  assert.deepEqual(stale.items['lesson-nope'], {status: 'missing'});
});

test('serveContent validates input and refuses signed-out callers', async () => {
  const d = deps({allow: async () => true});
  assert.equal(await code(serveContent(undefined, {kind: 'lessons', ids: ['a'], knownVersions: {}}, d)), 'unauthenticated');
  assert.equal(await code(serveContent(named('c-bad'), {kind: 'secrets', ids: ['a'], knownVersions: {}}, d)), 'invalid-argument');
  assert.equal(await code(serveContent(named('c-bad'), {kind: 'lessons', ids: [], knownVersions: {}}, d)), 'invalid-argument');
  assert.equal(await code(serveContent(named('c-bad'), {kind: 'lessons', ids: Array.from({length: 21}, (_, i) => `l${i}`), knownVersions: {}}, d)), 'invalid-argument');
  assert.equal(await code(serveContent(named('c-bad'), {kind: 'lessons', ids: ['a/b'], knownVersions: {}}, d)), 'invalid-argument');
});

test('the daily limit counts requested ids and refuses once it is reached', async () => {
  await reset('c-limit');
  const d = deps({dailyIds: 3});
  const ask = ids => serveContent(named('c-limit'), {kind: 'lessons', ids, knownVersions: {}}, d);
  assert.equal(await code(ask(['lesson-t1', 'x2'])), 'ok');
  assert.equal(await code(ask(['lesson-t1', 'x2'])), 'resource-exhausted');
  assert.equal(await code(ask(['lesson-t1'])), 'ok');
  assert.equal(await code(ask(['lesson-t1'])), 'resource-exhausted');
});

const batch = (id, extra = {}) => ({sessionId: id, startedAt: NOW - 60000, finishedAt: NOW, durationMs: 60000,
  answers: [{questionId: 'q1', chosen: 'a', correct: true, answeredAt: NOW - 30000}, {questionId: 'q2', chosen: null, correct: false, answeredAt: NOW - 10000}], ...extra});

test('recordSession stores one server-only batch per session and a replay is idempotent', async () => {
  const uid = 'i-ok';
  await reset(uid);
  const d = deps({allow: async () => true});
  const first = await recordSession(anon(uid), batch('sess-0001'), d);
  assert.deepEqual(first, {sessionId: 'sess-0001', stored: true});
  const replay = await recordSession(anon(uid), batch('sess-0001', {durationMs: 1}), deps({allow: async () => true, now: () => NOW + 5000}));
  assert.deepEqual(replay, {sessionId: 'sess-0001', stored: false});
  const rows = await db.collection(`users/${uid}/server/answers/items`).get();
  assert.equal(rows.size, 1);
  const row = rows.docs[0].data();
  assert.equal(row.durationMs, 60000);
  assert.equal(row.receivedAt, NOW);
  assert.equal(row.answers.length, 2);
});

test('recordSession refuses signed-out callers, bad shapes and oversize batches', async () => {
  const d = deps({allow: async () => true});
  const u = named('i-bad');
  assert.equal(await code(recordSession(undefined, batch('sess-0002'), d)), 'unauthenticated');
  assert.equal(await code(recordSession(u, batch('x'), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess/0003'), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0004', {answers: []}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0005', {answers: Array.from({length: MAX_ANSWERS + 1}, () => batch('z').answers[0])}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0006', {durationMs: -1}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0007', {finishedAt: NOW + 3 * DAY}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0008', {answers: [{questionId: 'q', chosen: 'a', correct: 'yes', answeredAt: NOW}]}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, batch('sess-0009', {answers: [{questionId: 'q'.repeat(200), chosen: 'a', correct: true, answeredAt: NOW}]}), d)), 'invalid-argument');
  assert.equal(await code(recordSession(u, {...batch('sess-0010'), extra: 'x'.repeat(10)}, d)), 'ok');
  assert.equal((await db.doc('users/i-bad/server/answers/items/sess-0010').get()).get('extra'), undefined);
});

test('recordSession refuses once the per-account daily limit is reached', async () => {
  const uid = 'i-limit';
  await reset(uid);
  const d = deps({dailySessions: 2});
  assert.equal(await code(recordSession(named(uid), batch('sess-1001'), d)), 'ok');
  assert.equal(await code(recordSession(named(uid), batch('sess-1002'), d)), 'ok');
  assert.equal(await code(recordSession(named(uid), batch('sess-1003'), d)), 'resource-exhausted');
});
