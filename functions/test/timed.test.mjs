import assert from 'node:assert/strict';
import { readdirSync, readFileSync } from 'node:fs';
import test from 'node:test';
import { HttpsError } from 'firebase-functions/v2/https';
import { timed } from '../lib/_timed.js';

function harness(clockTicks = [0, 25]) {
  const lines = [];
  const ticks = [...clockTicks];
  return {lines, deps: {log: (message, fields) => lines.push([message, fields]), now: () => ticks.shift() ?? 0}};
}
const request = {auth: {uid: 'user-123456', token: {email: 'a@b.co'}}, data: {uid: 'user-123456'}};

test('logs one fn_timing line per call with the elapsed milliseconds', async () => {
  const {lines, deps} = harness([100, 142.4]);
  const handler = timed('getThing', async () => 'result', deps);
  assert.equal(await handler(request), 'result');
  assert.equal(lines.length, 1);
  assert.equal(lines[0][0], 'fn_timing');
  assert.deepEqual(lines[0][1], {kind: 'fn_timing', fn: 'getThing', ms: 42, cold: true, outcome: 'ok'});
});

test('passes the request through and returns the handler result unchanged, sync or async', async () => {
  const {deps} = harness();
  const seen = [];
  const sync = timed('a', (r) => { seen.push(r); return {n: 1}; }, deps);
  const asyncHandler = timed('b', async (r) => { seen.push(r); return {n: 2}; }, deps);
  assert.deepEqual(await sync(request), {n: 1});
  assert.deepEqual(await asyncHandler(request), {n: 2});
  assert.deepEqual(seen, [request, request]);
});

test('cold is true only on the first call in that instance', async () => {
  const {lines, deps} = harness();
  const handler = timed('getThing', () => 1, deps);
  await handler(request);
  await handler(request);
  await handler(request);
  assert.deepEqual(lines.map(([, f]) => f.cold), [true, false, false]);
});

test('an HttpsError is rethrown unchanged and logged with its code', async () => {
  const {lines, deps} = harness();
  const failure = new HttpsError('permission-denied', 'No.');
  const handler = timed('getThing', async () => { throw failure; }, deps);
  await assert.rejects(handler(request), (error) => error === failure && error.code === 'permission-denied');
  assert.equal(lines.length, 1);
  assert.equal(lines[0][1].outcome, 'error');
  assert.equal(lines[0][1].code, 'permission-denied');
});

test('a synchronous throw is rethrown unchanged and logged', async () => {
  const {lines, deps} = harness();
  const failure = new HttpsError('invalid-argument', 'Bad.');
  const handler = timed('getThing', () => { throw failure; }, deps);
  await assert.rejects(handler(request), (error) => error === failure);
  assert.equal(lines[0][1].code, 'invalid-argument');
});

test('an unexpected error is rethrown unchanged, logged as an error with no code', async () => {
  const {lines, deps} = harness();
  const failure = new TypeError('boom');
  const handler = timed('getThing', async () => { throw failure; }, deps);
  await assert.rejects(handler(request), (error) => error === failure);
  assert.equal(lines[0][1].outcome, 'error');
  assert.ok(!('code' in lines[0][1]));
});

test('a failing log call never changes the result', async () => {
  const handler = timed('getThing', async () => 'fine', {log: () => { throw new Error('log down'); }, now: () => 0});
  assert.equal(await handler(request), 'fine');
});

test('the line never contains the uid, email or token', async () => {
  const {lines, deps} = harness();
  await timed('getThing', async () => ({uid: 'user-123456'}), deps)(request);
  await assert.rejects(timed('getThing', async () => { throw new HttpsError('not-found', 'user-123456'); }, deps)(request));
  const text = JSON.stringify(lines);
  for (const forbidden of ['user-123456', 'a@b.co', 'uid', 'email', 'token', 'auth']) {
    assert.ok(!text.includes(forbidden), `the line must not contain ${forbidden}`);
  }
});

test('every onCall export wraps its handler with its own export name', () => {
  const srcDir = new URL('../src/', import.meta.url);
  let found = 0;
  for (const file of readdirSync(srcDir).filter((name) => name.endsWith('.ts'))) {
    const source = readFileSync(new URL(file, srcDir), 'utf8');
    for (const match of source.matchAll(/export const (\w+)\s*=\s*onCall\(/g)) {
      found += 1;
      assert.ok(source.includes(`timed('${match[1]}',`), `${file}: ${match[1]} must use timed('${match[1]}', ...)`);
    }
    assert.equal([...source.matchAll(/\bonCall\(/g)].length, [...source.matchAll(/export const \w+\s*=\s*onCall\(/g)].length, `${file}: an onCall is not an export const`);
  }
  assert.ok(found >= 36, `found only ${found} callables`);
});
