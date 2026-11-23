#!/usr/bin/env node
// One-time removal for the under-18 flag ruling (D1 and H1). Run once by the lead, never on a schedule.
// Usage: node scripts/remove_unconfirmed_guardian_records.mjs --project <id> [--dry-run | --live | --verify]
// --verify counts the records that still have no cleanup time (it must print 0 after the live run).
// Rollout order: deploy the index; wait until it is READY; deploy the functions (the old writers stop);
// run this live; run --verify and see 0; only then rely on the due-time query. Until then the daily
// scan in the hourly cleanup still reads the old rows and logs how many it found.
// For every account with no confirmed guardian it deletes the leftover request record: flag-only records,
// declined requests still waiting out their seven days, and expired requests. It also deletes that
// account's guardian page links and takes the account off its used or revoked answer links.
// Accounts with a confirmed guardian, and withdrawals in progress, are never deleted. An account that
// said it is 18 keeps that mark and nothing else. Decline evidence that shares its id with a kept link
// row is copied to its own id. Open requests and
// confirmed records written before the hourly cleanup gained its due-time field get that field, so the
// hourly cleanup still finds them.
// Run `npm run build` first: it imports the compiled code in functions/lib.
// Dry run is the default and prints counts only. Never prints emails, names or uids.
import {pathToFileURL} from 'node:url';
import {initializeApp, getApps} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {CLEANUP_DUE_FIELD, GUARDIAN_WINDOW_MS, consentDue, dropRequestLinks, endRequest, needsDueField, requestLinksQuery} from '../lib/guardianConsent.js';

const CONTACT_FIELDS = ['emailHash', 'maskedEmail', 'tokenHash', 'sentAt', 'expiresAt', 'createdAt'];

/**
 * What to do with one request record. `delete` removes it and its links, `schedule` gives it the
 * cleanup's due-time field, `keep` leaves it alone.
 */
export function decide(data, now) {
  if (data.status === 'withdrawn') return {action: 'keep'};
  if (data.status === 'confirmed') {
    if (data[CLEANUP_DUE_FIELD] !== undefined || !CONTACT_FIELDS.some(key => data[key] !== undefined)) return {action: 'keep'};
    // The cleanup uses the same deadline: the answer time plus seven days, else the time given here.
    return {action: 'schedule', due: consentDue(data) ?? now + GUARDIAN_WINDOW_MS};
  }
  if (data.status === 'pending' && typeof data.expiresAt === 'number' && now < data.expiresAt) {
    return data[CLEANUP_DUE_FIELD] !== undefined ? {action: 'keep'} : {action: 'schedule', due: data.expiresAt};
  }
  // An adult mark alone is not a request, so it is not touched.
  if (data.ageGroup === 'adult' && data.status === undefined && !CONTACT_FIELDS.some(key => data[key] !== undefined)) return {action: 'keep'};
  return {action: 'delete'};
}

const uidOf = ref => /^users\/([^/]+)\/server\/guardianConsent$/.exec(ref.path)?.[1];
const countLinks = links => ({
  removed: links.docs.filter(l => l.get('kind') === 'manage' || l.get('state') === 'open').length,
  stripped: links.docs.filter(l => l.get('kind') !== 'manage' && l.get('state') !== 'open').length,
});

/**
 * Counts only. `reads` and `writes` are what this run used (a dry run counts the writes a live run would
 * make), so the lead can check them against the free tier. A dry run writes nothing.
 */
export async function removeUnconfirmedGuardianRecords({db, live = false, now = Date.now}) {
  const out = {serverDocuments: 0, guardianRecords: 0, deleted: 0, scheduled: 0, kept: 0,
    linksRemoved: 0, linksStripped: 0, evidenceUnlinked: 0, reads: 0, writes: 0};
  const found = [];
  for await (const doc of db.collectionGroup('server').stream()) {
    out.serverDocuments++; out.reads++;
    if (doc.id === 'guardianConsent' && uidOf(doc.ref)) found.push(doc.ref);
  }
  out.guardianRecords = found.length;
  for (const ref of found) {
    const uid = uidOf(ref);
    const result = await db.runTransaction(async tx => {
      const data = (await tx.get(ref)).data();
      if (!data) return {action: 'keep', reads: 1};
      const plan = decide(data, now());
      if (plan.action === 'schedule') {
        if (live) tx.set(ref, {[CLEANUP_DUE_FIELD]: plan.due}, {merge: true});
        return {action: 'schedule', reads: 1, writes: 1};
      }
      if (plan.action !== 'delete') return {action: 'keep', reads: 1};
      const links = await tx.get(requestLinksQuery(db, uid));
      const counted = countLinks(links);
      if (live) {
        dropRequestLinks(tx, links);
        endRequest(tx, ref, data);
      }
      return {action: 'delete', reads: 1 + Math.max(1, links.size), writes: 1 + links.size, ...counted};
    });
    out.reads += result.reads; out.writes += result.writes ?? 0;
    if (result.action === 'delete') {
      out.deleted++; out.linksRemoved += result.removed; out.linksStripped += result.stripped;
    } else if (result.action === 'schedule') out.scheduled++;
    else out.kept++;
  }
  await unlinkDeclineEvidence(db, live, out);
  return out;
}

