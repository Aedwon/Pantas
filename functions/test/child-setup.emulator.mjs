import {setTestSecrets} from './_secrets-helper.mjs';
import '../lib/index.js';
import assert from 'node:assert/strict';
import test, {beforeEach} from 'node:test';
import {getAuth} from 'firebase-admin/auth';
import {getFirestore} from 'firebase-admin/firestore';
import {CHILD_LIMIT, listChildrenFor, openSession, setNickname, setupChild} from '../lib/childSetup.js';
import {checkGuardianCode, sendGuardianCode} from '../lib/guardianCodeGate.js';
import {CHILD_NOTICE_VERSION, GUARDIAN_DOCUMENT_VERSIONS, GUARDIAN_TICK_TEXT_VERSIONS} from '../lib/guardianConsent.js';
import {createCheckout} from '../lib/paymongoCheckout.js';

setTestSecrets();
assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
const db = getFirestore();
const auth = getAuth();
const KEY = 'child-setup-emulator-key';
const T0 = Date.parse('2026-11-19T10:00:00+08:00');
const HOLDER = 'cs-holder';
const EMAIL = 'maria.setup@example.test';
const app = {appId: 'app', token: {}, alreadyConsumed: false};
const named = (uid, provider = 'custom') => ({uid, token: {firebase: {sign_in_provider: provider}, email_verified: true}});
const as = (uid, data, provider) => ({auth: named(uid, provider), app, data});
const rejected = async promise => { try { await promise; return null; } catch (e) { return e; } };
const reasonOf = e => e?.details?.reason;

const versions = {tick1TextVersion: GUARDIAN_TICK_TEXT_VERSIONS.tick1, tick2TextVersion: GUARDIAN_TICK_TEXT_VERSIONS.tick2,
  termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms, childNoticeVersion: CHILD_NOTICE_VERSION};

let clock;
let sent;
let open;
let n;
const deps = (over = {}) => ({db, auth, now: () => clock, open: () => open, allow: async () => true, dailyCap: 100,
  linkOrigin: 'https://app.example.test/', mailer: {send: async m => { sent.push(m); }}, ...over});

const wipeUser = async uid => {
  await db.recursiveDelete(db.doc(`users/${uid}`));
  await db.recursiveDelete(db.doc(`guardianConsentEvidence/${uid}`));
  try { await auth.deleteUser(uid); } catch { /* absent */ }
};
const createdChildren = [];
const cleanupChildren = async () => {
  for (const uid of createdChildren.splice(0)) await wipeUser(uid);
};
const setup = async (uid, data = {}, over = {}) => {
  const result = await setupChild(as(uid, {...versions, ...data}), deps(over));
  createdChildren.push(result.childUid);
  return result;
};
const itemsOf = holder => db.collection(`users/${holder}/server/children/items`);
const entryOf = async (holder, child) => (await itemsOf(holder).doc(child).get()).data();

beforeEach(async () => {
  clock = T0; sent = []; open = true; n = 0;
  await cleanupChildren();
  await db.recursiveDelete(db.collection('guardianCodeProofs'));
  await db.recursiveDelete(db.collection('guardianLimits'));
  await wipeUser(HOLDER);
  await wipeUser('cs-holder-two');
  await auth.createUser({uid: HOLDER, email: EMAIL, emailVerified: true});
  await auth.createUser({uid: 'cs-holder-two', email: 'two.setup@example.test', emailVerified: true});
});

/** Makes a holder with `count` active children straight in the database, as setup would have left it. */
const seedChildren = async (count, holder = HOLDER) => {
  await db.doc(`users/${holder}/server/holder`).set({createdAt: T0});
  const ids = [];
  for (let i = 0; i < count; i += 1) {
    const childUid = `cs-seed-${holder}-${i}`;
    ids.push(childUid);
    await itemsOf(holder).doc(childUid).set({childUid, nickname: `Kid${i}`, active: true, siblingOpenWithoutCode: false, createdAt: T0 + i});
    await db.doc(`users/${childUid}/server/childLink`).set({holderUid: holder});
  }
  return ids;
};
const wipeSeeds = async ids => { for (const id of ids) await db.recursiveDelete(db.doc(`users/${id}`)); };
/** A proof as the real gate would have left it. */
const proofFor = async (holderUid, action, childId) => {
  const id = String(++n + 1000).padStart(32, '0');
  await db.doc(`guardianCodeProofs/${id}`).set({holderUid, childId, action,
    expiresAt: new Date(clock + 5 * 60_000), purgeAt: new Date(clock + 86_400_000)});
  return id;
};

