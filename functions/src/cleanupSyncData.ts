import {
  getFirestore,
  Timestamp,
  type DocumentReference,
  type QueryDocumentSnapshot,
} from 'firebase-admin/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import {
  cutoffDate,
  generationCleanupEligible,
  RETIRED_RETENTION_DAYS,
  STAGING_RETENTION_DAYS,
  TOMBSTONE_RETENTION_DAYS,
} from './syncGenerationPolicy.js';

const SYNC_COLLECTIONS = [
  'quiz_attempts',
  'assessments',
  'fsrs_cards',
  'lesson_progress',
  'lesson_bookmarks',
  'question_flags',
  'mock_exam_attempts',
  'review_logs',
  'track_scope',
  'custom_blueprints',
] as const;

function timestampDate(value: unknown): Date | undefined {
  if (value instanceof Date) {
    return value;
  }

  if (
    value != null
    && typeof value === 'object'
    && 'toDate' in value
    && typeof value.toDate === 'function'
  ) {
    const converted = value.toDate();

    return converted instanceof Date ? converted : undefined;
  }

  return undefined;
}

async function cleanupTombstones(now: Date): Promise<void> {
  const db = getFirestore();
  const cutoff = Timestamp.fromDate(
    cutoffDate(now, TOMBSTONE_RETENTION_DAYS),
  );

  for (const collectionName of SYNC_COLLECTIONS) {
    while (true) {
      const snapshot = await db
        .collectionGroup(collectionName)
        .where('deleted', '==', true)
        .where('updatedAt', '<=', cutoff)
        .limit(500)
        .get();

      if (snapshot.empty) {
        break;
      }

      const batch = db.batch();

      for (const document of snapshot.docs) {
        batch.delete(document.ref);
      }

      await batch.commit();

      if (snapshot.size < 500) {
        break;
      }
    }
  }
}

async function cleanupGenerationCandidate(
  candidateRef: DocumentReference,
  now: Date,
): Promise<void> {
  const db = getFirestore();
  const candidateGenerationId = candidateRef.id;
  const userRef = candidateRef.parent.parent;

  if (userRef == null || userRef.parent.id !== 'users') {
    return;
  }

  const currentRef = userRef.collection('sync_state').doc('current');
  const claimed = await db.runTransaction(async (transaction) => {
    const freshCurrentSnapshot = await transaction.get(currentRef);
    const rawFreshActiveGenerationId = freshCurrentSnapshot.exists
      ? freshCurrentSnapshot.get('activeGenerationId')
      : null;
    const freshActiveGenerationId =
      typeof rawFreshActiveGenerationId === 'string'
        ? rawFreshActiveGenerationId
        : null;

    if (freshActiveGenerationId === candidateGenerationId) {
      return false;
    }

    const freshGenerationSnapshot = await transaction.get(candidateRef);

    if (!freshGenerationSnapshot.exists) {
      return false;
    }

    const rawStatus = freshGenerationSnapshot.get('status');
    if (rawStatus === 'deleting') return true;
    const status = typeof rawStatus === 'string' ? rawStatus : '';
    const createdAt = timestampDate(
      freshGenerationSnapshot.get('createdAt'),
    );
    const retiredAt = timestampDate(
      freshGenerationSnapshot.get('retiredAt'),
    );

    if (
      !generationCleanupEligible({
        generationId: candidateGenerationId,
        status,
        createdAt,
        retiredAt,
        activeGenerationId: freshActiveGenerationId,
        now,
      })
    ) {
      return false;
    }

    transaction.update(candidateRef, { status: 'deleting' });
    return true;
  });
  if (!claimed) return;

  await db.recursiveDelete(candidateRef);
}

async function cleanupStaleGenerations(now: Date): Promise<void> {
  const db = getFirestore();

  for (const [status, timeField, retentionDays] of [
    ['staging', 'createdAt', STAGING_RETENTION_DAYS],
    ['retired', 'retiredAt', RETIRED_RETENTION_DAYS],
    // Resume a claimed cleanup if an earlier invocation ended before deletion.
    ['deleting', 'createdAt', 0],
  ] as const) {
    const baseQuery = db.collectionGroup('sync_generations')
      .where('status', '==', status)
      .where(timeField, '<=', Timestamp.fromDate(cutoffDate(now, retentionDays)))
      .orderBy(timeField)
      .limit(500);
    let cursor: QueryDocumentSnapshot | undefined;
    while (true) {
      const snapshot = await (cursor ? baseQuery.startAfter(cursor) : baseQuery).get();
      if (snapshot.empty) break;
      for (const candidate of snapshot.docs) {
        await cleanupGenerationCandidate(candidate.ref, now);
      }
      cursor = snapshot.docs[snapshot.size - 1];
      if (snapshot.size < 500) break;
    }
  }
}

export const cleanupSyncData = onSchedule(
  {
    schedule: 'every day 04:00',
    timeZone: 'Asia/Singapore',
    region: 'asia-southeast1',
  },
  async () => {
    const now = new Date();

    await cleanupTombstones(now);
    await cleanupStaleGenerations(now);
  },
);
