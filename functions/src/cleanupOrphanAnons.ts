import { getAuth, type UserRecord } from 'firebase-admin/auth';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { onSchedule } from 'firebase-functions/v2/scheduler';

function isOldAnonymous(user: UserRecord, cutoff: number): boolean {
  // Pantas anonymous identities have no linked provider, email, or phone.
  const lastSignIn = Date.parse(user.metadata.lastSignInTime);
  const lastRefresh = Date.parse(user.metadata.lastRefreshTime ?? '');
  return user.providerData.length === 0 && !user.email && !user.phoneNumber
    && Number.isFinite(lastSignIn) && lastSignIn < cutoff
    && (!Number.isFinite(lastRefresh) || lastRefresh < cutoff);
}

// Subcollections an anonymous account may hold that are safe to delete with it: server-side
// answers and mock records, and rate-limit counters. Anything else keeps the account.
const DISPOSABLE = new Set(['server', 'limits']);

async function onlyDisposableData(db: Firestore, uid: string): Promise<boolean> {
  const root = db.doc(`users/${uid}`);
  const collections = await root.listCollections();
  if (collections.some((collection) => !DISPOSABLE.has(collection.id))) return false;
  // An entitlement or trial record means the account touched payments; leave it for support.
  const kept = await db.getAll(root.collection('server').doc('entitlement'), root.collection('server').doc('trial'));
  return kept.every((doc) => !doc.exists);
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
        if ((await root.get()).exists || !(await onlyDisposableData(db, user.uid))) continue;
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
        // Synced answers, mock records and limits belong to an identity no one can sign in to again.
        await db.recursiveDelete(root);
        await auth.deleteUser(user.uid);
        deleted += 1;
      }
      pageToken = page.pageToken;
    } while (pageToken);
    logger.info('cleanupOrphanAnons', { scanned, deleted });
  },
);
