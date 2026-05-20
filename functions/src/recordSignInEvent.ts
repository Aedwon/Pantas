import { onCall } from 'firebase-functions/v2/https';
import { assertNamedUser, writeAuditLog } from './_audit.js';

export const recordSignInEvent = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    await writeAuditLog({ uid, event: 'signInLinked' });
    return { logged: true };
  },
);
