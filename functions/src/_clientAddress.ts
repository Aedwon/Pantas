import {createHmac} from 'node:crypto';
import {isIP} from 'node:net';
import type {Firestore} from 'firebase-admin/firestore';

/** What a callable needs of its request to tell clients apart. */
export type AddressRequest = {
  rawRequest?: {ip?: string; headers?: Record<string, string | string[] | undefined>};
};

/**
 * The bucket one client address belongs to, or null when the text is not an address. IPv4 is kept
 * whole. IPv6 is cut to its /64 prefix, because one subscriber usually holds a whole /64 and could
 * otherwise rotate through billions of addresses. An IPv4-mapped IPv6 address is its IPv4 address.
 */
export function addressBucket(raw: string): string | null {
  const text = raw.trim().replace(/%.*$/, '').toLowerCase();
  const family = isIP(text);
  if (family === 4) return `v4:${text}`;
  if (family !== 6) return null;
  let rest = text;
  const tail = /(\d+)\.(\d+)\.(\d+)\.(\d+)$/.exec(rest);
  if (tail) {
    const [a, b, c, d] = tail.slice(1).map(Number) as [number, number, number, number];
    rest = `${rest.slice(0, tail.index)}${((a << 8) | b).toString(16)}:${((c << 8) | d).toString(16)}`;
  }
  const halves = rest.split('::');
  const left = halves[0] ? halves[0].split(':') : [];
  const right = halves[1] ? halves[1].split(':') : [];
  const groups = halves.length === 2 ?
    [...left, ...new Array<string>(8 - left.length - right.length).fill('0'), ...right] : left;
  const words = groups.map(group => parseInt(group, 16));
  if (words.length !== 8 || words.some(word => !Number.isInteger(word))) return null;
  if (words.slice(0, 5).every(word => word === 0) && words[5] === 0xffff) {
    return `v4:${words[6]! >> 8}.${words[6]! & 255}.${words[7]! >> 8}.${words[7]! & 255}`;
  }
  return `v6:${words.slice(0, 4).map(word => word.toString(16)).join(':')}`;
}

/**
 * The caller's address bucket. Google's front end appends the address it saw to `X-Forwarded-For`,
 * so the right-most entry is the only one the caller cannot choose; anything to its left is
 * client-supplied. With no usable header the connection address is used, and with neither the call
 * falls into one shared "unknown" bucket, so a missing address never skips the limit.
 */
export function clientBucket(request: AddressRequest): string {
  const header = request.rawRequest?.headers?.['x-forwarded-for'];
  const entries = (Array.isArray(header) ? header.join(',') : header ?? '').split(',')
    .map(entry => entry.trim()).filter(Boolean);
  const forwarded = entries.length > 0 ? addressBucket(entries[entries.length - 1]!) : null;
  const direct = request.rawRequest?.ip ? addressBucket(request.rawRequest.ip) : null;
  return forwarded ?? direct ?? 'unknown';
}


/**
 * One counting window per client address bucket, under a keyed hash so the address is never stored.
 * Returns false once `max` calls have been counted in the window. Each caller names its own `scope`
 * so its counters stay apart from the others.
 */
export async function allowFromAddress(db: Firestore, key: string, scope: string, bucket: string, at: number,
  max: number, windowMs: number): Promise<boolean> {
  const ref = db.doc(`${scope}-${createHmac('sha256', key).update(`${scope}\0${bucket}`).digest('hex')}`);
  return db.runTransaction(async transaction => {
    const snapshot = await transaction.get(ref);
    const startedAtValue: unknown = snapshot.get('windowStartedAt');
    const startedAt = typeof startedAtValue === 'number' ? startedAtValue : 0;
    const inWindow = startedAt > 0 && at - startedAt < windowMs;
    const count = inWindow ? Number(snapshot.get('count') ?? 0) : 0;
    if (count >= max) return false;
    transaction.set(ref, {windowStartedAt: inWindow ? startedAt : at, count: count + 1,
      purgeAt: new Date(at + 2 * windowMs), cleanupAt: at + 2 * windowMs});
    return true;
  });
}
