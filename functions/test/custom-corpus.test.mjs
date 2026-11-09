import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {readdirSync, readFileSync, statSync} from 'node:fs';
import {join, relative} from 'node:path';
import test from 'node:test';
import {applyScope, clearExamContentCache, loadCorpusCached, loadStudyContent} from '../lib/_examContent.js';
import {catalogItems} from '../lib/contentUpload.js';
import {documents, fakeDb} from './custom-corpus-fixture.mjs';

const CUSTOM = 'exam_custom_0a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const path = id => `content/catalog/items/${id}`;
const without = (docs, ...ids) => Object.fromEntries(Object.entries(docs).filter(([id]) => !ids.includes(id)));
const rejects = (promise, code, message) => assert.rejects(promise, error => {
  assert.equal(error.code, code);
  if (message) assert.equal(error.message, message);
  return true;
});

test.beforeEach(() => clearExamContentCache());

// ---- listed exams: output pinned before the custom branch was added ----------------------------
const alphaPinned = {
  revision: 'exam_alpha:v-exam_alpha|index:v-index:exam-lessons-v2',
  subjects: [{id: 'subj_sci', name: 'Science', ordering: 1}],
  topics: [{id: 'topic_bio', name: 'Biology', subjectId: 'subj_sci', ordering: 1}],
  lessons: [{id: 'lesson-bio-cells', topicId: 'topic_bio', title: 'Cells', ordering: 1, prerequisites: []},
    {id: 'lesson-bio-genes', topicId: 'topic_bio', title: 'Genes', ordering: 2, prerequisites: [{lesson: 'lesson-alg-eq', strength: 'required'}]}],
  questions: [
    {id: 'bio-1', setId: 'qs-bio__cells', topicId: 'topic_bio', lessonId: 'lesson-bio-cells', passageId: null},
    {id: 'bio-2', setId: 'qs-bio__cells', topicId: 'topic_bio', lessonId: 'lesson-bio-cells', passageId: 'rc-1'},
    {id: 'bio-3', setId: 'qs-bio__genes', topicId: 'topic_bio', lessonId: 'lesson-bio-genes', passageId: null}],
};
const betaPinned = {
  revision: 'exam_alpha:v-exam_alpha|exam_beta.subj_math:v-exam_beta.subj_math|exam_beta:v-exam_beta|index:v-index:exam-lessons-v2',
  subjects: [{id: 'subj_sci', name: 'Science', ordering: 1}, {id: 'subj_math', name: 'Mathematics', ordering: 2}],
  topics: [{id: 'topic_bio', name: 'Biology', subjectId: 'subj_sci', ordering: 1},
    {id: 'topic_alg', name: 'Algebra', subjectId: 'subj_math', ordering: 1}],
  lessons: [{id: 'lesson-alg-eq', topicId: 'topic_alg', title: 'Equations', ordering: 1, prerequisites: []},
    // Exam beta has no question on Genes, so the exam lesson rule (Nov 5) leaves it out.
    {id: 'lesson-bio-cells', topicId: 'topic_bio', title: 'Cells', ordering: 1, prerequisites: []}],
  questions: [
    {id: 'bio-1', setId: 'qs-bio__cells', topicId: 'topic_bio', lessonId: 'lesson-bio-cells', passageId: null},
    {id: 'bio-2', setId: 'qs-bio__cells', topicId: 'topic_bio', lessonId: 'lesson-bio-cells', passageId: 'rc-1'},
    {id: 'alg-1', setId: 'qs-alg__eq', topicId: 'topic_alg', lessonId: 'lesson-alg-eq', passageId: null}],
};

test('a listed exam loads exactly as before, in order, with its revision and its reads', async () => {
  const one = fakeDb();
  assert.deepEqual(await loadStudyContent(one.db, 'exam_alpha', one.tx), alphaPinned);
  assert.deepEqual(one.db.reads, [path('exam_alpha'), path('index')]);
  const two = fakeDb();
  assert.deepEqual(await loadStudyContent(two.db, 'exam_beta', two.tx), betaPinned);
  assert.deepEqual(two.db.reads, [path('exam_beta'), path('exam_beta.subj_math'), path('index'), path('exam_alpha')],
    'a split exam reads its parts, then the index, then the exam that owns the lessons');
});

test('a listed exam loads the same without a transaction, and without an index document', async () => {
  const {db} = fakeDb();
  assert.deepEqual(await loadStudyContent(db, 'exam_beta'), betaPinned);
  const bare = fakeDb(without(documents(), 'index'));
  assert.deepEqual(await loadStudyContent(bare.db, 'exam_alpha'), {...alphaPinned, revision: 'exam_alpha:v-exam_alpha:exam-lessons-v2'});
});

