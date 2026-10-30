import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { assertFreshAppCheck } from './_appCheck.js';
import { assertNamedUser, writeAuditLog } from './_audit.js';
import { retirePublicId } from './publicId.js';
import { clearPassOwnership } from './revenuecatPasses.js';
import { identityMarkers, trialIdentityKey } from './webTrial.js';

export const deleteAccount = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
    secrets: [trialIdentityKey],
  },
  async (request) => {
    assertFreshAppCheck(request);
    const uid = assertNamedUser(request.auth);
    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);
    const authTimeSeconds = request.auth?.token.auth_time ?? 0;
    const authAgeSeconds = Math.floor(Date.now() / 1000) - authTimeSeconds;
    if (authAgeSeconds > 5 * 60) {
      throw new HttpsError(
        'failed-precondition',
        'Recent sign-in is required before deleting an account.',
        { reason: 'requires-recent-login' },
      );
    }

    // Older trials have only an account-local record. Preserve eligibility before
    // deleting that record, including when an earlier deletion attempt is retried.
    if ((await userRef.collection('server').doc('trial').get()).exists) {
      const batch = db.batch();
      for (const marker of identityMarkers(request.auth, db)) batch.set(marker, {used: true});
      await batch.commit();
    }
    await writeAuditLog({ uid, event: 'accountDeleted' });
    await retirePublicId(db, uid);
    await db.recursiveDelete(userRef);
    await clearPassOwnership(db, uid);
    // The payment-to-account index is account data; the grant ledger went with the user tree.
    for (const collection of ['paymongoPayments', 'paymongoOrders', 'paymongoCheckouts', 'paymongoFollowUps']) {
      const payments = await db.collection(collection).where('uid', '==', uid).get();
      await Promise.all(payments.docs.map((doc) => doc.ref.delete()));
    }
    // trialUsedIdentities contains only keyed hashes and deliberately survives deletion.

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

    // The Firebase Auth identity is deleted last so any failed data cleanup
    // leaves the account recoverable for a retry.
    await getAuth().deleteUser(uid);

    return { deletedAt: new Date().toISOString() };
  },
);
