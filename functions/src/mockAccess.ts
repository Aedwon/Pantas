import type {Firestore, Transaction} from 'firebase-admin/firestore';
import {readEntitlementInputs} from './entitlementInputs.js';
import {ledgerGrants} from './grants.js';
import {coverageForRevenueCatAnswer, type RevenueCatAccessSource} from './revenuecatPolicy.js';
import {examCatalog, livePasses} from './revenuecatPasses.js';
import type {PriceTier} from './revenuecatCoverage.js';

const tiers: Record<string, PriceTier> = {'Student': 'student', 'Civil Service': 'civilService', 'Licensure': 'licensure', 'PSHS-NCE': 'nce'};
/** One current, exam-specific server decision shared by mock starts and readers. */
export async function mockCoverage(transaction: Transaction, db: Firestore, uid: string, now: number) {
  const inputs = await readEntitlementInputs(transaction, db, uid);
  const facts = inputs.record.get('facts') as {sources?: RevenueCatAccessSource[];
    coverageContext?: {appId: string; firebaseProjectId: string; sandboxTester: boolean}} | undefined;
  const context = facts?.coverageContext ?? {appId: '', firebaseProjectId: process.env.GCLOUD_PROJECT ?? '', sandboxTester: false};
  const access = coverageForRevenueCatAnswer(facts?.sources ?? [], {...context, at: now,
    passes: livePasses(inputs.passes), grants: ledgerGrants(inputs.grants.values())});
  // Recheck at the next ledger transition, independently of the device clock.
  const transitions = [
    ...inputs.passes.filter(p => p.state === 'active').map(p => p.endsAt),
    ...[...inputs.grants.values()].filter(g => g.state === 'active').flatMap(g => [g.startsAt, g.endsAt]),
    ...(facts?.sources ?? []).filter(s => s.active).map(s => s.endsAt),
  ].filter(at => Number.isFinite(at) && at > now);
  return {recheckAt: transitions.length ? Math.min(...transitions) : null,
    coversExam: (examId: string): boolean => {
    const entry = examCatalog.find(e => e.id === examId) as {priceTier?: string} | undefined;
    const tier = entry?.priceTier ? tiers[entry.priceTier] : undefined;
      return tier !== undefined && access.coversExam(examId, tier);
    }};
}
