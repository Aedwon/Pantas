/**
 * True only for a live Pro claim: the same test as `hasLivePro()` in firestore.rules.
 * The claim comes from the verified ID token the server wrote; the app never sets it.
 */
export function hasLiveProClaim(token: {pro?: unknown; proUntil?: unknown} | undefined, now: number): boolean {
  return token?.pro === true && typeof token.proUntil === 'number' && token.proUntil > now;
}
