import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
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

    // Purge hosted Wrapped cards: top-level docs + their storage objects
    // (landing-page spec §5.2).
    const sharedCards = await db
      .collection('wrapped_shares')
      .where('ownerUid', '==', uid)
      .get();
    await Promise.all(sharedCards.docs.map((doc) => doc.ref.delete()));
    await getStorage()
      .bucket()
      .deleteFiles({ prefix: `wrapped/${uid}/` });

    return { deletedAt: new Date().toISOString() };
  },
);
