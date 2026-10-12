import { createHmac, timingSafeEqual } from 'node:crypto';
import {coverageAt, type CoveragePeriod, type LedgerPass} from './revenuecatCoverage.js';
export {coverageAt} from './revenuecatCoverage.js';

const HMAC_SHA256_HEX = /^[0-9a-f]{64}$/i;
const UNIX_TIMESTAMP = /^\d+$/;
const REVENUECAT_ANONYMOUS_PREFIX = '$RCAnonymousID:';

export function requireExactRevenueCatRawBody(rawBody: unknown): Buffer | null {
  return Buffer.isBuffer(rawBody) ? rawBody : null;
}

export function isUnresolvedFirebaseIdentityError(error: unknown): boolean {
  if (error == null || typeof error !== 'object' || !('code' in error)) {
    return false;
  }
  const code = (error as { code?: unknown }).code;
  return code === 'auth/user-not-found' || code === 'auth/invalid-uid';
}

export interface NormalizedRevenueCatEvent {
  eventId: string;
  eventType: string;
  uid: string;
  transferredFrom?: string[];
  transferredTo?: string[];
}

export function verifyRevenueCatSignature(
  rawBody: Buffer,
  signatureHeader: string,
  secret: string,
  now = Date.now(),
): boolean {
  if (!signatureHeader || !secret) return false;

  let timestamp: string | null = null;
  const signatures: string[] = [];

  for (const rawPart of signatureHeader.split(',')) {
    const part = rawPart.trim();
    const separator = part.indexOf('=');
    if (separator <= 0 || separator === part.length - 1) return false;

    const key = part.slice(0, separator);
    const value = part.slice(separator + 1);
    if (key === 't') {
      if (timestamp != null || !UNIX_TIMESTAMP.test(value)) return false;
      timestamp = value;
      continue;
    }
    if (key === 'v1') {
      if (!HMAC_SHA256_HEX.test(value)) return false;
      signatures.push(value.toLowerCase());
      continue;
    }
    return false;
  }

  if (timestamp == null || signatures.length === 0) return false;
  const signedAt = Number(timestamp) * 1000;
  if (!Number.isSafeInteger(signedAt) || Math.abs(now - signedAt) > 300_000) return false;

  const expected = createHmac('sha256', secret)
    .update(Buffer.from(`${timestamp}.`))
    .update(rawBody)
    .digest();

  return signatures.some((signature) => {
    const actual = Buffer.from(signature, 'hex');
    return actual.length === expected.length && timingSafeEqual(expected, actual);
  });
}

export function normalizeRevenueCatEvent(
  body: unknown,
): NormalizedRevenueCatEvent | null {
  if (body == null || typeof body !== 'object') return null;
  const event = (body as { event?: Record<string, unknown> }).event;
  if (event == null) return null;

  const eventId = stringField(event.id);
  const eventType = stringField(event.type);
  if (eventId == null || eventType == null) return null;

  if (eventType === 'TRANSFER') {
    const transferredFrom = uniqueStringArray(event.transferred_from);
    const transferredTo = uniqueStringArray(event.transferred_to);
    if (transferredFrom == null || transferredTo == null) return null;

    const allIds = [...transferredTo, ...transferredFrom];
    const uid =
      allIds.find((candidate) => !isRevenueCatAnonymousId(candidate)) ??
      allIds[0];
    if (uid == null) return null;

    return {
      eventId,
      eventType,
      uid,
      transferredFrom,
      transferredTo,
    };
  }

  const uid =
    stringField(event.app_user_id) ?? stringField(event.original_app_user_id);
  if (uid == null) return null;
  return { eventId, eventType, uid };
}

export function isRevenueCatAnonymousId(uid: string): boolean {
  return uid.startsWith(REVENUECAT_ANONYMOUS_PREFIX);
}

function stringField(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function uniqueStringArray(value: unknown): string[] | null {
  if (!Array.isArray(value)) return null;
  const result: string[] = [];
  const seen = new Set<string>();
  for (const entry of value) {
    const normalized = stringField(entry);
    if (normalized == null) continue;
    if (seen.has(normalized)) continue;
    seen.add(normalized);
    result.push(normalized);
  }
  return result;
}

export interface RevenueCatAccessSource {
  productId: string | null;
  entitlementIds: string[];
  appId: string | null;
  environment: string;
  store?: string;
  endsAt: number;
  active: boolean;
}

export function claimsForRevenueCatAnswer(sources: RevenueCatAccessSource[], options: {
  appId: string; firebaseProjectId: string; sandboxTester: boolean; at: number;
  passes?: readonly LedgerPass[];
}): {pro: boolean; proUntil: number} {
  const subscriptions: CoveragePeriod[] = [];
  const promotions: CoveragePeriod[] = [];
  for (const source of sources) {
    if (!source.active || !Number.isFinite(source.endsAt) || source.endsAt <= options.at) continue;
    if (source.environment !== 'production' && !(source.environment === 'sandbox' &&
        (options.firebaseProjectId === 'pantas-staging' || options.sandboxTester))) continue;
    if (source.store === 'promotional') {
      promotions.push(...source.entitlementIds.map(id => ({id, endsAt: source.endsAt, active: true})));
    } else if (source.appId === options.appId && source.entitlementIds.includes('pro') && source.productId) {
      subscriptions.push({id: source.productId.split(':')[0], endsAt: source.endsAt, active: true});
    }
  }
  const coverage = coverageAt({at: options.at, subscriptions, promotions, passes: options.passes});
  const latest = coverage.endsAt ?? 0;
  return {pro: latest > 0, proUntil: latest > 0 ? latest + 86_400_000 : 0};
}
