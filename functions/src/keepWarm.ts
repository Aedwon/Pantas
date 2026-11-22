import { logger } from 'firebase-functions';
import { defineBoolean } from 'firebase-functions/params';
import { onSchedule } from 'firebase-functions/v2/scheduler';

const warmupEnabled = defineBoolean('WARMUP_ENABLED', { default: false });
/**
 * The warm-up stops here whatever WARMUP_ENABLED says (Fable 5.2 rule 7 ruling 3): Nov 24, 2026
 * 00:00 in Manila. Past it, the 5-minute pings are a cost with no beta to serve.
 */
export const WARMUP_ENDS_AT = '2026-11-23T16:00:00Z';
const targets = [
  'getBetaAccess', 'getRoadmap', 'setExamSettings', 'getWebEntitlement',
  'getMockAvailability', 'getStudyInsights', 'getContent',
  // The study loop: Home waits on these after a quiz or a lesson. Cold they took 2.5 to 3.4 s.
  'ingestSession', 'recordLessonRead', 'getSessionDiagnosis', 'advanceRoadmap',
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

/** The whole warm-up task, for the combined five-minute job and the manual runner. */
export async function runKeepCallablesWarm(options: {
  enabled?: boolean; now?: number; project?: string | undefined; fetcher?: typeof fetch;
} = {}): Promise<void> {
  const now = options.now ?? Date.now();
  if (now >= Date.parse(WARMUP_ENDS_AT)) return;
  await warmCallables(options.enabled ?? warmupEnabled.value(), 'project' in options ? options.project : process.env.GCLOUD_PROJECT, options.fetcher);
}

export const keepCallablesWarm = onSchedule(
  { schedule: 'every 5 minutes', region: 'asia-southeast1', serviceAccount: 'pantas-jobs@' },
  async () => runKeepCallablesWarm(),
);
