import assert from 'node:assert/strict';
import test from 'node:test';
import {checkGuardianCode, consumeGuardianProof, guardianCodeMessage, hashGuardianCode, sendGuardianCode,
  GUARDIAN_CODES_PER_HOLDER_PER_DAY} from '../lib/guardianCodeGate.js';
import {fakeFirestore} from './_fake-firestore.mjs';

const KEY = 'gate-test-key';
const HOLDER_EMAIL = 'maria@example.com';
const T0 = Date.UTC(2026, 10, 19, 10, 0, 0);
const MIN = 60_000;
const entry = (childUid, nickname, over = {}) =>
  ({childUid, nickname, active: true, siblingOpenWithoutCode: false, createdAt: 1, ...over});
const caller = uid => ({uid, token: {firebase: {sign_in_provider: 'custom'}}});
const err = promise => promise.then(() => assert.fail('expected a refusal'), e => e);

function rig({users, send = {}, verify = {}, mailer} = {}) {
  const db = fakeFirestore({
    'users/h1/server/children/items/kidA': entry('kidA', 'Ana'),
    'users/h1/server/children/items/kidB': entry('kidB', 'Ben'),
    'users/h1/server/children/items/kidX': entry('kidX', 'Gone', {active: false}),
    'users/kidA/server/childLink': {holderUid: 'h1'},
    'users/kidB/server/childLink': {holderUid: 'h1'},
    'users/kidX/server/childLink': {holderUid: 'h1'},
    'users/h2/server/children/items/kidZ': entry('kidZ', 'Zed'),
    'users/kidZ/server/childLink': {holderUid: 'h2'},
  });
  const accounts = users ?? {h1: {uid: 'h1', email: HOLDER_EMAIL}, h2: {uid: 'h2', email: 'other@example.com'},
    lonely: {uid: 'lonely', email: 'lonely@example.com'}};
  const auth = {getUser: async uid => {
    if (!accounts[uid]) throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'});
    return accounts[uid];
  }};
  const sent = [];
  const mail = mailer ?? {send: async m => { sent.push(m); }};
  let t = T0;
  let n = 0;
  let c = 41;
  const clock = {now: () => t, advance: ms => { t += ms; }};
  const deps = {db, auth, key: KEY, mailer: mail, now: clock.now, allow: async () => true,
    random: () => ++c, proofId: () => String(++n).padStart(32, '0'), ...send};
  const vdeps = {db, auth, key: KEY, now: clock.now, allow: async () => true,
    proofId: deps.proofId, ...verify};
  const ask = (uid, data, over = {}) => sendGuardianCode({auth: caller(uid), app: {appId: 'a'}, data, ...over}, deps);
  const check = (uid, data, over = {}) => checkGuardianCode({auth: caller(uid), app: {appId: 'a'}, data, ...over}, vdeps);
  return {db, sent, clock, deps, vdeps, ask, check};
}

const codeRow = r => r.db.rows.get('guardianCodes/h1');
const del = {action: 'delete', childId: 'kidA'};

// ---------------------------------------------------------------- request

test('a child asks: the server stores only a keyed hash bound to holder, child and action, and mails the holder', async () => {
  const r = rig();
  const result = await r.ask('kidA', del);
  assert.deepEqual(result, {maskedEmail: 'm***@e***.com', resendAfterSeconds: 60, expiresInSeconds: 600});
  const row = codeRow(r);
  assert.equal(row.holderUid, 'h1');
  assert.equal(row.childId, 'kidA');
  assert.equal(row.action, 'delete');
  assert.equal(row.attempts, 0);
  assert.equal(row.codeHash, hashGuardianCode(KEY, 'h1', 'kidA', 'delete', '000042'));
  assert.equal(row.expiresAt.getTime(), T0 + 10 * MIN);
  assert.ok(row.purgeAt instanceof Date);
  assert.ok(!JSON.stringify([...r.db.rows.values()]).includes('000042'));
  assert.equal(r.sent.length, 1);
  assert.equal(r.sent[0].to, HOLDER_EMAIL);
  assert.equal(r.sent[0].subject, 'Pantas code for Ana');
  assert.equal(r.sent[0].text, 'Use this code to confirm deleting the account for Ana: 000042. ' +
    'It works once and expires soon. If you did not ask for it, ignore this email.');
});

