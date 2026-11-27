import assert from 'node:assert/strict';
import test from 'node:test';
import {FieldValue} from 'firebase-admin/firestore';
import * as guardian from '../lib/guardianConsent.js';

const DAY = 86400000;
const T0 = Date.parse('2026-11-09T00:00:00+08:00');
const versions = {privacy: '2026-11-28', terms: '2026-11-28', teens: '2026-11-28'};
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
          if (op === '==') return v === value;
          if (op === 'in') return value.includes(v);
          if (op === '>') return typeof v === 'number' && v > value;
          return typeof v === 'number' && v <= value;
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
  let autoIds = 0;
  const tx = {get: async ref => ref.path ? (reads.push(ref.path), snapshot(ref)) : ref.get(),
    set: (ref, value, options) => rows.set(ref.path, options?.merge ? merged(ref.path, value) : value),
    delete: ref => rows.delete(ref.path)};
  const db = {doc,
    collection: name => ({...make(path => path.split('/').length === 2 && path.startsWith(`${name}/`)),
      doc: () => doc(`${name}/auto${++autoIds}`)}),
    collectionGroup: name => make(path => path.split('/').at(-2) === name),
    runTransaction: async fn => { transactions++; return fn(tx); }};
  return {db, rows, reads, transactions: () => transactions, rawTx: tx};
}
const consentPath = 'users/student/server/guardianConsent';
const evidencePath = hash => `guardianConsentEvidence/student/responses/${hash}`;
/** Every evidence row of the account, whatever its id. */
const evidenceRows = rows => [...rows].filter(([path]) => path.startsWith('guardianConsentEvidence/student/responses/'));
function pending() {
  const token = 'a'.repeat(64);
  const hash = guardian.hashValue('key', 'token', token);
  const s = store({[consentPath]: {status: 'pending', ageGroup: 'minor',
    tokenHash: hash, emailHash: 'email-hash', maskedEmail: 'm***@g***.com',
    sentAt: T0, expiresAt: T0 + 7 * DAY, guardianDueAt: T0 + 7 * DAY},
  [`guardianTokens/${hash}`]: {uid: 'student', state: 'open', createdAt: T0, expiresAt: T0 + 7 * DAY, cleanupAt: T0 + 7 * DAY}});
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
    assert.equal(evidenceRows(s.rows).length, 1);
    assert.deepEqual(evidenceRows(s.rows)[0][1], {
      documentVersions: versions, noticeWordingVersion: '2026-11-12',
      action: decision, agreed: decision === 'confirm', decidedAt: T0 + DAY,
      ...(decision === 'confirm' ? {sharingAllowed: false} : {}),
    });
    await guardian.answerRequest(request(data), {...s.deps, now: () => T0 + 2 * DAY});
    assert.equal(evidenceRows(s.rows).length, 1);
    assert.equal(evidenceRows(s.rows)[0][1].decidedAt, T0 + DAY, 'replay cannot replace evidence');
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
  const deps = {db: s.db, requestsOpen: true, key: 'key', now: () => T0, allow: async () => true,
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
  assert.equal(evidenceRows(s.rows)[0][1].action, 'decline', 'the decline stays as evidence');
  const status = await guardian.getStatus({auth: {uid: 'student'}, app, data: {}}, {...s.deps, now: () => T0 + DAY});
  assert.equal(status.status, 'none');
});

test('after a decline the only record that links the account to a guardian request is the decline answer', async () => {
  const s = await sentTwice();
  assert.ok(namingStudent(s.rows).length >= 5, 'the setup has consent, two answer links and two manage links');
  await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => T0 + DAY});
  assert.deepEqual(namingStudent(s.rows), evidenceRows(s.rows).map(([path]) => path));
  assert.equal(evidenceRows(s.rows).length, 1);
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
  s.rows.set('guardianTokens/late', {uid: 'student', state: 'revoked', revokedAt: T0 + 6 * DAY, createdAt: T0, cleanupAt: T0 + 13 * DAY});
  s.rows.set('guardianTokens/open', {uid: 'student', state: 'open', createdAt: T0, expiresAt: T0 + 30 * DAY, cleanupAt: T0 + 30 * DAY});
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
  {...s.deps, requestsOpen: true, token: () => token.repeat(64), now: () => now});
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
  await guardian.purgeGuardianRecords(s.db, T0 + 14 * DAY, {legacyScan: true});
  assert.equal(s.rows.has('guardianTokens/old'), false);
  assert.equal(s.rows.has('guardianLimits/email'), false);
  assert.equal(s.rows.has('guardianLimits/global-2026-11-09'), false);
  assert.ok(s.rows.has('guardianTokens/new'));
  assert.ok(s.rows.has('users/student/server/other'));
});

