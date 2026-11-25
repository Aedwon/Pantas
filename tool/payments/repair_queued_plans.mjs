#!/usr/bin/env node
// Moves tier-wide plans that were queued behind exam-only coverage (a pass, beta or reward) back to
// start now, keeping each plan's length (docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md,
// PAY-06). Run it once per project after the fix is deployed.
// node tool/payments/repair_queued_plans.mjs <pantas-prod|pantas-staging> [--apply]
// Without --apply it only counts how many accounts and plans would change. It prints counts, never uids.
// It uses your own Google login (`gcloud auth application-default login`) and prints no secret.
import {createRequire} from 'node:module';
import {dirname, join} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const PROJECT = /^pantas-(prod|staging)$/;
const here = dirname(fileURLToPath(import.meta.url));

export async function repairQueuedPlans({args, db, repair, now = Date.now, log = console.log}) {
  const [project, ...flags] = args ?? [];
  const apply = flags.includes('--apply');
  if (!PROJECT.test(project ?? '') || flags.some(flag => flag !== '--apply') || flags.length > 1) {
    throw new Error('Check the arguments: <pantas-prod|pantas-staging> [--apply].');
  }
  const at = now();
  // Only accounts that hold an active grant starting in the future can have a queued plan.
  const uids = new Set();
  for (const doc of (await db.collectionGroup('grants').get()).docs) {
    const data = doc.data();
    const [root, uid] = doc.ref.path.split('/');
    if (root === 'users' && uid && data.state === 'active' && data.startsAt > at) uids.add(uid);
  }
  let accounts = 0, plans = 0;
  for (const uid of uids) {
    const moved = await repair(db, uid, at, {dryRun: !apply});
    if (moved > 0) {accounts += 1; plans += moved;}
  }
  log(`${apply ? 'Moved' : 'Dry run: would move'} ${plans} plan${plans === 1 ? '' : 's'} in ${accounts} account${accounts === 1 ? '' : 's'}.` +
    (apply ? '' : ' Run again with --apply to change them.'));
  return {accounts, plans, applied: apply};
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const args = process.argv.slice(2);
    // Check the arguments before touching Firebase.
    await repairQueuedPlans({args, db: {collectionGroup: () => ({get: async () => ({docs: []})})}, repair: async () => 0, log: () => {}});
    const functions = join(here, '..', '..', 'functions');
    const require = createRequire(join(functions, 'package.json'));
    const {initializeApp} = require('firebase-admin/app');
    const {getFirestore} = require('firebase-admin/firestore');
    initializeApp({projectId: args[0]});
    const {repairExamOnlyQueuedPlans} = await import(pathToFileURL(join(functions, 'lib', 'paymongoGrants.js')).href);
    await repairQueuedPlans({args, db: getFirestore(), repair: repairExamOnlyQueuedPlans});
  } catch (error) { console.error(error.message); process.exitCode = 2; }
}
