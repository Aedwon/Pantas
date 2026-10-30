import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join, relative} from 'node:path';
import {readdirSync, statSync} from 'node:fs';
import {createRequire} from 'node:module';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {blueprintItem, catalogItems, lessonItem, questionSetItems, planWrites, writeContent} from '../lib/contentUpload.js';
import * as upload from '../lib/contentUpload.js';
import {serveContent} from '../lib/content.js';
import * as endpoints from '../lib/index.js';

const source = name => readFileSync(new URL(`../src/${name}`, import.meta.url), 'utf8');
const set = {
  meta: {subject: 'science', topic: 'biology', subtopic: 'botany', exams: ['cse-pro']},
  questions: [
    {id: 'q1', type: 'single_choice', stem: 'S', explanation: 'E', figureSpec: {cells: [[0, 1], [1, 0]]},
      choices: [{text: 'A', correct: true}, {text: 'B', rationale: 'Why B fails'}, {text: 'C'}]},
    {id: 'q2', type: 'single_choice', stem: 'T', explanation: 'F',
      choices: [{text: 'A'}, {text: 'B', correct: true}]},
  ],
};

test('lesson item carries the free fields, a stable version, and no Pro document', () => {
  const a = lessonItem({_id: 'lesson-x', title: 'T', summary: 'S', subject: 's', topic: 't', estimatedMinutes: 5}, '## Body');
  const b = lessonItem({_id: 'lesson-x', title: 'T', summary: 'S', subject: 's', topic: 't', estimatedMinutes: 5}, '## Body');
  const c = lessonItem({_id: 'lesson-x', title: 'T', summary: 'S', subject: 's', topic: 't', estimatedMinutes: 5}, '## Body 2');
  assert.equal(a.kind, 'lessons');
  assert.equal(a.id, 'lesson-x');
  assert.equal(a.data.body, '## Body');
  assert.equal(a.data.version, b.data.version);
  assert.notEqual(a.data.version, c.data.version);
  assert.equal(a.pro, undefined);
});

test('question set strips wrong-choice notes from the free document into the Pro document', () => {
  const {item, pro} = questionSetItems(set, 'science/biology/botany.yaml');
  assert.equal(item.kind, 'questions');
  assert.equal(item.id, 'qs-science__biology__botany');
  const free = JSON.parse(item.data.payload);
  assert.equal(JSON.stringify(free).includes('Why B fails'), false);
  assert.deepEqual(free.questions[0].figureSpec, {cells: [[0, 1], [1, 0]]});
  assert.equal(free.questions[0].explanation, 'E');
  assert.deepEqual(free.questions[0].choices[1], {text: 'B'});
  assert.equal(pro.id, item.id);
  assert.deepEqual(JSON.parse(pro.data.payload), {q1: [null, 'Why B fails', null]});
  assert.equal(pro.data.version, item.data.version);
  for (const forbidden of Object.values(item.data)) assert.notEqual(typeof forbidden, 'undefined');
});

test('a set without notes has no Pro document', () => {
  const plain = {...set, questions: [set.questions[1]]};
  assert.equal(questionSetItems(plain, 'a/b/c.yaml').pro, undefined);
});

test('planWrites skips equal versions and reports creates and updates', () => {
  const lesson = lessonItem({_id: 'l1', title: 'T'}, 'B');
  const existing = new Map([[`lessons/l1`, lesson.data.version], ['lessons/gone', 'old']]);
  assert.deepEqual(planWrites([lesson], existing).counts, {create: 0, update: 0, unchanged: 1});
  const changed = lessonItem({_id: 'l1', title: 'T'}, 'B2');
  assert.deepEqual(planWrites([changed], existing).counts, {create: 0, update: 1, unchanged: 0});
  const fresh = lessonItem({_id: 'l2', title: 'T'}, 'B');
  assert.deepEqual(planWrites([fresh], existing).counts, {create: 1, update: 0, unchanged: 0});
});

