/**
 * Age groups the server records. Only `adult` is unrestricted. Every check that today asks "is this a
 * minor" asks this instead, so `child` and any unknown or malformed value are restricted by default.
 */
export type AgeGroup = 'adult' | 'minor' | 'child';

export const isRestrictedAgeGroup = (value: unknown): boolean => value !== 'adult';

/** A known group as it is, anything else as `minor`: at least as strict as a teen account. */
export const normalizeAgeGroup = (value: unknown): AgeGroup =>
  value === 'adult' || value === 'minor' || value === 'child' ? value : 'minor';
