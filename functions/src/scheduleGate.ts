/**
 * Env switches read once when the module loads, because they decide which functions are exported.
 * Only an explicit off value turns a switch off, so a typo cannot silently stop cleanup.
 *
 * The pinned firebase-tools (functions/package.json) puts `.env.<project>` into the environment
 * before it loads the code to find the functions. The global firebase-tools 15.26.0 does not: on
 * Nov 14, 2026 a staging deploy with it listed schedules that the deployed code, which did get the
 * file, then did not export, and every scheduled function failed its health check. Discovery for a
 * real project without its file now stops the deploy before anything changes.
 */
const REAL_PROJECTS = new Set(['pantas-prod', 'pantas-staging']);
if (process.env.FUNCTIONS_CONTROL_API === 'true' && REAL_PROJECTS.has(process.env.GCLOUD_PROJECT ?? '') &&
    process.env.SCHEDULED_JOBS === undefined) {
  throw new Error(`functions/.env.${process.env.GCLOUD_PROJECT} was not loaded when firebase-tools read the ` +
    'functions, so it would deploy the wrong set. Deploy with the pinned firebase-tools: ' +
    '`npx --prefix functions firebase deploy ...` (the global 15.26.0 does not pass project env files to discovery).');
}
const OFF = new Set(['off', 'false', '0', 'no']);

export function switchIsOn(value: string | undefined): boolean {
  return !OFF.has((value ?? '').trim().toLowerCase());
}

export const scheduledJobsOn = switchIsOn(process.env.SCHEDULED_JOBS);
export const legacySchedulesOn = switchIsOn(process.env.LEGACY_SCHEDULES);
