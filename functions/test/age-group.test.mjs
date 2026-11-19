import assert from 'node:assert/strict';
import test from 'node:test';
import {isRestrictedAgeGroup, normalizeAgeGroup} from '../lib/ageGroup.js';

test('only an adult is unrestricted: child, minor, unknown and malformed values are restricted', () => {
  assert.equal(isRestrictedAgeGroup('adult'), false);
  for (const value of ['minor', 'child', 'teen', '', 'ADULT', null, undefined, 13, {}]) {
    assert.equal(isRestrictedAgeGroup(value), true, String(value));
  }
});

test('normalizing keeps the three known groups and turns anything else into minor', () => {
  for (const value of ['adult', 'minor', 'child']) assert.equal(normalizeAgeGroup(value), value);
  for (const value of ['teen', '', null, undefined, 13]) assert.equal(normalizeAgeGroup(value), 'minor', String(value));
});
