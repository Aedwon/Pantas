import {
  getFirestore,
  Timestamp,
  type DocumentReference,
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
  const freshCurrentSnapshot = await currentRef.get();
  const rawFreshActiveGenerationId = freshCurrentSnapshot.exists
    ? freshCurrentSnapshot.get('activeGenerationId')
    : null;
  const freshActiveGenerationId =
    typeof rawFreshActiveGenerationId === 'string'
      ? rawFreshActiveGenerationId
      : null;

  if (freshActiveGenerationId === candidateGenerationId) {
    return;
  }

  const freshGenerationSnapshot = await candidateRef.get();

  if (!freshGenerationSnapshot.exists) {
    return;
  }

  const rawStatus = freshGenerationSnapshot.get('status');
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
    return;
  }

  await db.recursiveDelete(candidateRef);
}

async function cleanupStaleGenerations(now: Date): Promise<void> {
  const db = getFirestore();

  const stagingSnapshot = await db
    .collectionGroup('sync_generations')
    .where('status', '==', 'staging')
    .where(
      'createdAt',
      '<=',
      Timestamp.fromDate(cutoffDate(now, STAGING_RETENTION_DAYS)),
    )
    .get();

  const retiredSnapshot = await db
    .collectionGroup('sync_generations')
    .where('status', '==', 'retired')
    .where(
      'retiredAt',
      '<=',
      Timestamp.fromDate(cutoffDate(now, RETIRED_RETENTION_DAYS)),
    )
    .get();

  for (const candidate of [
    ...stagingSnapshot.docs,
    ...retiredSnapshot.docs,
  ]) {
    await cleanupGenerationCandidate(candidate.ref, now);
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
