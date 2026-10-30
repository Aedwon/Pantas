import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';

/**
 * Replay protection for payment, trial, deletion and admin callables.
 *
 * `consumeAppCheckToken: true` makes the platform mark the token as used, but
 * it does not reject a token that was used before. It only reports that in
 * `request.app.alreadyConsumed`. Without this check, consuming does nothing.
 * Clients must send a limited-use token (`limitedUseAppCheckToken`) for these
 * callables, so every call carries a fresh one.
 */
export function assertFreshAppCheck(request: Pick<CallableRequest, 'app'>): void {
  if (request.app?.alreadyConsumed === true) {
    throw new HttpsError('unauthenticated', 'Unauthenticated');
  }
}
