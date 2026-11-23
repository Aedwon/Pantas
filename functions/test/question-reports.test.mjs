import assert from 'node:assert/strict';
import test from 'node:test';
import {
  MAX_REPORT_MESSAGE, MAX_PER_QUESTION, MAX_PER_DAY, MAX_REQUEST_BYTES,
  validateQuestionReport, storeQuestionReport, reportDocId, questionCounterId,
} from '../lib/questionReports.js';
import {RateLimiter} from '../lib/clientTelemetry.js';

const valid = () => ({
  reportId: 'a1b2c3d4-e5f6-4789-9abc-def012345678', accountId: 'u1', questionId: 'cse-math-0001',
  questionVersion: 3, examId: 'cse-pro', message: 'Two answers look right.', build: '1293236267',
});
const refuses = (mutate) => {
  const data = valid();
  mutate(data);
  assert.throws(() => validateQuestionReport(data), (e) => e.code === 'invalid-argument');
};

test('a full report is accepted and returned as a clean, trimmed copy', () => {
  const input = {...valid(), message: ' Two answers look right. '};
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

test('the account the report was made under is required, 1 to 128 characters', () => {
  for (const bad of [undefined, '', 'u'.repeat(129), 5, null]) refuses((d) => { d.accountId = bad; });
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
});

test('the raw message is bounded before trimming, so padding cannot hide size', () => {
  refuses((d) => { d.message = `${' '.repeat(5000)}short${' '.repeat(5000)}`; });
  refuses((d) => { d.message = ` ${'m'.repeat(MAX_REPORT_MESSAGE)}`; });
});

test('the whole request is bounded in bytes', () => {
  assert.ok(MAX_REQUEST_BYTES <= 8192);
  refuses((d) => { d.questionId = 'q'; d.extraPadding = 'x'.repeat(MAX_REQUEST_BYTES); });
  refuses((d) => { d.message = 'é'.repeat(MAX_REPORT_MESSAGE); d.examId = 'e'.repeat(64); d.build = 'b'.repeat(40);
    d.reportId = 'r'.repeat(64); d.questionId = 'q'.repeat(128); d.accountId = 'u'.repeat(128); d.pad = 'x'.repeat(8000); });
});

test('build is 1 to 40 safe characters', () => {
  for (const bad of ['', 'a'.repeat(41), 'has space', 5, undefined]) refuses((d) => { d.build = bad; });
});

test('stored keys cannot collide: the uid and the id are encoded apart', () => {
  assert.notEqual(reportDocId('a_b', 'c-id-0000000000001'), reportDocId('a', 'b_c-id-0000000000001'));
  assert.notEqual(reportDocId('a', 'b'), reportDocId('a_', 'b'));
  assert.match(reportDocId('u_1', 'abc'), /^[A-Za-z0-9_-]+\.abc$/);
});

test('question counter ids are encoded, so __proto__ and constructor are plain ids', () => {
  const ids = ['__proto__', 'constructor', 'toString', 'a.b', 'a-b', 'A', 'a'].map(questionCounterId);
  assert.equal(new Set(ids).size, ids.length);
  for (const id of ids) assert.match(id, /^q[A-Za-z0-9_-]+$/);
});

// A transactional double that counts reads and writes and orders them like Firestore.
function fixture(at = Date.parse('2026-11-23T12:00:00+08:00')) {
  const rows = new Map();
  const log = {reads: 0, writes: 0};
  const doc = (path) => ({path, id: path.split('/').at(-1)});
  const snap = (ref) => ({ref, exists: rows.has(ref.path), data: () => rows.get(ref.path), get: (k) => rows.get(ref.path)?.[k]});
  const db = {doc, runTransaction: async (fn) => {
    const pending = [];
    const read = (ref) => { assert.equal(pending.length, 0, 'reads must precede writes'); log.reads++; return snap(ref); };
    const tx = {
      get: async (ref) => read(ref),
      getAll: async (...refs) => refs.map(read),
      set: (ref, value) => { pending.push(() => rows.set(ref.path, value)); },
    };
    const result = await fn(tx);
    pending.forEach((write) => { log.writes++; write(); });
    return result;
  }};
  const state = {at};
  return {db, rows, log, state, deps: (extra = {}) => ({db, now: () => state.at, limiter: new RateLimiter(1000), ...extra})};
}
const request = (data, uid = 'u1', accountId = uid) => ({auth: {uid}, app: {appId: 'test'}, data: {...data, accountId}});

test('a new report stores the fields and costs 5 reads and 3 writes', async () => {
  const f = fixture();
  const result = await storeQuestionReport(request(valid()), f.deps());
  assert.deepEqual(result, {ok: true, reportId: valid().reportId});
  const stored = f.rows.get(`questionReports/${reportDocId('u1', valid().reportId)}`);
  assert.equal(stored.accountId, 'u1');
  assert.equal(stored.questionId, 'cse-math-0001');
  assert.equal(stored.questionVersion, 3);
  assert.equal(stored.examId, 'cse-pro');
  assert.equal(stored.message, 'Two answers look right.');
  assert.equal(stored.build, '1293236267');
  assert.equal(stored.createdAt.toMillis(), f.state.at);
  assert.deepEqual(f.log, {reads: 5, writes: 3});
});

test('a retry of the same report costs 3 reads, no writes, and counts nothing', async () => {
  const f = fixture();
  await storeQuestionReport(request(valid()), f.deps());
  f.log.reads = 0; f.log.writes = 0;
  assert.deepEqual(await storeQuestionReport(request(valid()), f.deps()), {ok: true, reportId: valid().reportId});
  assert.deepEqual(f.log, {reads: 3, writes: 0});
  assert.equal(f.rows.get(`users/u1/questionReportCounts/${questionCounterId('cse-math-0001')}`).count, 1);
});

test('the same report id with different content is refused, not acknowledged', async () => {
  const f = fixture();
  await storeQuestionReport(request(valid()), f.deps());
  for (const change of [{message: 'changed'}, {questionId: 'other'}, {examId: 'cse-sub'}, {questionVersion: 9}]) {
    await assert.rejects(storeQuestionReport(request({...valid(), ...change}), f.deps()),
      (e) => e.code === 'already-exists' && e.details?.reason === 'report-id-reused');
  }
  assert.equal(f.rows.get(`questionReports/${reportDocId('u1', valid().reportId)}`).message, 'Two answers look right.');
});

test('the fourth report for one question is refused with a reason, other questions still work', async () => {
  const f = fixture();
  for (let i = 0; i < 3; i++) await storeQuestionReport(request({...valid(), reportId: `report-id-number-${i}`}), f.deps());
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-9'}), f.deps()),
    (e) => e.code === 'resource-exhausted' && e.details?.reason === 'question-limit');
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-8', questionId: 'other'}), f.deps());
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-7'}, 'u2'), f.deps());
});

test('the limits equal the app\'s', () => {
  assert.equal(MAX_PER_QUESTION, 3);
  assert.equal(MAX_PER_DAY, 20);
});

test('question ids that match inherited object properties are counted like any other', async () => {
  const f = fixture();
  for (const questionId of ['__proto__', 'constructor', 'toString', 'hasOwnProperty']) {
    for (let i = 0; i < 3; i++) {
      await storeQuestionReport(request({...valid(), questionId, reportId: `${questionId}-report-${i}-padding`}), f.deps());
    }
    await assert.rejects(storeQuestionReport(request({...valid(), questionId, reportId: `${questionId}-report-9-padding`}), f.deps()),
      (e) => e.details?.reason === 'question-limit', questionId);
  }
});

test('counters stay one small document per question, never one growing document', async () => {
  const f = fixture();
  for (let i = 0; i < 10; i++) await storeQuestionReport(request({...valid(), questionId: `q${i}`, reportId: `report-id-number-${i}`}), f.deps());
  const counters = [...f.rows.keys()].filter((k) => k.startsWith('users/u1/questionReportCounts/'));
  assert.equal(counters.length, 10);
  for (const key of counters) assert.deepEqual(Object.keys(f.rows.get(key)), ['count']);
  assert.deepEqual(Object.keys(f.rows.get('users/u1/server/questionReportDay')).sort(), ['count', 'day']);
});

test('the 21st report in one Manila day is refused, and the next day works', async () => {
  const f = fixture(Date.parse('2026-11-23T23:30:00+08:00'));
  for (let i = 0; i < 20; i++) await storeQuestionReport(request({...valid(), reportId: `report-id-number-${i}`, questionId: `q${i}`}), f.deps());
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-x', questionId: 'qx'}), f.deps()),
    (e) => e.code === 'resource-exhausted' && e.details?.reason === 'daily-limit');
  f.state.at = Date.parse('2026-11-24T00:05:00+08:00');
  await storeQuestionReport(request({...valid(), reportId: 'report-id-number-y', questionId: 'qx'}), f.deps());
});

