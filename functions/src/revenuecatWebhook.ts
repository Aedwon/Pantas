import { createHmac, timingSafeEqual } from 'node:crypto';
import { getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { applyRevenueCatClaimTransition } from './revenuecatClaims.js';

const MAX_EVENTS_PER_MINUTE = 30;

export const revenuecatWebhook = onRequest(
  { region: 'asia-southeast1' },
  async (req, res) => {
    const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
    const authorization = req.header('authorization') ?? '';
    const rawBody = Buffer.isBuffer(req.rawBody)
      ? req.rawBody
      : Buffer.from(JSON.stringify(req.body ?? {}));

    if (!secret || !verifyRevenueCatSignature(rawBody, authorization, secret)) {
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
    await applyRevenueCatClaimTransition(event);
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

export function verifyRevenueCatSignature(
  rawBody: Buffer,
  authorization: string,
  secret: string,
): boolean {
  if (!authorization) return false;
  const expected = createHmac('sha256', secret).update(rawBody).digest('hex');
  const actual = authorization.replace(/^Bearer\s+/i, '').trim();
  const expectedBuffer = Buffer.from(expected);
  const actualBuffer = Buffer.from(actual);
  return (
    expectedBuffer.length === actualBuffer.length &&
    timingSafeEqual(expectedBuffer, actualBuffer)
  );
}

function normalizeRevenueCatEvent(body: unknown) {
  if (body == null || typeof body !== 'object') return null;
  const event = (body as { event?: Record<string, unknown> }).event;
  if (event == null) return null;
  const eventId = String(event.id ?? '');
  const eventType = normalizeEventType(String(event.type ?? ''));
  const uid = String(event.app_user_id ?? event.original_app_user_id ?? '');
  if (!eventId || !eventType || !uid) return null;
  return { eventId, eventType, uid };
}

function normalizeEventType(type: string): string {
  if (type !== 'TRANSFER') return type;
  return 'TRANSFER_INCOMING';
}

function minuteWindow(date: Date): string {
  return date.toISOString().slice(0, 16);
}
