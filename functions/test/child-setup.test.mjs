import assert from 'node:assert/strict';
import test from 'node:test';
import {openSession} from '../lib/childSetup.js';
import {fakeFirestore} from './_fake-firestore.mjs';

const sessionRequest = (uid, childId) => ({
  auth: {uid, token: {firebase: {sign_in_provider: 'custom'}}},
  app: {appId: 'test'},
  data: {childId},
});
const childEntry = (nickname, siblingOpenWithoutCode = false) => ({
  nickname, active: true, siblingOpenWithoutCode, createdAt: 1,
});

function sessionRig() {
  const db = fakeFirestore({
    'users/holder/server/children/items/kidA': childEntry('A'),
    'users/holder/server/children/items/kidB': childEntry('B', true),
    'users/kidA/server/childLink': {holderUid: 'holder'},
    'users/kidB/server/childLink': {holderUid: 'holder'},
    'guardianCodes/holder': {childId: 'kidA', action: 'delete'},
  });
  db.getAll = (...refs) => Promise.all(refs.map(ref => ref.get()));
  return {db, auth: {createCustomToken: async uid => `test-token-for-${uid}`}, allow: async () => true};
}

test('switching to a sibling without a code cancels the pending challenge', async () => {
  const deps = sessionRig();
  assert.equal((await openSession(sessionRequest('kidA', 'kidB'), deps)).customToken, 'test-token-for-kidB');
  assert.equal(deps.db.rows.has('guardianCodes/holder'), false);
  const same = sessionRig();
  await openSession(sessionRequest('kidA', 'kidA'), same);
  assert.equal(same.db.rows.has('guardianCodes/holder'), true);
});
