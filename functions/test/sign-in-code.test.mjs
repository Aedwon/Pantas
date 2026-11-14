import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {checkSignInCode, codeDocId, hashCode, normalizeEmail, sendSignInCode,
  signInCodeMessage} from '../lib/signInCode.js';

const KEY = 'test-key';
const EMAIL = 'maria@example.com';
const CODE = '000042';
const caller = (provider = 'anonymous', uid = 'anon1') =>
  ({uid, token: {firebase: {sign_in_provider: provider}}});
const req = (data, overrides = {}) => ({auth: caller(), app: {appId: 'web'}, data, ...overrides});

/** A Firestore stand-in: doc, collection().where().get(), and serialized transactions. */
function fakeDb() {
  const rows = new Map();
  let chain = Promise.resolve();
  const ref = path => ({path, delete: async () => { rows.delete(path); }});
  const db = {
    rows,
    getAll: async (...refs) => refs.map(r => ({exists: rows.has(r.path), get: key => rows.get(r.path)?.[key]})),
    doc: ref,
    collection: name => ({where: (field, op, value) => ({get: async () => ({docs: [...rows.entries()]
      .filter(([path, row]) => path.startsWith(`${name}/`) && row[field] === value)
      .map(([, row]) => ({get: key => row[key]}))})})}),
    runTransaction: fn => {
      const run = chain.then(() => fn({
        get: async r => ({exists: rows.has(r.path), get: field => rows.get(r.path)?.[field]}),
        set: (r, data, options) => rows.set(r.path, options?.merge ? {...rows.get(r.path), ...data} : {...data}),
        delete: r => rows.delete(r.path),
      }));
      chain = run.catch(() => {});
      return run;
    },
  };
  return db;
}

function fakeAuth(users = {}) {
  const calls = [];
  const byEmail = email => Object.values(users).find(u => u.email === email);
  const notFound = () => Object.assign(new Error('nope'), {code: 'auth/user-not-found'});
  return {
    calls, users,
    getUserByEmail: async email => { const user = byEmail(email); if (!user) throw notFound(); return user; },
    createUser: async props => {
      calls.push(['createUser', props]);
      if (byEmail(props.email)) throw Object.assign(new Error('dup'), {code: 'auth/email-already-exists'});
      const uid = `new${calls.length}`;
      users[uid] = {uid, disabled: false, ...props};
      return users[uid];
    },
    createCustomToken: async uid => `token-for-${uid}`,
    getUser: async uid => { if (!users[uid]) throw notFound(); return users[uid]; },
    revokeRefreshTokens: async uid => { calls.push(['revoke', uid]); },
    deleteUser: async uid => { calls.push(['deleteUser', uid]); if (!users[uid]) throw notFound(); delete users[uid]; },
  };
}

function sender(fail = false) {
  const sent = [];
  return {sent, send: async message => { if (fail) throw new Error('provider down'); sent.push(message); }};
}

/** Everything one test needs: a database, Auth, a mailer, a clock and ready-made dependencies. */
function rig({users = {anon1: {uid: 'anon1'}}, mailer = sender(), send = {}, verify = {}} = {}) {
  const db = fakeDb();
  const auth = fakeAuth(users);
  let t = 1_000_000;
  let n = 0;
  const clock = {now: () => t, advance: ms => { t += ms; }};
  const sendDeps = {db, auth, key: KEY, mailer, now: clock.now, random: () => 42, allow: async () => true,
    challengeId: () => String(++n).padStart(32, '0'), ...send};
  // Stands in for the full account deletion, which the emulator tests run for real.
  const purge = async uid => { auth.calls.push(['purge', uid]); delete users[uid]; };
  const verifyDeps = {db, auth, key: KEY, now: clock.now, allow: async () => true, purge, ...verify};
  // Each call comes from its own address unless a test names one, so the per-address limit stays out of the way.
  let caller = 0;
  const fresh = () => ({ip: `10.${Math.floor(++caller / 250)}.${caller % 250}.1`});
  return {db, auth, mailer, clock, sendDeps, verifyDeps,
    send: (email = EMAIL, overrides = {}) => sendSignInCode(req({email}, {rawRequest: fresh(), ...overrides}), sendDeps),
    verify: (challengeId, code = CODE, overrides = {}) => checkSignInCode(req({challengeId, code}, overrides), verifyDeps)};
}

const id = n => String(n).padStart(32, '0');
const ID1 = id(1);
const challenge = (r, challengeId = ID1) => r.db.rows.get(`signInChallenges/${challengeId}`);
const limits = (r, email = EMAIL) => r.db.rows.get(`signInCodes/${codeDocId(email)}`);
const outcome = async promise => promise.then(value => ({value}), error => ({error}));
const isExpired = error => error.code === 'not-found' && error.details.reason === 'expired';

// ------------------------------------------------------------------ request

test('invalid emails are refused', async () => {
  for (const bad of [undefined, null, 5, '', 'no-at', 'a@b', 'a b@c.com', 'a@c.c', `${'x'.repeat(250)}@a.com`]) {
    await assert.rejects(() => sendSignInCode(req({email: bad}), rig().sendDeps), {code: 'invalid-argument'}, String(bad));
  }
  assert.equal(normalizeEmail('  Maria@Example.COM '), EMAIL);
});

test('a send makes a challenge that holds only a keyed hash of the code', async () => {
  const r = rig();
  const result = await r.send(' Maria@Example.com');
  assert.deepEqual(result, {challengeId: ID1, resendAfterSeconds: 60});
  const row = challenge(r);
  assert.equal(row.codeHash, hashCode(KEY, EMAIL, CODE));
  assert.equal(row.email, EMAIL);
  assert.equal(row.emailKey, codeDocId(EMAIL));
  assert.equal(row.requesterUid, 'anon1');
  assert.equal(row.attempts, 0);
  assert.equal(row.expiresAt.getTime(), 1_000_000 + 10 * 60_000);
  assert.ok(!JSON.stringify([...r.db.rows.values()]).includes(CODE));
  assert.equal(r.db.rows.get(`signInRequests/${[...r.db.rows.keys()].find(k => k.startsWith('signInRequests/')).split('/')[1]}`).challengeId, ID1);
  assert.equal(limits(r).codeHash, undefined);
  assert.equal(r.mailer.sent.length, 1);
  assert.equal(r.mailer.sent[0].to, EMAIL);
  assert.equal(r.mailer.sent[0].subject, '000042 is your Pantas sign-in code');
  assert.ok(r.mailer.sent[0].text.includes('Your sign-in code'));
  assert.ok(r.mailer.sent[0].text.includes("It expires in 10 minutes. If you didn't try to sign in to Pantas, ignore this email."));
  assert.ok(r.mailer.sent[0].html.includes('letter-spacing'));
});