test('upload tool dry run reads the sources, writes nothing and refuses a live target without --live', () => {
  const root = mkdtempSync(join(tmpdir(), 'content-'));
  mkdirSync(join(root, 'lessons/s/t'), {recursive: true});
  mkdirSync(join(root, 'questions/s/t'), {recursive: true});
  mkdirSync(join(root, 'mock'), {recursive: true});
  writeFileSync(join(root, 'mock/e.yaml'), 'exam: exam_cse_pro\nname: P\ndurationMinutes: 60\nsections:\n  - id: s1\n    name: One\n    questionCount: 2\n    suggestedMinutes: 60\n    topicIds: [topic_cse_pro_t]\n    topicWeights: {topic_cse_pro_t: 1}\n');
  writeFileSync(join(root, 'lessons/s/t/a.md'), '---\n_id: "lesson-a"\ntitle: "A"\ntopic: "topic-t"\n---\n## Hi\n');
  writeFileSync(join(root, 'questions/s/t/u.yaml'),
    'meta:\n  subject: s\n  topic: t\n  subtopic: u\n  exams: [cse-pro]\nquestions:\n  - id: q1\n    stem: x\n    choices:\n      - text: a\n        correct: true\n      - text: b\n        rationale: no\n');
  const tool = new URL('../../tools/upload_content/upload_content.mjs', import.meta.url).pathname;
  const env = {...process.env};
  delete env.FIRESTORE_EMULATOR_HOST;
  const dry = spawnSync('node', [tool, '--root', root, '--dry-run'], {env, encoding: 'utf8'});
  assert.equal(dry.status, 0, dry.stderr);
  assert.match(dry.stdout, /lessons: 1/);
  assert.match(dry.stdout, /question sets: 1/);
  assert.match(dry.stdout, /mock blueprints: 1/);
  assert.match(dry.stdout, /pro documents: 1/);
  assert.match(dry.stdout, /dry run/i);
  const exported = join(root, 'export.json');
  writeFileSync(exported, JSON.stringify({
    exam: [{_id: 'exam_cse_pro'}], subject: [{_id: 'subject', exam: {_ref: 'exam_cse_pro'}}],
    topic: [{_id: 'topic_upcat_t', subject: {_ref: 'subject'}}],
    lessonLink: [{lesson: 'lesson-a', requires: 'lesson-p', strength: 'helpful'}],
    gapTag: [{question: 'q1', choice: 'q1_b', prerequisite: 'lesson-p'}],
  }));
  const withExport = spawnSync('node', [tool, '--root', root, '--dry-run', '--export', exported], {env, encoding: 'utf8'});
  assert.equal(withExport.status, 0, withExport.stderr);
  assert.match(withExport.stdout, /gap documents: 1/);
  const output = join(root, 'out');
  const files = spawnSync('node', [tool, '--root', root, '--export', exported, '--out-dir', output], {env, encoding: 'utf8'});
  assert.equal(files.status, 0, files.stderr);
  const catalog = JSON.parse(readFileSync(join(output, 'catalog/exam_cse_pro.json'), 'utf8'));
  assert.deepEqual(catalog.lessons[0].prerequisites, [{lesson: 'lesson-p', strength: 'helpful'}]);
  assert.equal(readdirSync(output).includes('gaps'), false);
  const live = spawnSync('node', [tool, '--root', root], {env, encoding: 'utf8'});
  assert.notEqual(live.status, 0);
  assert.match(live.stderr, /--live/);
});

test('index exports the Pro content, mock and ingest callables, all behind App Check', () => {
  for (const [name, file] of [['getContent', 'content.ts'], ['startMock', 'mock.ts'], ['submitMock', 'mock.ts'], ['ingestSession', 'ingestSession.ts']]) {
    assert.equal(typeof endpoints[name], 'function', name);
    assert.match(source('index.ts'), new RegExp(`export \\{ ${name} \\}`));
    assert.match(source(file), /enforceAppCheck: enforceAppCheck/);
  }
  assert.match(source('mock.ts'), /assertNamedUser\(auth\)/);
});

test('a blueprint item is keyed by exam, keeps the sections as JSON and changes version with them', () => {
  const doc = {exam: 'exam_cse_pro', name: 'P', durationMinutes: 60, sections: [{id: 's1', questionCount: 2}]};
  const item = blueprintItem(doc);
  assert.equal(item.kind, 'mocks');
  assert.equal(item.id, 'exam_cse_pro');
  assert.deepEqual(JSON.parse(item.data.sectionsJson), doc.sections);
  assert.notEqual(blueprintItem({...doc, durationMinutes: 61}).data.version, item.data.version);
  assert.throws(() => blueprintItem({exam: 'exam_cse_pro', sections: []}));
});

