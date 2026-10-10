import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { getAuth, type Auth } from 'firebase-admin/auth';
import { defineSecret } from 'firebase-functions/params';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { commitRevenueCatAnswer, copyEntitlementClaims, repairClaims } from './revenuecatClaims.js';
import { claimsForRevenueCatAnswer, normalizeRevenueCatEvent, requireExactRevenueCatRawBody,
  verifyRevenueCatSignature, isUnresolvedFirebaseIdentityError, type RevenueCatAccessSource } from './revenuecatPolicy.js';
import { readRevenueCatCustomer } from './revenuecatSubscriber.js';
export { verifyRevenueCatSignature } from './revenuecatPolicy.js';

const apiSecret = defineSecret('REVENUECAT_SECRET_API_KEY');
const signingSecret = defineSecret('REVENUECAT_WEBHOOK_SECRET');
const MAX_EVENTS_PER_MINUTE = 30;

type Dependencies = {db: Firestore; auth: Pick<Auth,'getUser'|'setCustomUserClaims'>;
  appId: string; firebaseProjectId: string; signingSecret: string;
  readCustomer(uid: string): Promise<RevenueCatAccessSource[]>; now?: () => number};

export async function reconcileWebhook(body: unknown, rawBody: unknown, signature: string,
  deps: Dependencies): Promise<number> {
  const now = deps.now ?? Date.now;
  const raw = requireExactRevenueCatRawBody(rawBody);
  if (!raw || !verifyRevenueCatSignature(raw, signature, deps.signingSecret, now())) return 401;
  const event = normalizeRevenueCatEvent(body);
  if (!event) return 400;
  const payload = (body as {event: Record<string, unknown>}).event;
  const promotional = payload.store === 'PROMOTIONAL';
  if (payload.app_id !== deps.appId && !(promotional && payload.app_id == null)) return 200;
  const uids = event.eventType === 'TRANSFER'
    ? [...new Set([...(event.transferredFrom ?? []), ...(event.transferredTo ?? [])])]
    : [event.uid];
  try {
    for (const uid of uids) {
      if (uid.startsWith('$RCAnonymousID:')) continue;
      if (!uid || uid.includes('/') || uid.length > 128) return 400;
      try { await deps.auth.getUser(uid); }
      catch (error) { if (isUnresolvedFirebaseIdentityError(error)) continue; throw error; }
      const record = deps.db.doc(`users/${uid}/server/entitlement`);
      const duplicate = await deps.db.doc(`webhookEvents/${event.eventId}/users/${uid}`).get();
      if (!duplicate.exists) {
        const rate = deps.db.doc(`webhookRateLimits/${uid}_${Math.floor(now() / 60_000)}`);
        const available = await deps.db.runTransaction(async transaction => {
          const snapshot = await transaction.get(rate);
          const count = Number(snapshot.get('count') ?? 0);
          if (count >= MAX_EVENTS_PER_MINUTE) return false;
          transaction.set(rate, {uid, count:count + 1});
          return true;
        });
        if (!available) return 429;
        const testers = await deps.db.doc('config/testers').get();
        const sandboxTester = Array.isArray(testers.get('uids')) && testers.get('uids').includes(uid);
        // V2 has no requestDate. This server time precedes the first REST read.
        const answerAt = now();
        const sources = await deps.readCustomer(uid);
        const claim = claimsForRevenueCatAnswer(sources, {appId:deps.appId,
          firebaseProjectId:deps.firebaseProjectId, sandboxTester, at:answerAt});
        if (sandboxTester && sources.some(s => s.environment === 'sandbox')) {
          console.info('RevenueCat sandbox tester reconciliation', {uid,eventId:event.eventId});
        }
        await commitRevenueCatAnswer(deps.db, uid, event.eventId, answerAt, claim, {
          eventType:event.eventType, appId:payload.app_id ?? null,
          environment:payload.environment ?? null, productId:payload.product_id ?? null,
          entitlementIds:payload.entitlement_ids ?? [], expiry:payload.expiration_at_ms ?? null, sources,
        });
      }
      const current = await record.get();
      if (current.get('claimsVersion') !== current.get('version')) {
        await copyEntitlementClaims(deps.db, deps.auth, uid);
      }
    }
    return 200;
  } catch (error) {
    console.error('RevenueCat reconciliation failed', {eventId:event.eventId,error});
    return 500;
  }
}

export const revenuecatWebhook = onRequest({region:'asia-southeast1', secrets:[apiSecret, signingSecret]}, async (req,res) => {
  const projectId = process.env.REVENUECAT_PROJECT_ID;
  const appId = process.env.REVENUECAT_APP_ID;
  if (!projectId || !appId) {res.status(500).send('RevenueCat configuration required'); return;}
  const status = await reconcileWebhook(req.body, req.rawBody,
    req.header('x-revenuecat-webhook-signature') ?? '', {
      db:getFirestore(),auth:getAuth(),appId,
      firebaseProjectId:process.env.GCLOUD_PROJECT ?? '', signingSecret:signingSecret.value(),
      readCustomer:uid => readRevenueCatCustomer(projectId,uid,apiSecret.value()),
    });
  res.status(status).send(status === 200 ? 'ok' : 'reconciliation failed');
});

export const repairEntitlementClaims = onSchedule({schedule:'every 60 minutes',region:'asia-southeast1'},
  () => repairClaims(getFirestore(), getAuth()));
