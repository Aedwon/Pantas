import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {answerRequest, getStatus, readRequest, sendLink, ADDRESS_LIMIT, GUARDIAN_WINDOW_MS, SEND_LIMIT, deleteGuardianRecords, purgeGuardianRecords} from '../lib/guardianConsent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const KEY = 'guardian-test-key';
const T0 = Date.parse('2026-11-02T10:00:00+08:00');
const DAY = 86400000;
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const documentVersions = {privacy: '2026-11-12', terms: '2026-11-12', teens: '2026-11-12'};
// Each caller comes from its own address unless a test names one, so the per-address limit stays out of the way.
const addressOf = uid => { let n = 7; for (const c of uid) n = (n * 31 + c.charCodeAt(0)) % 16_000_000; return `10.${n >> 16}.${(n >> 8) & 255}.${n & 255}`; };
const req = (uid, data, extra = {}) => ({auth: anon(uid), app, data: data?.decision
  ? {documentVersions, noticeWordingVersion: '2026-11-12', ...data} : data, rawRequest: {ip: addressOf(uid)}, ...extra});
const code = async promise => { try { await promise; return 'ok'; } catch (e) { assert.equal(typeof e.code, 'string', String(e)); return e.code; } };

function harness({now = T0} = {}) {
  const sent = [];
  let clock = now;
  let n = 0;
  return {
    sent, now: () => clock, advance: ms => { clock += ms; },
    deps: {db, key: KEY, linkOrigin: 'https://app.example.test/', now: () => clock,
      token: () => (++n).toString(16).padStart(64, '0'),
      allow: async () => true,
      mailer: {send: async m => { sent.push(m); }}},
  };
}
const body = (over = {}) => ({guardianName: 'Maria', guardianEmail: 'Maria@Gmail.com', ...over});
const reset = async uid => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.recursiveDelete(db.collection('guardianLimits'));
};
const tokenOf = m => /token=([a-f0-9]{64})/.exec(m.text)[1];
const stored = uid => db.doc(`users/${uid}/server/guardianConsent`).get().then(s => s.data());

test('a send stores hashes only, masks the address and mails a one-use link', async () => {
  const uid = 'g-send'; await reset(uid);
  const h = harness();
  const res = await sendLink(req(uid, body()), h.deps);
  assert.equal(res.maskedEmail, 'm***@g***.com');
  assert.equal(res.expiresAt, T0 + GUARDIAN_WINDOW_MS);
  assert.equal(h.sent.length, 1);
  assert.equal(h.sent[0].to, 'maria@gmail.com');
  const token = tokenOf(h.sent[0]);
  assert.ok(h.sent[0].text.includes(`https://app.example.test/guardian?token=${token}`));
  const doc = await stored(uid);
  assert.equal(doc.status, 'pending');
  assert.equal(doc.ageGroup, 'minor');
  const raw = JSON.stringify(doc);
  assert.ok(!raw.includes(token), 'token is not stored');
  assert.ok(!raw.toLowerCase().includes('maria@gmail.com'), 'email is not stored');
  assert.ok(!raw.includes('Maria'), 'guardian name is not stored');
  assert.match(doc.emailHash, /^[a-f0-9]{64}$/);
  assert.match(doc.tokenHash, /^[a-f0-9]{64}$/);
  const row = (await db.doc(`guardianTokens/${doc.tokenHash}`).get()).data();
  assert.deepEqual({uid: row.uid, state: row.state, expiresAt: row.expiresAt}, {uid, state: 'open', expiresAt: T0 + GUARDIAN_WINDOW_MS});
});

