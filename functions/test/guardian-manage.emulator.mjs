import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import * as guardian from '../lib/guardianConsent.js';
import * as deletion from '../lib/deleteUserData.js';
import * as acceptance from '../lib/setupAcceptance.js';
import * as inactive from '../lib/purgeInactiveAccounts.js';
import {identityMarkers} from '../lib/webTrial.js';

// Local emulator fixture only. Production requires the provisioned Functions secret.
process.env.TRIAL_IDENTITY_HMAC_KEY = 'manage-emulator-only-hmac-key';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const auth = getAuth();
const KEY = 'guardian-manage-key';
const T0 = Date.parse('2026-11-09T10:00:00+08:00');
const DAY = 86400000;
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const versions = {privacy: '2026-11-12', terms: '2026-11-12', teens: '2026-11-12'};
const req = (uid, data, extra = {}) => ({auth: anon(uid), app, data, ...extra});
const answer = (token, over = {}) => ({token, decision: 'confirm', agreed: true,
  documentVersions: versions, noticeWordingVersion: '2026-11-12', ...over});
const code = async promise => { try { await promise; return 'ok'; } catch (e) { assert.equal(typeof e.code, 'string', String(e)); return e.code; } };
const confirmTokenOf = m => /guardian\?token=([a-f0-9]{64})/.exec(m.text)[1];
const manageTokenOf = m => /guardian\/manage\?token=([a-f0-9]{64})/.exec(m.text)[1];
const stored = uid => db.doc(`users/${uid}/server/guardianConsent`).get().then(s => s.data());
const body = (over = {}) => ({guardianName: 'Maria', guardianEmail: 'maria@gmail.com', ...over});
const rows = async path => (await db.collection(path).get()).docs.map(d => d.data());

function harness({now = T0, authApi = auth} = {}) {
  const sent = [];
  let clock = now;
  let n = 0;
  return {
    sent, now: () => clock, advance: ms => { clock += ms; },
    deps: {db, auth: authApi, key: KEY, linkOrigin: 'https://app.example.test/', now: () => clock,
      token: () => (++n).toString(16).padStart(64, 'a'),
      allow: async () => true, mailer: {send: async m => { sent.push(m); }}},
  };
}

async function reset(uid) {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.recursiveDelete(db.doc(`guardianConsentEvidence/${uid}`));
  await db.doc(`accountDeletions/${uid}`).delete();
  await db.recursiveDelete(db.collection('guardianLimits'));
  for (const row of (await db.collection('guardianTokens').where('uid', '==', uid).get()).docs) await row.ref.delete();
  try { await auth.deleteUser(uid); } catch { /* absent */ }
}

/** A confirmed minor with a real Auth user. Returns both tokens. */
async function confirmedMinor(uid, h, allowSharing) {
  await reset(uid);
  await auth.createUser({uid, email: `${uid}@example.test`, emailVerified: true});
  await guardian.sendLink(req(uid, body()), h.deps);
  const result = await guardian.answerRequest(req('visitor', answer(confirmTokenOf(h.sent.at(-1)),
    allowSharing === undefined ? {} : {allowSharing})), h.deps);
  return {emailManage: manageTokenOf(h.sent.at(-1)), pageManage: result.manageToken, result};
}

// ---- A. Deletion core -------------------------------------------------------------------------

test('deleteUserData keeps the guardian evidence, marks the deletion and removes the account', async () => {
  const uid = 'dm-core'; await reset(uid);
  await auth.createUser({uid});
  await db.doc(`users/${uid}/data/x`).set({a: 1});
  await db.doc(`guardianConsentEvidence/${uid}/responses/r1`).set({action: 'confirm', decidedAt: T0});
  await deletion.deleteUserData(db, auth, uid, 'inactive_24_months', {now: () => T0 + DAY});
  assert.equal((await db.doc(`users/${uid}/data/x`).get()).exists, false);
  assert.deepEqual((await db.doc(`guardianConsentEvidence/${uid}`).get()).data(),
    {accountDeletedAt: T0 + DAY, reason: 'inactive_24_months'});
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}/responses/r1`).get()).exists, true);
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
});

test('an adult with no evidence and no attested purchase gets no marker document', async () => {
  const uid = 'dm-adult'; await reset(uid);
  await auth.createUser({uid});
  await db.doc(`paymongoCheckouts/cs_dm_adult`).set({uid, product: 'pantas_cs_monthly', createdAt: T0});
  await deletion.deleteUserData(db, auth, uid, 'user_request', {now: () => T0});
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}`).get()).exists, false);
  assert.equal((await db.doc('paymongoCheckouts/cs_dm_adult').get()).exists, false, 'the payment index still goes');
});

