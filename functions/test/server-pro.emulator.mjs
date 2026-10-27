import '../lib/index.js';
import assert from 'node:assert/strict';
import test, {before} from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {serveContent} from '../lib/content.js';
import {recordSession, MAX_ANSWERS} from '../lib/ingestSession.js';
import {catalogItems, lessonItem, questionSetItems, writeContent} from '../lib/contentUpload.js';

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

before(async () => {
  for (const uid of ['c-pro', 'cat-pro', 'pas-pro']) {
    await reset(uid);
    await db.doc(`users/${uid}/grants/test`).set({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + DAY, state: 'active'});
  }
  await reset('c-v');
});

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

test('a covered account gets wrong-choice notes; claims alone grant nothing', async () => {
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
  await db.doc('users/c-v/grants/test').set({source: 'paymongo', product: 'pantas_cs_monthly', tier: 'civilService', startsAt: NOW - DAY, endsAt: NOW + DAY, state: 'active'});
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

// ---- catalog and passages ----------------------------------------------------------------------
const stamp = '2026-01-01T00:00:00.000Z';
const row = (id, fields) => ({_id: id, _updatedAt: stamp, schemaVersion: 1, isActive: true, ...fields});
const pset = questionSetItems({
  meta: {subject: 's', topic: 'pt', subtopic: 'pu', exams: ['upcat']},
  passages: [{id: 'pp-1', title: 'PASS-TITLE', body: 'PASS-BODY words here.'}],
  questions: [{id: 'pq1', passage: 'pp-1', stem: 'STEM-PRIVATE', explanation: 'EXPL-PRIVATE',
    choices: [{text: 'CHOICE-PRIVATE', correct: true}, {text: 'b', rationale: 'NOTE-PRO'}]}],
}, 's/pt/pu.yaml');
const catalog = catalogItems({
  structure: {
    exam: [row('exam_upcat', {code: 'CATX', name: 'X', shortName: 'X', language: 'en', ordering: 1})],
    subject: [row('subj_upcat_s', {exam: {_ref: 'exam_upcat'}, name: 'S', ordering: 1})],
    topic: [row('topic_upcat_pt', {subject: {_ref: 'subj_upcat_s'}, name: 'PT', ordering: 1})],
  },
  lessons: [{_id: 'lesson-pt-pu', title: 'T', summary: 'S', topic: 'topic-pt', estimatedMinutes: 3}],
  sets: [{source: {meta: {subject: 's', topic: 'pt', subtopic: 'pu', exams: ['upcat']}, passages: [{id: 'pp-1', title: 'PASS-TITLE', body: 'PASS-BODY words here.'}],
    questions: [{id: 'pq1', passage: 'pp-1', stem: 'STEM-PRIVATE', explanation: 'EXPL-PRIVATE', choices: [{text: 'CHOICE-PRIVATE', correct: true}]}]}, relativePath: 's/pt/pu.yaml'}],
});

test('the catalog is uploaded, served to every tier alike, and holds no text', async () => {
  await writeContent(db, [pset.item, ...catalog], pset.pro ? [pset.pro] : [], {});
  const free = await serveContent(named('cat-free'), {kind: 'catalog', ids: ['index', 'exam_upcat'], knownVersions: {}}, deps({allow: async () => true}));
  const proOut = await serveContent(pro('cat-pro'), {kind: 'catalog', ids: ['index', 'exam_upcat'], knownVersions: {}}, deps({allow: async () => true}));
  assert.equal(free.tier, 'free');
  assert.deepEqual(free.items.index.data.catalogs, ['exam_upcat']);
  assert.equal(free.items.exam_upcat.data.id, 'exam_upcat');
  assert.deepEqual(free.items.exam_upcat.data.sets[0].questions, [{id: 'pq1', passage: 'pp-1'}]);
  assert.deepEqual(free.items.exam_upcat.data.lessons[0].id, 'lesson-pt-pu');
  const text = JSON.stringify(free);
  for (const secret of ['STEM-PRIVATE', 'EXPL-PRIVATE', 'CHOICE-PRIVATE', 'NOTE-PRO', 'PASS-BODY', 'PASS-TITLE']) assert.equal(text.includes(secret), false, secret);
  assert.deepEqual(proOut.items.exam_upcat.data, free.items.exam_upcat.data);
  assert.match(free.items.index.version, /\.f$/);
  assert.match(proOut.items.index.version, /\.p$/);
});

test('catalog ids are validated like any other: unknown is missing, same version is unchanged', async () => {
  const d = deps({allow: async () => true});
  const out = await serveContent(named('cat-x'), {kind: 'catalog', ids: ['index', 'exam_nope', 'exam_upcat.nope'], knownVersions: {}}, d);
  assert.equal(out.items.exam_nope.status, 'missing');
  assert.equal(out.items['exam_upcat.nope'].status, 'missing');
  const again = await serveContent(named('cat-x'), {kind: 'catalog', ids: ['index'], knownVersions: {index: out.items.index.version}}, d);
  assert.equal(again.items.index.status, 'unchanged');
  assert.equal(await code(serveContent(undefined, {kind: 'catalog', ids: ['index'], knownVersions: {}}, d)), 'unauthenticated');
  assert.equal(await code(serveContent(named('cat-x'), {kind: 'catalog', ids: ['../x'], knownVersions: {}}, d)), 'invalid-argument');
});

test('catalog ids use their own daily budget, so app starts never spend the content budget', async () => {
  await reset('cat-limit');
  const d = deps({dailyIds: 1, dailyCatalogIds: 3});
  const ask = ids => serveContent(named('cat-limit'), {kind: 'catalog', ids, knownVersions: {}}, d);
  assert.equal(await code(ask(['index', 'exam_upcat'])), 'ok');
  assert.equal(await code(ask(['index', 'exam_upcat'])), 'resource-exhausted');
  assert.equal(await code(ask(['index'])), 'ok');
  // The content budget of 1 is still whole after three catalog ids.
  assert.equal(await code(serveContent(named('cat-limit'), {kind: 'questions', ids: [pset.item.id], knownVersions: {}}, d)), 'ok');
});

test('a set serves its passages to a Free account, with the Pro notes kept out', async () => {
  const d = deps({allow: async () => true});
  const free = await serveContent(named('pas-free'), {kind: 'questions', ids: [pset.item.id], knownVersions: {}}, d);
  const data = free.items[pset.item.id].data;
  assert.deepEqual(data.passages, [{id: 'pp-1', topic: 'topic_upcat_pt', title: 'PASS-TITLE', body: 'PASS-BODY words here.', language: 'en', wordCount: 3}]);
  assert.equal(JSON.stringify(free).includes('NOTE-PRO'), false);
  const paid = await serveContent(pro('pas-pro'), {kind: 'questions', ids: [pset.item.id], knownVersions: {}}, d);
  assert.deepEqual(paid.items[pset.item.id].data.passages, data.passages);
  assert.equal(JSON.stringify(paid).includes('NOTE-PRO'), true);
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
