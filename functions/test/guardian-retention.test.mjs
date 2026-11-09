import assert from 'node:assert/strict';
import test from 'node:test';
import * as guardian from '../lib/guardianConsent.js';

const DAY = 86400000;
const T0 = Date.parse('2026-11-09T00:00:00+08:00');
const versions = {privacy: '2026-11-10', terms: '2026-11-10', teens: '2026-11-10'};
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const request = (data) => ({auth: {uid: 'visitor'}, app, data});

// Runs the real consent transactions against a small document store.
function store(initial = {}) {
  const rows = new Map(Object.entries(initial));
  const snapshot = ref => ({ref, id: ref.id, exists: rows.has(ref.path),
    data: () => rows.get(ref.path), get: key => rows.get(ref.path)?.[key]});
  const doc = path => ({path, id: path.split('/').at(-1),
    get: async () => snapshot(doc(path)),
    delete: async () => rows.delete(path)});
  const query = (matches, cursor = '', size = Infinity) => ({
    orderBy: () => query(matches, cursor, size),
    limit: n => query(matches, cursor, n),
    where: (field, op, value) => query(path => matches(path) && rows.get(path)?.[field] === value, cursor, size),
    startAfter: last => query(matches, last.ref.path, size),
    get: async () => {
      const docs = [...rows.keys()].sort().filter(path => path > cursor && matches(path))
        .slice(0, size).map(path => snapshot(doc(path)));
      return {docs, empty: docs.length === 0, size: docs.length};
    },
  });
  const tx = {get: async ref => ref.path ? snapshot(ref) : ref.get(),
    set: (ref, value, options) => rows.set(ref.path,
      options?.merge ? {...rows.get(ref.path), ...value} : value),
    delete: ref => rows.delete(ref.path)};
  const db = {doc,
    collection: name => query(path => path.split('/').length === 2 && path.startsWith(`${name}/`)),
    collectionGroup: name => query(path => path.split('/').at(-2) === name),
    runTransaction: async fn => fn(tx)};
  return {db, rows};
}
const consentPath = 'users/student/server/guardianConsent';
const evidencePath = hash => `guardianConsentEvidence/student/responses/${hash}`;
function pending() {
  const token = 'a'.repeat(64);
  const hash = guardian.hashValue('key', 'token', token);
  const s = store({[consentPath]: {status: 'pending', ageGroup: 'minor',
    tokenHash: hash, emailHash: 'email-hash', maskedEmail: 'm***@g***.com',
    sentAt: T0, expiresAt: T0 + 7 * DAY},
  [`guardianTokens/${hash}`]: {uid: 'student', state: 'open', createdAt: T0, expiresAt: T0 + 7 * DAY}});
  const deps = {db: s.db, key: 'key', now: () => T0 + DAY,
    allow: async () => true, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'};
  return {...s, deps, token, hash};
}

for (const decision of ['confirm', 'decline']) {
  test(`${decision} records the shown versions, action and time without contact data`, async () => {
    const s = pending();
    const data = {token: s.token, decision, agreed: decision === 'confirm',
      documentVersions: versions, noticeWordingVersion: '2026-11-11'};
    await guardian.answerRequest(request(data), s.deps);
    assert.deepEqual(s.rows.get(evidencePath(s.hash)), {
      documentVersions: versions, noticeWordingVersion: '2026-11-11',
      action: decision, agreed: decision === 'confirm', decidedAt: T0 + DAY,
      ...(decision === 'confirm' ? {sharingAllowed: false} : {}),
    });
    await guardian.answerRequest(request(data), {...s.deps, now: () => T0 + 2 * DAY});
    assert.equal(s.rows.get(evidencePath(s.hash)).decidedAt, T0 + DAY, 'replay cannot replace evidence');
  });
}

test('missing or mismatched shown versions cannot create false evidence', async () => {
  for (const extra of [{}, {documentVersions: {...versions, teens: 'old'}, noticeWordingVersion: '2026-11-11'},
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
  assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'minor'});
  assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
});

for (const decision of ['confirm', 'decline']) {
  test(`${decision} removes contact and used links seven days later but retains evidence`, async () => {
    const s = pending();
    await guardian.answerRequest(request({token: s.token, decision, agreed: decision === 'confirm',
      documentVersions: versions, noticeWordingVersion: '2026-11-11'}), s.deps);
    await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY - 1);
    assert.ok(s.rows.has(`guardianTokens/${s.hash}`));
    await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
    assert.equal(s.rows.has(`guardianTokens/${s.hash}`), false);
    assert.ok(s.rows.has(evidencePath(s.hash)));
    if (decision === 'confirm') {
      assert.deepEqual(s.rows.get(consentPath), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0 + DAY, sharingAllowed: false});
    } else {
      assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'minor'});
    }
  });
}

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
  // Contact data and the status go; the minor mark stays for checkout.
  assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'minor'});
});

test('a declined request keeps only the minor mark, and the status reads as none', async () => {
  const s = store({[consentPath]: {status: 'declined', ageGroup: 'minor', decidedAt: T0,
    emailHash: 'e', maskedEmail: 'm***@g***.com', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY}});
  await guardian.purgeGuardianRecords(s.db, T0 + 7 * DAY);
  assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'minor'});
  await guardian.purgeGuardianRecords(s.db, T0 + 30 * DAY);
  assert.deepEqual(s.rows.get(consentPath), {ageGroup: 'minor'});
  const status = await guardian.getStatus({auth: {uid: 'student'}, app, data: {}},
    {db: s.db, key: 'key', now: () => T0 + 30 * DAY, allow: async () => true,
      mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test'});
  assert.equal(status.status, 'none');
  assert.equal(status.ageGroup, 'minor');
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
    sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0}});
  await guardian.purgeGuardianRecords(s.db, T0 + 8 * DAY);
  assert.deepEqual(s.rows.get(consentPath), kept, 'an adult is not turned back into a minor');
  const minor = store({[consentPath]: {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true,
    emailHash: 'e', maskedEmail: 'm', tokenHash: 't', sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0}});
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
