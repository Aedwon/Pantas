// The version list: one index document per content kind holding id -> version, so a plan reads a handful of
// documents instead of scanning every content document (process-improvement, "Upload runs read past the free
// tier again (Nov 28)").
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {lessonItem, writeContent, expectedPlanReads, VERSION_INDEX_COLLECTION} from '../lib/contentUpload.js';
import {serveContent} from '../lib/content.js';

const KINDS = ['lessons', 'questions', 'mocks', 'catalog', 'gaps'];
const indexPath = (kind) => `${VERSION_INDEX_COLLECTION}/${kind}`;

/** An in-memory Firestore that counts billed reads: one per document returned (one at least per query) and one per get. */
function memoryDb() {
  const stored = new Map();
  const scans = [];
  let writes = 0;
  let reads = 0;
  return {stored, scans, get writes() { return writes; }, get reads() { return reads; },
    collection(path) { scans.push(path); return {select() { return {async get() {
      const docs = [...stored].filter(([key]) => key.startsWith(path + '/')).map(([key, data]) =>
        ({id: key.slice(path.length + 1), get: field => data[field]}));
      reads += Math.max(1, docs.length);
      return {docs};
    }}}}; },
    doc(path) { return {path, async get() { reads += 1; const data = stored.get(path); return {exists: !!data, get: key => data?.[key], data: () => data}; }}; },
    batch() { return {delete(ref) { stored.delete(ref.path); }, set(ref, data) { stored.set(ref.path, data); writes++; }, async commit() {}}; },
  };
}

const lessons = (n, body = 'body') => Array.from({length: n}, (_, i) => lessonItem({_id: `lesson-${String(i).padStart(4, '0')}`, title: `T${i}`}, `${body} ${i}`));
const clone = (db) => { const copy = memoryDb(); for (const [key, data] of db.stored) copy.stored.set(key, structuredClone(data)); return copy; };

test('an upload writes one index document per kind it has documents for, with a count', async () => {
  const db = memoryDb();
  await writeContent(db, lessons(3), [], {});
  const index = db.stored.get(indexPath('lessons'));
  assert.equal(index.count, 3);
  assert.deepEqual(Object.keys(JSON.parse(index.payload)).sort(), ['lesson-0000', 'lesson-0001', 'lesson-0002']);
  assert.equal(JSON.parse(index.payload)['lesson-0001'], lessons(3)[1].data.version);
});

test('the index is written before the bank marker turns valid', async () => {
  const db = memoryDb();
  const order = [];
  const plain = db.batch;
  db.batch = () => {
    const b = plain();
    const set = b.set;
    b.set = (ref, data) => { order.push(ref.path.startsWith(VERSION_INDEX_COLLECTION) ? 'index' : ref.path.endsWith('_bank') && !String(data.bankVersion).startsWith('writing:') ? 'valid' : 'other'); set(ref, data); };
    return b;
  };
  await writeContent(db, lessons(2), [], {});
  assert.ok(order.includes('index') && order.includes('valid'));
  assert.ok(order.indexOf('index') < order.indexOf('valid'), order.join(','));
});

test('a plan from the index equals the plan from the scan on the same data', async () => {
  const seeded = memoryDb();
  await writeContent(seeded, lessons(40), [], {});
  // Edit three lessons, add two, and leave the rest.
  const next = [...lessons(40).map((item, i) => i < 3 ? lessonItem({_id: item.id, title: 'edited'}, 'new body') : item), ...lessons(42).slice(40)];
  const viaIndex = await writeContent(clone(seeded), next, [], {dryRun: true});
  const viaScan = await writeContent(clone(seeded), next, [], {dryRun: true, fullScan: true});
  assert.deepEqual(viaIndex, viaScan);
  assert.deepEqual(viaIndex.counts, {create: 2, update: 3, unchanged: 37});
  // Partial upload: the stored bank is bigger than the input, so summaries are not covered either way.
  const partial = lessons(10);
  assert.deepEqual(await writeContent(clone(seeded), partial, [], {dryRun: true}),
    await writeContent(clone(seeded), partial, [], {dryRun: true, fullScan: true}));
});

test('a plan with an index reads a handful of documents, and a scan reads one per stored document', async () => {
  const seeded = memoryDb();
  await writeContent(seeded, lessons(300), [], {});
  const withIndex = clone(seeded);
  await writeContent(withIndex, lessons(300), [], {dryRun: true});
  assert.ok(withIndex.reads <= KINDS.length + 1, `read ${withIndex.reads} documents`);
  assert.deepEqual(withIndex.scans, []);
  const scanned = clone(seeded);
  await writeContent(scanned, lessons(300), [], {dryRun: true, fullScan: true});
  assert.ok(scanned.reads >= 300, `read ${scanned.reads} documents`);
});

test('a missing index falls back to the scan for that kind and the next upload rewrites it', async () => {
  const seeded = memoryDb();
  await writeContent(seeded, lessons(5), [], {});
  const db = clone(seeded);
  db.stored.delete(indexPath('lessons'));
  const dry = await writeContent(db, lessons(5), [], {dryRun: true});
  assert.deepEqual(dry.counts, {create: 0, update: 0, unchanged: 5});
  assert.deepEqual(db.scans, ['content/lessons/items']);
  assert.equal(db.stored.has(indexPath('lessons')), false, 'a dry run writes nothing');
  await writeContent(db, lessons(5), [], {});
  assert.equal(db.stored.get(indexPath('lessons')).count, 5);
});

