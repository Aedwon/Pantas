import assert from 'node:assert/strict';
import test from 'node:test';
import {build} from '../lib/roadmap.js';
import {clearExamContentCache} from '../lib/_examContent.js';

const examId = 'exam_cse_pro', now = Date.parse('2026-10-24T10:00:00+08:00');
const snapshot = (id, data) => ({id, exists: data !== undefined, get: key => data?.[key]});
const settings = {examId, examDate: {precision: 'day', day: '2026-10-25'},
  studyDays: [1, 2, 3, 4, 5, 6, 7], assessmentCompleted: true};
const emptyView = async () => ({scores: {}, seenQuestionIds: [], answeredPerActiveDay: [], anyAnswers: false, sessions: 0});

function legacyDb(catalog, lessons = []) {
  const questionDocs = ['alpha', 'beta'].map(topic => snapshot(topic, {payload: JSON.stringify({
    meta: {topic, exams: ['cse-pro']}, questions: [{id: topic + '-q'}],
  })}));
  return {
    doc: path => {
      assert.ok([`content/catalog/items/${examId}`, 'content/catalog/items/index', `content/mocks/items/${examId}`,
        'users/compat/server/roadmap'].includes(path), path);
      return {get: async () => snapshot(path, path === `content/catalog/items/${examId}` ? catalog : undefined)};
    },
    collection: path => {
      const rows = {
        'content/questions/items': questionDocs,
        'content/lessons/items': lessons.map(id => snapshot(id, {topic: 'topic-alpha'})),
        'users/compat/server/mocks/items': [],
        'users/compat/server/lessonReads/items': [],
        'users/compat/server/reviews/items': [],
      };
      assert.ok(path in rows, path);
      const query = {get: async () => ({docs: rows[path]}), select: () => query,
        orderBy: () => query, limit: () => query, where: () => query};
      return query;
    },
  };
}

test('compatibility authored topic exclusions remove unlinked legacy lessons too', async () => {
  clearExamContentCache();
  const catalog = {version: 'authored-v1', payload: JSON.stringify({
    subjects: [{_id: 'subject', name: 'Subject', exam: examId}],
    topics: [{_id: 'authored-alpha', name: 'Alpha', subject: 'subject'},
      {_id: 'authored-beta', name: 'Beta', subject: 'subject'}],
    lessons: ['linked', 'unlinked'].map(id => ({id, title: id, topic: 'authored-alpha'})),
    sets: [{id: 'alpha', topic: 'authored-alpha', lesson: 'linked', exams: [examId], questions: [{id: 'alpha-q'}]},
      {id: 'beta', topic: 'authored-beta', lesson: null, exams: [examId], questions: [{id: 'beta-q'}]}],
  })};
  const {roadmap} = await build(legacyDb(catalog, ['linked', 'unlinked']), 'compat',
    {...settings, excludedTopicIds: ['authored-alpha']}, true, now, emptyView);
  assert.deepEqual(roadmap.today.lessonIds, []);
  assert.deepEqual(roadmap.today.newQuestionIds, ['beta-q']);
});

for (const [name, catalog] of [
  ['absent', undefined],
  ['unreadable', {version: 'partial'}],
  ['partial', {version: 'partial', payload: JSON.stringify({sets: []})}],
]) {
  test(`compatibility roadmap uses legacy questions when the catalog is ${name}`, async () => {
    clearExamContentCache();
    const {roadmap} = await build(legacyDb(catalog), 'compat', settings, true, now, emptyView);
    assert.deepEqual([...roadmap.today.newQuestionIds].sort(), ['alpha-q', 'beta-q']);
  });

  test(`compatibility legacy topic exclusions work when the catalog is ${name}`, async () => {
    clearExamContentCache();
    const {roadmap} = await build(legacyDb(catalog), 'compat',
      {...settings, excludedTopicIds: ['topic_cse_pro_alpha']}, true, now, emptyView);
    assert.deepEqual(roadmap.today.newQuestionIds, ['beta-q']);
  });
}
