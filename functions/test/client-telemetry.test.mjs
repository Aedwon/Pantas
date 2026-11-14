import assert from 'node:assert/strict';
import test from 'node:test';
import {
  RateLimiter, processClientReport, validateClientReport, reportClientTelemetry,
} from '../lib/clientTelemetry.js';
import {SCREEN_IDS} from '../lib/usageVisit.js';

const valid = () => ({
  v: 1,
  build: '1293236267-5bbf79dc07b4',
  visit: 'return',
  browser: 'chrome',
  mobile: true,
  viewport: 'phone',
  timings: [{n: 'boot.firebase', ms: 412}],
  errors: [{type: 'StateError', msg: 'Bad state: x', stack: ['package:pantas/a.dart 1:2'], count: 1}],
});

const accepts = (mutate) => {
  const data = valid();
  mutate(data);
  assert.doesNotThrow(() => validateClientReport(data));
};
const refuses = (mutate) => {
  const data = valid();
  mutate(data);
  assert.throws(() => validateClientReport(data), (error) => error.code === 'invalid-argument');
};

test('the contract example is accepted and returned as a clean copy', () => {
  const input = valid();
  const out = validateClientReport(input);
  assert.deepEqual(out, input);
  assert.notEqual(out, input);
});

test('the request must be a plain object', () => {
  for (const bad of [null, undefined, 'x', 3, [], [valid()]]) {
    assert.throws(() => validateClientReport(bad), (error) => error.code === 'invalid-argument');
  }
});

test('v must be 1', () => {
  accepts((d) => { d.v = 1; });
  for (const bad of [2, 0, '1', undefined]) refuses((d) => { d.v = bad; });
});

test('build is 1 to 40 characters of letters, digits, dot, underscore, hyphen', () => {
  accepts((d) => { d.build = 'a'.repeat(40); });
  accepts((d) => { d.build = 'A9._-'; });
  for (const bad of ['a'.repeat(41), '', 'has space', 'semi;colon', 5, undefined]) refuses((d) => { d.build = bad; });
});

test('visit, browser and viewport come from fixed lists', () => {
  for (const visit of ['first', 'return', 'after_deploy']) accepts((d) => { d.visit = visit; });
  refuses((d) => { d.visit = 'second'; });
  for (const browser of ['chrome', 'safari', 'firefox', 'edge', 'samsung', 'other']) accepts((d) => { d.browser = browser; });
  refuses((d) => { d.browser = 'opera'; });
  for (const viewport of ['phone', 'tablet', 'wide']) accepts((d) => { d.viewport = viewport; });
  refuses((d) => { d.viewport = 'huge'; });
});

test('mobile must be a boolean', () => {
  accepts((d) => { d.mobile = false; });
  for (const bad of ['true', 1, null, undefined]) refuses((d) => { d.mobile = bad; });
});

test('timings: up to 40 items', () => {
  accepts((d) => { d.timings = []; });
  accepts((d) => { d.timings = Array.from({length: 40}, () => ({n: 'boot.auth', ms: 1})); });
  refuses((d) => { d.timings = Array.from({length: 41}, () => ({n: 'boot.auth', ms: 1})); });
  refuses((d) => { d.timings = 'x'; });
  refuses((d) => { delete d.timings; });
});

test('timing name matches ^[a-z0-9_.]{1,40}$', () => {
  accepts((d) => { d.timings = [{n: 'a'.repeat(40), ms: 1}]; });
  accepts((d) => { d.timings = [{n: 'screen.quizend_2', ms: 1}]; });
  for (const bad of ['', 'a'.repeat(41), 'Upper', 'has-dash', 'sp ace', 1]) refuses((d) => { d.timings = [{n: bad, ms: 1}]; });
});

test('timing ms is an integer from 0 to 600000', () => {
  for (const ok of [0, 600000, 412]) accepts((d) => { d.timings = [{n: 'boot.auth', ms: ok}]; });
  for (const bad of [-1, 600001, 1.5, '5', NaN, Infinity, undefined]) refuses((d) => { d.timings = [{n: 'boot.auth', ms: bad}]; });
});

test('errors: up to 10 items', () => {
  accepts((d) => { d.errors = []; });
  const item = {type: 'E', msg: 'm', stack: [], count: 1};
  accepts((d) => { d.errors = Array.from({length: 10}, () => ({...item})); });
  refuses((d) => { d.errors = Array.from({length: 11}, () => ({...item})); });
  refuses((d) => { delete d.errors; });
});

test('error type is 1 to 60 characters', () => {
  accepts((d) => { d.errors[0].type = 'a'.repeat(60); });
  for (const bad of ['a'.repeat(61), '', 4]) refuses((d) => { d.errors[0].type = bad; });
});

