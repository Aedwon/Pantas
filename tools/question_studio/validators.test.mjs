import { test } from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion, findDuplicateStems } from './validators.mjs';

test('valid question has no errors', () => {
  assert.deepEqual(
    validateQuestion({
      id: 'q-1',
      stem: 'Which is a metal?',
      choices: [
        { text: 'Iron', correct: true },
        { text: 'Oxygen', correct: false },
      ],
      explanation: 'Iron is a metal.',
    }),
    [],
  );
});

test('flags zero and multiple correct answers', () => {
  assert.match(
    validateQuestion({
      id: 'q-2', stem: 's', explanation: 'e',
      choices: [{ text: 'a', correct: false }, { text: 'b', correct: false }],
    }).join(' '),
    /exactly one correct/,
  );
});

test('flags empty fields and too few choices', () => {
  const errs = validateQuestion({ id: 'q-3', stem: '', explanation: '', choices: [{ text: 'a', correct: true }] });
  assert.ok(errs.some((e) => /stem/.test(e)));
  assert.ok(errs.some((e) => /explanation/.test(e)));
  assert.ok(errs.some((e) => /at least 2 choices/.test(e)));
});

test('detects duplicate stems', () => {
  assert.deepEqual(
    findDuplicateStems([
      { id: 'q-1', stem: 'Same  question?' },
      { id: 'q-2', stem: 'same question ?' },
    ]),
    [['q-1', 'q-2']],
  );
});
