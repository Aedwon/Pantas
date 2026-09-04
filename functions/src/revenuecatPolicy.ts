import { createHmac, timingSafeEqual } from 'node:crypto';

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

const GRANT_PRO_EVENTS = new Set([
  'INITIAL_PURCHASE',
  'RENEWAL',
  'TRANSFER_INCOMING',
]);
const REVOKE_PRO_EVENTS = new Set(['EXPIRATION', 'TRANSFER_OUTGOING']);

export interface RevenueCatClaimEvent {
  eventId: string;
  eventType: string;
  uid: string;
  unresolvedUserIsNoop?: boolean;
}

export interface RevenueCatClaimDependencies {
  getCustomClaims(uid: string): Promise<Record<string, unknown> | null>;
  setCustomClaims(uid: string, claims: Record<string, unknown>): Promise<void>;
  markTransferLoser(uid: string, eventId: string): Promise<void>;
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

  const expected = createHmac('sha256', secret)
    .update(Buffer.from(`${timestamp}.`))
    .update(rawBody)
    .digest();

  return signatures.some((signature) => {
    const actual = Buffer.from(signature, 'hex');
    return actual.length === expected.length && timingSafeEqual(expected, actual);
  });
}

export function proTransitionForEvent(eventType: string): boolean | null {
  if (GRANT_PRO_EVENTS.has(eventType)) return true;
  if (REVOKE_PRO_EVENTS.has(eventType)) return false;
  return null;
}

export function mergeProClaim(
  existingClaims: Record<string, unknown>,
  pro: boolean,
): Record<string, unknown> {
  return { ...existingClaims, pro };
}

export async function executeRevenueCatClaimTransition(
  input: RevenueCatClaimEvent,
  dependencies: RevenueCatClaimDependencies,
): Promise<boolean> {
  const pro = proTransitionForEvent(input.eventType);
  if (pro == null) return false;

  const existingClaims = await dependencies.getCustomClaims(input.uid);
  if (existingClaims == null) {
    if (input.unresolvedUserIsNoop === true) return false;
    throw new Error(`Firebase user not found for RevenueCat uid: ${input.uid}`);
  }

  await dependencies.setCustomClaims(
    input.uid,
    mergeProClaim(existingClaims, pro),
  );
  if (input.eventType === 'TRANSFER_OUTGOING') {
    await dependencies.markTransferLoser(input.uid, input.eventId);
  }
  return true;
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

export function firebaseTransferTransitions(
  event: NormalizedRevenueCatEvent,
): RevenueCatClaimEvent[] {
  if (event.eventType !== 'TRANSFER') return [];

  const outgoing = (event.transferredFrom ?? [])
    .filter((uid) => !isRevenueCatAnonymousId(uid))
    .map((uid) => ({
      eventId: event.eventId,
      eventType: 'TRANSFER_OUTGOING',
      uid,
      unresolvedUserIsNoop: true as const,
    }));
  const incoming = (event.transferredTo ?? [])
    .filter((uid) => !isRevenueCatAnonymousId(uid))
    .map((uid) => ({
      eventId: event.eventId,
      eventType: 'TRANSFER_INCOMING',
      uid,
      unresolvedUserIsNoop: true as const,
    }));
  return [...outgoing, ...incoming];
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
