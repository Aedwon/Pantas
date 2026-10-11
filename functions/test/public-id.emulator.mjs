import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import '../lib/index.js';
import {recordSignInEvent, deleteAccount} from '../lib/index.js';

assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
const db = getFirestore();
const auth = getAuth();
const module = () => import('../lib/publicId.js');
const named = uid => ({uid, token:{firebase:{sign_in_provider:'google.com'}}});

test('R-5 TS check digit matches the shared vectors', async () => {
  const {isValidPublicId} = await module();
  const vectors = JSON.parse(readFileSync(new URL('../../test/fixtures/public_id_vectors.json', import.meta.url)));
  for (const vector of vectors) assert.equal(isValidPublicId(vector.digits), vector.valid, vector.digits);
});

test('R-5 concurrent creation preserves one ID per account and retries collisions', async () => {
  const {ensurePublicId} = await module();
  const uid = 'public-id-concurrent';
  await db.recursiveDelete(db.doc('users/' + uid));
  const results = await Promise.all(Array.from({length:12}, () => ensurePublicId(db, named(uid))));
  assert.equal(new Set(results).size, 1);
  const id = results[0];
  assert.equal((await db.doc('publicIds/' + id).get()).get('uid'), uid);
  assert.equal((await db.doc('users/' + uid).get()).get('publicId'), id);
  const other = 'public-id-collision';
  await db.recursiveDelete(db.doc('users/' + other));
  const sequence = [id, '876543216'];
  await db.doc('publicIds/876543216').delete();
  await db.doc('retiredPublicIds/876543216').delete();
  assert.equal(await ensurePublicId(db, named(other), () => sequence.shift()), '876543216');
});

test('R-5 anonymous and non-Google identities get no ID', async () => {
  const {ensurePublicId} = await module();
  for (const provider of ['anonymous', 'password']) {
    const uid = 'public-id-' + provider;
    await db.recursiveDelete(db.doc('users/' + uid));
    assert.equal(await ensurePublicId(db, {uid, token:{firebase:{sign_in_provider:provider}}}), null);
    assert.equal((await db.doc('users/' + uid).get()).exists, false);
  }
});

test('R-5 ensurePublicId still runs when the sign-in audit is rate limited', async () => {
  const uid = 'public-id-sign-in';
  await db.recursiveDelete(db.doc('users/' + uid));
  await db.doc('users/' + uid + '/limits/signInAudit').set({windowStartedAt:Timestamp.now(), count:1});
  const response = await recordSignInEvent.run({data:{}, auth:named(uid), app:{appId:'demo-app'}});
  assert.equal(response.logged, false);
  assert.match((await db.doc('users/' + uid).get()).get('publicId'), /^[1-9][0-9]{8}$/);
});

test('R-5 lookup requires admin and App Check and records the resolution', async () => {
  const {lookupPublicId} = await import('../lib/publicIdAdmin.js');
  const {ensurePublicId} = await module();
  const uid = 'public-id-lookup';
  const id = await ensurePublicId(db, named(uid));
  for (const request of [{}, {auth:named(uid), app:{appId:'demo-app'}},
    {auth:{uid:'public-id-admin', token:{admin:true}}}]) {
    await assert.rejects(() => lookupPublicId(request, id), {code:'permission-denied'});
  }
  assert.equal(await lookupPublicId({auth:{uid:'public-id-admin',token:{admin:true}},app:{appId:'demo-app'}}, id), uid);
  const logs = await db.collection('audit_logs').where('uid','==','public-id-admin').where('event','==','publicIdLookup').get();
  assert.ok(logs.docs.some(doc => doc.get('metadata.publicId') === id && doc.get('metadata.targetUid') === uid));
});

test('R-5 deletion retires before Auth deletion, prevents recreation and never reissues', async () => {
  const {ensurePublicId, retirePublicId} = await module();
  const uid = 'public-id-delete';
  try {await auth.deleteUser(uid);} catch (error) {assert.equal(error.code,'auth/user-not-found');}
  await auth.createUser({uid});
  await db.recursiveDelete(db.doc('users/' + uid));
  const id = await ensurePublicId(db, named(uid));
  await retirePublicId(db, uid);
  assert.equal(await ensurePublicId(db, named(uid)), null);
  assert.equal((await db.doc('publicIds/' + id).get()).exists, false);
  assert.equal((await db.doc('retiredPublicIds/' + id).get()).exists, true);
  await db.recursiveDelete(db.doc('users/' + uid));
  assert.equal(await ensurePublicId(db, named(uid)), null,
    'data cleanup before Auth deletion must not permit a replacement ID');
  // Exercise the real handler's final retirement path with a fresh ID too.
  const handlerUid = 'public-id-delete-handler';
  try {await auth.deleteUser(handlerUid);} catch (error) {assert.equal(error.code,'auth/user-not-found');}
  await auth.createUser({uid:handlerUid});
  await db.recursiveDelete(db.doc('users/' + handlerUid));
  const nextId = await ensurePublicId(db, named(handlerUid));
  await deleteAccount.run({data:{}, auth:{...named(handlerUid),token:{...named(handlerUid).token,auth_time:Math.floor(Date.now()/1000)}},app:{appId:'demo-app'}});
  assert.equal((await db.doc('publicIds/' + nextId).get()).exists, false);
  assert.equal((await db.doc('retiredPublicIds/' + nextId).get()).exists, true);
  await assert.rejects(() => auth.getUser(handlerUid), {code:'auth/user-not-found'});
  await auth.deleteUser(uid);
  const sequence = [id, nextId, '100000009'];
  await db.doc('publicIds/100000009').delete();
  await db.doc('retiredPublicIds/100000009').delete();
  await db.recursiveDelete(db.doc('users/public-id-after-delete'));
  assert.equal(await ensurePublicId(db, named('public-id-after-delete'), () => sequence.shift()), '100000009');
});

test('R-5 deletion before first ID allocation prevents a late sign-in from creating an orphan mapping', async () => {
  const {ensurePublicId,retirePublicId} = await module();
  const uid = 'public-id-delete-before-first-id';
  await db.recursiveDelete(db.doc('users/'+uid));
  await retirePublicId(db,uid);
  await db.recursiveDelete(db.doc('users/'+uid));
  assert.equal(await ensurePublicId(db,named(uid)),null);
  assert.equal((await db.collection('publicIds').where('uid','==',uid).get()).empty,true);
});