test('challenge ids come from 128 random bits by default', async () => {
  const r = rig();
  delete r.sendDeps.challengeId;
  const a = await sendSignInCode(req({email: EMAIL}), r.sendDeps);
  assert.match(a.challengeId, /^[0-9a-f]{32}$/);
});

test('the email escapes values and uses the app palette without em dashes', () => {
  const m = signInCodeMessage({to: EMAIL, code: '<b>1'});
  assert.ok(!m.html.includes('<b>1'));
  assert.ok(m.html.includes('&lt;b&gt;1'));
  const clean = signInCodeMessage({to: EMAIL, code: '123456'});
  for (const color of ['#1D1D1F', '#6E6E73', '#0B7A68']) assert.ok(clean.html.includes(color), color);
  assert.ok(!/—/.test(clean.text + clean.html));
});

test('inside the cooldown anyone asking again gets the same challenge and the true wait, real or not', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(20_000);
  assert.deepEqual(await r.send(), {challengeId: ID1, resendAfterSeconds: 40});
  const other = caller('anonymous', 'anon2');
  const stranger = await r.send(EMAIL, {auth: other});
  assert.deepEqual(Object.keys(stranger).sort(), ['challengeId', 'resendAfterSeconds']);
  assert.equal(stranger.resendAfterSeconds, 60);
  assert.notEqual(stranger.challengeId, ID1);
  assert.equal(r.mailer.sent.length, 1);
  assert.equal(challenge(r, stranger.challengeId).standIn, true);
  assert.equal(challenge(r, stranger.challengeId).requesterUid, 'anon2');
  r.clock.advance(15_000);
  assert.deepEqual(await r.send(EMAIL, {auth: other}), {challengeId: stranger.challengeId, resendAfterSeconds: 45});
  r.clock.advance(40_000);
  assert.equal((await r.send()).resendAfterSeconds, 60);
  assert.equal(r.mailer.sent.length, 2);
});

test('a new request does not close an earlier open challenge', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(61_000);
  await r.send(EMAIL, {auth: caller('anonymous', 'anon2')});
  assert.ok(challenge(r, ID1));
  assert.ok(challenge(r, id(2)));
  assert.match((await r.verify(ID1)).token, /^token-for-new/);
});

test('after five sends in an hour the next looks like a send but nothing is mailed', async () => {
  const r = rig();
  for (let i = 0; i < 5; i += 1) { await r.send(); r.clock.advance(61_000); }
  const sixth = await r.send();
  assert.deepEqual(Object.keys(sixth).sort(), ['challengeId', 'resendAfterSeconds']);
  assert.equal(sixth.resendAfterSeconds, 60);
  assert.equal(r.mailer.sent.length, 5);
  assert.equal(challenge(r, sixth.challengeId).standIn, true);
  await assert.rejects(() => r.verify(sixth.challengeId),
    error => error.code === 'invalid-argument' && error.details.triesLeft === 4);
  r.clock.advance(3_600_000);
  await r.send();
  assert.equal(r.mailer.sent.length, 6);
});

test('the per-caller limit refuses before anything is stored or sent', async () => {
  const seen = [];
  const r = rig({send: {allow: async (...args) => { seen.push(args); return false; }}});
  await assert.rejects(() => r.send(), {code: 'resource-exhausted'});
  assert.deepEqual(seen, [['anon1', 'signInCodeSend', 10, 3_600_000]]);
  assert.equal(r.db.rows.size, 0);
  assert.equal(r.mailer.sent.length, 0);
});

test('a mail failure deletes the challenge, keeps the cooldown and gives the cap place back', async () => {
  const r = rig({mailer: sender(true)});
  await assert.rejects(() => r.send(), {code: 'unavailable'});
  assert.equal(challenge(r), undefined);
  assert.equal(limits(r).sendCount, 1);
  assert.deepEqual(limits(r).open, []);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 0);
  // The cooldown does not hand out the dead challenge. The reply is a look-alike.
  const next = await r.send();
  assert.notEqual(next.challengeId, ID1);
  assert.equal(challenge(r, next.challengeId).standIn, true);
});

test('requests need a signed-in caller and a fresh App Check token', async () => {
  const r = rig();
  for (const overrides of [{auth: undefined}, {app: undefined}, {app: {alreadyConsumed: true}}]) {
    await assert.rejects(() => r.send(EMAIL, overrides), {code: 'unauthenticated'});
    await assert.rejects(() => checkSignInCode(req({challengeId: ID1, code: CODE}, overrides), r.verifyDeps), {code: 'unauthenticated'});
  }
});

// ------------------------------------------------------------------- verify

test('a wrong code counts down and the fifth wrong try locks the challenge for its owner', async () => {
  const r = rig();
  await r.send();
  for (const triesLeft of [4, 3, 2, 1, 0]) {
    await assert.rejects(() => r.verify(ID1, '111111'),
      error => error.code === 'invalid-argument' && error.details.reason === 'wrong' && error.details.triesLeft === triesLeft);
  }
  await assert.rejects(() => r.verify(ID1, CODE),
    error => error.code === 'resource-exhausted' && error.details.reason === 'tooManyTries');
  assert.equal(r.auth.calls.length, 0);
  // Someone else still sees it as gone.
  await assert.rejects(() => r.verify(ID1, CODE, {auth: caller('anonymous', 'anon2')}), isExpired);
});

