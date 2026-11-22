/**
 * Which service account each Cloud Function runs as (security audit S-13). Without one, a function
 * runs as the default compute account, which holds project Editor.
 *
 * Each account is written out in full from the project id firebase-tools sets during discovery
 * (GCLOUD_PROJECT), so the same code works on staging and prod. The short form `name@` is not used: the
 * pinned firebase-tools expands it when it deploys, but not when it grants secret access (a 400 on the
 * Nov 22 staging deploy). Every function not listed runs as the default account.
 * `test/service-accounts.test.mjs` fails if an export has the wrong account or a listed name is not an export.
 */
/** `name@<project>.iam.gserviceaccount.com` for the project being deployed; `name@` when none is set. */
export function serviceAccountEmail(name: string): string {
  const project = process.env.GCLOUD_PROJECT;
  return project ? `${name}@${project}.iam.gserviceaccount.com` : `${name}@`;
}

export const DEFAULT_SERVICE_ACCOUNT = serviceAccountEmail('pantas-app');

export const SERVICE_ACCOUNTS: Record<string, readonly string[]> = {
  'pantas-entitlements': ['setBetaPro', 'getBetaReward', 'activateBetaReward', 'getWebEntitlement', 'recomputePassEnds'],
  'pantas-payments': ['createPaymongoCheckout', 'paymongoWebhook', 'revenuecatWebhook'],
  'pantas-identity': ['requestSignInCode', 'verifySignInCode', 'exchangeGoogleSignIn', 'startWebTrial', 'listWebPlans',
    'sendGuardianLink', 'answerGuardianRequest', 'getGuardianStatus', 'getGuardianRequest', 'getGuardianManage',
    'setGuardianSharing', 'withdrawGuardianPermission', 'markGuardianAdult', 'deleteAccount'],
  'pantas-jobs': ['onUserCreated', 'jobsFrequent', 'jobsDailyEarly', 'jobsDailyLate', 'runScheduledTask',
    'cleanupSyncData', 'repairEntitlementClaims', 'checkRecentEntitlementClaims', 'cleanupOrphanAnons',
    'purgeOldAuditLogs', 'cleanupWrappedOrphans', 'purgeOldGuardianRecords', 'purgeInactiveAccounts',
    'keepCallablesWarm'],
};

/** The service account the named function runs as. */
export function serviceAccountFor(name: string): string {
  for (const [account, names] of Object.entries(SERVICE_ACCOUNTS)) {
    if (names.includes(name)) return serviceAccountEmail(account);
  }
  return DEFAULT_SERVICE_ACCOUNT;
}
