import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';

/** A run stops starting new pages after this long, leaving room under the 540 second timeout. */
const RUN_BUDGET_MS = 450_000;
const PAGE_SIZE = 500;

export type WrappedCleanupDeps = {
  db: Firestore;
  bucket: ReturnType<ReturnType<typeof getStorage>['bucket']>;
  now?: () => number;
  pageSize?: number;
  /** Stop after this many pages. For tests. */
  maxPages?: number;
  budgetMs?: number;
};

/**
 * Deletes wrapped card files that no share record points to. The place in the file list is kept in
 * `jobState/cleanupWrappedOrphans`, so each run continues where the last one stopped, and the next
 * run after the end of the list starts again from the beginning. `finished` is true when the end
 * of the list was reached.
 */
export async function runWrappedCleanup(deps: WrappedCleanupDeps): Promise<{scanned: number; deleted: number; finished: boolean}> {
  const { db, bucket } = deps;
  const now = deps.now ?? Date.now;
  const state = db.doc('jobState/cleanupWrappedOrphans');
  const cutoff = now() - 24 * 60 * 60 * 1000;
  const deadline = Date.now() + (deps.budgetMs ?? RUN_BUDGET_MS);
  const saved: unknown = (await state.get()).get('cursor');
  let pageToken: string | undefined = typeof saved === 'string' && saved.length > 0 ? saved : undefined;
  let scanned = 0;
  let deleted = 0;
  let pages = 0;
  let finished = false;
  while (true) {
    let files;
    let nextQuery;
    try {
      [files, nextQuery] = await bucket.getFiles({
        prefix: 'wrapped/', maxResults: deps.pageSize ?? PAGE_SIZE, autoPaginate: false, pageToken,
      });
    } catch (error) {
      // A saved token that no longer works restarts the list instead of failing every run.
      if (pageToken === undefined) throw error;
      logger.warn('cleanupWrappedOrphans cursor rejected, starting again', { error: String(error) });
      pageToken = undefined;
      await state.set({ cursor: null, updatedAt: Date.now() });
      continue;
    }
    for (const file of files) {
      scanned += 1;
      if (!/^wrapped\/[^/]+\/.+/.test(file.name)) continue;
      const generation = file.metadata.generation;
      if (generation == null) continue;
      const createdAt = Date.parse(file.metadata.timeCreated ?? '');
      if (!Number.isFinite(createdAt) || createdAt >= cutoff) continue;
      const shares = await db.collection('wrapped_shares').where('storagePath', '==', file.name).limit(1).get();
      if (!shares.empty) continue;
      const latestShares = await db.collection('wrapped_shares').where('storagePath', '==', file.name).limit(1).get();
      if (!latestShares.empty) continue;
      try {
        await file.delete({ ignoreNotFound: true, ifGenerationMatch: generation });
        deleted += 1;
      } catch (error) {
        if ((error as { code?: number }).code !== 412) throw error;
        // A replacement belongs to its publisher, not this cleanup snapshot.
      }
    }
    pages += 1;
    pageToken = (nextQuery as { pageToken?: string } | null | undefined)?.pageToken;
    // Saved after each page, so a timeout loses at most one page of work.
    await state.set({ cursor: pageToken ?? null, updatedAt: Date.now() });
    if (!pageToken) { finished = true; break; }
    if (pages >= (deps.maxPages ?? Infinity) || Date.now() >= deadline) break;
  }
  logger.info('cleanupWrappedOrphans', { scanned, deleted, finished });
  return { scanned, deleted, finished };
}

export const cleanupWrappedOrphans = onSchedule(
  { schedule: 'every day 04:15', timeZone: 'Asia/Singapore', region: 'asia-southeast1', timeoutSeconds: 540 },
  async () => {
    await runWrappedCleanup({ db: getFirestore(), bucket: getStorage().bucket() });
  },
);