test('the hash differs when holder, child, action or code differ', () => {
  const base = hashGuardianCode(KEY, 'h1', 'kidA', 'delete', '000042');
  for (const other of [hashGuardianCode(KEY, 'h2', 'kidA', 'delete', '000042'),
    hashGuardianCode(KEY, 'h1', 'kidB', 'delete', '000042'), hashGuardianCode(KEY, 'h1', 'kidA', 'withdraw', '000042'),
    hashGuardianCode(KEY, 'h1', 'kidA', 'delete', '000043'), hashGuardianCode(KEY, 'h1', null, 'delete', '000042'),
    hashGuardianCode('other', 'h1', 'kidA', 'delete', '000042')]) assert.notEqual(other, base);
});

test('the holder can ask too, and every action has a plain phrase', async () => {
  const phrases = {dataCopy: 'a copy of the data', withdraw: 'withdrawing permission', delete: 'deleting the account',
    siblingOptIn: 'the sibling sign-in setting', switchInto: 'opening the account'};
  for (const [action, phrase] of Object.entries(phrases)) {
    const r = rig();
    await r.ask('h1', {action, childId: 'kidB'});
    assert.equal(r.sent[0].text, `Use this code to confirm ${phrase} for Ben: 000042. ` +
      'It works once and expires soon. If you did not ask for it, ignore this email.', action);
  }
});

test('addChild has no child: the holder is the caller or the caller\'s holder', async () => {
  for (const uid of ['kidA', 'h1']) {
    const r = rig();
    await r.ask(uid, {action: 'addChild'});
    assert.equal(codeRow(r).childId, null);
    assert.equal(r.sent[0].to, HOLDER_EMAIL);
    assert.equal(r.sent[0].subject, 'Pantas code for your account');
    assert.equal(r.sent[0].text, 'Use this code to confirm adding a child for your account: 000042. ' +
      'It works once and expires soon. If you did not ask for it, ignore this email.');
  }
  const r = rig();
  assert.equal((await err(r.ask('h1', {action: 'addChild', childId: 'kidA'}))).code, 'invalid-argument');
});

test('unlinked callers and unlinked children are refused and nothing is mailed', async () => {
  const r = rig();
  for (const [uid, data] of [['lonely', del], ['kidZ', del], ['h2', del], ['kidA', {action: 'delete', childId: 'kidZ'}],
    ['h1', {action: 'delete', childId: 'kidX'}], ['h1', {action: 'delete', childId: 'nobody'}],
    ['lonely', {action: 'addChild'}], ['kidX', {action: 'addChild'}]]) {
    const e = await err(r.ask(uid, data));
    assert.equal(e.code, 'permission-denied', `${uid} ${JSON.stringify(data)}`);
  }
  assert.equal(r.sent.length, 0);
  assert.equal(codeRow(r), undefined);
});

test('bad input is refused', async () => {
  const r = rig();
  for (const data of [undefined, {}, {action: 'nope', childId: 'kidA'}, {action: 5, childId: 'kidA'},
    {action: 'delete'}, {action: 'delete', childId: ''}, {action: 'delete', childId: 'a/b'}, {action: 'delete', childId: 7}]) {
    assert.equal((await err(r.ask('h1', data))).code, 'invalid-argument', JSON.stringify(data));
  }
});