test('wrong guesses by another user neither count nor reveal anything', async () => {
  const r = rig();
  await r.send();
  for (let i = 0; i < 8; i += 1) {
    await assert.rejects(() => r.verify(ID1, '111111', {auth: caller('anonymous', 'anon2')}), isExpired);
  }
  assert.equal(challenge(r).attempts, 0);
  assert.equal((await r.verify(ID1)).token, 'token-for-new1');
});

test('unknown, malformed, expired, consumed, foreign and wrong-id challenges all fail the same way', async () => {
  const r = rig();
  await r.send();
  const errors = [];
  const attempt = async (challengeId, overrides) => errors.push((await outcome(r.verify(challengeId, CODE, overrides))).error);
  await attempt(id(99));
  await attempt('../users/anon1');
  await attempt(undefined);
  await attempt(ID1, {auth: caller('anonymous', 'anon2')});
  r.clock.advance(10 * 60_000 + 1);
  await attempt(ID1);
  await r.send();
  await r.verify(id(2));
  await attempt(id(2));
  assert.equal(errors.length, 6);
  for (const error of errors) {
    assert.ok(isExpired(error), String(error));
    assert.equal(error.message, errors[0].message);
    assert.deepEqual(error.details, errors[0].details);
  }
  assert.equal(challenge(r), undefined);
});

test('the code must be exactly six digits and the caller limit applies', async () => {
  const r = rig();
  await r.send();
  for (const bad of ['12345', '1234567', 'abcdef', '12 456', 123456, null]) {
    await assert.rejects(() => r.verify(ID1, bad), {code: 'invalid-argument'}, String(bad));
  }
  const seen = [];
  await assert.rejects(() => checkSignInCode(req({challengeId: ID1, code: CODE}),
    {...r.verifyDeps, allow: async (...args) => { seen.push(args); return false; }}), {code: 'resource-exhausted'});
  assert.deepEqual(seen, [['anon1', 'signInCodeVerify', 30, 600_000]]);
});

test('the email field is ignored: the challenge decides the address', async () => {
  const r = rig();
  await r.send();
  await checkSignInCode(req({challengeId: ID1, code: CODE, email: 'other@example.com'}), r.verifyDeps);
  assert.deepEqual(r.auth.calls, [['createUser', {email: EMAIL, emailVerified: true}]]);
});

test('the right code is single use and closes every other open challenge for the mailbox', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(61_000);
  await r.send();
  r.clock.advance(61_000);
  await r.send('other@example.com');
  assert.match((await r.verify(ID1)).token, /^token-for-new/);
  assert.equal(challenge(r, ID1), undefined);
  assert.equal(challenge(r, id(2)), undefined);
  assert.ok(challenge(r, id(3)), 'another mailbox is untouched');
  assert.equal(limits(r).sendCount, 2);
  await assert.rejects(() => r.verify(ID1), isExpired);
  await assert.rejects(() => r.verify(id(2)), isExpired);
});

// ------------------------------------------------------------------ accounts

test('an anonymous caller is never upgraded: a new account is created and the client switches to it', async () => {
  const r = rig();
  await r.send();
  const result = await r.verify(ID1);
  assert.equal(result.token, 'token-for-new1');
  assert.deepEqual(r.auth.calls, [['createUser', {email: EMAIL, emailVerified: true}]]);
  assert.equal(r.auth.users.anon1.email, undefined);
});

test('an existing verified account is signed in as itself and not modified', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: false,
    providerData: [{providerId: 'password'}]}, anon1: {uid: 'anon1'}}});
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u9'});
  assert.deepEqual(r.auth.calls, []);
  assert.deepEqual(r.auth.users.u9.providerData, [{providerId: 'password'}]);
  assert.equal(r.auth.users.u9.email, EMAIL);
});

test('a disabled account, or an unverified one with another provider, is refused and left untouched', async () => {
  const messages = [];
  for (const record of [
    {emailVerified: false, disabled: false, providerData: [{providerId: 'google.com'}]},
    {emailVerified: false, disabled: false, providerData: [{providerId: 'password'}, {providerId: 'google.com'}]},
    {emailVerified: false, disabled: false, providerData: [{providerId: 'phone'}]},
    {emailVerified: true, disabled: true},
    {emailVerified: false, disabled: true, providerData: [{providerId: 'password'}]},
    {emailVerified: false, disabled: true}]) {
    const r = rig({users: {u9: {uid: 'u9', email: EMAIL, ...record}}});
    const before = JSON.stringify(r.auth.users.u9);
    await r.send();
    const error = (await outcome(r.verify(ID1))).error;
    assert.equal(error.code, 'permission-denied', JSON.stringify(record));
    messages.push(error.message);
    assert.deepEqual(r.auth.calls, []);
    assert.equal(JSON.stringify(r.auth.users.u9), before);
  }
  assert.deepEqual(new Set(messages), new Set(["This account can't sign in. Write to support@pantas.study."]));
});

// ----------------------------------------------- S-06: a squatter is replaced

const squatter = (providerData) => ({uid: 'sq1', email: EMAIL, emailVerified: false, disabled: false,
  ...(providerData === undefined ? {} : {providerData})});

for (const providers of [[{providerId: 'password'}], [], undefined]) {
  test(`an unverified password-only account on the address is replaced once the code is right (${JSON.stringify(providers)})`, async () => {
    const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter(providers)}});
    await r.send();
    const result = await r.verify(ID1);
    assert.match(result.token, /^token-for-new/);
    assert.deepEqual(r.auth.calls.map(c => c[0]), ['revoke', 'purge', 'createUser']);
    assert.deepEqual(r.auth.calls[0], ['revoke', 'sq1']);
    assert.deepEqual(r.auth.calls[1], ['purge', 'sq1']);
    assert.equal(r.auth.users.sq1, undefined);
    const owner = Object.values(r.auth.users).find(u => u.email === EMAIL);
    assert.equal(owner.emailVerified, true);
    assert.equal(result.token, `token-for-${owner.uid}`);
  });
}