test('opening the link does not confirm; confirming needs the agreement box and works once', async () => {
  const uid = 'g-confirm'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  const guardian = 'g-visitor';
  assert.deepEqual(await readRequest(req(guardian, {token}), h.deps), {state: 'open', expiresAt: T0 + GUARDIAN_WINDOW_MS});
  await readRequest(req(guardian, {token}), h.deps);
  assert.equal((await stored(uid)).status, 'pending', 'reading never confirms');
  assert.equal(await code(answerRequest(req(guardian, {token, decision: 'confirm', agreed: false}), h.deps)), 'failed-precondition');
  assert.equal(await code(answerRequest(req(guardian, {token, decision: 'confirm'}), h.deps)), 'failed-precondition');
  assert.equal((await stored(uid)).status, 'pending');
  const confirmed = await answerRequest(req(guardian, {token, decision: 'confirm', agreed: true}), h.deps);
  assert.equal(confirmed.state, 'confirmed');
  assert.match(confirmed.manageToken, /^[a-f0-9]{64}$/);
  assert.equal((await stored(uid)).status, 'confirmed');
  assert.deepEqual(await answerRequest(req(guardian, {token, decision: 'confirm', agreed: true}), h.deps), {state: 'used'});
  assert.deepEqual(await readRequest(req(guardian, {token}), h.deps), {state: 'used'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'confirmed');
});

test('declining keeps the student waiting, and a new email replaces the old link', async () => {
  const uid = 'g-decline'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const first = tokenOf(h.sent[0]);
  assert.deepEqual(await answerRequest(req('v', {token: first, decision: 'decline'}), h.deps), {state: 'declined'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'declined');
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body({guardianEmail: 'other@mail.com'})), h.deps);
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'pending');
  assert.equal((await getStatus(req(uid, {}), h.deps)).maskedEmail, 'o***@m***.com');
  const second = tokenOf(h.sent[1]);
  assert.notEqual(first, second);
  assert.deepEqual(await answerRequest(req('v', {token: first, decision: 'confirm', agreed: true}), h.deps), {state: 'unknown'});
  assert.equal((await stored(uid)).status, 'pending', 'the old link cannot confirm');
  assert.equal((await answerRequest(req('v', {token: second, decision: 'confirm', agreed: true}), h.deps)).state, 'confirmed');
});

test('a resend revokes the earlier link', async () => {
  const uid = 'g-resend'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  const [a, b] = h.sent.map(tokenOf);
  assert.deepEqual(await readRequest(req('v', {token: a}), h.deps), {state: 'unknown'});
  assert.equal((await readRequest(req('v', {token: b}), h.deps)).state, 'open');
});

test('an expired link cannot be read or confirmed, and the status says expired', async () => {
  const uid = 'g-expire'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  h.advance(GUARDIAN_WINDOW_MS - 1);
  assert.equal((await readRequest(req('v', {token}), h.deps)).state, 'open');
  h.advance(1);
  assert.deepEqual(await readRequest(req('v', {token}), h.deps), {state: 'expired'});
  assert.deepEqual(await answerRequest(req('v', {token, decision: 'confirm', agreed: true}), h.deps), {state: 'expired'});
  assert.equal((await getStatus(req(uid, {}), h.deps)).status, 'expired');
  assert.equal((await stored(uid)).status, 'pending', 'expiry is computed, not trusted from a write');
});

test('sends are rate limited per student, per gap and per guardian address', async () => {
  const uid = 'g-limit'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'resource-exhausted', 'gap');
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uid, body()), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'resource-exhausted', 'same address, fourth send in a day');
  h.advance(DAY);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'ok', 'a new day opens the window');
  const denied = {...h.deps, allow: async () => false};
  await reset('g-limit2');
  assert.equal(await code(sendLink(req('g-limit2', body()), denied)), 'resource-exhausted', 'per-student limiter');
  assert.equal(await code(getStatus(req('g-limit2', {}), denied)), 'resource-exhausted');
  assert.equal(await code(readRequest(req('g-limit2', {token: 'a'.repeat(64)}), denied)), 'resource-exhausted');
});

test('a student name sent by an old client is ignored and never stored', async () => {
  const uid = 'g-noname'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body({studentName: 'Juan'})), h.deps);
  assert.ok(!h.sent[0].text.includes('Juan'));
  assert.equal(JSON.stringify(await stored(uid)).includes('Juan'), false);
  assert.equal('studentName' in (await stored(uid)), false);
});

