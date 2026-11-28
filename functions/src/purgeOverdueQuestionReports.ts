import {getFirestore, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';

/**
 * The sweep behind the report TTL. Reports are written with a deletion time 85 days out and a
 * Firestore TTL policy removes them, but Google gives only "typically within 24 hours", not a
 * time. The published promise is "within 90 days of receipt", so this daily task deletes any
 * report received more than 86 days ago that TTL has not removed. It finds them by `createdAt`,
 * because the TTL field's single-field index is switched off and cannot be queried.
 *
 * It is a task inside an existing daily job, not a scheduled job of its own. Cost: when nothing
 * is overdue, one query that reads nothing and is billed one read, once a day. Each overdue report
 * costs one read and one delete. A run deletes at most `MAX_PER_RUN`; the rest wait for the next.
 */
export const SWEEP_AFTER_DAYS = 86;
const PAGE = 200;
export const MAX_PER_RUN = 1000;

export async function runPurgeOverdueQuestionReports(
  deps: {db?: Firestore; now?: () => number} = {},
): Promise<{deleted: number}> {
  const db = deps.db ?? getFirestore();
  const cutoff = Timestamp.fromMillis((deps.now ?? Date.now)() - SWEEP_AFTER_DAYS * 86_400_000);
  let deleted = 0;
  while (deleted < MAX_PER_RUN) {
    const page = await db.collection('questionReports').where('createdAt', '<', cutoff)
      .limit(Math.min(PAGE, MAX_PER_RUN - deleted)).get();
    if (page.empty) break;
    const batch = db.batch();
    for (const doc of page.docs) batch.delete(doc.ref);
    await batch.commit();
    deleted += page.size;
    if (page.size < PAGE) break;
  }
  logger.info('purgeOverdueQuestionReports', {deleted});
  return {deleted};
}