test('the replacement runs the real account deletion path unless a test stands in for it', () => {
  const source = readFileSync(new URL('../src/_squatter.ts', import.meta.url), 'utf8');
  assert.match(source, /deleteUserData\(/);
});

test('a wrong code never replaces anything', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  await assert.rejects(() => r.verify(ID1, '999999'), {code: 'invalid-argument'});
  assert.deepEqual(r.auth.calls, []);
  assert.ok(r.auth.users.sq1);
});

test('a stand-in challenge never replaces anything, even with its own secret', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}, send: {openCap: 0, standInCode: () => 777}});
  await r.send();
  await assert.rejects(() => r.verify(ID1, '000777'), {code: 'invalid-argument'});
  assert.deepEqual(r.auth.calls, []);
});

test('a verified account is never replaced', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'},
    u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: false, providerData: [{providerId: 'password'}]}}});
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u9'});
  assert.deepEqual(r.auth.calls, []);
});

test('another sign-in that replaces the squatter and makes the account first wins, and we sign in as it', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  r.verifyDeps.purge = async uid => {
    // The other sign-in finishes the whole replacement while this one is deleting.
    delete r.auth.users[uid];
    r.auth.users.w1 = {uid: 'w1', email: EMAIL, emailVerified: true, disabled: false};
  };
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-w1'});
  assert.equal(Object.values(r.auth.users).filter(u => u.email === EMAIL).length, 1);
});

test('a delete that finds the squatter already deleted is not an error', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  r.verifyDeps.purge = async uid => {
    delete r.auth.users[uid];
    throw Object.assign(new Error('gone'), {code: 'auth/user-not-found'});
  };
  assert.match((await r.verify(ID1)).token, /^token-for-new/);
});

test('a squatter that is already gone when we delete it is not an error', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  const getUser = r.auth.getUser;
  r.auth.getUser = async uid => {
    if (uid === 'sq1') { delete r.auth.users.sq1; }
    return getUser(uid);
  };
  const result = await r.verify(ID1);
  assert.match(result.token, /^token-for-new/);
});

test('if the attacker registers the address again before the new account is made, it is replaced again', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  const create = r.auth.createUser;
  let first = true;
  r.auth.createUser = async props => {
    if (first) { first = false; r.auth.users.sq2 = {...squatter([{providerId: 'password'}]), uid: 'sq2'}; }
    return create(props);
  };
  const result = await r.verify(ID1);
  assert.equal(r.auth.users.sq1, undefined);
  assert.equal(r.auth.users.sq2, undefined);
  const owner = Object.values(r.auth.users).find(u => u.email === EMAIL);
  assert.equal(result.token, `token-for-${owner.uid}`);
});

test('an account that is replaced is logged once as a structured line with the uid and no address', async t => {
  const lines = [];
  for (const stream of [process.stdout, process.stderr]) {
    t.mock.method(stream, 'write', chunk => { lines.push(String(chunk)); return true; });
  }
  const r = rig({users: {anon1: {uid: 'anon1'}, sq1: squatter([{providerId: 'password'}])}});
  await r.send();
  await r.verify(ID1);
  const logged = lines.filter(line => line.includes('Replaced an unclaimed account'));
  assert.equal(logged.length, 1);
  const entry = JSON.parse(logged[0]);
  assert.equal(entry.uid, 'sq1');
  assert.ok(!logged[0].includes('example.com'));
});

test('a signed-in non-anonymous caller also gets a new account for a new email', async () => {
  const google = caller('google.com', 'g1');
  const r = rig({users: {g1: {uid: 'g1', email: 'g@example.com'}}});
  await r.send(EMAIL, {auth: google});
  const result = await r.verify(ID1, CODE, {auth: google});
  assert.match(result.token, /^token-for-new/);
  assert.deepEqual(r.auth.calls[0], ['createUser', {email: EMAIL, emailVerified: true}]);
  assert.equal(r.auth.users.g1.email, 'g@example.com');
});

test('a lost race on creation signs in as the account that won, if it is verified', async () => {
  const r = rig();
  await r.send();
  const lookup = r.auth.getUserByEmail;
  let first = true;
  r.auth.getUserByEmail = async email => {
    if (first) { first = false; throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'}); }
    return lookup(email);
  };
  r.auth.users.u7 = {uid: 'u7', email: EMAIL, emailVerified: true, disabled: false};
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u7'});
});

test('a lost race on creation is refused if the winner is unverified and linked to another provider', async () => {
  const r = rig();
  await r.send();
  const lookup = r.auth.getUserByEmail;
  let first = true;
  r.auth.getUserByEmail = async email => {
    if (first) { first = false; throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'}); }
    return lookup(email);
  };
  r.auth.users.u7 = {uid: 'u7', email: EMAIL, emailVerified: false, disabled: false, providerData: [{providerId: 'google.com'}]};
  await assert.rejects(() => r.verify(ID1), {code: 'permission-denied'});
});

test('a token failure reports unavailable', async () => {
  const r = rig();
  await r.send();
  r.auth.createCustomToken = async () => { throw new Error('iam.serviceAccounts.signBlob denied'); };
  await assert.rejects(() => r.verify(ID1), {code: 'unavailable'});
});

// -------------------------------------------- IP limit, buckets, aliases, caps

const fromIp = (r, ip, email, uid = 'anon1') => r.send(email, {auth: caller('anonymous', uid), rawRequest: {ip}});

test('one IP gets 10 sends an hour whatever accounts it uses, and only a hash of it is stored', async () => {
  const r = rig();
  for (let i = 0; i < 10; i += 1) await fromIp(r, '203.0.113.9', `u${i}@example.com`, `anon${i}`);
  await assert.rejects(() => fromIp(r, '203.0.113.9', 'late@example.com', 'anon99'), {code: 'resource-exhausted'});
  assert.equal(r.mailer.sent.length, 10);
  assert.ok(![...r.db.rows.keys()].some(path => path.includes('203.0.113.9')));
  await fromIp(r, '203.0.113.10', 'x@example.com');
  await r.send('y@example.com');
  r.clock.advance(3_600_001);
  await fromIp(r, '203.0.113.9', 'late@example.com');
});

test('selected beta applicants use the reserved bucket, and the rest use the open one', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}}, send: {openCap: 2, reservedCap: 1}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  r.db.rows.set('betaApplications/b', {email: 'waiting@example.com', selected: false});
  for (const email of ['beta@example.com', 'waiting@example.com', 'stranger@example.com', 'late@example.com']) await r.send(email);
  assert.equal(r.db.rows.get('signInLimits/global-reserved-1970-01-01').count, 1);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 2);
  assert.deepEqual(r.mailer.sent.map(m => m.to), ['beta@example.com', 'waiting@example.com', 'stranger@example.com']);
});

