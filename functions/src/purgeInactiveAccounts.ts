import {getAuth, type Auth, type UserRecord} from 'firebase-admin/auth';
import {FieldPath, FieldValue, getFirestore, type DocumentReference, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';
import {onSchedule} from 'firebase-functions/v2/scheduler';
import {DELETION_RETRY_MS, deleteUserData, type DeletionReason} from './deleteUserData.js';
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
// A pending deletion is retried by the daily run an hour after its last attempt, so a live attempt is
// left alone. At most this many retries run per day, so failing tasks cannot use up the whole cap.
export const RETRY_AFTER_MS = DELETION_RETRY_MS;
export const RETRIES_PER_RUN = 50;
// Evidence parents checked per run, in each of the two passes (marked parents, legacy parents).
export const EVIDENCE_PARENTS_PER_RUN = 500;

type InactivityDeps = {
  db: Firestore;
  auth: Pick<Auth, 'listUsers' | 'getUser' | 'deleteUser' | 'updateUser' | 'revokeRefreshTokens'>;
  mailer: GuardianMailer;
  /** The app address the warning's "Open Pantas" link points to. */
  linkOrigin: string;
  now?: () => number;
  deletionCap?: number;
  /** Stalled deletions retried per run. */
  retryCap?: number;
  warningCap?: number;
  /** Evidence parents checked per run. */
  evidenceBudget?: number;
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
  // Deletions started, not finished: a failed deletion may already have erased data, so it counts.
  let attempts = 0;

  /** Still unused for 730 days, with no Pro running, on a fresh read of the account. */
  const stillIdleAndUnpaid = async (user: UserRecord): Promise<boolean> => {
    const last = lastActivity(user);
    return last !== null && now - last >= INACTIVE_DAYS * DAY_MS && !await proRunning(deps.db, user, now);
  };

  // Rechecks the account just before deleting, in case it was used or paid since the page was read.
  // `warnedAt` is the warning the scan relied on, or null for an account that is deleted without one.
  const deleteNow = async (uid: string, warnedAt: number | null): Promise<boolean> => {
    let disabledHere = false;
    try {
      const fresh = await deps.auth.getUser(uid);
      const last = lastActivity(fresh);
      if (fresh.disabled || last === null || !await stillIdleAndUnpaid(fresh)) return false;
      if (warnedAt === null) {
        // An account that gained a verified address since the page was read is owed a warning first.
        if (fresh.email && fresh.emailVerified) return false;
      } else if (!(last < warnedAt && now >= warnedAt + WARNING_GRACE_DAYS * DAY_MS)) {
        return false;
      }
      attempts += 1;
      // Stop new sign-ins and token refreshes, then look once more: a use or a payment that landed
      // between the first read and the disable must still save the account.
      await deps.auth.updateUser(uid, {disabled: true});
      disabledHere = true;
      await deps.auth.revokeRefreshTokens(uid);
      if (!await stillIdleAndUnpaid(await deps.auth.getUser(uid))) {
        await deps.auth.updateUser(uid, {disabled: false});
        return false;
      }
      await deleteUserData(deps.db, deps.auth, uid, 'inactive_24_months', {now: () => now});
      return true;
    } catch (error) {
      if (!isMissing(error)) logger.error('Inactive account deletion failed', {uid, error: String(error)});
      // Disabled by this run but no deletion record to finish it: give the account back, or it would
      // stay locked forever, since the scan skips disabled accounts.
      if (disabledHere) {
        try {
          if (!(await deps.db.doc(`accountDeletions/${uid}`).get()).exists) {
            await deps.auth.updateUser(uid, {disabled: false});
          }
        } catch (restoreError) {
          logger.error('Could not re-enable an account after a failed deletion', {uid, error: String(restoreError)});
        }
      }
      return false;
    }
  };

  // First finish deletions an earlier run or a guardian withdrawal started and did not complete.
  try {
    const retryCap = Math.min(deletionCap, deps.retryCap ?? RETRIES_PER_RUN);
    const unfinished = retryCap > 0
      ? await deps.db.collection('accountDeletions').where('nextRetryAt', '<=', now)
        .orderBy('nextRetryAt').limit(retryCap).get()
      : {docs: []};
    for (const task of unfinished.docs) {
      if (attempts >= deletionCap) break;
      const reason = task.get('reason') as DeletionReason;
      try {
        // An inactivity deletion that stalled before any data was removed is dropped if the account
        // now has paid access, and the account is given back. A withdrawal or the user's own request
        // is always finished, and so is any deletion that already removed data.
        const reasons = (task.get('reasons') as DeletionReason[] | undefined) ?? [reason];
        const onlyInactivity = reasons.every((r) => r === 'inactive_24_months');
        if (onlyInactivity && task.get('destructiveAt') === undefined) {
          const current = await deps.auth.getUser(task.id).catch((error: unknown) => {
            if (isMissing(error)) return null;
            throw error;
          });
          if (current && await proRunning(deps.db, current, now)) {
            // A withdrawal or the user's own request may have joined this task since the query ran.
            // Read it again, so a deletion that gained a reason is never called off.
            const fresh = await task.ref.get();
            const freshReasons = (fresh.get('reasons') as DeletionReason[] | undefined) ?? [reason];
            if (fresh.exists && freshReasons.every((r) => r === 'inactive_24_months') && fresh.get('destructiveAt') === undefined) {
              await deps.auth.updateUser(task.id, {disabled: false});
              await task.ref.delete();
              continue;
            }
          }
        }
        // A deletion that earlier failed before the sign-out step must not leave the account usable
        // while its data goes: disable and sign out again. A step that fails here ends this attempt.
        try {
          await deps.auth.updateUser(task.id, {disabled: true});
          await deps.auth.revokeRefreshTokens(task.id);
        } catch (error) {
          if (!isMissing(error)) throw error;
        }
        attempts += 1;
        await deleteUserData(deps.db, deps.auth, task.id, reason, {now: () => now});
        result.deleted += 1;
      } catch (error) {
        logger.error('Pending account deletion failed', {uid: task.id, error: String(error)});
      }
    }
  } catch (error) {
    logger.error('Pending account deletions not read', {error: String(error)});
  }

  const handle = async (user: UserRecord): Promise<void> => {
    // A disabled account is a guardian withdrawal in progress.
    if (user.disabled) return;
    const last = lastActivity(user);
    if (last === null || now - last < WARN_DAYS * DAY_MS) return;
    if (await proRunning(deps.db, user, now)) return;
    const idleLongEnough = now - last >= INACTIVE_DAYS * DAY_MS;

    if (!user.email || !user.emailVerified) {
      // No address to warn: a guest, or an address Google never verified (a Google sign-in can
      // leave one). Mailing an unverified address could reach someone else, so these accounts
      // end at 24 months without a warning, as the privacy texts say.
      if (idleLongEnough && attempts < deletionCap && await deleteNow(user.uid, null)) result.deleted += 1;
      return;
    }

    const record = deps.db.doc(`users/${user.uid}/server/inactivity`);
    const warnedAt = (await record.get()).get('warnedAt');
    // A warning older than the last use does not count: using the app cancels it.
    if (typeof warnedAt === 'number' && warnedAt > last) {
      const due = now >= warnedAt + WARNING_GRACE_DAYS * DAY_MS;
      if (idleLongEnough && due && attempts < deletionCap && await deleteNow(user.uid, warnedAt)) result.deleted += 1;
      return;
    }
    if (result.warned >= warningCap) return;
    try {
      await deps.mailer.send(inactivityWarningMessage({email: user.email,
        deleteOn: now + WARNING_GRACE_DAYS * DAY_MS, origin: deps.linkOrigin}));
    } catch (error) {
      // Record nothing, so the next run tries again. Not-configured mail lands here too.
      logger.error('Inactivity warning not sent', {uid: user.uid, error: String(error)});
      return;
    }
    await record.set({warnedAt: now});
    result.warned += 1;
  };

  let pageToken: string | undefined;
  do {
    const page = await deps.auth.listUsers(1000, pageToken);
    for (const user of page.users) {
      result.scanned += 1;
      if (attempts >= deletionCap && result.warned >= warningCap) break;
      // One account's failure must not stop the others.
      try {
        await handle(user);
      } catch (error) {
        logger.error('Inactivity check failed for one account', {uid: user.uid, error: String(error)});
      }
    }
    pageToken = page.pageToken;
  } while (pageToken && (attempts < deletionCap || result.warned < warningCap));
  logger.info('purgeInactiveAccounts', result);
  return result;
}

type EvidenceDeps = {db: Firestore; auth: Pick<Auth, 'getUser'>; now?: () => number; budget?: number};

/**
 * Deletes guardian evidence ten years after its newest answer or purchase attestation, once the
 * account is gone. Evidence with no deletion marker predates the marker: if its account no longer
 * exists, the marker is written now so the ten-year clock, which runs from the newest record, applies.
 *
 * Each run checks at most `budget` marked parents, then at most `budget` answer records to find
 * parents with no marker. A saved cursor resumes where the last run stopped and wraps to the start
 * when a page comes back short.
 */
export async function purgeExpiredEvidence(deps: EvidenceDeps): Promise<number> {
  const now = (deps.now ?? Date.now)();
  const budget = deps.budget ?? EVIDENCE_PARENTS_PER_RUN;
  const state = deps.db.doc('jobState/evidencePurge');
  const saved = (await state.get()).data() ?? {};
  let removed = 0;

  const purgeParent = async (evidence: DocumentReference): Promise<void> => {
    try {
      // Only an account that is really gone releases its evidence. A failed deletion can leave the
      // marker on an account that still exists.
      try {
        await deps.auth.getUser(evidence.id);
        return;
      } catch (error) {
        if (!isMissing(error)) throw error;
      }
      let deletedAt = (await evidence.get()).get('accountDeletedAt');
      if (typeof deletedAt !== 'number') {
        deletedAt = now;
        await evidence.set({accountDeletedAt: now, reason: 'legacy'}, {merge: true});
      }
      const [answers, purchases] = await Promise.all([
        evidence.collection('responses').orderBy('decidedAt', 'desc').limit(1).get(),
        evidence.collection('purchases').orderBy('attestedAt', 'desc').limit(1).get()]);
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
  };

  // Pass one: parents that exist as documents (every one written since the marker was introduced).
  const parents = deps.db.collection('guardianConsentEvidence').orderBy(FieldPath.documentId());
  const page = await (typeof saved.cursor === 'string' ? parents.startAfter(saved.cursor) : parents).limit(budget).get();
  for (const parent of page.docs) await purgeParent(parent.ref);
  const cursor = page.size >= budget ? page.docs[page.size - 1].id : FieldValue.delete();
  await state.set({cursor}, {merge: true});

  // Pass two: parents that exist only as the parent of an answer record, found through the answers.
  const answers = deps.db.collectionGroup('responses').orderBy(FieldPath.documentId());
  const answerPage = await (typeof saved.legacyCursor === 'string' ? answers.startAfter(deps.db.doc(saved.legacyCursor)) : answers)
    .limit(budget).get();
  const seen = new Set<string>();
  for (const answer of answerPage.docs) {
    const parent = answer.ref.parent.parent;
    if (!parent || parent.parent.id !== 'guardianConsentEvidence' || seen.has(parent.id)) continue;
    seen.add(parent.id);
    try {
      // A marked parent belongs to pass one.
      if (typeof (await parent.get()).get('accountDeletedAt') === 'number') continue;
    } catch (error) {
      logger.error('Evidence purge failed for one record', {uid: parent.id, error: String(error)});
      continue;
    }
    await purgeParent(parent);
  }
  const legacyCursor = answerPage.size >= budget ? answerPage.docs[answerPage.size - 1].ref.path : FieldValue.delete();
  await state.set({legacyCursor}, {merge: true});
  return removed;
}

/** The whole daily run: inactive accounts first, then expired evidence. Neither can stop the other. */
export async function runDailyPass(deps: InactivityDeps): Promise<void> {
  try {
    await runInactivityPass(deps);
  } catch (error) {
    logger.error('Inactivity pass failed', {error: String(error)});
  }
  try {
    await purgeExpiredEvidence({db: deps.db, auth: deps.auth, now: deps.now,
      ...(deps.evidenceBudget === undefined ? {} : {budget: deps.evidenceBudget})});
  } catch (error) {
    logger.error('Evidence purge failed', {error: String(error)});
  }
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
