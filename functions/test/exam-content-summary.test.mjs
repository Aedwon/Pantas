// Exam content summaries (plan docs/superpowers/plans/2026-11-21-exam-content-summary.md).
// A summary may replace the whole-bank scan only when it matches the stored bank; otherwise the loader
// scans, as before, and logs why. These tests fail if a stale summary could be served.
import assert from 'node:assert/strict';
import test from 'node:test';
import {loadExamContent, clearExamContentCache, buildExamContent, BUILDER_VERSION} from '../lib/_examContent.js';
import {lessonItem, questionSetItems, summaryItems, writeContent} from '../lib/contentUpload.js';

const EXAM = 'exam_cse_pro';
const lessonFronts = [
  {_id: 'lesson-algebra-a', topic: 'topic-algebra', ordering: 2},
  {_id: 'lesson-algebra-b', topic: 'topic-algebra', ordering: 1},
  {_id: 'lesson-algebra-old', topic: 'topic-algebra', status: 'retired', replacedBy: ['lesson-algebra-a']},
  {_id: 'lesson-filing-a', topic: 'topic-filing', ordering: 0},
];
const setSources = [
  [{meta: {subject: 's', topic: 'algebra', subtopic: 'a', exams: ['cse-pro', 'cse-sub']},
    questions: [{id: 'q1', lesson: 'lesson-algebra-old'}, {id: 'q2'}, {id: 'q3', isActive: false}]}, 'cse/algebra/a.yaml'],
  [{meta: {subject: 's', topic: 'filing', subtopic: 'a', exams: ['cse-sub']}, questions: [{id: 'q4'}]}, 'cse/filing/a.yaml'],
  [{meta: {subject: 's', topic: 'algebra', subtopic: 'b', exams: ['cse-pro']}, questions: [{id: 'q5', passage: 'p1'}]}, 'cse/algebra/b.yaml'],
];
const bank = () => [
  ...lessonFronts.map(front => lessonItem(front, 'body')),
  ...setSources.map(([source, path]) => questionSetItems({...source, passages: [{id: 'p1', body: 'text'}]}, path).item),
];

/** An in-memory Firestore with the calls the loader and the upload use, counting reads. */
function fakeDb(seed = {}) {
  const docs = new Map(Object.entries(seed));
  const stats = {reads: 0, queries: 0, getAll: 0, writes: []};
  const snap = (path) => {
    const data = docs.get(path);
    return {id: path.split('/').pop(), exists: data !== undefined, get: key => data?.[key], data: () => data};
  };
  const ref = (path) => ({path, get: async () => { stats.reads += 1; return snap(path); }});
  const collection = (path) => ({
    select() { return this; },
    get: async () => {
      stats.queries += 1;
      const prefix = path + '/';
      const found = [...docs.keys()].filter(k => k.startsWith(prefix) && !k.slice(prefix.length).includes('/')).sort();
      stats.reads += Math.max(1, found.length);
      return {docs: found.map(snap)};
    },
  });
  const db = {
    stats, docs,
    doc: ref, collection,
    getAll: async (...refs) => { stats.getAll += 1; stats.reads += refs.length; return refs.map(r => snap(r.path)); },
    batch: () => {
      const ops = [];
      return {set: (r, data) => ops.push(['set', r.path, data]), delete: r => ops.push(['delete', r.path]),
        commit: async () => { for (const [op, path, data] of ops) { stats.writes.push(path); op === 'set' ? docs.set(path, data) : docs.delete(path); } }};
    },
  };
  return db;
}

async function uploaded(items = bank(), seed = {}) {
  const db = fakeDb(seed);
  await writeContent(db, items, [], {});
  return db;
}

const scanOf = async (db, examId = EXAM) => {
  const plain = fakeDb(Object.fromEntries([...db.docs].filter(([k]) => !k.startsWith('content/summaries/'))));
  clearExamContentCache();
  return loadExamContent(plain, examId, 0);
};

/** Captures what the functions logger prints (it writes to the process streams). */
function captureWarnings() {
  const lines = [];
  const out = process.stdout.write, err = process.stderr.write;
  const grab = (chunk) => { lines.push(String(chunk)); return true; };
  process.stdout.write = grab; process.stderr.write = grab;
  return {lines, restore: () => { process.stdout.write = out; process.stderr.write = err; }};
}

test('parity: every exam summary equals the scan of the same bank', async () => {
  const db = await uploaded();
  for (const examId of ['exam_cse_pro', 'exam_cse_sub']) {
    clearExamContentCache();
    const fromSummary = await loadExamContent(db, examId, 0);
    assert.deepEqual(fromSummary, await scanOf(db, examId), examId);
  }
});