test('the server flag closed refuses setup and writes nothing', async () => {
  open = false;
  const e = await rejected(setupChild(as(HOLDER, versions), deps()));
  assert.equal(e.code, 'failed-precondition');
  assert.equal(reasonOf(e), 'child-accounts-closed');
  assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).exists, false);
});

test('an anonymous caller, an unverified or emailless caller and a child caller are refused', async () => {
  const anon = await rejected(setupChild(as('cs-anon', versions, 'anonymous'), deps()));
  assert.equal(anon.code, 'permission-denied');
  assert.equal(reasonOf(anon), 'named-sign-in-required');
  await auth.createUser({uid: 'cs-unverified', email: 'unverified.setup@example.test', emailVerified: false});
  assert.equal(reasonOf(await rejected(setupChild(as('cs-unverified', versions), deps()))), 'named-sign-in-required');
  await auth.createUser({uid: 'cs-noemail'});
  assert.equal(reasonOf(await rejected(setupChild(as('cs-noemail', versions), deps()))), 'named-sign-in-required');
  const [kid] = await seedChildren(1);
  const child = await rejected(setupChild(as(kid, versions), deps()));
  assert.equal(child.code, 'permission-denied');
  assert.equal(reasonOf(child), 'child-cannot-set-up');
  await wipeSeeds([kid]);
  for (const uid of ['cs-unverified', 'cs-noemail']) await auth.deleteUser(uid);
});

test('a token without App Check is refused', async () => {
  const e = await rejected(setupChild({auth: named(HOLDER), data: versions}, deps()));
  assert.equal(e.code, 'unauthenticated');
});

test('an account with a profile, study data, a pass or a consent record is refused with the spec message', async () => {
  const cases = {
    profile: uid => db.doc(`users/${uid}`).set({createdAt: T0, displayName: 'Maria'}),
    answers: uid => db.doc(`users/${uid}/server/answers`).set({n: 1}),
    acceptance: uid => db.doc(`users/${uid}/server/acceptance`).set({at: T0}),
    entitlement: uid => db.doc(`users/${uid}/server/entitlement`).set({pro: true}),
    grant: uid => db.doc(`users/${uid}/grants/g1`).set({state: 'active'}),
    syncRows: uid => db.doc(`users/${uid}/sync_generations/g1`).set({status: 'active'}),
    consent: uid => db.doc(`users/${uid}/server/guardianConsent`).set({ageGroup: 'minor', status: 'confirmed'}),
    claim: uid => auth.setCustomUserClaims(uid, {pro: true, proUntil: T0 + 1e9}),
  };
  for (const [name, seed] of Object.entries(cases)) {
    await wipeUser(HOLDER);
    await auth.createUser({uid: HOLDER, email: EMAIL, emailVerified: true});
    await seed(HOLDER);
    const e = await rejected(setupChild(as(HOLDER, versions), deps()));
    assert.equal(e?.code, 'failed-precondition', name);
    assert.equal(reasonOf(e), 'email-has-account', name);
    assert.equal(e.message, 'This email already has a Pantas account. Use another email.', name);
    assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).exists, false, name);
  }
});

test('an empty named account becomes the holder; a root document with only createdAt, rate limits and a Google sign-in still count as empty', async () => {
  await db.doc(`users/${HOLDER}`).set({createdAt: T0, lastSeenAt: T0});
  await db.doc(`users/${HOLDER}/limits/setupChildAccount`).set({count: 1});
  const result = await setup(HOLDER);
  assert.equal(typeof result.childUid, 'string');
  assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).get('createdAt'), T0);
  const viaGoogle = await setup('cs-holder-two', {}, {});
  assert.ok(viaGoogle.childUid);
  assert.equal((await db.doc('users/cs-holder-two/server/holder').get()).exists, true);
});

