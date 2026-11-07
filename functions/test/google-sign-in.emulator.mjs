import assert from 'node:assert/strict';
import test from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import '../lib/index.js';
import {checkGoogleSignIn} from '../lib/googleSignIn.js';

assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
const auth = getAuth();
const CLIENT = 'client.apps.googleusercontent.com';
const NOW = Date.now();
const info = (sub, email) => ({aud: CLIENT, iss: 'accounts.google.com', email, email_verified: 'true',
  exp: String(Math.floor(NOW / 1000) + 600), sub});
const exchange = (sub, email) => checkGoogleSignIn(
  {auth: {uid: 'anon-caller', token: {firebase: {sign_in_provider: 'anonymous'}}}, app: {appId: 'web'},
    data: {idToken: 'stand-in'}},
  {auth, clientId: CLIENT, now: () => NOW, allow: async () => true,
    fetchTokenInfo: async () => ({status: 200, body: info(sub, email)})});

test('the real Auth service links Google to the existing account once and finds it by that identity', async () => {
  const user = await auth.createUser({email: 'exists@gmail.com', emailVerified: true});
  const {token} = await exchange('sub-1', 'exists@gmail.com');
  assert.equal(typeof token, 'string');
  const linked = await auth.getUserByProviderUid('google.com', 'sub-1');
  assert.equal(linked.uid, user.uid);
  assert.deepEqual(linked.providerData.map(p => p.providerId).sort(), ['google.com']);
  // A second sign-in finds the link and changes nothing.
  await exchange('sub-1', 'exists@gmail.com');
  assert.equal((await auth.getUser(user.uid)).providerData.length, 1);
  assert.equal((await auth.getUser(user.uid)).email, 'exists@gmail.com');
});

test('the real Auth service refuses to give one Google identity to a second account', async () => {
  await auth.createUser({email: 'second@gmail.com', emailVerified: true});
  await assert.rejects(exchange('sub-1', 'second@gmail.com'), {code: 'permission-denied'});
  assert.equal((await auth.getUserByEmail('second@gmail.com')).providerData.length, 0);
});

test('the real Auth service has no account to sign in for a new address, and none is created', async () => {
  await assert.rejects(exchange('sub-new', 'brand-new@gmail.com'), {code: 'permission-denied'});
  await assert.rejects(auth.getUserByEmail('brand-new@gmail.com'), {code: 'auth/user-not-found'});
});
