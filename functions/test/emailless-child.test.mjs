import assert from 'node:assert/strict';
import test from 'node:test';
import {checkBetaAccess, selectedBetaApplication, BETA_START} from '../lib/betaAccess.js';
import {fakeFirestore} from './_fake-firestore.mjs';

// A linked child is an emailless custom-token user. It inherits its holder's beta selection.
const childAuth = uid => ({uid, token: {firebase: {sign_in_provider: 'custom'}}});
const entry = (childUid, over = {}) =>
  ({childUid, nickname: 'Kid', active: true, siblingOpenWithoutCode: false, createdAt: 1, ...over});

function world({selected = true, holderVerified = true, active = true, holderEmail = ' Parent@Example.test '} = {}) {
  const db = fakeFirestore({
    'users/kid/server/childLink': {holderUid: 'holder'},
    'users/holder/server/children/items/kid': entry('kid', {active}),
    'users/loose/server/childLink': {holderUid: 'holder'},
  });
  // The beta applications query is the only query the code makes.
  const base = db.collection;
  db.collection = name => name === 'betaApplications'
    ? {where: (field, op, value) => ({get: async () => ({docs: value === 'parent@example.test'
      ? [{get: key => ({selected, email: value})[key]}] : []})})}
    : base(name);
  const auth = {getUser: async uid => {
    if (uid !== 'holder') throw Object.assign(new Error('gone'), {code: 'auth/user-not-found'});
    return {uid, email: holderEmail, emailVerified: holderVerified};
  }};
  return {db, auth};
}

test('a linked child inherits its holder\'s beta selection', async () => {
  const {db, auth} = world();
  assert.equal(await selectedBetaApplication(childAuth('kid'), db, auth), true);
  assert.deepEqual(await checkBetaAccess({auth: childAuth('kid'), app: {appId: 'a'}},
    {db, auth, allow: async () => true, now: () => BETA_START}), {selected: true});
});

test('a child whose holder is not selected is not selected', async () => {
  const {db, auth} = world({selected: false});
  assert.equal(await selectedBetaApplication(childAuth('kid'), db, auth), false);
});

test('an unlinked emailless user, an inactive link and an unverified holder stay not selected', async () => {
  assert.equal(await selectedBetaApplication(childAuth('nobody'), world().db, world().auth), false);
  assert.equal(await selectedBetaApplication(childAuth('loose'), world().db, world().auth), false);
  const inactive = world({active: false});
  assert.equal(await selectedBetaApplication(childAuth('kid'), inactive.db, inactive.auth), false);
  const unverified = world({holderVerified: false});
  assert.equal(await selectedBetaApplication(childAuth('kid'), unverified.db, unverified.auth), false);
});

test('a child with no holder record in Auth is not selected', async () => {
  const {db} = world();
  const auth = {getUser: async () => { throw Object.assign(new Error('gone'), {code: 'auth/user-not-found'}); }};
  assert.equal(await selectedBetaApplication(childAuth('kid'), db, auth), false);
});
