import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import test from 'node:test';
import {checkSignInCode, codeDocId, hashCode, normalizeEmail, sendSignInCode,
  signInCodeMessage} from '../lib/signInCode.js';

const KEY = 'test-key';
const EMAIL = 'maria@example.com';
const caller = (provider = 'anonymous', uid = 'anon1') =>
  ({uid, token: {firebase: {sign_in_provider: provider}}});
const req = (data, overrides = {}) => ({auth: caller(), app: {appId: 'web'}, data, ...overrides});

/** A Firestore stand-in with the three things the code uses: doc, runTransaction, get/set(merge). */
function fakeDb() {
  const rows = new Map();
  const db = {
    rows,
    doc: path => ({path}),
    runTransaction: async fn => fn({
      get: async ref => ({exists: rows.has(ref.path), get: field => rows.get(ref.path)?.[field]}),
      set: (ref, data, options) => rows.set(ref.path, options?.merge ? {...rows.get(ref.path), ...data} : {...data}),
    }),
  };
  return db;
}

function fakeAuth(users = {}) {
  const calls = [];
  const byEmail = email => Object.values(users).find(u => u.email === email);
  return {
    calls, users,
    getUserByEmail: async email => {
      const user = byEmail(email);
      if (!user) throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'});
      return user;
    },
    createUser: async props => { calls.push(['createUser', props]); const uid = `new${calls.length}`; users[uid] = {uid, disabled: false, ...props}; return users[uid]; },
    updateUser: async (uid, props) => {
      calls.push(['updateUser', uid, props]);
      if (props.email && byEmail(props.email) && byEmail(props.email).uid !== uid) throw Object.assign(new Error('dup'), {code: 'auth/email-already-exists'});
      users[uid] = {...(users[uid] ?? {uid}), ...props};
      return users[uid];
    },
    createCustomToken: async uid => `token-for-${uid}`,
  };
}

function sender(fail = false) {
  const sent = [];
  return {sent, send: async message => { if (fail) throw new Error('provider down'); sent.push(message); }};
}

function sendDeps(overrides = {}) {
  const db = overrides.db ?? fakeDb();
  const mailer = overrides.mailer ?? sender();
  let t = 1_000_000;
  const clock = {now: () => t, advance: ms => { t += ms; }};
  return {db, mailer, clock, deps: {db, key: KEY, mailer, now: clock.now, random: () => 42,
    allow: async () => true, ...overrides.deps}};
}

const storedDoc = db => db.rows.get(`signInCodes/${codeDocId(EMAIL)}`);

test('invalid emails are refused', async () => {
  for (const bad of [undefined, null, 5, '', 'no-at', 'a@b', 'a b@c.com', 'a@c.c', `${'x'.repeat(250)}@a.com`]) {
    await assert.rejects(() => sendSignInCode(req({email: bad}), sendDeps().deps), {code: 'invalid-argument'}, String(bad));
  }
  assert.equal(normalizeEmail('  Maria@Example.COM '), EMAIL);
});

test('a send stores the code only as a keyed hash and mails the plain code', async () => {
  const {db, mailer, deps} = sendDeps();
  const result = await sendSignInCode(req({email: ' Maria@Example.com'}), deps);
  assert.deepEqual(result, {resendAfterSeconds: 60});
  const row = storedDoc(db);
  assert.equal(row.codeHash, hashCode(KEY, EMAIL, '000042'));
  assert.ok(!JSON.stringify(row).includes('000042'));
  assert.ok(!JSON.stringify(row).includes('maria'));
  assert.equal(row.attempts, 0);
  assert.equal(row.expiresAt.getTime(), 1_000_000 + 10 * 60_000);
  assert.ok(db.rows.has(`signInCodes/${createHash('sha256').update(EMAIL).digest('hex')}`));
  assert.equal(mailer.sent.length, 1);
  assert.equal(mailer.sent[0].to, EMAIL);
  assert.equal(mailer.sent[0].subject, '000042 is your Pantas sign-in code');
  assert.ok(mailer.sent[0].text.includes('Your sign-in code'));
  assert.ok(mailer.sent[0].text.includes('It expires in 10 minutes. If you didn\'t try to sign in to Pantas, ignore this email.'));
  assert.ok(mailer.sent[0].html.includes('letter-spacing'));
});

