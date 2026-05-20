import { onSchedule } from 'firebase-functions/v2/scheduler';

export const purgeOldExports = onSchedule(
  {
    schedule: 'every day 03:15',
    timeZone: 'Asia/Singapore',
    region: 'asia-southeast1',
  },
  async () => {
    return;
  },
);
