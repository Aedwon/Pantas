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
    const authTimeSeconds = request.auth?.token.auth_time ?? 0;
    const authAgeSeconds = Math.floor(Date.now() / 1000) - authTimeSeconds;
    if (authAgeSeconds > 5 * 60) {
      throw new Error('requires-recent-login');
    }

    await writeAuditLog({ uid, event: 'accountDeleted' });

    return { deletedAt: new Date().toISOString() };
  },
);
