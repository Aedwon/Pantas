import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { writeAuditLog, assertNamedUser } from './_audit.js';

export const exportData = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
    consumeAppCheckToken: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    const downloadUrl = `https://storage.googleapis.com/export-placeholder/${uid}.json`;
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

    // Shared Wrapped cards are PII under RA10173 and live outside /users/{uid},
    // so include them in the export (landing-page spec §5.2).
    const sharedSnapshot = await getFirestore()
      .collection('wrapped_shares')
      .where('ownerUid', '==', uid)
      .get();
    const sharedCards = sharedSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        shareId: doc.id,
        createdAt: data.createdAt?.toDate?.()?.toISOString() ?? null,
        archetypeId: String(data.archetypeId ?? ''),
      };
    });

    await writeAuditLog({
      uid,
      event: 'dataExported',
      metadata: { byteSize: 0 },
    });

    return { downloadUrl, expiresAt, sharedCards };
  },
);
