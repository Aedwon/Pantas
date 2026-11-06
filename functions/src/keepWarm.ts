import { logger } from 'firebase-functions';
import { defineBoolean } from 'firebase-functions/params';
import { onSchedule } from 'firebase-functions/v2/scheduler';

const warmupEnabled = defineBoolean('WARMUP_ENABLED', { default: false });
const targets = [
  'getBetaAccess', 'getRoadmap', 'setExamSettings', 'getWebEntitlement',
  'getMockAvailability', 'getStudyInsights', 'getContent',
];

export async function warmCallables(
  enabled: boolean,
  project: string | undefined,
  fetcher: typeof fetch = fetch,
): Promise<void> {
  if (!enabled) return;
  if (!project) {
    logger.warn('keepCallablesWarm: GCLOUD_PROJECT is missing');
    return;
  }
  const urls = targets.map(name => `https://asia-southeast1-${project}.cloudfunctions.net/${name}`);
  const results = await Promise.allSettled(urls.map(async url => {
    const response = await fetcher(url, {
      method: 'OPTIONS',
      headers: {
        Origin: 'https://app.pantas.study',
        'Access-Control-Request-Method': 'POST',
      },
      signal: AbortSignal.timeout(10000),
    });
    if (!response.ok) throw new Error(`Preflight returned ${response.status}`);
  }));
  const failedTargets = urls.filter((_, index) => results[index].status === 'rejected');
  if (failedTargets.length) logger.warn('keepCallablesWarm: preflights failed', { failedTargets });
}

export const keepCallablesWarm = onSchedule(
  { schedule: 'every 5 minutes', region: 'asia-southeast1' },
  async () => warmCallables(warmupEnabled.value(), process.env.GCLOUD_PROJECT),
);