test('cleanup pages through more than one batch and is safe to repeat', async () => {
  const initial = Object.fromEntries(Array.from({length: 405}, (_, i) => [
    `guardianTokens/${String(i).padStart(4, '0')}`, {state: 'open', expiresAt: T0, cleanupAt: T0},
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
  const deps = {db: s.db, requestsOpen: true, key: 'key', now: () => T0, token: () => 'a'.repeat(64),
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
  await guardian.purgeGuardianRecords(s.db, T0, {legacyScan: true});
  assert.equal(s.rows.has('guardianTokens/revoked'), false);
  assert.ok(s.rows.has('guardianLimits/email'));
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY, {legacyScan: true});
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
    'guardianTokens/revoked': {kind: 'manage', uid: 'student', state: 'revoked', createdAt: T0, revokedAt: T0 + DAY, cleanupAt: T0 + 8 * DAY},
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

// ---------------------------------------------------------------- round 2

test('a resend after expiry, before the cleanup, clears the expired request\'s links in the same transaction', async () => {
  const s = await sentTwice();
  const send = (n, now) => guardian.sendLink({auth: {uid: 'student'}, app,
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
  {...s.deps, now: () => now, token: () => n.repeat(64), manageToken: () => (n === 'c' ? '3' : '4').repeat(64)});
  const later = T0 + 60_000 + 7 * DAY + 1;
  await send('c', later);
  const linkRows = [...s.rows].filter(([path]) => path.startsWith('guardianTokens/'));
  const naming = linkRows.filter(([, body]) => body.uid === 'student');
  assert.equal(naming.length, 2, 'only the replacement answer link and manage link name the account');
  assert.deepEqual(naming.map(([, body]) => body.state), ['open', 'open']);
  const oldManage = guardian.hashValue('key', 'token', '2'.repeat(64));
  assert.equal(s.rows.has(`guardianTokens/${oldManage}`), false, 'the expired request\'s page link is deleted');
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false, 'its open answer link is deleted');
  assert.equal(s.rows.get(consentPath).status, 'pending');
});

test('decline evidence has its own id, so a kept used link cannot be tied back to the account through it', async () => {
  const s = await sentTwice();
  await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => T0 + DAY});
  assert.equal(s.rows.has(evidencePath(s.hash)), false);
  assert.equal(evidenceRows(s.rows).length, 1);
  assert.ok(!evidenceRows(s.rows)[0][0].includes(s.hash));
  assert.ok(!JSON.stringify(evidenceRows(s.rows)[0][1]).includes(s.hash));
});

test('an adult mark survives the expiry and the decline of a request, and still blocks a new minor request', async () => {
  const adult = {status: 'pending', ageGroup: 'adult', adultSince: T0 + DAY, emailHash: 'e', maskedEmail: 'm', tokenHash: 't',
    sentAt: T0, createdAt: T0, expiresAt: T0 + 7 * DAY, guardianDueAt: T0 + 7 * DAY};
  const s = store({[consentPath]: adult});
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'adult', adultSince: T0 + DAY});
  const deps = {db: s.db, requestsOpen: true, key: 'key', now: () => T0 + 8 * DAY, allow: async () => true,
    mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  await assert.rejects(guardian.sendLink({auth: {uid: 'student'}, app,
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}}, deps), error => error.code === 'failed-precondition');
  const d = pending();
  d.rows.set(consentPath, {...d.rows.get(consentPath), ageGroup: 'adult', adultSince: T0 + DAY});
  await guardian.answerRequest(request({token: d.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), d.deps);
  assert.deepEqual(d.rows.get(consentPath), {ageGroup: 'adult', adultSince: T0 + DAY});
});

test('an answer that retries reads the time again, so a retry after expiry cannot confirm', async () => {
  const s = pending();
  const run = s.db.runTransaction;
  // The first attempt is thrown away, as a contended transaction is; only the retry commits.
  s.db.runTransaction = async fn => {
    await run(async tx => fn({get: ref => tx.get(ref), set() {}, delete() {}}));
    return run(fn);
  };
  let calls = 0;
  const result = await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}),
  {...s.deps, now: () => (++calls === 1 ? T0 + 7 * DAY - 1 : T0 + 7 * DAY)});
  assert.deepEqual(result, {state: 'expired'});
  assert.equal(s.rows.get(consentPath).status, 'pending');
});