test('a listed exam with no catalog document is unavailable, and a custom-looking id gets no special path unless it matches', async () => {
  const {db} = fakeDb();
  await rejects(loadStudyContent(db, 'exam_gamma'), 'unavailable', 'The exam content catalog is not available.');
  await rejects(loadStudyContent(db, 'exam_custom'), 'unavailable', 'The exam content catalog is not available.');
  await rejects(loadStudyContent(db, CUSTOM.toUpperCase()), 'unavailable', 'The exam content catalog is not available.');
});

test('a listed exam still refuses a repeated question identity, even inside one catalog', async () => {
  const docs = documents();
  docs.exam_alpha.sets = [docs.exam_alpha.sets[0], docs.exam_alpha.sets[0]];
  await rejects(loadStudyContent(fakeDb(docs).db, 'exam_alpha'), 'unavailable', 'Duplicate authored question identities.');
});

// ---- custom ids: the union of every catalog the index lists -------------------------------------
test('a custom id loads the union of every listed catalog once, with each set once', async () => {
  const {db, tx} = fakeDb();
  const content = await loadStudyContent(db, CUSTOM, tx);
  assert.deepEqual(content.questions.map(q => q.id), ['bio-1', 'bio-2', 'bio-3', 'alg-1'],
    'the set tagged for both exams appears in both catalogs and counts once');
  assert.deepEqual(content.topics.map(t => t.id), ['topic_bio', 'topic_alg']);
  assert.deepEqual(content.subjects.map(s => s.id), ['subj_sci', 'subj_math']);
  assert.deepEqual(content.lessons.map(l => l.id), ['lesson-alg-eq', 'lesson-bio-cells', 'lesson-bio-genes'],
    'lessons come from every catalog, whichever one holds them');
  assert.equal(content.revision, 'exam_alpha:v-exam_alpha|exam_beta.subj_math:v-exam_beta.subj_math|exam_beta:v-exam_beta|index:v-index:exam-lessons-v2');
});

test('a custom id reads each document once, including the lesson owners and the part documents', async () => {
  const {db} = fakeDb();
  await loadStudyContent(db, CUSTOM);
  assert.deepEqual([...db.reads].sort(), [path('exam_alpha'), path('exam_beta'), path('exam_beta.subj_math'), path('index')]);
  assert.equal(new Set(db.reads).size, db.reads.length, 'no document is read twice');
});

test('a subject or topic with no set in any catalog does not appear', async () => {
  const content = await loadStudyContent(fakeDb().db, CUSTOM);
  assert.equal(content.subjects.some(s => s.id === 'subj_verbal'), false);
  assert.equal(content.topics.some(t => t.id === 'topic_vocab'), false);
});

test('a custom id needs the index: a missing index is unavailable', async () => {
  const {db} = fakeDb(without(documents(), 'index'));
  await rejects(loadStudyContent(db, CUSTOM), 'unavailable', 'The exam content catalog is not available.');
});

test('a custom id never returns a partial corpus: a listed catalog or part that is missing is unavailable', async () => {
  await rejects(loadStudyContent(fakeDb(without(documents(), 'exam_beta')).db, CUSTOM), 'unavailable', 'The exam content catalog is not available.');
  await rejects(loadStudyContent(fakeDb(without(documents(), 'exam_beta.subj_math')).db, CUSTOM), 'unavailable', 'The exam content catalog is not available.');
  await rejects(loadStudyContent(fakeDb(without(documents(), 'exam_alpha')).db, CUSTOM), 'unavailable', 'The exam content catalog is not available.');
});

test('a custom id refuses an index that lists no usable catalogs', async () => {
  for (const catalogs of [undefined, [], 'exam_alpha', [7], ['a/b']]) {
    const docs = documents();
    docs.index = {...docs.index, catalogs};
    await rejects(loadStudyContent(fakeDb(docs).db, CUSTOM), 'unavailable');
  }
});

test('a malformed catalog document is unavailable for a custom id, not a crash', async () => {
  const {db} = fakeDb({...documents(), exam_beta: '{not json'});
  await rejects(loadStudyContent(db, CUSTOM), 'unavailable', 'The exam content catalog could not be read.');
});

