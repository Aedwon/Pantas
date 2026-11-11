export const TOMBSTONE_RETENTION_DAYS = 90;
export const STAGING_RETENTION_DAYS = 7;
export const RETIRED_RETENTION_DAYS = 30;

const MILLIS_PER_DAY = 24 * 60 * 60 * 1000;

export interface SyncAuthLike {
  uid: string;
  token: Record<string, unknown>;
}

export function assertNamedPro(auth: SyncAuthLike | undefined): string {
  if (auth == null || auth.uid.length === 0) {
    throw new Error('Named Pro authentication is required.');
  }

  const firebase = auth.token.firebase;
  const signInProvider =
    firebase != null && typeof firebase === 'object'
      ? (firebase as Record<string, unknown>).sign_in_provider
      : undefined;

  if (signInProvider === 'anonymous' || auth.token.pro !== true ||
      typeof auth.token.proUntil !== 'number' || !Number.isFinite(auth.token.proUntil) ||
      auth.token.proUntil <= Date.now()) {
    throw new Error('Named Pro authentication is required.');
  }

  return auth.uid;
}

export interface ActivationDecisionInput {
  currentGenerationId: string | null;
  expectedActiveGenerationId: string | null;
  requestedGenerationId: string;
  requestedGenerationStatus: string | null;
}

export type ActivationDecision =
  | {kind: 'activate'; previousGenerationId: string | null}
  | {kind: 'already-active'}
  | {kind: 'generation-conflict'; activeGenerationId: string | null}
  | {kind: 'invalid-target'};

export function decideActivation(
  input: ActivationDecisionInput,
): ActivationDecision {
  if (
    input.currentGenerationId === input.requestedGenerationId &&
    input.requestedGenerationStatus === 'active'
  ) {
    return {kind: 'already-active'};
  }

  if (input.requestedGenerationStatus !== 'staging') {
    return {kind: 'invalid-target'};
  }

  if (input.currentGenerationId !== input.expectedActiveGenerationId) {
    return {
      kind: 'generation-conflict',
      activeGenerationId: input.currentGenerationId,
    };
  }

  return {
    kind: 'activate',
    previousGenerationId: input.currentGenerationId,
  };
}

export function cutoffDate(now: Date, days: number): Date {
  return new Date(now.getTime() - days * MILLIS_PER_DAY);
}

export function generationCleanupEligible(input: {
  generationId: string;
  status: string;
  createdAt?: Date;
  retiredAt?: Date;
  activeGenerationId: string | null;
  now: Date;
}): boolean {
  if (input.generationId === input.activeGenerationId) {
    return false;
  }

  if (input.status === 'staging' && input.createdAt != null) {
    return (
      input.createdAt.getTime() <=
      cutoffDate(input.now, STAGING_RETENTION_DAYS).getTime()
    );
  }

  if (input.status === 'retired' && input.retiredAt != null) {
    return (
      input.retiredAt.getTime() <=
      cutoffDate(input.now, RETIRED_RETENTION_DAYS).getTime()
    );
  }

  return false;
}
