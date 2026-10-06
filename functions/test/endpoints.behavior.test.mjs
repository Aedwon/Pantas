import assert from 'node:assert/strict';
import test from 'node:test';
import * as endpoints from '../lib/index.js';

test('deploy entry does not expose the unused content endpoint', () => {
  assert.equal(Object.hasOwn(endpoints, 'getProContent'), false);
});
