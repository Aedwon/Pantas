import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError } from 'firebase-functions/v2/https';

export type AuditEvent =
  | 'accountCreated'
  | 'signInLinked'
  | 'dataExported'
  | 'accountDeleted'
  | 'cloudDataReset';

export interface AuditLogInput {
  uid: string;
  event: AuditEvent;
  metadata?: Record<string, unknown>;
}

export async function writeAuditLog(input: AuditLogInput): Promise<void> {
  logger.info('audit', {
    event: input.event,
    uid: input.uid,
    metadata: input.metadata ?? {},
  });

  await getFirestore().collection('audit_logs').add({
    uid: input.uid,
    event: input.event,
    timestamp: new Date(),
    metadata: input.metadata ?? {},
  });
}

export function assertNamedUser(
  auth:
    | {
        uid: string;
        token: { firebase?: { sign_in_provider?: string }; auth_time?: number };
      }
    | undefined,
): string {
  if (!auth) {
    throw new HttpsError('unauthenticated', 'Authentication is required.');
  }
  if (auth.token.firebase?.sign_in_provider === 'anonymous') {
    throw new HttpsError(
      'permission-denied',
      'A named account is required for this operation.',
    );
  }
  return auth.uid;
}
