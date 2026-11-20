import assert from 'node:assert/strict';
import test from 'node:test';
import {clearExamContentCache} from '../lib/_examContent.js';
import {assemblePaper} from '../lib/mock.js';

for (const [exam, prefix] of Object.entries({
  dlsucet: 'upcat', ustet: 'upcat', acet: 'upcat',
  upcat: 'upcat', cse_pro: 'cse_pro', cse_sub: 'cse_sub',
})) {
  test(`${exam} fills authored topic slots from exam-tagged question and passage pools`, async () => {
    clearExamContentCache();
    const examId = `exam_${exam}`;
    const fields = {
      durationMinutes: 10,
      sectionsJson: JSON.stringify([{
        id: 'reading', name: 'Reading', questionCount: 3, suggestedMinutes: 10,
        topicIds: [`topic_${prefix}_reading_comprehension`],
      }]),
    };
    const questionSet = (id, exams, questions) => ({
      id, get: key => ({payload: JSON.stringify({
        meta: {topic: 'reading-comprehension', exams}, questions,
      })})[key],
    });
    const expected = [{id: 'p1', passage: 'passage'}, {id: 'p2', passage: 'passage'}, {id: 'solo'}];
    const docs = [
      questionSet('included', [exam.replaceAll('_', '-')], [
        ...expected,
        ...['big1', 'big2', 'big3', 'big4'].map(id => ({id, passage: 'oversized'})),
      ]),
      questionSet('other', ['exam-tag-not-selected'], [{id: 'other'}]),
    ];
    const history = {where: () => history, orderBy: () => history, limit: () => history,
      get: async () => ({docs: []}),
    };
    const db = {
      doc: path => {
        assert.equal(path, `content/mocks/items/${examId}`);
        return {get: async () => ({exists: true, get: key => fields[key]})};
      },
      collection: path => {
        if (path === 'content/questions/items') return {get: async () => ({docs})};
        if (path === 'content/lessons/items') return {select: () => ({get: async () => ({docs: []})})};
        assert.equal(path, 'users/student/server/mocks/items');
        return history;
      },
    };

    for (let seed = 0; seed < 12; seed++) {
      const {paper} = await assemblePaper(db, 'student', examId, 0, seed);
      assert.equal(paper.expectedQuestionCount, 3);
      assert.deepEqual(paper.sections[0].questions.sort((a, b) => a.id.localeCompare(b.id)),
        expected.map(({id}) => ({id, setId: 'included'})));
    }
  });
}
