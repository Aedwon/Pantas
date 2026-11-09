import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import * as inactive from '../lib/purgeInactiveAccounts.js';

// Local emulator fixture only. Production requires the provisioned Functions secret.
process.env.TRIAL_IDENTITY_HMAC_KEY = 'inactivity-emulator-only-hmac-key';

const db = getFirestore();
const DAY = 86400000;
const NOW = Date.parse('2028-06-01T12:00:00+08:00');
const ago = days => new Date(NOW - days * DAY).toUTCString();
const inactivity = uid => db.doc(`users/${uid}/server/inactivity`);

function user(uid, {days, refreshDays, email, verified = true, disabled = false, claims, providers} = {}) {
  return {uid, email, emailVerified: email ? verified : false, disabled, customClaims: claims,
    providerData: providers ?? (email ? [{providerId: 'google.com', uid: `${uid}-sub`, email}] : []),
    metadata: {creationTime: ago(900), lastSignInTime: ago(days),
      ...(refreshDays === undefined ? {} : {lastRefreshTime: ago(refreshDays)})}};
}

/** A fake Auth with paging, a delete log and a missing-user error like the real one. */
function fakeAuth(users, pageSize = 2) {
  const all = [...users];
  const gone = new Set();
  const deleted = [];
  const missing = () => Object.assign(new Error('no user'), {code: 'auth/user-not-found'});
  return {deleted,
    listUsers: async (max, token) => {
      const start = token ? Number(token) : 0;
      const end = Math.min(start + Math.min(max, pageSize), all.length);
      return {users: all.slice(start, end), pageToken: end < all.length ? String(end) : undefined};
    },
    getUser: async uid => { const found = all.find(u => u.uid === uid); if (!found || gone.has(uid)) throw missing(); return found; },
    deleteUser: async uid => { deleted.push(uid); gone.add(uid); },
  };
}
function mailbox({failFor} = {}) {
  const sent = [];
  return {sent, mailer: {send: async message => {
    if (failFor === 'all' || failFor === message.to) throw new Error('Guardian mail is not configured.');
    sent.push(message);
  }}};
}
const run = (users, over = {}) => {
  const auth = fakeAuth(users);
  const box = mailbox(over);
  const pass = inactive.runInactivityPass({db, auth, mailer: box.mailer, now: () => NOW, linkOrigin: 'https://app.test', ...over});
  return pass.then(result => ({result, auth, box}));
};
const wipe = async (...uids) => { for (const uid of uids) { await db.recursiveDelete(db.doc(`users/${uid}`)); await db.recursiveDelete(db.doc(`guardianConsentEvidence/${uid}`)); } };

test('the inactivity limit is 24 months as 730 days, with the warning at 700', () => {
  assert.equal(inactive.INACTIVE_DAYS, 730);
  assert.equal(inactive.WARN_DAYS, 700);
  assert.equal(inactive.WARNING_GRACE_DAYS, 30);
});

test('an account at 22 months is left alone', async () => {
  await wipe('in-22');
  const {result, box, auth} = await run([user('in-22', {days: 670, email: 'a@mail.com'})]);
  assert.equal(box.sent.length, 0);
  assert.deepEqual(auth.deleted, []);
  assert.equal((await inactivity('in-22').get()).exists, false);
  assert.deepEqual({warned: result.warned, deleted: result.deleted}, {warned: 0, deleted: 0});
});

test('at 23 months the account is warned once, and a second run sends nothing', async () => {
  await wipe('in-23');
  const users = [user('in-23', {days: 700, email: 'a@mail.com'})];
  const first = await run(users);
  assert.equal(first.box.sent.length, 1);
  const mail = first.box.sent[0];
  assert.equal(mail.to, 'a@mail.com');
  assert.equal(mail.subject, 'Your Pantas account will be deleted on Jul 1, 2028');
  assert.deepEqual((await inactivity('in-23').get()).data(), {warnedAt: NOW});
  const second = await run(users);
  assert.equal(second.box.sent.length, 0);
  assert.deepEqual(second.auth.deleted, []);
});

test('a warning gets its full 30 days, even when the job first runs late', async () => {
  await wipe('in-late', 'in-due', 'in-early');
  const late = await run([user('in-late', {days: 800, email: 'a@mail.com'})]);
  assert.equal(late.box.sent.length, 1, 'no warning yet, so it warns instead of deleting');
  assert.deepEqual(late.auth.deleted, []);
  await inactivity('in-due').set({warnedAt: NOW - 30 * DAY});
  await inactivity('in-early').set({warnedAt: NOW - 30 * DAY + 1});
  const due = await run([user('in-due', {days: 760, email: 'b@mail.com'}), user('in-early', {days: 760, email: 'c@mail.com'})]);
  assert.deepEqual(due.auth.deleted, ['in-due']);
  assert.equal(due.box.sent.length, 0);
  assert.equal(due.result.deleted, 1);
});

