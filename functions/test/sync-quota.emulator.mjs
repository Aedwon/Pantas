import '../lib/index.js';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import assert from 'node:assert/strict';
import test, {beforeEach, afterEach, mock} from 'node:test';
import {recordSyncWrite} from '../lib/countSyncWrites.js';
import {isValidPublicId} from '../lib/publicId.js';
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const uid = 'quota-uid-secret-1';
const at = new Date('2026-11-22T13:45:10.000Z');
const limits = () => db.doc(`users/${uid}/limits/sync_20261122`);
const state = () => db.doc(`users/${uid}/sync_state/current`);
const saved = {};
const setEnv = (values) => { for (const [k, v] of Object.entries(values)) { saved[k] ??= process.env[k]; process.env[k] = v; } };
let seq = 0;
const write = (row = {a: 1}, extra = {}) =>
  recordSyncWrite(db, {uid, eventId: `ev-${++seq}`, row, now: at, generationId: 'g1', ...extra});
const generation = (id) => db.doc(`users/${uid}/sync_generations/${id}`);
beforeEach(async () => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await state().set({activeGenerationId: 'g1', schemaVersion: 1});
  await generation('g1').set({status: 'active'});
  setEnv({SYNC_ROWS_PER_HOUR: '1000', SYNC_ROWS_PER_DAY: '1000', SYNC_BYTES_PER_DAY: '1000000', SYNC_CHECK_EVERY: '1'});
});
afterEach(() => {
  for (const [k, v] of Object.entries(saved)) { if (v === undefined) delete process.env[k]; else process.env[k] = v; }
  mock.restoreAll();
});

test('a row write adds one row, its JSON length and one to the hour bucket', async () => {
  await write({a: 1});
  await write({text: 'hello'});
  const data = (await limits().get()).data();
  assert.equal(data.rows, 2);
  assert.equal(data.bytes, JSON.stringify({a: 1}).length + JSON.stringify({text: 'hello'}).length);
  assert.equal(data.h13, 2);
});

test('a delete or an event with no row is ignored', async () => {
  await recordSyncWrite(db, {uid, eventId: 'del-1', row: undefined, now: at});
  await recordSyncWrite(db, {uid, eventId: 'del-2', row: null, now: at});
  assert.equal((await limits().get()).exists, false);
});

test('a malformed row never throws and still counts as a row', async () => {
  const circular = {}; circular.self = circular;
  await write(circular);
  await write('not an object');
  await write(42);
  assert.equal((await limits().get()).get('rows'), 3);
});

test('under every cap the account is not paused', async () => {
  for (let i = 0; i < 5; i++) await write();
  assert.equal((await state().get()).get('suspendedUntil'), undefined);
});

test('the hourly cap pauses until the next UTC hour', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '3'});
  for (let i = 0; i < 3; i++) await write();
  assert.equal((await state().get()).get('suspendedUntil'), undefined, 'at the cap is allowed');
  await write();
  const until = (await state().get()).get('suspendedUntil');
  assert.ok(until instanceof Timestamp);
  assert.equal(until.toDate().toISOString(), '2026-11-22T14:00:00.000Z');
});

test('the daily row cap pauses until UTC midnight, even when the hourly cap also passed', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '2', SYNC_ROWS_PER_DAY: '4'});
  for (let i = 0; i < 5; i++) await write();
  assert.equal((await state().get()).get('suspendedUntil').toDate().toISOString(), '2026-11-23T00:00:00.000Z');
});

test('the daily byte cap pauses until UTC midnight', async () => {
  setEnv({SYNC_BYTES_PER_DAY: '30'});
  await write({text: 'x'.repeat(40)});
  assert.equal((await state().get()).get('suspendedUntil').toDate().toISOString(), '2026-11-23T00:00:00.000Z');
});

test('a later pause is never shortened by an earlier one', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  const midnight = Timestamp.fromDate(new Date('2026-11-23T00:00:00.000Z'));
  await state().update({suspendedUntil: midnight});
  await write(); await write();
  assert.equal((await state().get()).get('suspendedUntil').toMillis(), midnight.toMillis());
});

test('only the sampled events read the counters', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '1', SYNC_CHECK_EVERY: '1000000'});
  let checked = 0;
  for (let i = 0; i < 20; i++) {
    await recordSyncWrite(db, {uid, eventId: `sample-${i}`, row: {a: 1}, now: at});
    if ((await state().get()).get('suspendedUntil')) checked++;
  }
  assert.ok(checked < 20, 'with a huge sampling interval, most events must skip the check');
});

test('with no sync_state document the pause is skipped and the document is not created', async () => {
  await state().delete();
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  await write(); await write();
  assert.equal((await state().get()).exists, false);
  assert.equal((await limits().get()).get('rows'), 2);
});

test('the pause log line carries the public id and never the raw uid or the row', async () => {
  let publicId;
  for (let n = 100_000_000; ; n++) if (isValidPublicId(String(n))) { publicId = String(n); break; }
  await db.doc(`users/${uid}`).set({publicId});
  const lines = [];
  const realWrite = process.stderr.write.bind(process.stderr);
  process.stderr.write = (chunk, ...rest) => { lines.push(String(chunk)); return realWrite(chunk, ...rest); };
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  try {
    await write({secret: 'row-content-marker'}); await write({secret: 'row-content-marker'});
  } finally { process.stderr.write = realWrite; }
  assert.ok(lines.length >= 1);
  const joined = lines.join('\n');
  assert.match(joined, /sync paused hourly/);
  assert.ok(joined.includes(publicId));
  assert.ok(!joined.includes(uid), 'no raw uid');
  assert.ok(!joined.includes('row-content-marker'), 'no row content');
});

test('a failing database call is swallowed, never thrown', async () => {
  const broken = {doc: () => { throw new Error('boom'); }};
  mock.method(console, 'error', () => {});
  await assert.doesNotReject(recordSyncWrite(broken, {uid, eventId: 'x', row: {a: 1}, now: at}));
});

test('a pause is also set on the generation being written, with no sync_state document (first push)', async () => {
  await state().delete();
  await generation('staging1').set({status: 'staging'});
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  await write({a: 1}, {generationId: 'staging1'}); await write({a: 1}, {generationId: 'staging1'});
  assert.equal((await generation('staging1').get()).get('suspendedUntil').toDate().toISOString(), '2026-11-22T14:00:00.000Z');
  assert.equal((await state().get()).exists, false);
});

test('a new generation is paused by the next counted event of a paused account', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  await write(); await write();
  assert.ok((await state().get()).get('suspendedUntil'));
  await generation('g2').set({status: 'staging'});
  await write({a: 1}, {generationId: 'g2'});
  assert.equal((await generation('g2').get()).get('suspendedUntil').toDate().toISOString(), '2026-11-22T14:00:00.000Z');
});

test('a missing generation document is not created, and a later generation pause is not shortened', async () => {
  setEnv({SYNC_ROWS_PER_HOUR: '1'});
  await write({a: 1}, {generationId: 'ghost'}); await write({a: 1}, {generationId: 'ghost'});
  assert.equal((await generation('ghost').get()).exists, false);
  const midnight = Timestamp.fromDate(new Date('2026-11-23T00:00:00.000Z'));
  await generation('g1').update({suspendedUntil: midnight});
  await write(); await write();
  assert.equal((await generation('g1').get()).get('suspendedUntil').toMillis(), midnight.toMillis());
});

test('each daily counter carries purgeAt, two days after the counter day', async () => {
  await write();
  assert.equal((await limits().get()).get('purgeAt').toDate().toISOString(), '2026-11-24T00:00:00.000Z');
});
