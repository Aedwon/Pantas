import { getAuth, type Auth, type UserRecord } from 'firebase-admin/auth';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { deleteGuardianRecords } from './guardianConsent.js';

function isOldAnonymous(user: UserRecord, cutoff: number): boolean {
  // Pantas anonymous identities have no linked provider, email, or phone.
  const lastSignIn = Date.parse(user.metadata.lastSignInTime);
  const lastRefresh = Date.parse(user.metadata.lastRefreshTime ?? '');
  return user.providerData.length === 0 && !user.email && !user.phoneNumber
    && Number.isFinite(lastSignIn) && lastSignIn < cutoff
    && (!Number.isFinite(lastRefresh) || lastRefresh < cutoff);
}

// Subcollections an anonymous account may hold that are safe to delete with it: server-side
// answers and mock records, and rate-limit counters. Anything else keeps the account.
const DISPOSABLE = new Set(['server', 'limits']);

async function onlyDisposableData(db: Firestore, uid: string): Promise<boolean> {
  const root = db.doc(`users/${uid}`);
  const collections = await root.listCollections();
  if (collections.some((collection) => !DISPOSABLE.has(collection.id))) return false;
  // An entitlement or trial record means the account touched payments; leave it for support.
  const kept = await db.getAll(root.collection('server').doc('entitlement'), root.collection('server').doc('trial'));
  return kept.every((doc) => !doc.exists);
}

/** A run stops starting new pages after this long, leaving room under the 540 second timeout. */
const RUN_BUDGET_MS = 450_000;
const PAGE_SIZE = 500;

export type OrphanAnonDeps = {
  auth: Pick<Auth, 'listUsers' | 'getUser' | 'deleteUser'>;
  db: Firestore;
  pageSize?: number;
  /** Stop after this many pages. For tests. */
  maxPages?: number;
  budgetMs?: number;
};

/**
 * Deletes old orphan anonymous accounts. The place in the user list is kept in
 * `jobState/cleanupOrphanAnons`, so each run continues where the last one stopped, and the next
 * run after the end of the list starts again from the beginning. `finished` is true when the end
 * of the list was reached.
 */
export async function runOrphanAnonCleanup(deps: OrphanAnonDeps): Promise<{scanned: number; deleted: number; finished: boolean}> {
  const {auth, db} = deps;
  const state = db.doc('jobState/cleanupOrphanAnons');
  const cutoff = Date.now() - 30 * 86400000;
  const deadline = Date.now() + (deps.budgetMs ?? RUN_BUDGET_MS);
  const saved: unknown = (await state.get()).get('cursor');
  let pageToken: string | undefined = typeof saved === 'string' && saved.length > 0 ? saved : undefined;
  let scanned = 0;
  let deleted = 0;
  let pages = 0;
  let finished = false;
  while (true) {
    let page;
    try {
      page = await auth.listUsers(deps.pageSize ?? PAGE_SIZE, pageToken);
    } catch (error) {
      // A saved token that no longer works restarts the list instead of failing every run.
      if (pageToken === undefined) throw error;
      logger.warn('cleanupOrphanAnons cursor rejected, starting again', { error: String(error) });
      pageToken = undefined;
      await state.set({ cursor: null, updatedAt: Date.now() });
      continue;
    }
    for (const user of page.users) {
      scanned += 1;
      if (!isOldAnonymous(user, cutoff)) continue;
      const root = db.doc(`users/${user.uid}`);
      if ((await root.get()).exists || !(await onlyDisposableData(db, user.uid))) continue;
      const shares = await db.collection('wrapped_shares').where('ownerUid', '==', user.uid).limit(1).get();
      if (!shares.empty) continue;
      // Recheck after the data reads in case the user signed in or linked a provider.
      let fresh: UserRecord;
      try {
        fresh = await auth.getUser(user.uid);
      } catch (error) {
        if ((error as { code?: string }).code === 'auth/user-not-found') continue;
        throw error;
      }
      if (!isOldAnonymous(fresh, cutoff)) continue;
      // Synced answers, mock records and limits belong to an identity no one can sign in to again.
      await deleteGuardianRecords(db, user.uid);
      await db.recursiveDelete(root);
      await auth.deleteUser(user.uid);
      deleted += 1;
    }
    pages += 1;
    pageToken = page.pageToken;
    // Saved after each page, so a timeout loses at most one page of work.
    await state.set({ cursor: pageToken ?? null, updatedAt: Date.now() });
    if (!pageToken) { finished = true; break; }
    if (pages >= (deps.maxPages ?? Infinity) || Date.now() >= deadline) break;
  }
  logger.info('cleanupOrphanAnons', { scanned, deleted, finished });
  return { scanned, deleted, finished };
}

export const cleanupOrphanAnons = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Asia/Singapore', region: 'asia-southeast1', timeoutSeconds: 540 },
  async () => {
    await runOrphanAnonCleanup({ auth: getAuth(), db: getFirestore() });
  },
);
