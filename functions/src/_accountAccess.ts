import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {HttpsError, onCall as firebaseOnCall, type CallableOptions, type CallableRequest} from 'firebase-functions/v2/https';

/** A final refusal, distinct from a missing prerequisite that the app may retry. */
export const accountClosed = () => new HttpsError('permission-denied', 'This account is being deleted.',
  {reason: 'account-closed'});

/** Never cache this decision: an otherwise valid ID token can outlive withdrawal. */
export async function assertAccountActive(db: Firestore, uid: string): Promise<void> {
  const [deletion, consent] = await db.getAll(db.doc(`accountDeletions/${uid}`),
    db.doc(`users/${uid}/server/guardianConsent`));
  if (deletion.exists || consent.get('status') === 'withdrawn') throw accountClosed();
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

/** Shared dispatch boundary. Internal Admin cleanup deliberately does not use it. */
export function accountHandler<T = any, R = unknown>(handler: (request: CallableRequest<T>) => R | Promise<R>) {
  return async (request: CallableRequest<T>): Promise<R> => {
    if (request.auth) await assertAccountActive(getFirestore(), request.auth.uid);
    return handler(request);
  };
}

/** Same callable options and timing handlers; the gate runs before user data or side effects. */
export function onAccountCall<T = any, R = unknown>(options: CallableOptions<T>,
  handler: (request: CallableRequest<T>) => R | Promise<R>) {
  return firebaseOnCall(options, accountHandler(handler));
}
