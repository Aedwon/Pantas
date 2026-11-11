import assert from 'node:assert/strict';
import {registerHooks} from 'node:module';
import {test} from 'node:test';

// Read the source without building functions or starting an emulator.
registerHooks({resolve(specifier, context, nextResolve) {
  if (specifier === './generated/cse_parts.js') {
    return nextResolve('./generated/cse_parts.ts', context);
  }
  return nextResolve(specifier, context);
}});
const {examSubjectGroups, examPerformanceSubjects, examSubjectName} =
  await import('../src/_examSubjectGroups.ts');

const content = {
  subjects: [{id: 'math', name: 'Mathematics', ordering: 0}],
  topics: ['Algebra', 'Data Interpretation', 'Vocabulary',
    'Philippine Constitution', 'Clerical Ability', 'Geometry'].map((name, i) =>
    ({id: 't' + i, name, subjectId: 'math', ordering: i})),
};

test('CSE headings contain only the ordered parts', () => {
  assert.deepEqual(examSubjectGroups('exam_cse_pro', content).map(s => s.name),
    ['General Information', 'Verbal Ability', 'Analytical Ability', 'Numerical Ability']);
  assert.deepEqual(examSubjectGroups('exam_cse_sub', content).map(s => s.name),
    ['General Information', 'Verbal Ability', 'Numerical Ability', 'Clerical Ability']);
  assert.equal(examSubjectName('exam_cse_pro', content.topics[5], 'Mathematics'), null);
});

test('other exams retain their subjects and topic identities', () => {
  assert.deepEqual(examSubjectGroups('exam_upcat', content),
    [{id: 'math', name: 'Mathematics', topics: content.topics}]);
});

test('Data Interpretation figures belong to Analytical', () => {
  const rows = examPerformanceSubjects('exam_cse_pro', content, [
    {id: 't0', correct: 0, answered: 3},
    {id: 't1', correct: 2, answered: 4},
  ]);
  assert.deepEqual(rows, [
    {id: 'analytical_ability', title: 'Analytical Ability', correct: 2, answered: 4, topicCount: 1},
    {id: 'numerical_ability', title: 'Numerical Ability', correct: 0, answered: 3, topicCount: 1},
  ]);
});
