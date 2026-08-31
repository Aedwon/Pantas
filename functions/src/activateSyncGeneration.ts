import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import {
  assertNamedPro,
  decideActivation,
} from './syncGenerationPolicy.js';

interface ActivateSyncGenerationRequest {
  generationId: string;
  expectedActiveGenerationId: string | null;
}

interface ActivateSyncGenerationResponse {
  activeGenerationId: string;
  alreadyActive: boolean;
}

function isValidGenerationId(value: unknown): value is string {
  return (
    typeof value === 'string' &&
    value.length > 0 &&
    value.length <= 128 &&
    !value.includes('/')
  );
}

export const activateSyncGeneration = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
  },
  async (request): Promise<ActivateSyncGenerationResponse> => {
    let uid: string;

    try {
      uid = assertNamedPro(
        request.auth == null
          ? undefined
          : {
              uid: request.auth.uid,
              token: request.auth.token as Record<string, unknown>,
            },
      );
    } catch {
      throw new HttpsError(
        'permission-denied',
        'A named Pro account is required for Sync.',
      );
    }

    const data = request.data as
      | Partial<ActivateSyncGenerationRequest>
      | undefined;

    const generationId = data?.generationId;
    const expectedActiveGenerationId = data?.expectedActiveGenerationId;

    if (!isValidGenerationId(generationId)) {
      throw new HttpsError(
        'invalid-argument',
        'A valid generationId is required.',
      );
    }

    if (
      expectedActiveGenerationId !== null &&
      !isValidGenerationId(expectedActiveGenerationId)
    ) {
      throw new HttpsError(
        'invalid-argument',
        'expectedActiveGenerationId must be a valid generation ID or null.',
      );
    }

    const db = getFirestore();
    const userRef = db.collection('users').doc(uid);
    const currentRef = userRef.collection('sync_state').doc('current');
    const targetRef = userRef
      .collection('sync_generations')
      .doc(generationId);

    const result = await db.runTransaction(
      async (transaction): Promise<ActivateSyncGenerationResponse> => {
        const currentSnapshot = await transaction.get(currentRef);
        const targetSnapshot = await transaction.get(targetRef);

        const rawCurrentGenerationId = currentSnapshot.exists
          ? currentSnapshot.get('activeGenerationId')
          : null;

        const currentGenerationId =
          typeof rawCurrentGenerationId === 'string'
            ? rawCurrentGenerationId
            : null;

        const rawTargetStatus = targetSnapshot.exists
          ? targetSnapshot.get('status')
          : null;

        const requestedGenerationStatus =
          typeof rawTargetStatus === 'string'
            ? rawTargetStatus
            : null;

        const decision = decideActivation({
          currentGenerationId,
          expectedActiveGenerationId,
          requestedGenerationId: generationId,
          requestedGenerationStatus,
        });

        if (decision.kind === 'already-active') {
          return {
            activeGenerationId: generationId,
            alreadyActive: true,
          };
        }

        if (decision.kind === 'invalid-target') {
          throw new HttpsError(
            'failed-precondition',
            'The requested generation is not a staging generation.',
            {
              code: 'invalid-generation',
            },
          );
        }

        if (decision.kind === 'generation-conflict') {
          throw new HttpsError(
            'failed-precondition',
            'The active Sync generation changed before activation.',
            {
              code: 'generation-conflict',
              activeGenerationId: decision.activeGenerationId,
            },
          );
        }

        transaction.update(targetRef, {
          status: 'active',
          activatedAt: FieldValue.serverTimestamp(),
        });

        if (
          decision.previousGenerationId !== null &&
          decision.previousGenerationId !== generationId
        ) {
          const previousRef = userRef
            .collection('sync_generations')
            .doc(decision.previousGenerationId);

          transaction.update(previousRef, {
            status: 'retired',
            retiredAt: FieldValue.serverTimestamp(),
          });
        }

        transaction.set(currentRef, {
          activeGenerationId: generationId,
          schemaVersion: 1,
          updatedAt: FieldValue.serverTimestamp(),
        });

        return {
          activeGenerationId: generationId,
          alreadyActive: false,
        };
      },
    );

    logger.info('audit', {
      event: 'syncGenerationActivated',
      uid,
      metadata: {
        generationId,
        alreadyActive: result.alreadyActive,
      },
    });

    await db.collection('audit_logs').add({
      uid,
      event: 'syncGenerationActivated',
      timestamp: new Date(),
      metadata: {
        generationId,
        alreadyActive: result.alreadyActive,
      },
    });

    return result;
  },
);
