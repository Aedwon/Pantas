import assert from 'node:assert/strict';
import test from 'node:test';
import {
  buildGcloudArgs, filterEntries, formatReport, parseArguments, percentile, summarize,
} from './report.mjs';

const client = (overrides = {}) => ({
  jsonPayload: {
    kind: 'client_telemetry', v: 1, build: 'b1', visit: 'return', browser: 'chrome', mobile: true, viewport: 'phone',
    timings: [], errors: [], ...overrides,
  },
});
const server = (fn, ms, extra = {}) => ({jsonPayload: {kind: 'fn_timing', fn, ms, cold: false, outcome: 'ok', ...extra}});

test('percentile uses the nearest rank on sorted values', () => {
  const values = [50, 10, 40, 20, 30];
  assert.equal(percentile(values, 50), 30);
  assert.equal(percentile(values, 90), 50);
  assert.equal(percentile(values, 0), 10);
  assert.equal(percentile(values, 100), 50);
  assert.equal(percentile([7], 90), 7);
});

test('percentile does not change its input and returns null for no values', () => {
  const values = [3, 1, 2];
  percentile(values, 50);
  assert.deepEqual(values, [3, 1, 2]);
  assert.equal(percentile([], 50), null);
});

test('summarize reports count, p50, p90 and max per client timing name', () => {
  const entries = [
    client({timings: [{n: 'boot.auth', ms: 100}, {n: 'boot.firebase', ms: 400}]}),
    client({timings: [{n: 'boot.auth', ms: 300}]}),
    client({timings: [{n: 'boot.auth', ms: 200}]}),
  ];
  const {timings} = summarize(entries);
  assert.deepEqual(timings.find((t) => t.name === 'boot.auth'), {name: 'boot.auth', count: 3, p50: 200, p90: 300, max: 300});
  assert.deepEqual(timings.find((t) => t.name === 'boot.firebase'), {name: 'boot.firebase', count: 1, p50: 400, p90: 400, max: 400});
  assert.deepEqual(timings.map((t) => t.name), ['boot.auth', 'boot.firebase']);
});

test('summarize reports count, p50, p90, cold share and errors per function', () => {
  const entries = [
    server('getRoadmap', 100),
    server('getRoadmap', 200, {cold: true}),
    server('getRoadmap', 300, {outcome: 'error', code: 'internal'}),
    server('getRoadmap', 400),
    server('getContent', 50),
  ];
  const {functions} = summarize(entries);
  assert.deepEqual(functions.find((f) => f.fn === 'getRoadmap'), {fn: 'getRoadmap', count: 4, p50: 200, p90: 400, coldShare: 0.25, errors: 1});
  assert.deepEqual(functions.find((f) => f.fn === 'getContent'), {fn: 'getContent', count: 1, p50: 50, p90: 50, coldShare: 0, errors: 0});
});

test('summarize groups errors by type and first stack line and adds their counts', () => {
  const entries = [
    client({errors: [{type: 'StateError', msg: 'a', stack: ['package:pantas/a.dart 1:2', 'x'], count: 2}]}),
    client({errors: [{type: 'StateError', msg: 'b', stack: ['package:pantas/a.dart 1:2'], count: 3}]}),
    client({errors: [{type: 'StateError', msg: 'c', stack: ['package:pantas/b.dart 9:9'], count: 1}]}),
    client({errors: [{type: 'TypeError', msg: 'd', stack: [], count: 1}]}),
  ];
  const {errors} = summarize(entries);
  assert.deepEqual(errors[0], {type: 'StateError', frame: 'package:pantas/a.dart 1:2', count: 5, reports: 2, sample: 'a'});
  assert.equal(errors.length, 3);
  assert.deepEqual(errors.at(-1), {type: 'TypeError', frame: '', count: 1, reports: 1, sample: 'd'});
});

test('summarize counts reports and ignores other entries and malformed ones', () => {
  const summary = summarize([client(), client(), server('f', 1), {jsonPayload: {kind: 'other'}}, {}, null, {jsonPayload: {kind: 'client_telemetry'}}]);
  assert.equal(summary.reports, 3);
  assert.equal(summary.calls, 1);
});

test('summarize handles no entries', () => {
  assert.deepEqual(summarize([]), {reports: 0, calls: 0, timings: [], functions: [], errors: []});
});

test('filterEntries keeps only the wanted build and visit on client reports', () => {
  const entries = [
    client({build: 'b1', visit: 'return'}),
    client({build: 'b2', visit: 'return'}),
    client({build: 'b1', visit: 'first'}),
    server('f', 1),
  ];
  assert.equal(filterEntries(entries, {build: 'b1'}).filter((e) => e.jsonPayload.kind === 'client_telemetry').length, 2);
  assert.equal(filterEntries(entries, {visit: 'return'}).filter((e) => e.jsonPayload.kind === 'client_telemetry').length, 2);
  assert.equal(filterEntries(entries, {build: 'b1', visit: 'return'}).length, 2, 'one client report plus the server line');
  assert.equal(filterEntries(entries, {}).length, 4);
});

test('parseArguments reads the flags and applies defaults', () => {
  assert.deepEqual(parseArguments(['--project', 'pantas-prod']), {project: 'pantas-prod', hours: 24, build: undefined, visit: undefined});
  assert.deepEqual(
    parseArguments(['--project', 'pantas-prod', '--hours', '6', '--build', '1-abc', '--visit', 'return']),
    {project: 'pantas-prod', hours: 6, build: '1-abc', visit: 'return'},
  );
});

test('parseArguments refuses bad input', () => {
  for (const argv of [
    [], ['--project', 'Bad Project'], ['--project', 'pantas-prod', '--hours', '0'], ['--project', 'pantas-prod', '--hours', 'x'],
    ['--project', 'pantas-prod', '--hours', '1000'], ['--project', 'pantas-prod', '--visit', 'later'],
    ['--project', 'pantas-prod', '--build', 'a b'], ['--project', 'pantas-prod', '--nope', '1'],
  ]) {
    assert.throws(() => parseArguments(argv), /./, JSON.stringify(argv));
  }
});

test('buildGcloudArgs reads both log kinds for the project and period without a shell', () => {
  const args = buildGcloudArgs({project: 'pantas-prod', hours: 6});
  assert.deepEqual(args.slice(0, 3), ['logging', 'read', 'jsonPayload.kind=("client_telemetry" OR "fn_timing")']);
  assert.ok(args.includes('--project=pantas-prod'));
  assert.ok(args.includes('--freshness=6h'));
  assert.ok(args.includes('--format=json'));
});

test('formatReport prints a section per kind with the numbers', () => {
  const text = formatReport(summarize([
    client({timings: [{n: 'boot.auth', ms: 120}], errors: [{type: 'StateError', msg: 'Bad', stack: ['package:pantas/a.dart 1:2'], count: 2}]}),
    server('getRoadmap', 80, {cold: true}),
  ]));
  assert.match(text, /1 client reports, 1 function calls/);
  assert.match(text, /boot\.auth\s+1\s+120\s+120\s+120/);
  assert.match(text, /getRoadmap\s+1\s+80\s+80\s+100%\s+0/);
  assert.match(text, /StateError\s+2\s+1\s+package:pantas\/a\.dart 1:2/);
});

test('formatReport says so when there is no data', () => {
  assert.match(formatReport(summarize([])), /No reports/);
});