test('a deletion needs 730 days of inactivity as well as the warning', async () => {
  await wipe('in-short');
  await inactivity('in-short').set({warnedAt: NOW - 40 * DAY});
  const {auth, box} = await run([user('in-short', {days: 729.5, email: 'a@mail.com'})]);
  assert.deepEqual(auth.deleted, []);
  assert.equal(box.sent.length, 0, 'warned already');
});

test('activity after a warning cancels the deletion, and a later idle spell warns again', async () => {
  await wipe('in-back', 'in-again');
  await inactivity('in-back').set({warnedAt: NOW - 35 * DAY});
  const back = await run([user('in-back', {days: 800, refreshDays: 10, email: 'a@mail.com'})]);
  assert.deepEqual(back.auth.deleted, []);
  assert.equal(back.box.sent.length, 0);
  await inactivity('in-again').set({warnedAt: NOW - 710 * DAY});
  const again = await run([user('in-again', {days: 705, email: 'b@mail.com'})]);
  assert.equal(again.box.sent.length, 1, 'the old warning is older than the last use');
  assert.equal((await inactivity('in-again').get()).get('warnedAt'), NOW);
});

test('the later of sign-in and refresh counts as the last use', async () => {
  await wipe('in-refresh');
  const {auth, box} = await run([user('in-refresh', {days: 900, refreshDays: 100, email: 'a@mail.com'})]);
  assert.deepEqual(auth.deleted, []);
  assert.equal(box.sent.length, 0);
});

test('accounts with Pro access running are skipped, by claim or by grant', async () => {
  await wipe('in-claim', 'in-grant', 'in-expired');
  await db.doc('users/in-grant/grants/g1').set({state: 'active', endsAt: NOW + DAY, product: 'x'});
  await db.doc('users/in-expired/grants/g1').set({state: 'active', endsAt: NOW - DAY, product: 'x'});
  await inactivity('in-claim').set({warnedAt: NOW - 60 * DAY});
  const {auth, box} = await run([
    user('in-claim', {days: 800, email: 'a@mail.com', claims: {pro: true, proUntil: NOW + DAY}}),
    user('in-grant', {days: 800, email: 'b@mail.com'}),
    user('in-expired', {days: 800, email: 'c@mail.com', claims: {pro: true, proUntil: NOW - DAY}}),
  ]);
  assert.deepEqual(auth.deleted, []);
  assert.deepEqual(box.sent.map(m => m.to), ['c@mail.com'], 'only the lapsed one is warned');
});

test('disabled accounts are skipped', async () => {
  await wipe('in-disabled');
  const {auth, box} = await run([user('in-disabled', {days: 900, email: 'a@mail.com', disabled: true})]);
  assert.deepEqual(auth.deleted, []);
  assert.equal(box.sent.length, 0);
});

test('an account with no email is deleted at 730 days without any mail, and not before', async () => {
  await wipe('in-anon-old', 'in-anon-new');
  await db.doc('users/in-anon-old/server/x').set({a: 1});
  const {auth, box} = await run([user('in-anon-old', {days: 730}), user('in-anon-new', {days: 729})]);
  assert.deepEqual(auth.deleted, ['in-anon-old']);
  assert.equal(box.sent.length, 0);
  assert.equal((await db.doc('users/in-anon-old/server/x').get()).exists, false);
});

test('an unverified email is neither warned nor deleted', async () => {
  await wipe('in-unverified');
  const {auth, box} = await run([user('in-unverified', {days: 900, email: 'u@mail.com', verified: false})]);
  assert.deepEqual(auth.deleted, []);
  assert.equal(box.sent.length, 0);
});

test('a mail failure records no warning and the pass goes on', async () => {
  await wipe('in-fail', 'in-after');
  const {result, auth, box} = await run([user('in-fail', {days: 710, email: 'bad@mail.com'}), user('in-after', {days: 800})],
    {failFor: 'bad@mail.com'});
  assert.equal((await inactivity('in-fail').get()).exists, false);
  assert.equal(box.sent.length, 0);
  assert.deepEqual(auth.deleted, ['in-after']);
  assert.equal(result.warned, 0);
  const none = await run([user('in-fail', {days: 710, email: 'bad@mail.com'})], {failFor: 'all'});
  assert.equal((await inactivity('in-fail').get()).exists, false, 'not configured');
  assert.equal(none.result.warned, 0);
});

test('deletions and warnings stop at their caps', async () => {
  const ids = Array.from({length: 5}, (_, i) => `in-cap${i}`);
  await wipe(...ids, ...ids.map(i => `${i}w`));
  const del = await run(ids.map(id => user(id, {days: 800})), {deletionCap: 2});
  assert.equal(del.auth.deleted.length, 2);
  assert.equal(del.result.deleted, 2);
  const warnUsers = ids.map(id => user(`${id}w`, {days: 710, email: `${id}@mail.com`}));
  const warn = await run(warnUsers, {warningCap: 3});
  assert.equal(warn.box.sent.length, 3);
  assert.equal(inactive.DELETIONS_PER_RUN, 200);
  assert.equal(inactive.WARNINGS_PER_RUN, 500);
});

