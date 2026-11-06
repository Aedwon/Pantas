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
    getUser: async uid => { if (!users[uid]) throw notFound(); return users[uid]; },
    getUserByEmail: async email => { const user = byEmail(email); if (!user) throw notFound(); return user; },
    createUser: async props => {
      calls.push(['createUser', props]);
      const uid = `new${calls.length}`;
      users[uid] = {uid, disabled: false, ...props};
      return users[uid];
    },
    updateUser: async (uid, props) => {
      calls.push(['updateUser', uid, props]);
      if (props.providersToUnlink) {
        users[uid] = {...users[uid], providerData: (users[uid].providerData ?? []).filter(p => !props.providersToUnlink.includes(p.providerId))};
        const {providersToUnlink, ...rest} = props;
        props = rest;
      }
      if (props.email && byEmail(props.email) && byEmail(props.email).uid !== uid) {
        throw Object.assign(new Error('dup'), {code: 'auth/email-already-exists'});
      }
      users[uid] = {...(users[uid] ?? {uid}), ...props};
      return users[uid];
    },
    createCustomToken: async uid => `token-for-${uid}`,
    revokeRefreshTokens: async uid => { calls.push(['revoke', uid]); },
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
  const verifyDeps = {db, auth, key: KEY, now: clock.now, allow: async () => true, ...verify};
  return {db, auth, mailer, clock, sendDeps, verifyDeps,
    send: (email = EMAIL, overrides = {}) => sendSignInCode(req({email}, overrides), sendDeps),
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
  assert.equal(limits(r).lastChallengeId, ID1);
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

test('inside the cooldown only the latest requester gets the challenge id back, and nothing is sent', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(20_000);
  assert.deepEqual(await r.send(), {challengeId: ID1, resendAfterSeconds: 40});
  const stranger = await r.send(EMAIL, {auth: caller('anonymous', 'anon2')});
  assert.deepEqual(stranger, {resendAfterSeconds: 40});
  assert.equal(r.mailer.sent.length, 1);
  r.clock.advance(40_000);
  const again = await r.send();
  assert.match(again.challengeId, /^0+\d+$/);
  assert.notEqual(again.challengeId, ID1);
  assert.equal(again.resendAfterSeconds, 60);
  assert.equal(r.mailer.sent.length, 2);
});

test('a new request does not close an earlier open challenge', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(61_000);
  await r.send(EMAIL, {auth: caller('anonymous', 'anon2')});
  assert.ok(challenge(r, ID1));
  assert.ok(challenge(r, id(2)));
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-anon1'});
});

test('the sixth send in an hour is refused, and the window reopens after an hour', async () => {
  const r = rig();
  for (let i = 0; i < 5; i += 1) { await r.send(); r.clock.advance(61_000); }
  await assert.rejects(() => r.send(), {code: 'resource-exhausted'});
  assert.equal(r.mailer.sent.length, 5);
  r.clock.advance(3_600_000);
  assert.equal((await r.send()).resendAfterSeconds, 60);
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
  // The cooldown does not hand out the dead challenge.
  assert.deepEqual(await r.send(), {resendAfterSeconds: 60});
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
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-anon1'});
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
  assert.deepEqual(r.auth.calls[0], ['updateUser', 'anon1', {email: EMAIL, emailVerified: true}]);
});

test('the right code is single use and closes every other open challenge for the mailbox', async () => {
  const r = rig();
  await r.send();
  r.clock.advance(61_000);
  await r.send();
  r.clock.advance(61_000);
  await r.send('other@example.com');
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-anon1'});
  assert.equal(challenge(r, ID1), undefined);
  assert.equal(challenge(r, id(2)), undefined);
  assert.ok(challenge(r, id(3)), 'another mailbox is untouched');
  assert.equal(limits(r).sendCount, 2);
  await assert.rejects(() => r.verify(ID1), isExpired);
  await assert.rejects(() => r.verify(id(2)), isExpired);
});

// ------------------------------------------------------------------ accounts

test('an anonymous caller that is still anonymous keeps its uid', async () => {
  const r = rig();
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-anon1'});
  assert.deepEqual(r.auth.calls, [['updateUser', 'anon1', {email: EMAIL, emailVerified: true}]]);
});

test('a stale anonymous token whose user has since gained an email does not change that email', async () => {
  const r = rig({users: {anon1: {uid: 'anon1', email: 'owner@example.com', emailVerified: true, providerData: [{providerId: 'google.com'}]}}});
  await r.send();
  const result = await r.verify(ID1);
  assert.match(result.token, /^token-for-new/);
  assert.equal(r.auth.users.anon1.email, 'owner@example.com');
  assert.deepEqual(r.auth.calls.map(c => c[0]), ['createUser']);
  assert.equal(r.db.rows.has('signInUpgrades/anon1'), false);
});

test('a stale anonymous token is not upgraded when the user has a provider, a phone, is disabled or is gone', async () => {
  for (const record of [{providerData: [{providerId: 'phone'}]}, {phoneNumber: '+639170000000'}, {disabled: true}, null]) {
    const r = rig({users: record ? {anon1: {uid: 'anon1', ...record}} : {}});
    await r.send();
    const result = await r.verify(ID1);
    assert.match(result.token, /^token-for-new/, JSON.stringify(record));
    assert.ok(!r.auth.calls.some(c => c[0] === 'updateUser'), JSON.stringify(record));
  }
});