test('two different sets holding one question id stay a duplicate identity', async () => {
  const docs = documents();
  docs['exam_beta.subj_math'].sets = [docs['exam_beta.subj_math'].sets[0],
    {...docs['exam_beta.subj_math'].sets[1], questions: [{id: 'bio-3'}]}];
  await rejects(loadStudyContent(fakeDb(docs).db, CUSTOM), 'unavailable', 'Duplicate authored question identities.');
});

// A set tagged for two exams sits in both catalogs. Real uploads write the same copy in each; copies that differ mean a read met an upload.
const copyDocs = (second) => {
  const docs = documents();
  docs['exam_beta.subj_math'].sets = [second, docs['exam_beta.subj_math'].sets[1]];
  return docs;
};
const shared = documents().exam_alpha.sets[0];

test('copies of one set that differ are unavailable, so a read during an upload is retried and never mixed', async () => {
  for (const second of [
    {...shared, questions: [{id: 'bio-1'}]},                              // a question missing
    {...shared, questions: [{id: 'bio-1'}, {id: 'bio-2'}]},               // a passage missing
    {...shared, questions: [...shared.questions, {id: 'bio-9'}]},         // a question added
    {...shared, questions: [...shared.questions].reverse()},              // another order
    {...shared, topic: 'topic_alg'},
    {...shared, lesson: 'lesson-bio-genes'},
    {...shared, lesson: null},
  ]) {
    await rejects(loadStudyContent(fakeDb(copyDocs(second)).db, CUSTOM), 'unavailable', 'Question-set copies differ.');
    clearExamContentCache();
    await rejects(loadCorpusCached(fakeDb(copyDocs(second)).db, 1_000), 'unavailable', 'Question-set copies differ.');
  }
});

test('identical copies of a set dedupe, however their references are written and whatever exams they list', async () => {
  const baseline = await loadStudyContent(fakeDb().db, CUSTOM);
  for (const second of [
    {...shared},
    {...shared, topic: {_ref: 'topic_bio'}, lesson: {_ref: 'lesson-bio-cells'}},
    {...shared, exams: ['exam_beta']},
    {...shared, exams: ['exam_alpha', 'exam_beta', 'exam_gamma'], language: 'fil'},
  ]) {
    assert.deepEqual(await loadStudyContent(fakeDb(copyDocs(second)).db, CUSTOM), baseline);
  }
  // A listed exam does not compare copies at all.
  const listed = documents();
  listed.exam_alpha.sets = [shared, {...shared, questions: [{id: 'bio-1'}]}, listed.exam_alpha.sets[1]];
  await rejects(loadStudyContent(fakeDb(listed).db, 'exam_alpha'), 'unavailable', 'Duplicate authored question identities.');
});

test('a set without its exam tags is unavailable, as for a listed exam', async () => {
  const docs = documents();
  docs.exam_alpha.sets = [docs.exam_alpha.sets[0], {...docs.exam_alpha.sets[1], exams: undefined}];
  await rejects(loadStudyContent(fakeDb(docs).db, CUSTOM), 'unavailable', 'Question-set exam membership is not available.');
});

test('a set whose lesson belongs to another topic is unavailable for a custom id too', async () => {
  const docs = documents();
  docs.exam_alpha.sets = [docs.exam_alpha.sets[0], {...docs.exam_alpha.sets[1], lesson: 'lesson-alg-eq'}];
  await rejects(loadStudyContent(fakeDb(docs).db, CUSTOM), 'unavailable', 'The lesson and question-set topics differ.');
});

test('a content upload changes the custom revision, as it does for a listed exam', async () => {
  const first = await loadStudyContent(fakeDb().db, CUSTOM);
  const changed = fakeDb();
  changed.db.stored.get(path('exam_beta.subj_math')).version = 'v-next';
  assert.notEqual((await loadStudyContent(changed.db, CUSTOM)).revision, first.revision);
});

test('the custom content is the same for any custom id', async () => {
  const other = 'exam_custom_ffffffff-ffff-4fff-bfff-ffffffffffff';
  assert.deepEqual(await loadStudyContent(fakeDb().db, other), await loadStudyContent(fakeDb().db, CUSTOM));
});

// ---- applyScope ---------------------------------------------------------------------------------
test('applyScope removes excluded topics, excluded lessons and the questions that depend on them', async () => {
  const all = await loadStudyContent(fakeDb().db, CUSTOM);
  const scoped = applyScope(all, ['topic_alg'], ['lesson-bio-genes']);
  assert.deepEqual(scoped.topics.map(t => t.id), ['topic_bio']);
  assert.deepEqual(scoped.lessons.map(l => l.id), ['lesson-bio-cells']);
  assert.deepEqual(scoped.questions.map(q => q.id), ['bio-1', 'bio-2'],
    'bio-3 is linked to an excluded lesson and alg-1 to an excluded topic');
  assert.equal(scoped.revision, all.revision);
  assert.deepEqual(scoped.subjects, all.subjects);
  assert.equal(all.questions.length, 4, 'the input is not changed');
});

