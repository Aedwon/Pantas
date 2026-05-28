import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { assertNamedUser, writeAuditLog } from './_audit.js';

export const deleteAccount = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);
    const authTimeSeconds = request.auth?.token.auth_time ?? 0;
    const authAgeSeconds = Math.floor(Date.now() / 1000) - authTimeSeconds;
    if (authAgeSeconds > 5 * 60) {
      throw new Error('requires-recent-login');
    }

    await writeAuditLog({ uid, event: 'accountDeleted' });
    await db.recursiveDelete(userRef);

    return { deletedAt: new Date().toISOString() };
  },
);