test('sign-in and App Check are required', async () => {
  const r = rig();
  assert.equal((await err(sendGuardianCode({data: del, app: {appId: 'a'}}, r.deps))).code, 'unauthenticated');
  assert.equal((await err(checkGuardianCode({data: {...del, code: '000042'}, app: {appId: 'a'}}, r.vdeps))).code, 'unauthenticated');
});

test('a holder with no email on file cannot get a code', async () => {
  const r = rig({users: {h1: {uid: 'h1'}}});
  assert.equal((await err(r.ask('h1', del))).code, 'failed-precondition');
  assert.equal(r.sent.length, 0);
});

test('the per-caller limit refuses before anything is stored', async () => {
  const r = rig({send: {allow: async () => false}});
  const e = await err(r.ask('h1', del));
  assert.equal(e.code, 'resource-exhausted');
  assert.equal(r.sent.length, 0);
});

test('the email escapes the nickname and has no em dash', () => {
  const m = guardianCodeMessage({to: 'a@b.co', code: '123456', action: 'delete', nickname: '<b>Ana</b>'});
  assert.ok(!m.html.includes('<b>Ana'));
  assert.ok(m.html.includes('&lt;b&gt;Ana'));
  assert.ok(!/—/.test(m.text + m.html + m.subject));
  assert.ok(m.html.includes('123456'));
});

test('asking again for the same child and action inside a minute sends nothing new', async () => {
  const r = rig();
  await r.ask('kidA', del);
  r.clock.advance(20_000);
  const again = await r.ask('kidA', del);
  assert.equal(again.resendAfterSeconds, 40);
  assert.equal(r.sent.length, 1);
  r.clock.advance(41_000);
  await r.ask('kidA', del);
  assert.equal(r.sent.length, 2);
  // The new code replaced the old one.
  assert.equal((await err(r.check('kidA', {...del, code: '000042'}))).details.reason, 'wrong');
  assert.ok((await r.check('kidA', {...del, code: '000043'})).proof);
});

test('a request for a different child or action cancels the pending code at once', async () => {
  for (const next of [{action: 'delete', childId: 'kidB'}, {action: 'withdraw', childId: 'kidA'}, {action: 'addChild'}]) {
    const r = rig();
    await r.ask('kidA', del);
    await r.ask('kidA', next);
    assert.equal(r.sent.length, 2);
    const e = await err(r.check('kidA', {...del, code: '000042'}));
    assert.equal(e.code, 'not-found');
    assert.equal(e.details.reason, 'expired');
    assert.ok((await r.check('kidA', {...next, code: '000043'})).proof);
  }
});

test('the per-holder daily limit is a named constant of 10 and counts per UTC day', async () => {
  assert.equal(GUARDIAN_CODES_PER_HOLDER_PER_DAY, 10);
  const r = rig();
  for (let i = 0; i < 10; i += 1) {
    await r.ask('kidA', del);
    r.clock.advance(61_000);
  }
  assert.equal(r.sent.length, 10);
  const e = await err(r.ask('kidA', del));
  assert.equal(e.code, 'resource-exhausted');
  assert.equal(e.details.reason, 'guardian-code-daily-limit');
  assert.equal(r.sent.length, 10);
  // The refused request left the last code alone.
  assert.ok((await r.check('kidA', {...del, code: '000051'})).proof);
  // Another holder is unaffected.
  await r.ask('kidZ', {action: 'delete', childId: 'kidZ'});
  assert.equal(r.sent.length, 11);
  // The next UTC day starts a new count.
  r.clock.advance(24 * 3_600_000);
  await r.ask('kidA', del);
  assert.equal(r.sent.length, 12);
});