test('bad input, no App Check and no sign-in are refused; a confirmed student cannot send again', async () => {
  const uid = 'g-input'; await reset(uid);
  const h = harness();
  for (const bad of [body({guardianEmail: 'nope'}), body({guardianName: ''}), body({guardianName: 'x'.repeat(61)}), {}]) {
    assert.equal(await code(sendLink(req(uid, bad), h.deps)), 'invalid-argument');
  }
  assert.equal(await code(sendLink({auth: anon(uid), data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink({app, data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink({auth: anon(uid), app: {...app, alreadyConsumed: true}, data: body()}, h.deps)), 'unauthenticated');
  assert.equal(await code(sendLink(req(uid, body(), {auth: {uid, token: {email: 'maria@gmail.com', firebase: {sign_in_provider: 'google.com'}}}}), h.deps)), 'invalid-argument', 'own email');
  assert.equal(h.sent.length, 0);
  await sendLink(req(uid, body()), h.deps);
  const token = tokenOf(h.sent[0]);
  await answerRequest(req('v', {token, decision: 'confirm', agreed: true}), h.deps);
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'failed-precondition');
});

test('names allow only letters, spaces, hyphens, apostrophes and periods, 40 at most', async () => {
  const uid = 'g-names'; await reset(uid);
  const h = harness();
  const bad = ['Maria2', 'Visit http://x.co', 'a@b', 'Call 0917', 'www.evil.com now', 'x'.repeat(41), 'Maria_', 'Maria\u{1F600}', '<b>'];
  for (const name of bad) {
    assert.equal(await code(sendLink(req(uid, body({guardianName: name})), h.deps)), 'invalid-argument', `guardian ${name}`);
  }
  assert.equal(h.sent.length, 0);
  for (const name of ["Mary-Ann O'Neil Jr.", 'José Niño', 'x'.repeat(40)]) {
    h.advance(SEND_LIMIT.gapMs + 1);
    assert.equal(await code(sendLink(req(uid, body({guardianName: name, guardianEmail: `n${h.sent.length}@mail.com`})), h.deps)), 'ok', name);
  }
  assert.equal(h.sent.at(-1).subject, "Review your child's Pantas account");
});

const globalDoc = h => db.doc(`guardianLimits/global-${new Intl.DateTimeFormat('en-CA', {timeZone: 'Asia/Manila'}).format(h.now())}`);
const fresh = async (...uids) => { for (const u of uids) await reset(u); await db.recursiveDelete(db.collection('guardianLimits')); };

test('new guardian emails stop at 80% of the daily cap; the cap resets next day', async () => {
  const uids = Array.from({length: 10}, (_, i) => `g-cap${i}`);
  await fresh(...uids);
  const h = harness();
  const deps = {...h.deps, dailyCap: 10, alert: () => {}};
  for (let i = 0; i < 8; i++) assert.equal(await code(sendLink(req(uids[i], body({guardianEmail: `n${i}@mail.com`})), deps)), 'ok', `send ${i}`);
  assert.equal(await code(sendLink(req(uids[8], body({guardianEmail: 'n8@mail.com'})), deps)), 'resource-exhausted');
  h.advance(DAY);
  assert.equal(await code(sendLink(req(uids[8], body({guardianEmail: 'n8@mail.com'})), deps)), 'ok');
  for (const bad of [0, -1, NaN]) {
    assert.equal(await code(sendLink(req(uids[9], body({guardianEmail: 'z@mail.com'})), {...h.deps, dailyCap: bad})), 'resource-exhausted', `cap ${bad}`);
  }
});

test('the last 20% of the cap is kept for re-sends to an email already on file', async () => {
  const uids = Array.from({length: 9}, (_, i) => `g-res${i}`);
  await fresh(...uids);
  const h = harness();
  const deps = {...h.deps, dailyCap: 10, alert: () => {}};
  for (let i = 0; i < 8; i++) await sendLink(req(uids[i], body({guardianEmail: `r${i}@mail.com`})), deps);
  assert.equal(await code(sendLink(req(uids[8], body({guardianEmail: 'new@mail.com'})), deps)), 'resource-exhausted', 'a new email is refused');
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uids[0], body({guardianEmail: 'r0@mail.com'})), deps)), 'ok', 'resend 1');
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uids[1], body({guardianEmail: 'r1@mail.com'})), deps)), 'ok', 'resend 2');
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uids[2], body({guardianEmail: 'r2@mail.com'})), deps)), 'resource-exhausted', 'cap reached');
  assert.equal((await globalDoc(h).get()).get('count'), 10);
});

test('a failed mail gives its place back', async () => {
  await fresh('g-refund');
  const h = harness();
  const failing = {...h.deps, dailyCap: 10, alert: () => {}, mailer: {send: async () => { throw new Error('down'); }}};
  assert.equal(await code(sendLink(req('g-refund', body()), failing)), 'unavailable');
  assert.equal((await globalDoc(h).get()).get('count'), 0);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req('g-refund', body()), {...h.deps, dailyCap: 10, alert: () => {}});
  assert.equal((await globalDoc(h).get()).get('count'), 1);
});

