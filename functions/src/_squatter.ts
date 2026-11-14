import type {Auth, UserRecord} from 'firebase-admin/auth';
import type {Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions/logger';
import {deleteUserData} from './deleteUserData.js';

export type SquatterAuth = Pick<Auth, 'getUser' | 'deleteUser' | 'revokeRefreshTokens'>;

const authCode = (error: unknown): string | undefined => (error as {code?: string} | null)?.code;

/**
 * An account made with an address nobody proved: Identity Toolkit lets anyone register any address
 * with a password, and the address stays unverified. Only such an account may be replaced: unverified,
 * not disabled, and holding no sign-in method but a password. An account with Google, phone or any
 * other provider, or one that is verified or disabled, belongs to someone and is never touched.
 */
export function isSquatter(user: UserRecord): boolean {
  const providers = user.providerData ?? [];
  return !user.emailVerified && !user.disabled && providers.every(provider => provider.providerId === 'password');
}

/**
 * Removes a squatter after the caller has proved they own the address (a correct email code, or a
 * verified Google ID token). The password session is cut first, then the account and its server
 * data go through the same deletion that account deletion uses. Returns false when the account was
 * already gone or has changed so that it is no longer a squatter, so the caller looks it up again.
 * A second sign-in doing the same thing at the same time is harmless: a missing account is not an error.
 */
export async function replaceSquatter(
  db: Firestore,
  auth: SquatterAuth,
  user: UserRecord,
  purge: (uid: string) => Promise<void> = uid => deleteUserData(db, auth, uid, 'unclaimed_address'),
): Promise<boolean> {
  // Read the account again: it may have been replaced, or given a provider, since the lookup.
  let fresh: UserRecord;
  try {
    fresh = await auth.getUser(user.uid);
  } catch (error) {
    if (authCode(error) === 'auth/user-not-found') return false;
    throw error;
  }
  if (!isSquatter(fresh)) return false;
  try {
    await auth.revokeRefreshTokens(fresh.uid);
  } catch (error) {
    if (authCode(error) !== 'auth/user-not-found') throw error;
  }
  try {
    await purge(fresh.uid);
  } catch (error) {
    if (authCode(error) !== 'auth/user-not-found') throw error;
  }
  logger.info('Replaced an unclaimed account', {uid: fresh.uid});
  return true;
}