test('attested checkouts are copied with four fields only; others are not', async () => {
  const uid = 'dm-purchase'; await reset(uid);
  await auth.createUser({uid});
  await db.doc('paymongoCheckouts/cs_dm_a').set({uid, product: 'pantas_cs_monthly', createdAt: T0,
    attestedAt: T0 + 5, termsVersion: '2026-11-12', reference: 'ref-a', sessionPrivate: 'x'});
  await db.doc('paymongoCheckouts/cs_dm_b').set({uid, product: 'pantas_cs_yearly', createdAt: T0});
  await db.doc('paymongoCheckouts/cs_dm_other').set({uid: 'someone-else', attestedAt: T0, termsVersion: 'v', reference: 'r', product: 'p'});
  await deletion.deleteUserData(db, auth, uid, 'guardian_withdrawal', {now: () => T0 + 9});
  assert.deepEqual((await db.doc(`guardianConsentEvidence/${uid}/purchases/cs_dm_a`).get()).data(),
    {attestedAt: T0 + 5, termsVersion: '2026-11-12', reference: 'ref-a', product: 'pantas_cs_monthly'});
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}/purchases/cs_dm_b`).get()).exists, false);
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}/purchases/cs_dm_other`).get()).exists, false);
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}`).get()).get('reason'), 'guardian_withdrawal');
  assert.equal((await db.doc('paymongoCheckouts/cs_dm_a').get()).exists, false);
  await db.doc('paymongoCheckouts/cs_dm_other').delete();
});

test('a retried deletion keeps the first deletion time', async () => {
  const uid = 'dm-retry'; await reset(uid);
  await auth.createUser({uid});
  await db.doc(`guardianConsentEvidence/${uid}/responses/r1`).set({action: 'confirm', decidedAt: T0});
  await db.doc(`guardianConsentEvidence/${uid}`).set({accountDeletedAt: T0, reason: 'guardian_withdrawal'});
  await deletion.deleteUserData(db, auth, uid, 'guardian_withdrawal', {now: () => T0 + DAY});
  assert.equal((await db.doc(`guardianConsentEvidence/${uid}`).get()).get('accountDeletedAt'), T0);
});

test('without a request token, trial markers come from the Auth record and match the callable ones', async () => {
  const uid = 'dm-trial'; await reset(uid);
  const email = 'Trial.Person+x@gmail.com';
  await auth.createUser({uid, email, emailVerified: true});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0, grantId: 'trial'});
  const callerToken = {uid, token: {email, email_verified: true,
    firebase: {sign_in_provider: 'custom', identities: {email: [email.toLowerCase()]}}}};
  const expected = identityMarkers(callerToken, db).map(ref => ref.path);
  for (const path of expected) await db.doc(path).delete();
  await deletion.deleteUserData(db, auth, uid, 'inactive_24_months', {now: () => T0});
  assert.ok(expected.length >= 2);
  for (const path of expected) assert.deepEqual((await db.doc(path).get()).data(), {used: true}, path);
});

test('the callable path still uses the request token', async () => {
  const uid = 'dm-token'; await reset(uid);
  await auth.createUser({uid});
  await db.doc(`users/${uid}/server/trial`).set({usedAt: T0, grantId: 'trial'});
  const caller = {uid, token: {email: 'tok@example.test', email_verified: true,
    firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['dm-token-sub']}}}};
  const expected = identityMarkers(caller, db).map(ref => ref.path);
  await deletion.deleteUserData(db, auth, uid, 'user_request', {requestAuth: caller, now: () => T0});
  for (const path of expected) assert.equal((await db.doc(path).get()).exists, true, path);
});

// ---- B. Manage tokens and callables -----------------------------------------------------------

test('a send mints a no-expiry manage token and the email carries its link', async () => {
  const uid = 'dm-send'; await reset(uid);
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  const manage = manageTokenOf(h.sent[0]);
  assert.notEqual(manage, confirmTokenOf(h.sent[0]));
  assert.ok(h.sent[0].text.includes(`Manage permission (after you confirm): https://app.example.test/guardian/manage?token=${manage}`));
  assert.ok(h.sent[0].html.includes('guardian/manage?token='));
  const row = (await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', manage)}`).get()).data();
  assert.deepEqual(row, {kind: 'manage', uid, state: 'open', createdAt: T0});
  assert.equal(JSON.stringify(await stored(uid)).includes(manage), false, 'the plain token is never stored');
});