test('the email escapes values and uses the app palette without em dashes', () => {
  const m = signInCodeMessage({to: EMAIL, code: '<b>1'});
  assert.ok(!m.html.includes('<b>1'));
  assert.ok(m.html.includes('&lt;b&gt;1'));
  const clean = signInCodeMessage({to: EMAIL, code: '123456'});
  for (const color of ['#1D1D1F', '#6E6E73', '#0B7A68']) assert.ok(clean.html.includes(color), color);
  assert.ok(!/—/.test(clean.text + clean.html));
});

test('a second request inside 60 seconds does not send and reports the wait', async () => {
  const {mailer, clock, deps} = sendDeps();
  await sendSignInCode(req({email: EMAIL}), deps);
  clock.advance(20_000);
  assert.deepEqual(await sendSignInCode(req({email: EMAIL}), deps), {resendAfterSeconds: 40});
  assert.equal(mailer.sent.length, 1);
  clock.advance(40_000);
  assert.deepEqual(await sendSignInCode(req({email: EMAIL}), deps), {resendAfterSeconds: 60});
  assert.equal(mailer.sent.length, 2);
});

test('a new send replaces the old code and resets tries', async () => {
  const {db, clock, deps} = sendDeps();
  await sendSignInCode(req({email: EMAIL}), deps);
  await db.runTransaction(async t => t.set(db.doc(`signInCodes/${codeDocId(EMAIL)}`), {attempts: 3}, {merge: true}));
  clock.advance(61_000);
  await sendSignInCode(req({email: EMAIL}), {...deps, random: () => 7});
  assert.equal(storedDoc(db).codeHash, hashCode(KEY, EMAIL, '000007'));
  assert.equal(storedDoc(db).attempts, 0);
});

test('the sixth send in an hour is refused, and the window reopens after an hour', async () => {
  const {mailer, clock, deps} = sendDeps();
  for (let i = 0; i < 5; i += 1) { await sendSignInCode(req({email: EMAIL}), deps); clock.advance(61_000); }
  await assert.rejects(() => sendSignInCode(req({email: EMAIL}), deps), {code: 'resource-exhausted'});
  assert.equal(mailer.sent.length, 5);
  clock.advance(3_600_000);
  assert.deepEqual(await sendSignInCode(req({email: EMAIL}), deps), {resendAfterSeconds: 60});
});

test('the per-caller limit refuses before anything is stored or sent', async () => {
  const seen = [];
  const {db, mailer, deps} = sendDeps({deps: {allow: async (...args) => { seen.push(args); return false; }}});
  await assert.rejects(() => sendSignInCode(req({email: EMAIL}), deps), {code: 'resource-exhausted'});
  assert.deepEqual(seen, [['anon1', 'signInCodeSend', 10, 3_600_000]]);
  assert.equal(db.rows.size, 0);
  assert.equal(mailer.sent.length, 0);
});

test('a mail failure clears the code, keeps the counters and reports unavailable', async () => {
  const {db, deps} = sendDeps({mailer: sender(true)});
  await assert.rejects(() => sendSignInCode(req({email: EMAIL}), deps), {code: 'unavailable'});
  assert.equal(storedDoc(db).codeHash, null);
  assert.equal(storedDoc(db).sendCount, 1);
  // The failed send gives its place in the day's cap back.
  assert.equal(db.rows.get('signInLimits/global-1970-01-01').count, 0);
});

test('requests need a signed-in caller and a fresh App Check token', async () => {
  const {deps} = sendDeps();
  for (const overrides of [{auth: undefined}, {app: undefined}, {app: {alreadyConsumed: true}}]) {
    await assert.rejects(() => sendSignInCode(req({email: EMAIL}, overrides), deps), {code: 'unauthenticated'});
    await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '123456'}, overrides),
      verifyHarness().deps), {code: 'unauthenticated'});
  }
});

