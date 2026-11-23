import assert from 'node:assert/strict';
import test from 'node:test';
import {FieldValue} from 'firebase-admin/firestore';
import * as guardian from '../lib/guardianConsent.js';

const DAY = 86400000;
const T0 = Date.parse('2026-11-09T00:00:00+08:00');
const versions = {privacy: '2026-11-12', terms: '2026-11-12', teens: '2026-11-12'};
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const request = (data) => ({auth: {uid: 'visitor'}, app, data});

// Runs the real consent transactions against a small document store. `reads` lists every document
// a call read (an empty query counts once), the way Firestore bills them.
function store(initial = {}) {
  const rows = new Map(Object.entries(initial));
  const reads = [];
  const dropped = value => value?.isEqual?.(FieldValue.delete()) === true;
  const merged = (path, value) => {
    const next = {...rows.get(path), ...value};
    for (const [key, field] of Object.entries(next)) if (dropped(field)) delete next[key];
    return next;
  };
  const snapshot = (ref, key) => ({ref, id: ref.id, exists: rows.has(ref.path), orderKey: key,
    data: () => rows.get(ref.path), get: field => rows.get(ref.path)?.[field]});
  const doc = path => ({path, id: path.split('/').at(-1),
    get: async () => { reads.push(path); return snapshot(doc(path)); },
    delete: async () => rows.delete(path)});
  const compare = (a, b) => {
    for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return a[i] < b[i] ? -1 : 1;
    return 0;
  };
  const query = (spec) => ({
    orderBy: field => query({...spec, order: typeof field === 'string' ? field : null}),
    limit: n => query({...spec, size: n}),
    where: (field, op, value) => query({...spec, filters: [...spec.filters, [field, op, value]]}),
    startAfter: last => query({...spec, after: last.orderKey}),
    get: async () => {
      const keyOf = path => spec.order ? [rows.get(path)?.[spec.order], path] : [path];
      const docs = [...rows.keys()].filter(path => spec.matches(path)
        && spec.filters.every(([field, op, value]) => {
          const v = rows.get(path)?.[field];
          return op === '==' ? v === value : typeof v === 'number' && v <= value;
        }))
        .map(path => ({path, key: keyOf(path)})).sort((a, b) => compare(a.key, b.key))
        .filter(item => !spec.after || compare(item.key, spec.after) > 0)
        .slice(0, spec.size).map(item => snapshot(doc(item.path), item.key));
      if (docs.length === 0) reads.push('(empty query)');
      for (const d of docs) reads.push(d.ref.path);
      return {docs, empty: docs.length === 0, size: docs.length};
    },
  });
  const make = matches => query({matches, filters: [], size: Infinity});
  let transactions = 0;
  const tx = {get: async ref => ref.path ? (reads.push(ref.path), snapshot(ref)) : ref.get(),
    set: (ref, value, options) => rows.set(ref.path, options?.merge ? merged(ref.path, value) : value),
    delete: ref => rows.delete(ref.path)};
  const db = {doc,
    collection: name => make(path => path.split('/').length === 2 && path.startsWith(`${name}/`)),
    collectionGroup: name => make(path => path.split('/').at(-2) === name),
    runTransaction: async fn => { transactions++; return fn(tx); }};
  return {db, rows, reads, transactions: () => transactions};
}
const consentPath = 'users/student/server/guardianConsent';
const evidencePath = hash => `guardianConsentEvidence/student/responses/${hash}`;
function pending() {
  const token = 'a'.repeat(64);
  const hash = guardian.hashValue('key', 'token', token);
  const s = store({[consentPath]: {status: 'pending', ageGroup: 'minor',
    tokenHash: hash, emailHash: 'email-hash', maskedEmail: 'm***@g***.com',
    sentAt: T0, expiresAt: T0 + 7 * DAY, guardianDueAt: T0 + 7 * DAY},
  [`guardianTokens/${hash}`]: {uid: 'student', state: 'open', createdAt: T0, expiresAt: T0 + 7 * DAY}});
  const deps = {db: s.db, key: 'key', now: () => T0 + DAY,
    allow: async () => true, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  return {...s, deps, token, hash};
}

for (const decision of ['confirm', 'decline']) {
  test(`${decision} records the shown versions, action and time without contact data`, async () => {
    const s = pending();
    const data = {token: s.token, decision, agreed: decision === 'confirm',
      documentVersions: versions, noticeWordingVersion: '2026-11-12'};
    await guardian.answerRequest(request(data), s.deps);
    assert.deepEqual(s.rows.get(evidencePath(s.hash)), {
      documentVersions: versions, noticeWordingVersion: '2026-11-12',
      action: decision, agreed: decision === 'confirm', decidedAt: T0 + DAY,
      ...(decision === 'confirm' ? {sharingAllowed: false} : {}),
    });
    await guardian.answerRequest(request(data), {...s.deps, now: () => T0 + 2 * DAY});
    assert.equal(s.rows.get(evidencePath(s.hash)).decidedAt, T0 + DAY, 'replay cannot replace evidence');
  });
}

test('missing or mismatched shown versions cannot create false evidence', async () => {
  for (const extra of [{}, {documentVersions: {...versions, teens: 'old'}, noticeWordingVersion: '2026-11-12'},
    {documentVersions: versions, noticeWordingVersion: 'old'}]) {
    const s = pending();
    await assert.rejects(guardian.answerRequest(request({token: s.token, decision: 'decline', ...extra}), s.deps),
      error => error.code === 'failed-precondition');
    assert.equal(s.rows.get(consentPath).status, 'pending');
    assert.equal(s.rows.has(evidencePath(s.hash)), false);
  }
});

test('unanswered request and link disappear at the seven-day boundary', async () => {
  const s = pending();
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY - 1);
  assert.ok(s.rows.has(consentPath));
  assert.ok(s.rows.has(`guardianTokens/${s.hash}`));
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.has(consentPath), false, 'the whole request goes, not only its contact data');
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
});

