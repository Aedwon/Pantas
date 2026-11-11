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
    getUserByEmail: async email => { const user = byEmail(email); if (!user) throw notFound(); return user; },
    createUser: async props => {
      calls.push(['createUser', props]);
      if (byEmail(props.email)) throw Object.assign(new Error('dup'), {code: 'auth/email-already-exists'});
      const uid = `new${calls.length}`;
      users[uid] = {uid, disabled: false, ...props};
      return users[uid];
    },
    createCustomToken: async uid => `token-for-${uid}`,
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

test('an existing unverified or disabled account is refused and left untouched', async () => {
  const messages = [];
  for (const record of [{emailVerified: false, disabled: false, providerData: [{providerId: 'password'}]},
    {emailVerified: true, disabled: true}, {emailVerified: false, disabled: true}]) {
    const r = rig({users: {u9: {uid: 'u9', email: EMAIL, ...record}}});
    const before = JSON.stringify(r.auth.users.u9);
    await r.send();
    const error = (await outcome(r.verify(ID1))).error;
    assert.equal(error.code, 'permission-denied');
    messages.push(error.message);
    assert.deepEqual(r.auth.calls, []);
    assert.equal(JSON.stringify(r.auth.users.u9), before);
  }
  assert.deepEqual(new Set(messages), new Set(["This account can't sign in. Write to support@pantas.study."]));
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

test('a lost race on creation is refused if the winner is unverified', async () => {
  const r = rig();
  await r.send();
  const lookup = r.auth.getUserByEmail;
  let first = true;
  r.auth.getUserByEmail = async email => {
    if (first) { first = false; throw Object.assign(new Error('nope'), {code: 'auth/user-not-found'}); }
    return lookup(email);
  };
  r.auth.users.u7 = {uid: 'u7', email: EMAIL, emailVerified: false, disabled: false};
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

test('only selected beta applicants use the reserved bucket', async () => {
  const r = rig({users: {u9: {uid: 'u9', email: 'known@example.com'}}, send: {openCap: 2, reservedCap: 1}});
  r.db.rows.set('betaApplications/a', {email: 'beta@example.com', selected: true});
  r.db.rows.set('betaApplications/b', {email: 'waiting@example.com', selected: false});
  for (const email of ['beta@example.com', 'known@example.com', 'waiting@example.com', 'stranger@example.com']) await r.send(email);
  assert.equal(r.db.rows.get('signInLimits/global-reserved-1970-01-01').count, 1);
  assert.equal(r.db.rows.get('signInLimits/global-open-1970-01-01').count, 2);
  assert.equal(r.mailer.sent.length, 3);
  assert.deepEqual(r.mailer.sent.map(m => m.to), ['beta@example.com', 'known@example.com', 'waiting@example.com']);
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
