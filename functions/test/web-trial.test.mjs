import assert from 'node:assert/strict';
import test from 'node:test';
import {FieldValue} from 'firebase-admin/firestore';
import {listPlans} from '../lib/webPlans.js';
import {startTrial, trialEligible} from '../lib/webTrial.js';
import {changeBetaPro, BETA_CUTOFF} from '../lib/betaPro.js';
import {fakeAuth} from './_paymongo-helpers.mjs';
import {identityMarkers} from '../lib/webTrial.js';
import {assertNamedUser} from '../lib/_audit.js';
import {selectedBetaApplication} from '../lib/betaAccess.js';
import {ensurePublicId} from '../lib/publicId.js';

const NOW = BETA_CUTOFF - 86400000;
const named = uid => ({uid, token: {email: 'tester@example.com', email_verified: true, firebase: {sign_in_provider: 'google.com', identities: {'google.com': ['beta-tester']}}}});

// Keep transaction reads and writes in memory so these tests need no emulator.
function memoryDb() {
  const rows = new Map([['betaApplications/opaque', {email: 'tester@example.com', selected: true}]]);
  let nextId = 0;
  const snapshot = ref => ({ref, id: ref.path.split('/').at(-1), exists: rows.has(ref.path),
    get: key => rows.get(ref.path)?.[key], data: () => rows.get(ref.path)});
  const doc = path => ({path, get: async () => snapshot(doc(path))});
  const collection = path => ({path, collection: true, doc: () => doc(`${path}/${++nextId}`),
    where: (field, op, value) => ({get: async () => ({docs: [...rows.entries()]
      .filter(([key, row]) => key.startsWith(`${path}/`) && row[field] === value)
      .map(([key]) => snapshot(doc(key)))})})});
  const get = async ref => ref.collection
    ? {docs: [...rows.keys()].filter(path => path.startsWith(`${ref.path}/`) &&
        !path.slice(ref.path.length + 1).includes('/')).map(path => snapshot(doc(path)))}
    : snapshot(ref);
  const write = (ref, value, options) => {
    const data = options?.merge ? {...rows.get(ref.path), ...value} : {...value};
    for (const [key, field] of Object.entries(data)) {
      if (field instanceof FieldValue && field.isEqual(FieldValue.delete())) delete data[key];
    }
    rows.set(ref.path, data);
  };
  return {rows, doc, collection, runTransaction: async callback => {
    const writes = [];
    const result = await callback({get, getAll: async (...refs) => Promise.all(refs.map(get)),
      set: (...args) => writes.push(args), create: (...args) => writes.push(args),
      update: (ref, value) => writes.push([ref, value, {merge: true}])});
    for (const args of writes) write(...args);
    return result;
  }};
}

const deps = db => ({db, auth: fakeAuth(), allow: async () => true, now: () => NOW});
const listed = (auth, d) => listPlans(auth, {...d, renewal: async () => false});

for (const state of ['active', 'revoked', 'expired']) {
  test(`${state} beta access preserves the listed trial and its seven days`, async () => {
    const db = memoryDb();
    const auth = named('tester');
    const d = {...deps(db), until: () => BETA_CUTOFF};
    const request = enabled => ({auth, app: {appId: 'test'}, data: {enabled, examId: 'exam_cse_pro'}});
    await changeBetaPro(request(true), d);
    if (state === 'revoked') await changeBetaPro(request(false), d);
    const now = state === 'expired' ? BETA_CUTOFF + 1 : NOW;
    d.now = () => now;
    assert.equal((await listed(auth, d)).trialEligible, true);
    assert.deepEqual(await startTrial(auth, d), {startsAt: now, endsAt: now + 604800000});
    assert.equal((await listed(auth, d)).trialEligible, false);
    await assert.rejects(startTrial(auth, d), {code: 'failed-precondition'});
    assert.equal(db.rows.get('users/tester/grants/trial').source, 'trial');

    // Account deletion leaves the one-use identity record in place.
    for (const path of db.rows.keys()) if (path.startsWith('users/tester/')) db.rows.delete(path);
    const recreated = named('recreated');
    assert.equal(await trialEligible(recreated, db), false);
    await assert.rejects(startTrial(recreated, d), {code: 'failed-precondition'});
  });
}

for (const source of ['paymongo', 'trial', 'unknown', undefined]) {
  test(`beta does not hide previous ${source} grants`, async () => {
    const db = memoryDb();
    const d = deps(db);
    const auth = named('tester');
    await changeBetaPro({auth, app: {appId: 'test'},
      data: {enabled: true, examId: 'exam_cse_pro'}}, {...d, until: () => BETA_CUTOFF});
    db.rows.set('users/tester/grants/previous', {source, product: 'old', state: 'revoked',
      tier: 'civilService', startsAt: 1, endsAt: 2, createdAt: 1});
    assert.equal((await listed(auth, d)).trialEligible, false);
    await assert.rejects(startTrial(auth, d), {code: 'failed-precondition'});
    assert.equal(db.rows.has('users/tester/server/trial'), false);
  });
}

