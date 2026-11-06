/**
 * An address reduced to one form per mailbox, for abuse keys only (trial markers and send limits).
 * Never use it as the account's email or as the address to send to: the exact normalized
 * (lowercase) address does that. Strips a `+tag` from the local part for every domain, and for
 * Gmail also removes dots and maps googlemail.com to gmail.com.
 */
export function canonicalEmail(value: string): string {
  const email = value.trim().toLowerCase();
  const at = email.lastIndexOf('@');
  if (at < 1) return email;
  let local = email.slice(0, at);
  let domain = email.slice(at + 1);
  const plus = local.indexOf('+');
  if (plus > 0) local = local.slice(0, plus);
  if (domain === 'googlemail.com') domain = 'gmail.com';
  if (domain === 'gmail.com') local = local.replaceAll('.', '') || local;
  return `${local}@${domain}`;
}
