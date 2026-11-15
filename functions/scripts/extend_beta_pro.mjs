#!/usr/bin/env node
// Extends existing beta Pro grants from the old cutoff (Nov 16, 2026) to the new one (Nov 23, 2026).
// Usage: node scripts/extend_beta_pro.mjs --project <id> [--dry-run | --live]
// Run `npm run build` first: it imports the compiled code in functions/lib.
// Dry run is the default and prints counts only. Never prints emails, names or uids.
import {pathToFileURL} from 'node:url';
import {initializeApp, getApps} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {getAuth} from 'firebase-admin/auth';
import {readEntitlementInputs, claimsFromInputs, entitlementWrite, nativeCoverageRows} from '../lib/entitlementInputs.js';
import {reanchorQueued} from '../lib/paymongoGrants.js';
import {copyEntitlementClaims} from '../lib/revenuecatClaims.js';

export const OLD_CUTOFF = Date.parse('2026-11-16T00:00:00+08:00');
export const NEW_CUTOFF = Date.parse('2026-11-23T00:00:00+08:00');
const isOld = g => g?.source === 'beta' && g.state === 'active' && g.endsAt === OLD_CUTOFF;

/** Returns {users, grants} that would change (dry run) or did change (live). */
export async function extendBetaPro({db, auth, live = false, now = Date.now}) {
  // No filter: a collection-group filter needs an index this project does not define.
  const byUser = new Map();
  for await (const doc of db.collectionGroup('grants').select('source', 'state', 'endsAt').stream()) {
    if (!doc.id.startsWith('beta_') || !isOld(doc.data())) continue;
    const uid = doc.ref.parent.parent.id;
    byUser.set(uid, (byUser.get(uid) ?? 0) + 1);
  }
  if (!live) return {users: byUser.size, grants: [...byUser.values()].reduce((a, b) => a + b, 0)};
  let users = 0, grants = 0;
  for (const uid of byUser.keys()) {
    const changed = await db.runTransaction(async tx => {
      const at = now();
      const inputs = await readEntitlementInputs(tx, db, uid);
      const next = new Map(inputs.grants);
      let count = 0;
      for (const [id, g] of inputs.grants) {
        if (id.startsWith('beta_') && isOld(g)) {next.set(id, {...g, endsAt: NEW_CUTOFF}); count++;}
      }
      if (!count) return 0;
      const all = reanchorQueued(next, nativeCoverageRows(inputs, at), at);
      for (const [id, row] of all) if (row !== inputs.grants.get(id)) tx.set(db.doc(`users/${uid}/grants/${id}`), row);
      tx.set(inputs.record.ref, entitlementWrite(inputs, claimsFromInputs(inputs, at, all)), {merge: true});
      return count;
    });
    if (!changed) continue;
    users++; grants += changed;
    await copyEntitlementClaims(db, auth, uid);
  }
  return {users, grants};
}

function parse(argv) {
  const out = {project: undefined, live: false};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--project') out.project = argv[++i];
    else if (argv[i] === '--live') out.live = true;
    else if (argv[i] === '--dry-run') out.live = false;
    else throw new Error(`Unknown flag ${argv[i]}`);
  }
  if (!out.project) throw new Error('Usage: node scripts/extend_beta_pro.mjs --project <id> [--dry-run | --live]');
  return out;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  try {
    const {project, live} = parse(process.argv.slice(2));
    if (!getApps().length) initializeApp({projectId: project});
    const result = await extendBetaPro({db: getFirestore(), auth: getAuth(), live});
    console.log(`${live ? 'LIVE' : 'DRY RUN'} ${project}: ${result.users} users, ${result.grants} grants ${live ? 'extended' : 'would change'}`);
  } catch (e) {
    console.error(e.message); process.exit(1);
  }
}