test('a blueprint without a positive duration is refused, so a strict mock never gets a NaN clock', () => {
  const sections = [{id: 's1', questionCount: 2}];
  for (const durationMinutes of [undefined, null, 0, -5, '60', Number.NaN]) {
    assert.throws(() => blueprintItem({exam: 'exam_cse_pro', durationMinutes, sections}), /duration/);
  }
});

// ---- passages inside question sets ------------------------------------------------------------
const passageSource = (questions, passages = [{id: 'rc-1', title: 'PASSAGE-TITLE', body: 'PASSAGE-BODY text.\n\nMore words here.'}]) =>
  ({meta: set.meta, passages, questions});

test('a set carries the passages its questions name, and only those', () => {
  const source = passageSource([{...set.questions[1], passage: 'rc-1'}, {id: 'q3', stem: 'x', choices: [{text: 'a'}]}],
    [{id: 'rc-1', title: 'PASSAGE-TITLE', body: 'PASSAGE-BODY text.\n\nMore words here.'}, {id: 'rc-2', title: 'T', body: 'Unused.'}]);
  const payload = JSON.parse(questionSetItems(source, 'a/b/c.yaml').item.data.payload);
  assert.deepEqual(payload.passages.map(p => p.id), ['rc-1']);
  assert.equal(payload.passages[0].body, 'PASSAGE-BODY text.\n\nMore words here.');
  assert.deepEqual(Object.keys(payload.passages[0]).sort(), ['body', 'id', 'language', 'title', 'topic', 'wordCount']);
  assert.equal(payload.passages[0].topic, 'topic_upcat_biology');
  assert.equal(payload.passages[0].wordCount, 5, 'counted from the body');
  assert.equal('passages' in payload.questions[0], false);
});

test('a set without passages has no passages key, and a missing passage is refused', () => {
  assert.equal('passages' in JSON.parse(questionSetItems(set, 'a/b/c.yaml').item.data.payload), false);
  assert.throws(() => questionSetItems(passageSource([{id: 'q9', passage: 'rc-404', stem: 'x', choices: [{text: 'a'}]}]), 'a/b/c.yaml'), /rc-404/);
});

test('passage text changes the set version', () => {
  const questions = [{id: 'q3', passage: 'rc-1', stem: 'x', choices: [{text: 'a'}]}];
  const a = questionSetItems(passageSource(questions), 'a/b/c.yaml');
  const b = questionSetItems(passageSource(questions, [{id: 'rc-1', title: 'T', body: 'Edited.'}]), 'a/b/c.yaml');
  assert.notEqual(a.item.data.version, b.item.data.version);
});