test('two verifications from one anonymous uid: only one upgrades it', async () => {
  const r = rig();
  await r.send('a@example.com');
  await r.send('b@example.com', {auth: caller('anonymous', 'anon1')});
  const [first, second] = await Promise.all([r.verify(ID1), r.verify(id(2))]);
  const upgrades = r.auth.calls.filter(c => c[0] === 'updateUser' && c[1] === 'anon1');
  assert.equal(upgrades.length, 1);
  assert.equal(r.auth.calls.filter(c => c[0] === 'createUser').length, 1);
  assert.deepEqual([first.token, second.token].sort(), ['token-for-anon1', 'token-for-new2'].sort());
  assert.ok(r.db.rows.has('signInUpgrades/anon1'));
});

test('a failed upgrade releases the lock so the caller can try again', async () => {
  const r = rig();
  await r.send();
  const original = r.auth.updateUser;
  r.auth.updateUser = async () => { throw Object.assign(new Error('transient'), {code: 'auth/internal-error'}); };
  await assert.rejects(() => r.verify(ID1));
  assert.equal(r.db.rows.has('signInUpgrades/anon1'), false);
  r.auth.updateUser = original;
  r.clock.advance(61_000);
  await r.send();
  assert.deepEqual(await r.verify(id(2)), {token: 'token-for-anon1'});
});

test('an existing unverified account is signed in as itself, verified, with its sessions revoked', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: false, disabled: false}, anon1: {uid: 'anon1'}}});
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u9'});
  assert.deepEqual(r.auth.calls, [['updateUser', 'u9', {emailVerified: true}], ['revoke', 'u9']]);
  assert.equal(r.auth.users.anon1.email, undefined);
});

test('a pre-registered password on an unverified account is unlinked and its sessions revoked', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: false, disabled: false,
    providerData: [{providerId: 'password'}, {providerId: 'phone'}]}}});
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u9'});
  assert.deepEqual(r.auth.calls, [['updateUser', 'u9', {emailVerified: true, providersToUnlink: ['password']}], ['revoke', 'u9']]);
  assert.deepEqual(r.auth.users.u9.providerData, [{providerId: 'phone'}]);
  assert.equal(r.auth.users.u9.emailVerified, true);
});

test('a verified account, even with a password, is left alone', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: false, providerData: [{providerId: 'password'}]}}});
  await r.send();
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u9'});
  assert.deepEqual(r.auth.calls, []);
  assert.deepEqual(r.auth.users.u9.providerData, [{providerId: 'password'}]);
});

test('a disabled account is refused', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: EMAIL, emailVerified: true, disabled: true}}});
  await r.send();
  await assert.rejects(() => r.verify(ID1), {code: 'permission-denied'});
});

test('a signed-in non-anonymous caller creates a new account for a new email', async () => {
  const google = caller('google.com', 'g1');
  const r = rig({users: {g1: {uid: 'g1', email: 'g@example.com'}}});
  await r.send(EMAIL, {auth: google});
  const result = await r.verify(ID1, CODE, {auth: google});
  assert.match(result.token, /^token-for-new/);
  assert.deepEqual(r.auth.calls[0], ['createUser', {email: EMAIL, emailVerified: true}]);
});

test('a lost race on the email falls back to the account that won, and cleans it if unverified', async () => {
  const r = rig();
  await r.send();
  const original = r.auth.updateUser;
  r.auth.updateUser = async (uid, props) => {
    if (uid === 'anon1') r.auth.users.u7 = {uid: 'u7', email: EMAIL, emailVerified: false, disabled: false, providerData: [{providerId: 'password'}]};
    return original(uid, props);
  };
  let first = true;
  const lookup = r.auth.getUserByEmail;
  r.auth.getUserByEmail = async email => {
    if (first) { first = false; throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'}); }
    return lookup(email);
  };
  assert.deepEqual(await r.verify(ID1), {token: 'token-for-u7'});
  assert.ok(r.auth.calls.some(c => c[0] === 'revoke' && c[1] === 'u7'));
  assert.deepEqual(r.auth.users.u7.providerData, []);
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

test('selected beta applicants and existing accounts use the reserved bucket', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: 'known@example.com'}}, send: {openCap: 1, reservedCap: 2}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  r.db.rows.set('betaApplications/b', {email: 'waiting@example.com', selected: false});
  const results = [];
  for (const email of ['beta@example.com', 'known@example.com', 'waiting@example.com', 'stranger@example.com']) {
    results.push(await r.send(email).then(value => value.resendAfterSeconds, e => e.code));
  }
  assert.deepEqual(results, [60, 60, 60, 'resource-exhausted']);
  assert.equal(r.db.rows.get('signInLimits/global-reserved-1970-01-01').count, 2);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 1);
});