test('the same fallback deadline: an undated confirmation scheduled by the script is trimmed by the cleanup', async () => {
  const undated = {status: 'confirmed', ageGroup: 'minor', sharingAllowed: true, emailHash: 'e', maskedEmail: 'm', tokenHash: 't',
    sentAt: T0, createdAt: T0, expiresAt: T0 + 7 * DAY};
  assert.equal(guardian.consentDue(undated), null, 'no answer time and no scheduled time: no deadline of its own');
  const due = T0 + 30 * DAY + 7 * DAY;
  assert.equal(guardian.consentDue({...undated, guardianDueAt: due}), due, 'the scheduled time is the deadline');
  const s = store({[consentPath]: {...undated, guardianDueAt: due}});
  await guardian.purgeGuardianRecords(s.db, due - 1);
  assert.equal(s.rows.get(consentPath).emailHash, 'e');
  await guardian.purgeGuardianRecords(s.db, due);
  assert.deepEqual(s.rows.get(consentPath), {status: 'confirmed', ageGroup: 'minor', sharingAllowed: true});
});

test('the hourly cleanup reads no token or limit row that is not due, and no manage link of a confirmed minor', async () => {
  const initial = {};
  for (let i = 0; i < 200; i++) {
    initial[`guardianTokens/manage${i}`] = {kind: 'manage', uid: `u${i}`, state: 'open', createdAt: T0};
    initial[`guardianTokens/used${i}`] = {uid: `u${i}`, state: 'used', usedAt: T0, cleanupAt: T0 + 7 * DAY};
    initial[`guardianLimits/e${i}`] = {windowStartedAt: T0, count: 1, cleanupAt: T0 + 7 * DAY};
  }
  const s = store(initial);
  const result = await guardian.purgeGuardianRecords(s.db, T0 + DAY);
  assert.deepEqual(s.reads, ['(empty query)', '(empty query)', '(empty query)'], 'three due queries and nothing else');
  assert.equal(result.undated, 0);
  s.reads.length = 0;
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.equal(s.rows.size, 200, 'only the open manage links are left');
  assert.ok(s.reads.every(path => !path.startsWith('guardianTokens/manage')));
});

test('the daily scan finds old rows with no due time, cleans them and counts them', async () => {
  const s = store({
    'guardianTokens/old': {uid: 'student', state: 'revoked', revokedAt: T0},
    'guardianLimits/email': {windowStartedAt: T0, count: 1},
    [consentPath]: {status: 'pending', ageGroup: 'minor', emailHash: 'e', expiresAt: T0 + 7 * DAY},
    'users/other/server/guardianConsent': {status: 'pending', ageGroup: 'minor', emailHash: 'e', expiresAt: T0 + 30 * DAY},
  });
  const hourly = await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.equal(s.rows.has('guardianTokens/old'), true, 'the hourly run does not look for undated rows');
  assert.equal(hourly.undated, 0);
  const daily = await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY, {legacyScan: true});
  assert.equal(daily.undated, 4, 'the old token, the old limit and both requests had no due time');
  assert.equal(s.rows.has('guardianTokens/old'), false);
  assert.equal(s.rows.has(consentPath), false);
  assert.ok(s.rows.has('users/other/server/guardianConsent'));
});

