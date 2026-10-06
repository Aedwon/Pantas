import { getAuth, type UserRecord } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';

function isOldAnonymous(user: UserRecord, cutoff: number): boolean {
  // Pantas anonymous identities have no linked provider, email, or phone.
  const lastSignIn = Date.parse(user.metadata.lastSignInTime);
  return user.providerData.length === 0 && !user.email && !user.phoneNumber
    && Number.isFinite(lastSignIn) && lastSignIn < cutoff;
}

export const cleanupOrphanAnons = onSchedule(
  { schedule: 'every day 03:00', timeZone: 'Asia/Singapore', region: 'asia-southeast1' },
  async () => {
    const auth = getAuth();
    const db = getFirestore();
    const cutoff = Date.now() - 30 * 86400000;
    let pageToken: string | undefined;
    let scanned = 0;
    let deleted = 0;
    do {
      const page = await auth.listUsers(500, pageToken);
      for (const user of page.users) {
        scanned += 1;
        if (!isOldAnonymous(user, cutoff)) continue;
        const root = db.doc(`users/${user.uid}`);
        if ((await root.get()).exists || (await root.listCollections()).length > 0) continue;
        const shares = await db.collection('wrapped_shares').where('ownerUid', '==', user.uid).limit(1).get();
        if (!shares.empty) continue;
        // Recheck after the data reads in case the user signed in or linked a provider.
        let fresh: UserRecord;
        try {
          fresh = await auth.getUser(user.uid);
        } catch (error) {
          if ((error as { code?: string }).code === 'auth/user-not-found') continue;
          throw error;
        }
        if (!isOldAnonymous(fresh, cutoff)) continue;
        await auth.deleteUser(user.uid);
        deleted += 1;
      }
      pageToken = page.pageToken;
    } while (pageToken);
    logger.info('cleanupOrphanAnons', { scanned, deleted });
  },
);