/**
 * Decline evidence written by the earlier code is named after the link row that answered it, and that
 * row stays for seven days. This copies each such answer to an id of its own and deletes the old one.
 */
async function unlinkDeclineEvidence(db, live, out) {
  const pairs = [];
  for await (const doc of db.collectionGroup('responses').stream()) {
    out.reads++;
    if (!doc.ref.path.startsWith('guardianConsentEvidence/') || doc.get('action') !== 'decline') continue;
    pairs.push(doc.ref);
  }
  for (const ref of pairs) {
    const link = await db.doc(`guardianTokens/${ref.id}`).get();
    out.reads += 2;
    if (!link.exists) continue;
    out.evidenceUnlinked++; out.writes += 2;
    if (!live) continue;
    await db.runTransaction(async tx => {
      const old = await tx.get(ref);
      if (!old.exists) return;
      tx.set(ref.parent.doc(), old.data());
      tx.delete(ref);
    });
  }
}

/** Records that still need a cleanup time. Counts only; it must be 0 after the live run. */
export async function countUndated({db}) {
  let undated = 0, reads = 0;
  for await (const doc of db.collectionGroup('server').stream()) {
    reads++;
    if (doc.id === 'guardianConsent' && uidOf(doc.ref) && needsDueField(doc.data())) undated++;
  }
  return {undated, reads};
}

/** One line of counts. Reads and writes are a retry-free estimate: a retried transaction reads again. */
export function summary(project, live, r) {
  const would = live ? '' : ' would be';
  return `${live ? 'LIVE' : 'DRY RUN'} ${project}: ${r.guardianRecords} guardian records among ${r.serverDocuments} server documents; `
    + `${r.deleted} deleted${would ? ' (would be)' : ''}, ${r.scheduled} given a cleanup time${would ? ' (would be)' : ''}, ${r.kept} kept; `
    + `links: ${r.linksRemoved} deleted, ${r.linksStripped} cleared of the account${would ? ' (would be)' : ''}; `
    + `${r.evidenceUnlinked} decline answers moved to their own id${would ? ' (would be)' : ''}; `
    + `retry-free estimate: ${r.reads} reads, ${r.writes} writes${live ? '' : ' if run live'}`;
}

function parse(argv) {
  const out = {project: undefined, live: false, verify: false};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--project') out.project = argv[++i];
    else if (argv[i] === '--live') out.live = true;
    else if (argv[i] === '--dry-run') out.live = false;
    else if (argv[i] === '--verify') out.verify = true;
    else throw new Error('usage');
  }
  if (!out.project) throw new Error('usage');
  return out;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  // Only fixed reason codes are printed, never an error message.
  let project;
  try {
    const args = parse(process.argv.slice(2));
    project = args.project;
    // firebase-admin's credential lookup also needs the project in the environment.
    process.env.GOOGLE_CLOUD_PROJECT = project;
    process.env.GCLOUD_PROJECT = project;
    if (!getApps().length) initializeApp({projectId: project});
    if (args.verify) {
      const r = await countUndated({db: getFirestore()});
      console.log(`VERIFY ${project}: ${r.undated} records without a cleanup time; retry-free estimate: ${r.reads} reads`);
      if (r.undated) process.exit(2);
    } else {
      console.log(summary(project, args.live, await removeUnconfirmedGuardianRecords({db: getFirestore(), live: args.live})));
    }
  } catch (e) {
    console.error(e?.message === 'usage' ? 'REASON usage' : 'REASON failed');
    process.exit(1);
  }
}
