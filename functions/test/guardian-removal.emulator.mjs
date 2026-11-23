import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {spawnSync} from 'node:child_process';
import {removeUnconfirmedGuardianRecords, countUndated, summary} from '../scripts/remove_unconfirmed_guardian_records.mjs';
import {purgeGuardianRecords} from '../lib/guardianConsent.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const DAY = 86400000;
const T0 = Date.parse('2026-11-25T10:00:00+08:00');
const consent = uid => db.doc(`users/${uid}/server/guardianConsent`);
const links = async uid => (await db.collection('guardianTokens').where('uid', '==', uid).get()).docs;
const contact = {emailHash: 'e', maskedEmail: 'm***@g***.com', tokenHash: 't', sentAt: T0 - 10 * DAY, createdAt: T0 - 10 * DAY};

async function wipe() {
  await db.recursiveDelete(db.collection('users'));
  await db.recursiveDelete(db.collection('guardianTokens'));
  await db.recursiveDelete(db.collection('guardianConsentEvidence'));
}

async function seed() {
  await wipe();
  // Flag-only record left by the old trim, with a page link that never expires.
  await consent('flag').set({ageGroup: 'minor'});
  await db.doc('guardianTokens/flag-manage').set({kind: 'manage', uid: 'flag', state: 'open', createdAt: T0 - 30 * DAY});
  // Declined, still inside its old seven days, with a used link and a revoked one.
  await consent('declined').set({status: 'declined', ageGroup: 'minor', decidedAt: T0 - DAY, ...contact, expiresAt: T0 + 6 * DAY});
  await db.doc('guardianTokens/declined-used').set({uid: 'declined', state: 'used', usedAt: T0 - DAY, expiresAt: T0 + 6 * DAY});
  await db.doc('guardianTokens/declined-revoked').set({uid: 'declined', state: 'revoked', revokedAt: T0 - 3 * DAY});
  await db.doc('guardianTokens/declined-manage').set({kind: 'manage', uid: 'declined', state: 'open', createdAt: T0 - 5 * DAY});
  // Expired and never answered.
  await consent('expired').set({status: 'pending', ageGroup: 'minor', ...contact, expiresAt: T0 - DAY});
  // An open request that has not expired: kept, and given a cleanup time.
  await consent('open').set({status: 'pending', ageGroup: 'minor', ...contact, expiresAt: T0 + 3 * DAY});
  await db.doc('guardianTokens/open-link').set({uid: 'open', state: 'open', createdAt: T0, expiresAt: T0 + 3 * DAY});
  // A confirmed guardian with contact data still on the record: kept, and given a cleanup time.
  await consent('confirmed').set({status: 'confirmed', ageGroup: 'minor', decidedAt: T0 - 2 * DAY, sharingAllowed: true, ...contact});
  await db.doc('guardianTokens/confirmed-manage').set({kind: 'manage', uid: 'confirmed', state: 'open', createdAt: T0 - 2 * DAY});
  // Already trimmed and confirmed: nothing to do. A withdrawal in progress: untouched.
  await consent('trimmed').set({status: 'confirmed', ageGroup: 'minor', decidedAt: T0 - 20 * DAY, sharingAllowed: false});
  await consent('withdrawn').set({status: 'withdrawn', ageGroup: 'minor', withdrawnAt: T0 - DAY, ...contact});
  await db.doc('users/flag/server/entitlement').set({updatedAt: T0});
  // An adult mark alone is left exactly as it is. An adult with an expired request keeps only the mark.
  await consent('adult').set({ageGroup: 'adult', adultSince: T0 - 3 * DAY});
  await consent('adultpending').set({status: 'pending', ageGroup: 'adult', adultSince: T0 - 8 * DAY, ...contact, expiresAt: T0 - DAY});
  // A confirmation from before answers were timed, still holding contact data.
  await consent('undated').set({status: 'confirmed', ageGroup: 'minor', sharingAllowed: false, ...contact});
  // The old decline evidence, named after the used link row that answered it.
  await db.doc('guardianConsentEvidence/declined/responses/declined-used').set({action: 'decline', decidedAt: T0 - DAY});
  await db.doc('guardianConsentEvidence/confirmed/responses/confirmed-answer').set({action: 'confirm', decidedAt: T0 - 2 * DAY});
}

test('a dry run prints counts and writes nothing', async () => {
  await seed();
  const r = await removeUnconfirmedGuardianRecords({db, live: false, now: () => T0});
  assert.deepEqual({guardianRecords: r.guardianRecords, deleted: r.deleted, scheduled: r.scheduled, kept: r.kept,
    linksRemoved: r.linksRemoved, linksStripped: r.linksStripped},
  {guardianRecords: 10, deleted: 4, scheduled: 3, kept: 3, linksRemoved: 2, linksStripped: 2});
  assert.equal(r.evidenceUnlinked, 1);
  assert.equal(r.serverDocuments, 11);
  assert.ok(r.reads > 0 && r.writes > 0);
  for (const id of ['flag', 'declined', 'expired', 'open', 'confirmed', 'trimmed', 'withdrawn']) {
    assert.equal((await consent(id).get()).exists, true, id);
  }
  assert.equal((await db.collection('guardianTokens').get()).size, 6);
  assert.equal((await db.doc('guardianConsentEvidence/declined/responses/declined-used').get()).exists, true);
  assert.match(summary('demo', false, r), /retry-free estimate: \d+ reads, \d+ writes if run live/);
  assert.equal((await consent('open').get()).get('guardianDueAt'), undefined);
});

