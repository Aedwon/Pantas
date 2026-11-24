import {getFirestore, type Firestore} from 'firebase-admin/firestore';
import {logger} from 'firebase-functions';

/**
 * NPC Circular 2022-04: registering with the National Privacy Commission becomes mandatory when a
 * controller processes sensitive personal information of at least 1,000 data subjects, and age
 * counts as sensitive. The only age the server holds is `ageGroup` ('minor' or 'adult') on
 * `users/{uid}/server/guardianConsent`; birth year stays on the device.
 */
export const NPC_REGISTRATION_THRESHOLD = 1000;
/** Alert this early, so there is time to register before the threshold is crossed. */
export const NPC_ALERT_AT = 800;

/**
 * Daily task inside an existing job. One count aggregation, billed one read per 1,000 matches, so
 * about one read a day. It needs the collection-group index on `server.ageGroup`. The logs carry
 * only counts, never a uid or other personal data.
 */
export async function runNpcDataSubjectCount(
  deps: {db?: Firestore; info?: (text: string) => void; error?: (text: string) => void} = {},
): Promise<{count: number}> {
  const db = deps.db ?? getFirestore();
  const info = deps.info ?? ((text: string) => logger.info(text));
  const error = deps.error ?? ((text: string) => logger.error(text));
  const snapshot = await db.collectionGroup('server').where('ageGroup', 'in', ['minor', 'adult']).count().get();
  const count = snapshot.data().count;
  info(`npc data subjects ${count}`);
  if (count >= NPC_ALERT_AT) error(`npc registration threshold near ${count} of ${NPC_REGISTRATION_THRESHOLD}`);
  return {count};
}
