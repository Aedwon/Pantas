import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { assertNamedUser } from './_audit.js';

export const exportData = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    assertNamedUser(request.auth);
    throw new HttpsError(
      'failed-precondition',
      "Data export isn't available in the app yet. Email our Data Protection Officer for a copy.",
    );
  },
);
