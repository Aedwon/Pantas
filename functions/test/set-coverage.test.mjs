import assert from 'node:assert/strict';
import test from 'node:test';
import {setCoveredByTags, examIdOfTag} from '../lib/_setCoverage.js';

const covers = (...ids) => id => ids.includes(id);

test('a tag names its exam id the way content delivery does', () => {
  assert.equal(examIdOfTag('cse-pro'), 'exam_cse_pro');
});

test('a set is covered when any of its exam tags is covered', () => {
  assert.equal(setCoveredByTags(['upcat', 'cse-pro'], covers('exam_cse_pro')), true);
  assert.equal(setCoveredByTags(['upcat'], covers('exam_cse_pro')), false);
});

test('a set with no usable tags is never covered', () => {
  assert.equal(setCoveredByTags(undefined, covers('exam_cse_pro')), false);
  assert.equal(setCoveredByTags([], covers('exam_cse_pro')), false);
  assert.equal(setCoveredByTags([7, null], covers('exam_cse_pro')), false);
  assert.equal(setCoveredByTags('cse-pro', covers('exam_cse_pro')), false);
});