test('confirm removes contact and the used link seven days later but retains evidence', async () => {
  const s = pending();
  await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), s.deps);
  assert.equal(s.rows.get(consentPath).guardianDueAt, T0 + 8 * DAY, 'the cleanup is due seven days after the answer');
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY - 1);
  assert.ok(s.rows.has(`guardianTokens/${s.hash}`));
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
  assert.ok(s.rows.has(evidencePath(s.hash)));
  assert.deepEqual(s.rows.get(consentPath), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0 + DAY, sharingAllowed: false});
});

/** Every stored row (path or body) that names the account. */
const namingStudent = rows => [...rows].filter(([path, body]) =>
  path.includes('student') || JSON.stringify(body).includes('student')).map(([path]) => path);

/** A request sent through the real send, then replaced once, so there is a revoked link and two manage links. */
async function sentTwice() {
  const s = store();
  const deps = {db: s.db, key: 'key', now: () => T0, allow: async () => true,
    mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  const send = (n, now) => guardian.sendLink({auth: {uid: 'student'}, app,
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
  {...deps, now: () => now, token: () => n.repeat(64), manageToken: () => (n === 'a' ? '1' : '2').repeat(64)});
  await send('a', T0);
  await send('b', T0 + 60_000);
  return {...s, deps, token: 'b'.repeat(64), hash: guardian.hashValue('key', 'token', 'b'.repeat(64))};
}

test('a decline deletes the request in the same write that records the answer', async () => {
  const s = await sentTwice();
  const before = s.transactions();
  const result = await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => T0 + DAY});
  assert.deepEqual(result, {state: 'declined'});
  assert.equal(s.transactions() - before, 1, 'one write records the answer and deletes the request');
  assert.equal(s.rows.has(consentPath), false, 'no seven-day wait');
  assert.equal(s.rows.get(evidencePath(s.hash)).action, 'decline', 'the decline stays as evidence');
  const status = await guardian.getStatus({auth: {uid: 'student'}, app, data: {}}, {...s.deps, now: () => T0 + DAY});
  assert.equal(status.status, 'none');
});

