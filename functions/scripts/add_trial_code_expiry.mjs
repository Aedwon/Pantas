#!/usr/bin/env node
// One-time: gives every trial code that has no expiry (legal ruling D7) startedAt = the deploy time
// and expireAt = deploy time + 730 days, so the Firestore TTL policy can remove it.
// Usage: node scripts/add_trial_code_expiry.mjs --project <id> [--live] [--deploy-at <ISO time>]
// Run `npm run build` first: it imports the compiled code in functions/lib.
// Dry run is the default and prints counts only. Never prints identity hashes or any other id.
// Idempotent: a code that already has expireAt is never touched, so a rerun changes nothing.
// Cost: one read per code (a rerun reads them all again), one write per code without an expiry.
import {pathToFileURL} from 'node:url';
import {initializeApp, getApps} from 'firebase-admin/app';
import {getFirestore, Timestamp} from 'firebase-admin/firestore';
import {TRIAL_CODE_DAYS} from '../lib/trialMarker.js';

export {TRIAL_CODE_DAYS};
const DAY = 86_400_000;
const BATCH = 400;

/**
 * Returns {reads, missing, writes, skipped}: documents read, those without expireAt, documents
 * written, and documents skipped because they changed or were deleted after the scan. Each write
 * carries the scanned update time as a precondition, so a code that gained an expiry meanwhile
 * keeps it, a deleted code is not recreated, and one failure never aborts the rest.
 * `afterScan` is only for tests.
 */
export async function addTrialCodeExpiry({db, live = false, deployAt, afterScan}) {
  if (!Number.isFinite(deployAt)) throw new Error('deployAt is required.');
  const stamp = Timestamp.fromMillis(deployAt + TRIAL_CODE_DAYS * DAY);
  const missing = [];
  let reads = 0;
  for await (const doc of db.collection('trialUsedIdentities').select('expireAt').stream()) {
    reads++;
    if (doc.get('expireAt') === undefined) missing.push({ref: doc.ref, seen: doc.updateTime});
  }
  let writes = 0, skipped = 0;
  if (live) {
    await afterScan?.();
    const writer = db.bulkWriter();
    writer.onWriteError(() => false); // a failed precondition is a skip, never a retry
    const done = missing.map(({ref, seen}) =>
      writer.update(ref, {startedAt: deployAt, expireAt: stamp}, {lastUpdateTime: seen})
        .then(() => { writes++; }, () => { skipped++; }));
    await writer.close(); // flushes every queued write
    await Promise.all(done);
  }
  return {reads, missing: missing.length, writes, skipped};
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  const args = process.argv.slice(2);
  const value = flag => { const i = args.indexOf(flag); return i >= 0 ? args[i + 1] : undefined; };
  const project = value('--project');
  if (!project) { console.error('Usage: add_trial_code_expiry.mjs --project <id> [--live] [--deploy-at <ISO time>]'); process.exit(2); }
  const deployAt = value('--deploy-at') ? Date.parse(value('--deploy-at')) : Date.now();
  if (!Number.isFinite(deployAt)) { console.error('--deploy-at is not a date.'); process.exit(2); }
  if (!getApps().length) initializeApp({projectId: project});
  const live = args.includes('--live');
  const result = await addTrialCodeExpiry({db: getFirestore(), live, deployAt});
  console.log(`${live ? 'LIVE' : 'DRY RUN'} ${project}: ${JSON.stringify(result)}`);
}
