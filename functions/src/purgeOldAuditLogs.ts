import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';

export const purgeOldAuditLogs = onSchedule(
  { schedule: 'every day 03:30', timeZone: 'Asia/Singapore', region: 'asia-southeast1' },
  async () => {
    const db = getFirestore();
    const cutoff = Timestamp.fromMillis(Date.now() - 730 * 86400000);
    let deleted = 0;
    while (true) {
      const page = await db.collection('audit_logs').where('timestamp', '<', cutoff).limit(500).get();
      if (page.empty) break;
      const batch = db.batch();
      for (const document of page.docs) batch.delete(document.ref);
      await batch.commit();
      deleted += page.size;
      if (page.size < 500) break;
    }
    logger.info('purgeOldAuditLogs', { deleted });
  },
);
