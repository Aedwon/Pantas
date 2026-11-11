import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import {HttpsError} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {assertFreshAppCheck, enforceAppCheck} from './_appCheck.js';
import { assertNamedUser } from './_audit.js';
import { deleteUserData } from './deleteUserData.js';
import { trialIdentityKey } from './webTrial.js';
import { ACCOUNT_DELETION_MAX_INSTANCES } from './_options.js';
import {timed} from './_timed.js';

export const deleteAccount = onCall(
  {
    region: 'asia-southeast1',
    maxInstances: ACCOUNT_DELETION_MAX_INSTANCES,
    enforceAppCheck: enforceAppCheck,
    consumeAppCheckToken: enforceAppCheck,
    secrets: [trialIdentityKey],
  },
  timed('deleteAccount', async (request) => {
    assertFreshAppCheck(request);
    const uid = assertNamedUser(request.auth);
    const authTimeSeconds = request.auth?.token.auth_time ?? 0;
    const authAgeSeconds = Math.floor(Date.now() / 1000) - authTimeSeconds;
    if (authAgeSeconds > 5 * 60) {
      throw new HttpsError(
        'failed-precondition',
        'Recent sign-in is required before deleting an account.',
        { reason: 'requires-recent-login' },
      );
    }

    await deleteUserData(getFirestore(), getAuth(), uid, 'user_request', { requestAuth: request.auth });

    return { deletedAt: new Date().toISOString() };
  }),
);