test('S-10 item 2: a verified, enabled account is in the reserved bucket, so a full open bucket does not block it', async () => {
  const users = {anon1: {uid: 'anon1'},
    back: {uid: 'back', email: 'back@example.com', emailVerified: true, disabled: false},
    squat: {uid: 'squat', email: 'unverified@example.com', emailVerified: false, disabled: false},
    off: {uid: 'off', email: 'off@example.com', emailVerified: true, disabled: true}};
  const r = rig({users, send: {openCap: 1, reservedCap: 5, auth: undefined}});
  r.sendDeps.auth = r.auth;
  await r.send('stranger@example.com');
  assert.equal(r.mailer.sent.length, 1);
  const returning = await r.send('back@example.com');
  assert.equal(r.mailer.sent.length, 2, 'the returning user still gets a code');
  assert.equal(challenge(r, returning.challengeId).standIn, undefined);
  assert.equal(r.db.rows.get('signInLimits/global-reserved-1970-01-01').count, 1);
  // Unverified and disabled accounts stay in the open bucket, which is full.
  for (const email of ['unverified@example.com', 'off@example.com']) {
    const held = await r.send(email);
    assert.equal(challenge(r, held.challengeId).standIn, true, email);
  }
  assert.equal(r.mailer.sent.length, 2);
});

test('S-10 item 2: the reply is the same whichever bucket was used, and a failed account lookup falls back to open', async () => {
  const r = rig({users: {anon1: {uid: 'anon1'}, back: {uid: 'back', email: 'back@example.com', emailVerified: true, disabled: false}},
    send: {openCap: 5, reservedCap: 5}});
  r.sendDeps.auth = r.auth;
  const known = await r.send('back@example.com');
  const stranger = await r.send('stranger@example.com');
  assert.deepEqual(Object.keys(known).sort(), Object.keys(stranger).sort());
  assert.equal(known.resendAfterSeconds, stranger.resendAfterSeconds);
  r.auth.getUserByEmail = async () => { throw new Error('auth down'); };
  const after = await r.send('back2@example.com');
  assert.deepEqual(Object.keys(after).sort(), Object.keys(stranger).sort());
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 2);
});

test('a full bucket never blocks the other, and a held-back send looks exactly like a real one', async () => {
  const r = rig({send: {openCap: 1, reservedCap: 1}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  const real = await r.send('a@example.com');
  const openFull = await r.send('b@example.com');
  const reserved = await r.send('beta@example.com');
  const reservedFull = await r.send('beta2@example.com');
  r.db.rows.set('betaApplications/b', {email: 'beta3@example.com', selected: true});
  const reservedFull2 = await r.send('beta3@example.com');
  assert.equal(r.mailer.sent.length, 2);
  for (const reply of [real, openFull, reserved, reservedFull, reservedFull2]) {
    assert.deepEqual(Object.keys(reply).sort(), ['challengeId', 'resendAfterSeconds']);
    assert.equal(reply.resendAfterSeconds, 60);
    assert.match(reply.challengeId, /^[0-9a-f]{32}$/);
  }
  assert.equal(challenge(r, openFull.challengeId).standIn, true);
  assert.equal(challenge(r, reservedFull2.challengeId).standIn, true);
  assert.equal(challenge(r, real.challengeId).standIn, undefined);
  assert.equal(typeof challenge(r, openFull.challengeId).codeHash, 'string');
  // The daily count does not move, and the full day is flagged once so it is logged once.
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 1);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').fullLogged, true);
  assert.equal(r.db.rows.get('signInLimits/global-reserved-1970-01-01').fullLogged, true);
  await assert.rejects(() => r.verify(openFull.challengeId),
    error => error.code === 'invalid-argument' && error.details.triesLeft === 4);
});

test('a held-back send waits on the pad so it takes as long as a real one, and a real send does not', async () => {
  let pads = 0;
  const r = rig({send: {openCap: 1, pad: async () => { pads += 1; }}});
  await r.send('a@example.com');
  assert.equal(pads, 0);
  await r.send('b@example.com');
  assert.equal(pads, 1);
});

test('the reply for a known address has the same shape as for a stranger', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: 'known@example.com'}}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  const replies = [];
  for (const email of ['known@example.com', 'beta@example.com', 'stranger@example.com']) replies.push(await r.send(email));
  for (const reply of replies) assert.deepEqual(Object.keys(reply).sort(), ['challengeId', 'resendAfterSeconds']);
  assert.deepEqual(replies.map(x => x.resendAfterSeconds), [60, 60, 60]);
});

test('a beta lookup failure falls back to the open bucket', async () => {
  const r = rig();
  r.db.collection = () => ({where: () => ({get: async () => { throw new Error('unavailable'); }})});
  await r.send();
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 1);
});

test('aliases of one mailbox share one limit document, and the challenge keeps the exact address', async () => {
  const r = rig();
  assert.equal(codeDocId('a.b+x@gmail.com'), codeDocId('ab@googlemail.com'));
  assert.equal(codeDocId('Someone+tag@Outlook.com'), codeDocId('someone@outlook.com'));
  assert.notEqual(codeDocId('a.b@example.com'), codeDocId('ab@example.com'));
  assert.notEqual(codeDocId('someone+tag@example.com'), codeDocId('someone@example.com'));
  assert.notEqual(codeDocId('a.b@outlook.com'), codeDocId('ab@outlook.com'));
  await r.send('A.B+one@Gmail.com');
  assert.deepEqual(await r.send('ab+two@googlemail.com'), {challengeId: ID1, resendAfterSeconds: 60});
  assert.equal(r.mailer.sent.length, 1);
  assert.equal(r.mailer.sent[0].to, 'a.b+one@gmail.com');
  assert.equal(challenge(r).email, 'a.b+one@gmail.com');
  assert.equal([...r.db.rows.keys()].filter(path => path.startsWith('signInCodes/')).length, 1);
  for (let i = 0; i < 4; i += 1) { r.clock.advance(61_000); await r.send(`a.b+n${i}@gmail.com`); }
  r.clock.advance(61_000);
  const held = await r.send('ab@gmail.com');
  assert.equal(r.mailer.sent.length, 5);
  assert.equal(challenge(r, held.challengeId).standIn, true);
});