test('a rejected request reads nothing: bad input, wrong account, signed out, over the burst limit', async () => {
  const f = fixture();
  await assert.rejects(storeQuestionReport({auth: undefined, data: valid()}, f.deps()), (e) => e.code === 'unauthenticated');
  await assert.rejects(storeQuestionReport(request({...valid(), message: ''}), f.deps()), (e) => e.code === 'invalid-argument');
  await assert.rejects(storeQuestionReport(request({...valid(), message: ' '.repeat(5000)}), f.deps()), (e) => e.code === 'invalid-argument');
  await assert.rejects(storeQuestionReport(request(valid(), 'u1', 'u2'), f.deps()),
    (e) => e.code === 'failed-precondition' && e.details?.reason === 'wrong-account');
  const limiter = new RateLimiter(1);
  await storeQuestionReport(request(valid()), f.deps({limiter}));
  const before = {...f.log};
  await assert.rejects(storeQuestionReport(request({...valid(), reportId: 'report-id-number-2'}), f.deps({limiter})),
    (e) => e.code === 'resource-exhausted');
  assert.deepEqual(f.log, before, 'the burst-limited call read nothing');
  const g = fixture();
  for (const bad of [{message: ''}, {questionId: 'a/b'}]) {
    await assert.rejects(storeQuestionReport(request({...valid(), ...bad}), g.deps()));
  }
  await assert.rejects(storeQuestionReport(request(valid(), 'u1', 'other'), g.deps()));
  assert.deepEqual(g.log, {reads: 0, writes: 0});
});

test('a closed account is refused inside the transaction, with nothing written', async () => {
  for (const mark of [
    ['accountDeletions/u1', {reason: 'user_request'}],
    ['users/u1/server/guardianConsent', {status: 'withdrawn'}],
  ]) {
    const f = fixture();
    f.rows.set(mark[0], mark[1]);
    await assert.rejects(storeQuestionReport(request(valid()), f.deps()),
      (e) => e.code === 'permission-denied' && e.details?.reason === 'account-closed');
    assert.equal([...f.rows.keys()].filter((k) => k.includes('uestionReport')).length, 0);
    assert.equal(f.log.writes, 0);
  }
});