test('parity on the builder itself: upload order does not change the summary', () => {
  const items = bank();
  const forward = summaryItems(items).filter(i => i.id === EXAM);
  const reversed = summaryItems([...items].reverse()).filter(i => i.id === EXAM);
  assert.deepEqual(forward.map(i => i.data.payload), reversed.map(i => i.data.payload));
});

test('a matching summary is read with one getAll and no collection query', async () => {
  const db = await uploaded();
  clearExamContentCache();
  db.stats.reads = 0; db.stats.queries = 0; db.stats.getAll = 0;
  await loadExamContent(db, EXAM, 0);
  assert.equal(db.stats.queries, 0);
  assert.equal(db.stats.getAll, 1);
  assert.ok(db.stats.reads <= 3, `reads ${db.stats.reads}`);
});

for (const [name, mutate, reason] of [
  ['a summary whose bank version differs from the marker', d => d.docs.set(`content/summaries/items/${EXAM}`, {...d.docs.get(`content/summaries/items/${EXAM}`), bankVersion: 'other'}), /bank version/],
  ['a missing summary', d => d.docs.delete(`content/summaries/items/${EXAM}`), /missing/],
  ['a missing marker', d => d.docs.delete('content/summaries/items/_bank'), /marker/],
  ['a writing marker', d => d.docs.set('content/summaries/items/_bank', {bankVersion: 'writing:1'}), /marker/],
  ['a partial marker', d => d.docs.set('content/summaries/items/_bank', {bankVersion: 'partial:1'}), /marker/],
  ['a summary from another builder version', d => d.docs.set(`content/summaries/items/${EXAM}`, {...d.docs.get(`content/summaries/items/${EXAM}`), builderVersion: 'old'}), /builder/],
  ['a missing part', d => {
    const head = d.docs.get(`content/summaries/items/${EXAM}`);
    d.docs.set(`content/summaries/items/${EXAM}`, {...head, parts: 2});
  }, /part/],
  ['an unreadable summary', d => d.docs.set(`content/summaries/items/${EXAM}`, {...d.docs.get(`content/summaries/items/${EXAM}`), payload: '{'}), /unreadable/],
]) {
  test(`stale guard: ${name} falls back to the scan and logs why`, async () => {
    const db = await uploaded();
    mutate(db);
    const warn = captureWarnings();
    try {
      clearExamContentCache();
      const value = await loadExamContent(db, EXAM, 0);
      assert.deepEqual(value, await scanOf(db));
      assert.ok(warn.lines.some(l => l.includes('exam content summary unusable') && l.includes(EXAM) && reason.test(l)), warn.lines.join('\n'));
    } finally { warn.restore(); }
  });
}

test('stale guard: a summary listing a lesson the bank no longer has is never served', async () => {
  const db = await uploaded();
  // The bank changes behind the summary's back, and the marker moves with it.
  const head = db.docs.get(`content/summaries/items/${EXAM}`);
  const stale = JSON.parse(head.payload);
  stale.lessons.push({id: 'lesson-gone', topicId: 'topic_cse_pro_algebra', ordering: 9});
  db.docs.set(`content/summaries/items/${EXAM}`, {...head, payload: JSON.stringify(stale)});
  db.docs.set('content/summaries/items/_bank', {...db.docs.get('content/summaries/items/_bank'), bankVersion: 'moved'});
  const warn = captureWarnings();
  try {
    clearExamContentCache();
    const value = await loadExamContent(db, EXAM, 0);
    assert.ok(!value.lessons.some(l => l.id === 'lesson-gone'));
  } finally { warn.restore(); }
});

test('a partial upload (a stored set missing from the input) writes no summaries and marks the bank partial', async () => {
  const db = await uploaded();
  const summaryBefore = db.docs.get(`content/summaries/items/${EXAM}`);
  const changed = lessonItem({_id: 'lesson-algebra-a', topic: 'topic-algebra', ordering: 5}, 'new body');
  await writeContent(db, [changed], [], {});
  assert.match(db.docs.get('content/summaries/items/_bank').bankVersion, /^partial:/);
  assert.deepEqual(db.docs.get(`content/summaries/items/${EXAM}`), summaryBefore);
  const warn = captureWarnings();
  try {
    clearExamContentCache();
    assert.deepEqual(await loadExamContent(db, EXAM, 0), await scanOf(db));
  } finally { warn.restore(); }
});