test('applyScope keeps a question with no lesson, and treats missing lists as empty', () => {
  const content = {revision: 'r', subjects: [], topics: [{id: 't', name: 'T', subjectId: 's', ordering: 0}], lessons: [],
    questions: [{id: 'q', setId: 'set', topicId: 't', lessonId: null, passageId: null}]};
  assert.deepEqual(applyScope(content, undefined, undefined), content);
  assert.deepEqual(applyScope(content, [], ['anything']).questions.map(q => q.id), ['q']);
  assert.deepEqual(applyScope(content, ['t'], []).questions, []);
});

// ---- the cached corpus --------------------------------------------------------------------------
test('loadCorpusCached holds the corpus for five minutes and clearExamContentCache drops it', async () => {
  const {db} = fakeDb();
  const first = await loadCorpusCached(db, 1_000);
  assert.deepEqual(first, await loadStudyContent(fakeDb().db, CUSTOM));
  const reads = db.reads.length;
  assert.equal(await loadCorpusCached(db, 1_000 + 299_999), first);
  assert.equal(db.reads.length, reads, 'inside the window nothing is read');
  await loadCorpusCached(db, 1_000 + 300_000);
  assert.ok(db.reads.length > reads, 'after five minutes it is read again');
  const again = db.reads.length;
  await loadCorpusCached(db, 1_000 + 300_000);
  assert.equal(db.reads.length, again);
  clearExamContentCache();
  await loadCorpusCached(db, 1_000 + 300_000);
  assert.ok(db.reads.length > again, 'clearing drops it');
  const early = db.reads.length;
  await loadCorpusCached(db, 5);
  assert.ok(db.reads.length > early, 'a clock that moved back is never a hit');
});

test('loadCorpusCached with fresh reads again inside the window, and keeps what it read', async () => {
  const {db} = fakeDb();
  const first = await loadCorpusCached(db, 1_000);
  const reads = db.reads.length;
  assert.equal(await loadCorpusCached(db, 1_001), first);
  assert.equal(db.reads.length, reads);
  db.stored.set(path('exam_beta.subj_math'), {...db.stored.get(path('exam_beta.subj_math')), version: 'v-next'});
  const fresh = await loadCorpusCached(db, 1_002, {fresh: true});
  assert.ok(db.reads.length > reads, 'a fresh load reads');
  assert.notEqual(fresh.revision, first.revision);
  assert.equal(await loadCorpusCached(db, 1_003), fresh, 'and what it read is what the cache now holds');
  assert.equal((await loadCorpusCached(db, 1_004, {fresh: false})), fresh);
});

test('a failed corpus load is not cached', async () => {
  const broken = fakeDb(without(documents(), 'exam_beta'));
  await rejects(loadCorpusCached(broken.db, 1_000), 'unavailable');
  const good = fakeDb();
  assert.equal((await loadCorpusCached(good.db, 1_001)).questions.length, 4);
});

// ---- catalog documents built by the upload code from the committed content tree -----------------
// The upload tool takes the exam, subject and topic rows from a Dart build, which a Node-only job
// cannot run. This builds them from the committed outline, which lists the same subjects and topics
// except the two the real catalog adds for the Civil Service Verbal Ability subject (no set anywhere).
// The sets and lessons are the real files. Counts are printed, never asserted as constants.
const walk = (dir, ext) => readdirSync(dir).sort().flatMap(name => {
  const full = join(dir, name);
  return statSync(full).isDirectory() ? walk(full, ext) : full.endsWith(ext) ? [full] : [];
});
const stamp = '2026-01-01T00:00:00.000Z';
const row = (id, fields) => ({_id: id, _updatedAt: stamp, schemaVersion: 1, isActive: true, ...fields});
const underscore = value => value.replaceAll('-', '_');

