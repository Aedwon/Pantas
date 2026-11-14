import assert from 'node:assert/strict';
import test from 'node:test';
import {RateLimiter} from '../lib/clientTelemetry.js';
import {
  SCREEN_IDS, processUsageVisit, validateUsageVisit, reportUsageVisit,
} from '../lib/usageVisit.js';

const valid = () => ({
  v: 1,
  build: '1293236267-5bbf79dc07b4',
  visit_id: '0123456789abcdef',
  screens: [{s: 'home', t: 0}, {s: 'study', t: 4200}, {s: 'lesson', t: 9100}],
});

const accepts = (mutate) => {
  const data = valid();
  mutate(data);
  assert.doesNotThrow(() => validateUsageVisit(data));
};
const refuses = (mutate) => {
  const data = valid();
  mutate(data);
  assert.throws(() => validateUsageVisit(data), (error) => error.code === 'invalid-argument');
};

test('the contract example is accepted and returned as a clean copy', () => {
  const input = valid();
  const out = validateUsageVisit(input);
  assert.deepEqual(out, input);
  assert.notEqual(out, input);
  assert.notEqual(out.screens[0], input.screens[0]);
});

test('the request must be a plain object', () => {
  for (const bad of [null, undefined, 'x', 3, [], [valid()]]) {
    assert.throws(() => validateUsageVisit(bad), (error) => error.code === 'invalid-argument');
  }
});

test('v must be 1', () => {
  for (const bad of [2, 0, '1', undefined]) refuses((d) => { d.v = bad; });
});

test('build is 1 to 40 characters of letters, digits, dot, underscore, hyphen', () => {
  accepts((d) => { d.build = 'a'.repeat(40); });
  for (const bad of ['a'.repeat(41), '', 'has space', 'semi;colon', 5, undefined]) refuses((d) => { d.build = bad; });
});

test('visit_id is exactly 16 lowercase hex characters', () => {
  accepts((d) => { d.visit_id = 'ffffffffffffffff'; });
  for (const bad of ['0123456789abcde', '0123456789abcdef0', '0123456789ABCDEF', '0123456789abcdeg', '', 5, undefined]) {
    refuses((d) => { d.visit_id = bad; });
  }
});

test('screens holds 1 to 100 entries', () => {
  accepts((d) => { d.screens = Array.from({length: 100}, () => ({s: 'home', t: 1})); });
  refuses((d) => { d.screens = Array.from({length: 101}, () => ({s: 'home', t: 1})); });
  refuses((d) => { d.screens = []; });
  refuses((d) => { d.screens = 'home'; });
  refuses((d) => { delete d.screens; });
});

test('every screen id in the closed set is accepted and nothing else is', () => {
  assert.ok(SCREEN_IDS.length > 40);
  assert.equal(new Set(SCREEN_IDS).size, SCREEN_IDS.length);
  for (const id of SCREEN_IDS) {
    assert.match(id, /^[a-z][a-z0-9_]*$/);
    accepts((d) => { d.screens = [{s: id, t: 0}]; });
  }
  for (const bad of ['Home', 'home ', 'lesson_42', '/home', '', 'a@b.co', 5, undefined]) {
    refuses((d) => { d.screens = [{s: bad, t: 0}]; });
  }
});

test('t is an integer of milliseconds from 0 to 7 days', () => {
  for (const ok of [0, 1, 604800000]) accepts((d) => { d.screens = [{s: 'home', t: ok}]; });
  for (const bad of [-1, 604800001, 1.5, '5', NaN, Infinity, undefined]) refuses((d) => { d.screens = [{s: 'home', t: bad}]; });
});

test('any extra key is refused at every level', () => {
  refuses((d) => { d.uid = 'abc'; });
  refuses((d) => { d.email = 'a@b.co'; });
  refuses((d) => { d.screens[0].extra = 1; });
  refuses((d) => { d.screens[0].text = 'hello'; });
});

test('a missing key is refused', () => {
  for (const key of Object.keys(valid())) refuses((d) => { delete d[key]; });
  refuses((d) => { delete d.screens[0].t; });
  refuses((d) => { delete d.screens[0].s; });
});

const authed = {uid: 'user-123456', token: {email: 'a@b.co'}};

test('a visit is logged once with kind usage_visit and no identity', () => {
  const lines = [];
  const result = processUsageVisit(authed, valid(), {limiter: new RateLimiter(), log: (message, fields) => lines.push([message, fields]), now: 5});
  assert.deepEqual(result, {ok: true});
  assert.equal(lines.length, 1);
  assert.equal(lines[0][0], 'usage_visit');
  assert.equal(lines[0][1].kind, 'usage_visit');
  assert.deepEqual({...lines[0][1], kind: undefined}, {...valid(), kind: undefined});
  const text = JSON.stringify(lines);
  for (const forbidden of ['user-123456', 'a@b.co', '"uid"', 'auth', 'token', 'email']) {
    assert.ok(!text.includes(forbidden), `the log line must not contain ${forbidden}`);
  }
});

test('a rate limited visit returns dropped and logs nothing', () => {
  const lines = [];
  const options = {limiter: new RateLimiter(), log: (...args) => lines.push(args), now: 5};
  for (let i = 0; i < 30; i += 1) assert.deepEqual(processUsageVisit(authed, valid(), options), {ok: true});
  assert.deepEqual(processUsageVisit(authed, valid(), options), {ok: true, dropped: true});
  assert.equal(lines.length, 30);
});

test('a request without auth is refused and logs nothing', () => {
  const lines = [];
  assert.throws(
    () => processUsageVisit(undefined, valid(), {limiter: new RateLimiter(), log: (...args) => lines.push(args), now: 1}),
    (error) => error.code === 'unauthenticated',
  );
  assert.equal(lines.length, 0);
});

test('an invalid visit is refused before it is logged or counted', () => {
  const lines = [];
  const limiter = new RateLimiter();
  assert.throws(
    () => processUsageVisit(authed, {...valid(), uid: 'x'}, {limiter, log: (...args) => lines.push(args), now: 1}),
    (error) => error.code === 'invalid-argument',
  );
  assert.equal(lines.length, 0);
  assert.equal(limiter.size, 0);
});

test('the callable is deployed in asia-southeast1', () => {
  const endpoint = reportUsageVisit.__endpoint;
  assert.ok(endpoint.callableTrigger);
  assert.deepEqual(endpoint.region, ['asia-southeast1']);
});