// -------------------------------------------------------------- verify

function verifyHarness({users = {}, mail} = {}) {
  const sendSide = sendDeps(mail ? {mailer: mail} : {});
  const auth = fakeAuth(users);
  return {...sendSide, auth, deps: {db: sendSide.db, auth, key: KEY, now: sendSide.clock.now, allow: async () => true},
    send: () => sendSignInCode(req({email: EMAIL}), sendSide.deps)};
}

test('a wrong code counts down, and the fifth wrong try blanks the code', async () => {
  const h = verifyHarness();
  await h.send();
  for (const triesLeft of [4, 3, 2, 1, 0]) {
    await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '111111'}), h.deps),
      error => error.code === 'invalid-argument' && error.details.reason === 'wrong' && error.details.triesLeft === triesLeft);
  }
  assert.equal(storedDoc(h.db).codeHash, null);
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps),
    error => error.code === 'not-found' && error.details.reason === 'expired');
  assert.equal(h.auth.calls.length, 0);
});

test('a locked document reports too many tries', async () => {
  const h = verifyHarness();
  await h.send();
  await h.db.runTransaction(async t => t.set(h.db.doc(`signInCodes/${codeDocId(EMAIL)}`), {attempts: 5}, {merge: true}));
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps),
    error => error.code === 'resource-exhausted' && error.details.reason === 'tooManyTries');
});

test('a missing or expired code reports expired, and an expired one is blanked', async () => {
  const h = verifyHarness();
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps),
    error => error.code === 'not-found' && error.details.reason === 'expired');
  await h.send();
  h.clock.advance(10 * 60_000 + 1);
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps),
    error => error.code === 'not-found' && error.details.reason === 'expired');
  assert.equal(storedDoc(h.db).codeHash, null);
});

test('the code must be exactly six digits and the caller limit applies', async () => {
  const h = verifyHarness();
  for (const bad of ['12345', '1234567', 'abcdef', '12 456', 123456, null, undefined]) {
    await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: bad}), h.deps), {code: 'invalid-argument'}, String(bad));
  }
  const seen = [];
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '123456'}),
    {...h.deps, allow: async (...args) => { seen.push(args); return false; }}), {code: 'resource-exhausted'});
  assert.deepEqual(seen, [['anon1', 'signInCodeVerify', 30, 600_000]]);
});

test('the right code is single use and an anonymous caller keeps its uid', async () => {
  const h = verifyHarness({users: {anon1: {uid: 'anon1', disabled: false}}});
  await h.send();
  assert.deepEqual(await checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {token: 'token-for-anon1'});
  assert.deepEqual(h.auth.calls, [['updateUser', 'anon1', {email: EMAIL, emailVerified: true}]]);
  assert.equal(storedDoc(h.db).codeHash, null);
  assert.equal(storedDoc(h.db).sendCount, 1);
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {code: 'not-found'});
});

test('an existing account is signed in as itself, and its email is marked verified', async () => {
  const h = verifyHarness({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: false, disabled: false}, anon1: {uid: 'anon1'}}});
  await h.send();
  assert.deepEqual(await checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {token: 'token-for-u9'});
  assert.deepEqual(h.auth.calls, [['updateUser', 'u9', {emailVerified: true}]]);
  assert.equal(h.auth.users.anon1.email, undefined);
});

test('a verified existing account needs no update', async () => {
  const h = verifyHarness({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: false}}});
  await h.send();
  await checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps);
  assert.deepEqual(h.auth.calls, []);
});

test('a disabled account is refused', async () => {
  const h = verifyHarness({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: true}}});
  await h.send();
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {code: 'permission-denied'});
});

test('a signed-in non-anonymous caller creates a new account for a new email', async () => {
  const h = verifyHarness();
  await h.send();
  const result = await checkSignInCode(req({email: EMAIL, code: '000042'}, {auth: caller('google.com', 'g1')}), h.deps);
  assert.match(result.token, /^token-for-new/);
  assert.deepEqual(h.auth.calls[0], ['createUser', {email: EMAIL, emailVerified: true}]);
});