test('a send gives every link and counter row a cleanup time, and page links of an open request none', async () => {
  const s = await sentTwice();
  for (const [path, body] of s.rows) {
    if (!path.startsWith('guardianTokens/') && !path.startsWith('guardianLimits/')) continue;
    if (body.kind === 'manage' && body.state === 'open') assert.equal(body.cleanupAt, undefined, path);
    else assert.equal(typeof body.cleanupAt, 'number', path);
  }
});

test('the cleanup needs only a collection-group index on the due-time field', async () => {
  const {readFileSync} = await import('node:fs');
  const config = JSON.parse(readFileSync(new URL('../../firestore.indexes.json', import.meta.url)));
  const entry = config.fieldOverrides.find(o => o.collectionGroup === 'server' && o.fieldPath === 'guardianDueAt');
  assert.deepEqual(entry.indexes, [{order: 'ASCENDING', queryScope: 'COLLECTION_GROUP'}]);
});

// ---------------------------------------------------------------- round 3

/** Every number a retained token holds, with the field name. */
const numbersOf = body => Object.entries(body).filter(([, value]) => typeof value === 'number');

test('a retained token cannot be joined to the decline evidence by time', async () => {
  const s = await sentTwice();
  const decidedAt = T0 + DAY + 12_345;
  await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => decidedAt});
  assert.equal(evidenceRows(s.rows)[0][1].decidedAt, decidedAt, 'the evidence keeps the exact time');
  const tokens = [...s.rows].filter(([path]) => path.startsWith('guardianTokens/'));
  assert.equal(tokens.length, 2);
  for (const [path, body] of tokens) {
    assert.equal(body.usedAt, undefined, path);
    assert.equal(body.revokedAt, undefined, path);
    for (const [name, value] of numbersOf(body)) {
      assert.notEqual(value, decidedAt, `${path} ${name}`);
      assert.notEqual(value, decidedAt + guardian.GUARDIAN_WINDOW_MS, `${path} ${name}`);
      assert.notEqual(value, decidedAt - guardian.GUARDIAN_WINDOW_MS, `${path} ${name}`);
    }
  }
  // The coarse time still ends the retention: the link goes within a day of the seven days.
  const used = s.rows.get(`guardianTokens/${s.hash}`);
  assert.ok(used.cleanupAt >= decidedAt + guardian.GUARDIAN_WINDOW_MS && used.cleanupAt < decidedAt + guardian.GUARDIAN_WINDOW_MS + DAY);
  await guardian.purgeGuardianRecords(s.db, used.cleanupAt - 1);
  assert.ok(s.rows.has(`guardianTokens/${s.hash}`));
  await guardian.purgeGuardianRecords(s.db, used.cleanupAt);
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
});

