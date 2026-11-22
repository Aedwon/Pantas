import { logger } from 'firebase-functions';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { runCleanupOrphanAnons } from './cleanupOrphanAnons.js';
import { runCleanupSyncData } from './cleanupSyncData.js';
import { runCleanupWrappedOrphans } from './cleanupWrappedOrphans.js';
import { runPurgeOldGuardianRecords } from './guardianConsent.js';
import { runKeepCallablesWarm } from './keepWarm.js';
import { purgeInactiveSecrets, runPurgeInactiveAccounts } from './purgeInactiveAccounts.js';
import { runPurgeOldAuditLogs } from './purgeOldAuditLogs.js';
import { runCheckRecentEntitlementClaims, runRepairEntitlementClaims } from './revenuecatWebhook.js';

/**
 * Cloud Scheduler bills per job after three free ones per billing account, and paused jobs count.
 * So prod runs nine tasks from three jobs. Each task is a plain function; a job runs its tasks one
 * after another, each in its own try/catch with its own time budget, so one failure never stops
 * the rest and the job itself never throws because of a task.
 */
export const TASK_NAMES = [
  'keepCallablesWarm', 'repairEntitlementClaims', 'purgeOldGuardianRecords',
  'cleanupOrphanAnons', 'purgeOldAuditLogs', 'checkRecentEntitlementClaims',
  'cleanupSyncData', 'purgeInactiveAccounts', 'cleanupWrappedOrphans',
] as const;
export type TaskName = (typeof TASK_NAMES)[number];

export type ScheduledTask = { name: TaskName; budgetMs: number; run: () => Promise<unknown> };
export type TaskRegistry = Record<TaskName, ScheduledTask>;
export type TaskOutcome = { task: TaskName; ok: boolean; ms: number; result?: unknown; error?: string };
export type JobDeps = { log?: (message: string, fields: Record<string, unknown>) => void };

/**
 * Time each task may take. The three long cleanups keep the 540 s they had as their own functions.
 * The rest had the platform default as their own functions; they get at least that. A budget stops
 * the job waiting; it cannot cancel the work, which ends when the instance does.
 */
const SECOND = 1000;
export const TASKS: TaskRegistry = {
  keepCallablesWarm: { name: 'keepCallablesWarm', budgetMs: 30 * SECOND, run: runKeepCallablesWarm },
  repairEntitlementClaims: { name: 'repairEntitlementClaims', budgetMs: 120 * SECOND, run: runRepairEntitlementClaims },
  purgeOldGuardianRecords: { name: 'purgeOldGuardianRecords', budgetMs: 120 * SECOND, run: runPurgeOldGuardianRecords },
  cleanupOrphanAnons: { name: 'cleanupOrphanAnons', budgetMs: 540 * SECOND, run: runCleanupOrphanAnons },
  purgeOldAuditLogs: { name: 'purgeOldAuditLogs', budgetMs: 300 * SECOND, run: runPurgeOldAuditLogs },
  checkRecentEntitlementClaims: { name: 'checkRecentEntitlementClaims', budgetMs: 300 * SECOND, run: runCheckRecentEntitlementClaims },
  cleanupSyncData: { name: 'cleanupSyncData', budgetMs: 300 * SECOND, run: runCleanupSyncData },
  purgeInactiveAccounts: { name: 'purgeInactiveAccounts', budgetMs: 540 * SECOND, run: runPurgeInactiveAccounts },
  cleanupWrappedOrphans: { name: 'cleanupWrappedOrphans', budgetMs: 540 * SECOND, run: runCleanupWrappedOrphans },
};

export const HOURLY_TASKS: readonly TaskName[] = ['repairEntitlementClaims', 'purgeOldGuardianRecords'];
export const DAILY_EARLY_TASKS: readonly TaskName[] = ['cleanupOrphanAnons', 'purgeOldAuditLogs', 'checkRecentEntitlementClaims'];
export const DAILY_LATE_TASKS: readonly TaskName[] = ['cleanupSyncData', 'purgeInactiveAccounts', 'cleanupWrappedOrphans'];

/** Function timeouts. Each is above the sum of its tasks' budgets; the five-minute job ends before the next trigger. */
export const JOB_TIMEOUT_SECONDS = { jobsFrequent: 300, jobsDailyEarly: 1800, jobsDailyLate: 1800 } as const;

/**
 * Tasks for one five-minute run. Warm-up runs every time. The hourly tasks run on the first run
 * of each hour, judged from the scheduled time, so a late delivery cannot skip or double an hour.
 * Manila and Singapore are whole hours from UTC, so UTC minutes give the same answer there.
 * With no readable scheduled time the hourly tasks run, because they are safe to repeat.
 */
export function frequentTaskNames(scheduleTime?: string): TaskName[] {
  const scheduled = Date.parse(scheduleTime ?? '');
  const minute = new Date(Number.isFinite(scheduled) ? scheduled : Date.now()).getUTCMinutes();
  const firstOfHour = !Number.isFinite(scheduled) || minute < 5;
  return ['keepCallablesWarm', ...(firstOfHour ? HOURLY_TASKS : [])];
}

