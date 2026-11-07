import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {checkGoogleSignIn} from '../lib/googleSignIn.js';

const CLIENT = 'client-id.apps.googleusercontent.com';
const EMAIL = 'maria@gmail.com';
const SUB = '1234567890';
const NOW = 1_700_000_000_000;
const caller = (provider = 'anonymous', uid = 'anon1') =>
  ({uid, token: {firebase: {sign_in_provider: provider}}});
const req = (data, overrides = {}) => ({auth: caller(), app: {appId: 'web'}, data, ...overrides});

/** What Google's tokeninfo returns for a good token. All values are strings, as Google sends them. */
const goodInfo = (changes = {}) => ({
  aud: CLIENT, iss: 'https://accounts.google.com', email: EMAIL, email_verified: 'true',
  exp: String(NOW / 1000 + 600), sub: SUB, ...changes,
});

const account = (changes = {}) =>
  ({uid: 'maria', email: EMAIL, emailVerified: true, disabled: false, providerData: [], ...changes});

function fakeAuth(users = {maria: account()}) {
  const calls = [];
  const notFound = () => Object.assign(new Error('nope'), {code: 'auth/user-not-found'});
  const all = () => Object.values(users);
  return {
    calls, users,
    getUserByEmail: async email => { const u = all().find(x => x.email === email); if (!u) throw notFound(); return u; },
    getUserByProviderUid: async (providerId, uid) => {
      const u = all().find(x => x.providerData.some(p => p.providerId === providerId && p.uid === uid));
      if (!u) throw notFound();
      return u;
    },
    updateUser: async (uid, props) => {
      calls.push(['updateUser', uid, props]);
      users[uid].providerData = [...users[uid].providerData, props.providerToLink];
      return users[uid];
    },
    createCustomToken: async uid => `token-for-${uid}`,
  };
}

/** A tokeninfo stand-in. The tests never reach Google. */
function rig({users, info = goodInfo(), status = 200, clientId = CLIENT, allow = async () => true} = {}) {
  const auth = fakeAuth(users);
  const fetched = [];
  const deps = {
    auth, clientId, now: () => NOW, allow,
    fetchTokenInfo: async idToken => {
      fetched.push(idToken);
      return {status, body: info};
    },
  };
  return {auth, fetched, deps, run: (data = {idToken: 'google-id-token'}, overrides = {}) =>
    checkGoogleSignIn(req(data, overrides), deps)};
}

const refused = async (promise, code) => assert.rejects(promise, {code});

// ---------------------------------------------------------------- success

test('a verified Google address that has an account links Google once and returns a token', async () => {
  const r = rig();
  assert.deepEqual(await r.run(), {token: 'token-for-maria'});
  assert.deepEqual(r.auth.calls, [['updateUser', 'maria', {providerToLink: {
    providerId: 'google.com', uid: SUB, email: EMAIL}}]]);
  assert.deepEqual(r.fetched, ['google-id-token']);
  // The next time the link is there, so nothing is written again.
  assert.deepEqual(await r.run(), {token: 'token-for-maria'});
  assert.equal(r.auth.calls.length, 1);
});

test('an account that already has this Google identity is not changed', async () => {
  const r = rig({users: {maria: account({providerData: [{providerId: 'google.com', uid: SUB}]})}});
  assert.deepEqual(await r.run(), {token: 'token-for-maria'});
  assert.deepEqual(r.auth.calls, []);
});

test('the address is trimmed and lower cased before it is looked up', async () => {
  const r = rig({info: goodInfo({email: ' Maria@Gmail.COM '})});
  assert.deepEqual(await r.run(), {token: 'token-for-maria'});
  assert.equal(r.auth.calls[0][2].providerToLink.email, EMAIL);
});

test('both Google issuer spellings are accepted', async () => {
  for (const iss of ['accounts.google.com', 'https://accounts.google.com']) {
    assert.deepEqual(await rig({info: goodInfo({iss})}).run(), {token: 'token-for-maria'}, iss);
  }
});

test('a signed-in non-anonymous caller is also accepted, like the code flow', async () => {
  const r = rig();
  assert.deepEqual(await r.run({idToken: 'x'}, {auth: caller('password', 'u9')}), {token: 'token-for-maria'});
});

// ---------------------------------------------------------- token checks

