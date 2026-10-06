import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';

export const cleanupWrappedOrphans = onSchedule(
  { schedule: 'every day 04:15', timeZone: 'Asia/Singapore', region: 'asia-southeast1' },
  async () => {
    const db = getFirestore();
    const bucket = getStorage().bucket();
    const cutoff = Date.now() - 24 * 60 * 60 * 1000;
    let pageToken: string | undefined;
    let scanned = 0;
    let deleted = 0;
    do {
      const [files, nextQuery] = await bucket.getFiles({
        prefix: 'wrapped/', maxResults: 500, autoPaginate: false, pageToken,
      });
      for (const file of files) {
        scanned += 1;
        if (!/^wrapped\/[^/]+\/.+/.test(file.name)) continue;
        const createdAt = Date.parse(file.metadata.timeCreated ?? '');
        if (!Number.isFinite(createdAt) || createdAt >= cutoff) continue;
        const shares = await db.collection('wrapped_shares').where('storagePath', '==', file.name).limit(1).get();
        if (!shares.empty) continue;
        await file.delete({ ignoreNotFound: true });
        deleted += 1;
      }
      pageToken = nextQuery?.pageToken;
    } while (pageToken);
    logger.info('cleanupWrappedOrphans', { scanned, deleted });
  },
);
