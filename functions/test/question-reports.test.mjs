import assert from 'node:assert/strict';
import test from 'node:test';
import {
  MAX_REPORT_MESSAGE, MAX_PER_QUESTION, MAX_PER_DAY, validateQuestionReport, storeQuestionReport,
} from '../lib/questionReports.js';
import {RateLimiter} from '../lib/clientTelemetry.js';

const valid = () => ({
  reportId: 'a1b2c3d4-e5f6-4789-9abc-def012345678', questionId: 'cse-math-0001', questionVersion: 3,
  examId: 'cse-pro', message: 'Two answers look right.', build: '1293236267',
});
const refuses = (mutate) => {
  const data = valid();
  mutate(data);
  assert.throws(() => validateQuestionReport(data), (e) => e.code === 'invalid-argument');
};

test('a full report is accepted and returned as a clean, trimmed copy', () => {
  const input = {...valid(), message: '  Two answers look right.  '};
  const out = validateQuestionReport(input);
  assert.deepEqual(out, valid());
  assert.notEqual(out, input);
});

test('the request must be a plain object with known keys only', () => {
  for (const bad of [null, undefined, 'x', 3, [], [valid()]]) {
    assert.throws(() => validateQuestionReport(bad), (e) => e.code === 'invalid-argument');
  }
  refuses((d) => { d.extra = 1; });
});

test('a report from before this change may leave out version and exam', () => {
  const {questionVersion, examId, ...old} = valid();
  assert.deepEqual(validateQuestionReport(old), {...old, questionVersion: null, examId: null});
});

test('report id is 16 to 64 letters, digits, hyphen or underscore', () => {
  for (const bad of ['short', 'a'.repeat(65), 'has space!!!!!!!!!!!!', '', 5, undefined]) refuses((d) => { d.reportId = bad; });
  assert.doesNotThrow(() => validateQuestionReport({...valid(), reportId: 'A'.repeat(20)}));
});

test('question id follows the content id pattern and 128 characters', () => {
  for (const bad of ['', 'a/b', 'a b', 'q'.repeat(129), 5, undefined, 'é']) refuses((d) => { d.questionId = bad; });
  assert.doesNotThrow(() => validateQuestionReport({...valid(), questionId: 'q.1_a-B'.padEnd(128, 'x')}));
});

test('question version is a positive safe integer', () => {
  for (const bad of [0, -1, 1.5, '3', Number.MAX_SAFE_INTEGER + 1, null]) refuses((d) => { d.questionVersion = bad; });
});

test('exam id follows the id pattern and 64 characters', () => {
  for (const bad of ['', 'a/b', 'e'.repeat(65), 5, null]) refuses((d) => { d.examId = bad; });
});

test('message is 1 to the client maximum after trimming', () => {
  assert.equal(MAX_REPORT_MESSAGE, 1000);
  for (const bad of ['', '   ', 'm'.repeat(MAX_REPORT_MESSAGE + 1), 5, undefined]) refuses((d) => { d.message = bad; });
  assert.doesNotThrow(() => validateQuestionReport({...valid(), message: 'm'.repeat(MAX_REPORT_MESSAGE)}));
  assert.doesNotThrow(() => validateQuestionReport({...valid(), message: ` ${'m'.repeat(MAX_REPORT_MESSAGE)} `}));
});

test('build is 1 to 40 safe characters', () => {
  for (const bad of ['', 'a'.repeat(41), 'has space', 5, undefined]) refuses((d) => { d.build = bad; });
});