test('the account takes the exact typed address, not the canonical one', async () => {
  const r = rig();
  await r.send('a.b+x@gmail.com');
  await r.verify(ID1);
  assert.deepEqual(r.auth.calls[0], ['createUser', {email: 'a.b+x@gmail.com', emailVerified: true}]);
});

test('the daily cap counts per Manila day, holds back at the cap and starts again the next day', async () => {
  const r = rig({send: {openCap: 3}});
  const emails = ['a@example.com', 'b@example.com', 'c@example.com', 'd@example.com'];
  for (const email of emails.slice(0, 3)) await r.send(email);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 3);
  const held = await r.send(emails[3]);
  assert.equal(held.resendAfterSeconds, 60);
  assert.equal(r.mailer.sent.length, 3);
  assert.equal(limits(r, emails[3]), undefined, 'a held-back send uses no limit of the mailbox');
  // The same requester asking again inside the cooldown of a real send still gets the real answer.
  assert.equal((await r.send(emails[0])).challengeId, id(1));
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 3);
  // 1970-01-01 16:00 UTC is already 1970-01-02 in Manila.
  r.clock.advance(16 * 3_600_000 - 1_000_000);
  await r.send(emails[3]);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-02').count, 1);
  assert.equal(r.mailer.sent.length, 4);
});

test('the daily cap warns once at 80 percent, and a zero cap holds everything back', async () => {
  const alerts = [];
  const r = rig({send: {openCap: 10, alert: m => alerts.push(m)}});
  for (let i = 0; i < 10; i += 1) await r.send(`u${i}@example.com`);
  assert.deepEqual(alerts, ['Sign-in emails (open bucket) reached 80% of the daily cap (8 of 10).']);
  assert.equal(r.mailer.sent.length, 10);
  await r.send('z@example.com');
  assert.equal(r.mailer.sent.length, 10);
  const zero = rig({send: {openCap: 0}});
  const reply = await zero.send();
  assert.equal(reply.resendAfterSeconds, 60);
  assert.equal(zero.mailer.sent.length, 0);
});

test('the default open cap is 60 and the production file sets 20 and 40', async () => {
  const env = readFileSync(new URL('../.env.pantas-prod', import.meta.url), 'utf8');
  assert.match(env, /^SIGN_IN_DAILY_SEND_CAP=20$/m);
  assert.match(env, /^SIGN_IN_DAILY_RESERVED_CAP=40$/m);
  const r = rig();
  for (let i = 0; i < 60; i += 1) await r.send(`u${i}@example.com`);
  await r.send('z@example.com');
  assert.equal(r.mailer.sent.length, 60);
});


// ------------------------------------------------ stand-ins behave like real challenges

/** Every observable part of a call's result, so two calls can be compared. */
const seen = async promise => {
  const {value, error} = await outcome(promise);
  return error ? {code: error.code, message: error.message, details: error.details} : {ok: Object.keys(value).sort()};
};

/** A real challenge for anon1 and a stand-in for anon2 on the same mailbox, with a known stand-in secret. */
async function pair() {
  const r = rig({send: {standInCode: () => 777}});
  const realReply = await r.send();
  const other = caller('anonymous', 'anon2');
  const fakeReply = await r.send(EMAIL, {auth: other});
  assert.equal(challenge(r, fakeReply.challengeId).standIn, true);
  const guess = (which, code) => which === 'real'
    ? r.verify(realReply.challengeId, code) : r.verify(fakeReply.challengeId, code, {auth: other});
  return {r, realReply, fakeReply, other, guess};
}

test('a real and a stand-in challenge get replies of the same shape', async () => {
  const {r, realReply, fakeReply} = await pair();
  assert.deepEqual(Object.keys(realReply).sort(), Object.keys(fakeReply).sort());
  assert.equal(realReply.resendAfterSeconds, fakeReply.resendAfterSeconds);
  assert.equal(r.mailer.sent.length, 1);
});

test('a wrong guess gives the same answer on a real and a stand-in challenge', async () => {
  const {guess} = await pair();
  assert.deepEqual(await seen(guess('fake', '111111')), await seen(guess('real', '111111')));
  assert.equal((await seen(guess('fake', '222222'))).details.triesLeft, 3);
});

test('five wrong guesses lock a stand-in exactly as they lock a real challenge', async () => {
  const {r, guess} = await pair();
  for (let i = 0; i < 7; i += 1) {
    assert.deepEqual(await seen(guess('fake', `11111${i}`)), await seen(guess('real', `11111${i}`)), `try ${i + 1}`);
  }
  const locked = await seen(guess('fake', '999999'));
  assert.equal(locked.code, 'resource-exhausted');
  assert.deepEqual(locked, await seen(guess('real', '999999')));
  assert.equal(r.auth.calls.length, 0);
});

test('the stand-in secret code is treated as a wrong guess and never signs anyone in', async () => {
  const {r, fakeReply, guess} = await pair();
  const result = await seen(guess('fake', '000777'));
  assert.equal(result.code, 'invalid-argument');
  assert.equal(result.details.reason, 'wrong');
  assert.equal(result.details.triesLeft, 4);
  assert.ok(challenge(r, fakeReply.challengeId), 'the stand-in is not consumed');
  assert.equal(r.auth.calls.length, 0);
  // The real challenge, by contrast, accepts its own code.
  assert.match((await guess('real', CODE)).token, /^token-for-new/);
});

