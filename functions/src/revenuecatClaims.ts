// Firestore owns the decision; Auth is repaired after commit, never inside it.
import { FieldPath, FieldValue, type Firestore, type Transaction } from 'firebase-admin/firestore';
import type { Auth } from 'firebase-admin/auth';

type ClaimAuth = Pick<Auth, 'getUser' | 'setCustomUserClaims'>;

type Claims = {pro: boolean; proUntil: number};
export async function commitRevenueCatAnswer(db: Firestore, uid: string, eventId: string,
  answerAt: number, claims: Claims | ((transaction: Transaction) => Promise<{claims:Claims; apply():void}>),
  facts: object): Promise<boolean> {
  const record = db.doc(`users/${uid}/server/entitlement`);
  const event = db.doc(`webhookEvents/${eventId}/users/${uid}`);
  return db.runTransaction(async transaction => {
    const [previous, dedupe] = await transaction.getAll(record, event);
    if (dedupe.exists) return false;
    if (previous.exists && previous.get('answerAt') > answerAt) {
      transaction.set(event, {answerAt,facts}); return false;
    }
    const prepared = typeof claims === 'function' ? await claims(transaction) : {claims,apply:()=>{}};
    prepared.apply();
    transaction.set(event, {answerAt, facts});
    transaction.set(record, {...prepared.claims, answerAt, facts,
      version: Number(previous.get('version') ?? 0) + 1,
      claimsVersion: Number(previous.get('claimsVersion') ?? 0)});
    return true;
  });
}

export async function copyEntitlementClaims(db: Firestore, auth: ClaimAuth, uid: string): Promise<void> {
  const record = db.doc(`users/${uid}/server/entitlement`);
  for (let attempt = 0; attempt < 3; attempt++) {
    const snapshot = await record.get();
    if (!snapshot.exists || snapshot.get('claimsVersion') === snapshot.get('version')) return;
    const version = snapshot.get('version') as number;
    try {
      const user = await auth.getUser(uid);
      await auth.setCustomUserClaims(uid, {...user.customClaims,
        pro: snapshot.get('pro') === true, proUntil: Number(snapshot.get('proUntil'))});
    } catch (error) {
      await db.runTransaction(async transaction => {
        const latest = await transaction.get(record);
        if (latest.exists) transaction.update(record, {claimsVersion: 0});
      });
      throw error;
    }
    const applied = await db.runTransaction(async transaction => {
      const latest = await transaction.get(record);
      if (!latest.exists) return true;
      if (latest.get('version') !== version) {
        // An older in-flight copy can overwrite a newer acknowledged copy.
        // Leave a mismatch for retry/hourly repair even if that newer copy ran.
        transaction.update(record, {claimsVersion: 0});
        return false;
      }
      transaction.update(record, {claimsVersion: version});
      transaction.set(db.doc(`users/${uid}`), {
        claimsVersion: version, claimsChangedAt: FieldValue.serverTimestamp(),
      }, {merge:true});
      return true;
    });
    if (applied) return;
  }
  throw new Error('Entitlement changed during claim copy; retry required');
}

export async function repairClaims(db: Firestore, auth: ClaimAuth): Promise<void> {
  let last;
  while (true) {
    let query = db.collectionGroup('server').orderBy(FieldPath.documentId()).limit(500);
    if (last) query = query.startAfter(last);
    const page = await query.get();
    for (const doc of page.docs) {
      if (doc.id !== 'entitlement' || doc.get('claimsVersion') === doc.get('version')) continue;
      const user = doc.ref.parent.parent;
      if (user?.parent.id !== 'users') continue;
      try { await copyEntitlementClaims(db, auth, user.id); }
      catch (error) { console.error('Entitlement claim repair failed', {uid:user.id, error}); }
    }
    if (page.size < 500) return;
    last = page.docs.at(-1);
  }
}
