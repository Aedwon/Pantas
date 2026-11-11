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

/**
 * A fake Auth with paging, a delete log and a missing-user error like the real one. The list hands out
 * copies, so a change made after the scan is only seen by a fresh getUser, as with the real service.
 * `hooks.afterList` runs once the page is built; `hooks.afterUpdate` runs after each updateUser.
 */
function fakeAuth(users, pageSize = 2, hooks = {}) {
  const all = [...users];
  const gone = new Set();
  const deleted = [];
  const updates = [];
  const missing = () => Object.assign(new Error('no user'), {code: 'auth/user-not-found'});
  const snapshot = u => Object.defineProperty(Object.defineProperties({}, Object.getOwnPropertyDescriptors(u)),
    'metadata', {value: {...u.metadata}, enumerable: true, writable: true, configurable: true});
  const find = uid => { const found = all.find(u => u.uid === uid); if (!found || gone.has(uid)) throw missing(); return found; };
  return {deleted, updates, all,
    listUsers: async (max, token) => {
      if (hooks.listFails) throw new Error('list down');
      const start = token ? Number(token) : 0;
      const end = Math.min(start + Math.min(max, pageSize), all.length);
      const page = {users: all.slice(start, end).map(snapshot), pageToken: end < all.length ? String(end) : undefined};
      await hooks.afterList?.(all);
      return page;
    },
    getUser: async uid => snapshot(find(uid)),
    updateUser: async (uid, patch) => {
      const found = find(uid);
      updates.push([uid, patch]);
      Object.assign(found, patch);
      await hooks.afterUpdate?.(found, patch);
      return snapshot(found);
    },
    revokeRefreshTokens: async uid => {
      if (hooks.revokeFails) throw new Error('auth down');
      find(uid);
    },
    deleteUser: async uid => {
      if (hooks.deleteFails) throw new Error('auth down');
      find(uid); deleted.push(uid); gone.add(uid);
    },
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
  const auth = fakeAuth(users, 2, over.hooks);
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
  // Start clean: other suites in the same emulator run may leave pending deletion records.
  await db.recursiveDelete(db.collection('accountDeletions'));
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

test('an unverified email gets no mail and is deleted at 730 days, like a guest', async () => {
  // Google sign-in can leave an account whose address Google never verified.
  // Mailing it could reach someone else, so it is not warned; it still ends at 24 months.
  await wipe('in-unverified-old', 'in-unverified-new');
  await db.doc('users/in-unverified-old/server/x').set({a: 1});
  const {auth, box} = await run([
    user('in-unverified-old', {days: 730, email: 'u@mail.com', verified: false}),
    user('in-unverified-new', {days: 729, email: 'v@mail.com', verified: false}),
  ]);
  assert.deepEqual(auth.deleted, ['in-unverified-old']);
  assert.equal(box.sent.length, 0);
  assert.equal((await db.doc('users/in-unverified-old/server/x').get()).exists, false);
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
const clear = async () => { await db.recursiveDelete(db.collection('guardianConsentEvidence')); await db.doc('jobState/evidencePurge').delete(); };
const purge = (users, now, budget) => inactive.purgeExpiredEvidence({db, auth: fakeAuth(users), now: () => now, ...(budget ? {budget} : {})});
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

// ---- Audit fixes: the deletion race, durable deletion, the cap, evidence safety ----------------

const pending = uid => db.doc(`accountDeletions/${uid}`);
const wipeTasks = async (...uids) => { for (const uid of uids) await pending(uid).delete(); };
const HOUR = 3600000;

test('a Pro claim that appears between the scan and the delete prevents the deletion', async () => {
  await wipe('in-race-pro');
  const claims = {pro: true, proUntil: NOW + DAY};
  const {auth, result} = await run([user('in-race-pro', {days: 800})],
    {hooks: {afterList: all => { all[0].customClaims = claims; }}});
  assert.deepEqual(auth.deleted, []);
  assert.equal(result.deleted, 0);
  assert.equal(auth.all[0].disabled, false, 'never disabled');
});

test('activity that appears before the disable prevents the deletion and leaves the user enabled', async () => {
  await wipe('in-race-active', 'in-race-warned');
  await inactivity('in-race-warned').set({warnedAt: NOW - 40 * DAY});
  const fresh = () => ago(1);
  const {auth} = await run([user('in-race-active', {days: 800}), user('in-race-warned', {days: 800, email: 'w@mail.com'})],
    {hooks: {afterList: all => { for (const u of all) u.metadata.lastRefreshTime = fresh(); }}});
  assert.deepEqual(auth.deleted, []);
  assert.deepEqual(auth.updates, []);
  assert.equal(auth.all.every(u => u.disabled === false), true);
});

test('a guest that gains a verified address after the scan is not deleted without a warning', async () => {
  await wipe('in-race-mail');
  const {auth} = await run([user('in-race-mail', {days: 800})],
    {hooks: {afterList: all => { all[0].email = 'late@mail.com'; all[0].emailVerified = true; }}});
  assert.deepEqual(auth.deleted, []);
  assert.deepEqual(auth.updates, []);
});

test('a warned account whose last use falls after the warning is not deleted, even if still idle for 730 days', async () => {
  await wipe('in-race-warn');
  // The scan saw activity 800 days ago and a warning 760 days ago. By the fresh read the account was used 740
  // days ago: still over 730 idle days, but after the warning, so the warning no longer counts.
  await inactivity('in-race-warn').set({warnedAt: NOW - 760 * DAY});
  const {auth} = await run([user('in-race-warn', {days: 800, email: 'w@mail.com'})],
    {hooks: {afterList: all => { all[0].metadata.lastRefreshTime = ago(740); }}});
  assert.deepEqual(auth.deleted, []);
  assert.deepEqual(auth.updates, []);
});

test('activity or Pro that appears after the disable re-enables the user and skips the deletion', async () => {
  await wipe('in-after-disable');
  const {auth, result} = await run([user('in-after-disable', {days: 800})],
    {hooks: {afterUpdate: (found, patch) => { if (patch.disabled === true) found.customClaims = {pro: true, proUntil: NOW + DAY}; }}});
  assert.deepEqual(auth.deleted, []);
  assert.equal(result.deleted, 0);
  assert.deepEqual(auth.updates.map(([, patch]) => patch), [{disabled: true}, {disabled: false}]);
  assert.equal(auth.all[0].disabled, false);
});

test('a failure after the disable and before the deletion starts gives the account back', async () => {
  await wipe('in-revoke-fails');
  const {auth, result} = await run([user('in-revoke-fails', {days: 800})], {hooks: {revokeFails: true}});
  assert.deepEqual(auth.deleted, []);
  assert.equal(result.deleted, 0);
  assert.equal(auth.all[0].disabled, false, 'not left locked');
  assert.equal((await db.doc('accountDeletions/in-revoke-fails').get()).exists, false);
});

test('a deletion that goes ahead disables the user first, then deletes', async () => {
  await wipe('in-order');
  const {auth} = await run([user('in-order', {days: 800})]);
  assert.deepEqual(auth.updates, [['in-order', {disabled: true}]]);
  assert.deepEqual(auth.deleted, ['in-order']);
});

test('the cap counts attempts, so failing Auth deletions stop at 200 attempts', async () => {
  const ids = Array.from({length: 205}, (_, i) => `in-capfail${i}`);
  await wipe(...ids); await wipeTasks(...ids);
  const {auth, result} = await run(ids.map(id => user(id, {days: 800})), {hooks: {deleteFails: true}});
  assert.equal(auth.updates.filter(([, patch]) => patch.disabled === true).length, 200);
  assert.equal(result.deleted, 0);
  assert.equal((await db.collection('accountDeletions').where('startedAt', '==', NOW).get()).size >= 200, true);
  await wipeTasks(...ids);
});

test('a failed deletion leaves a durable record, and the next daily run finishes it', async () => {
  await wipe('in-durable'); await wipeTasks('in-durable');
  await db.doc('users/in-durable/server/x').set({a: 1});
  const first = await run([user('in-durable', {days: 800})], {hooks: {deleteFails: true}});
  assert.deepEqual(first.auth.deleted, []);
  const task = (await pending('in-durable').get()).data();
  assert.deepEqual(task, {reason: 'inactive_24_months', startedAt: NOW, nextRetryAt: NOW + HOUR, attempts: 1,
    reasons: ['inactive_24_months'], destructiveAt: NOW});
  // Fifty-nine minutes later nothing is retried yet.
  const early = await run([user('in-durable', {days: 800, disabled: true})], {now: () => NOW + HOUR - 60000});
  assert.deepEqual(early.auth.deleted, []);
  // The next day the disabled account is still in the list, and the record gets it finished.
  const later = await run([user('in-durable', {days: 801, disabled: true})], {now: () => NOW + DAY});
  assert.deepEqual(later.auth.deleted, ['in-durable']);
  assert.equal(later.result.deleted, 1);
  assert.deepEqual((await pending('in-durable').get()).data(), {closedUntil: NOW + DAY + 2 * HOUR, nextRetryAt: NOW + DAY + 2 * HOUR});
});

test('a pending deletion for a user that is already gone finishes cleanup and keeps a closure marker', async () => {
  await wipe('in-gone'); await wipeTasks('in-gone');
  await pending('in-gone').set({reason: 'guardian_withdrawal', startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, attempts: 1});
  await db.doc('users/in-gone/data/x').set({a: 1});
  const {result} = await run([]);
  assert.equal((await db.doc('users/in-gone/data/x').get()).exists, false);
  assert.deepEqual((await pending('in-gone').get()).data(), {closedUntil: NOW + 2 * HOUR, nextRetryAt: NOW + 2 * HOUR});
  assert.equal(result.deleted, 1);
});

test('an unfinished deletion keeps its record and counts another attempt', async () => {
  await wipe('in-twice'); await wipeTasks('in-twice');
  await pending('in-twice').set({reason: 'user_request', startedAt: NOW - 3 * HOUR, nextRetryAt: NOW - 2 * HOUR, attempts: 1});
  await run([user('in-twice', {days: 10, disabled: true})], {hooks: {deleteFails: true}});
  assert.deepEqual((await pending('in-twice').get()).data(), {reason: 'user_request', startedAt: NOW - 3 * HOUR, nextRetryAt: NOW + HOUR, attempts: 2,
    reasons: ['user_request'], destructiveAt: NOW});
  await wipeTasks('in-twice'); await wipe('in-twice');
});

test('a stalled inactivity deletion is dropped and the account given back if Pro is now running', async () => {
  await wipe('in-paid-retry'); await wipeTasks('in-paid-retry');
  await db.doc('users/in-paid-retry/server/x').set({a: 1});
  await pending('in-paid-retry').set({reason: 'inactive_24_months', startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, attempts: 1});
  const {auth, result} = await run([user('in-paid-retry', {days: 800, disabled: true, claims: {pro: true, proUntil: NOW + DAY}})]);
  assert.deepEqual(auth.deleted, []);
  assert.equal(result.deleted, 0);
  assert.equal(auth.all[0].disabled, false);
  assert.equal((await pending('in-paid-retry').get()).exists, false);
  assert.equal((await db.doc('users/in-paid-retry/server/x').get()).exists, true);
});

test('with paid access running, a stalled deletion is still finished once data was removed or a guardian asked', async () => {
  const ids = ['in-paid-started', 'in-paid-withdrawn'];
  await wipe(...ids); await wipeTasks(...ids);
  await pending('in-paid-started').set({reason: 'inactive_24_months', reasons: ['inactive_24_months'],
    startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, destructiveAt: NOW - 2 * HOUR, attempts: 1});
  await pending('in-paid-withdrawn').set({reason: 'inactive_24_months', reasons: ['inactive_24_months', 'guardian_withdrawal'],
    startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, attempts: 1});
  const paid = {pro: true, proUntil: NOW + DAY};
  const {auth} = await run(ids.map(id => user(id, {days: 800, disabled: true, claims: paid})));
  assert.deepEqual(auth.deleted.sort(), [...ids].sort());
  assert.equal(auth.updates.some(([, patch]) => patch.disabled === false), false, 'never given back');
});

test('a task that keeps failing moves to the back, so the others still get their turn', async () => {
  const ids = ['in-rot0', 'in-rot1'];
  await wipe(...ids); await wipeTasks(...ids);
  await pending('in-rot0').set({reason: 'user_request', startedAt: NOW - 5 * HOUR, nextRetryAt: NOW - 4 * HOUR, attempts: 3});
  await pending('in-rot1').set({reason: 'user_request', startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, attempts: 1});
  const users = () => [user('in-rot0', {days: 10, disabled: true}), user('in-rot1', {days: 10, disabled: true})];
  const first = await run(users(), {retryCap: 1, hooks: {deleteFails: true}});
  assert.equal((await pending('in-rot0').get()).get('attempts'), 4, 'oldest tried first');
  const second = await run(users(), {retryCap: 1, now: () => NOW + DAY});
  assert.deepEqual(second.auth.deleted, ['in-rot1'], 'the newer task is not starved');
  assert.deepEqual(first.auth.deleted, []);
  await wipeTasks(...ids);
});

test('pending deletions count against the deletion cap', async () => {
  const ids = ['in-pcap0', 'in-pcap1', 'in-pcap2'];
  await wipe(...ids); await wipeTasks(...ids);
  for (const id of ids) await pending(id).set({reason: 'inactive_24_months', startedAt: NOW - 2 * HOUR, nextRetryAt: NOW - HOUR, attempts: 1});
  const {result} = await run([], {deletionCap: 2});
  assert.equal(result.deleted, 2);
  assert.equal((await db.collection('accountDeletions').where('reason', '==', 'inactive_24_months')
    .where('startedAt', '==', NOW - 2 * HOUR).get()).size, 1);
  await wipeTasks(...ids);
});

test('evidence is kept while its account survives, even with a marker older than ten years', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  await db.doc('guardianConsentEvidence/ev-marked-live').set({accountDeletedAt: decided, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-marked-live/responses/r1').set({action: 'confirm', decidedAt: decided});
  await purge([user('ev-marked-live', {days: 1})], evidenceNow(decided) + 100 * DAY);
  assert.equal(await exists('ev-marked-live'), true);
  assert.deepEqual((await db.doc('guardianConsentEvidence/ev-marked-live').get()).data(), {accountDeletedAt: decided, reason: 'user_request'});
});

function throwingUser(uid) {
  const u = user(uid, {days: 800});
  Object.defineProperty(u, 'customClaims', {get() { throw new Error('entitlement read failed'); }, enumerable: true, configurable: true});
  return u;
}

test('one user whose read throws does not stop the next user or the evidence purge', async () => {
  await clear(); await wipe('in-throw', 'in-next');
  const decided = NOW - (3653 + 1) * DAY;
  await db.doc('guardianConsentEvidence/ev-after-throw').set({accountDeletedAt: decided, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-after-throw/responses/r1').set({action: 'confirm', decidedAt: decided});
  const auth = fakeAuth([throwingUser('in-throw'), user('in-next', {days: 800})]);
  await inactive.runDailyPass({db, auth, mailer: mailbox().mailer, now: () => NOW, linkOrigin: 'https://app.test'});
  assert.deepEqual(auth.deleted, ['in-next']);
  assert.equal(await exists('ev-after-throw'), false);
});

test('the evidence purge runs even when the whole inactivity pass throws', async () => {
  await clear();
  const decided = NOW - (3653 + 1) * DAY;
  await db.doc('guardianConsentEvidence/ev-after-list').set({accountDeletedAt: decided, reason: 'user_request'});
  await db.doc('guardianConsentEvidence/ev-after-list/responses/r1').set({action: 'confirm', decidedAt: decided});
  const auth = fakeAuth([], 2, {listFails: true});
  await inactive.runDailyPass({db, auth, mailer: mailbox().mailer, now: () => NOW, linkOrigin: 'https://app.test'});
  assert.equal(await exists('ev-after-list'), false);
});

test('the evidence purge pages with a budget and a saved cursor: three runs of two cover five parents', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  const ids = ['ev-pg1', 'ev-pg2', 'ev-pg3', 'ev-pg4', 'ev-pg5'];
  for (const id of ids) {
    await db.doc(`guardianConsentEvidence/${id}`).set({accountDeletedAt: decided, reason: 'user_request'});
    await db.doc(`guardianConsentEvidence/${id}/responses/r1`).set({action: 'confirm', decidedAt: decided});
  }
  const left = async () => (await Promise.all(ids.map(exists))).filter(Boolean).length;
  const at = evidenceNow(decided);
  assert.equal(await purge([], at, 2), 2);
  assert.equal(await left(), 3);
  assert.equal(await purge([], at, 2), 2);
  assert.equal(await left(), 1);
  assert.equal(await purge([], at, 2), 1);
  assert.equal(await left(), 0);
  assert.equal((await db.doc('jobState/evidencePurge').get()).get('cursor') ?? null, null, 'wrapped to the start');
});

test('the saved cursor skips parents already covered and wraps when a page is short', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  const ids = ['ev-cu1', 'ev-cu2', 'ev-cu3'];
  for (const id of ids) {
    await db.doc(`guardianConsentEvidence/${id}`).set({accountDeletedAt: decided, reason: 'user_request'});
    await db.doc(`guardianConsentEvidence/${id}/responses/r1`).set({action: 'confirm', decidedAt: decided});
  }
  // Live accounts are kept, so each run's coverage shows in the cursor and not in deletions.
  const live = ids.map(id => user(id, {days: 1}));
  await purge(live, evidenceNow(decided), 2);
  assert.equal((await db.doc('jobState/evidencePurge').get()).get('cursor'), 'ev-cu2');
  await purge(live, evidenceNow(decided), 2);
  assert.equal((await db.doc('jobState/evidencePurge').get()).get('cursor') ?? null, null);
});

test('legacy parents with no marker are found by paging the responses, within the same budget', async () => {
  await clear();
  const decided = Date.parse('2026-11-09T10:00:00+08:00');
  const ids = ['ev-lg1', 'ev-lg2', 'ev-lg3'];
  for (const id of ids) await db.doc(`guardianConsentEvidence/${id}/responses/r1`).set({action: 'confirm', decidedAt: decided});
  const marked = async () => (await Promise.all(ids.map(id => db.doc(`guardianConsentEvidence/${id}`).get()))).filter(d => d.exists).length;
  await purge([], decided + 30 * DAY, 2);
  assert.equal(await marked(), 2);
  assert.equal(typeof (await db.doc('jobState/evidencePurge').get()).get('legacyCursor'), 'string');
  await purge([], decided + 30 * DAY, 2);
  assert.equal(await marked(), 3);
  assert.equal(await exists('ev-lg1'), true, 'kept: the ten years have not passed');
});
