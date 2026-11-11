// Run before deploying functions to production. Fails when the functions
// runtime service account lacks a role that a feature in functions/src needs.
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
  const info = await (await fetch(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}`,
    {headers: {authorization: `Bearer ${token}`}})).json();
  const account = `${info.projectNumber}-compute@developer.gserviceaccount.com`;
  const needed = requiredRoles(sources('functions/src'));
  const projectPolicy = await call(`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:getIamPolicy`, token);
  const accountPolicy = await call(
    `https://iam.googleapis.com/v1/projects/${project}/serviceAccounts/${account}:getIamPolicy`, token);
  const missing = missingRoles(needed, `serviceAccount:${account}`, projectPolicy, accountPolicy);
  for (const need of missing) console.error(`MISSING ${need.role} on ${account} (needed for ${need.why}).`);
  if (missing.length) process.exit(1);
  console.log(`IAM preflight OK for ${project}: ${needed.map(need => need.role).join(', ') || 'no special roles'}.`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(error => { console.error(error.message); process.exit(2); });
}
