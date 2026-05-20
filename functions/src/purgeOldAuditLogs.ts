import { onSchedule } from 'firebase-functions/v2/scheduler';

export const purgeOldAuditLogs = onSchedule(
  {
    schedule: 'every day 03:30',
    timeZone: 'Asia/Singapore',
    region: 'asia-southeast1',
  },
  async () => {
    return;
  },
);
