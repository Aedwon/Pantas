import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { assertNamedUser, writeAuditLog } from './_audit.js';
import { allowAtMost } from './_limits.js';

export const recordSignInEvent = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);

    await db.runTransaction(async (transaction) => {
      const snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        transaction.create(userRef, {
          createdAt: FieldValue.serverTimestamp(),
        });
      }
    });

    const logged = await allowAtMost(uid, 'signInAudit', 1, 60 * 60 * 1000);
    if (logged) {
      await writeAuditLog({ uid, event: 'signInLinked' });
    }
    return { logged };
  },
);
