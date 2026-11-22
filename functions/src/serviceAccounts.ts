/**
 * Which service account each Cloud Function runs as (security audit S-13). Without one, a function
 * runs as the default compute account, which holds project Editor.
 *
 * The short form `name@` is expanded by the pinned firebase-tools to `name@<project>.iam.gserviceaccount.com`,
 * so the same code works on staging and prod. Every function not listed runs as the default account.
 * `test/service-accounts.test.mjs` fails if an export has the wrong account or a listed name is not an export.
 */
export const DEFAULT_SERVICE_ACCOUNT = 'pantas-app@';

export const SERVICE_ACCOUNTS: Record<string, readonly string[]> = {
  'pantas-entitlements@': ['setBetaPro', 'getBetaReward', 'activateBetaReward', 'getWebEntitlement', 'recomputePassEnds'],
  'pantas-payments@': ['createPaymongoCheckout', 'paymongoWebhook', 'revenuecatWebhook'],
  'pantas-identity@': ['requestSignInCode', 'verifySignInCode', 'exchangeGoogleSignIn', 'startWebTrial', 'listWebPlans',
    'sendGuardianLink', 'answerGuardianRequest', 'getGuardianStatus', 'getGuardianRequest', 'getGuardianManage',
    'setGuardianSharing', 'withdrawGuardianPermission', 'markGuardianAdult', 'deleteAccount'],
  'pantas-jobs@': ['onUserCreated', 'jobsFrequent', 'jobsDailyEarly', 'jobsDailyLate', 'runScheduledTask',
    'cleanupSyncData', 'repairEntitlementClaims', 'checkRecentEntitlementClaims', 'cleanupOrphanAnons',
    'purgeOldAuditLogs', 'cleanupWrappedOrphans', 'purgeOldGuardianRecords', 'purgeInactiveAccounts',
    'keepCallablesWarm'],
};

/** The service account the named function runs as. */
export function serviceAccountFor(name: string): string {
  for (const [account, names] of Object.entries(SERVICE_ACCOUNTS)) {
    if (names.includes(name)) return account;
  }
  return DEFAULT_SERVICE_ACCOUNT;
}
