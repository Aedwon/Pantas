import {setGlobalOptions} from 'firebase-functions/v2';

/**
 * Every function may run on at most this many instances unless it sets its own limit. This caps
 * the bill from a traffic spike or an attack. Aedwon approved the value; it may be tuned.
 *
 * Each function is its own service with its own instances, so a cap on content traffic cannot
 * take instances from the payment webhooks. Those, and account deletion, set a higher explicit
 * limit anyway.
 *
 * At deploy time the pinned firebase-tools gives a 256 MiB function 1 vCPU and a concurrency of
 * 80 (a concurrency above 1 needs at least 1 vCPU). So the most requests one function serves at
 * once is its cap times 80: 800 at the default of 10.
 *
 * Import this file before any file that defines a function. `index.ts` does so first.
 */
export const DEFAULT_MAX_INSTANCES = 10;
export const WEBHOOK_MAX_INSTANCES = 30;
export const ACCOUNT_DELETION_MAX_INSTANCES = 20;

setGlobalOptions({maxInstances: DEFAULT_MAX_INSTANCES});
