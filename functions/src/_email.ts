// Providers whose `+tag` addresses reach the same mailbox. Elsewhere a plus sign may be a real,
// different address, so those domains are only lowercased and trimmed.
const PLUS_DOMAINS = new Set(['gmail.com', 'googlemail.com', 'outlook.com', 'hotmail.com', 'live.com',
  'icloud.com', 'me.com', 'mac.com', 'proton.me', 'protonmail.com']);

/**
 * An address reduced to one form per mailbox, for abuse keys only (trial markers and send limits).
 * Never use it as the account's email or as the address to send to: the exact normalized
 * (lowercase) address does that. For the providers above it strips a `+tag`, and for Gmail it also
 * removes dots and maps googlemail.com to gmail.com.
 */
export function canonicalEmail(value: string): string {
  const email = value.trim().toLowerCase();
  const at = email.lastIndexOf('@');
  if (at < 1) return email;
  let local = email.slice(0, at);
  let domain = email.slice(at + 1);
  if (domain === 'googlemail.com') domain = 'gmail.com';
  if (!PLUS_DOMAINS.has(domain)) return email;
  const plus = local.indexOf('+');
  if (plus > 0) local = local.slice(0, plus);
  if (domain === 'gmail.com') local = local.replaceAll('.', '') || local;
  return `${local}@${domain}`;
}
