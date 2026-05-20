import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { writeAuditLog } from './_audit.js';

export const onUserCreated = onDocumentCreated(
  {
    document: 'users/{uid}',
    region: 'asia-southeast1',
  },
  async (event) => {
    await writeAuditLog({
      uid: event.params.uid,
      event: 'accountCreated',
    });
  },
);
