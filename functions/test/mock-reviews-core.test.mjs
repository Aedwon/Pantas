import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {readFileSync, existsSync} from 'node:fs';
import test from 'node:test';
createRequire(import.meta.url)(new URL('../src/generated/pantas_core.js', import.meta.url).pathname);
test('the shared scheduler is exported for server recording and due reads', () => {
  assert.equal(typeof globalThis.pantasScheduleReviews, 'function');
  assert.equal(typeof globalThis.pantasDueReviews, 'function');
});
const fixtures = new URL('../../server_dart/fixtures/review_scenarios.json', import.meta.url);
const expected = new URL('../../server_dart/fixtures/review_expected.json', import.meta.url);
if (existsSync(fixtures) && existsSync(expected)) {
 const inputs = JSON.parse(readFileSync(fixtures, 'utf8'));
 const outputs = JSON.parse(readFileSync(expected, 'utf8'));
 for (const [name, input] of Object.entries(inputs)) test(`review scheduler ${name} matches the Dart VM byte for byte`, () => {
   const states = globalThis.pantasScheduleReviews(JSON.stringify(input));
   assert.equal(states, JSON.stringify(outputs[name].states));
   assert.equal(globalThis.pantasDueReviews(JSON.stringify({now: input.now, states: JSON.parse(states)})), JSON.stringify(outputs[name].due));
 });
}