test('a send counts the student under a keyed hash, and nothing under the account survives a decline', async () => {
  const s = store();
  const {allow: _ignored, ...rest} = {db: s.db, requestsOpen: true, key: 'key', now: () => T0, allow: undefined,
    mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test', token: () => 'a'.repeat(64)};
  await guardian.sendLink({auth: {uid: 'student'}, app, rawRequest: {ip: '10.0.0.1'},
    data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}}, rest);
  assert.deepEqual(namingStudent(s.rows).filter(path => path.startsWith('users/') && path.includes('/limits/')), []);
  assert.ok([...s.rows.keys()].some(path => path.startsWith('guardianLimits/acct-')), 'the per-student count is kept under a hash');
  await guardian.answerRequest(request({token: 'a'.repeat(64), decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...rest, allow: async () => true, now: () => T0 + DAY});
  assert.deepEqual(namingStudent(s.rows), evidenceRows(s.rows).map(([path]) => path));
  await guardian.purgeGuardianRecords(s.db, T0 + 3 * DAY);
  assert.deepEqual([...s.rows.keys()].filter(path => path.startsWith('guardianLimits/acct-')), [], 'the count ends with its window');
});

test('a resend whose clock crosses expiry during the transaction still clears the expired request', async () => {
  const s = await sentTwice();
  const expiry = T0 + 60_000 + 7 * DAY;
  let calls = 0;
  await guardian.sendLink({auth: {uid: 'student'}, app, data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
    {...s.deps, token: () => 'c'.repeat(64), manageToken: () => '3'.repeat(64),
      now: () => (++calls === 1 ? expiry - 1 : expiry + 1)});
  const naming = [...s.rows].filter(([path, body]) => path.startsWith('guardianTokens/') && body.uid === 'student');
  assert.equal(naming.length, 2, 'only the replacement links name the account');
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
});

test('the daily scan stops once the backfill is verified, and never reads open manage links', async () => {
  const initial = {'guardianLimits/d1-backfill-verified': {verifiedAt: T0}};
  for (let i = 0; i < 100; i++) initial[`guardianTokens/manage${i}`] = {kind: 'manage', uid: `u${i}`, state: 'open', createdAt: T0};
  const s = store(initial);
  assert.equal(await guardian.legacyScanNeeded(s.db), false);
  assert.deepEqual(s.reads, ['guardianLimits/d1-backfill-verified'], 'one read, then nothing');
  const open = store({...initial, 'guardianLimits/d1-backfill-verified': undefined});
  open.rows.delete('guardianLimits/d1-backfill-verified');
  await guardian.purgeGuardianRecords(open.db, T0 + DAY, {legacyScan: true});
  assert.ok(open.reads.every(path => !path.startsWith('guardianTokens/manage')), 'no open manage link is read');
});

/**
 * Makes transactions optimistic, as Firestore's are: a commit whose reads changed since they were made
 * runs the function again. `beforeCommit` runs once, between a transaction's reads and its commit,
 * so a test places another operation exactly there.
 */
function interleave(s, beforeCommit) {
  s.db.runTransaction = async fn => {
    for (let attempt = 0; attempt < 5; attempt++) {
      const reads = new Map();
      const writes = [];
      const view = path => JSON.stringify(s.rows.get(path) ?? null);
      const tx = {get: async ref => {
        if (ref.path) { reads.set(ref.path, view(ref.path)); return ref.get(); }
        const result = await ref.get();
        for (const d of result.docs) reads.set(d.ref.path, view(d.ref.path));
        return result;
      }, set: (ref, value, options) => writes.push(() => s.rawTx.set(ref, value, options)),
      delete: ref => writes.push(() => s.rawTx.delete(ref))};
      const result = await fn(tx);
      await beforeCommit(reads);
      if ([...reads].some(([path, seen]) => view(path) !== seen)) continue;
      for (const write of writes) write();
      return result;
    }
    throw new Error('too many attempts');
  };
}

test('an answer overtaken by the expiry cleanup is refused and leaves no half state', async () => {
  const s = await sentTwice();
  const expiry = T0 + 60_000 + 7 * DAY;
  let fired = false;
  interleave(s, async reads => {
    if (fired || !reads.has(consentPath) || !reads.has(`guardianTokens/${s.hash}`)) return;
    fired = true;
    await guardian.purgeGuardianRecords(s.db, expiry);
  });
  const result = await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => expiry - 1});
  assert.ok(fired);
  assert.notEqual(result.state, 'confirmed');
  assert.equal(s.rows.has(consentPath), false);
  assert.equal(evidenceRows(s.rows).length, 0);
  assert.deepEqual(namingStudent(s.rows), []);
});

test('an expiry cleanup overtaken by an answer leaves the confirmed record alone', async () => {
  const s = await sentTwice();
  const expiry = T0 + 60_000 + 7 * DAY;
  let fired = false;
  let result;
  interleave(s, async reads => {
    if (fired || !reads.has(`guardianTokens/${s.hash}`)) return;
    fired = true;
    result = await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
      documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...s.deps, now: () => expiry - 1});
  });
  await guardian.purgeGuardianRecords(s.db, expiry);
  assert.ok(fired);
  assert.equal(result.state, 'confirmed');
  assert.equal(s.rows.get(consentPath).status, 'confirmed');
  assert.equal(evidenceRows(s.rows).length, 1);
});

// ---------------------------------------------------------------- round 4

