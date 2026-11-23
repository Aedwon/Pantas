import {Timestamp} from 'firebase-admin/firestore';
import {DAY_MS} from './grants.js';

/**
 * How long a trial code is kept after its trial started (legal ruling D7). The Firestore TTL policy
 * on the `trialUsedIdentities` expiry field removes the code then, so no cleanup job exists. 730 days
 * covers four CSE sittings, so a trial cannot be repeated each exam season.
 */
export const TRIAL_CODE_DAYS = 730;

/** The row for one used trial identity. `startedAt` is the trial start in epoch milliseconds. */
export function trialMarker(startedAt: number) {
  const expireAt = Timestamp.fromMillis(startedAt + TRIAL_CODE_DAYS * DAY_MS);
  return {used: true, startedAt, expireAt};
}

/** True when a stored code already lasts at least as long as `row`, so a rewrite must keep it. */
export function keepsStoredExpiry(existing: {exists: boolean; get(field: string): unknown}, row: {expireAt: Timestamp}): boolean {
  const stored = existing.exists ? existing.get('expireAt') : undefined;
  return stored instanceof Timestamp && stored.toMillis() >= row.expireAt.toMillis();
}
