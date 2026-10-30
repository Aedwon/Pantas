import {readFileSync} from 'node:fs';
import {join} from 'node:path';

export type PriceTier = 'student' | 'civilService' | 'licensure' | 'nce';
export interface CoveragePeriod {id: string; endsAt: number; active: boolean}
// Trusted server ledger input only. Task 5 owns reading records in its transaction.
export interface LedgerPass {examId: string; endsAt: number; active: boolean}
// Server-owned grant ledger input (PayMongo purchases and the web trial).
export interface LedgerGrant {source: 'paymongo' | 'trial' | 'beta'; examId?: string; product: string; tier: PriceTier;
  startsAt: number; endsAt: number; active: boolean}
type Product = {id: string; kind: string; tier: PriceTier; examId?: string | null};
const products = JSON.parse(readFileSync(join(__dirname, 'products.json'), 'utf8')) as Product[];
const tiers: PriceTier[] = ['student', 'civilService', 'licensure', 'nce'];
const higher = (a: PriceTier | null, b: PriceTier): PriceTier =>
  a === null || tiers.indexOf(b) > tiers.indexOf(a) ? b : a;

export function coverageAt(input: {
  at: number; subscriptions?: readonly CoveragePeriod[];
  promotions?: readonly CoveragePeriod[]; passes?: readonly LedgerPass[];
  grants?: readonly LedgerGrant[];
  nonSubscriptionPurchases?: readonly CoveragePeriod[]; onUnknown?: (id: string) => void;
}) {
  let subscriptionTier: PriceTier | null = null;
  let grantTier: PriceTier | null = null;
  let endsAt: number | null = null;
  let graceEndsAt = 0;
  let hasUnknown = false;
  const passes = new Map<string, number>();
  const logUnknown = input.onUnknown ?? (id => console.info('Unknown payment item', {id}));
  const live = (source: {active: boolean; endsAt: number}) =>
    source.active && Number.isFinite(source.endsAt) && source.endsAt > input.at;
  const includeEnd = (end: number, grace = true) => {
    endsAt = Math.max(endsAt ?? end, end);
    if (grace) graceEndsAt = Math.max(graceEndsAt, end);
  };
  const include = (sources: readonly CoveragePeriod[], kind: string) => {
    for (const source of sources) {
      if (!live(source)) continue;
      const product = products.find(p => p.id === source.id);
      if (!product) {hasUnknown = true; logUnknown(source.id); continue;}
      if (product.kind !== kind) continue;
      if (kind === 'subscription') subscriptionTier = higher(subscriptionTier, product.tier);
      else grantTier = higher(grantTier, product.tier);
      includeEnd(source.endsAt);
    }
  };
  include(input.subscriptions ?? [], 'subscription');
  include(input.promotions ?? [], 'promotional');
  for (const pass of input.passes ?? []) {
    if (!live(pass)) continue;
    passes.set(pass.examId, Math.max(passes.get(pass.examId) ?? pass.endsAt, pass.endsAt));
    includeEnd(pass.endsAt);
  }
  // A grant covers only [startsAt, endsAt).
  for (const grant of input.grants ?? []) {
    if (!live(grant) || !(grant.startsAt <= input.at)) continue;
    if (grant.source === 'beta') {
      if (!grant.examId) continue;
      passes.set(grant.examId, Math.max(passes.get(grant.examId) ?? 0, grant.endsAt));
      includeEnd(grant.endsAt, false);
      continue;
    }
    if (grant.source === 'trial') {
      if (!tiers.includes(grant.tier)) {hasUnknown = true; logUnknown(grant.product); continue;}
      grantTier = higher(grantTier, grant.tier);
      includeEnd(grant.endsAt);
      continue;
    }
    const product = products.find(p => p.id === grant.product);
    if (!product) {hasUnknown = true; logUnknown(grant.product); continue;}
    if (product.kind === 'subscription') {
      subscriptionTier = higher(subscriptionTier, product.tier);
      includeEnd(grant.endsAt);
    } else if (product.kind === 'pass' && product.examId) {
      passes.set(product.examId, Math.max(passes.get(product.examId) ?? grant.endsAt, grant.endsAt));
      includeEnd(grant.endsAt);
    }
  }
  // Stacked prepaid grants that start where the live chain ends extend its end (the
  // claim expiry), so access does not lapse at the first grant. A gap breaks the chain.
  if (endsAt !== null) {
    const chainable = (g: LedgerGrant) => g.source === 'trial' ||
      products.find(p => p.id === g.product)?.kind === 'subscription';
    const ahead = (input.grants ?? []).filter(g => g.active && g.startsAt > input.at && g.endsAt > g.startsAt &&
      Number.isFinite(g.endsAt) && chainable(g)).sort((a, b) => a.startsAt - b.startsAt);
    for (const g of ahead) if (g.startsAt <= endsAt) includeEnd(g.endsAt);
  }
  for (const purchase of input.nonSubscriptionPurchases ?? []) {
    if (!products.some(p => p.id === purchase.id)) logUnknown(purchase.id);
  }
  const tier = subscriptionTier === null ? grantTier : grantTier === null
    ? subscriptionTier : higher(subscriptionTier, grantTier);
  return {
    subscriptionTier, grantTier, tier, passes, endsAt, graceEndsAt,
    hasKnownCoverage: tier !== null || passes.size > 0,
    isUnknown: hasUnknown && tier === null && passes.size === 0,
    coversExam: (examId: string, requested: PriceTier): boolean => passes.has(examId) ||
      (tier !== null && (tier === 'nce' ? requested === 'nce' :
        requested !== 'nce' && tiers.indexOf(tier) >= tiers.indexOf(requested))),
  };
}
