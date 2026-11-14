import assert from 'node:assert/strict';
import test from 'node:test';
import {readFileSync} from 'node:fs';
import {readSessionDiagnosis} from '../lib/sessionDiagnosis.js';
import {core} from '../lib/_core.js';
import {clearExamContentCache} from '../lib/_examContent.js';
import {phStamp} from '../lib/_phDate.js';

const cases = JSON.parse(readFileSync(new URL('../../test/fixtures/content/lesson_credit_cases.json', import.meta.url), 'utf8'));
const snapshot = (id, data) => ({id, exists: data !== undefined, get: key => data?.[key], data: () => data});

for (const fixture of cases.filter(c => !c.name.startsWith('cycle'))) {
  test('diagnosis applies family credit: ' + fixture.name, async () => {
    clearExamContentCache();
    const examId = 'exam_cse_pro';
    const catalog = {
      subjects: [{_id: 'subject', name: 'Subject', exam: examId}],
      topics: [{_id: 'topic', name: 'Topic', subject: 'subject'}],
      lessons: [
        ...fixture.active.map(id => ({id, topic: 'topic', title: id})),
        ...Object.entries(fixture.retired).map(([id, replacedBy]) => ({id, topic: 'topic', title: id, status: 'retired', replacedBy})),
      ],
      sets: fixture.active.map(id => ({id: 'set-' + id, topic: 'topic', lesson: id, exams: [examId], questions: [{id: 'q-' + id}]})),
    };
    const docs = {
      'users/credit/server/answers/items/session': {examId, answers: []},
      'users/credit/server/settings': {examId, examDate: null, studyDays: [1], excludedLessonIds: fixture.excluded},
      ['content/catalog/items/' + examId]: {version: 'credit', payload: JSON.stringify(catalog)},
    };
    const collections = {
      'users/credit/server/lessonReads/items': Object.entries(fixture.reads).map(([lessonId, readAt]) => snapshot(lessonId, {lessonId, readAt})),
      'users/credit/passes': [],
      'users/credit/grants': [],
    };
    const db = {
      doc: path => ({path, get: async () => snapshot(path, docs[path])}),
      collection: path => ({path, collection: true}),
      runTransaction: async fn => fn({get: async ref => ref.collection
        ? {docs: collections[ref.path] ?? assert.fail(ref.path)}
        : snapshot(ref.path, docs[ref.path])}),
    };
    const engine = core(), original = engine.sessionDiagnosis;
    let inputs;
    engine.sessionDiagnosis = json => { inputs = JSON.parse(json).inputs; return JSON.stringify({tracedCount: 0}); };
    try {
      await readSessionDiagnosis({uid: 'credit'}, {expectedUid: 'credit', examId, sessionId: 'session'}, {db, now: () => 1000, allow: async () => true});
    } finally {
      engine.sessionDiagnosis = original;
    }
    const eligible = fixture.active.filter(id => !fixture.expectedExcluded.includes(id));
    assert.deepEqual(inputs.lessons.map(l => l.id).sort(), [...eligible].sort());
    assert.deepEqual(Object.fromEntries(inputs.lessons.map(l => [l.id, l.readAt])),
      Object.fromEntries(eligible.map(id => [id, id in fixture.expectedReads ? phStamp(fixture.expectedReads[id]) : null])));
  });
}