test('every wrong or missing Google claim is refused and nothing is linked', async () => {
  const bad = {
    'wrong audience': goodInfo({aud: 'someone-elses-client'}),
    'missing audience': goodInfo({aud: undefined}),
    'wrong issuer': goodInfo({iss: 'https://evil.example.com'}),
    'missing issuer': goodInfo({iss: undefined}),
    'unverified email': goodInfo({email_verified: 'false'}),
    'email_verified as a boolean': goodInfo({email_verified: true}),
    'missing email_verified': goodInfo({email_verified: undefined}),
    'expired': goodInfo({exp: String(NOW / 1000 - 1)}),
    'expires right now': goodInfo({exp: String(NOW / 1000)}),
    'missing exp': goodInfo({exp: undefined}),
    'exp is not a number': goodInfo({exp: 'soon'}),
    'missing sub': goodInfo({sub: undefined}),
    'empty sub': goodInfo({sub: ''}),
    'missing email': goodInfo({email: undefined}),
    'empty email': goodInfo({email: ''}),
  };
  for (const [name, info] of Object.entries(bad)) {
    const r = rig({info});
    await refused(r.run(), 'permission-denied');
    assert.deepEqual(r.auth.calls, [], name);
  }
  for (const body of [null, 'text', 5, []]) {
    await refused(rig({info: body}).run(), 'permission-denied');
  }
});

test('Google answering with anything but 200 is a refusal, or unavailable when Google is down', async () => {
  for (const status of [400, 401, 403, 404]) await refused(rig({status}).run(), 'permission-denied');
  for (const status of [201, 204, 302]) await refused(rig({status}).run(), 'permission-denied');
  for (const status of [429, 500, 503]) await refused(rig({status}).run(), 'unavailable');
});

test('a failed or timed out request to Google is unavailable', async () => {
  const r = rig();
  r.deps.fetchTokenInfo = async () => { throw new Error('timeout'); };
  await refused(r.run(), 'unavailable');
});

test('an empty client id setting refuses every call before Google is asked', async () => {
  const r = rig({clientId: ''});
  await refused(r.run(), 'failed-precondition');
  assert.deepEqual(r.fetched, []);
});

// ------------------------------------------------- who Google speaks for

test('a verified non-Gmail address with no hd claim is refused, because Google is not authoritative for it', async () => {
  const r = rig({info: goodInfo({email: 'maria@yahoo.com'}), users: {maria: account({email: 'maria@yahoo.com'})}});
  await refused(r.run(), 'permission-denied');
  assert.deepEqual(r.auth.calls, []);
});

test('googlemail.com and gmail.com addresses are accepted without an hd claim', async () => {
  for (const email of ['maria@googlemail.com', 'Maria@GMAIL.com']) {
    const r = rig({info: goodInfo({email}), users: {maria: account({email: email.toLowerCase()})}});
    assert.deepEqual(await r.run(), {token: 'token-for-maria'}, email);
  }
});

test('a Workspace address is accepted when hd equals its domain, ignoring case', async () => {
  for (const hd of ['school.edu.ph', 'School.EDU.ph']) {
    const r = rig({info: goodInfo({email: 'maria@school.edu.ph', hd}),
      users: {maria: account({email: 'maria@school.edu.ph'})}});
    assert.deepEqual(await r.run(), {token: 'token-for-maria'}, hd);
  }
});

test('an hd claim that differs from the address domain is refused', async () => {
  for (const hd of ['other.edu.ph', 'edu.ph', 'xschool.edu.ph', '', 5]) {
    const r = rig({info: goodInfo({email: 'maria@school.edu.ph', hd}),
      users: {maria: account({email: 'maria@school.edu.ph'})}});
    await refused(r.run(), 'permission-denied');
    assert.deepEqual(r.auth.calls, [], String(hd));
  }
});

test('an hd claim does not make a Gmail address depend on it', async () => {
  const r = rig({info: goodInfo({hd: 'something-else.com'})});
  assert.deepEqual(await r.run(), {token: 'token-for-maria'});
});

// -------------------------------------------------------------- accounts

test('an address with no account is refused, so no account is made here', async () => {
  const r = rig({users: {}});
  await refused(r.run(), 'permission-denied');
  assert.deepEqual(r.auth.calls, []);
});

test('a disabled account and an account with an unverified address are refused untouched', async () => {
  for (const changes of [{disabled: true}, {emailVerified: false}]) {
    const r = rig({users: {maria: account(changes)}});
    await refused(r.run(), 'permission-denied');
    assert.deepEqual(r.auth.calls, []);
  }
});

test('an account whose address differs after normalization is refused', async () => {
  const r = rig({users: {maria: account({email: 'MARIA@gmail.com'})}});
  r.auth.getUserByEmail = async () => account({email: 'someone.else@gmail.com'});
  await refused(r.run(), 'permission-denied');
  assert.deepEqual(r.auth.calls, []);
});