test('after a decline the only record that links the account to a guardian request is the decline answer', async () => {
  const s = await sentTwice();
  assert.ok(namingStudent(s.rows).length >= 5, 'the setup has consent, two answer links and two manage links');
  await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => T0 + DAY});
  assert.deepEqual(namingStudent(s.rows), [evidencePath(s.hash)]);
  // The used and revoked answer links stay for their seven days, without the account.
  assert.equal(s.rows.get(`guardianTokens/${s.hash}`).state, 'used');
  assert.equal(s.rows.get(`guardianTokens/${s.hash}`).uid, undefined);
  assert.equal([...s.rows.keys()].filter(path => path.startsWith('guardianTokens/')).length, 2);
  const replay = await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => T0 + DAY});
  assert.deepEqual(replay, {state: 'used'}, 'the used link still reads as used');
});

test('after an expiry nothing links the account to a guardian request', async () => {
  const s = await sentTwice();
  // A link revoked late enough to outlive the request, as a legacy row can.
  s.rows.set('guardianTokens/late', {uid: 'student', state: 'revoked', revokedAt: T0 + 6 * DAY, createdAt: T0});
  s.rows.set('guardianTokens/open', {uid: 'student', state: 'open', createdAt: T0, expiresAt: T0 + 30 * DAY});
  await guardian.purgeGuardianRecords(s.db, T0 + 60_000 + 7 * DAY);
  assert.equal(s.rows.has(consentPath), false);
  assert.deepEqual(namingStudent(s.rows), []);
  assert.ok(s.rows.has('guardianTokens/late'), 'the link keeps its own seven days, without the account');
  assert.equal(s.rows.has('guardianTokens/open'), false, 'a still-open link to a deleted request is removed');
});

test('a confirmed guardian keeps the manage links when the cleanup trims the record', async () => {
  const s = store({[consentPath]: {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true,
    emailHash: 'e', maskedEmail: 'm', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY, guardianDueAt: T0 + 7 * DAY},
  'guardianTokens/manage': {kind: 'manage', uid: 'student', state: 'open', createdAt: T0}});
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.ok(s.rows.has('guardianTokens/manage'));
  assert.equal(s.rows.get(consentPath).status, 'confirmed');
});

test('a send records when the cleanup is due, and a resend moves it', async () => {
  const s = await sentTwice();
  assert.equal(s.rows.get(consentPath).guardianDueAt, T0 + 60_000 + 7 * DAY);
  assert.equal(s.rows.get(consentPath).guardianDueAt, s.rows.get(consentPath).expiresAt);
});

test('the hourly cleanup reads no account that has no due guardian record', async () => {
  const initial = {};
  for (let i = 0; i < 300; i++) {
    initial[`users/u${i}/server/entitlement`] = {updatedAt: T0};
    initial[`users/u${i}/server/other`] = {expiresAt: T0};
  }
  // One account with an open request that is not due yet.
  initial[consentPath] = {status: 'pending', ageGroup: 'minor', expiresAt: T0 + 7 * DAY, guardianDueAt: T0 + 7 * DAY};
  const s = store(initial);
  await guardian.purgeGuardianRecords(s.db, T0 + DAY);
  assert.deepEqual(s.reads.filter(path => path.startsWith('users/')), [], 'no account document was read');
  const serverReads = s.reads.filter(path => path === '(empty query)');
  assert.ok(serverReads.length >= 1);
  assert.ok(s.reads.length <= 4, `reads per run with nothing due: ${s.reads.length}`);
});

test('the cleanup reads only the due guardian records, whatever else the accounts hold', async () => {
  const initial = {};
  for (let i = 0; i < 100; i++) initial[`users/u${i}/server/entitlement`] = {updatedAt: T0};
  initial['users/due/server/guardianConsent'] = {status: 'pending', ageGroup: 'minor', expiresAt: T0, guardianDueAt: T0};
  initial['users/later/server/guardianConsent'] = {status: 'pending', ageGroup: 'minor', expiresAt: T0 + 3 * DAY, guardianDueAt: T0 + 3 * DAY};
  const s = store(initial);
  await guardian.purgeGuardianRecords(s.db, T0 + DAY);
  assert.equal(s.rows.has('users/due/server/guardianConsent'), false);
  assert.ok(s.rows.has('users/later/server/guardianConsent'));
  assert.ok(!s.reads.includes('users/later/server/guardianConsent'), 'a record that is not due costs no read');
  assert.ok(s.reads.filter(path => path.startsWith('users/')).every(path => path === 'users/due/server/guardianConsent'));
});