test('a lost race on the email falls back to the account that won', async () => {
  const h = verifyHarness({users: {anon1: {uid: 'anon1'}}});
  await h.send();
  const original = h.auth.updateUser;
  h.auth.updateUser = async (uid, props) => {
    h.auth.users.u7 = {uid: 'u7', email: EMAIL, emailVerified: true, disabled: false};
    return original(uid, props);
  };
  let first = true;
  const lookup = h.auth.getUserByEmail;
  h.auth.getUserByEmail = async email => {
    if (first) { first = false; throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'}); }
    return lookup(email);
  };
  assert.deepEqual(await checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {token: 'token-for-u7'});
});

test('a token failure reports unavailable', async () => {
  const h = verifyHarness();
  await h.send();
  h.auth.createCustomToken = async () => { throw new Error('iam.serviceAccounts.signBlob denied'); };
  await assert.rejects(() => checkSignInCode(req({email: EMAIL, code: '000042'}), h.deps), {code: 'unavailable'});
});


test('the daily cap counts per Manila day, refuses at the cap and starts again the next day', async () => {
  const {db, mailer, clock, deps} = sendDeps({deps: {dailyCap: 3}});
  clock.advance(0);
  const emails = ['a@example.com', 'b@example.com', 'c@example.com', 'd@example.com'];
  for (const email of emails.slice(0, 3)) await sendSignInCode(req({email}), deps);
  assert.equal(db.rows.get('signInLimits/global-1970-01-01').count, 3);
  await assert.rejects(() => sendSignInCode(req({email: emails[3]}), deps), {code: 'resource-exhausted'});
  assert.equal(mailer.sent.length, 3);
  assert.equal(db.rows.has(`signInCodes/${codeDocId(emails[3])}`), false);
  // A cooldown reply sends nothing and does not use a place.
  assert.deepEqual(await sendSignInCode(req({email: emails[0]}), deps), {resendAfterSeconds: 60});
  assert.equal(db.rows.get('signInLimits/global-1970-01-01').count, 3);
  // 1970-01-01 16:00 UTC is already 1970-01-02 in Manila.
  clock.advance(16 * 3_600_000 - 1_000_000);
  await sendSignInCode(req({email: emails[3]}), deps);
  assert.equal(db.rows.get('signInLimits/global-1970-01-02').count, 1);
});

test('the daily cap warns once at 80 percent and refuses a bad cap', async () => {
  const alerts = [];
  const {mailer, deps} = sendDeps({deps: {dailyCap: 10, alert: m => alerts.push(m)}});
  for (let i = 0; i < 10; i += 1) await sendSignInCode(req({email: `u${i}@example.com`}), deps);
  assert.deepEqual(alerts, ['Sign-in emails reached 80% of the daily cap (8 of 10).']);
  assert.equal(mailer.sent.length, 10);
  await assert.rejects(() => sendSignInCode(req({email: 'z@example.com'}), deps), {code: 'resource-exhausted'});
  const zero = sendDeps({deps: {dailyCap: 0}});
  await assert.rejects(() => sendSignInCode(req({email: EMAIL}), zero.deps), {code: 'resource-exhausted'});
  assert.equal(zero.mailer.sent.length, 0);
});

test('the default cap is 80 and is set in the production environment file', async () => {
  const {readFileSync} = await import('node:fs');
  assert.match(readFileSync(new URL('../.env.pantas-prod', import.meta.url), 'utf8'), /^SIGN_IN_DAILY_SEND_CAP=60$/m);
  const {mailer, deps} = sendDeps();
  for (let i = 0; i < 80; i += 1) await sendSignInCode(req({email: `u${i}@example.com`}), deps);
  await assert.rejects(() => sendSignInCode(req({email: 'z@example.com'}), deps), {code: 'resource-exhausted'});
  assert.equal(mailer.sent.length, 80);
});