for (const [name, record, pass] of [
  ['subscription', {facts: {sources: [{productId: 'pantas_pro_monthly'}]}}],
  ['purchase', {facts: {purchases: [{productId: 'pantas_pass_cse_pro'}]}}],
  ['pass', {}, {product: 'pantas_pass_cse_pro', state: 'revoked'}],
  ['trial record', {}, null],
]) {
  test(`beta does not hide a previous ${name}`, async () => {
    const db = memoryDb();
    const d = deps(db);
    const auth = named('tester');
    await changeBetaPro({auth, app: {appId: 'test'},
      data: {enabled: true, examId: 'exam_cse_pro'}}, {...d, until: () => BETA_CUTOFF});
    Object.assign(db.rows.get('users/tester/server/entitlement'), record);
    if (pass) db.rows.set('users/tester/passes/old', pass);
    if (name === 'trial record') db.rows.set('users/tester/server/trial', {usedAt: 1});
    assert.equal((await listed(auth, d)).trialEligible, false);
    await assert.rejects(startTrial(auth, d), {code: 'failed-precondition'});
  });
}

for (const record of [{pro: true}, {proUntil: 1}]) {
  test(`legacy Pro claims without beta history still block trials: ${JSON.stringify(record)}`, async () => {
    const db = memoryDb();
    db.rows.set('users/tester/server/entitlement', record);
    assert.equal(await trialEligible(named('tester'), db), false);
    await assert.rejects(startTrial(named('tester'), deps(db)), {code: 'failed-precondition'});
  });
}

// Email code sign-in arrives as provider "custom", with the email read from the user record.
const codeUser = (uid, token = {}) => ({uid, token: {email: 'tester@example.com', email_verified: true,
  firebase: {sign_in_provider: 'custom'}, ...token}});
const identityRows = db => [...db.rows.keys()].filter(path => path.startsWith('trialUsedIdentities/'));

test('a verified-email code sign-in gets the trial, keyed by the email alone', async () => {
  const db = memoryDb();
  const auth = codeUser('coder');
  assert.equal(identityMarkers(auth, db).length, 1);
  assert.equal(await trialEligible(auth, db), true);
  assert.deepEqual(await startTrial(auth, deps(db)), {startsAt: NOW, endsAt: NOW + 604800000});
  assert.equal(identityRows(db).length, 1);
  await assert.rejects(startTrial(auth, deps(db)), {code: 'failed-precondition'});
  // The same address through Google shares the marker, so it cannot take a second trial.
  assert.equal(await trialEligible(named('other'), db), false);
  await assert.rejects(startTrial(named('other'), deps(db)), {code: 'failed-precondition'});
  // The marker is not case sensitive.
  const upper = codeUser('coder2', {email: 'Tester@Example.com'});
  assert.equal(await trialEligible(upper, db), false);
});

test('the Google marker is unchanged: a provider id and the verified email', () => {
  assert.equal(identityMarkers(named('g1'), memoryDb()).length, 2);
  assert.equal(identityMarkers({uid: 'g2', token: {firebase: {sign_in_provider: 'google.com',
    identities: {'google.com': ['g2']}}}}, memoryDb()).length, 1);
});

for (const [name, token] of [
  ['an unverified email', {email_verified: false}],
  ['a missing verified flag', {email_verified: undefined}],
  ['no email', {email: undefined}],
  ['a non-string email', {email: 5}],
]) {
  test(`a code sign-in with ${name} gets no trial`, async () => {
    const db = memoryDb();
    const auth = codeUser('coder', token);
    assert.throws(() => identityMarkers(auth, db), {code: 'failed-precondition'});
    await assert.rejects(trialEligible(auth, db), {code: 'failed-precondition'});
    await assert.rejects(startTrial(auth, deps(db)), {code: 'failed-precondition'});
    assert.equal(identityRows(db).length, 0);
  });
}

test('anonymous and signed-out callers still get no trial', async () => {
  const db = memoryDb();
  const anon = {uid: 'a', token: {email: 'tester@example.com', email_verified: true, firebase: {sign_in_provider: 'anonymous'}}};
  assert.equal(await trialEligible(anon, db), false);
  assert.equal(await trialEligible(undefined, db), false);
  await assert.rejects(startTrial(anon, deps(db)), {code: 'permission-denied'});
  assert.throws(() => identityMarkers(anon, db), {code: 'failed-precondition'});
});

test('other server checks already treat a verified-email code sign-in as a named user', async () => {
  const auth = codeUser('coder');
  assert.equal(assertNamedUser(auth), 'coder');
  assert.equal(await selectedBetaApplication(auth, memoryDb()), true);
  const d = deps(memoryDb());
  assert.deepEqual(await changeBetaPro({auth, app: {appId: 'test'}, data: {enabled: true, examId: 'exam_cse_pro'}},
    {...d, until: () => BETA_CUTOFF}), {enabled: true, betaProUntil: BETA_CUTOFF});
  // Public ids stay a Google-only feature, so a code sign-in gets none.
  assert.equal(await ensurePublicId(memoryDb(), auth), null);
});
