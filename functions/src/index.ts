import './_options.js';
import './_admin.js';
import { scheduledJobsOn, legacySchedulesOn } from './scheduleGate.js';
import { cleanupSyncData as legacy_cleanupSyncData } from './cleanupSyncData.js';
import { repairEntitlementClaims as legacy_repairEntitlementClaims } from './revenuecatWebhook.js';
import { checkRecentEntitlementClaims as legacy_checkRecentEntitlementClaims } from './revenuecatWebhook.js';
import { cleanupOrphanAnons as legacy_cleanupOrphanAnons } from './cleanupOrphanAnons.js';
import { purgeOldAuditLogs as legacy_purgeOldAuditLogs } from './purgeOldAuditLogs.js';
import { cleanupWrappedOrphans as legacy_cleanupWrappedOrphans } from './cleanupWrappedOrphans.js';
import { purgeOldGuardianRecords as legacy_purgeOldGuardianRecords } from './guardianConsent.js';
import { purgeInactiveAccounts as legacy_purgeInactiveAccounts } from './purgeInactiveAccounts.js';
import { keepCallablesWarm as legacy_keepCallablesWarm } from './keepWarm.js';
import * as combined from './scheduledJobs.js';

export { exportData } from './exportData.js';
export { deleteAccount } from './deleteAccount.js';
export { renderWrappedPage } from './renderWrappedPage.js';
export { activateSyncGeneration } from './activateSyncGeneration.js';
export { revenuecatWebhook } from './revenuecatWebhook.js';
export { recomputePassEnds } from './revenuecatPasses.js';
export { recordSignInEvent } from './recordSignInEvent.js';
export { onUserCreated } from './onUserCreated.js';
export { createPaymongoCheckout } from './paymongoCheckout.js';
export { paymongoWebhook } from './paymongoWebhook.js';
export { startWebTrial } from './webTrial.js';
export { getContent } from './content.js';
export { startMock } from './mock.js';
export { submitMock } from './mock.js';
export { getMockPaper } from './mock.js';
export { controlMock } from './mock.js';
export { ingestSession } from './ingestSession.js';
export { setExamSettings } from './roadmap.js';
export { getRoadmap } from './roadmap.js';
export {getMockAvailability, getMockResults, getMockHistory, updateMockReview} from './mockReader.js';

export {recordLessonRead} from './studyObservations.js';

export {advanceRoadmap,getRoadmapDay,getRoadmapWeek} from './roadmap.js';

export {getStudyInsights} from './studyInsights.js';
export {getCarryableCount} from './carryableCount.js';
export { listWebPlans } from './webPlans.js';
export {getWebEntitlement} from './webEntitlement.js';
export {reportClientTelemetry} from './clientTelemetry.js';
export {reportUsageVisit} from './usageVisit.js';
export {getSessionDiagnosis} from './sessionDiagnosis.js';

export {getCustomTracks, deleteCustomTrack} from './customTracks.js';

export {setBetaPro} from './betaPro.js';

export {sendGuardianLink, answerGuardianRequest, getGuardianStatus, getGuardianRequest,
  getGuardianManage, setGuardianSharing, withdrawGuardianPermission, markGuardianAdult} from './guardianConsent.js';
export {recordSetupAcceptance} from './setupAcceptance.js';

export {getBetaAccess} from './betaAccess.js';

export {requestSignInCode, verifySignInCode} from './signInCode.js';
export {requestGuardianCode, verifyGuardianCode} from './guardianCodeGate.js';
export {listChildren, openChildSession, setChildNickname, setupChildAccount} from './childSetup.js';
export {exchangeGoogleSignIn} from './googleSignIn.js';


export {activateBetaReward, sendBetaFeedback, recordBetaDay, submitBetaSurvey, getBetaReward} from './betaReward.js';

// Scheduled jobs. Cloud Scheduler bills per job, so prod runs three combined jobs and staging runs
// none. An export that is undefined is skipped by firebase-functions' loader (scheduled-gating
// test), so a switch off means the function is not deployed, and a deploy removes it.
// SCHEDULED_JOBS=off: no schedule at all, old or new (staging).
// LEGACY_SCHEDULES=off: only the three combined jobs (after they have run every task on prod).
export const jobsFrequent = scheduledJobsOn ? combined.jobsFrequent : undefined;
export const jobsDailyEarly = scheduledJobsOn ? combined.jobsDailyEarly : undefined;
export const jobsDailyLate = scheduledJobsOn ? combined.jobsDailyLate : undefined;
// The manual runner is deployed whatever the switches say, on staging and prod.
export const runScheduledTask = combined.runScheduledTask;

export const cleanupSyncData = scheduledJobsOn && legacySchedulesOn ? legacy_cleanupSyncData : undefined;
export const repairEntitlementClaims = scheduledJobsOn && legacySchedulesOn ? legacy_repairEntitlementClaims : undefined;
export const checkRecentEntitlementClaims = scheduledJobsOn && legacySchedulesOn ? legacy_checkRecentEntitlementClaims : undefined;
export const cleanupOrphanAnons = scheduledJobsOn && legacySchedulesOn ? legacy_cleanupOrphanAnons : undefined;
export const purgeOldAuditLogs = scheduledJobsOn && legacySchedulesOn ? legacy_purgeOldAuditLogs : undefined;
export const cleanupWrappedOrphans = scheduledJobsOn && legacySchedulesOn ? legacy_cleanupWrappedOrphans : undefined;
export const purgeOldGuardianRecords = scheduledJobsOn && legacySchedulesOn ? legacy_purgeOldGuardianRecords : undefined;
export const purgeInactiveAccounts = scheduledJobsOn && legacySchedulesOn ? legacy_purgeInactiveAccounts : undefined;
export const keepCallablesWarm = scheduledJobsOn && legacySchedulesOn ? legacy_keepCallablesWarm : undefined;
