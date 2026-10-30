import { HttpsError, onCall } from 'firebase-functions/v2/https';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import { assertNamedUser } from './_audit.js';

export const exportData = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: enforceAppCheck,
    consumeAppCheckToken: enforceAppCheck,
  },
  async (request) => {
    assertFreshAppCheck(request);
    assertNamedUser(request.auth);
    throw new HttpsError(
      'failed-precondition',
      "Data export isn't available in the app yet. Email our Data Protection Officer for a copy.",
    );
  },
);
