import assert from 'node:assert/strict';
import test from 'node:test';
import {changeBetaPro, BETA_CUTOFF} from '../lib/betaPro.js';

const request = token => ({auth: {uid: 'tester', token}, app: {appId: 'test'},
  data: {enabled: true, examId: 'exam_cse_pro'}});

test('Beta Pro refuses an unverified email before changing grants', async () => {
  const db = {runTransaction: async () => assert.fail('An unverified user must not change grants')};
  await assert.rejects(changeBetaPro(request({email: 'tester@example.com', email_verified: false,
    firebase: {sign_in_provider: 'google.com'}}), {db, auth: {}, allow: async () => true,
    now: () => BETA_CUTOFF - 1000, until: () => BETA_CUTOFF}), {code: 'permission-denied'});
});

const {checkBetaAccess, selectedBetaApplication, BETA_START} = await import('../lib/betaAccess.js');
function applications(rows) {
  return {collection: name => {
    assert.equal(name, 'betaApplications');
    return {where: (field, op, value) => {
      assert.equal(field, 'email'); assert.equal(op, '==');
      assert.equal(value, 'tester@example.com');
      return {get: async () => ({docs: rows.filter(row => row.email === value).map(row => ({get: key => row[key]}))})};
    }};
  }};
}
const verified = {email: ' Tester@Example.COM ', email_verified: true, firebase: {sign_in_provider: 'password'}};
for (const [name, rows, selected] of [
  ['selected', [{email: 'tester@example.com', selected: true}], true],
  ['unselected', [{email: 'tester@example.com', selected: false}], false],
  ['other email', [{email: 'other@example.com', selected: true}], false],
  ['missing', [], false],
  ['nonboolean selection', [{email: 'tester@example.com', selected: 'true'}], false],
  ['later selected application', [{email: 'tester@example.com', selected: false}, {email: 'tester@example.com', selected: true}], true],
]) test(`access checks canonical ${name} application`, async () => {
  assert.deepEqual(await checkBetaAccess(request(verified),
    {db: applications(rows), allow: async () => true, now: () => BETA_START}), {selected});
});
for (const token of [{}, {...verified, email_verified: false}, {...verified, email: ''},
  {...verified, firebase: {sign_in_provider: 'anonymous'}}]) {
  test(`selection fails closed for ${JSON.stringify(token)}`, async () => {
    assert.equal(await selectedBetaApplication(request(token).auth, applications([])), false);
  });
}
test('access rejects missing auth, missing or consumed App Check, and rate limiting', async () => {
  for (const [overrides, allow, code] of [
    [{auth: undefined}, true, 'unauthenticated'], [{app: undefined}, true, 'unauthenticated'],
    [{app: {alreadyConsumed: true}}, true, 'unauthenticated'], [{}, false, 'resource-exhausted'],
  ]) await assert.rejects(checkBetaAccess({...request(verified), ...overrides},
    {db: applications([]), allow: async () => allow}), {code});
});
test('Beta Pro refuses a verified but unselected account in both switch states', async () => {
  for (const enabled of [true, false]) await assert.rejects(changeBetaPro({...request(verified),
    data: {enabled, examId: 'exam_cse_pro'}}, {db: applications([]), auth: {}, allow: async () => true}), {code: 'permission-denied'});
});

test('the beta starts at Nov 9 midnight in the Philippines', () => {
  assert.equal(new Date(BETA_START).toISOString(), '2026-11-08T16:00:00.000Z');
});
const waits = (rows, now) => checkBetaAccess(request(verified),
  {db: applications(rows), allow: async () => true, now: () => now});
const tester = {email: 'tester@example.com', selected: true};
test('a selected tester gets a wait until the start, up to the last millisecond', async () => {
  for (const now of [0, BETA_START - 86_400_000, BETA_START - 1]) {
    assert.deepEqual(await waits([tester], now), {selected: true, waitUntil: BETA_START});
  }
});
test('the wait ends at the start and stays ended', async () => {
  for (const now of [BETA_START, BETA_START + 1, BETA_START + 86_400_000]) {
    assert.deepEqual(await waits([tester], now), {selected: true});
  }
});
test('owner test accounts and the early-access list skip the wait', async () => {
  for (const flag of ['ownerTest', 'earlyAccess']) {
    assert.deepEqual(await waits([{...tester, [flag]: true}], BETA_START - 1), {selected: true});
    assert.deepEqual(await waits([{...tester, [flag]: 'true'}], BETA_START - 1),
      {selected: true, waitUntil: BETA_START}, 'only a real true skips');
    assert.deepEqual(await waits([{...tester, [flag]: false}], BETA_START - 1),
      {selected: true, waitUntil: BETA_START});
  }
});
test('a flag on an application that is not selected skips nothing', async () => {
  assert.deepEqual(await waits([{email: 'tester@example.com', selected: false, ownerTest: true}], BETA_START - 1),
    {selected: false});
  assert.deepEqual(await waits([{email: 'tester@example.com', selected: false, earlyAccess: true}, tester],
    BETA_START - 1), {selected: true, waitUntil: BETA_START});
});
test('an unselected account never gets a wait', async () => {
  assert.deepEqual(await waits([], 0), {selected: false});
});
