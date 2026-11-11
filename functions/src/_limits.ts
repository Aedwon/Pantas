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

/**
 * Takes as many of `wanted` units as the window still has room for, and returns how many it took
 * (0 to `wanted`). Unlike `allowAtMost` it never refuses the whole request, so a caller can
 * deliver part of it. The read and the write are one transaction on one document, so concurrent
 * calls cannot take more than `max` between them. Nothing is reserved up front, so there is
 * nothing to refund.
 */
export async function takeAtMost(
  uid: string,
  key: string,
  max: number,
  windowMs: number,
  wanted: number,
): Promise<number> {
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
    const granted = Math.max(0, Math.min(wanted, max - count));
    if (granted > 0) {
      transaction.set(ref, {
        windowStartedAt: withinWindow ? startedAt : now,
        count: count + granted,
      });
    }
    return granted;
  }, {maxAttempts: 10});
}