test('the first child writes the exact link documents, the consent record, claims and evidence, and returns a token', async () => {
  const {childUid, customToken} = await setup(HOLDER, {nickname: '  Ana  '});
  assert.ok(customToken.length > 20);
  const entry = await entryOf(HOLDER, childUid);
  assert.equal(entry.childUid, childUid);
  assert.equal(entry.nickname, 'Ana');
  assert.equal(entry.active, true);
  assert.equal(entry.siblingOpenWithoutCode, false);
  assert.equal(entry.createdAt, T0);
  assert.deepEqual((await db.doc(`users/${childUid}/server/childLink`).get()).data(), {holderUid: HOLDER});
  const consent = (await db.doc(`users/${childUid}/server/guardianConsent`).get()).data();
  assert.equal(consent.ageGroup, 'child');
  assert.equal(consent.method, 'guardian_held');
  assert.equal(consent.status, 'confirmed');
  assert.equal(consent.holderUid, HOLDER);
  assert.equal(consent.sharingAllowed, false);
  const evidence = await db.collection(`guardianConsentEvidence/${childUid}/responses`).get();
  assert.equal(evidence.size, 1);
  const e = evidence.docs[0].data();
  assert.equal(e.ageGroup, 'child');
  assert.equal(e.method, 'guardian_held');
  assert.equal(e.holderUid, HOLDER);
  assert.equal(e.childUid, childUid);
  assert.deepEqual(e.link, {holderUid: HOLDER, childUid});
  assert.equal(e.decidedAt, T0);
  assert.deepEqual(e.documentVersions, {...GUARDIAN_DOCUMENT_VERSIONS, child: CHILD_NOTICE_VERSION});
  assert.deepEqual(e.tickTextVersions, {tick1: GUARDIAN_TICK_TEXT_VERSIONS.tick1, tick2: GUARDIAN_TICK_TEXT_VERSIONS.tick2});
  assert.ok(!JSON.stringify(e).includes(EMAIL));
  const user = await auth.getUser(childUid);
  assert.equal(user.email, undefined);
  assert.equal(user.passwordHash, undefined);
  assert.equal(user.providerData.length, 0);
  assert.deepEqual(user.customClaims, {ageGroup: 'child', holder: HOLDER});
  assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).exists, true);
});

test('without a nickname the child is listed with an empty one and no receipt goes out; the nickname step sends it once', async () => {
  const {childUid} = await setup(HOLDER);
  assert.equal((await entryOf(HOLDER, childUid)).nickname, '');
  assert.equal(sent.length, 0);
  const listed = await listChildrenFor(as(childUid, {}), deps());
  assert.deepEqual(listed.children.map(c => c.nickname), ['']);
  const first = await setNickname(as(childUid, {childId: childUid, nickname: ' Ana '}), deps());
  assert.deepEqual(first, {nickname: 'Ana'});
  assert.equal(sent.length, 1);
  const mail = sent[0];
  assert.equal(mail.to, EMAIL);
  assert.equal(mail.subject, 'Pantas account for Ana');
  assert.ok(mail.text.startsWith('Hi,\n\nYou set up a Pantas account for Ana on Nov 19, 2026. You accepted the Terms and agreed to ' +
    'the Child Notice (version 2026-11-19). If you want to delete Ana\'s account and data, use the button below. ' +
    'You can also do this in the app under "For parents." We send one email for each child.'), mail.text);
  assert.ok(mail.text.includes(`https://app.example.test/parents/delete?child=${childUid}`));
  assert.ok(!/token/i.test(mail.text));
  assert.ok(mail.html.includes('Delete account'));
  await setNickname(as(childUid, {childId: childUid, nickname: 'Anna'}), deps());
  assert.equal(sent.length, 1);
  assert.equal((await entryOf(HOLDER, childUid)).nickname, 'Anna');
});

test('a nickname given at setup sends the receipt at setup, and a failed mail is retried at the next nickname change', async () => {
  const failing = {mailer: {send: async () => { throw new Error('down'); }}};
  const {childUid} = await setup(HOLDER, {nickname: 'Ana'}, failing);
  assert.equal((await entryOf(HOLDER, childUid)).receiptSentAt, undefined);
  assert.equal((await db.doc('guardianLimits/global-2026-11-19').get()).get('count') ?? 0, 0);
  await setNickname(as(childUid, {childId: childUid, nickname: 'Ana'}), deps());
  assert.equal(sent.length, 1);
  assert.equal((await db.doc('guardianLimits/global-2026-11-19').get()).get('count'), 1);
});

test('the receipt shares the guardian daily cap: when it is full setup still works and no mail goes out', async () => {
  await db.doc('guardianLimits/global-2026-11-19').set({count: 3});
  const {childUid} = await setup(HOLDER, {nickname: 'Ana'}, {dailyCap: 3});
  assert.ok(childUid);
  assert.equal(sent.length, 0);
  assert.equal((await db.doc('guardianLimits/global-2026-11-19').get()).get('count'), 3);
});

