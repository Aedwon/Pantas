import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import {checkGoogleSignIn} from '../lib/googleSignIn.js';
import {checkSignInCode, sendSignInCode} from '../lib/signInCode.js';

// Local emulator fixture only. Production requires the provisioned Functions secret.
process.env.TRIAL_IDENTITY_HMAC_KEY = 'squatter-emulator-only-hmac-key';

assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
const auth = getAuth();
const db = getFirestore();
const KEY = 'squatter-emulator-key';
const NOW = Date.now();
const app = {appId: 'web'};
const anon = uid => ({uid, token: {firebase: {sign_in_provider: 'anonymous'}}});

/** Mails a real challenge (code 000042) and checks it, with the real Auth service and the real deletion path. */
async function emailSignIn(email, callerUid, at = Date.now()) {
  const sent = [];
  const reply = await sendSignInCode({auth: anon(callerUid), app, data: {email}, rawRequest: {ip: `10.9.${sent.length}.${callerUid.length}`}},
    {db, auth, key: KEY, mailer: {send: async m => { sent.push(m); }}, allow: async () => true, random: () => 42, now: () => at});
  return checkSignInCode({auth: anon(callerUid), app, data: {challengeId: reply.challengeId, code: '000042'}},
    {db, auth, key: KEY, allow: async () => true, now: () => at});
}

const CLIENT = 'client.apps.googleusercontent.com';
const part = value => Buffer.from(JSON.stringify(value)).toString('base64url');
const googleSignIn = (sub, email) => checkGoogleSignIn(
  {auth: anon('anon-google'), app, rawRequest: {ip: '203.0.113.50'}, data: {idToken: `${part({alg: 'RS256'})}.${part({
    aud: CLIENT, iss: 'accounts.google.com', email, exp: Math.floor(NOW / 1000) + 600})}.signature`}},
  {auth, db, key: KEY, clientId: CLIENT, now: () => NOW, allow: async () => true,
    fetchTokenInfo: async () => ({status: 200, body: {aud: CLIENT, iss: 'accounts.google.com', email,
      email_verified: 'true', exp: String(Math.floor(NOW / 1000) + 600), sub}})});

async function squatterWithData(email) {
  const squatter = await auth.createUser({email, password: 'attacker-chosen-1', emailVerified: false});
  await db.doc(`users/${squatter.uid}/server/trial`).set({note: 'data the squatter made'});
  await db.doc(`users/${squatter.uid}/answers/a1`).set({note: 'more data'});
  return squatter;
}

test('email code: the squatter and its data go, the owner gets a new verified account and a token', async () => {
  const squatter = await squatterWithData('victim-code@gmail.com');
  const {token} = await emailSignIn('victim-code@gmail.com', 'caller-code');
  assert.equal(typeof token, 'string');
  const owner = await auth.getUserByEmail('victim-code@gmail.com');
  assert.notEqual(owner.uid, squatter.uid);
  assert.equal(owner.emailVerified, true);
  assert.equal(owner.providerData.length, 0, 'the squatter password is gone');
  await assert.rejects(auth.getUser(squatter.uid), {code: 'auth/user-not-found'});
  assert.equal((await db.doc(`users/${squatter.uid}/answers/a1`).get()).exists, false);
  assert.deepEqual((await db.doc(`accountDeletions/${squatter.uid}`).get()).data(), {}, 'the old uid stays closed');
  assert.equal(JSON.stringify((await db.doc(`accountDeletions/${squatter.uid}`).get()).data()).includes('victim'), false);
  // The owner signs in again as the same new account.
  assert.equal(typeof (await emailSignIn('victim-code@gmail.com', 'caller-code2', Date.now() + 120_000)).token, 'string');
  assert.equal((await auth.getUserByEmail('victim-code@gmail.com')).uid, owner.uid);
});

test('email code: a verified account is untouched', async () => {
  const user = await auth.createUser({email: 'verified-code@gmail.com', password: 'a-long-password-1', emailVerified: true});
  await db.doc(`users/${user.uid}/answers/a1`).set({note: 'kept'});
  await emailSignIn('verified-code@gmail.com', 'caller-v');
  assert.equal((await auth.getUser(user.uid)).email, 'verified-code@gmail.com');
  assert.equal((await db.doc(`users/${user.uid}/answers/a1`).get()).exists, true);
});

test('email code: an unverified account that also has Google, and a disabled one, are refused untouched', async () => {
  const linked = await auth.createUser({email: 'linked-code@gmail.com', emailVerified: false});
  await auth.updateUser(linked.uid, {providerToLink: {providerId: 'google.com', uid: 'g-linked', email: 'linked-code@gmail.com'}});
  const before = await auth.getUser(linked.uid);
  assert.equal(before.emailVerified, false);
  await assert.rejects(emailSignIn('linked-code@gmail.com', 'caller-l'), {code: 'permission-denied'});
  assert.ok(await auth.getUser(linked.uid));
  const off = await auth.createUser({email: 'off-code@gmail.com', password: 'a-long-password-1', disabled: true});
  await assert.rejects(emailSignIn('off-code@gmail.com', 'caller-d'), {code: 'permission-denied'});
  assert.ok(await auth.getUser(off.uid));
});

test('google: the squatter and its data go, and the owner is signed in to a new verified account at once', async () => {
  const squatter = await squatterWithData('victim-google@gmail.com');
  assert.deepEqual(Object.keys(await googleSignIn('sub-victim', 'victim-google@gmail.com')), ['token']);
  await assert.rejects(auth.getUser(squatter.uid), {code: 'auth/user-not-found'});
  assert.equal((await db.doc(`users/${squatter.uid}/answers/a1`).get()).exists, false);
  const owner = await auth.getUserByEmail('victim-google@gmail.com');
  assert.notEqual(owner.uid, squatter.uid);
  assert.equal(owner.emailVerified, true);
  assert.equal((await auth.getUserByProviderUid('google.com', 'sub-victim')).uid, owner.uid);
  // The next Google sign-in finds the link and signs in to the same account.
  assert.deepEqual(Object.keys(await googleSignIn('sub-victim', 'victim-google@gmail.com')), ['token']);
  assert.equal((await auth.getUserByEmail('victim-google@gmail.com')).uid, owner.uid);
});

test('google: a verified account is linked as before, and an unverified Google-linked one is refused untouched', async () => {
  const verified = await auth.createUser({email: 'verified-google@gmail.com', password: 'a-long-password-1', emailVerified: true});
  assert.deepEqual(Object.keys(await googleSignIn('sub-v', 'verified-google@gmail.com')), ['token']);
  assert.equal((await auth.getUserByEmail('verified-google@gmail.com')).uid, verified.uid);
  const linked = await auth.createUser({email: 'linked-google@gmail.com', emailVerified: false});
  await auth.updateUser(linked.uid, {providerToLink: {providerId: 'google.com', uid: 'sub-other', email: 'linked-google@gmail.com'}});
  await assert.rejects(googleSignIn('sub-l', 'linked-google@gmail.com'), {code: 'permission-denied'});
  assert.ok(await auth.getUser(linked.uid));
});

test('email code: two sign-ins for the same squatter end on one verified account', async () => {
  await squatterWithData('race-code@gmail.com');
  const [a, b] = await Promise.allSettled([emailSignIn('race-code@gmail.com', 'caller-r1'), emailSignIn('race-code@gmail.com', 'caller-r2')]);
  assert.ok([a, b].some(r => r.status === 'fulfilled'), JSON.stringify([a, b]));
  const owner = await auth.getUserByEmail('race-code@gmail.com');
  assert.equal(owner.emailVerified, true);
});