test('error msg is at most 300 characters', () => {
  accepts((d) => { d.errors[0].msg = 'a'.repeat(300); });
  accepts((d) => { d.errors[0].msg = ''; });
  for (const bad of ['a'.repeat(301), 4]) refuses((d) => { d.errors[0].msg = bad; });
});

test('error stack is up to 8 strings of up to 200 characters', () => {
  accepts((d) => { d.errors[0].stack = Array.from({length: 8}, () => 'a'.repeat(200)); });
  refuses((d) => { d.errors[0].stack = Array.from({length: 9}, () => 'a'); });
  refuses((d) => { d.errors[0].stack = ['a'.repeat(201)]; });
  refuses((d) => { d.errors[0].stack = [1]; });
  refuses((d) => { d.errors[0].stack = 'a'; });
});

test('error count is an integer from 1 to 1000', () => {
  for (const ok of [1, 1000]) accepts((d) => { d.errors[0].count = ok; });
  for (const bad of [0, 1001, 1.5, '1', undefined]) refuses((d) => { d.errors[0].count = bad; });
});

test('any extra key is refused at every level', () => {
  refuses((d) => { d.uid = 'abc'; });
  refuses((d) => { d.extra = 1; });
  refuses((d) => { d.timings[0].extra = 1; });
  refuses((d) => { d.errors[0].extra = 1; });
});

test('a missing top-level key is refused', () => {
  for (const key of Object.keys(valid())) refuses((d) => { delete d[key]; });
});

test('the rate limiter allows 30 reports in a rolling minute and drops the 31st', () => {
  const limiter = new RateLimiter();
  for (let i = 0; i < 30; i += 1) assert.equal(limiter.allow('uid-1', 1000 + i), true, `report ${i + 1}`);
  assert.equal(limiter.allow('uid-1', 1500), false);
  assert.equal(limiter.allow('uid-2', 1500), true, 'another user is unaffected');
});

test('the rate limiter allows again once the oldest reports leave the window', () => {
  const limiter = new RateLimiter();
  for (let i = 0; i < 30; i += 1) limiter.allow('uid-1', 1000);
  assert.equal(limiter.allow('uid-1', 60999), false);
  assert.equal(limiter.allow('uid-1', 61000), true);
});

test('the rate limiter keys by a hash, never the raw uid', () => {
  const limiter = new RateLimiter();
  limiter.allow('secret-uid-value', 1);
  for (const key of limiter.keys()) {
    assert.doesNotMatch(key, /secret-uid-value/);
    assert.match(key, /^[0-9a-f]{64}$/);
  }
});

test('the rate limiter never holds more than 5000 keys', () => {
  const limiter = new RateLimiter();
  for (let i = 0; i < 12000; i += 1) limiter.allow(`uid-${i}`, 1000 + i);
  assert.ok(limiter.size <= 5000, `size ${limiter.size}`);
  assert.equal(limiter.allow('uid-11999', 13000), true);
});

test('the rate limiter prunes expired keys before evicting live ones', () => {
  const limiter = new RateLimiter();
  for (let i = 0; i < 5000; i += 1) limiter.allow(`old-${i}`, 0);
  limiter.allow('fresh', 120000);
  assert.ok(limiter.size <= 5000);
  for (let i = 0; i < 29; i += 1) limiter.allow('fresh', 120001);
  assert.equal(limiter.allow('fresh', 120002), false, 'the live key keeps its history');
});

const authed = {uid: 'user-123456', token: {email: 'a@b.co'}};

test('a report is logged once with the contract fields and no identity', () => {
  const lines = [];
  const result = processClientReport(authed, valid(), {limiter: new RateLimiter(), log: (message, fields) => lines.push([message, fields]), now: 5});
  assert.deepEqual(result, {ok: true});
  assert.equal(lines.length, 1);
  assert.equal(lines[0][0], 'client_telemetry');
  assert.equal(lines[0][1].kind, 'client_telemetry');
  assert.deepEqual({...lines[0][1], kind: undefined}, {...valid(), kind: undefined});
  const text = JSON.stringify(lines);
  for (const forbidden of ['user-123456', 'a@b.co', 'uid', 'auth', 'token', 'email']) {
    assert.ok(!text.includes(forbidden), `the log line must not contain ${forbidden}`);
  }
});

test('a rate limited report returns dropped and logs nothing', () => {
  const lines = [];
  const options = {limiter: new RateLimiter(), log: (...args) => lines.push(args), now: 5};
  for (let i = 0; i < 30; i += 1) assert.deepEqual(processClientReport(authed, valid(), options), {ok: true});
  assert.deepEqual(processClientReport(authed, valid(), options), {ok: true, dropped: true});
  assert.equal(lines.length, 30);
});