// ---- catalog documents -------------------------------------------------------------------------
const stamp = '2026-01-01T00:00:00.000Z';
const doc = (id, fields) => ({_id: id, _updatedAt: stamp, schemaVersion: 1, isActive: true, ...fields});
const structure = {
  exam: [doc('exam_upcat', {code: 'UPCAT', name: 'U', shortName: 'U', language: 'en', ordering: 1}),
    doc('exam_acet', {code: 'ACET', name: 'A', shortName: 'A', language: 'en', ordering: 99})],
  subject: [doc('subj_upcat_sci', {exam: {_ref: 'exam_upcat'}, name: 'Science', ordering: 1}),
    doc('subj_upcat_math', {exam: {_ref: 'exam_upcat'}, name: 'Math', ordering: 2})],
  topic: [doc('topic_upcat_biology', {subject: {_ref: 'subj_upcat_sci'}, name: 'Biology', ordering: 1}),
    doc('topic_upcat_algebra', {subject: {_ref: 'subj_upcat_math'}, name: 'Algebra', ordering: 1})],
  mockBlueprint: [doc('mock_blueprint_upcat', {schemaVersion: 2, exam: {_ref: 'exam_upcat'}, name: 'P', durationMinutes: 60, sections: [{id: 's1'}]})],
};
const lessonFront = (n, topic, extra = {}) => ({_id: `lesson-${topic}-${n}`, title: `Title ${n}`, summary: 'Sum', topic: `topic-${topic}`, estimatedMinutes: 5, ...extra});
const algSource = {meta: {subject: 'math', topic: 'algebra', subtopic: 'eq', exams: ['upcat']}, questions: [{id: 'alg-1', stem: 's', explanation: 'e', choices: [{text: 'a'}]}]};
const catalogInput = {
  structure,
  lessons: [lessonFront('cells', 'biology', {ordering: 7}), lessonFront('genes', 'biology'), lessonFront('eq', 'algebra'), {...lessonFront('off', 'algebra'), isActive: false}],
  sets: [{source: {meta: {subject: 'science', topic: 'biology', subtopic: 'cells', exams: ['upcat']},
    passages: [{id: 'rc-1', title: 'PASSAGE-TITLE', body: 'PASSAGE-BODY text.'}], questions: [
    {id: 'bio-1', stem: 'STEM-SECRET', explanation: 'EXPLAIN-SECRET', choices: [{text: 'CHOICE-SECRET', correct: true}, {text: 'b', rationale: 'NOTE-SECRET'}]},
    {id: 'bio-2', passage: 'rc-1', figureSpec: {k: 1}, stem: 's', explanation: 'e', choices: [{text: 'a'}]},
    {id: 'bio-3', figure: 'pending', stem: 's', explanation: 'e', choices: [{text: 'a'}]}]}, relativePath: 'science/biology/cells.yaml'},
  {source: algSource, relativePath: 'math/algebra/eq.yaml'}],
};
const parsed = items => Object.fromEntries(items.map(i => [i.id, JSON.parse(i.data.payload)]));

test('the catalog lists only exams that have content and holds no question or passage text', () => {
  const items = catalogItems(catalogInput);
  assert.ok(items.every(i => i.kind === 'catalog'));
  const docs = parsed(items);
  assert.deepEqual(docs.index.catalogs, ['exam_upcat']);
  assert.deepEqual(docs.index.exams.map(e => e._id), ['exam_upcat', 'exam_acet']);
  assert.equal(docs.index.topics.length, 2);
  const all = items.map(i => i.data.payload).join('\n');
  for (const secret of ['STEM-SECRET', 'EXPLAIN-SECRET', 'CHOICE-SECRET', 'NOTE-SECRET', 'PASSAGE-BODY', 'PASSAGE-TITLE']) {
    assert.equal(all.includes(secret), false, secret);
  }
  assert.equal(all.includes('"choices"'), false);
  assert.equal(all.includes('"stem"'), false);
});

test('an exam catalog has text-free lessons, compact sets, the passage link and the figure flag', () => {
  const docs = parsed(catalogItems(catalogInput));
  const exam = docs.exam_upcat;
  assert.equal(exam.id, 'exam_upcat');
  const byId = Object.fromEntries(exam.lessons.map(l => [l.id, l]));
  assert.deepEqual(Object.keys(byId).sort(), ['lesson-algebra-eq', 'lesson-biology-cells', 'lesson-biology-genes']);
  assert.deepEqual(byId['lesson-biology-cells'], {id: 'lesson-biology-cells', topic: 'topic_upcat_biology', subtopic: 'subtopic_cells',
    title: 'Title cells', summary: 'Sum', estimatedMinutes: 5, ordering: 7});
  assert.equal(byId['lesson-biology-genes'].ordering, 2, 'the position among the topic lessons when none is given');
  const sets = Object.fromEntries(exam.sets.map(s => [s.id, s]));
  const bio = sets['qs-science__biology__cells'];
  assert.deepEqual({...bio, questions: undefined}, {id: 'qs-science__biology__cells', topic: 'topic_upcat_biology', subtopic: 'subtopic_cells',
    lesson: 'lesson-biology-cells', exams: ['exam_upcat'], language: 'en', questions: undefined});
  assert.deepEqual(bio.questions, [{id: 'bio-1'}, {id: 'bio-2', passage: 'rc-1', figure: true}], 'a figure not drawn yet is held back');
  assert.equal(exam.mockBlueprints.length, 1);
  assert.deepEqual(exam.subjects.map(s => s._id), ['subj_upcat_sci', 'subj_upcat_math']);
  assert.equal(exam.parts, undefined);
});

