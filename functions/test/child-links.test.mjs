import assert from 'node:assert/strict';
import test from 'node:test';
import {childrenOfHolder, holderForChild} from '../lib/childLinks.js';
import {fakeFirestore} from './_fake-firestore.mjs';

const entry = (childUid, nickname, over = {}) =>
  ({childUid, nickname, active: true, siblingOpenWithoutCode: false, createdAt: 1, ...over});
const world = () => fakeFirestore({
  'users/h1/server/children/items/kidA': entry('kidA', 'Ana'),
  'users/h1/server/children/items/kidB': entry('kidB', 'Ben', {siblingOpenWithoutCode: true}),
  'users/h1/server/children/items/kidX': entry('kidX', 'Gone', {active: false}),
  'users/kidA/server/childLink': {holderUid: 'h1'},
  'users/kidB/server/childLink': {holderUid: 'h1'},
  'users/kidX/server/childLink': {holderUid: 'h1'},
  'users/orphan/server/childLink': {holderUid: 'h1'},
  'users/lonely/server/childLink': {holderUid: 'h2'},
});

test('holderForChild returns the holder of an active linked child', async () => {
  assert.equal(await holderForChild(world(), 'kidA'), 'h1');
});

test('holderForChild is null when the link, the holder entry or the active flag is missing', async () => {
  const db = world();
  for (const uid of ['nobody', 'orphan', 'lonely', 'kidX']) assert.equal(await holderForChild(db, uid), null, uid);
  assert.equal(await holderForChild(db, ''), null);
  assert.equal(await holderForChild(db, 'a/b'), null);
});

test('childrenOfHolder lists active children with their fields', async () => {
  const kids = await childrenOfHolder(world(), 'h1');
  assert.deepEqual(kids.map(k => k.childUid).sort(), ['kidA', 'kidB']);
  const ben = kids.find(k => k.childUid === 'kidB');
  assert.deepEqual(ben, {childUid: 'kidB', nickname: 'Ben', active: true, siblingOpenWithoutCode: true, createdAt: 1});
  assert.deepEqual(await childrenOfHolder(world(), 'h2'), []);
});
