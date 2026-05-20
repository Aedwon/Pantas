import { onSchedule } from 'firebase-functions/v2/scheduler';

export const cleanupOrphanAnons = onSchedule(
  {
    schedule: 'every day 03:00',
    timeZone: 'Asia/Singapore',
    region: 'asia-southeast1',
  },
  async () => {
    return;
  },
);