test('the guardian daily mail cap is shared with guardian consent mail', async () => {
  const r = rig({send: {dailyCap: 2}});
  const day = '2026-11-19';
  await r.ask('kidA', del);
  r.clock.advance(61_000);
  await r.ask('kidA', del);
  r.clock.advance(61_000);
  const e = await err(r.ask('kidA', del));
  assert.equal(e.details.reason, 'guardian-code-daily-limit');
  assert.equal(r.db.rows.get(`guardianLimits/global-${day}`).count, 2);
  // Consent mail already counted today is counted too.
  const s = rig({send: {dailyCap: 5}});
  s.db.rows.set(`guardianLimits/global-${day}`, {count: 5});
  assert.equal((await err(s.ask('kidA', del))).details.reason, 'guardian-code-daily-limit');
});

test('a mail failure gives the places back and leaves no pending code', async () => {
  const r = rig({mailer: {send: async () => { throw new Error('provider down'); }}});
  const e = await err(r.ask('kidA', del));
  assert.equal(e.code, 'unavailable');
  assert.equal(codeRow(r), undefined);
  assert.equal(r.db.rows.get('guardianLimits/global-2026-11-19').count, 0);
  const holderDay = [...r.db.rows.entries()].find(([k]) => k.startsWith('guardianCodeLimits/'));
  assert.equal(holderDay[1].count, 0);
});

// ----------------------------------------------------------------- verify

test('a right code returns a short-lived proof bound to holder, child and action, and uses the code up', async () => {
  const r = rig();
  await r.ask('kidA', del);
  r.clock.advance(MIN);
  const result = await r.check('kidA', {...del, code: '000042'});
  assert.deepEqual(result, {proof: '00000000000000000000000000000001', expiresInSeconds: 300});
  assert.deepEqual({...r.db.rows.get(`guardianCodeProofs/${result.proof}`), expiresAt: undefined, purgeAt: undefined},
    {holderUid: 'h1', childId: 'kidA', action: 'delete', expiresAt: undefined, purgeAt: undefined});
  assert.equal(r.db.rows.get(`guardianCodeProofs/${result.proof}`).expiresAt.getTime(), T0 + MIN + 5 * MIN);
  assert.equal(codeRow(r), undefined);
});

test('proof ids come from 128 random bits by default', async () => {
  const r = rig();
  delete r.vdeps.proofId;
  await r.ask('kidA', del);
  assert.match((await r.check('kidA', {...del, code: '000042'})).proof, /^[0-9a-f]{32}$/);
});

test('a code cannot be used for another child or action, and that does not spend tries', async () => {
  const r = rig();
  await r.ask('kidA', del);
  for (const data of [{action: 'delete', childId: 'kidB', code: '000042'}, {action: 'withdraw', childId: 'kidA', code: '000042'},
    {action: 'addChild', code: '000042'}]) {
    const e = await err(r.check('kidA', data));
    assert.equal(e.code, 'not-found', JSON.stringify(data));
    assert.equal(e.details.reason, 'expired');
  }
  assert.equal(codeRow(r).attempts, 0);
  assert.ok((await r.check('kidA', {...del, code: '000042'})).proof);
});

test('a code does not work for a caller who is not linked to that holder', async () => {
  const r = rig();
  await r.ask('kidA', del);
  for (const uid of ['lonely', 'kidZ', 'h2']) {
    assert.equal((await err(r.check(uid, {...del, code: '000042'}))).code, 'permission-denied', uid);
  }
  assert.equal(codeRow(r).attempts, 0);
});

test('a code expires after 10 minutes', async () => {
  const r = rig();
  await r.ask('kidA', del);
  r.clock.advance(10 * MIN);
  const e = await err(r.check('kidA', {...del, code: '000042'}));
  assert.equal(e.details.reason, 'expired');
  assert.equal(codeRow(r), undefined);
  const s = rig();
  await s.ask('kidA', del);
  s.clock.advance(10 * MIN - 1);
  assert.ok((await s.check('kidA', {...del, code: '000042'})).proof);
});

test('a code works once', async () => {
  const r = rig();
  await r.ask('kidA', del);
  await r.check('kidA', {...del, code: '000042'});
  assert.equal((await err(r.check('kidA', {...del, code: '000042'}))).details.reason, 'expired');
});

