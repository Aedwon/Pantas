import assert from 'node:assert/strict';
import test from 'node:test';
import {checkAnswers} from '../lib/_answers.js';
const now = Date.parse('2026-10-24T10:00:00+08:00');
const answer = {questionId:'q',chosen:'a',correct:true,answeredAt:now};
test('C9 keeps actual optional answer timing and version', () => {
  assert.deepEqual(checkAnswers([{...answer,responseMs:1250,questionVersion:3,ignored:'x'}], now),
    [{...answer,responseMs:1250,questionVersion:3}]);
  assert.deepEqual(checkAnswers([answer],now),[answer]);
});
test('C9 refuses invalid measured timing and version', () => {
  for (const fields of [{responseMs:-1},{responseMs:1.1},{responseMs:86400001},{questionVersion:0},{questionVersion:1.1}]) {
    assert.throws(() => checkAnswers([{...answer,...fields}],now), {code:'invalid-argument'});
  }
});