test('a catalog item is versioned by its content and stored as a JSON string', () => {
  const a = catalogItems(catalogInput).find(i => i.id === 'exam_upcat');
  const b = catalogItems({...catalogInput, lessons: catalogInput.lessons.slice(1)}).find(i => i.id === 'exam_upcat');
  assert.equal(typeof a.data.payload, 'string');
  assert.notEqual(a.data.version, b.data.version);
  assert.equal(catalogItems(catalogInput).find(i => i.id === 'exam_upcat').data.version, a.data.version);
});

test('an exam catalog over the size limit is split by subject into parts', () => {
  const items = catalogItems(catalogInput, {splitAbove: 100});
  const docs = parsed(items);
  assert.deepEqual(docs.exam_upcat.parts, ['exam_upcat.subj_upcat_sci', 'exam_upcat.subj_upcat_math']);
  assert.equal(docs.exam_upcat.lessons, undefined);
  assert.deepEqual(docs['exam_upcat.subj_upcat_sci'].sets.map(s => s.id), ['qs-science__biology__cells']);
  assert.deepEqual(docs['exam_upcat.subj_upcat_math'].lessons.map(l => l.id), ['lesson-algebra-eq']);
  assert.deepEqual(docs['exam_upcat.subj_upcat_math'].parts, undefined);
});

test('a catalog document that cannot fit under the hard limit is refused', () => {
  assert.throws(() => catalogItems(catalogInput, {splitAbove: 100, hardLimit: 100}), /limit/);
});

// ---- the real corpus ---------------------------------------------------------------------------
const walk = (dir, ext) => readdirSync(dir).sort().flatMap(name => {
  const path = join(dir, name);
  return statSync(path).isDirectory() ? walk(path, ext) : path.endsWith(ext) ? [path] : [];
});

test('every catalog document built from the real content tree is under 1 MiB and holds no text', () => {
  const {parse} = createRequire(import.meta.url)('yaml');
  const root = new URL('../../content/', import.meta.url).pathname;
  const outline = JSON.parse(readFileSync(new URL('../../tools/lesson_author/outline.json', import.meta.url), 'utf8'));
  const real = {exam: [], subject: [], topic: []};
  const exams = new Set();
  for (const subject of outline.subjects) {
    const examId = `exam_${(subject.exam ?? 'upcat').replaceAll('-', '_')}`;
    exams.add(examId);
    const subjectId = `subj_upcat_${subject.slug.replaceAll('-', '_')}`;
    real.subject.push(doc(subjectId, {exam: {_ref: examId}, name: subject.name, ordering: 1}));
    for (const topic of subject.topics) real.topic.push(doc(`topic_upcat_${topic.slug.replaceAll('-', '_')}`, {subject: {_ref: subjectId}, name: topic.name, ordering: 1}));
  }
  for (const id of exams) real.exam.push(doc(id, {code: id, name: id, shortName: id, language: 'en', ordering: 1}));
  const lessons = walk(join(root, 'lessons'), '.md').map(file => parse(/^---\n([\s\S]*?)\n---/.exec(readFileSync(file, 'utf8'))[1]));
  const questionsRoot = join(root, 'questions');
  // The uploader reports a file the YAML library rejects and skips it with --skip-invalid; so does this test.
  const sets = walk(questionsRoot, '.yaml').flatMap((file) => {
    try { return [{source: parse(readFileSync(file, 'utf8')), relativePath: relative(questionsRoot, file)}]; } catch { return []; }
  });
  for (const {source, relativePath} of sets) {
    const bytes = Buffer.byteLength(questionSetItems(source, relativePath).item.data.payload);
    assert.ok(bytes < 1024 * 1024, `${relativePath} set document is ${bytes} bytes`);
  }
  const items = catalogItems({structure: real, lessons, sets});
  assert.ok(items.length > 1);
  let biggest = 0;
  for (const item of items) {
    const bytes = Buffer.byteLength(item.data.payload);
    biggest = Math.max(biggest, bytes);
    assert.ok(bytes < 1024 * 1024, `${item.id} is ${bytes} bytes`);
  }
  console.log(`# largest catalog document: ${biggest} bytes of ${items.length}`);
  const questionCount = sets.reduce((n, s) => n + s.source.questions.length, 0);
  const listed = new Set(items.flatMap(i => JSON.parse(i.data.payload).sets ?? []).flatMap(s => s.questions.map(q => q.id)));
  assert.ok(listed.size > 0 && listed.size <= questionCount);
  const sample = sets[0].source.questions[0];
  assert.equal(items.some(i => i.data.payload.includes(String(sample.stem).slice(0, 40))), false);
});