// A small transactional double: reads must precede writes, like Firestore.
function fixture(at = Date.parse('2026-11-23T12:00:00+08:00')) {
  const rows = new Map();
  const log = {reads: 0, writes: 0};
  const doc = (path) => ({path, id: path.split('/').at(-1)});
  const snap = (ref) => ({exists: rows.has(ref.path), data: () => rows.get(ref.path), get: (k) => rows.get(ref.path)?.[k]});
  const db = {doc, runTransaction: async (fn) => {
    const pending = [];
    const tx = {
      get: async (ref) => { assert.equal(pending.length, 0, 'reads must precede writes'); log.reads++; return snap(ref); },
      set: (ref, value) => { pending.push(() => rows.set(ref.path, value)); },
    };
    const result = await fn(tx);
    pending.forEach((write) => { log.writes++; write(); });
    return result;
  }};
  const state = {at};
  return {db, rows, log, state, deps: () => ({db, now: () => state.at, limiter: new RateLimiter(1000)})};
}
const request = (data, uid = 'u1') => ({auth: {uid}, app: {appId: 'test'}, data});

test('a new report stores the fields and costs 2 reads and 2 writes', async () => {
  const f = fixture();
  const result = await storeQuestionReport(request(valid()), f.deps());
  assert.deepEqual(result, {ok: true, reportId: valid().reportId});
  const stored = f.rows.get(`questionReports/u1_${valid().reportId}`);
  assert.equal(stored.accountId, 'u1');
  assert.equal(stored.questionId, 'cse-math-0001');
  assert.equal(stored.questionVersion, 3);
  assert.equal(stored.examId, 'cse-pro');
  assert.equal(stored.message, 'Two answers look right.');
  assert.equal(stored.build, '1293236267');
  assert.equal(stored.createdAt.toMillis(), f.state.at);
  assert.deepEqual(f.log, {reads: 2, writes: 2});
});

test('a retry of the same report id stores nothing new and counts nothing', async () => {
  const f = fixture();
  await storeQuestionReport(request(valid()), f.deps());
  const again = await storeQuestionReport(request({...valid(), message: 'changed'}), f.deps());
  assert.deepEqual(again, {ok: true, reportId: valid().reportId});
  assert.equal([...f.rows.keys()].filter((k) => k.startsWith('questionReports/')).length, 1);
  assert.equal(f.rows.get(`questionReports/u1_${valid().reportId}`).message, 'Two answers look right.');
  assert.equal(f.rows.get('users/u1/server/questionReportCounts').perQuestion['cse-math-0001'], 1);
});

test('the limits equal the app\'s', () => {
  assert.equal(MAX_PER_QUESTION, 3);
  assert.equal(MAX_PER_DAY, 20);
});

test('the fourth report for one question is refused with a reason, other questions still work', async () => {
  const f = fixture();
  for (let i = 0; i < 3; i++) await storeQuestionReport(request({...valid(), reportId: `report-id-number-${i}`}), f.deps());
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-9'}), f.deps()),
    (e) => e.code === 'resource-exhausted' && e.details?.reason === 'question-limit');
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-8', questionId: 'other'}), f.deps());
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-7'}, 'u2'), f.deps());
});

test('the 21st report in one Manila day is refused, and the next day works', async () => {
  const f = fixture(Date.parse('2026-11-23T23:30:00+08:00'));
  for (let i = 0; i < 20; i++) await storeQuestionReport(request({...valid(), reportId: `report-id-number-${i}`, questionId: `q${i}`}), f.deps());
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-x', questionId: 'qx'}), f.deps()),
    (e) => e.code === 'resource-exhausted' && e.details?.reason === 'daily-limit');
  f.state.at = Date.parse('2026-11-24T00:05:00+08:00');
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-y', questionId: 'qx'}), f.deps());
});

test('a signed-out call is refused and an invalid one writes nothing', async () => {
  const f = fixture();
  await assert.rejects(storeQuestionReport({auth: undefined, data: valid()}, f.deps()), (e) => e.code === 'unauthenticated');
  await assert.rejects(storeQuestionReport(request({...valid(), message: ''}), f.deps()), (e) => e.code === 'invalid-argument');
  assert.equal(f.rows.size, 0);
});

test('a caller over the burst limit is refused before any read', async () => {
  const f = fixture();
  const deps = {...f.deps(), limiter: new RateLimiter(1)};
  await storeQuestionReport(request(valid()), deps);
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-2'}), deps), (e) => e.code === 'resource-exhausted');
});