test('an error-level alert is raised once when sends reach 80% of the cap', async () => {
  const uids = Array.from({length: 9}, (_, i) => `g-alert${i}`);
  await fresh(...uids);
  const h = harness();
  const alerts = [];
  const deps = {...h.deps, dailyCap: 10, alert: m => alerts.push(m)};
  for (let i = 0; i < 7; i++) await sendLink(req(uids[i], body({guardianEmail: `a${i}@mail.com`})), deps);
  assert.equal(alerts.length, 0);
  await sendLink(req(uids[7], body({guardianEmail: 'a7@mail.com'})), deps);
  assert.equal(alerts.length, 1);
  assert.match(alerts[0], /80%/);
  h.advance(SEND_LIMIT.gapMs + 1);
  await sendLink(req(uids[0], body({guardianEmail: 'a0@mail.com'})), deps);
  assert.equal(alerts.length, 1, 'only once');
});

test('unknown and malformed tokens reveal nothing', async () => {
  const h = harness();
  for (const token of [undefined, '', 'short', 'z'.repeat(64), 'a'.repeat(64), 5]) {
    assert.deepEqual(await readRequest(req('v', {token}), h.deps), {state: 'unknown'});
    assert.deepEqual(await answerRequest(req('v', {token, decision: 'decline'}), h.deps), {state: 'unknown'});
  }
  assert.equal(await code(answerRequest(req('v', {token: 'a'.repeat(64), decision: 'maybe'}), h.deps)), 'invalid-argument');
});

test('a failed mail leaves the student able to retry and reports it', async () => {
  const uid = 'g-mailfail'; await reset(uid);
  const h = harness();
  const failing = {...h.deps, mailer: {send: async () => { throw new Error('provider down'); }}};
  assert.equal(await code(sendLink(req(uid, body()), failing)), 'unavailable');
  h.advance(SEND_LIMIT.gapMs + 1);
  assert.equal(await code(sendLink(req(uid, body()), h.deps)), 'ok');
});

test('deleting the account removes the link record', async () => {
  const uid = 'g-delete'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const {tokenHash} = await stored(uid);
  await deleteGuardianRecords(db, uid);
  assert.equal((await db.doc(`guardianTokens/${tokenHash}`).get()).exists, false);
  await deleteGuardianRecords(db, 'g-never');
});


test('cleanup deletes expired contact data and preserves server-only consent evidence', async () => {
  const uid = 'g-cleanup'; await reset(uid);
  const h = harness();
  await sendLink(req(uid, body()), h.deps);
  const {tokenHash} = await stored(uid);
  h.advance(DAY);
  await answerRequest(req('v', {token: tokenOf(h.sent[0]), decision: 'confirm', agreed: true}), h.deps);
  const evidence = db.doc(`guardianConsentEvidence/${uid}/responses/${tokenHash}`);
  assert.deepEqual((await evidence.get()).data(), {documentVersions,
    noticeWordingVersion: '2026-11-12', action: 'confirm', agreed: true, decidedAt: T0 + DAY, sharingAllowed: false});
  await purgeGuardianRecords(db, T0 + 8 * DAY - 1);
  assert.equal((await db.doc(`guardianTokens/${tokenHash}`).get()).exists, true);
  await purgeGuardianRecords(db, T0 + 8 * DAY);
  assert.equal((await db.doc(`guardianTokens/${tokenHash}`).get()).exists, false);
  assert.deepEqual(await stored(uid), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0 + DAY, sharingAllowed: false});
  await db.recursiveDelete(db.doc(`users/${uid}`));
  assert.equal((await evidence.get()).exists, true, 'minimum evidence survives account deletion');
});

// ------------------------------------------------ S-10 item 5: a limit per client address

const fromAddress = (uid, ip, forwarded, data = body()) => req(uid, data,
  {rawRequest: {ip, headers: forwarded === undefined ? {} : {'x-forwarded-for': forwarded}}});

