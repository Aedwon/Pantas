import type {Sitting} from './revenuecatPasses.js';
import type {LedgerGrant, PriceTier} from './revenuecatCoverage.js';

/** One row of users/{uid}/grants/{grantId}. Server-only writes; the owner may read. */
export interface Grant {
  source: 'paymongo' | 'trial';
  product: string;
  tier: PriceTier;
  startsAt: number;
  endsAt: number;
  paymentId?: string;
  paidAt?: number;
  examId?: string;
  sitting?: Sitting;
  unusedDuplicateOf?: string;
  /** Set when a payment can never give access (for example paid after its sitting ended). */
  unusableReason?: string;
  revokedReason?: string;
  disputeId?: string;
  disputeResolved?: boolean;
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

/** Remaining length is the original length times (1 - refunded/paid), from startsAt, floored to the second. */
export function shortenedEnd(startsAt: number, fullEndsAt: number, refunded: number, paid: number): number {
  if (refunded <= 0) return fullEndsAt;
  const ms = Math.floor((fullEndsAt - startsAt) * Math.max(paid - refunded, 0) / paid);
  return startsAt + Math.floor(ms / 1000) * 1000;
}
