import {createHash} from 'node:crypto';
import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {onDocumentWritten} from 'firebase-functions/v2/firestore';
import {logger} from 'firebase-functions';
import {getFirestore} from 'firebase-admin/firestore';
import {isValidPublicId} from './publicId.js';
import {serviceAccountEmail} from './serviceAccounts.js';

/**
 * Per-account sync write quota (M4b, option C). Every sync row write adds to a daily counter at
 * `users/{uid}/limits/sync_<YYYYMMDD UTC>`. On about 1 event in 20 the counter is read, and past a cap
 * the account is paused: `suspendedUntil` on `users/{uid}/sync_state/current`, which the rules check.
 *
 * The counter is a blind increment, so a retried event can count a row twice. An over-count by retries
 * is acceptable: the caps are abuse limits well above real use, not billing. Nothing here throws, so a
 * malformed row can never make the trigger fail or retry.
 */

export interface SyncCaps {rowsPerHour: number; rowsPerDay: number; bytesPerDay: number}

function envNumber(name: string, fallback: number): number {
  const value = Number(process.env[name]);
  return Number.isFinite(value) && value > 0 ? Math.floor(value) : fallback;
}

/** Caps come from environment values (staging lowers them for the abuse run). */
export function syncCaps(): SyncCaps {
  return {
    rowsPerHour: envNumber('SYNC_ROWS_PER_HOUR', 10_000),
    rowsPerDay: envNumber('SYNC_ROWS_PER_DAY', 30_000),
    bytesPerDay: envNumber('SYNC_BYTES_PER_DAY', 50_000_000),
  };
}

export const dayKey = (at: Date): string => at.toISOString().slice(0, 10).replaceAll('-', '');
const hourKey = (at: Date): string => `h${String(at.getUTCHours()).padStart(2, '0')}`;
export const nextUtcHour = (at: Date): Date =>
  new Date(Date.UTC(at.getUTCFullYear(), at.getUTCMonth(), at.getUTCDate(), at.getUTCHours() + 1));
export const purgeAtFor = (at: Date): Date =>
  new Date(Date.UTC(at.getUTCFullYear(), at.getUTCMonth(), at.getUTCDate() + 2));
export const nextUtcMidnight = (at: Date): Date =>
  new Date(Date.UTC(at.getUTCFullYear(), at.getUTCMonth(), at.getUTCDate() + 1));

/** True for about 1 event in `every`, decided by a hash of the event id. */
export function shouldCheck(eventId: string, every: number): boolean {
  if (every <= 1) return true;
  return createHash('sha256').update(eventId).digest().readUInt32BE(0) % every === 0;
}

function rowBytes(row: unknown): number {
  try { return Buffer.byteLength(JSON.stringify(row) ?? ''); } catch { return 0; }
}

async function publicIdOf(db: Firestore, uid: string): Promise<string> {
  try {
    const id: unknown = (await db.doc(`users/${uid}`).get()).get('publicId');
    return isValidPublicId(id) ? id : 'none';
  } catch { return 'unknown'; }
}

export async function recordSyncWrite(db: Firestore,
  input: {uid: string; eventId: string; row: unknown; generationId?: string; now?: Date}): Promise<void> {
  try {
    if (input.row === undefined || input.row === null) return;
    const now = input.now ?? new Date();
    const counters = db.doc(`users/${input.uid}/limits/sync_${dayKey(now)}`);
    await counters.set({rows: FieldValue.increment(1), bytes: FieldValue.increment(rowBytes(input.row)),
      [hourKey(now)]: FieldValue.increment(1),
      // For a Firestore TTL policy on the `limits` collection group (not yet configured; see the M4b notes).
      purgeAt: Timestamp.fromDate(purgeAtFor(now))}, {merge: true});
    if (!shouldCheck(input.eventId, envNumber('SYNC_CHECK_EVERY', 20))) return;
    const caps = syncCaps();
    const counted = (await counters.get()).data() ?? {};
    const hour = Number(counted[hourKey(now)] ?? 0);
    const dailyReason = Number(counted.rows ?? 0) > caps.rowsPerDay ? 'daily rows'
      : Number(counted.bytes ?? 0) > caps.bytesPerDay ? 'daily bytes' : null;
    const reason = dailyReason ?? (hour > caps.rowsPerHour ? 'hourly' : null);
    if (reason === null) return;
    const until = dailyReason === null ? nextUtcHour(now) : nextUtcMidnight(now);
    const target = Timestamp.fromDate(until);
    const targets = [`users/${input.uid}/sync_state/current`];
    if (input.generationId) targets.push(`users/${input.uid}/sync_generations/${input.generationId}`);
    let wrote = false;
    for (const path of targets) {
      const ref = db.doc(path);
      const current = await ref.get();
      // Never create either document: the app reads sync_state/current as the active generation pointer.
      if (!current.exists) continue;
      const existing: unknown = current.get('suspendedUntil');
      if (existing instanceof Timestamp && existing.toMillis() >= until.getTime()) continue;
      await ref.update({suspendedUntil: target});
      wrote = true;
    }
    if (wrote) logger.warn(`sync paused ${reason}`, {publicId: await publicIdOf(db, input.uid)});
  } catch (error) {
    console.error('Sync write count failed', {error: error instanceof Error ? error.message : 'unknown'});
  }
}

export const countSyncWrites = onDocumentWritten(
  {
    document: 'users/{uid}/sync_generations/{generationId}/{collection}/{rowId}',
    region: 'asia-southeast1',
    serviceAccount: serviceAccountEmail('pantas-jobs'),
    maxInstances: 3,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    await recordSyncWrite(getFirestore(), {uid: event.params.uid, eventId: event.id, row: after.data(), generationId: event.params.generationId});
  },
);