test('nicknames are trimmed, 1 to 30 characters, with no markup, links, addresses or control characters', async () => {
  for (const bad of ['   ', 'x'.repeat(31), '<b>Ana</b>', 'ana@example.com', 'see http://x.test', 'two\nlines', 'a.b']) {
    const e = await rejected(setupChild(as(HOLDER, {...versions, nickname: bad}), deps()));
    assert.equal(e?.code, 'invalid-argument', JSON.stringify(bad));
  }
  assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).exists, false);
  const {childUid} = await setup(HOLDER, {nickname: 'x'.repeat(30)});
  const empty = await rejected(setNickname(as(childUid, {childId: childUid, nickname: ''}), deps()));
  assert.equal(empty.code, 'invalid-argument');
  const other = await rejected(setNickname(as(HOLDER, {childId: childUid, nickname: 'Hi'}), deps()));
  assert.equal(other.code, 'permission-denied');
  assert.equal(reasonOf(other), 'not-linked');
});

test('both tick versions, the Terms version and the Child Notice version must be the current ones', async () => {
  for (const field of ['tick1TextVersion', 'tick2TextVersion', 'termsVersion', 'childNoticeVersion']) {
    for (const bad of ['2020-01-01', undefined, 5]) {
      const e = await rejected(setupChild(as(HOLDER, {...versions, [field]: bad}), deps()));
      assert.equal(e?.code, 'failed-precondition', `${field}=${bad}`);
      assert.equal(reasonOf(e), 'stale-consent-text', `${field}=${bad}`);
    }
  }
  assert.equal((await db.doc(`users/${HOLDER}/server/holder`).get()).exists, false);
});

test('a second child needs a valid proof for addChild; the proof is used up and a wrong one burns nothing', async () => {
  const first = await setup(HOLDER, {nickname: 'Ana'});
  assert.equal(reasonOf(await rejected(setupChild(as(HOLDER, versions), deps()))), 'guardian-proof-invalid');
  const wrongAction = await proofFor(HOLDER, 'delete', first.childUid);
  assert.equal(reasonOf(await rejected(setupChild(as(HOLDER, {...versions, guardianProofId: wrongAction}), deps()))), 'guardian-proof-invalid');
  const otherHolder = await proofFor('someone-else', 'addChild', null);
  assert.equal(reasonOf(await rejected(setupChild(as(HOLDER, {...versions, guardianProofId: otherHolder}), deps()))), 'guardian-proof-invalid');
  const good = await proofFor(HOLDER, 'addChild', null);
  const second = await setup(HOLDER, {guardianProofId: good, nickname: 'Ben'});
  assert.notEqual(second.childUid, first.childUid);
  assert.equal(reasonOf(await rejected(setupChild(as(HOLDER, {...versions, guardianProofId: good}), deps()))), 'guardian-proof-invalid');
  assert.equal((await itemsOf(HOLDER).get()).size, 2);
});

test('the proof comes from the real gate: a code mailed to the holder, verified inside a child session', async () => {
  const first = await setup(HOLDER, {nickname: 'Ana'});
  sent.length = 0;
  const gate = {db, auth, key: KEY, now: () => clock, allow: async () => true, dailyCap: 100, random: () => 123456,
    mailer: {send: async m => { sent.push(m); }}};
  await sendGuardianCode(as(first.childUid, {action: 'addChild'}), gate);
  clock += 61_000;
  const {proof} = await checkGuardianCode(as(first.childUid, {action: 'addChild', code: '123456'}), gate);
  const second = await setup(HOLDER, {guardianProofId: proof});
  assert.ok(second.childUid);
});

test('the sixth child is refused with child-limit and burns no proof', async () => {
  const ids = await seedChildren(CHILD_LIMIT);
  const proof = await proofFor(HOLDER, 'addChild', null);
  const e = await rejected(setupChild(as(HOLDER, {...versions, guardianProofId: proof}), deps()));
  assert.equal(e.code, 'failed-precondition');
  assert.equal(reasonOf(e), 'child-limit');
  assert.equal((await db.doc(`guardianCodeProofs/${proof}`).get()).exists, true);
  assert.equal((await itemsOf(HOLDER).get()).size, CHILD_LIMIT);
  await wipeSeeds(ids);
});

test('an inactive child does not count toward the limit', async () => {
  const ids = await seedChildren(CHILD_LIMIT);
  await itemsOf(HOLDER).doc(ids[0]).set({active: false}, {merge: true});
  const proof = await proofFor(HOLDER, 'addChild', null);
  const added = await setup(HOLDER, {guardianProofId: proof});
  assert.ok(added.childUid);
  await wipeSeeds(ids);
});