test('the cleanup pages through more than one batch of due records', async () => {
  const initial = {};
  for (let i = 0; i < 405; i++) {
    initial[`users/p${String(i).padStart(3, '0')}/server/guardianConsent`] = {status: 'pending', ageGroup: 'minor',
      expiresAt: T0 + i, guardianDueAt: T0 + i};
  }
  const s = store(initial);
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.size, 0);
});

test('replacement cleanup preserves later requests and the original replacement deadline', async () => {
  const s = pending();
  const send = (token, now) => guardian.sendLink({auth: {uid: 'student'}, app,
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
  {...s.deps, token: () => token.repeat(64), now: () => now});
  await send('b', T0 + DAY);
  await send('c', T0 + 2 * DAY);
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY - 1);
  assert.ok(s.rows.has(`guardianTokens/${s.hash}`));
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
  assert.ok(s.rows.has(consentPath));
  assert.equal(s.rows.get(consentPath).status, 'pending');
  const hashB = guardian.hashValue('key', 'token', 'b'.repeat(64));
  assert.ok(s.rows.has(`guardianTokens/${hashB}`));
  const hashC = guardian.hashValue('key', 'token', 'c'.repeat(64));
  assert.ok(s.rows.has(`guardianTokens/${hashC}`));
});

test('legacy replaced links and expired contact counters are removed without deleting other server data', async () => {
  const s = store({
    'guardianTokens/old': {uid: 'student', state: 'revoked', createdAt: T0, expiresAt: T0 + 7 * DAY},
    'guardianTokens/new': {uid: 'student', state: 'open', expiresAt: T0 + 20 * DAY},
    'guardianLimits/email': {windowStartedAt: T0, count: 1},
    'guardianLimits/global-2026-11-09': {count: 1},
    'users/student/server/other': {expiresAt: T0},
  });
  await guardian.purgeGuardianRecords(s.db, T0 + 14 * DAY);
  assert.equal(s.rows.has('guardianTokens/old'), false);
  assert.equal(s.rows.has('guardianLimits/email'), false);
  assert.equal(s.rows.has('guardianLimits/global-2026-11-09'), false);
  assert.ok(s.rows.has('guardianTokens/new'));
  assert.ok(s.rows.has('users/student/server/other'));
});

test('cleanup pages through more than one batch and is safe to repeat', async () => {
  const initial = Object.fromEntries(Array.from({length: 405}, (_, i) => [
    `guardianTokens/${String(i).padStart(4, '0')}`, {state: 'open', expiresAt: T0},
  ]));
  const s = store(initial);
  await guardian.purgeGuardianRecords(s.db, T0);
  assert.equal(s.rows.size, 0);
  await guardian.purgeGuardianRecords(s.db, T0);
  assert.equal(s.rows.size, 0);
});

test('the contact-linked send counter expires with the unanswered request', async () => {
  const s = store();
  const emailHash = guardian.hashValue('key', 'email', 'maria@gmail.com');
  const deps = {db: s.db, key: 'key', now: () => T0, token: () => 'a'.repeat(64),
    allow: async () => true, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  await guardian.sendLink({auth: {uid: 'student'}, app,
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}}, deps);
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY - 1);
  assert.ok(s.rows.has(`guardianLimits/${emailHash}`));
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.has(`guardianLimits/${emailHash}`), false);
  assert.equal(s.rows.has(consentPath), false, 'the whole request goes with its counter');
});

