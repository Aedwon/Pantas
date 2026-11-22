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

// M4 part 2: functions run as five narrow accounts, not the default compute account.
test('every runtime account must hold its own roles, and a missing one is named', async () => {
  const {accountRoles, missingAccountRoles} = await import('../../tool/deploy/prod_iam_preflight.mjs');
  const project = 'pantas-staging';
  const roles = accountRoles(project);
  assert.deepEqual(Object.keys(roles).sort(), ['pantas-app', 'pantas-entitlements', 'pantas-identity', 'pantas-jobs', 'pantas-payments']);
  const sa = name => `serviceAccount:${name}@${project}.iam.gserviceaccount.com`;
  const full = {bindings: Object.entries(roles).flatMap(([name, list]) =>
    list.filter(r => r.scope === 'project').map(r => ({role: r.role, members: [sa(name)]})))};
  const identityPolicy = {bindings: [{role: 'roles/iam.serviceAccountTokenCreator', members: [sa('pantas-identity')]}]};
  assert.deepEqual(missingAccountRoles(project, full, {'pantas-identity': identityPolicy}), []);
  // The Nov 6 failure, now per account: the identity account without the App Check verifier.
  const without = {bindings: full.bindings.map(b => b.role === 'roles/firebaseappcheck.tokenVerifier'
    ? {...b, members: b.members.filter(m => m !== sa('pantas-identity'))} : b)};
  assert.deepEqual(missingAccountRoles(project, without, {'pantas-identity': identityPolicy}).map(m => `${m.account} ${m.role}`),
    ['pantas-identity roles/firebaseappcheck.tokenVerifier']);
  // Token creator must be on the identity account itself.
  assert.deepEqual(missingAccountRoles(project, full, {}).map(m => `${m.account} ${m.role}`),
    ['pantas-identity roles/iam.serviceAccountTokenCreator']);
  // Custom Auth roles are project roles of that project.
  assert.ok(roles['pantas-identity'].some(r => r.role === `projects/${project}/roles/pantasAuthUsers`));
});

test('the runtime accounts in the preflight match the accounts the functions use', async () => {
  const {readFileSync} = await import('node:fs');
  const {accountRoles} = await import('../../tool/deploy/prod_iam_preflight.mjs');
  const mapping = readFileSync(new URL('../../functions/src/serviceAccounts.ts', import.meta.url), 'utf8');
  // Accounts appear as keys of SERVICE_ACCOUNTS and in serviceAccountEmail('pantas-app') for the default.
  const used = [...new Set([...mapping.matchAll(/'(pantas-[a-z]+)'/g)].map(m => m[1]))].sort();
  assert.deepEqual(Object.keys(accountRoles('p')).sort(), used);
});
