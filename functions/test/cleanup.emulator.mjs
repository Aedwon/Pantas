import assert from 'node:assert/strict';
import test, { before, after, mock } from 'node:test';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

const DAY = 86400000;
const uids = ['cleanup-active', 'cleanup-orphan', 'cleanup-root', 'cleanup-nested', 'cleanup-shared', 'cleanup-named'];
const names = ['wrapped/cleanup-owner/orphan.png', 'wrapped/cleanup-owner/upload/orphan.png',
  'wrapped/cleanup-owner/shared.png', 'other/cleanup-control.png'];
let endpoints;
let db;
let bucket;

before(async () => {
  assert.equal(process.env.GCLOUD_PROJECT, 'demo-pantas-test');
  assert.ok(process.env.FIRESTORE_EMULATOR_HOST);
  assert.ok(process.env.FIREBASE_AUTH_EMULATOR_HOST);
  assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST);
  initializeApp({ projectId: 'demo-pantas-test', storageBucket: 'demo-pantas-test.appspot.com' });
  endpoints = await import('../lib/index.js');
  db = getFirestore();
  bucket = getStorage().bucket();
});
after(async () => {
  mock.restoreAll();
  if (!db || !bucket) return;
  for (const uid of uids) {
    try { await getAuth().deleteUser(uid); } catch (error) { if (error.code !== 'auth/user-not-found') throw error; }
    await db.recursiveDelete(db.doc(`users/${uid}`));
  }
  await db.doc('wrapped_shares/cleanup-anon-share').delete();
  await db.doc('wrapped_shares/cleanup-file-share').delete();
  for (const name of names) await bucket.file(name).delete({ ignoreNotFound: true });
  const logs = await db.collection('audit_logs').where('uid', '==', 'cleanup-audit').get();
  for (let start = 0; start < logs.size; start += 500) {
    const batch = db.batch();
    for (const log of logs.docs.slice(start, start + 500)) batch.delete(log.ref);
    await batch.commit();
  }
});

test('anonymous cleanup deletes only old users without root data, nested data, or shares', async () => {
  const old = new Date(Date.now() - 31 * DAY).toISOString();
  const imported = await getAuth().importUsers(uids.map((uid) => ({
    uid,
    metadata: { creationTime: old, lastSignInTime: uid === 'cleanup-active' ? new Date().toISOString() : old },
    ...(uid === 'cleanup-named' ? { email: 'named@example.test', providerData: [{ uid: 'google-named', providerId: 'google.com', email: 'named@example.test' }] } : {}),
  })));
  assert.equal(imported.failureCount, 0);
  await db.doc('users/cleanup-root').set({ createdAt: Timestamp.now() });
  await db.doc('users/cleanup-nested/private/row').set({ progress: true });
  await db.doc('wrapped_shares/cleanup-anon-share').set({ ownerUid: 'cleanup-shared' });
  await endpoints.cleanupOrphanAnons.run({ scheduleTime: new Date().toISOString() });
  await assert.rejects(getAuth().getUser('cleanup-orphan'), { code: 'auth/user-not-found' });
  for (const uid of uids.filter((uid) => uid !== 'cleanup-orphan')) assert.equal((await getAuth().getUser(uid)).uid, uid);
});

test('audit cleanup retains 729-day entries and purges 731-day entries across 500-row pages', async () => {
  await db.doc('audit_logs/cleanup-keep').set({ uid: 'cleanup-audit', timestamp: Timestamp.fromMillis(Date.now() - 729 * DAY) });
  for (let start = 0; start < 501; start += 500) {
    const batch = db.batch();
    for (let i = start; i < Math.min(start + 500, 501); i++) batch.set(db.doc(`audit_logs/cleanup-old-${i}`), {
      uid: 'cleanup-audit', timestamp: Timestamp.fromMillis(Date.now() - 731 * DAY),
    });
    await batch.commit();
  }
  await endpoints.purgeOldAuditLogs.run({ scheduleTime: new Date().toISOString() });
  const remaining = await db.collection('audit_logs').where('uid', '==', 'cleanup-audit').get();
  assert.deepEqual(remaining.docs.map((d) => d.id), ['cleanup-keep']);
});

test('Wrapped cleanup retains new files and shared files, and deletes old orphans including upload files', async () => {
  assert.equal(typeof endpoints.cleanupWrappedOrphans, 'function', 'Wrapped cleanup must be exported');
  for (const name of names) await bucket.file(name).save(Buffer.from('test-file'), { metadata: { contentType: 'image/png' } });
  await db.doc('wrapped_shares/cleanup-file-share').set({ ownerUid: 'cleanup-owner', storagePath: names[2] });
  await endpoints.cleanupWrappedOrphans.run({ scheduleTime: new Date().toISOString() });
  for (const name of names) assert.equal((await bucket.file(name).exists())[0], true);
  mock.timers.enable({ apis: ['Date'], now: Date.now() + 25 * 60 * 60 * 1000 });
  try {
    await endpoints.cleanupWrappedOrphans.run({ scheduleTime: new Date().toISOString() });
  } finally {
    mock.timers.reset();
  }
  assert.equal((await bucket.file(names[0]).exists())[0], false);
  assert.equal((await bucket.file(names[1]).exists())[0], false);
  assert.equal((await bucket.file(names[2]).exists())[0], true);
  assert.equal((await bucket.file(names[3]).exists())[0], true);
});