test('listChildren: the holder and a linked child see active children and a masked email; anyone else is refused', async () => {
  const ids = await seedChildren(2);
  await itemsOf(HOLDER).doc(ids[1]).set({siblingOpenWithoutCode: true}, {merge: true});
  await itemsOf(HOLDER).doc('gone').set({childUid: 'gone', nickname: 'Gone', active: false, siblingOpenWithoutCode: false, createdAt: T0});
  for (const caller of [HOLDER, ids[0]]) {
    const result = await listChildrenFor(as(caller, {}), deps());
    assert.deepEqual(result, {maskedHolderEmail: 'm***@e***.test', children: [
      {childUid: ids[0], nickname: 'Kid0', siblingOpenWithoutCode: false},
      {childUid: ids[1], nickname: 'Kid1', siblingOpenWithoutCode: true}]});
    assert.ok(!JSON.stringify(result).includes('maria'));
  }
  const stranger = await rejected(listChildrenFor(as('cs-stranger', {}), deps()));
  assert.equal(stranger.code, 'permission-denied');
  assert.equal(reasonOf(stranger), 'not-linked');
  await wipeSeeds(ids);
});

test('openChildSession: the holder needs no code; a sibling needs a switchInto proof unless the target opted in', async () => {
  const [a, b] = await seedChildren(2);
  const asHolder = await openSession(as(HOLDER, {childId: a}), deps());
  assert.ok(asHolder.customToken.length > 20);
  const noProof = await rejected(openSession(as(a, {childId: b}), deps()));
  assert.equal(noProof.code, 'permission-denied');
  assert.equal(reasonOf(noProof), 'guardian-proof-invalid');
  const forWrongChild = await proofFor(HOLDER, 'switchInto', a);
  assert.equal(reasonOf(await rejected(openSession(as(a, {childId: b, guardianProofId: forWrongChild}), deps()))), 'guardian-proof-invalid');
  const good = await proofFor(HOLDER, 'switchInto', b);
  assert.ok((await openSession(as(a, {childId: b, guardianProofId: good}), deps())).customToken);
  assert.equal(reasonOf(await rejected(openSession(as(a, {childId: b, guardianProofId: good}), deps()))), 'guardian-proof-invalid');
  await itemsOf(HOLDER).doc(b).set({siblingOpenWithoutCode: true}, {merge: true});
  assert.ok((await openSession(as(a, {childId: b}), deps())).customToken);
  // The opt-in belongs to the child that turned it on only.
  assert.equal(reasonOf(await rejected(openSession(as(b, {childId: a}), deps()))), 'guardian-proof-invalid');
  await wipeSeeds([a, b]);
});

test('openChildSession refuses strangers, other families, inactive children and bad input', async () => {
  const [a] = await seedChildren(1);
  const [x] = await seedChildren(1, 'cs-holder-two');
  assert.equal(reasonOf(await rejected(openSession(as('cs-stranger', {childId: a}), deps()))), 'not-linked');
  assert.equal(reasonOf(await rejected(openSession(as(x, {childId: a}), deps()))), 'not-linked');
  assert.equal(reasonOf(await rejected(openSession(as('cs-holder-two', {childId: a}), deps()))), 'not-linked');
  assert.equal(reasonOf(await rejected(openSession(as(HOLDER, {childId: 'nobody'}), deps()))), 'not-linked');
  assert.equal((await rejected(openSession(as(HOLDER, {}), deps()))).code, 'invalid-argument');
  await itemsOf(HOLDER).doc(a).set({active: false}, {merge: true});
  assert.equal(reasonOf(await rejected(openSession(as(HOLDER, {childId: a}), deps()))), 'not-linked');
  await wipeSeeds([a, x]);
});

test('a withdrawn child cannot be opened', async () => {
  const [a] = await seedChildren(1);
  await db.doc(`users/${a}/server/guardianConsent`).set({status: 'withdrawn', ageGroup: 'child'});
  const e = await rejected(openSession(as(HOLDER, {childId: a}), deps()));
  assert.equal(e.code, 'permission-denied');
  await wipeSeeds([a]);
});

test('a holder cannot check out, and nothing is reserved', async () => {
  await db.doc(`users/${HOLDER}/server/holder`).set({createdAt: T0});
  const unreachable = async () => { throw new Error('must not be reached'); };
  const client = {createCheckoutSession: unreachable, getCheckoutSession: unreachable};
  const e = await rejected(createCheckout(named(HOLDER), {product: 'pantas_cs_monthly'},
    {client, db, origin: 'https://app.example.test', methods: ['card'], allow: async () => true, now: () => clock}));
  assert.equal(e.code, 'permission-denied');
  assert.equal(reasonOf(e), 'holder-cannot-buy');
  assert.equal((await db.collection(`users/${HOLDER}/pendingCheckouts`).get()).size, 0);
});