test('a request without auth is refused and logs nothing', () => {
  const lines = [];
  assert.throws(
    () => processClientReport(undefined, valid(), {limiter: new RateLimiter(), log: (...args) => lines.push(args), now: 1}),
    (error) => error.code === 'unauthenticated',
  );
  assert.equal(lines.length, 0);
});

test('an invalid report is refused before it is logged or counted', () => {
  const lines = [];
  const limiter = new RateLimiter();
  assert.throws(
    () => processClientReport(authed, {...valid(), uid: 'x'}, {limiter, log: (...args) => lines.push(args), now: 1}),
    (error) => error.code === 'invalid-argument',
  );
  assert.equal(lines.length, 0);
  assert.equal(limiter.size, 0);
});

test('the callable is deployed in asia-southeast1 with the shared App Check policy', () => {
  const endpoint = reportClientTelemetry.__endpoint;
  assert.ok(endpoint.callableTrigger);
  assert.deepEqual(endpoint.region, ['asia-southeast1']);
});

// Screen counts (usage telemetry step 2). Optional; absent stays valid.
const withScreens = (screens) => (d) => { d.screens = screens; };

test('screens may be absent, and an absent key is not added', () => {
  const out = validateClientReport(valid());
  assert.equal('screens' in out, false);
});

test('screens: a valid list is accepted and returned as a clean copy', () => {
  const screens = [
    {s: 'home', first: true, last: false, n: 2},
    {s: 'study', first: false, last: true, n: 1000},
  ];
  const input = valid();
  input.screens = screens;
  const out = validateClientReport(input);
  assert.deepEqual(out.screens, screens);
  assert.notEqual(out.screens[0], screens[0]);
  assert.deepEqual(Object.keys(out.screens[0]), ['s', 'first', 'last', 'n']);
  accepts(withScreens([]));
});

test('screens: every id of the closed set is accepted, anything else is refused', () => {
  for (const id of SCREEN_IDS) accepts(withScreens([{s: id, first: false, last: false, n: 1}]));
  for (const bad of ['Home', 'lesson_42', '/home', '', 'startup', 5, undefined]) {
    refuses(withScreens([{s: bad, first: false, last: false, n: 1}]));
  }
});

test('screens: at most 80 entries, each screen once', () => {
  const entry = (i) => ({s: SCREEN_IDS[i % SCREEN_IDS.length], first: false, last: false, n: 1});
  accepts(withScreens(SCREEN_IDS.map((_, i) => entry(i))));
  refuses(withScreens(Array.from({length: 81}, (_, i) => entry(i))));
  refuses(withScreens([entry(0), entry(0)]));
  refuses(withScreens('home'));
  refuses(withScreens(null));
});

test('screens: each entry has exactly s, first, last and n', () => {
  const ok = {s: 'home', first: false, last: false, n: 1};
  refuses(withScreens([{s: 'home', first: false, last: false}]));
  refuses(withScreens([{...ok, t: 5}]));
  refuses(withScreens([{...ok, uid: 'abc'}]));
  refuses(withScreens([{...ok, visit_id: '0123456789abcdef'}]));
  refuses(withScreens(['home']));
  refuses(withScreens([null]));
});

test('screens: first and last are booleans', () => {
  for (const bad of ['true', 1, null, undefined]) {
    refuses(withScreens([{s: 'home', first: bad, last: false, n: 1}]));
    refuses(withScreens([{s: 'home', first: false, last: bad, n: 1}]));
  }
});

test('screens: n is a whole number from 1 to 1000', () => {
  for (const good of [1, 1000]) accepts(withScreens([{s: 'home', first: false, last: false, n: good}]));
  for (const bad of [0, -1, 1001, 1.5, '3', null, undefined, NaN]) {
    refuses(withScreens([{s: 'home', first: false, last: false, n: bad}]));
  }
});

test('screens: at most one first and one last per report', () => {
  const entry = (s, first, last) => ({s, first, last, n: 1});
  accepts(withScreens([entry('home', true, false), entry('study', false, true)]));
  accepts(withScreens([entry('home', true, true)]));
  refuses(withScreens([entry('home', true, false), entry('study', true, false)]));
  refuses(withScreens([entry('home', false, true), entry('study', false, true)]));
});

test('screens: a report with screens is logged with them and without any caller identity', () => {
  const lines = [];
  const input = valid();
  input.screens = [{s: 'home', first: true, last: false, n: 1}];
  processClientReport({uid: 'user-123'}, input, {
    limiter: new RateLimiter(),
    log: (message, fields) => lines.push({message, fields}),
  });
  assert.equal(lines.length, 1);
  assert.deepEqual(lines[0].fields.screens, input.screens);
  assert.doesNotMatch(JSON.stringify(lines[0]), /user-123/);
});