const links = [{lesson: 'lesson-biology-cells', requires: 'lesson-algebra-eq', strength: 'required'}];
const tags = [{question: 'bio-1', choice: 'bio-1_b', prerequisite: 'lesson-algebra-eq'}];

test('catalog links carry only lesson and strength and change the version', () => {
  const items = catalogItems({...catalogInput, links});
  const lesson = parsed(items).exam_upcat.lessons.find(l => l.id === links[0].lesson);
  assert.deepEqual(lesson.prerequisites, [{lesson: 'lesson-algebra-eq', strength: 'required'}]);
  assert.notEqual(items.find(i => i.id === 'exam_upcat').data.version,
    catalogItems(catalogInput).find(i => i.id === 'exam_upcat').data.version);
  assert.equal(parsed(items).exam_upcat.parts, undefined);
});

test('gap document groups choices by question and has a stable content digest', () => {
  const item = upload.gapItem(tags);
  assert.equal(item.kind, 'gaps');
  assert.equal(item.id, 'tags');
  assert.deepEqual(JSON.parse(item.data.payload), {'bio-1': {'bio-1_b': 'lesson-algebra-eq'}});
  assert.equal(upload.gapItem([...tags].reverse()).data.version, item.data.version);
  assert.notEqual(upload.gapItem([]).data.version, item.data.version);
});

function memoryDb() {
  const stored = new Map();
  const scans = [];
  let writes = 0;
  return {stored, scans, get writes() { return writes; },
    collection(path) { scans.push(path); return {select() { return {async get() {
      return {docs: [...stored].filter(([key]) => key.startsWith(path + '/')).map(([key, data]) =>
        ({id: key.slice(path.length + 1), get: field => data[field]}))};
    }}}}; },
    doc(path) { return {path, async get() { const data = stored.get(path); return {exists: !!data, get: key => data?.[key], data: () => data}; }}; },
    batch() { return {delete(ref) { stored.delete(ref.path); }, set(ref, data) { stored.set(ref.path, data); writes++; }, async commit() {}}; },
  };
}

test('writeContent scans gaps and writes the one gap document only when changed', async () => {
  const db = memoryDb();
  const item = upload.gapItem(tags);
  assert.deepEqual((await writeContent(db, [item], [], {})).counts, {create: 1, update: 0, unchanged: 0});
  assert.ok(db.scans.includes('content/gaps/items'));
  assert.deepEqual((await writeContent(db, [item], [], {})).counts, {create: 0, update: 0, unchanged: 1});
  assert.equal(db.writes, 1);
});

test('Free served payloads of every kind contain no gap tags and gaps is rejected', async () => {
  const db = memoryDb();
  db.runTransaction = async callback => callback({get: async ref => ref.get ? ref.get() : {docs: [], empty: true}, getAll: async (...refs) => Promise.all(refs.map(ref => ref.get()))});
  const items = [lessonItem({_id: 'lesson-free'}, 'body'),
    questionSetItems(catalogInput.sets[0].source, catalogInput.sets[0].relativePath).item,
    ...catalogItems({...catalogInput, links}), upload.gapItem(tags)];
  await writeContent(db, items, [], {});
  const auth = {uid: 'free-gap-test', token: {}};
  const deps = {db, allow: async () => true};
  await assert.rejects(serveContent(auth, {kind: 'gaps', ids: ['tags']}, deps), {code: 'invalid-argument'});
  for (const kind of ['lessons', 'questions', 'catalog']) {
    const response = await serveContent(auth, {kind, ids: items.filter(i => i.kind === kind).map(i => i.id)}, deps);
    assert.equal(response.tier, 'free');
    const text = JSON.stringify(response);
    for (const tag of tags) assert.equal(text.includes(tag.choice), false);
    assert.equal(text.includes('NOTE-SECRET'), false);
  }
});
