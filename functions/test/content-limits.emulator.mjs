import '../lib/index.js';
import assert from 'node:assert/strict';
import test, {before} from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {serveContent, DAILY_CONTENT_IDS, DAILY_CATALOG_IDS, DAILY_CONTENT_REQUESTS, DAILY_CATALOG_REQUESTS} from '../lib/content.js';
import {lessonItem, writeContent} from '../lib/contentUpload.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const NOW = Date.parse('2026-11-20T10:00:00+08:00');
const ids = Array.from({length: 60}, (_, i) => `lim-lesson-${i}`);
const lessons = ids.map(id => lessonItem({_id: id, title: id, summary: 's', subject: 's', topic: 't', estimatedMinutes: 1}, '## Body'));
const as = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const reset = uid => db.recursiveDelete(db.doc(`users/${uid}`));
const count = async (uid, key) => (await db.doc(`users/${uid}/limits/${key}`).get()).get('count') ?? 0;
const ask = (uid, list, known = {}, extra = {}) =>
  serveContent(as(uid), {kind: 'lessons', ids: list, knownVersions: known}, {db, now: () => NOW, ceiling: null, ...extra});
const fail = async promise => { try { await promise; return null; } catch (e) { return e; } };
const okCount = out => Object.values(out.items).filter(e => e.status === 'ok').length;

before(async () => { await writeContent(db, lessons.map(l => l), [], {}); });

test('the account budgets are 300 delivered and 200 catalog, with a separate cap of 1000 requested ids for each', () => {
  assert.equal(DAILY_CONTENT_IDS, 300);
  assert.equal(DAILY_CATALOG_IDS, 200);
  assert.equal(DAILY_CONTENT_REQUESTS, 1000);
  assert.equal(DAILY_CATALOG_REQUESTS, 1000);
});

test('an ok item costs one delivered id; unchanged and missing cost none but count on the request cap', async () => {
  const uid = 'lim-cost';
  await reset(uid);
  const first = await ask(uid, ids.slice(0, 5));
  assert.equal(okCount(first), 5);
  assert.equal(await count(uid, 'getContent'), 5);
  const known = Object.fromEntries(Object.entries(first.items).map(([id, e]) => [id, e.version]));
  const again = await ask(uid, [...ids.slice(0, 5), 'lim-missing-1'], known);
  assert.deepEqual(Object.values(again.items).map(e => e.status).sort(), ['missing', 'unchanged', 'unchanged', 'unchanged', 'unchanged', 'unchanged']);
  assert.equal(await count(uid, 'getContent'), 5, 'unchanged and missing are free against the delivered allowance');
  assert.equal(await count(uid, 'getContentRequests'), 11, 'every requested id counts on the request cap');
});

test('a re-check of items already held works after the delivered allowance is used up', async () => {
  const uid = 'lim-spent';
  await reset(uid);
  const first = await ask(uid, ids.slice(0, 3), {}, {dailyIds: 3});
  const known = Object.fromEntries(Object.entries(first.items).map(([id, e]) => [id, e.version]));
  const check = await ask(uid, ids.slice(0, 3), known, {dailyIds: 3});
  assert.equal(Object.values(check.items).every(e => e.status === 'unchanged'), true);
  const err = await fail(ask(uid, ids.slice(3, 4), {}, {dailyIds: 3}));
  assert.equal(err.code, 'resource-exhausted');
  assert.equal(err.message, 'Daily content limit reached. Try again tomorrow.');
  assert.deepEqual(err.details, {kind: 'content', scope: 'delivered'});
});

test('items beyond the delivered allowance come back as limited, never as content', async () => {
  const uid = 'lim-partial';
  await reset(uid);
  const out = await ask(uid, ids.slice(0, 5), {}, {dailyIds: 3});
  const entries = Object.entries(out.items);
  assert.equal(entries.filter(([, e]) => e.status === 'ok').length, 3);
  const limited = entries.filter(([, e]) => e.status === 'limited');
  assert.equal(limited.length, 2);
  for (const [, e] of limited) assert.deepEqual(e, {status: 'limited'});
  assert.equal(await count(uid, 'getContent'), 3);
});

test('the request cap is checked before any document is read', async () => {
  const uid = 'lim-requests';
  await reset(uid);
  let reads = 0;
  const spy = new Proxy(db, {get(target, prop) {
    if (prop === 'doc') return path => { if (String(path).startsWith('content/')) reads++; return target.doc(path); };
    const value = Reflect.get(target, prop, target);
    return typeof value === 'function' ? value.bind(target) : value;
  }});
  await serveContent(as(uid), {kind: 'lessons', ids: ids.slice(0, 4), knownVersions: {}}, {db: spy, now: () => NOW, ceiling: null, dailyRequests: 6});
  const before = reads;
  const err = await fail(serveContent(as(uid), {kind: 'lessons', ids: ids.slice(4, 8), knownVersions: {}}, {db: spy, now: () => NOW, ceiling: null, dailyRequests: 6}));
  assert.equal(err.code, 'resource-exhausted');
  assert.deepEqual(err.details, {kind: 'content', scope: 'requests'});
  assert.equal(reads, before, 'no document was read after the cap was hit');
  assert.equal(await count(uid, 'getContent'), 4);
});

test('catalog has its own pair of limits and reports its kind', async () => {
  const uid = 'lim-catalog';
  await reset(uid);
  const err = await fail(serveContent(as(uid), {kind: 'catalog', ids: ['a', 'b', 'c']}, {db, now: () => NOW, ceiling: null, dailyCatalogRequests: 2}));
  assert.deepEqual(err.details, {kind: 'catalog', scope: 'requests'});
  assert.equal(await count(uid, 'getContent'), 0);
});

test('concurrent calls can never deliver more than the allowance between them', async () => {
  const uid = 'lim-race';
  await reset(uid);
  const allowance = 25;
  const calls = Array.from({length: 8}, (_, i) =>
    ask(uid, ids.slice(i * 6, i * 6 + 10), {}, {dailyIds: allowance}).then(out => okCount(out), () => 0));
  const delivered = (await Promise.all(calls)).reduce((a, b) => a + b, 0);
  assert.equal(delivered, allowance);
  assert.equal(await count(uid, 'getContent'), allowance);
});

test('the ceiling refuses lessons and questions with the same error but leaves the catalog open', async () => {
  const uid = 'lim-ceiling';
  await reset(uid);
  const writes = [];
  const closed = {isOpen: async () => false, record: async n => { writes.push(n); }};
  const err = await fail(ask(uid, ids.slice(0, 2), {}, {ceiling: closed}));
  assert.equal(err.code, 'resource-exhausted');
  assert.equal(err.message, 'Daily content limit reached. Try again tomorrow.');
  assert.deepEqual(err.details, {kind: 'content', scope: 'ceiling'});
  assert.equal(await count(uid, 'getContent'), 0);
  const open = {isOpen: async () => true, record: async n => { writes.push(n); }};
  const out = await ask(uid, ids.slice(0, 4), {}, {ceiling: open});
  assert.equal(okCount(out), 4);
  assert.deepEqual(writes, [4], 'one ceiling write per call, for what was delivered');
  const catalog = await serveContent(as(uid), {kind: 'catalog', ids: ['index']}, {db, now: () => NOW, ceiling: closed});
  assert.equal(catalog.items.index.status, 'missing');
  assert.deepEqual(writes, [4], 'catalog neither checks nor adds to the ceiling');
});
