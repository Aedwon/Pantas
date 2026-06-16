import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildFigureItems, worklistTsv } from './question_figures.mjs';

const doc = {
  meta: { subject: 'reasoning', topic: 'mechanical-technical-reasoning', subtopic: 'structural-stability' },
  questions: [
    {
      id: 'q-mechanical-technical-reasoning-structural-stability-0001',
      figure: 'structural-stability-01',
      stem: 'Figure shows an object balanced on a point.',
      choices: [{ text: 'Center of gravity', correct: true }, { text: 'Fulcrum', correct: false }],
      explanation: 'The center of gravity is the balance point.',
    },
    {
      id: 'q-mechanical-technical-reasoning-structural-stability-0002',
      stem: 'No figure needed for this one.',
      choices: [{ text: 'A', correct: true }, { text: 'B', correct: false }],
      explanation: 'Plain text question.',
    },
  ],
};

test('buildFigureItems only includes questions with a figure slug', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(items.length, 1);
  assert.equal(items[0].questionId, 'q-mechanical-technical-reasoning-structural-stability-0001');
});

test('buildFigureItems derives the target path from subject/topic/subtopic/slug', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(
    items[0].target,
    'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png',
  );
});

test('buildFigureItems uses the stem as the description', () => {
  const items = buildFigureItems('reasoning', 'mechanical-technical-reasoning', 'structural-stability', doc);
  assert.equal(items[0].description, 'Figure shows an object balanced on a point.');
});

test('buildFigureItems returns nothing for a doc with no questions', () => {
  assert.deepEqual(buildFigureItems('s', 't', 'st', {}), []);
});

test('worklistTsv writes a header and one tab-separated row per item', () => {
  const tsv = worklistTsv([
    {
      subject: 'reasoning', topic: 'mechanical-technical-reasoning', subtopic: 'structural-stability',
      slug: 'structural-stability-01', questionId: 'q-mechanical-technical-reasoning-structural-stability-0001',
      target: 'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png',
      status: 'todo',
    },
  ]);
  const lines = tsv.trim().split('\n');
  assert.equal(lines[0], 'subject\ttopic\tsubtopic\tslug\tquestion_id\ttarget_file\tstatus');
  assert.equal(lines.length, 2);
  assert.equal(
    lines[1],
    'reasoning\tmechanical-technical-reasoning\tstructural-stability\tstructural-stability-01\t'
      + 'q-mechanical-technical-reasoning-structural-stability-0001\t'
      + 'content/illustrations/questions/reasoning/mechanical-technical-reasoning/structural-stability/structural-stability-01.png\ttodo',
  );
});
