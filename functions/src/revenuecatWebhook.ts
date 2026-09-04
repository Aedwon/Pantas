import { getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { applyRevenueCatClaimTransition } from './revenuecatClaims.js';
import {
  firebaseTransferTransitions,
  normalizeRevenueCatEvent,
  requireExactRevenueCatRawBody,
  verifyRevenueCatSignature,
} from './revenuecatPolicy.js';

export { verifyRevenueCatSignature } from './revenuecatPolicy.js';

const MAX_EVENTS_PER_MINUTE = 30;

export const revenuecatWebhook = onRequest(
  { region: 'asia-southeast1' },
  async (req, res) => {
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
    const signatureHeader =
      req.header('x-revenuecat-webhook-signature') ?? '';
    const rawBody = requireExactRevenueCatRawBody(req.rawBody);

    if (
      !secret ||
      rawBody == null ||
      !verifyRevenueCatSignature(rawBody, signatureHeader, secret)
    ) {
      res.status(401).send('unauthorized');
      return;
    }

    const event = normalizeRevenueCatEvent(req.body);
    if (event == null) {
      res.status(400).send('invalid event');
      return;
    }

    const db = getFirestore();
    const eventRef = db.collection('webhookEvents').doc(event.eventId);
    const existing = await eventRef.get();
    if (existing.exists) {
      res.status(200).send('duplicate');
      return;
    }

    const rateRef = db
      .collection('webhookRateLimits')
      .doc(`${event.uid}_${minuteWindow(new Date())}`);
    const rateSnapshot = await rateRef.get();
    const count = Number(rateSnapshot.get('count') ?? 0);
    if (count >= MAX_EVENTS_PER_MINUTE) {
      res.status(429).send('rate limited');
      return;
    }

    await rateRef.set({ uid: event.uid, count: count + 1 }, { merge: true });

    if (event.eventType === 'TRANSFER') {
      for (const transition of firebaseTransferTransitions(event)) {
        await applyRevenueCatClaimTransition(transition);
      }
    } else {
      await applyRevenueCatClaimTransition(event);
    }

    await eventRef.set({
      uid: event.uid,
      eventType: event.eventType,
      processedAt: new Date().toISOString(),
    });
    await db.collection('webhookLog').doc(event.eventId).set({
      uid: event.uid,
      eventType: event.eventType,
      processedAt: new Date().toISOString(),
    });

    res.status(200).send('ok');
  },
);

function minuteWindow(date: Date): string {
  return date.toISOString().slice(0, 16);
}