test('a stand-in expires exactly as a real challenge does', async () => {
  const {r, guess} = await pair();
  r.clock.advance(10 * 60_000 - 1);
  assert.deepEqual(await seen(guess('fake', '111111')), await seen(guess('real', '111111')));
  r.clock.advance(2);
  const fake = await seen(guess('fake', '111111'));
  assert.deepEqual(fake, await seen(guess('real', '111111')));
  assert.equal(fake.details.reason, 'expired');
});

test('asking again gives the same id and a falling countdown for a real and a stand-in challenge alike', async () => {
  const {r, realReply, fakeReply, other} = await pair();
  for (const [wait, left] of [[10_000, 50], [25_000, 25]]) {
    r.clock.advance(wait);
    assert.deepEqual(await r.send(), {challengeId: realReply.challengeId, resendAfterSeconds: left});
    assert.deepEqual(await r.send(EMAIL, {auth: other}), {challengeId: fakeReply.challengeId, resendAfterSeconds: left});
  }
  assert.equal(r.mailer.sent.length, 1);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 1);
  // After the minute both ask afresh: a new send for the real one's mailbox slot is again a stand-in
  // or a real send, and either way a new challenge id comes back.
  r.clock.advance(30_000);
  const [a, b] = [await r.send(), await r.send(EMAIL, {auth: other})];
  assert.notEqual(a.challengeId, realReply.challengeId);
  assert.notEqual(b.challengeId, fakeReply.challengeId);
  assert.equal(a.resendAfterSeconds, 60);
  assert.equal(b.resendAfterSeconds, 60);
});

test('the stand-in secret is random by default and is never mailed', async () => {
  const r = rig();
  await r.send();
  const fake = await r.send(EMAIL, {auth: caller('anonymous', 'anon2')});
  assert.equal(r.mailer.sent.length, 1);
  assert.ok(!r.mailer.sent[0].text.includes('777'));
  const secrets = new Set();
  for (let i = 0; i < 6; i += 1) {
    const q = rig();
    await q.send();
    const reply = await q.send(EMAIL, {auth: caller('anonymous', 'anon2')});
    secrets.add(challenge(q, reply.challengeId).codeHash);
  }
  assert.ok(secrets.size > 1);
  assert.ok(fake.challengeId);
});

for (const marker of ['users/maria/server/guardianConsent', 'accountDeletions/maria']) {
  test(`active anonymous code caller cannot mint for closed target: ${marker}`, async () => {
    const r = rig({users: {maria: {uid: 'maria', email: EMAIL, emailVerified: true}}});
    await r.send();
    r.db.rows.set(marker, {status: 'withdrawn'});
    let minted = false;
    r.auth.createCustomToken = async () => { minted = true; return 'unexpected'; };
    await assert.rejects(r.verify(ID1), error => error.code === 'permission-denied' && error.details?.reason !== 'account-closed');
    assert.equal(minted, false);
  });
}


// ------------------------------------------- S-10 item 1: one address, no spoofing

const via = (r, forwarded, ip, email, uid = 'anon1') => r.send(email,
  {auth: caller('anonymous', uid), rawRequest: {ip, headers: forwarded === undefined ? {} : {'x-forwarded-for': forwarded}}});

test('S-10 item 1: a spoofed X-Forwarded-For does not give a caller a fresh address', async () => {
  const r = rig();
  for (let i = 0; i < 10; i += 1) await via(r, `198.51.100.${i}, 203.0.113.9`, '10.0.0.1', `s${i}@example.com`, `anon${i}`);
  await assert.rejects(() => via(r, '192.0.2.77, 203.0.113.9', '10.0.0.1', 'late@example.com', 'anon50'), {code: 'resource-exhausted'});
  assert.equal(r.mailer.sent.length, 10);
  // The same left side with a different right-most entry is another client.
  await via(r, '198.51.100.0, 203.0.113.10', '10.0.0.1', 'other@example.com', 'anon51');
});

test('S-10 item 1: with no usable header the connection address counts', async () => {
  const r = rig();
  for (let i = 0; i < 10; i += 1) await via(r, 'not-an-address', '203.0.113.9', `d${i}@example.com`, `anon${i}`);
  await assert.rejects(() => via(r, undefined, '203.0.113.9', 'late@example.com', 'anon50'), {code: 'resource-exhausted'});
});

test('S-10 item 1: a call with no address at all shares one unknown bucket instead of skipping the limit', async () => {
  const r = rig();
  for (let i = 0; i < 10; i += 1) await sendSignInCode(req({email: `n${i}@example.com`}, {auth: caller('anonymous', `anon${i}`)}), r.sendDeps);
  await assert.rejects(() => sendSignInCode(req({email: 'late@example.com'}, {auth: caller('anonymous', 'anon50'), rawRequest: {}}), r.sendDeps),
    {code: 'resource-exhausted'});
  assert.ok(![...r.db.rows.keys()].some(path => path.includes('203.0.113.9')));
});

// ----------------------------------------- S-10 items 3 and 4: per-mailbox limits

const MINUTE = 60_000;
/** Sends until `count` real codes are mailed to one mailbox, spacing them so the hourly limit never applies. */
async function mailTo(r, email, count, from = 0) {
  for (let i = 0; i < count; i += 1) {
    await r.send(email, {auth: caller('anonymous', `m${from + i}`)});
    r.clock.advance(13 * MINUTE);
  }
}

test('S-10 item 3: at most 10 codes per mailbox per Philippine day, then a stand-in with the same reply', async () => {
  const r = rig();
  await mailTo(r, EMAIL, 10);
  assert.equal(r.mailer.sent.length, 10);
  const held = await r.send(EMAIL, {auth: caller('anonymous', 'm99')});
  assert.equal(r.mailer.sent.length, 10);
  assert.equal(challenge(r, held.challengeId).standIn, true);
  assert.deepEqual(Object.keys(held).sort(), ['challengeId', 'resendAfterSeconds']);
  assert.equal(held.resendAfterSeconds, 60);
  // An alias shares the mailbox and its limit; another mailbox is unaffected.
  await r.send('m.aria@example.com', {auth: caller('anonymous', 'm98')});
  assert.equal(r.mailer.sent.length, 11);
  r.clock.advance(16 * 3_600_000);
  await r.send(EMAIL, {auth: caller('anonymous', 'm97')});
  assert.equal(r.mailer.sent.length, 12, 'the next Philippine day starts again');
});

