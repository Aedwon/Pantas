#!/usr/bin/env node
// One-time removal for the under-18 flag ruling (D1 and H1). Run once by the lead, never on a schedule.
// Usage: node scripts/remove_unconfirmed_guardian_records.mjs --project <id> [--dry-run | --live | --verify]
// --verify counts records without a cleanup time and adult switch rows without a confirmation.
// When all counts are 0 it also writes the marker that switches off the daily scan in the hourly cleanup.
// Rollout order: deploy the index; wait until it is READY; deploy the functions (the old writers stop);
// check the dry-run counts plus verification and retry headroom against the remaining daily free tier;
// run this live; run --verify and see 0; only then rely on the due-time query. Until then the daily
// scan in the hourly cleanup still reads the old rows and logs how many it found.
// For every account with no confirmed guardian it deletes the leftover request record: flag-only records,
// declined requests still waiting out their seven days, and expired requests. It also deletes that
// account's guardian page links and takes the account off its used or revoked answer links.
// Accounts with a confirmed guardian, and withdrawals in progress, are never deleted. An account that
// said it is 18 keeps that mark and nothing else. Decline evidence that shares its id with a kept link
// row is copied to its own id. Open requests and
// confirmed records written before the hourly cleanup gained its due-time field get that field, so the
// hourly cleanup still finds them. Adult switch evidence without a confirmation is removed, along
// with its parent if no responses or purchases remain.
// Run `npm run build` first: it imports the compiled code in functions/lib.
// Dry run is the default and prints counts only. Never prints emails, names or uids.
import {pathToFileURL} from 'node:url';
import {initializeApp, getApps} from 'firebase-admin/app';
import {FieldValue, getFirestore} from 'firebase-admin/firestore';
import {BACKFILL_MARKER, CLEANUP_DUE_FIELD, coarseEnd, GUARDIAN_WINDOW_MS, consentDue, dropRequestLinks, endRequest, needsDueField, requestLinksQuery} from '../lib/guardianConsent.js';

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
  const out = {serverDocuments: 0, guardianRecords: 0, deleted: 0, adultMarksKept: 0, scheduled: 0, kept: 0,
    linksRemoved: 0, linksStripped: 0, evidenceUnlinked: 0, limitersRemoved: 0,
    unconfirmedAdultRows: 0, emptyEvidenceParents: 0, reads: 0, writes: 0};
  const found = [];
  for await (const doc of db.collectionGroup('server').stream()) {
    out.serverDocuments++; out.reads++;
    if (doc.id === 'guardianConsent' && uidOf(doc.ref)) found.push(doc.ref);
  }
  out.reads = Math.max(1, out.reads);
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
      return {action: 'delete', keepsAdultMark: data.ageGroup === 'adult',
        reads: 1 + Math.max(1, links.size), writes: 1 + links.size, ...counted};
    });
    out.reads += result.reads; out.writes += result.writes ?? 0;
    if (result.action === 'delete') {
      if (result.keepsAdultMark) out.adultMarksKept++;
      out.deleted++; out.linksRemoved += result.removed; out.linksStripped += result.stripped;
    } else if (result.action === 'schedule') out.scheduled++;
    else out.kept++;
  }
  const evidence = await scanEvidence(db);
  out.reads += evidence.reads;
  await unlinkDeclineEvidence(db, live, out, evidence.declines);
  await inspectAdultEvidence(db, evidence.adultParents, out, {live});
  await removeOldSendLimiters(db, live, out);
  return out;
}

/** These limiters used to sit under the account. The code no longer writes them, so every one left is removed. */
const OLD_LIMITERS = ['guardianSend', 'guardianStatus', 'guardianAdult', 'guardianAnswer'];
async function removeOldSendLimiters(db, live, out) {
  let reads = 0;
  for await (const doc of db.collectionGroup('limits').stream()) {
    reads++;
    if (!OLD_LIMITERS.includes(doc.id) || !doc.ref.path.startsWith('users/')) continue;
    out.limitersRemoved++; out.writes++;
    if (live) await doc.ref.delete();
  }
  out.reads += Math.max(1, reads);
}

async function scanEvidence(db) {
  const declines = [];
  const adultParents = new Map();
  let reads = 0;
  for await (const doc of db.collectionGroup('responses').stream()) {
    reads++;
    const parent = doc.ref.parent.parent;
    if (parent?.parent.path !== 'guardianConsentEvidence') continue;
    const action = doc.get('action');
    if (action === 'decline') declines.push(doc.ref);
    if (action === 'became_adult') adultParents.set(parent.path, parent);
  }
  return {declines, adultParents, reads: Math.max(1, reads)};
}

async function inspectAdultEvidence(db, adultParents, out, {live = false, verify = false}) {
  for (const parent of adultParents.values()) {
    const result = await db.runTransaction(async tx => {
      // Recheck in the same transaction as the deletes in case evidence changed since the scan.
      const responses = await tx.get(parent.collection('responses'));
      let reads = Math.max(1, responses.size);
      if (responses.docs.some(row => row.get('action') === 'confirm')) {
        return {rows: 0, parents: 0, reads};
      }
      const adultRows = responses.docs.filter(row => row.get('action') === 'became_adult');
      let parentExists = false;
      if (!verify && adultRows.length > 0 && adultRows.length === responses.size) {
        const purchases = await tx.get(parent.collection('purchases').limit(1));
        reads++;
        if (purchases.empty) {
          parentExists = (await tx.get(parent)).exists;
          reads++;
        }
      }
      if (live) {
        for (const row of adultRows) tx.delete(row.ref);
        if (parentExists) tx.delete(parent);
      }
      return {rows: adultRows.length, parents: Number(parentExists), reads};
    });
    out.reads += result.reads;
    out.unconfirmedAdultRows += result.rows;
    if (!verify) {
      out.emptyEvidenceParents += result.parents;
      out.writes += result.rows + result.parents;
    }
  }
}

