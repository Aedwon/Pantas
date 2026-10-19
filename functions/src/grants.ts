import type {LedgerGrant, PriceTier} from './revenuecatCoverage.js';

/** One row of users/{uid}/grants/{grantId}. Server-only writes; the owner may read. */
export interface Grant {
  source: 'paymongo' | 'trial';
  product: string;
  tier: PriceTier;
  startsAt: number;
  endsAt: number;
  paymentId?: string;
  /** Centavos paid (paymongo only). Needed to size partial refunds. */
  paidAmount?: number;
  /** Refund id to centavos. Keyed by id so a replayed refund changes nothing. */
  refunds?: Record<string, number>;
  /** End before any refund; endsAt is this shortened by the refunded share. */
  fullEndsAt?: number;
  state: 'active' | 'revoked';
  createdAt: number;
}

export const TRIAL_PRODUCT = 'web_trial';
export const TRIAL_DAYS = 7;
export const DAY_MS = 86_400_000;
export const TIER_ORDER: PriceTier[] = ['student', 'civilService', 'licensure', 'nce'];

export const ledgerGrants = (rows: Iterable<Grant>): LedgerGrant[] =>
  [...rows].map(g => ({source: g.source, product: g.product, tier: g.tier,
    startsAt: g.startsAt, endsAt: g.endsAt, active: g.state === 'active'}));