/** Gives `n` challenges for one mailbox their five wrong tries. Returns how many reached the lock. */
async function lockChallenges(r, n, email = EMAIL) {
  for (let i = 0; i < n; i += 1) {
    const who = caller('anonymous', `l${i}`);
    const reply = await r.send(email, {auth: who});
    for (let t = 0; t < 5; t += 1) await outcome(r.verify(reply.challengeId, '999999', {auth: who}));
    r.clock.advance(2 * MINUTE);
  }
}

test('S-10 item 4: three challenges that reach the too-many-tries state hold back further sends that day', async () => {
  const r = rig();
  await lockChallenges(r, 2);
  const stillOpen = await r.send(EMAIL, {auth: caller('anonymous', 'p1')});
  assert.equal(challenge(r, stillOpen.challengeId).standIn, undefined, 'two locks are not enough');
  r.clock.advance(70 * MINUTE);
  await lockChallenges(r, 1, EMAIL);
  const sentBefore = r.mailer.sent.length;
  const held = await r.send(EMAIL, {auth: caller('anonymous', 'p2')});
  assert.equal(r.mailer.sent.length, sentBefore);
  assert.equal(challenge(r, held.challengeId).standIn, true);
  assert.deepEqual(Object.keys(held).sort(), ['challengeId', 'resendAfterSeconds']);
  // Other mailboxes are unaffected, and the next Philippine day lifts the lock.
  await r.send('other@example.com', {auth: caller('anonymous', 'p3')});
  assert.equal(r.mailer.sent.length, sentBefore + 1);
  r.clock.advance(16 * 3_600_000);
  const next = await r.send(EMAIL, {auth: caller('anonymous', 'p4')});
  assert.equal(challenge(r, next.challengeId).standIn, undefined);
});

test('S-10 item 4: wrong tries below the limit and repeated tries on one locked challenge count once', async () => {
  const r = rig();
  const who = caller('anonymous', 'l0');
  const reply = await r.send(EMAIL, {auth: who});
  for (let t = 0; t < 12; t += 1) await outcome(r.verify(reply.challengeId, '999999', {auth: who}));
  r.clock.advance(2 * MINUTE);
  await lockChallenges(r, 1);
  const held = await r.send(EMAIL, {auth: caller('anonymous', 'q1')});
  assert.equal(challenge(r, held.challengeId).standIn, undefined, 'one challenge locked twice over is still one');
});

// ----------------------------------------------- S-10 item 6: the full-bucket alert

/** The ERROR lines the log would carry, parsed. */
function errorLines(t) {
  const lines = [];
  for (const stream of [process.stdout, process.stderr]) {
    t.mock.method(stream, 'write', chunk => { lines.push(String(chunk)); return true; });
  }
  return () => lines.flatMap(line => { try { return [JSON.parse(line)]; } catch { return []; } })
    .filter(entry => entry.severity === 'ERROR');
}

test('S-10 item 6: each bucket logs exactly one ERROR line a day when it fills', async t => {
  const read = errorLines(t);
  const r = rig({send: {openCap: 2, reservedCap: 1}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  for (const email of ['a@example.com', 'b@example.com', 'c@example.com', 'd@example.com', 'beta@example.com', 'beta@example.com']) await r.send(email);
  const full = read().filter(entry => entry.event === 'mail_cap_full');
  assert.deepEqual(full.map(entry => entry.message.split('\n')[0]).sort(), [
    'Error: Mail cap full: sign-in open bucket, 1970-01-01.', 'Error: Mail cap full: sign-in reserved bucket, 1970-01-01.']);
  // The next Philippine day logs again, once.
  r.clock.advance(16 * 3_600_000);
  for (const email of ['e@example.com', 'f@example.com', 'g@example.com']) await r.send(email, {auth: caller('anonymous', 'x1')});
  assert.equal(read().filter(entry => entry.event === 'mail_cap_full' && entry.day === '1970-01-02' && entry.bucket === 'open').length, 1);
});

test('S-10 item 6: a cap of zero logs once on the first held-back send', async t => {
  const read = errorLines(t);
  const r = rig({send: {openCap: 0}});
  await r.send('a@example.com');
  await r.send('b@example.com');
  assert.equal(read().filter(entry => entry.event === 'mail_cap_full').length, 1);
});

// ------------------------------------------------------------------ expiry field for a Firestore TTL policy

const TTL_COLLECTIONS = ['signInChallenges', 'signInLimits', 'signInRequests'];
const ttlRows = r => [...r.db.rows.entries()].filter(([path]) => TTL_COLLECTIONS.includes(path.split('/')[0]));
function assertAllExpire(r, label) {
  const rows = ttlRows(r);
  assert.ok(rows.length > 0, label);
  for (const [path, row] of rows) {
    assert.ok(row.purgeAt instanceof Date, `${label}: ${path} has no purgeAt`);
    assert.ok(row.purgeAt.getTime() > r.clock.now(), `${label}: ${path} purgeAt is not in the future`);
  }
}

test('every sign-in challenge, limit and request document carries purgeAt, after the time it is useful', async () => {
  const real = rig({send: {openCap: 5}});
  await real.send('a@example.com');
  assertAllExpire(real, 'real send');
  assert.ok(challenge(real).purgeAt.getTime() >= challenge(real).expiresAt.getTime() + 86_400_000);
  // A stand-in challenge and a first "cap full" marker are written without a send.
  const full = rig({send: {openCap: 0}});
  await full.send('b@example.com');
  assertAllExpire(full, 'cap full');
  // A challenge that runs out of tries adds a mailbox-day counter.
  const locked = rig();
  await locked.send();
  for (let i = 0; i < 5; i += 1) await assert.rejects(() => locked.verify(ID1, '111111'));
  assertAllExpire(locked, 'locked');
});
