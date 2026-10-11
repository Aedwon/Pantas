// Firestore owns the decision; Auth is repaired after commit, never inside it.
import { FieldPath, FieldValue, Timestamp, type Firestore, type Transaction } from 'firebase-admin/firestore';
import type { Auth } from 'firebase-admin/auth';
import {randomUUID} from 'node:crypto';

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
      claimsVersion: Number(previous.get('claimsVersion') ?? 0), claimsPending:true}, {merge:true});
    return true;
  });
}

export async function copyEntitlementClaims(db: Firestore, auth: ClaimAuth, uid: string,
  now: () => number = Date.now): Promise<void> {
  const record = db.doc(`users/${uid}/server/entitlement`);
  const holder = randomUUID();
  const acquired = await db.runTransaction(async transaction => {
    const snapshot = await transaction.get(record);
    if (!snapshot.exists || (snapshot.get('claimsPending') !== true &&
        snapshot.get('claimsVersion') === snapshot.get('version'))) return false;
    const expiry = snapshot.get('claimsLeaseUntil') as Timestamp | undefined;
    if (snapshot.get('claimsLeaseHolder') && expiry && expiry.toMillis() > now()) {
      throw new Error('Entitlement claims lease is held; retry required');
    }
    transaction.update(record, {claimsPending:true, claimsLeaseHolder:holder,
      claimsLeaseUntil:Timestamp.fromMillis(now()+60_000)});
    return true;
  });
  if (!acquired) return;
  const holdsLease = (snapshot: import('firebase-admin/firestore').DocumentSnapshot) =>
    snapshot.get('claimsLeaseHolder') === holder &&
    (snapshot.get('claimsLeaseUntil') as Timestamp).toMillis() > now();
  try {
    for (let attempt = 0; attempt < 3; attempt++) {
      const user = await auth.getUser(uid);
      // Re-read under the lease after other async work, never copy event values.
      const snapshot = await record.get();
      if (!snapshot.exists || !holdsLease(snapshot)) throw new Error('Entitlement claims lease expired');
      const version = snapshot.get('version') as number;
      await auth.setCustomUserClaims(uid, {...user.customClaims,
        pro:snapshot.get('pro') === true, proUntil:Number(snapshot.get('proUntil'))});
      const applied = await db.runTransaction(async transaction => {
        const latest = await transaction.get(record);
        if (!latest.exists || !holdsLease(latest)) throw new Error('Entitlement claims lease lost');
        if (latest.get('version') !== version) return false;
        transaction.update(record, {claimsVersion:version,claimsPending:false,
          claimsLeaseHolder:FieldValue.delete(),claimsLeaseUntil:FieldValue.delete()});
        transaction.set(db.doc(`users/${uid}`), {
          claimsVersion:version,claimsChangedAt:FieldValue.serverTimestamp(),
        }, {merge:true});
        return true;
      });
      if (applied) return;
    }
    throw new Error('Entitlement changed during claim copy; retry required');
  } catch (error) {
    await db.runTransaction(async transaction => {
      const latest = await transaction.get(record);
      // A stale holder never releases a successor's lease or clears its work.
      if (latest.exists && latest.get('claimsLeaseHolder') === holder) {
        transaction.update(record, {claimsPending:true,
          claimsLeaseHolder:FieldValue.delete(),claimsLeaseUntil:FieldValue.delete()});
      }
    });
    throw error;
  }
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
