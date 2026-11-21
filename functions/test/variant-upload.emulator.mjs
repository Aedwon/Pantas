import assert from 'node:assert/strict';
import test from 'node:test';
import {initializeApp, deleteApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import * as upload from '../lib/contentUpload.js';

test('plans variant and Pro documents without writing during a dry run', async () => {
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  const app = initializeApp({projectId: 'demo-pantas-test'}, 'variant-upload');
  try {
    const db = getFirestore(app);
    const id = 'qt-upload-dry-run';
    const {item, pro} = upload.variantItems(
      {id, exams: ['cse-pro'], variants: []},
      {rationales: {}},
    );
    const freeRef = db.doc(`content/variants/items/${id}`);
    const proRef = db.doc(`contentPro/${id}`);
    const dryRun = await upload.writeContent(db, [item], [pro], {dryRun: true});
    assert.deepEqual(dryRun, {counts: {create: 1, update: 0, unchanged: 0}, proWritten: 1});
    assert.equal((await freeRef.get()).exists, false);
    assert.equal((await proRef.get()).exists, false);

    try {
      await upload.writeContent(db, [item], [pro], {});
      assert.equal((await freeRef.get()).get('version'), (await proRef.get()).get('version'));
      const retry = await upload.writeContent(db, [item], [pro], {dryRun: true});
      assert.equal(retry.counts.unchanged, 1);
    } finally {
      await Promise.all([freeRef.delete(), proRef.delete()]);
    }
  } finally {
    await deleteApp(app);
  }
});