/**
 * Decline evidence written by the earlier code is named after the link row that answered it, and that
 * row stays for seven days. This copies each such answer to an id of its own and deletes the old one.
 */
async function unlinkDeclineEvidence(db, live, out, declines) {
  for (const ref of declines) {
    const link = await db.doc(`guardianTokens/${ref.id}`).get();
    out.reads++;
    if (!link.exists) continue;
    out.reads += 2;
    const moved = await db.runTransaction(async tx => {
      const old = await tx.get(ref);
      const row = await tx.get(link.ref);
      // The cleanup may have deleted the link since the lookup. It is never recreated.
      if (!old.exists || !row.exists) return false;
      if (!live) return true;
      tx.set(ref.parent.doc(), old.data());
      tx.delete(ref);
      // The kept link also loses its exact answer time, which would join it to the evidence.
      const event = row.get('usedAt') ?? row.get('revokedAt');
      tx.set(link.ref, {usedAt: FieldValue.delete(), revokedAt: FieldValue.delete(), uid: FieldValue.delete(),
        ...(typeof event === 'number' ? {cleanupAt: coarseEnd(event)} : {})}, {merge: true});
      return true;
    });
    if (moved) { out.evidenceUnlinked++; out.writes += 3; }
  }
}

/**
 * Counts rows without a cleanup time and adult switch rows without a confirmation.
 * With `mark`, zero remaining writes the marker that stops the daily scan in the hourly cleanup.
 */
export async function countUndated({db, mark = false}) {
  let records = 0, tokens = 0, counters = 0, reads = 0;
  let scanned = 0;
  for await (const doc of db.collectionGroup('server').stream()) {
    scanned++;
    if (doc.id === 'guardianConsent' && uidOf(doc.ref) && needsDueField(doc.data())) records++;
  }
  reads += Math.max(1, scanned);
  scanned = 0;
  for await (const doc of db.collection('guardianTokens').stream()) {
    scanned++;
    if (doc.get('cleanupAt') === undefined && !(doc.get('kind') === 'manage' && doc.get('state') === 'open')) tokens++;
  }
  reads += Math.max(1, scanned);
  scanned = 0;
  for await (const doc of db.collection('guardianLimits').stream()) {
    scanned++;
    if (doc.get('cleanupAt') === undefined && doc.ref.path !== BACKFILL_MARKER) counters++;
  }
  reads += Math.max(1, scanned);
  const evidence = await scanEvidence(db);
  const out = {reads: reads + evidence.reads, unconfirmedAdultRows: 0};
  await inspectAdultEvidence(db, evidence.adultParents, out, {verify: true});
  const undated = records + tokens + counters;
  const marked = mark && undated === 0 && out.unconfirmedAdultRows === 0;
  if (marked) await db.doc(BACKFILL_MARKER).set({verifiedAt: Date.now()});
  return {undated, records, tokens, counters, ...out, writes: Number(marked), marked};
}

/** One line of counts. Writes include deletes. A retried transaction can add reads. */
export function summary(project, live, r) {
  const would = live ? '' : ' would be';
  const deletes = r.deleted - r.adultMarksKept + r.linksRemoved + r.evidenceUnlinked + r.limitersRemoved
    + r.unconfirmedAdultRows + r.emptyEvidenceParents;
  return `${live ? 'LIVE' : 'DRY RUN'} ${project}: ${r.guardianRecords} guardian records among ${r.serverDocuments} server documents; `
    + `${r.deleted} deleted${would ? ' (would be)' : ''}, ${r.scheduled} given a cleanup time${would ? ' (would be)' : ''}, ${r.kept} kept; `
    + `links: ${r.linksRemoved} deleted, ${r.linksStripped} cleared of the account${would ? ' (would be)' : ''}; `
    + `${r.evidenceUnlinked} decline answers moved to their own id${would ? ' (would be)' : ''}; ${r.limitersRemoved} old uid-keyed limiter rows deleted${would ? ' (would be)' : ''}; `
    + `${r.unconfirmedAdultRows} adult switch rows without a confirmation and ${r.emptyEvidenceParents} empty evidence parents deleted${would ? ' (would be)' : ''}; `
    + `retry-free estimate: ${r.reads} reads, ${r.writes} writes${live ? '' : ' if run live'} (${deletes} deletes included)`;
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
      const r = await countUndated({db: getFirestore(), mark: true});
      console.log(`VERIFY ${project}: ${r.records} records, ${r.tokens} links, ${r.counters} counters without a cleanup time; ${r.unconfirmedAdultRows} adult switch rows without a confirmation${r.marked ? '; daily scan switched off' : ''}; retry-free estimate: ${r.reads} reads, ${r.writes} writes`);
      if (r.undated || r.unconfirmedAdultRows) process.exit(2);
    } else {
      console.log(summary(project, args.live, await removeUnconfirmedGuardianRecords({db: getFirestore(), live: args.live})));
    }
  } catch (e) {
    console.error(e?.message === 'usage' ? 'REASON usage' : 'REASON failed');
    process.exit(1);
  }
}