test('a Google identity linked to another account is refused', async () => {
  const r = rig({users: {
    maria: account(),
    other: account({uid: 'other', email: 'other@gmail.com', providerData: [{providerId: 'google.com', uid: SUB}]}),
  }});
  await refused(r.run(), 'permission-denied');
  assert.deepEqual(r.auth.calls, []);
});

test('an account linked to a different Google identity is refused', async () => {
  const r = rig({users: {maria: account({providerData: [{providerId: 'google.com', uid: 'another-sub'}]})}});
  await refused(r.run(), 'permission-denied');
  assert.deepEqual(r.auth.calls, []);
});

test('a link that loses a race to another sign-in is a refusal', async () => {
  const r = rig();
  r.auth.updateUser = async () => { throw Object.assign(new Error('taken'), {code: 'auth/uid-already-exists'}); };
  await refused(r.run(), 'permission-denied');
});

test('other Auth errors are not hidden', async () => {
  const r = rig();
  r.auth.getUserByEmail = async () => { throw Object.assign(new Error('down'), {code: 'auth/internal-error'}); };
  await assert.rejects(r.run(), {code: 'auth/internal-error'});
});

test('a failed token creation is unavailable and says nothing about the account', async () => {
  const r = rig();
  r.auth.createCustomToken = async () => { throw new Error('no permission'); };
  await assert.rejects(r.run(), error => error.code === 'unavailable' && !/maria|google-id-token/.test(error.message));
});

// ------------------------------------------------------ caller and input

test('an unauthenticated call, or one without App Check, or a replayed token is refused', async () => {
  const r = rig();
  await refused(r.run({idToken: 'x'}, {auth: undefined}), 'unauthenticated');
  await refused(r.run({idToken: 'x'}, {app: {appId: 'web', alreadyConsumed: true}}), 'unauthenticated');
  assert.deepEqual(r.fetched, []);
});

test('the input is exactly one text id token of 4096 characters or fewer', async () => {
  for (const data of [null, 'x', 7, [], {}, {idToken: ''}, {idToken: 5}, {idToken: ['a']},
    {idToken: 'x'.repeat(4097)}, {idToken: 'x', extra: 1}, {idToken: 'x', email: EMAIL}]) {
    const r = rig();
    await refused(r.run(data), 'invalid-argument');
    assert.deepEqual(r.fetched, [], JSON.stringify(data)?.slice(0, 40));
  }
  assert.deepEqual(await rig().run({idToken: 'x'.repeat(4096)}), {token: 'token-for-maria'});
});

test('the rate limit is ten tries in ten minutes per caller and stops the call before Google is asked', async () => {
  const seen = [];
  const r = rig({allow: async (...args) => { seen.push(args); return false; }});
  await refused(r.run(), 'resource-exhausted');
  assert.deepEqual(seen, [['anon1', 'googleExchange', 10, 10 * 60_000]]);
  assert.deepEqual(r.fetched, []);
});

// ------------------------------------------------------------- deployment

test('the callable is deployed with App Check, a used-once token and the timing wrapper', () => {
  const source = readFileSync(new URL('../src/googleSignIn.ts', import.meta.url), 'utf8');
  assert.match(source, /export const exchangeGoogleSignIn = onCall\(/);
  assert.match(source, /region: 'asia-southeast1'/);
  assert.match(source, /enforceAppCheck: enforceAppCheck/);
  assert.match(source, /consumeAppCheckToken: enforceAppCheck/);
  assert.match(source, /timed\('exchangeGoogleSignIn'/);
  assert.match(source, /defineString\('GOOGLE_WEB_CLIENT_ID'/);
  const index = readFileSync(new URL('../src/index.ts', import.meta.url), 'utf8');
  assert.match(index, /exchangeGoogleSignIn[^;]*from '\.\/googleSignIn\.js'/);
});

test('production names the Google web client id and staging and dev leave it empty', () => {
  const env = name => readFileSync(new URL(`../${name}`, import.meta.url), 'utf8');
  assert.match(env('.env.pantas-prod'),
    /^GOOGLE_WEB_CLIENT_ID=416041343210-48rd2t4jivmdt7s1jbkoleobuadq9olj\.apps\.googleusercontent\.com$/m);
  assert.doesNotMatch(env('.env.pantas-staging'), /GOOGLE_WEB_CLIENT_ID/);
});

test('the id token is never written to a log', () => {
  const source = readFileSync(new URL('../src/googleSignIn.ts', import.meta.url), 'utf8');
  for (const line of source.split('\n').filter(l => /logger\.|console\./.test(l))) {
    assert.doesNotMatch(line, /\b(idToken|email|uid|sub|user)\b/, line);
  }
});