test('a full upload after a partial one restores a usable summary', async () => {
  const db = await uploaded();
  await writeContent(db, [lessonItem({_id: 'lesson-algebra-a', topic: 'topic-algebra', ordering: 5}, 'new body')], [], {});
  const items = bank().map(i => i.id === 'lesson-algebra-a' ? lessonItem({_id: 'lesson-algebra-a', topic: 'topic-algebra', ordering: 5}, 'new body') : i);
  await writeContent(db, items, [], {});
  assert.doesNotMatch(db.docs.get('content/summaries/items/_bank').bankVersion, /^(partial|writing):/);
  clearExamContentCache();
  db.stats.queries = 0;
  assert.deepEqual(await loadExamContent(db, EXAM, 0), await scanOf(db));
  assert.equal(db.stats.queries, 0);
});

test('upload order: the marker is invalid before any content write and valid only after the summaries', async () => {
  const db = await uploaded();
  const items = bank().map(i => i.id === 'lesson-algebra-b' ? lessonItem({_id: 'lesson-algebra-b', topic: 'topic-algebra', ordering: 7}, 'b2') : i);
  db.stats.writes = [];
  await writeContent(db, items, [], {});
  const order = db.stats.writes;
  const first = order.indexOf('content/summaries/items/_bank');
  const last = order.lastIndexOf('content/summaries/items/_bank');
  const content = order.findIndex(p => p.startsWith('content/lessons/'));
  const summary = order.indexOf(`content/summaries/items/${EXAM}`);
  assert.ok(first >= 0 && first < content, `marker reset first: ${order.join(', ')}`);
  assert.ok(summary > content && last > summary, `summaries then marker: ${order.join(', ')}`);
});

test('a crash after the content writes leaves the marker at writing, so readers scan', async () => {
  const db = await uploaded();
  const items = bank().map(i => i.id === 'lesson-algebra-b' ? lessonItem({_id: 'lesson-algebra-b', topic: 'topic-algebra', ordering: 7}, 'b2') : i);
  const batch = db.batch;
  db.batch = () => {
    const real = batch();
    let summaries = false;
    return {set: (r, d) => { if (r.path.includes('/summaries/items/') && !r.path.endsWith('/_bank')) summaries = true; real.set(r, d); },
      delete: real.delete, commit: async () => { if (summaries) throw new Error('crash'); return real.commit(); }};
  };
  await assert.rejects(writeContent(db, items, [], {}), /crash/);
  assert.match(db.docs.get('content/summaries/items/_bank').bankVersion, /^writing:/);
});

test('an unchanged full upload writes nothing', async () => {
  const db = await uploaded();
  db.stats.writes = [];
  await writeContent(db, bank(), [], {});
  assert.deepEqual(db.stats.writes, []);
});

test('a dry run writes nothing', async () => {
  const db = fakeDb();
  await writeContent(db, bank(), [], {dryRun: true});
  assert.deepEqual(db.stats.writes, []);
});

test('a summary above the split size is stored in parts and read back whole', async () => {
  const items = bank();
  for (let i = 0; i < 40; i++) {
    items.push(questionSetItems({meta: {subject: 's', topic: 'algebra', subtopic: `x${i}`, exams: ['cse-pro']},
      questions: Array.from({length: 120}, (_, j) => ({id: `big-${i}-${j}-${'p'.repeat(80)}`}))}, `cse/algebra/x${i}.yaml`).item);
  }
  const db = await uploaded(items);
  const head = db.docs.get(`content/summaries/items/${EXAM}`);
  assert.ok(head.parts > 1, `parts ${head.parts}`);
  for (let i = 1; i < head.parts; i++) assert.ok(db.docs.has(`content/summaries/items/${EXAM}~${i}`));
  clearExamContentCache();
  db.stats.queries = 0;
  assert.deepEqual(await loadExamContent(db, EXAM, 0), await scanOf(db));
  assert.equal(db.stats.queries, 0);
});

test('the builder version is a named constant', () => {
  assert.equal(typeof BUILDER_VERSION, 'string');
  assert.equal(typeof buildExamContent, 'function');
});

test('the upload module loads without starting a Firebase app (the upload tool sets its own project)', async () => {
  const {execFileSync} = await import('node:child_process');
  const script = "const m = require('./lib/contentUpload.js'); const {initializeApp} = require('firebase-admin/app');"
    + " initializeApp({projectId: 'upload-tool-check'}); if (typeof m.summaryItems !== 'function') process.exit(2);";
  execFileSync(process.execPath, ['-e', script], {cwd: new URL('..', import.meta.url), stdio: 'pipe'});
});
