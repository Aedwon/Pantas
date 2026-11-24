import './_secrets-helper.mjs';
import '../lib/index.js';
import test from 'node:test';
import assert from 'node:assert/strict';
import {getFirestore} from 'firebase-admin/firestore';
import {runNpcDataSubjectCount} from '../lib/npcDataSubjectCount.js';

// The emulator ignores indexes, so this proves only that the real query shape runs and counts.
const db = getFirestore();

test('the count query counts minor and adult age groups and nothing else', async () => {
  const before = (await runNpcDataSubjectCount({db, info: () => {}, error: () => {}})).count;
  await db.doc('users/npc_a/server/guardianConsent').set({ageGroup: 'minor'});
  await db.doc('users/npc_b/server/guardianConsent').set({ageGroup: 'adult'});
  await db.doc('users/npc_c/server/guardianConsent').set({ageGroup: 'unknown'});
  await db.doc('users/npc_d/server/other').set({note: 'no age'});
  const info = [];
  const {count} = await runNpcDataSubjectCount({db, info: (t) => info.push(t), error: () => {}});
  assert.equal(count, before + 2);
  assert.deepEqual(info, [`npc data subjects ${count}`]);
  for (const id of ['npc_a/server/guardianConsent', 'npc_b/server/guardianConsent', 'npc_c/server/guardianConsent', 'npc_d/server/other']) await db.doc(`users/${id}`).delete();
});
