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

test('opening a child session requires fresh App Check', async () => {
  const deps = sessionRig();
  for (const app of [undefined, {appId: 'test', alreadyConsumed: true}]) {
    const request = {...sessionRequest('kidA', 'kidB'), app};
    await assert.rejects(openSession(request, deps), {code: 'unauthenticated'});
    assert.equal(deps.db.rows.has('guardianCodes/holder'), true);
  }
});

test('child-session opening meters the caller and only looks up targets in that family', async () => {
  const deps = sessionRig();
  deps.db.rows.set('users/foreign/server/childLink', {holderUid: 'other-holder'});
  deps.db.rows.set('users/other-holder/server/children/items/foreign', childEntry('Other'));
  const events = [];
  const doc = deps.db.doc;
  deps.db.doc = path => {
    events.push(path);
    return doc(path);
  };
  deps.allow = async (uid, bucket) => {
    events.push(`${uid}/${bucket}`);
    return true;
  };

  for (const childId of ['foreign', 'missing']) {
    events.length = 0;
    await assert.rejects(openSession(sessionRequest('kidA', childId), deps), {details: {reason: 'not-linked'}});
    const limit = 'kidA/openChildSession';
    const target = `users/holder/server/children/items/${childId}`;
    assert.ok(events.includes(limit), 'the caller was metered');
    assert.ok(events.indexOf(target) > events.indexOf(limit), 'the family lookup followed the limit');
    assert.ok(!events.includes(`users/${childId}/server/childLink`), 'no lookup in the target account');
  }
});

test('switching to a sibling without a code cancels the pending challenge', async () => {
  const deps = sessionRig();
  assert.equal((await openSession(sessionRequest('kidA', 'kidB'), deps)).customToken, 'test-token-for-kidB');
  assert.equal(deps.db.rows.has('guardianCodes/holder'), false);
  const same = sessionRig();
  await openSession(sessionRequest('kidA', 'kidA'), same);
  assert.equal(same.db.rows.has('guardianCodes/holder'), true);
});
