import { getFirestore } from 'firebase-admin/firestore';
import { onCall } from 'firebase-functions/v2/https';
import { assertNamedUser, writeAuditLog } from './_audit.js';

export const resetCloudUserData = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
  },
  async (request) => {
    const uid = assertNamedUser(request.auth);
    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);
    const collections = [
      userRef.collection('lesson_progress'),
      userRef.collection('quiz_attempts'),
      userRef.collection('fsrs_cards'),
      userRef.collection('assessments'),
      userRef.collection('study_plan'),
      userRef.collection('mock_exam_attempts'),
    ];

    for (const collectionRef of collections) {
      await db.recursiveDelete(collectionRef);
    }

    await writeAuditLog({ uid, event: 'cloudDataReset' });

    return { resetAt: new Date().toISOString() };
  },
);
