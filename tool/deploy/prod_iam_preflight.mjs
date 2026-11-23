// Run before deploying functions to production. Fails when a functions runtime
// service account (functions/src/serviceAccounts.ts) lacks a role it needs.
// Unit tests fake App Check and IAM, so a missing production role cannot fail
// them: on Nov 6, 2026 every sign-in code request failed in production because
// the account could not verify App Check tokens.
//
// Usage: ACCESS_TOKEN=<oauth token> node tool/deploy/prod_iam_preflight.mjs [project]
import {readdirSync, readFileSync} from 'node:fs';
import {join} from 'node:path';

/** Roles the runtime account needs, keyed by the source pattern that needs them. */
export const NEEDS = [
  {pattern: /consumeAppCheckToken:\s*(?![\s]|false)/, role: 'roles/firebaseappcheck.tokenVerifier',
    why: 'callables that consume App Check tokens'},
  {pattern: /createCustomToken\(/, role: 'roles/iam.serviceAccountTokenCreator',
    why: 'minting custom sign-in tokens'},
];

export function requiredRoles(sources) {
  return NEEDS.filter(need => sources.some(source => need.pattern.test(source)));
}

/** Roles held by `member` on the project or, for Token Creator, on the account itself. */
export function missingRoles(needed, member, projectPolicy, accountPolicy = {}) {
  const held = new Set([...(projectPolicy.bindings ?? []), ...(accountPolicy.bindings ?? [])]
    .filter(binding => !binding.condition && binding.members?.includes(member))
    .map(binding => binding.role));
  return needed.filter(need => !held.has(need.role));
}

/**
 * Roles each Cloud Functions runtime account needs (M4 part 2). Which function runs as which account is
 * in functions/src/serviceAccounts.ts; tool/deploy/function_service_accounts.sh grants these.
 * `scope: 'account'` means a binding on the account itself (token creator, to sign custom tokens).
 */
export function accountRoles(project) {
  const custom = id => `projects/${project}/roles/${id}`;
  const p = role => ({role, scope: 'project'});
  return {
    'pantas-app': [p('roles/datastore.user'), p('roles/firebaseappcheck.tokenVerifier'), p('roles/firebaseauth.viewer')],
    'pantas-entitlements': [p('roles/datastore.user'), p('roles/firebaseappcheck.tokenVerifier'), p(custom('pantasAuthReadUpdate'))],
    'pantas-payments': [p('roles/datastore.user'), p('roles/firebaseappcheck.tokenVerifier'), p(custom('pantasAuthReadUpdate'))],
    'pantas-identity': [p('roles/datastore.user'), p('roles/firebaseappcheck.tokenVerifier'), p(custom('pantasAuthUsers')),
      {role: 'roles/iam.serviceAccountTokenCreator', scope: 'account'}],
    'pantas-jobs': [p('roles/datastore.user'), p(custom('pantasAuthJobs')), p('roles/run.invoker'), p('roles/eventarc.eventReceiver')],
  };
}

/** Every role an account lacks. `accountPolicies` maps an account name to the IAM policy on that account. */
export function missingAccountRoles(project, projectPolicy, accountPolicies) {
  const holds = (policy, member, role) => (policy?.bindings ?? [])
    .some(b => !b.condition && b.role === role && b.members?.includes(member));
  const missing = [];
  for (const [name, roles] of Object.entries(accountRoles(project))) {
    const member = `serviceAccount:${name}@${project}.iam.gserviceaccount.com`;
    for (const need of roles) {
      const policy = need.scope === 'account' ? accountPolicies[name] : projectPolicy;
      if (!holds(policy, member, need.role)) missing.push({account: name, role: need.role});
    }
  }
  return missing;
}

function sources(dir) {
  return readdirSync(dir).filter(name => name.endsWith('.ts')).map(name => readFileSync(join(dir, name), 'utf8'));
}

async function call(url, token) {
  const response = await fetch(url, {method: 'POST', body: '{}',
    headers: {authorization: `Bearer ${token}`, 'content-type': 'application/json'}});
  if (!response.ok) throw new Error(`${url} returned ${response.status}`);
  return response.json();
}

async function main() {
  const project = process.argv[2] ?? 'pantas-prod';
  const token = process.env.ACCESS_TOKEN;
  if (!token) throw new Error('Set ACCESS_TOKEN to an OAuth token that can read IAM policies.');
  const projectPolicy = await call(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:getIamPolicy`, token);
  const accountPolicies = {};
  for (const [name, roles] of Object.entries(accountRoles(project))) {
    if (!roles.some(r => r.scope === 'account')) continue;
    try {
      accountPolicies[name] = await call(
        `https://iam.googleapis.com/v1/projects/${project}/serviceAccounts/${name}@${project}.iam.gserviceaccount.com:getIamPolicy`, token);
    } catch (error) {
      if (!String(error.message).endsWith('returned 404')) throw error;
      console.error(`MISSING account ${name}@${project}.iam.gserviceaccount.com.`);
    }
  }
  const missing = missingAccountRoles(project, projectPolicy, accountPolicies);
  for (const m of missing) console.error(`MISSING ${m.role} on ${m.account}@${project}.iam.gserviceaccount.com.`);
  if (missing.length) {
    console.error('Run tool/deploy/function_service_accounts.sh ' + project + ' first.');
    process.exit(1);
  }
  // The feature scan still guards against a new feature that needs a role no account was given.
  const needed = requiredRoles(sources('functions/src')).map(need => need.role);
  const given = new Set(Object.values(accountRoles(project)).flat().map(r => r.role));
  const unplanned = needed.filter(role => !given.has(role));
  if (unplanned.length) { console.error(`MISSING ${unplanned.join(', ')}: needed by functions/src but given to no runtime account.`); process.exit(1); }
  console.log(`IAM preflight OK for ${project}: ${Object.keys(accountRoles(project)).length} runtime accounts hold their roles.`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => { console.error(error.message); process.exit(2); });
}