test('a live run removes the leftover requests and their links and keeps everything else', async () => {
  await seed();
  const r = await removeUnconfirmedGuardianRecords({db, live: true, now: () => T0});
  assert.equal(r.deleted, 4);
  assert.deepEqual((await consent('adult').get()).data(), {ageGroup: 'adult', adultSince: T0 - 3 * DAY}, 'an adult mark is never touched');
  assert.deepEqual((await consent('adultpending').get()).data(), {ageGroup: 'adult', adultSince: T0 - 8 * DAY}, 'an expired adult request keeps only the mark');
  const old = await db.doc('guardianConsentEvidence/declined/responses/declined-used').get();
  assert.equal(old.exists, false, 'the evidence no longer shares its id with the kept link row');
  const moved = (await db.collection('guardianConsentEvidence/declined/responses').get()).docs;
  assert.deepEqual(moved.map(d => d.get('action')), ['decline']);
  assert.equal((await db.doc('guardianConsentEvidence/confirmed/responses/confirmed-answer').get()).exists, true, 'confirmations are not moved');
  assert.equal((await countUndated({db})).undated, 0, 'every open or untrimmed record now has a cleanup time');
  for (const id of ['flag', 'declined', 'expired']) {
    assert.equal((await consent(id).get()).exists, false, id);
    assert.deepEqual((await links(id)).map(d => d.id).filter(i => i.endsWith('manage') || i === 'open-link'), [], id);
  }
  const used = await db.doc('guardianTokens/declined-used').get();
  assert.equal(used.get('state'), 'used', 'the used link keeps its own seven days');
  assert.equal(used.get('uid'), undefined, 'but no longer names the account');
  assert.equal((await db.doc('guardianTokens/declined-revoked').get()).get('uid'), undefined);
  assert.equal((await db.doc('guardianTokens/flag-manage').get()).exists, false);
  assert.equal((await db.doc('users/flag/server/entitlement').get()).exists, true, 'other server data is untouched');
  assert.equal((await consent('open').get()).get('guardianDueAt'), T0 + 3 * DAY);
  assert.equal((await consent('open').get()).get('status'), 'pending');
  assert.equal((await consent('confirmed').get()).get('guardianDueAt'), T0 - 2 * DAY + 7 * DAY);
  assert.equal((await consent('confirmed').get()).get('status'), 'confirmed');
  assert.deepEqual((await consent('trimmed').get()).data(), {status: 'confirmed', ageGroup: 'minor', decidedAt: T0 - 20 * DAY, sharingAllowed: false});
  assert.equal((await consent('withdrawn').get()).get('status'), 'withdrawn');
  assert.equal((await db.doc('guardianTokens/confirmed-manage').get()).exists, true);
  assert.equal((await db.doc('guardianTokens/open-link').get()).exists, true);
  const again = await removeUnconfirmedGuardianRecords({db, live: true, now: () => T0});
  assert.deepEqual({deleted: again.deleted, scheduled: again.scheduled, writes: again.writes}, {deleted: 0, scheduled: 0, writes: 0}, 'a second run changes nothing');
  await wipe();
});

test('an undated confirmation is scheduled by the script and then trimmed by the cleanup at the same deadline', async () => {
  await seed();
  await removeUnconfirmedGuardianRecords({db, live: true, now: () => T0});
  const due = (await consent('undated').get()).get('guardianDueAt');
  assert.equal(due, T0 + 7 * DAY);
  await purgeGuardianRecords(db, due - 1);
  assert.equal((await consent('undated').get()).get('emailHash'), 'e');
  await purgeGuardianRecords(db, due);
  assert.deepEqual((await consent('undated').get()).data(), {status: 'confirmed', ageGroup: 'minor', sharingAllowed: false});
  await wipe();
});

test('the verify count is above zero before the live run and the script prints only fixed reason codes', async () => {
  await seed();
  assert.equal((await countUndated({db})).undated, 6, 'open, confirmed, undated, declined, expired and the expired adult request');
  await wipe();
  const run = args => spawnSync(process.execPath, ['scripts/remove_unconfirmed_guardian_records.mjs', ...args], {encoding: 'utf8'});
  const bad = run(['--project', 'secret-project-name', '--nonsense', 'maria@example.com']);
  assert.equal(bad.status, 1);
  assert.equal(bad.stderr.trim(), 'REASON usage');
  assert.ok(!bad.stderr.includes('maria') && !bad.stdout.includes('maria'));
});
