import { onCall } from 'firebase-functions/v2/https';
import { writeAuditLog, assertNamedUser } from './_audit.js';

export const exportData = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    const downloadUrl = `https://storage.googleapis.com/export-placeholder/${uid}.json`;
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

    await writeAuditLog({
      uid,
      event: 'dataExported',
      metadata: { byteSize: 0 },
    });

    return { downloadUrl, expiresAt };
  },
);