test('the send counter keeps only days, and a replacement request does not copy the old request\'s time', async () => {
  const s = await sentTwice();
  await guardian.sendLink({auth: {uid: 'student'}, app, data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
    {...s.deps, allow: undefined, now: () => T0 + 120_000, token: () => 'd'.repeat(64), manageToken: () => '5'.repeat(64)});
  s.rows.set(consentPath, {...s.rows.get(consentPath), createdAt: T0});
  const counters = [...s.rows].filter(([path]) => path.startsWith('guardianLimits/acct-'));
  assert.equal(counters.length, 1);
  for (const [name, value] of numbersOf(counters[0][1]).filter(([name]) => name !== 'count')) {
    assert.equal(value % DAY, 0, `counter ${name} is a whole day, not an exact moment`);
  }
  const oldCreated = s.rows.get(consentPath).createdAt;
  assert.equal(oldCreated, T0);
  const later = T0 + 120_000 + 7 * DAY + 12_345;
  await guardian.sendLink({auth: {uid: 'student'}, app, data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
    {...s.deps, now: () => later, token: () => 'c'.repeat(64), manageToken: () => '3'.repeat(64)});
  assert.equal(s.rows.get(consentPath).createdAt, later, 'the replacement uses its own time');
  const retained = [...s.rows].filter(([path, body]) => path.startsWith('guardianTokens/') && body.uid === undefined);
  assert.ok(retained.length >= 1);
  const exact = new Set([T0, T0 + 60_000, T0 + 7 * DAY, T0 + 60_000 + 7 * DAY]);
  for (const [path, body] of retained) {
    for (const [name, value] of numbersOf(body)) assert.ok(!exact.has(value), `${path} ${name} keeps an exact request time`);
  }
});

const limiterPath = 'users/student/limits/guardianSend';

test('an old account-keyed send limiter row goes with the request, on decline, expiry and a resend after expiry', async () => {
  const declined = await sentTwice();
  declined.rows.set(limiterPath, {windowStartedAt: T0, count: 2});
  await guardian.answerRequest(request({token: declined.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...declined.deps, now: () => T0 + DAY});
  assert.equal(declined.rows.has(limiterPath), false);
  const expired = await sentTwice();
  expired.rows.set(limiterPath, {windowStartedAt: T0, count: 2});
  await guardian.purgeGuardianRecords(expired.db, T0 + 60_000 + 7 * DAY);
  assert.equal(expired.rows.has(limiterPath), false);
  const resent = await sentTwice();
  resent.rows.set(limiterPath, {windowStartedAt: T0, count: 2});
  await guardian.sendLink({auth: {uid: 'student'}, app, data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}},
    {...resent.deps, now: () => T0 + 60_000 + 7 * DAY + 5, token: () => 'c'.repeat(64), manageToken: () => '3'.repeat(64)});
  assert.equal(resent.rows.has(limiterPath), false);
});

test('an answer whose clock crosses expiry between its reads is refused as expired on the first attempt', async () => {
  const s = pending();
  let calls = 0;
  const result = await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}),
  {...s.deps, now: () => (++calls === 1 ? T0 + 7 * DAY - 1 : T0 + 7 * DAY)});
  assert.deepEqual(result, {state: 'expired'});
  assert.equal(s.rows.get(consentPath).status, 'pending');
  assert.equal(evidenceRows(s.rows).length, 0);
});

// ---------------------------------------------------------------- round 5 (ruling C5)

