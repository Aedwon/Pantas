import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const SET_PRO_EVENTS = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'PRODUCT_CHANGE',
  'TRANSFER_INCOMING',
]);

const CLEAR_PRO_EVENTS = new Set([
  'CANCELLATION',
  'EXPIRATION',
  'TRANSFER_OUTGOING',
]);

export interface RevenueCatClaimEvent {
  eventId: string;
  eventType: string;
  uid: string;
}

export async function applyRevenueCatClaimTransition(
  input: RevenueCatClaimEvent,
): Promise<void> {
  const { eventType, uid } = input;

  if (SET_PRO_EVENTS.has(eventType)) {
    await getAuth().setCustomUserClaims(uid, { pro: true });
    return;
  }

  if (CLEAR_PRO_EVENTS.has(eventType)) {
    await getAuth().setCustomUserClaims(uid, { pro: false });
    if (eventType === 'TRANSFER_OUTGOING') {
      await getFirestore().collection('transferLoser').doc(uid).set({
        uid,
        eventId: input.eventId,
        createdAt: new Date().toISOString(),
      });
    }
  }
}
