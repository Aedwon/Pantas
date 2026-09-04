import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import {
  executeRevenueCatClaimTransition,
  isUnresolvedFirebaseIdentityError,
  type RevenueCatClaimEvent,
} from './revenuecatPolicy.js';

export type { RevenueCatClaimEvent } from './revenuecatPolicy.js';

export async function applyRevenueCatClaimTransition(
  input: RevenueCatClaimEvent,
): Promise<boolean> {
  const auth = getAuth();

  return executeRevenueCatClaimTransition(input, {
    getCustomClaims: async (uid) => {
      try {
        const user = await auth.getUser(uid);
        return user.customClaims ?? {};
      } catch (error) {
        if (input.unresolvedUserIsNoop === true &&
          isUnresolvedFirebaseIdentityError(error)) {
          return null;
        }
        throw error;
      }
    },
    setCustomClaims: async (uid, claims) => {
      await auth.setCustomUserClaims(uid, claims);
    },
    markTransferLoser: async (uid, eventId) => {
      await getFirestore().collection('transferLoser').doc(uid).set({
        uid,
        eventId,
        createdAt: new Date().toISOString(),
      });
    },
  });
}