test('a full bucket never blocks the other, and both cap-hit errors look the same', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: 'known@example.com'}}, send: {openCap: 1, reservedCap: 1}});
  await r.send('a@example.com');
  await assert.rejects(() => r.send('b@example.com'), {code: 'resource-exhausted'});
  await r.send('known@example.com');
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  const reservedFull = (await outcome(r.send('beta@example.com'))).error;
  const openFull = (await outcome(r.send('c@example.com'))).error;
  assert.equal(reservedFull.code, 'resource-exhausted');
  assert.equal(openFull.code, 'resource-exhausted');
  assert.equal(reservedFull.message, openFull.message);
  assert.deepEqual(reservedFull.details, openFull.details);
});

test('the reply for a known address has the same shape as for a stranger', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: 'known@example.com'}}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  const replies = [];
  for (const email of ['known@example.com', 'beta@example.com', 'stranger@example.com']) replies.push(await r.send(email));
  for (const reply of replies) assert.deepEqual(Object.keys(reply).sort(), ['challengeId', 'resendAfterSeconds']);
  assert.deepEqual(replies.map(x => x.resendAfterSeconds), [60, 60, 60]);
});

test('an Auth lookup failure falls back to the open bucket', async () => {
  const r = rig();
  r.auth.getUserByEmail = async () => { throw Object.assign(new Error('boom'), {code: 'auth/internal-error'}); };
  await r.send();
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 1);
});

test('aliases of one mailbox share one limit document, and the challenge keeps the exact address', async () => {
  const r = rig();
  assert.equal(codeDocId('a.b+x@gmail.com'), codeDocId('ab@googlemail.com'));
  assert.equal(codeDocId('Someone+tag@Example.com'), codeDocId('someone@example.com'));
  assert.notEqual(codeDocId('a.b@example.com'), codeDocId('ab@example.com'));
  await r.send('A.B+one@Gmail.com');
  assert.deepEqual(await r.send('ab+two@googlemail.com'), {challengeId: ID1, resendAfterSeconds: 60});
  assert.equal(r.mailer.sent.length, 1);
  assert.equal(r.mailer.sent[0].to, 'a.b+one@gmail.com');
  assert.equal(challenge(r).email, 'a.b+one@gmail.com');
  assert.equal([...r.db.rows.keys()].filter(path => path.startsWith('signInCodes/')).length, 1);
  for (let i = 0; i < 4; i += 1) { r.clock.advance(61_000); await r.send(`a.b+n${i}@gmail.com`); }
  r.clock.advance(61_000);
  await assert.rejects(() => r.send('ab@gmail.com'), {code: 'resource-exhausted'});
});

test('the account takes the exact typed address, not the canonical one', async () => {
  const r = rig();
  await r.send('a.b+x@gmail.com');
  await r.verify(ID1);
  assert.deepEqual(r.auth.calls[0], ['updateUser', 'anon1', {email: 'a.b+x@gmail.com', emailVerified: true}]);
});

test('the daily cap counts per Manila day, refuses at the cap and starts again the next day', async () => {
  const r = rig({send: {openCap: 3}});
  const emails = ['a@example.com', 'b@example.com', 'c@example.com', 'd@example.com'];
  for (const email of emails.slice(0, 3)) await r.send(email);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 3);
  await assert.rejects(() => r.send(emails[3]), {code: 'resource-exhausted'});
  assert.equal(r.mailer.sent.length, 3);
  assert.equal(r.db.rows.has(`signInCodes/${codeDocId(emails[3])}`), false);
  // A cooldown reply sends nothing and does not use a place.
  assert.equal((await r.send(emails[0])).resendAfterSeconds, 60);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 3);
  // 1970-01-01 16:00 UTC is already 1970-01-02 in Manila.
  r.clock.advance(16 * 3_600_000 - 1_000_000);
  await r.send(emails[3]);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-02').count, 1);
});

test('the daily cap warns once at 80 percent and refuses a bad cap', async () => {
  const alerts = [];
  const r = rig({send: {openCap: 10, alert: m => alerts.push(m)}});
  for (let i = 0; i < 10; i += 1) await r.send(`u${i}@example.com`);
  assert.deepEqual(alerts, ['Sign-in emails (open bucket) reached 80% of the daily cap (8 of 10).']);
  assert.equal(r.mailer.sent.length, 10);
  await assert.rejects(() => r.send('z@example.com'), {code: 'resource-exhausted'});
  const zero = rig({send: {openCap: 0}});
  await assert.rejects(() => zero.send(), {code: 'resource-exhausted'});
  assert.equal(zero.mailer.sent.length, 0);
});

test('the default open cap is 60 and the production file sets 20 and 40', async () => {
  const env = readFileSync(new URL('../.env.pantas-prod', import.meta.url), 'utf8');
  assert.match(env, /^SIGN_IN_DAILY_SEND_CAP=20$/m);
  assert.match(env, /^SIGN_IN_DAILY_RESERVED_CAP=40$/m);
  const r = rig();
  for (let i = 0; i < 60; i += 1) await r.send(`u${i}@example.com`);
  await assert.rejects(() => r.send('z@example.com'), {code: 'resource-exhausted'});
  assert.equal(r.mailer.sent.length, 60);
});
