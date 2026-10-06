import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, type CallableRequest } from 'firebase-functions/v2/https';

if (!getApps().some((app) => app.name === '[DEFAULT]')) {
  initializeApp();
}

export async function requireAdmin(
  request: Pick<CallableRequest<unknown>, 'auth' | 'app'>,
): Promise<string> {
  if (request.auth?.token.admin !== true || request.app == null) {
    throw new HttpsError('permission-denied', 'Administrator access is required.');
  }

  const uid = request.auth.uid;
  const entry = {
    uid,
    event: 'adminAuthorized',
    timestamp: new Date(),
    metadata: { appId: request.app.appId },
  };
  logger.info('audit', entry);
  await getFirestore().collection('audit_logs').add(entry);
  return uid;
}