function withBudget<T>(work: Promise<T>, budgetMs: number): Promise<T> {
  let timer: NodeJS.Timeout | undefined;
  const timeout = new Promise<never>((_, reject) => {
    timer = setTimeout(() => reject(new Error(`timed out after ${budgetMs} ms`)), budgetMs);
  });
  return Promise.race([work, timeout]).finally(() => clearTimeout(timer));
}

const message = (error: unknown): string => (error instanceof Error ? error.message : String(error));

/**
 * Runs the named tasks in order. A task that throws or runs past its budget logs one ERROR line,
 * `Scheduled task failed: <taskName>`, with the task and the error message as fields. That line is
 * what the log-based alert matches. The job resolves whatever happens.
 */
export async function runJob(
  names: readonly TaskName[],
  registry: TaskRegistry = TASKS,
  deps: JobDeps = {},
): Promise<TaskOutcome[]> {
  const log = deps.log ?? ((text, fields) => logger.error(text, fields));
  const outcomes: TaskOutcome[] = [];
  for (const name of names) {
    const task = registry[name];
    const started = Date.now();
    try {
      const result = await withBudget(Promise.resolve().then(() => task.run()), task.budgetMs);
      outcomes.push({ task: name, ok: true, ms: Date.now() - started, result });
    } catch (error) {
      log(`Scheduled task failed: ${name}`, { task: name, error: message(error), ms: Date.now() - started });
      outcomes.push({ task: name, ok: false, ms: Date.now() - started, error: message(error) });
    }
  }
  return outcomes;
}

const region = 'asia-southeast1';
// One instance, one request at a time: the late job sends email and deletes accounts, so two runs
// must never overlap. Cloud Scheduler delivers at least once; a duplicate waits or is refused.
const oneAtATime = { region, serviceAccount: 'pantas-jobs@', maxInstances: 1, concurrency: 1 } as const;

export const jobsFrequent = onSchedule(
  { ...oneAtATime, schedule: 'every 5 minutes', timeoutSeconds: JOB_TIMEOUT_SECONDS.jobsFrequent },
  async (event) => { await runJob(frequentTaskNames(event.scheduleTime)); },
);

export const jobsDailyEarly = onSchedule(
  { ...oneAtATime, schedule: 'every day 03:00', timeZone: 'Asia/Singapore', timeoutSeconds: JOB_TIMEOUT_SECONDS.jobsDailyEarly },
  async () => { await runJob(DAILY_EARLY_TASKS); },
);

export const jobsDailyLate = onSchedule(
  { ...oneAtATime, schedule: 'every day 04:00', timeZone: 'Asia/Singapore', timeoutSeconds: JOB_TIMEOUT_SECONDS.jobsDailyLate,
    secrets: purgeInactiveSecrets },
  async () => { await runJob(DAILY_LATE_TASKS); },
);

export type RunnerReply = { status: number; body: Record<string, unknown> };

/** Runs one named task for the manual runner. Only a POST with a known name runs anything. */
export async function handleRunnerRequest(
  method: string,
  task: unknown,
  registry: TaskRegistry = TASKS,
  deps: JobDeps = {},
): Promise<RunnerReply> {
  if (method !== 'POST') return { status: 405, body: { error: 'Use POST', tasks: TASK_NAMES } };
  const name = typeof task === 'string' ? TASK_NAMES.find((candidate) => candidate === task) : undefined;
  if (!name) return { status: 400, body: { error: 'Unknown or missing task. Pass ?task=<name>.', tasks: TASK_NAMES } };
  const log = deps.log ?? ((text, fields) => logger.error(text, fields));
  const started = Date.now();
  try {
    const result = await withBudget(Promise.resolve().then(() => registry[name].run()), registry[name].budgetMs);
    logger.info('Manual scheduled task finished', { task: name, ms: Date.now() - started });
    return { status: 200, body: { task: name, ok: true, ms: Date.now() - started, result: result ?? null } };
  } catch (error) {
    // Not the alert line: a hand run that fails is already in front of the person who started it.
    log(`Manual scheduled task failed: ${name}`, { task: name, error: message(error) });
    return { status: 500, body: { task: name, ok: false, ms: Date.now() - started, error: message(error) } };
  }
}

/**
 * Private: callers need the Cloud Run invoker role, so only people and accounts Aedwon has granted
 * can run it. Runs one task by hand on staging or prod, for example a cleanup before a release that
 * changes it. One request at a time, like the combined jobs.
 */
export const runScheduledTask = onRequest(
  { region, serviceAccount: 'pantas-jobs@', invoker: 'private', maxInstances: 1, concurrency: 1, timeoutSeconds: 600, secrets: purgeInactiveSecrets },
  async (req, res) => {
    const reply = await handleRunnerRequest(req.method, req.query.task);
    res.status(reply.status).json(reply.body);
  },
);
