import assert from 'node:assert/strict';
import test from 'node:test';
import {createRequire} from 'node:module';
createRequire(import.meta.url)('../src/generated/pantas_core.js');

const topics = [
  {topicId: 'topic_cse_pro_vocabulary', correct: 3, answered: 4},
  {topicId: 'topic_cse_pro_text_types', correct: 0, answered: 2},
  {topicId: 'topic_cse_pro_logical_verbal_reasoning', correct: 0, answered: 1},
  {topicId: 'topic_cse_pro_data_interpretation', correct: 3, answered: 3},
  {topicId: 'topic_cse_pro_arithmetic_number_sense', correct: 1, answered: 2},
  {topicId: 'topic_cse_pro_algebra', correct: 2, answered: 2},
  {topicId: 'topic_cse_pro_philippine_constitution', correct: 0, answered: 1},
  {topicId: 'topic_cse_pro_geometry', correct: 4, answered: 4},
];
const accuracy = (examId, topics) => JSON.parse(globalThis.pantasOverallAccuracy(JSON.stringify({examId, topics})));
test('shared CSC area weights include reading and analytical data interpretation', () => {
  assert.equal(accuracy('exam_cse_pro', topics), .6375);
});
test('areas without answers are omitted from the weight denominator', () => {
  assert.ok(Math.abs(accuracy('exam_cse_pro', [topics[1], topics[3]]) - 35 / 65) < 1e-12);
});
test('other exams keep the raw answer ratio', () => {
  for (const exam of ['exam_cse_sub', 'exam_upcat']) {
    assert.equal(accuracy(exam, topics), 13 / 19);
  }
});
test('no in-scope answers gives no accuracy', () => {
  assert.equal(accuracy('exam_cse_pro', [topics.at(-1)]), null);
  assert.equal(accuracy('exam_cse_pro', []), null);
});

const areas = [
  {slugs: ['vocabulary', 'grammar_and_structure', 'language_application', 'text_types', 'comprehension_skills'], weight: 30},
  {slugs: ['logical_verbal_reasoning', 'verbal_logic', 'spatial_abstract_reasoning', 'data_interpretation'], weight: 35},
  {slugs: ['arithmetic_number_sense', 'algebra'], weight: 30},
  {slugs: ['philippine_constitution', 'code_of_conduct_ra_6713', 'peace_and_human_rights', 'environment_management'], weight: 5},
];
for (const {slugs, weight} of areas) {
  for (const slug of slugs) {
    test(slug + ' uses its CSC area for current and shared topics', () => {
      for (const prefix of ['topic_cse_pro_', 'topic_upcat_']) {
        const control = weight === 30 ? 'data_interpretation' : 'algebra';
        const controlWeight = weight === 30 ? 35 : 30;
        const actual = accuracy('exam_cse_pro', [
          {topicId: prefix + slug, correct: 1, answered: 1},
          {topicId: prefix + control, correct: 0, answered: 1},
        ]);
        assert.ok(Math.abs(actual - weight / (weight + controlWeight)) < 1e-12);
      }
    });
  }
}
test('unanswered topics and topics outside the CSC areas do not change accuracy', () => {
  assert.equal(accuracy('exam_cse_pro', [
    {topicId: 'topic_cse_pro_vocabulary', correct: 1, answered: 1},
    {topicId: 'topic_cse_pro_algebra', correct: 0, answered: 0},
    ...['geometry', 'mechanical_technical_reasoning', 'clerical_ability', 'unknown'].map(slug =>
      ({topicId: 'topic_cse_pro_' + slug, correct: 0, answered: 10})),
  ]), 1);
});