test('a resend revokes the earlier manage token and mints a new one', async () => {
  const uid = 'dm-resend'; await reset(uid);
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  h.advance(guardian.SEND_LIMIT.gapMs + 1);
  await guardian.sendLink(req(uid, body()), h.deps);
  const [a, b] = h.sent.map(manageTokenOf);
  const rowA = (await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', a)}`).get()).data();
  assert.equal(rowA.state, 'revoked');
  assert.equal(rowA.revokedAt, h.now());
  assert.equal((await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', b)}`).get()).get('state'), 'open');
  assert.deepEqual(await guardian.readManage(req('v', {token: a}), h.deps), {state: 'unknown'});
});

test('the age check notice version is stored when it matches and refused when it does not', async () => {
  const uid = 'dm-notice'; await reset(uid);
  const h = harness();
  assert.equal(guardian.AGE_CHECK_NOTICE_VERSION, '2026-11-12');
  assert.equal(await code(guardian.sendLink(req(uid, body({ageCheckNoticeVersion: 'old'})), h.deps)), 'invalid-argument');
  assert.equal(await code(guardian.sendLink(req(uid, body({ageCheckNoticeVersion: 5})), h.deps)), 'invalid-argument');
  assert.equal(h.sent.length, 0);
  await guardian.sendLink(req(uid, body({ageCheckNoticeVersion: '2026-11-12'})), h.deps);
  assert.equal((await stored(uid)).ageCheckNoticeVersion, '2026-11-12');
  const other = 'dm-notice2'; await reset(other);
  await guardian.sendLink(req(other, body()), h.deps);
  assert.equal('ageCheckNoticeVersion' in (await stored(other)), false);
});

test('confirming stores the sharing choice, returns a page manage token and keeps the email one', async () => {
  const uid = 'dm-confirm'; await reset(uid);
  const h = harness();
  const {emailManage, pageManage, result} = await confirmedMinor(uid, h, true);
  assert.equal(result.state, 'confirmed');
  assert.match(pageManage, /^[a-f0-9]{64}$/);
  assert.notEqual(pageManage, emailManage);
  assert.equal((await stored(uid)).sharingAllowed, true);
  const evidence = await rows(`guardianConsentEvidence/${uid}/responses`);
  assert.equal(evidence.length, 1);
  assert.equal(evidence[0].sharingAllowed, true);
  const row = (await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', pageManage)}`).get()).data();
  assert.deepEqual(row, {kind: 'manage', uid, state: 'open', createdAt: T0});
  for (const token of [emailManage, pageManage]) {
    assert.deepEqual(await guardian.readManage(req('v', {token}), h.deps), {state: 'active', sharingAllowed: true});
  }
});

test('sharing defaults to off, must be a boolean, and a decline gives no manage token', async () => {
  const uid = 'dm-default'; await reset(uid);
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  const token = confirmTokenOf(h.sent[0]);
  for (const bad of ['yes', 1, null]) {
    assert.equal(await code(guardian.answerRequest(req('v', answer(token, {allowSharing: bad})), h.deps)), 'invalid-argument');
  }
  assert.equal((await stored(uid)).status, 'pending');
  const done = await guardian.answerRequest(req('v', answer(token)), h.deps);
  assert.equal(done.state, 'confirmed');
  assert.equal((await stored(uid)).sharingAllowed, false);
  assert.equal((await rows(`guardianConsentEvidence/${uid}/responses`))[0].sharingAllowed, false);
  const other = 'dm-declined'; await reset(other);
  await guardian.sendLink(req(other, body()), h.deps);
  const declined = await guardian.answerRequest(req('v', answer(confirmTokenOf(h.sent.at(-1)), {decision: 'decline', agreed: false})), h.deps);
  assert.deepEqual(declined, {state: 'declined'});
});

test('the status reports sharing and age group', async () => {
  const uid = 'dm-status'; await reset(uid);
  const h = harness();
  assert.equal((await guardian.getStatus(req(uid, {}), h.deps)).sharingAllowed, false);
  await confirmedMinor(uid, h, true);
  const status = await guardian.getStatus(req(uid, {}), h.deps);
  assert.equal(status.sharingAllowed, true);
  assert.equal(status.ageGroup, 'minor');
});

test('readManage tells apart active, not confirmed and unknown', async () => {
  const uid = 'dm-read'; await reset(uid);
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  const manage = manageTokenOf(h.sent[0]);
  assert.deepEqual(await guardian.readManage(req('v', {token: manage}), h.deps), {state: 'not_confirmed'}, 'pending');
  h.advance(guardian.GUARDIAN_WINDOW_MS + 1);
  assert.deepEqual(await guardian.readManage(req('v', {token: manage}), h.deps), {state: 'not_confirmed'}, 'expired');
  h.advance(-guardian.GUARDIAN_WINDOW_MS);
  await guardian.answerRequest(req('v', answer(confirmTokenOf(h.sent[0]), {decision: 'decline', agreed: false})), h.deps);
  assert.deepEqual(await guardian.readManage(req('v', {token: manage}), h.deps), {state: 'not_confirmed'}, 'declined');
  for (const token of [undefined, '', 'short', 'z'.repeat(64), 'f'.repeat(64), 5, confirmTokenOf(h.sent[0])]) {
    assert.deepEqual(await guardian.readManage(req('v', {token}), h.deps), {state: 'unknown'}, String(token));
  }
  const denied = {...h.deps, allow: async () => false};
  assert.equal(await code(guardian.readManage(req('v', {token: manage}), denied)), 'resource-exhausted');
  assert.equal(await code(guardian.readManage({auth: anon('v'), data: {token: manage}}, h.deps)), 'unauthenticated');
});

test('setGuardianSharing flips the choice and records each change as evidence', async () => {
  const uid = 'dm-share'; await reset(uid);
  const h = harness();
  const {pageManage} = await confirmedMinor(uid, h, false);
  h.advance(DAY);
  assert.equal(await code(guardian.setSharing(req('v', {token: pageManage, allowed: 'yes'}), h.deps)), 'invalid-argument');
  assert.deepEqual(await guardian.setSharing(req('v', {token: pageManage, allowed: true}), h.deps), {state: 'active', sharingAllowed: true});
  assert.equal((await stored(uid)).sharingAllowed, true);
  h.advance(DAY);
  assert.deepEqual(await guardian.setSharing(req('v', {token: pageManage, allowed: false}), h.deps), {state: 'active', sharingAllowed: false});
  assert.equal((await stored(uid)).sharingAllowed, false);
  const log = (await rows(`guardianConsentEvidence/${uid}/responses`)).filter(r => r.action.startsWith('sharing'))
    .sort((a, b) => a.decidedAt - b.decidedAt);
  assert.deepEqual(log, [
    {action: 'sharing_on', decidedAt: T0 + DAY, documentVersions: versions, noticeWordingVersion: '2026-11-12'},
    {action: 'sharing_off', decidedAt: T0 + 2 * DAY, documentVersions: versions, noticeWordingVersion: '2026-11-12'}]);
  const pending = 'dm-share-pending'; await reset(pending);
  await guardian.sendLink(req(pending, body()), h.deps);
  assert.deepEqual(await guardian.setSharing(req('v', {token: manageTokenOf(h.sent.at(-1)), allowed: true}), h.deps), {state: 'not_confirmed'});
  assert.equal('sharingAllowed' in (await stored(pending)), false);
  assert.equal(await code(guardian.setSharing({auth: anon('v'), app: {...app, alreadyConsumed: true}, data: {token: pageManage, allowed: true}}, h.deps)), 'unauthenticated');
});

test('withdrawing disables, signs out, deletes the account and keeps the evidence', async () => {
  const uid = 'dm-withdraw'; await reset(uid);
  const log = [];
  const spy = {getUser: u => auth.getUser(u), deleteUser: u => { log.push('deleteUser'); return auth.deleteUser(u); },
    updateUser: (u, p) => { log.push(['updateUser', p]); return auth.updateUser(u, p); },
    revokeRefreshTokens: u => { log.push('revoke'); return auth.revokeRefreshTokens(u); }};
  const h = harness({authApi: spy});
  const {emailManage, pageManage} = await confirmedMinor(uid, h, true);
  await db.doc(`users/${uid}/data/progress`).set({n: 1});
  h.advance(DAY);
  assert.deepEqual(await guardian.withdraw(req('v', {token: pageManage}), h.deps), {state: 'withdrawn'});
  assert.deepEqual(log, [['updateUser', {disabled: true}], 'revoke', 'deleteUser']);
  assert.equal((await db.doc(`users/${uid}/data/progress`).get()).exists, false);
  assert.equal((await db.doc(`users/${uid}/server/guardianConsent`).get()).exists, false);
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
  const marker = (await db.doc(`guardianConsentEvidence/${uid}`).get()).data();
  assert.deepEqual(marker, {accountDeletedAt: T0 + DAY, reason: 'guardian_withdrawal'});
  const actions = (await rows(`guardianConsentEvidence/${uid}/responses`)).map(r => r.action).sort();
  assert.deepEqual(actions, ['confirm', 'withdraw']);
  const withdraw = (await rows(`guardianConsentEvidence/${uid}/responses`)).find(r => r.action === 'withdraw');
  assert.deepEqual(withdraw, {action: 'withdraw', decidedAt: T0 + DAY, documentVersions: versions, noticeWordingVersion: '2026-11-12'});
  for (const token of [pageManage, emailManage]) {
    assert.deepEqual(await guardian.withdraw(req('v', {token}), h.deps), {state: 'unknown'}, 'a second call');
    assert.deepEqual(await guardian.readManage(req('v', {token}), h.deps), {state: 'unknown'});
  }
});

test('withdrawing needs a confirmed consent', async () => {
  const uid = 'dm-withdraw-pending'; await reset(uid);
  await auth.createUser({uid});
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  assert.deepEqual(await guardian.withdraw(req('v', {token: manageTokenOf(h.sent[0])}), h.deps), {state: 'not_confirmed'});
  assert.equal((await auth.getUser(uid)).disabled, false);
  assert.deepEqual(await rows(`guardianConsentEvidence/${uid}/responses`), []);
});

test('a withdrawal that fails midway can be finished with the same link', async () => {
  const uid = 'dm-withdraw-retry'; await reset(uid);
  let failOnce = true;
  const flaky = {getUser: u => auth.getUser(u), deleteUser: u => auth.deleteUser(u), updateUser: (u, p) => auth.updateUser(u, p),
    revokeRefreshTokens: async u => { if (failOnce) { failOnce = false; throw new Error('down'); } return auth.revokeRefreshTokens(u); }};
  const h = harness({authApi: flaky});
  const {pageManage} = await confirmedMinor(uid, h, false);
  await assert.rejects(guardian.withdraw(req('v', {token: pageManage}), h.deps), /down/);
  assert.equal((await auth.getUser(uid)).disabled, true);
  assert.deepEqual(await guardian.readManage(req('v', {token: pageManage}), h.deps), {state: 'unknown'}, 'the page no longer offers it');
  assert.deepEqual(await guardian.withdraw(req('v', {token: pageManage}), h.deps), {state: 'withdrawn'});
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
  const withdraws = (await rows(`guardianConsentEvidence/${uid}/responses`)).filter(r => r.action === 'withdraw');
  assert.equal(withdraws.length, 1, 'the withdrawal is recorded once');
});

test('a withdrawal whose cleanup fails after the links are deleted is finished by the next daily run', async () => {
  const uid = 'dm-withdraw-durable'; await reset(uid);
  let failOnce = true;
  const flaky = {getUser: u => auth.getUser(u), updateUser: (u, p) => auth.updateUser(u, p),
    revokeRefreshTokens: u => auth.revokeRefreshTokens(u),
    deleteUser: async u => { if (failOnce) { failOnce = false; throw new Error('auth down'); } return auth.deleteUser(u); }};
  const h = harness({authApi: flaky});
  const {pageManage} = await confirmedMinor(uid, h, false);
  await db.doc(`users/${uid}/data/progress`).set({n: 1});
  h.advance(DAY);
  await assert.rejects(guardian.withdraw(req('v', {token: pageManage}), h.deps), /auth down/);
  assert.deepEqual((await db.collection('guardianTokens').where('uid', '==', uid).get()).size, 0, 'the links are gone');
  assert.deepEqual((await db.doc(`accountDeletions/${uid}`).get()).data(), {reason: 'guardian_withdrawal', startedAt: T0 + DAY, nextRetryAt: T0 + DAY + 3600000, attempts: 1,
    reasons: ['guardian_withdrawal'], destructiveAt: T0 + DAY});
  assert.equal((await auth.getUser(uid)).disabled, true);
  await inactive.runInactivityPass({db, auth, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test',
    now: () => T0 + DAY + 2 * 3600000});
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
  assert.equal((await db.doc(`users/${uid}/data/progress`).get()).exists, false);
  assert.deepEqual((await db.doc(`accountDeletions/${uid}`).get()).data(), {});
  assert.deepEqual((await db.doc(`guardianConsentEvidence/${uid}`).get()).data(), {accountDeletedAt: T0 + DAY, reason: 'guardian_withdrawal'});
});

test('a withdrawal records the deletion task in its own transaction, so a failed sign-out still gets deleted', async () => {
  const uid = 'dm-withdraw-task'; await reset(uid);
  const down = {getUser: u => auth.getUser(u), deleteUser: u => auth.deleteUser(u), revokeRefreshTokens: u => auth.revokeRefreshTokens(u),
    updateUser: async () => { throw new Error('auth down'); }};
  const h = harness({authApi: down});
  const {pageManage} = await confirmedMinor(uid, h, false);
  await db.doc(`users/${uid}/data/progress`).set({n: 1});
  h.advance(DAY);
  await assert.rejects(guardian.withdraw(req('v', {token: pageManage}), h.deps), /auth down/);
  assert.equal((await auth.getUser(uid)).disabled, false, 'the sign-out step never ran');
  assert.deepEqual((await db.doc(`accountDeletions/${uid}`).get()).data(),
    {reason: 'guardian_withdrawal', startedAt: T0 + DAY, nextRetryAt: T0 + DAY, reasons: ['guardian_withdrawal']});
  await inactive.runInactivityPass({db, auth, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test',
    now: () => T0 + DAY + 3600000});
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
  assert.equal((await db.doc(`users/${uid}/data/progress`).get()).exists, false);
  assert.deepEqual((await db.doc(`accountDeletions/${uid}`).get()).data(), {});
});

test('a withdrawal keeps an earlier deletion task reason and start time', async () => {
  const uid = 'dm-withdraw-merge'; await reset(uid);
  const h = harness();
  const {pageManage} = await confirmedMinor(uid, h, false);
  await db.doc(`accountDeletions/${uid}`).set({reason: 'inactive_24_months', startedAt: T0 - DAY, nextRetryAt: T0 + 9 * DAY, attempts: 2,
    reasons: ['inactive_24_months']});
  await assert.rejects(guardian.withdraw(req('v', {token: pageManage}), {...h.deps,
    auth: {...auth, getUser: u => auth.getUser(u), updateUser: async () => { throw new Error('auth down'); }}}), /auth down/);
  assert.deepEqual((await db.doc(`accountDeletions/${uid}`).get()).data(), {reason: 'inactive_24_months', startedAt: T0 - DAY,
    nextRetryAt: T0, attempts: 2, reasons: ['inactive_24_months', 'guardian_withdrawal']});
});

test('after a withdrawal the student cannot send a new request or switch to adult, and nothing changes', async () => {
  const uid = 'dm-withdraw-closed'; await reset(uid);
  const down = {getUser: u => auth.getUser(u), deleteUser: u => auth.deleteUser(u), revokeRefreshTokens: u => auth.revokeRefreshTokens(u),
    updateUser: async () => { throw new Error('auth down'); }};
  const h = harness({authApi: down});
  const {pageManage} = await confirmedMinor(uid, h, false);
  await assert.rejects(guardian.withdraw(req('v', {token: pageManage}), h.deps), /auth down/);
  const before = await stored(uid);
  assert.equal(before.status, 'withdrawn');
  const openManage = async () => (await db.collection('guardianTokens').where('uid', '==', uid).where('kind', '==', 'manage')
    .where('state', '==', 'open').get()).size;
  const openBefore = await openManage();
  assert.ok(openBefore >= 1);
  h.advance(DAY);
  assert.equal(await code(guardian.sendLink(req(uid, body({guardianEmail: 'other@gmail.com'})), h.deps)), 'permission-denied');
  assert.equal(await code(guardian.markAdult(req(uid, {}), h.deps)), 'permission-denied');
  assert.deepEqual(await stored(uid), before, 'the record is untouched');
  assert.equal(await openManage(), openBefore, 'the manage links stay open for a retry');
  assert.deepEqual(await guardian.withdraw(req('v', {token: pageManage}), {...h.deps, auth}), {state: 'withdrawn'});
});

test('a pending deletion closes sendLink and markAdult even when the consent record is gone, and withdrawal turns sharing off', async () => {
  const uid = 'dm-task-closed'; await reset(uid);
  const h = harness();
  await db.doc(`accountDeletions/${uid}`).set({reason: 'guardian_withdrawal', startedAt: T0, nextRetryAt: T0, reasons: ['guardian_withdrawal']});
  assert.equal(await code(guardian.sendLink(req(uid, body()), h.deps)), 'permission-denied');
  assert.equal(await code(guardian.markAdult(req(uid, {}), h.deps)), 'permission-denied');
  assert.equal(await stored(uid), undefined);
  const uid2 = 'dm-withdraw-sharing'; await reset(uid2);
  const {pageManage} = await confirmedMinor(uid2, h, true);
  assert.equal((await stored(uid2)).sharingAllowed, true);
  await guardian.withdraw(req('v', {token: pageManage}), {...h.deps, auth: {getUser: u => auth.getUser(u), deleteUser: u => auth.deleteUser(u),
    updateUser: async () => { throw new Error('auth down'); }, revokeRefreshTokens: u => auth.revokeRefreshTokens(u)}}).catch(() => {});
  assert.equal((await stored(uid2)).sharingAllowed, false);
});

test('the daily run signs the student out again before it finishes a withdrawal that failed at the sign-out', async () => {
  const uid = 'dm-retry-signout'; await reset(uid);
  await auth.createUser({uid});
  await db.doc(`users/${uid}/data/progress`).set({n: 1});
  await db.doc(`accountDeletions/${uid}`).set({reason: 'guardian_withdrawal', startedAt: T0, nextRetryAt: T0, reasons: ['guardian_withdrawal']});
  const failing = {listUsers: (...a) => auth.listUsers(...a), getUser: u => auth.getUser(u), updateUser: (u, p) => auth.updateUser(u, p), revokeRefreshTokens: u => auth.revokeRefreshTokens(u),
    deleteUser: async () => { throw new Error('auth down'); }};
  await inactive.runInactivityPass({db, auth: failing, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test', now: () => T0 + 1});
  assert.equal((await auth.getUser(uid)).disabled, true, 'signed out again');
  await inactive.runInactivityPass({db, auth, mailer: {send: async () => {}}, linkOrigin: 'https://app.example.test', now: () => T0 + 2 * 3600000});
  await assert.rejects(auth.getUser(uid), {code: 'auth/user-not-found'});
});

test('an attested order with no checkout record is copied, and an order with a checkout is copied once', async () => {
  const uid = 'dm-orders'; await reset(uid);
  await auth.createUser({uid});
  await db.doc('paymongoOrders/ref-only').set({uid, product: 'pantas_cs_weekly', createdAt: T0, attestedAt: T0 + 7, termsVersion: '2026-11-12', private: 'x'});
  await db.doc('paymongoOrders/ref-both').set({uid, product: 'pantas_cs_monthly', createdAt: T0, attestedAt: T0 + 5, termsVersion: '2026-11-12', sessionId: 'cs_dm_both'});
  await db.doc('paymongoCheckouts/cs_dm_both').set({uid, product: 'pantas_cs_monthly', createdAt: T0, attestedAt: T0 + 5, termsVersion: '2026-11-12', reference: 'ref-both'});
  await db.doc('paymongoOrders/ref-plain').set({uid, product: 'pantas_cs_yearly', createdAt: T0});
  await db.doc('paymongoOrders/ref-other').set({uid: 'someone-else', product: 'pantas_cs_yearly', createdAt: T0, attestedAt: T0, termsVersion: 'v'});
  await deletion.deleteUserData(db, auth, uid, 'user_request', {now: () => T0 + 9});
  const purchases = await db.collection(`guardianConsentEvidence/${uid}/purchases`).get();
  assert.deepEqual(purchases.docs.map(d => d.id).sort(), ['cs_dm_both', 'order-ref-only']);
  assert.deepEqual((await db.doc(`guardianConsentEvidence/${uid}/purchases/order-ref-only`).get()).data(),
    {attestedAt: T0 + 7, termsVersion: '2026-11-12', reference: 'ref-only', product: 'pantas_cs_weekly'});
  assert.deepEqual((await db.doc(`guardianConsentEvidence/${uid}/purchases/cs_dm_both`).get()).data(),
    {attestedAt: T0 + 5, termsVersion: '2026-11-12', reference: 'ref-both', product: 'pantas_cs_monthly'});
  assert.equal((await db.doc('paymongoOrders/ref-only').get()).exists, false, 'the order itself still goes');
  await db.doc('paymongoOrders/ref-other').delete();
});

test('markAdult revokes every manage token, switches once and ends the guardian page', async () => {
  const uid = 'dm-adult-switch'; await reset(uid);
  const h = harness();
  const {emailManage, pageManage} = await confirmedMinor(uid, h, true);
  h.advance(DAY);
  assert.deepEqual(await guardian.markAdult(req(uid, {}), h.deps), {state: 'adult'});
  const consent = await stored(uid);
  assert.equal(consent.ageGroup, 'adult');
  assert.equal(consent.adultSince, T0 + DAY);
  for (const token of [emailManage, pageManage]) {
    const row = (await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', token)}`).get()).data();
    assert.equal(row.state, 'revoked');
    assert.deepEqual(await guardian.readManage(req('v', {token}), h.deps), {state: 'unknown'});
  }
  const became = (await rows(`guardianConsentEvidence/${uid}/responses`)).filter(r => r.action === 'became_adult');
  assert.deepEqual(became, [{action: 'became_adult', decidedAt: T0 + DAY}]);
  assert.equal(await code(guardian.markAdult(req(uid, {}), h.deps)), 'failed-precondition');
  assert.equal((await guardian.getStatus(req(uid, {}), h.deps)).ageGroup, 'adult');
});

test('markAdult writes nothing when the server never knew a minor, and needs the caller', async () => {
  const uid = 'dm-adult-never'; await reset(uid);
  const h = harness();
  assert.deepEqual(await guardian.markAdult(req(uid, {}), h.deps), {state: 'adult'});
  assert.equal((await db.doc(`users/${uid}/server/guardianConsent`).get()).exists, false);
  assert.deepEqual(await rows(`guardianConsentEvidence/${uid}/responses`), []);
  assert.equal(await code(guardian.markAdult({data: {}, auth: anon(uid)}, h.deps)), 'unauthenticated');
  assert.equal(await code(guardian.markAdult({data: {}, app}, h.deps)), 'unauthenticated');
  assert.equal(await code(guardian.markAdult(req(uid, {}), {...h.deps, allow: async () => false})), 'resource-exhausted');
});

test('a student who became an adult cannot be turned back into a minor by a new send', async () => {
  const uid = 'dm-adult-send'; await reset(uid);
  const h = harness();
  await guardian.sendLink(req(uid, body()), h.deps);
  await guardian.markAdult(req(uid, {}), h.deps);
  h.advance(guardian.SEND_LIMIT.gapMs + 1);
  assert.equal(await code(guardian.sendLink(req(uid, body()), h.deps)), 'failed-precondition');
  assert.equal((await stored(uid)).ageGroup, 'adult');
});

test('the cleanup job keeps open manage links and still clears revoked ones', async () => {
  const uid = 'dm-purge'; await reset(uid);
  const h = harness();
  const {emailManage, pageManage} = await confirmedMinor(uid, h, true);
  await guardian.markAdult(req(uid, {}), h.deps);
  const open = 'dm-purge-open'; await reset(open);
  await guardian.sendLink(req(open, body({guardianEmail: 'keep@gmail.com'})), h.deps);
  const keep = guardian.hashValue(KEY, 'token', manageTokenOf(h.sent.at(-1)));
  await guardian.purgeGuardianRecords(db, T0 + 400 * DAY);
  assert.equal((await db.doc(`guardianTokens/${keep}`).get()).exists, true, 'an open manage link has no expiry');
  const revoked = guardian.hashValue(KEY, 'token', emailManage);
  assert.equal((await db.doc(`guardianTokens/${revoked}`).get()).exists, false, 'a revoked one follows the usual rule');
  assert.equal((await db.doc(`guardianTokens/${guardian.hashValue(KEY, 'token', pageManage)}`).get()).exists, false);
});

test('the cleanup job keeps the sharing choice and the adult mark when it trims a confirmed record', async () => {
  const uid = 'dm-minimize'; await reset(uid);
  const h = harness();
  await confirmedMinor(uid, h, true);
  await guardian.purgeGuardianRecords(db, T0 + 9 * DAY);
  assert.deepEqual(await stored(uid), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0, sharingAllowed: true});
  await guardian.markAdult(req(uid, {}), {...h.deps, now: () => T0 + 10 * DAY});
  await db.doc(`users/${uid}/server/guardianConsent`).set({status: 'confirmed', ageGroup: 'adult', adultSince: T0 + 10 * DAY,
    decidedAt: T0, sharingAllowed: false, ageCheckNoticeVersion: '2026-11-09', emailHash: 'x', maskedEmail: 'm***@g***.com',
    tokenHash: 'y', sentAt: T0, expiresAt: T0 + 7 * DAY, createdAt: T0});
  await guardian.purgeGuardianRecords(db, T0 + 20 * DAY);
  assert.deepEqual(await stored(uid), {status: 'confirmed', ageGroup: 'adult', adultSince: T0 + 10 * DAY,
    decidedAt: T0, sharingAllowed: false, ageCheckNoticeVersion: '2026-11-09'});
});

// ---- E. Setup acceptance ----------------------------------------------------------------------

test('the setup acceptance is recorded for a named account with the current version only', async () => {
  const uid = 'dm-accept'; await reset(uid);
  const named = {uid, token: {firebase: {sign_in_provider: 'google.com'}}};
  assert.equal(acceptance.SETUP_ACCEPTANCE_VERSION, '2026-11-09');
  const deps = {db, now: () => T0};
  assert.equal(await code(acceptance.recordAcceptance({auth: named, app, data: {version: 'old'}}, deps)), 'invalid-argument');
  assert.equal(await code(acceptance.recordAcceptance({auth: anon(uid), app, data: {version: '2026-11-09'}}, deps)), 'permission-denied');
  assert.equal(await code(acceptance.recordAcceptance({app, data: {version: '2026-11-09'}}, deps)), 'unauthenticated');
  assert.equal(await code(acceptance.recordAcceptance({auth: named, data: {version: '2026-11-09'}}, deps)), 'unauthenticated');
  assert.equal((await db.doc(`users/${uid}/server/acceptance`).get()).exists, false);
  await acceptance.recordAcceptance({auth: named, app, data: {version: '2026-11-09'}}, deps);
  assert.deepEqual((await db.doc(`users/${uid}/server/acceptance`).get()).data(), {version: '2026-11-09', acceptedAt: T0});
});
