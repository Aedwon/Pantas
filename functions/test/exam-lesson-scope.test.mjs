import assert from 'node:assert/strict';
import test from 'node:test';
import {loadStudyContent} from '../lib/_examContent.js';

const exam = 'exam_cse_pro';
const catalog = {
  subjects: [{_id: 'math', name: 'Math', exam}, {_id: 'clerical', name: 'Clerical', exam}],
  topics: [{_id: 'algebra', name: 'Algebra', subject: 'math'}, {_id: 'filing', name: 'Filing', subject: 'clerical'}],
  lessons: ['kept', 'other', 'inactive', 'empty', 'unlinked'].map(id => ({id, title: id, topic: 'algebra'}))
    .concat([{id: 'filing', title: 'Filing', topic: 'filing'}]),
  sets: [
    {id: 'yes', topic: 'algebra', lesson: 'kept', exams: [exam], questions: [{id: 'q1'}]},
    {id: 'other', topic: 'algebra', lesson: 'other', exams: ['exam_cse_sub'], questions: [{id: 'q2'}]},
    {id: 'inactive', topic: 'algebra', lesson: 'inactive', exams: [exam], questions: [{id: 'q3', isActive: false}]},
    {id: 'empty', topic: 'algebra', lesson: 'empty', exams: [exam], questions: []},
    {id: 'unlinked', topic: 'algebra', lesson: null, exams: [exam], questions: [{id: 'q4'}]},
    {id: 'filing', topic: 'filing', lesson: 'filing', exams: [exam], questions: []},
  ],
};
const db = {doc: path => ({get: async () => ({exists: path.endsWith('/' + exam),
  get: key => key === 'payload' ? JSON.stringify(catalog) : 'v1'})})};

test('study content keeps only lessons with active exam questions and their parents', async () => {
  const content = await loadStudyContent(db, exam);
  assert.deepEqual(content.lessons.map(l => l.id), ['kept']);
  assert.deepEqual(content.topics.map(t => t.id), ['algebra']);
  assert.deepEqual(content.subjects.map(s => s.id), ['math']);
  assert.deepEqual(content.questions.map(q => q.id), ['q1', 'q4']);
});

test('the same scope rule removes excluded lessons and empty parent topics', async () => {
  const {scopeLessonContent} = await import('../lib/_examContent.js');
  const content = await loadStudyContent(db, exam);
  const scoped = scopeLessonContent(content, [], ['kept']);
  assert.deepEqual(scoped.lessons, []);
  assert.deepEqual(scoped.topics, []);
  assert.deepEqual(scoped.questions.map(q => q.id), ['q4']);
  assert.deepEqual(content.lessons.map(l => l.id), ['kept']);
});

test('lessonless exam questions keep their topic and subject', async () => {
  const lessonless = {...catalog, lessons: [], sets: [
    {id: 'practice', topic: 'algebra', lesson: null, exams: [exam], questions: [{id: 'practice-q'}]},
  ]};
  const db = {doc: path => ({get: async () => ({exists: path.endsWith('/' + exam),
    get: key => key === 'payload' ? JSON.stringify(lessonless) : 'lessonless-v1'})})};
  const content = await loadStudyContent(db, exam);
  assert.deepEqual(content.lessons, []);
  assert.deepEqual(content.topics.map(t => t.id), ['algebra']);
  assert.deepEqual(content.subjects.map(s => s.id), ['math']);
  assert.deepEqual(content.questions.map(q => q.id), ['practice-q']);
});

test('excluding every eligible lesson preserves a separate lessonless topic', async () => {
  const {scopeLessonContent} = await import('../lib/_examContent.js');
  const content = {
    topics: [{id: 'algebra'}, {id: 'filing'}, {id: 'empty'}],
    lessons: [{id: 'kept', topicId: 'algebra'}],
    questions: [{id: 'q1', topicId: 'algebra', lessonId: 'kept'},
      {id: 'q2', topicId: 'filing', lessonId: null}],
  };
  const scoped = scopeLessonContent(content, [], ['kept']);
  assert.deepEqual(scoped.lessons, []);
  assert.deepEqual(scoped.topics.map(t => t.id), ['filing']);
  assert.deepEqual(scoped.questions.map(q => q.id), ['q2']);
  assert.deepEqual(scopeLessonContent(content, ['filing'], ['kept']).topics, []);
});

// TypeScript parity tests use the exact fixture consumed by the Dart exporter.
await import('./lesson-resolution-cases.ts');

test('both content readers list active lessons in ordering then id order and resolve question tags', async () => {
  const {loadExamContent, clearExamContentCache} = await import('../lib/_examContent.js');
  clearExamContentCache();
  const lessons = [
    {id: 'old', topic: 'algebra', status: 'retired', replacedBy: ['z'], ordering: 0},
    {id: 'a', topic: 'algebra', ordering: 2},
    {id: 'z', topic: 'algebra', ordering: 1},
    {id: 'b', topic: 'algebra', ordering: 2},
  ];
  const questions = [{id: 'q1', lesson: 'old'}, {id: 'q2', lesson: 'a'}, {id: 'q3', lesson: 'b'}];
  const authored = {...catalog, lessons, sets: [{id: 'set', topic: 'algebra', lesson: 'old', exams: [exam], questions}]};
  const db = {
    doc: path => ({get: async () => ({exists: path.endsWith('/' + exam), get: key => key === 'payload' ? JSON.stringify(authored) : 'v2'})}),
    collection: path => ({select() { return this; }, get: async () => ({docs: path.includes('/questions/')
      ? [{id: 'set', get: () => JSON.stringify({meta: {topic: 'algebra', subtopic: 'old', exams: ['cse-pro']}, questions})}]
      : lessons.map(l => ({id: l.id, get: key => l[key]}))})}),
  };
  for (const content of [await loadExamContent(db, exam, 0), await loadStudyContent(db, exam)]) {
    assert.deepEqual(content.lessons.map(l => [l.id, l.ordering]), [['z', 1], ['a', 2], ['b', 2]]);
    assert.deepEqual(content.questions.map(q => q.lessonId), ['z', 'a', 'b']);
  }
});

test('per-question lessons replace an absent set-derived lesson in study catalogs', async () => {
  const authored = {...catalog, lessons: [{id: 'part', title: 'Part', topic: 'algebra'}],
    sets: [{id: 'set', topic: 'algebra', lesson: 'old-derived', exams: [exam], questions: [{id: 'q', lesson: 'part'}]}]};
  const db = {doc: path => ({get: async () => ({exists: path.endsWith('/' + exam),
    get: key => key === 'payload' ? JSON.stringify(authored) : 'tagged-v1'})})};
  assert.equal((await loadStudyContent(db, exam)).questions[0].lessonId, 'part');
});