test('five wrong tries kill the code, even for the right code afterwards', async () => {
  const r = rig();
  await r.ask('kidA', del);
  for (let left = 4; left >= 0; left -= 1) {
    const e = await err(r.check('kidA', {...del, code: '999999'}));
    assert.equal(e.code, 'invalid-argument');
    assert.equal(e.details.reason, 'wrong');
    assert.equal(e.details.triesLeft, left);
  }
  const dead = await err(r.check('kidA', {...del, code: '000042'}));
  assert.equal(dead.code, 'resource-exhausted');
  assert.equal(dead.details.reason, 'tooManyTries');
  assert.equal(r.db.rows.size > 0 && [...r.db.rows.keys()].some(k => k.startsWith('guardianCodeProofs/')), false);
});

test('verify input and per-caller limit', async () => {
  const r = rig();
  await r.ask('kidA', del);
  for (const code of [undefined, 42, '12345', '1234567', 'abcdef', '12 456']) {
    assert.equal((await err(r.check('kidA', {...del, code}))).code, 'invalid-argument', String(code));
  }
  const limited = rig({verify: {allow: async () => false}});
  await limited.ask('kidA', del);
  assert.equal((await err(limited.check('kidA', {...del, code: '000042'}))).code, 'resource-exhausted');
});

// ----------------------------------------------------------------- proof

async function proofFor(r, data = del, uid = 'kidA') {
  await r.ask(uid, data);
  r.clock.advance(1);
  const code = String(r.deps.random() - 1).padStart(6, '0');
  return (await r.check(uid, {...data, code})).proof;
}

test('a proof is consumed once for the exact holder, child and action', async () => {
  const r = rig();
  const proof = await proofFor(r);
  const opts = {db: r.db, now: r.clock.now};
  await consumeGuardianProof(proof, 'h1', 'kidA', 'delete', opts);
  const e = await err(consumeGuardianProof(proof, 'h1', 'kidA', 'delete', opts));
  assert.equal(e.code, 'permission-denied');
  assert.equal(e.details.reason, 'guardian-proof-invalid');
});

test('a proof for another holder, child or action is refused and stays usable', async () => {
  const r = rig();
  const proof = await proofFor(r);
  const opts = {db: r.db, now: r.clock.now};
  for (const [h, c, a] of [['h2', 'kidA', 'delete'], ['h1', 'kidB', 'delete'], ['h1', 'kidA', 'withdraw'], ['h1', null, 'delete']]) {
    assert.equal((await err(consumeGuardianProof(proof, h, c, a, opts))).details.reason, 'guardian-proof-invalid', `${h} ${c} ${a}`);
  }
  await consumeGuardianProof(proof, 'h1', 'kidA', 'delete', opts);
});

test('an addChild proof has a null child', async () => {
  const r = rig();
  const proof = await proofFor(r, {action: 'addChild'}, 'h1');
  const opts = {db: r.db, now: r.clock.now};
  assert.equal((await err(consumeGuardianProof(proof, 'h1', 'kidA', 'addChild', opts))).details.reason, 'guardian-proof-invalid');
  await consumeGuardianProof(proof, 'h1', null, 'addChild', opts);
});

test('a proof expires after 5 minutes, and unknown or malformed proofs are refused', async () => {
  const r = rig();
  const proof = await proofFor(r);
  const opts = {db: r.db, now: r.clock.now};
  r.clock.advance(5 * MIN);
  assert.equal((await err(consumeGuardianProof(proof, 'h1', 'kidA', 'delete', opts))).details.reason, 'guardian-proof-invalid');
  for (const bad of ['', 'nope', '0'.repeat(32), undefined, 7, 'a/b']) {
    assert.equal((await err(consumeGuardianProof(bad, 'h1', 'kidA', 'delete', opts))).details.reason, 'guardian-proof-invalid', String(bad));
  }
});
