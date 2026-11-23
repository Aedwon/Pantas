import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { writeAuditLog } from './_audit.js';
import {serviceAccountEmail} from './serviceAccounts.js';

export const onUserCreated = onDocumentCreated(
  {
    document: 'users/{uid}',
    region: 'asia-southeast1',
    serviceAccount: serviceAccountEmail('pantas-jobs'),
  },
  async (event) => {
    await writeAuditLog({
      uid: event.params.uid,
      event: 'accountCreated',
    });
  },
);
