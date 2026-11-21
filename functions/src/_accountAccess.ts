import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {isRestrictedAgeGroup} from './ageGroup.js';
import {HttpsError, onCall as firebaseOnCall, type CallableOptions, type CallableRequest} from 'firebase-functions/v2/https';

/** A final refusal, distinct from a missing prerequisite that the app may retry. */
export const accountClosed = () => new HttpsError('permission-denied', 'This account is being deleted.',
  {reason: 'account-closed'});

/** Never cache this decision: an otherwise valid ID token can outlive withdrawal. */
export async function assertAccountActive(db: Firestore, uid: string) {
  const [deletion, consent] = await db.getAll(db.doc(`accountDeletions/${uid}`),
    db.doc(`users/${uid}/server/guardianConsent`));
  if (deletion.exists || consent.get('status') === 'withdrawn') throw accountClosed();
  return consent;
}

/** Refuse a closed sign-in target without closing a different caller's local session. */
export async function assertSignInTargetActive(db: Firestore, targetUid: string, callerUid: string): Promise<void> {
  try {
    await assertAccountActive(db, targetUid);
  } catch (error) {
    if (error instanceof HttpsError && (error.details as {reason?: string} | undefined)?.reason === 'account-closed' && targetUid !== callerUid) {
      throw new HttpsError('permission-denied', 'This account cannot sign in.');
    }
    throw error;
  }
}

export const PSHS_NCE_EXAM = 'exam_pshs_nce';

/** Shared dispatch boundary. Internal Admin cleanup deliberately does not use it. */
export function accountHandler<T = any, R = unknown>(handler: (request: CallableRequest<T>) => R | Promise<R>,
  {study = false, reporting = false, examScoped = false} = {}) {
  return async (request: CallableRequest<T>): Promise<R> => {
    if (request.auth) {
      const db = getFirestore();
      const {uid, token} = request.auth;
      const consent = await assertAccountActive(db, uid);
      // Adult accounts that never used the guardian flow have no age record.
      if (reporting && ((consent.exists && isRestrictedAgeGroup(consent.get('ageGroup'))) ||
          ('ageGroup' in token && isRestrictedAgeGroup(token.ageGroup)) || 'holder' in token)) {
        throw new HttpsError('permission-denied', 'Reporting is unavailable for this account.');
      }
      if (examScoped && (consent.get('ageGroup') === 'child' || consent.get('method') === 'guardian_held' ||
          token.ageGroup === 'child' || 'holder' in token) && (request.data as {examId?: unknown} | null | undefined)?.examId !== PSHS_NCE_EXAM) {
        throw new HttpsError('permission-denied', 'This account can study only for PSHS-NCE.',
          {reason: 'child-exam-restricted'});
      }
      if (study && (await db.doc(`users/${uid}/server/holder`).get()).exists) {
        throw new HttpsError('permission-denied', 'Open your child’s account to study.',
          {reason: 'holder-cannot-study'});
      }
    }
    return handler(request);
  };
}

/** Same callable options and timing handlers; the gate runs before user data or side effects. */
export function onAccountCall<T = any, R = unknown>(options: CallableOptions<T>,
  handler: (request: CallableRequest<T>) => R | Promise<R>) {
  return firebaseOnCall(options, accountHandler(handler));
}

/** Study endpoints share the account gate and refuse holder sign-ins. */
export function onStudyAccountCall<T = any, R = unknown>(options: CallableOptions<T>,
  handler: (request: CallableRequest<T>) => R | Promise<R>) {
  return firebaseOnCall(options, accountHandler(handler, {study: true}));
}

/** Study endpoints whose request selects a particular exam. */
export function onExamStudyAccountCall<T = any, R = unknown>(options: CallableOptions<T>,
  handler: (request: CallableRequest<T>) => R | Promise<R>) {
  return firebaseOnCall(options, accountHandler(handler, {study: true, examScoped: true}));
}

/** Reporting checks the server consent record before accepting any payload. */
export function onReportingAccountCall<T = any, R = unknown>(options: CallableOptions<T>,
  handler: (request: CallableRequest<T>) => R | Promise<R>, study = false) {
  return firebaseOnCall(options, accountHandler(handler, {study, reporting: true}));
}