test('the status, adult and answer limiters are kept under keyed hashes with a cleanup time, and the cleanup deletes them', async () => {
  const s = store();
  const deps = {db: s.db, requestsOpen: true, key: 'key', now: () => T0, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  await guardian.getStatus({auth: {uid: 'student'}, app, data: {}}, deps);
  await guardian.markAdult({auth: {uid: 'student'}, app, data: {}}, deps);
  await guardian.readRequest({auth: {uid: 'visitor-x'}, app, data: {token: 'a'.repeat(64)}}, deps);
  const rows = [...s.rows];
  assert.equal(rows.filter(([path]) => path.includes('/limits/')).length, 0, 'nothing is kept under the account');
  const limiters = rows.filter(([path]) => path.startsWith('guardianLimits/'));
  assert.equal(limiters.length, 3);
  for (const [path, body] of limiters) {
    assert.ok(!path.includes('student') && !path.includes('visitor-x'), path);
    assert.ok(!JSON.stringify(body).includes('student') && !JSON.stringify(body).includes('visitor-x'), path);
    assert.equal(typeof body.cleanupAt, 'number', path);
    assert.ok(body.cleanupAt <= T0 + 8 * DAY, `${path} ends within 8 days`);
  }
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.deepEqual([...s.rows.keys()].filter(path => path.startsWith('guardianLimits/')), []);
});

test('a decline whose request expired during its reads is refused as expired', async () => {
  const s = await sentTwice();
  const expiry = T0 + 60_000 + 7 * DAY;
  const manageB = `guardianTokens/${guardian.hashValue('key', 'token', '2'.repeat(64))}`;
  // The clock passes expiry only once the request's links have been read.
  const result = await guardian.answerRequest(request({token: s.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}),
  {...s.deps, now: () => (s.reads.includes(manageB) ? expiry : expiry - 1)});
  assert.deepEqual(result, {state: 'expired'});
  assert.equal(s.rows.get(consentPath).status, 'pending');
  assert.equal(evidenceRows(s.rows).length, 0);
});

test('C5 pass condition: after a decline or an expiry only the decline evidence names the account, and no kept link shares its id or time', async () => {
  const sentWithDefaults = async () => {
    const s = await sentTwice();
    return {...s, deps: {...s.deps, allow: undefined}};
  };
  const declined = await sentWithDefaults();
  const decidedAt = T0 + DAY + 4_321;
  await guardian.answerRequest(request({token: declined.token, decision: 'decline', agreed: false,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), {...declined.deps, now: () => decidedAt});
  const evidence = evidenceRows(declined.rows);
  assert.equal(evidence.length, 1);
  assert.deepEqual(namingStudent(declined.rows), [evidence[0][0]], 'only the evidence holds or sits under the account');
  assert.equal([...declined.rows.keys()].filter(path => path.startsWith('users/student/')).length, 0);
  const evidenceId = evidence[0][0].split('/').at(-1);
  for (const [path, body] of declined.rows) {
    if (!path.startsWith('guardianTokens/')) continue;
    assert.notEqual(path.split('/').at(-1), evidenceId);
    for (const [name, value] of numbersOf(body)) assert.notEqual(value, decidedAt, `${path} ${name}`);
  }
  const expired = await sentWithDefaults();
  await guardian.purgeGuardianRecords(expired.db, T0 + 60_000 + 7 * DAY);
  assert.deepEqual(namingStudent(expired.rows), []);
  assert.equal([...expired.rows.keys()].filter(path => path.startsWith('users/student/')).length, 0);
});

// Option C (Nov 25): under-18 sign-up is closed. A refused send writes and reads nothing.
test('a closed server refuses every send before it reads or writes anything', async () => {
  for (const requestsOpen of [undefined, false]) {
    const s = store();
    let allowCalls = 0;
    let mails = 0;
    const deps = {db: s.db, key: 'key', now: () => T0, requestsOpen, linkOrigin: 'https://app.example.test',
      allow: async () => { allowCalls++; return true; }, mailer: {send: async () => { mails++; }}};
    await assert.rejects(guardian.sendLink({auth: {uid: 'student'}, app, rawRequest: {ip: '10.0.0.1'},
      data: {guardianName: 'Maria', guardianEmail: 'maria@gmail.com'}}, deps), error => {
      assert.equal(error.code, 'failed-precondition');
      assert.deepEqual(error.details, {reason: 'minor-signup-closed'});
      return true;
    });
    assert.equal(s.rows.size, 0, 'no consent, token, limiter or counter row');
    assert.deepEqual(s.reads, []);
    assert.equal(s.transactions(), 0);
    assert.equal(allowCalls, 0);
    assert.equal(mails, 0);
  }
});

test('a closed server still answers a request that is already open', async () => {
  const s = pending();
  assert.equal(s.deps.requestsOpen, undefined);
  await guardian.answerRequest(request({token: s.token, decision: 'confirm', agreed: true,
    documentVersions: versions, noticeWordingVersion: '2026-11-12'}), s.deps);
  assert.equal(s.rows.get(consentPath).status, 'confirmed');
});
