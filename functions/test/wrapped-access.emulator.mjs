import '../lib/index.js';
import assert from 'node:assert/strict';
import test from 'node:test';
import {getFirestore} from 'firebase-admin/firestore';
import {getStorage} from 'firebase-admin/storage';
import {renderWrappedPage} from '../lib/renderWrappedPage.js';
const id = 'c'.repeat(32), ownerUid = 'wrapped-reader-owner';
async function read() {
  const result = {};
  const res = {status(code) {result.code = code; return this;}, set() {return this;}, send(body) {result.body = body; return this;}};
  await renderWrappedPage({path: `/wrapped/${id}/card.png`, header: () => ''}, res);
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
