import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, readFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import test from 'node:test';
import {lessonItem, questionSetItems, planWrites} from '../lib/contentUpload.js';
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
  mkdirSync(join(root, 'lessons/s'), {recursive: true});
  mkdirSync(join(root, 'questions/s/t'), {recursive: true});
  writeFileSync(join(root, 'lessons/s/a.md'), '---\n_id: "lesson-a"\ntitle: "A"\n---\n## Hi\n');
  writeFileSync(join(root, 'questions/s/t/u.yaml'),
    'meta:\n  subject: s\n  topic: t\n  subtopic: u\n  exams: [cse-pro]\nquestions:\n  - id: q1\n    stem: x\n    choices:\n      - text: a\n        correct: true\n      - text: b\n        rationale: no\n');
  const tool = new URL('../../tools/upload_content/upload_content.mjs', import.meta.url).pathname;
  const env = {...process.env};
  delete env.FIRESTORE_EMULATOR_HOST;
  const dry = spawnSync('node', [tool, '--root', root, '--dry-run'], {env, encoding: 'utf8'});
  assert.equal(dry.status, 0, dry.stderr);
  assert.match(dry.stdout, /lessons: 1/);
  assert.match(dry.stdout, /question sets: 1/);
  assert.match(dry.stdout, /pro documents: 1/);
  assert.match(dry.stdout, /dry run/i);
  const live = spawnSync('node', [tool, '--root', root], {env, encoding: 'utf8'});
  assert.notEqual(live.status, 0);
  assert.match(live.stderr, /--live/);
});

test('index exports the Pro content, mock and ingest callables, all behind App Check', () => {
  for (const [name, file] of [['getContent', 'content.ts'], ['startMock', 'mock.ts'], ['submitMock', 'mock.ts'], ['ingestSession', 'ingestSession.ts']]) {
    assert.equal(typeof endpoints[name], 'function', name);
    assert.match(source('index.ts'), new RegExp(`export \\{ ${name} \\}`));
    assert.match(source(file), /enforceAppCheck: true/);
  }
  assert.match(source('mock.ts'), /assertNamedUser\(auth\)/);
});