test('a declined request left by the old code is deleted, and the status reads as none', async () => {
  const s = store({[consentPath]: {status: 'declined', ageGroup: 'minor', decidedAt: T0,
    emailHash: 'e', maskedEmail: 'm***@g***.com', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY,
    guardianDueAt: T0 + 7 * DAY}});
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.has(consentPath), false);
  const status = await guardian.getStatus({auth: {uid: 'student'}, app, data: {}},
    {db: s.db, key: 'key', now: () => T0 + 30 * DAY, allow: async () => true,
      mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'});
  assert.equal(status.status, 'none');
  assert.equal(status.ageGroup, null);
});

test('a new request written after the cleanup scan is not deleted', async () => {
  const s = pending();
  const run = s.db.runTransaction;
  let changed = false;
  s.db.runTransaction = async fn => run(tx => fn({...tx, get: async ref => {
    if (ref.path === consentPath && !changed) {
      changed = true;
      s.rows.set(consentPath, {...s.rows.get(consentPath), expiresAt: T0 + 14 * DAY});
    }
    return tx.get(ref);
  }}));
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.get(consentPath).expiresAt, T0 + 14 * DAY);
});

test('legacy email counters meet the response deadline and undated revoked links are discarded', async () => {
  const s = store({
    'guardianLimits/email': {windowStartedAt: T0, count: 1},
    'guardianTokens/revoked': {uid: 'student', state: 'revoked', expiresAt: T0 + 7 * DAY},
  });
  await guardian.purgeGuardianRecords(s.db, T0);
  assert.equal(s.rows.has('guardianTokens/revoked'), false);
  assert.ok(s.rows.has('guardianLimits/email'));
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.has('guardianLimits/email'), false);
});

test('trimming a confirmed record keeps the sharing choice, the adult mark and the notice version', async () => {
  const kept = {status: 'confirmed', ageGroup: 'adult', adultSince: T0 + 2 * DAY, decidedAt: T0,
    sharingAllowed: true, ageCheckNoticeVersion: '2026-11-09'};
  const s = store({[consentPath]: {...kept, emailHash: 'e', maskedEmail: 'm***@g***.com', tokenHash: 't',
    sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0, guardianDueAt: T0 + 7 * DAY}});
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.deepEqual(s.rows.get(consentPath), kept, 'an adult is not turned back into a minor');
  const minor = store({[consentPath]: {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true,
    emailHash: 'e', maskedEmail: 'm', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0, guardianDueAt: T0 + 7 * DAY}});
  await guardian.purgeGuardianRecords(minor.db, T0 + 8 * DAY);
  assert.deepEqual(minor.rows.get(consentPath), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true});
  await guardian.purgeGuardianRecords(minor.db, T0 + 9 * DAY);
  assert.equal(minor.rows.get(consentPath).sharingAllowed, true, 'a second pass changes nothing');
});

test('open manage links never expire and revoked ones follow the usual seven days', async () => {
  const s = store({
    'guardianTokens/open': {kind: 'manage', uid: 'student', state: 'open', createdAt: T0},
    'guardianTokens/revoked': {kind: 'manage', uid: 'student', state: 'revoked', createdAt: T0, revokedAt: T0 + DAY},
  });
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY - 1);
  assert.ok(s.rows.has('guardianTokens/revoked'));
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.equal(s.rows.has('guardianTokens/revoked'), false);
  await guardian.purgeGuardianRecords(s.db, T0 + 5000 * DAY);
  assert.ok(s.rows.has('guardianTokens/open'));
});

test('a withdrawn record is left exactly as it is, so an unfinished withdrawal can still be retried', async () => {
  const withdrawn = {status: 'withdrawn', withdrawnAt: T0 + 2 * DAY, ageGroup: 'minor', decidedAt: T0, sharingAllowed: true,
    emailHash: 'e', maskedEmail: 'm***@g***.com', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0};
  const s = store({[consentPath]: {...withdrawn}});
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.deepEqual(s.rows.get(consentPath), withdrawn);
  await guardian.purgeGuardianRecords(s.db, T0 + 400 * DAY);
  assert.deepEqual(s.rows.get(consentPath), withdrawn);
});
