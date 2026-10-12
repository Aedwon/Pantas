import {getFirestore} from 'firebase-admin/firestore';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {requireAdmin} from './_admin.js';
import {isValidPublicId} from './publicId.js';

// Server operator helper only. Never export a public/client-callable ID lookup.
export async function lookupPublicId(request: Pick<CallableRequest<unknown>, 'auth' | 'app'>,
  digits: string): Promise<string | null> {
  const adminUid = await requireAdmin(request);
  if (!isValidPublicId(digits)) throw new HttpsError('invalid-argument', 'Invalid public ID.');
  const db = getFirestore();
  const mapping = await db.doc(`publicIds/${digits}`).get();
  const uid: unknown = mapping.get('uid');
  const targetUid = typeof uid === 'string' ? uid : null;
  await db.collection('audit_logs').add({uid: adminUid, event: 'publicIdLookup',
    timestamp: new Date(), metadata: {publicId: digits, targetUid}});
  return targetUid;
}
