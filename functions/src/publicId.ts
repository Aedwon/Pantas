import {createHash, randomInt} from 'node:crypto';
import {FieldValue, type Firestore} from 'firebase-admin/firestore';

export function isValidPublicId(value: unknown): value is string {
  if (typeof value !== 'string' || !/^[1-9][0-9]{8}$/.test(value)) return false;
  let sum = 0;
  for (let i = 0; i < value.length; i++) {
    const digit = Number(value[i]) * (i % 2 === 1 ? 2 : 1);
    sum += digit > 9 ? digit - 9 : digit;
  }
  return sum % 10 === 0;
}

function randomPublicId(): string {
  const payload = String(randomInt(10_000_000, 100_000_000));
  let sum = 0;
  for (let i = 0; i < payload.length; i++) {
    const digit = Number(payload[i]) * (i % 2 === 1 ? 2 : 1);
    sum += digit > 9 ? digit - 9 : digit;
  }
  return payload + String((10 - sum % 10) % 10);
}

type Identity = {uid: string; token: {firebase?: {sign_in_provider?: string}}} | undefined;
export async function ensurePublicId(db: Firestore, auth: Identity,
  generate: () => string = randomPublicId): Promise<string | null> {
  if (auth?.token.firebase?.sign_in_provider !== 'google.com') return null;
  const user = db.doc(`users/${auth.uid}`);
  for (let attempt = 0; attempt < 100; attempt++) {
    const id = generate();
    if (!isValidPublicId(id)) throw new Error('Invalid public ID candidate');
    const result = await db.runTransaction(async transaction => {
      const snapshot = await transaction.get(user);
      if (snapshot.get('publicIdRetired') === true) return {id: null};
      const existing: unknown = snapshot.get('publicId');
      if (isValidPublicId(existing)) return {id: existing};
      // The user root is removed before Auth. Keep retirement effective through
      // that cleanup window without retaining the raw UID in retired records.
      const ownerHash = createHash('sha256').update(auth.uid).digest('hex');
      const priorRetirement = await transaction.get(
        db.collection('retiredPublicIds').where('ownerHash', '==', ownerHash).limit(1));
      if (!priorRetirement.empty) return {id: null};
      const mapping = db.doc(`publicIds/${id}`);
      const retired = db.doc(`retiredPublicIds/${id}`);
      const reserved = await transaction.getAll(mapping, retired);
      if (reserved.some(doc => doc.exists)) return undefined;
      transaction.create(mapping, {uid: auth.uid, createdAt: FieldValue.serverTimestamp()});
      transaction.set(user, {publicId: id}, {merge: true});
      return {id};
    });
    if (result !== undefined) return result.id;
  }
  throw new Error('Public ID allocation exhausted; retry required');
}

export async function retirePublicId(db: Firestore, uid: string): Promise<void> {
  const user = db.doc(`users/${uid}`);
  await db.runTransaction(async transaction => {
    const snapshot = await transaction.get(user);
    const id: unknown = snapshot.get('publicId');
    if (!isValidPublicId(id)) {
      // Deletion can precede the first sign-in audit/ID allocation. Preserve
      // the same retirement guard through user-root cleanup in that case.
      const ownerHash = createHash('sha256').update(uid).digest('hex');
      transaction.set(db.doc(`retiredPublicIds/account_${ownerHash}`),
        {ownerHash,retiredAt:FieldValue.serverTimestamp()});
      transaction.set(user, {publicIdRetired:true}, {merge:true});
      return;
    }
    const mapping = db.doc(`publicIds/${id}`);
    const current = await transaction.get(mapping);
    if (current.exists && current.get('uid') !== uid) throw new Error('Public ID owner mismatch');
    transaction.set(db.doc(`retiredPublicIds/${id}`), {retiredAt: FieldValue.serverTimestamp(),
      ownerHash: createHash('sha256').update(uid).digest('hex')});
    transaction.delete(mapping);
    transaction.update(user, {publicId: FieldValue.delete(), publicIdRetired: true});
  });
}
