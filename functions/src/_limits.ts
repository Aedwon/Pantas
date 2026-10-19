import { getFirestore, Timestamp } from 'firebase-admin/firestore';

export async function allowAtMost(
  uid: string,
  key: string,
  max: number,
  windowMs: number,
  cost = 1,
): Promise<boolean> {
  const db = getFirestore();
  const ref = db.doc(`users/${uid}/limits/${key}`);
  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const now = Timestamp.now();
    const startedAt: unknown = snapshot.get('windowStartedAt');
    const oldCount: unknown = snapshot.get('count');
    const withinWindow = startedAt instanceof Timestamp
      && now.toMillis() - startedAt.toMillis() < windowMs;
    const count = withinWindow && typeof oldCount === 'number' ? oldCount : 0;
    if (count + cost > max) return false;
    transaction.set(ref, {
      windowStartedAt: withinWindow ? startedAt : now,
      count: count + cost,
    });
    return true;
  });
}