function realCatalogDocuments() {
  const {parse} = createRequire(import.meta.url)('yaml');
  const root = new URL('../../content/', import.meta.url).pathname;
  const outline = JSON.parse(readFileSync(new URL('../../tools/lesson_author/outline.json', import.meta.url), 'utf8'));
  const questionsRoot = join(root, 'questions');
  // The uploader reports a file the YAML library rejects and skips it with --skip-invalid; so does this.
  const sets = walk(questionsRoot, '.yaml').flatMap((file) => {
    try { return [{source: parse(readFileSync(file, 'utf8')), relativePath: relative(questionsRoot, file)}]; } catch { return []; }
  });
  const lessons = walk(join(root, 'lessons'), '.md').map(file => parse(/^---\n([\s\S]*?)\n---/.exec(readFileSync(file, 'utf8'))[1]));
  const structure = {exam: [], subject: [], topic: []};
  const exams = new Set(sets.flatMap(s => (s.source.meta.exams ?? []).map(code => `exam_${underscore(code)}`)));
  for (const subject of outline.subjects) {
    const examId = `exam_${underscore(subject.exam ?? 'upcat')}`;
    exams.add(examId);
    const subjectId = `subj_upcat_${underscore(subject.slug)}`;
    structure.subject.push(row(subjectId, {exam: {_ref: examId}, name: subject.name, ordering: structure.subject.length + 1}));
    for (const topic of subject.topics) {
      structure.topic.push(row(`topic_upcat_${underscore(topic.slug)}`, {subject: {_ref: subjectId}, name: topic.name, ordering: structure.topic.length + 1}));
    }
  }
  structure.subject.push(row('subj_cse_verbal', {exam: {_ref: 'exam_cse_pro'}, name: 'Verbal Ability', ordering: 99}));
  structure.topic.push(row('topic_cse_vocab', {subject: {_ref: 'subj_cse_verbal'}, name: 'Vocabulary', ordering: 99}));
  for (const id of exams) structure.exam.push(row(id, {code: id, name: id, shortName: id, language: 'en', ordering: structure.exam.length + 1}));
  const stored = Object.fromEntries(catalogItems({structure, lessons, sets}).map(item => [item.id, {payload: item.data.payload, version: item.data.version}]));
  return {stored, sets};
}

test('the union of the committed content tree has every set and question once, with no empty subject or topic', async () => {
  const {stored, sets} = realCatalogDocuments();
  const {db} = fakeDb({});
  for (const [id, data] of Object.entries(stored)) db.stored.set(path(id), data);
  const content = await loadStudyContent(db, CUSTOM);

  const held = q => q.figure != null && String(q.figure).trim() !== '' && q.figureSpec == null;
  const authored = sets.filter(s => Array.isArray(s.source.meta.exams) && s.source.meta.exams.length > 0);
  const expected = authored.flatMap(s => s.source.questions.filter(q => !held(q)).map(q => String(q.id)));
  assert.equal(new Set(expected).size, expected.length, 'the authored question ids are unique');
  assert.deepEqual(content.questions.map(q => q.id).sort(), expected.sort());
  assert.equal(new Set(content.questions.map(q => q.setId)).size, authored.length);

  const topicIds = new Set(content.topics.map(t => t.id));
  assert.ok(content.topics.length > 0);
  assert.ok(content.questions.every(q => topicIds.has(q.topicId)));
  assert.ok(content.topics.every(t => content.questions.some(q => q.topicId === t.id)), 'every topic has a question');
  assert.ok(content.subjects.every(s => content.topics.some(t => t.subjectId === s.id)), 'every subject has a topic');
  assert.ok(content.topics.every(t => t.id.startsWith('topic_upcat_')), 'only catalog topic ids, never a topic_custom_ id');
  assert.equal(topicIds.has('topic_cse_vocab'), false);
  assert.equal(content.subjects.some(s => s.id === 'subj_cse_verbal'), false);
  const lessonIds = new Set(content.lessons.map(l => l.id));
  assert.ok(content.questions.every(q => q.lessonId === null || lessonIds.has(q.lessonId)), 'every set lesson is present');
  assert.equal(new Set(db.reads).size, db.reads.length, 'no document is read twice');
  assert.equal(content.revision.split('|').length, Object.keys(stored).length, 'every document counts once in the revision');

  const listed = await loadStudyContent(db, 'exam_cse_pro');
  const union = new Set(content.questions.map(q => q.id));
  assert.ok(listed.questions.length > 0 && listed.questions.every(q => union.has(q.id)), 'a listed exam is inside the union');
  console.log(`# committed tree union: ${authored.length} sets, ${content.questions.length} questions, ${content.lessons.length} lessons, `
    + `${content.topics.length} topics, ${content.subjects.length} subjects, ${Object.keys(stored).length} catalog documents; exam_cse_pro alone: ${listed.questions.length} questions`);
});
