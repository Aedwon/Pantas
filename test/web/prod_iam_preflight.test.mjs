import assert from 'node:assert/strict';
import test from 'node:test';
import {missingRoles, requiredRoles} from '../../tool/deploy/prod_iam_preflight.mjs';

const member = 'serviceAccount:1-compute@developer.gserviceaccount.com';
const source = `onCall({enforceAppCheck: true, consumeAppCheckToken: enforceAppCheck}, () => auth.createCustomToken(uid))`;

test('the Nov 6 failure: App Check consumption without the verifier role is caught', () => {
  const needed = requiredRoles([source]);
  const policy = {bindings: [{role: 'roles/editor', members: [member]}]};
  const account = {bindings: [{role: 'roles/iam.serviceAccountTokenCreator', members: [member]}]};
  assert.deepEqual(missingRoles(needed, member, policy, account).map(need => need.role),
    ['roles/firebaseappcheck.tokenVerifier']);
});

test('both roles held passes, and unconditional bindings only count', () => {
  const needed = requiredRoles([source]);
  const policy = {bindings: [
    {role: 'roles/firebaseappcheck.tokenVerifier', members: [member]},
    {role: 'roles/iam.serviceAccountTokenCreator', members: [member], condition: {expression: 'false'}},
  ]};
  assert.deepEqual(missingRoles(needed, member, policy).map(need => need.role), ['roles/iam.serviceAccountTokenCreator']);
  policy.bindings[1] = {role: 'roles/iam.serviceAccountTokenCreator', members: [member]};
  assert.deepEqual(missingRoles(needed, member, policy), []);
});

test('sources without those features need no roles', () => {
  assert.deepEqual(requiredRoles(['onCall({consumeAppCheckToken: false}, () => 1)']), []);
});
