import {FieldValue, type Firestore, type Transaction} from 'firebase-admin/firestore';
import {claimsForRevenueCatAnswer, type RevenueCatAccessSource} from './revenuecatPolicy.js';
import {livePasses, type Pass} from './revenuecatPasses.js';
import {ledgerGrants, type Grant} from './grants.js';

export type EntitlementInputs = {
  record: FirebaseFirestore.DocumentSnapshot;
  passes: Pass[];
  grants: Map<string, Grant>;
};

/** Reads everything claims depend on besides RevenueCat. All reads precede any write. */
export async function readEntitlementInputs(transaction: Transaction, db: Firestore,
  uid: string): Promise<EntitlementInputs> {
  const [record, passes, grants] = await Promise.all([
    transaction.get(db.doc(`users/${uid}/server/entitlement`)),
    transaction.get(db.collection(`users/${uid}/passes`)),
    transaction.get(db.collection(`users/${uid}/grants`)),
  ]);
  return {record, passes: passes.docs.map(d => d.data() as Pass),
    grants: new Map(grants.docs.map(d => [d.id, d.data() as Grant]))};
}

/** Recomputes pro and proUntil from the stored RevenueCat facts plus passes and grants. */
export function claimsFromInputs(inputs: EntitlementInputs, at: number,
  grants: ReadonlyMap<string, Grant> = inputs.grants) {
  const facts = inputs.record.get('facts') as {sources?: RevenueCatAccessSource[];
    coverageContext?: {appId: string; firebaseProjectId: string; sandboxTester: boolean}} | undefined;
  const context = facts?.coverageContext ?? {appId: '', sandboxTester: false,
    firebaseProjectId: process.env.GCLOUD_PROJECT ?? ''};
  return claimsForRevenueCatAnswer(facts?.sources ?? [], {...context, at,
    passes: livePasses(inputs.passes), grants: ledgerGrants(grants.values())});
}

/** Bumps version and marks the claims copy pending, like the RevenueCat commit. */
export function entitlementWrite(inputs: EntitlementInputs, claims: {pro: boolean; proUntil: number}) {
  const version = Number(inputs.record.get('version') ?? 0) + 1;
  return {...claims, version, claimsPending: true,
    claimsVersion: Number(inputs.record.get('claimsVersion') ?? 0),
    updatedAt: FieldValue.serverTimestamp()};
}
