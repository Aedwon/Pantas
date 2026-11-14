/**
 * Env switches read once when the module loads, because they decide which functions are exported.
 * firebase-tools puts `.env.<project>` into the environment before it loads the code to find the
 * functions. Only an explicit off value turns a switch off, so a typo cannot silently stop cleanup.
 */
const OFF = new Set(['off', 'false', '0', 'no']);

export function switchIsOn(value: string | undefined): boolean {
  return !OFF.has((value ?? '').trim().toLowerCase());
}

export const scheduledJobsOn = switchIsOn(process.env.SCHEDULED_JOBS);
export const legacySchedulesOn = switchIsOn(process.env.LEGACY_SCHEDULES);