test('one client address gets 5 guardian emails an hour whatever accounts or X-Forwarded-For it uses', async () => {
  await reset('g-addr');
  const h = harness();
  // Children reach this step before they name an account, so the callers here are anonymous.
  for (let i = 0; i < ADDRESS_LIMIT.max; i += 1) {
    await sendLink(fromAddress(`g-addr-${i}`, '10.0.0.1', `198.51.100.${i}, 203.0.113.9`,
      body({guardianEmail: `parent${i}@example.com`})), h.deps);
  }
  assert.equal(h.sent.length, 5);
  assert.equal(await code(sendLink(fromAddress('g-addr-x', '10.0.0.1', '192.0.2.77, 203.0.113.9',
    body({guardianEmail: 'late@example.com'})), h.deps)), 'resource-exhausted', 'a spoofed left side is no new client');
  assert.equal(h.sent.length, 5);
  assert.equal(await code(sendLink(fromAddress('g-addr-y', '10.0.0.2', undefined,
    body({guardianEmail: 'other@example.com'})), h.deps)), 'ok', 'another client address is unaffected');
  assert.equal(await code(sendLink(fromAddress('g-addr-z', '10.0.0.3', '203.0.113.9',
    body({guardianEmail: 'third@example.com'})), h.deps)), 'resource-exhausted');
  const stored = (await db.collection('guardianLimits').get()).docs.map(doc => doc.id);
  assert.ok(stored.every(id => !id.includes('203.0.113.9')), 'the address is kept only as a hash');
  h.advance(60 * 60_000 + 1);
  assert.equal(await code(sendLink(fromAddress('g-addr-z', '10.0.0.3', '203.0.113.9',
    body({guardianEmail: 'third@example.com'})), h.deps)), 'ok', 'the window is an hour');
});

test('a call with no address at all shares one unknown bucket instead of skipping the limit', async () => {
  await reset('g-unk');
  const h = harness();
  for (let i = 0; i < ADDRESS_LIMIT.max; i += 1) {
    await sendLink(req(`g-unk-${i}`, body({guardianEmail: `p${i}@example.com`}), {rawRequest: undefined}), h.deps);
  }
  assert.equal(await code(sendLink(req('g-unk-x', body({guardianEmail: 'late@example.com'}), {rawRequest: {}}), h.deps)),
    'resource-exhausted');
});

test('a refused address limit sends nothing and stores no consent record', async () => {
  await reset('g-addr2');
  const h = harness();
  const deps = {...h.deps};
  for (let i = 0; i < ADDRESS_LIMIT.max; i += 1) {
    await sendLink(fromAddress(`g-addr2-${i}`, '10.0.1.1', undefined, body({guardianEmail: `q${i}@example.com`})), deps);
  }
  const before = h.sent.length;
  await code(sendLink(fromAddress('g-addr2-late', '10.0.1.1', undefined, body({guardianEmail: 'late@example.com'})), deps));
  assert.equal(h.sent.length, before);
  assert.equal(await stored('g-addr2-late'), undefined);
});

// ------------------------------------------------ S-10 item 6: the full-bucket alert

function errorLines(t) {
  const lines = [];
  for (const stream of [process.stdout, process.stderr]) {
    t.mock.method(stream, 'write', chunk => { lines.push(String(chunk)); return true; });
  }
  return () => lines.flatMap(line => { try { return [JSON.parse(line)]; } catch { return []; } })
    .filter(entry => entry.severity === 'ERROR' && entry.event === 'mail_cap_full');
}

test('the guardian daily bucket logs exactly one ERROR line a day when it is full', async t => {
  await reset('g-full');
  const read = errorLines(t);
  const h = harness();
  const deps = {...h.deps, dailyCap: 5};
  // A new address may use 80% of the cap (4). The fifth new address is refused: that is the full day.
  for (let i = 0; i < 8; i += 1) {
    await code(sendLink(fromAddress(`g-full-${i}`, `10.1.0.${i}`, undefined, body({guardianEmail: `f${i}@example.com`})), deps));
  }
  assert.equal(h.sent.length, 4);
  const lines = read();
  assert.equal(lines.length, 1);
  assert.equal(lines[0].bucket, 'guardian');
  assert.ok(lines[0].message.includes('Mail cap full: guardian bucket, 2026-11-02.'));
  // The next Philippine day logs again, once.
  h.advance(DAY);
  for (let i = 0; i < 8; i += 1) {
    await code(sendLink(fromAddress(`g-full-n${i}`, `10.2.0.${i}`, undefined, body({guardianEmail: `n${i}@example.com`})), deps));
  }
  assert.equal(read().length, 2);
});

test('a guardian mail failure gives the place back without clearing the day flag', async t => {
  await reset('g-fail');
  const h = harness();
  const deps = {...h.deps, dailyCap: 2, mailer: {send: async () => { throw new Error('provider down'); }}};
  await code(sendLink(fromAddress('g-fail', '10.3.0.1', undefined, body({guardianEmail: 'x@example.com'})), deps));
  const day = (await db.doc('guardianLimits/global-2026-11-02').get());
  assert.equal(day.get('count'), 0);
});