test('an index whose count disagrees with its map, or that cannot be parsed, falls back to the scan', async () => {
  for (const damage of [(d) => ({...d, count: d.count + 1}), (d) => ({...d, payload: '{not json'}), (d) => ({...d, payload: undefined})]) {
    const seeded = memoryDb();
    await writeContent(seeded, lessons(5), [], {});
    const db = clone(seeded);
    db.stored.set(indexPath('lessons'), damage(db.stored.get(indexPath('lessons'))));
    const result = await writeContent(db, lessons(5), [], {dryRun: true});
    assert.deepEqual(result.counts, {create: 0, update: 0, unchanged: 5});
    assert.deepEqual(db.scans, ['content/lessons/items']);
  }
});

test('--full-scan scans every kind and rewrites an index that is wrong', async () => {
  const seeded = memoryDb();
  await writeContent(seeded, lessons(5), [], {});
  const index = seeded.stored.get(indexPath('lessons'));
  const wrong = JSON.parse(index.payload);
  wrong['lesson-0002'] = 'stale-version';
  seeded.stored.set(indexPath('lessons'), {...index, payload: JSON.stringify(wrong)});
  // The count still agrees, so the index is trusted: this is what --full-scan is for.
  assert.equal((await writeContent(clone(seeded), lessons(5), [], {dryRun: true})).counts.update, 1);
  const checked = clone(seeded);
  const result = await writeContent(checked, lessons(5), [], {fullScan: true});
  assert.deepEqual(result.counts, {create: 0, update: 0, unchanged: 5});
  assert.deepEqual(checked.scans, KINDS.map((kind) => `content/${kind}/items`));
  assert.equal(JSON.parse(checked.stored.get(indexPath('lessons')).payload)['lesson-0002'], lessons(5)[2].data.version);
});

test('an upload keeps the index of ids it did not touch, and an unchanged re-run writes nothing', async () => {
  const db = memoryDb();
  await writeContent(db, lessons(4), [], {});
  await writeContent(db, [lessonItem({_id: 'lesson-0001', title: 'edited'}, 'x')], [], {});
  const index = db.stored.get(indexPath('lessons'));
  assert.equal(index.count, 4);
  assert.equal(JSON.parse(index.payload)['lesson-0001'], lessonItem({_id: 'lesson-0001', title: 'edited'}, 'x').data.version);
  const before = db.writes;
  await writeContent(db, [lessonItem({_id: 'lesson-0001', title: 'edited'}, 'x')], [], {});
  assert.equal(db.writes, before);
});

// Other worktrees still hold the tool without the list. Their upload changes lessons and the marker but
// leaves the list behind; a later re-upload of the earlier version (a rollback) must not be planned as
// "unchanged" from that stale list.
test('a list left behind by an upload that did not update it is not trusted: a rollback still writes', async () => {
  const db = memoryDb();
  const v1 = lessons(3);
  const v2 = lessons(3, 'changed');
  await writeContent(db, v1, [], {});
  const staleIndex = structuredClone(db.stored.get(indexPath('lessons')));
  await writeContent(db, v2, [], {});
  db.stored.set(indexPath('lessons'), staleIndex);
  const result = await writeContent(db, v1, [], {});
  assert.deepEqual(result.counts, {create: 0, update: 3, unchanged: 0});
  assert.equal(db.stored.get('content/lessons/items/lesson-0001').version, v1[1].data.version);
});

test('the read guard runs before a fallback scan, and a refusal stops the run before any write', async () => {
  const seeded = memoryDb();
  await writeContent(seeded, lessons(5), [], {});
  const db = clone(seeded);
  db.stored.delete(indexPath('lessons'));
  const asked = [];
  const refuse = async (reads) => { asked.push(reads); throw new Error('over budget'); };
  await assert.rejects(writeContent(db, lessons(5), [], {beforeReads: refuse}), /over budget/);
  assert.deepEqual(asked, [5]);
  assert.deepEqual(db.scans, []);
  assert.equal(db.writes, 0);
  // With a good index the guard is not asked at all: the run's reads were counted at the start.
  const quiet = [];
  await writeContent(clone(seeded), lessons(5), [], {dryRun: true, beforeReads: async (n) => quiet.push(n)});
  assert.deepEqual(quiet, []);
});

test('expected reads: the index documents plus the marker, or one per stored document plus the marker for a full scan', () => {
  const items = lessons(300);
  assert.equal(expectedPlanReads(items, {}), KINDS.length + 1);
  assert.equal(expectedPlanReads(items, {fullScan: true}), 300 + 1);
});

test('the version list is never served as a kind and no client can read it', async () => {
  const db = memoryDb();
  await assert.rejects(serveContent({uid: 'u', token: {}}, {kind: 'versions', ids: ['lessons']}, {db, allow: async () => true}), {code: 'invalid-argument'});
  const rules = readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8');
  assert.match(rules, /match \/content\/\{kind\}\/items\/\{itemId\} \{\s*allow read, write: if false;/);
  assert.equal(VERSION_INDEX_COLLECTION, 'content/versions/items');
});
