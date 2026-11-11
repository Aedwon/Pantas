import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';
import {renderWrappedPage} from '../lib/renderWrappedPage.js';
const id = 'c'.repeat(32), ownerUid = 'wrapped-reader-owner';
async function read(suffix = '/card.png') {
  const result = {headers: {}};
  const res = {status(code) {result.code = code; return this;}, set(headers) {Object.assign(result.headers, headers); return this;}, send(body) {result.body = body; return this;}};
  await renderWrappedPage({path: `/wrapped/${id}${suffix}`, header: () => ''}, res);
  return result;
}
test('share reader ignores forged stored paths and refuses invalid owners and revoked shares', async () => {
  const bucket = getStorage().bucket('demo-pantas-test.appspot.com');
  const ref = getFirestore().doc(`wrapped_shares/${id}`);
  await bucket.file('private/known-secret.png').save(Buffer.from('SECRET'));
  await bucket.file(`wrapped/${ownerUid}/${id}.png`).save(Buffer.from('OWN'));
  await ref.set({ownerUid, revoked: false, storagePath: 'private/known-secret.png'});
  const out = await read();
  assert.equal(out.code, 200);
  assert.equal(out.body.toString(), 'OWN');
  await ref.update({ownerUid: '../private'});
  assert.equal((await read()).body.toString().includes('SECRET'), false);
  await ref.update({ownerUid, revoked: true});
  assert.equal((await read()).body.toString().includes('OWN'), false);
});

for (const state of ['withdrawn', 'deleting', 'closed']) {
  for (const suffix of ['', '/card.png']) {
    test(`Wrapped ${suffix || 'page'} refuses owner ${state}`, async () => {
      const db = getFirestore(), uid = `wrapped-blocked-${state}`;
      await db.doc(`wrapped_shares/${id}`).set({ownerUid: uid, archetypeId: 'secret_archetype'});
      await getStorage().bucket().file(`wrapped/${uid}/${id}.png`).save(Buffer.from('PRIVATE_CARD'));
      if (state === 'withdrawn') await db.doc(`users/${uid}/server/guardianConsent`).set({status: 'withdrawn'});
      else await db.doc(`accountDeletions/${uid}`).set(state === 'closed' ? {} : {reason: 'guardian_withdrawal'});
      const out = await read(suffix);
      assert.doesNotMatch(out.body.toString(), /PRIVATE_CARD|Secret Archetype|og:image/);
      assert.equal(out.headers['Cache-Control'], 'no-store');
    });
  }
}
test('live Wrapped page and image cannot be cached across withdrawal', async () => {
  await getFirestore().doc(`wrapped_shares/${id}`).set({ownerUid});
  for (const suffix of ['', '/card.png']) assert.equal((await read(suffix)).headers['Cache-Control'], 'no-store');
});
