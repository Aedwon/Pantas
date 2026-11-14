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
 * once is its cap times 80: 240 at the default of 3.
 *
 * Lowered on Nov 14, 2026 (security audit S-08, approved with the billing cap): 10, 30 and 20 let an
 * attacker run up hundreds of dollars a day; 3, 10 and 5 still serve hundreds of requests at once
 * per function, far above beta use. Staging uses the same caps; the audit suggested 2 there, which
 * would need a per-project parameter, and staging also has a $5 Cloud Run spend cap.
 *
 * Import this file before any file that defines a function. `index.ts` does so first.
 */
export const DEFAULT_MAX_INSTANCES = 3;
export const WEBHOOK_MAX_INSTANCES = 10;
export const ACCOUNT_DELETION_MAX_INSTANCES = 5;

setGlobalOptions({maxInstances: DEFAULT_MAX_INSTANCES});
