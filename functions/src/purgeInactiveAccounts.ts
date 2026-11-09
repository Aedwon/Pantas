import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';
import {onSchedule} from 'firebase-functions/v2/scheduler';
import {deleteUserData} from './deleteUserData.js';
import {guardianLinkOrigin, guardianMailFrom, guardianMailKey} from './guardianConsent.js';
import {inactivityWarningMessage, mailerFor, type GuardianMailer} from './guardianMail.js';
import {hasLiveProClaim} from './_pro.js';
import {trialIdentityKey} from './webTrial.js';

const DAY_MS = 86_400_000;

// The spec's 24 months, counted as 730 days. Nothing here is shown to a student as a figure.
export const INACTIVE_DAYS = 730;
// The warning goes out 30 days before the deletion: 24 months minus 30 days.
export const WARN_DAYS = 700;
export const WARNING_GRACE_DAYS = 30;
// Per run, so one bad day cannot delete or mail the whole user base.
export const DELETIONS_PER_RUN = 200;
export const WARNINGS_PER_RUN = 500;
// Guardian answer records are kept ten years after the newest answer: 10 x 365 days plus 3 leap
// days (2028, 2032, 2036 fall inside a ten-year span starting in late 2026).
export const EVIDENCE_KEEP_DAYS = 3653;

type InactivityDeps = {
  db: Firestore;
  auth: Pick<Auth, 'listUsers' | 'getUser' | 'deleteUser'>;
  mailer: GuardianMailer;
  /** The app address the warning's "Open Pantas" link points to. */
  linkOrigin: string;
  now?: () => number;
  deletionCap?: number;
  warningCap?: number;
};

export type InactivityResult = {scanned: number; warned: number; deleted: number};

const isMissing = (error: unknown): boolean => (error as {code?: string} | null)?.code === 'auth/user-not-found';

/** The later of the last sign-in and the last token refresh, which happens whenever the app is used. */
function lastActivity(user: UserRecord): number | null {
  const times = [user.metadata.lastSignInTime, user.metadata.lastRefreshTime]
    .map((value) => Date.parse(value ?? '')).filter(Number.isFinite);
  if (times.length > 0) return Math.max(...times);
  const created = Date.parse(user.metadata.creationTime);
  // With no usable date at all, leave the account alone.
  return Number.isFinite(created) ? created : null;
}

/** Pro access that is still running: a live claim, or an active grant or pass the claim may lag behind. */
async function proRunning(db: Firestore, user: UserRecord, now: number): Promise<boolean> {
  if (hasLiveProClaim(user.customClaims as {pro?: unknown; proUntil?: unknown} | undefined, now)) return true;
  for (const collection of ['grants', 'passes']) {
    const rows = await db.collection(`users/${user.uid}/${collection}`).get();
    if (rows.docs.some((row) => row.get('state') === 'active' && Number(row.get('endsAt')) > now)) return true;
  }
  return false;
}