test('the real deletion path leaves guardian evidence and the deletion reason', async () => {
  await wipe('in-evidence');
  await db.doc('guardianConsentEvidence/in-evidence/responses/r').set({action: 'confirm', decidedAt: NOW - 800 * DAY});
  await run([user('in-evidence', {days: 800})]);
  assert.deepEqual((await db.doc('guardianConsentEvidence/in-evidence').get()).data(),
    {accountDeletedAt: NOW, reason: 'inactive_24_months'});
});

// ---- Evidence purge ---------------------------------------------------------------------------

const YEARS10 = 3653 * DAY;
const evidenceNow = decidedAt => decidedAt + YEARS10;
const clear = () => db.recursiveDelete(db.collection('guardianConsentEvidence'));
const purge = (users, now) => inactive.purgeExpiredEvidence({db, auth: fakeAuth(users), now: () => now});
const exists = uid => db.doc(`guardianConsentEvidence/${uid}`).listCollections().then(async c =>
  (await db.doc(`guardianConsentEvidence/${uid}`).get()).exists || (await Promise.all(c.map(x => x.limit(1).get()))).some(s => !s.empty));

test('evidence is kept until ten years after the newest answer, then deleted', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  await db.doc('guardianConsentEvidence/ev-a').set({accountDeletedAt: decided + DAY, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-a/responses/r1').set({action: 'confirm', decidedAt: decided});
  await db.doc('guardianConsentEvidence/ev-a/responses/r2').set({action: 'withdraw', decidedAt: decided - 5 * DAY});
  await purge([], evidenceNow(decided) - DAY);
  assert.equal(await exists('ev-a'), true, 'ten years minus a day');
  await purge([], evidenceNow(decided) - 1);
  assert.equal(await exists('ev-a'), true);
  await purge([], evidenceNow(decided));
  assert.equal(await exists('ev-a'), false, 'at ten years');
  await db.doc('guardianConsentEvidence/ev-b').set({accountDeletedAt: decided, reason: 'x'});
  await db.doc('guardianConsentEvidence/ev-b/responses/r1').set({action: 'confirm', decidedAt: decided});
  await purge([], evidenceNow(decided) + DAY);
  assert.equal(await exists('ev-b'), false, 'ten years plus a day');
});

test('a later purchase attestation moves the end date', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  const bought = decided + 400 * DAY;
  await db.doc('guardianConsentEvidence/ev-p').set({accountDeletedAt: bought, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-p/responses/r1').set({action: 'confirm', decidedAt: decided});
  await db.doc('guardianConsentEvidence/ev-p/purchases/cs_1').set({attestedAt: bought, termsVersion: 'v', reference: 'r', product: 'p'});
  await purge([], evidenceNow(decided) + DAY);
  assert.equal(await exists('ev-p'), true, 'the purchase is newer');
  await purge([], evidenceNow(bought));
  assert.equal(await exists('ev-p'), false);
});

test('an account that still exists keeps its evidence however old', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  await db.doc('guardianConsentEvidence/ev-live/responses/r1').set({action: 'confirm', decidedAt: decided});
  await purge([user('ev-live', {days: 1})], evidenceNow(decided) + 100 * DAY);
  assert.equal(await exists('ev-live'), true);
  assert.equal((await db.doc('guardianConsentEvidence/ev-live').get()).exists, false, 'no marker for a live account');
});

test('old evidence with no marker gets one when the account is gone, and keeps the ten-year clock', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  await db.doc('guardianConsentEvidence/ev-legacy/responses/r1').set({action: 'confirm', decidedAt: decided});
  await purge([], decided + 30 * DAY);
  assert.deepEqual((await db.doc('guardianConsentEvidence/ev-legacy').get()).data(), {accountDeletedAt: decided + 30 * DAY, reason: 'legacy'});
  assert.equal(await exists('ev-legacy'), true);
  await purge([], evidenceNow(decided) - DAY);
  assert.equal(await exists('ev-legacy'), true);
  await purge([], evidenceNow(decided));
  assert.equal(await exists('ev-legacy'), false);
});

test('the daily run does both jobs', async () => {
  await clear(); await wipe('in-daily');
  const decided = NOW - (3653 + 1) * DAY;
  await db.doc('guardianConsentEvidence/ev-daily').set({accountDeletedAt: decided, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-daily/responses/r1').set({action: 'confirm', decidedAt: decided});
  const box = mailbox();
  const auth = fakeAuth([user('in-daily', {days: 800})]);
  await inactive.runDailyPass({db, auth, mailer: box.mailer, now: () => NOW, linkOrigin: 'https://app.test'});
  assert.equal(await exists('ev-daily'), false);
  assert.deepEqual(auth.deleted, ['in-daily']);
});
