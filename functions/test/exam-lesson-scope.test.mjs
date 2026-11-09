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