/** Warns and deletes accounts that have not been used for 24 months. */
export async function runInactivityPass(deps: InactivityDeps): Promise<InactivityResult> {
  const now = (deps.now ?? Date.now)();
  const deletionCap = deps.deletionCap ?? DELETIONS_PER_RUN;
  const warningCap = deps.warningCap ?? WARNINGS_PER_RUN;
  const result: InactivityResult = {scanned: 0, warned: 0, deleted: 0};

  // Rechecks the account just before deleting, in case it was used since the page was read.
  const deleteNow = async (uid: string): Promise<boolean> => {
    try {
      const fresh = await deps.auth.getUser(uid);
      const last = lastActivity(fresh);
      if (fresh.disabled || last === null || now - last < INACTIVE_DAYS * DAY_MS) return false;
      await deleteUserData(deps.db, deps.auth, uid, 'inactive_24_months', {now: () => now});
      return true;
    } catch (error) {
      if (!isMissing(error)) logger.error('Inactive account deletion failed', {uid, error: String(error)});
      return false;
    }
  };

  let pageToken: string | undefined;
  do {
    const page = await deps.auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      result.scanned += 1;
      if (result.deleted >= deletionCap && result.warned >= warningCap) break;
      // A disabled account is a guardian withdrawal in progress.
      if (user.disabled) continue;
      const last = lastActivity(user);
      if (last === null || now - last < WARN_DAYS * DAY_MS) continue;
      if (await proRunning(deps.db, user, now)) continue;
      const idleLongEnough = now - last >= INACTIVE_DAYS * DAY_MS;

      if (!user.email) {
        // A guest account has no address to warn, and no one can sign back in to it.
        if (idleLongEnough && result.deleted < deletionCap && await deleteNow(user.uid)) result.deleted += 1;
        continue;
      }
      // Only a verified address is warned. An unverified one is left alone, never deleted unwarned.
      if (!user.emailVerified) continue;

      const record = deps.db.doc(`users/${user.uid}/server/inactivity`);
      const warnedAt = (await record.get()).get('warnedAt');
      // A warning older than the last use does not count: using the app cancels it.
      if (typeof warnedAt === 'number' && warnedAt > last) {
        const due = now >= warnedAt + WARNING_GRACE_DAYS * DAY_MS;
        if (idleLongEnough && due && result.deleted < deletionCap && await deleteNow(user.uid)) result.deleted += 1;
        continue;
      }
      if (result.warned >= warningCap) continue;
      try {
        await deps.mailer.send(inactivityWarningMessage({email: user.email,
          deleteOn: now + WARNING_GRACE_DAYS * DAY_MS, origin: deps.linkOrigin}));
      } catch (error) {
        // Record nothing, so the next run tries again. Not-configured mail lands here too.
        logger.error('Inactivity warning not sent', {uid: user.uid, error: String(error)});
        continue;
      }
      await record.set({warnedAt: now});
      result.warned += 1;
    }
    pageToken = page.pageToken;
  } while (pageToken && (result.deleted < deletionCap || result.warned < warningCap));
  logger.info('purgeInactiveAccounts', result);
  return result;
}

/**
 * Deletes guardian evidence ten years after its newest answer or purchase attestation, once the
 * account is gone. Evidence with no deletion marker predates the marker: if its account no longer
 * exists, the marker is written now so the ten-year clock, which runs from the newest record, applies.
 */
export async function purgeExpiredEvidence(deps: {db: Firestore; auth: Pick<Auth, 'getUser'>; now?: () => number}): Promise<number> {
  const now = (deps.now ?? Date.now)();
  let removed = 0;
  // listDocuments also returns parents that exist only as a parent of a subcollection.
  for (const evidence of await deps.db.collection('guardianConsentEvidence').listDocuments()) {
    try {
      let deletedAt = (await evidence.get()).get('accountDeletedAt');
      if (typeof deletedAt !== 'number') {
        try {
          await deps.auth.getUser(evidence.id);
          continue; // the account still exists
        } catch (error) {
          if (!isMissing(error)) throw error;
        }
        deletedAt = now;
        await evidence.set({accountDeletedAt: now, reason: 'legacy'}, {merge: true});
      }
      const [answers, purchases] = await Promise.all([evidence.collection('responses').get(), evidence.collection('purchases').get()]);
      const dates = [...answers.docs.map((row) => row.get('decidedAt')), ...purchases.docs.map((row) => row.get('attestedAt'))]
        .filter((value): value is number => typeof value === 'number');
      const newest = dates.length > 0 ? Math.max(...dates) : deletedAt;
      if (now >= newest + EVIDENCE_KEEP_DAYS * DAY_MS) {
        await deps.db.recursiveDelete(evidence);
        removed += 1;
      }
    } catch (error) {
      logger.error('Evidence purge failed for one record', {uid: evidence.id, error: String(error)});
    }
  }
  return removed;
}

/** The whole daily run: inactive accounts first, then expired evidence. */
export async function runDailyPass(deps: InactivityDeps): Promise<void> {
  await runInactivityPass(deps);
  await purgeExpiredEvidence(deps);
}

export const purgeInactiveAccounts = onSchedule(
  {schedule: 'every day 04:00', timeZone: 'Asia/Singapore', region: 'asia-southeast1', timeoutSeconds: 540,
    secrets: [guardianMailKey, trialIdentityKey]},
  async () => runDailyPass({
    db: getFirestore(),
    auth: getAuth(),
    // Built on first send, so a missing mail setting fails the warning and nothing else.
    mailer: {send: (message) => mailerFor(process.env,
      {apiKey: () => guardianMailKey.value(), from: () => guardianMailFrom.value()}).send(message)},
    linkOrigin: process.env.FUNCTIONS_EMULATOR === 'true'
      ? (process.env.GUARDIAN_LINK_ORIGIN || 'http://localhost:7357') : guardianLinkOrigin.value(),
  }),
);
