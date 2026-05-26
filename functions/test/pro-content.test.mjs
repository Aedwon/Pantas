import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const source = () =>
  readFileSync(new URL('../src/getProContent.ts', import.meta.url), 'utf8');
const indexSource = () =>
  readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');

test('getProContent rejects unauthenticated requests', () => {
  assert.match(source(), /if \(!request\.auth\)/);
  assert.match(source(), /HttpsError\('unauthenticated'/);
});

test('getProContent rejects authenticated requests without pro claim', () => {
  assert.match(source(), /request\.auth\.token\.pro !== true/);
  assert.match(source(), /HttpsError\('permission-denied'/);
});

test('getProContent allows authenticated pro claim and builds Pro query shape', () => {
  const content = source();

  assert.match(content, /request\.auth\.token\.pro === true/);
  assert.match(content, /pro == true/);
  assert.match(content, /doctype/);
});

test('getProContent source does not expose Sanity token literals', () => {
  const content = source();

  assert.doesNotMatch(content, /sk[A-Za-z0-9_]{20,}/);
  assert.match(content, /SANITY_READ_TOKEN/);
});

test('getProContent is exported from index', () => {
  assert.match(indexSource(), /export \{ getProContent \}/);
});
