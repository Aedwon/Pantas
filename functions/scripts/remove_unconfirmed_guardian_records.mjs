#!/usr/bin/env node
// One-time removal for the under-18 flag ruling (D1 and H1). Run once by the lead, never on a schedule.
// Usage: node scripts/remove_unconfirmed_guardian_records.mjs --project <id> [--dry-run | --live]
// For every account with no confirmed guardian it deletes the leftover request record: flag-only records,
// declined requests still waiting out their seven days, and expired requests. It also deletes that
// account's guardian page links and takes the account off its used or revoked answer links.
// Accounts with a confirmed guardian, and withdrawals in progress, are never deleted. Open requests and
// confirmed records written before the hourly cleanup gained its due-time field get that field, so the
// hourly cleanup still finds them.
// Run `npm run build` first: it imports the compiled code in functions/lib.
// Dry run is the default and prints counts only. Never prints emails, names or uids.
import {pathToFileURL} from 'node:url';
import {initializeApp, getApps} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {CLEANUP_DUE_FIELD, GUARDIAN_WINDOW_MS, dropRequestLinks, requestLinksQuery} from '../lib/guardianConsent.js';

const CONTACT_FIELDS = ['emailHash', 'maskedEmail', 'tokenHash', 'sentAt', 'expiresAt', 'createdAt'];

/**
 * What to do with one request record. `delete` removes it and its links, `schedule` gives it the
 * cleanup's due-time field, `keep` leaves it alone.
 */
export function decide(data, now) {
  if (data.status === 'withdrawn') return {action: 'keep'};
  if (data.status === 'confirmed') {
    if (data[CLEANUP_DUE_FIELD] !== undefined || !CONTACT_FIELDS.some(key => data[key] !== undefined)) return {action: 'keep'};
    return {action: 'schedule', due: typeof data.decidedAt === 'number' ? data.decidedAt + GUARDIAN_WINDOW_MS : now};
  }
  if (data.status === 'pending' && typeof data.expiresAt === 'number' && now < data.expiresAt) {
    return data[CLEANUP_DUE_FIELD] !== undefined ? {action: 'keep'} : {action: 'schedule', due: data.expiresAt};
  }
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
    linksRemoved: 0, linksStripped: 0, reads: 0, writes: 0};
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
        tx.delete(ref);
      }
      return {action: 'delete', reads: 1 + Math.max(1, links.size), writes: 1 + links.size, ...counted};
    });
    out.reads += result.reads; out.writes += result.writes ?? 0;
    if (result.action === 'delete') {
      out.deleted++; out.linksRemoved += result.removed; out.linksStripped += result.stripped;
    } else if (result.action === 'schedule') out.scheduled++;
    else out.kept++;
  }
  return out;
}

function parse(argv) {
  const out = {project: undefined, live: false};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--project') out.project = argv[++i];
    else if (argv[i] === '--live') out.live = true;
    else if (argv[i] === '--dry-run') out.live = false;
    else throw new Error(`Unknown flag ${argv[i]}`);
  }
  if (!out.project) throw new Error('Usage: node scripts/remove_unconfirmed_guardian_records.mjs --project <id> [--dry-run | --live]');
  return out;
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  try {
    const {project, live} = parse(process.argv.slice(2));
    // firebase-admin's credential lookup also needs the project in the environment.
    process.env.GOOGLE_CLOUD_PROJECT = project;
    process.env.GCLOUD_PROJECT = project;
    if (!getApps().length) initializeApp({projectId: project});
    const r = await removeUnconfirmedGuardianRecords({db: getFirestore(), live});
    console.log(`${live ? 'LIVE' : 'DRY RUN'} ${project}: ${r.guardianRecords} guardian records among ${r.serverDocuments} server documents; `
      + `${r.deleted} ${live ? 'deleted' : 'would be deleted'}, ${r.scheduled} ${live ? 'given' : 'would be given'} a cleanup time, ${r.kept} kept; `
      + `links: ${r.linksRemoved} ${live ? 'deleted' : 'would be deleted'}, ${r.linksStripped} ${live ? 'cleared of the account' : 'would be cleared of the account'}; `
      + `${r.reads} reads, ${r.writes} writes${live ? '' : ' if run live'}`);
  } catch (e) {
    console.error(e.message); process.exit(1);
  }
}
