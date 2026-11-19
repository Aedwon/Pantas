import type {Firestore} from 'firebase-admin/firestore';

/**
 * The server-only link between a holder (the parent or guardian's sign-in) and its child accounts.
 * Task T2 (child setup) writes these documents; the guardian code gate and later child callables read
 * them here, so the paths live in one place.
 *
 *   users/{holderUid}/server/children/items/{childUid}
 *       {childUid, nickname, active, siblingOpenWithoutCode, createdAt}
 *   users/{childUid}/server/childLink
 *       {holderUid}
 *
 * The collection sits under `server/children` (a document) because a document cannot have the odd-length
 * path `users/{holderUid}/server/children/{childUid}`. Firestore rules deny every client read and write
 * under `users/{uid}/server`.
 */
export type ChildLink = {
  childUid: string;
  nickname: string;
  active: boolean;
  siblingOpenWithoutCode: boolean;
  createdAt: number;
};

type Reader = Pick<Firestore, 'doc' | 'collection'>;

/** T2 may store a number or a Firestore timestamp. */
const millis = (value: unknown): number => {
  if (typeof value === 'number') return value;
  const toMillis = (value as {toMillis?: unknown} | null | undefined)?.toMillis;
  return typeof toMillis === 'function' ? Number(toMillis.call(value)) : 0;
};

const UID = /^[^/\s]{1,128}$/;

export const childLinkPath = (childUid: string): string => `users/${childUid}/server/childLink`;
export const childrenPath = (holderUid: string): string => `users/${holderUid}/server/children/items`;
export const childEntryPath = (holderUid: string, childUid: string): string => `${childrenPath(holderUid)}/${childUid}`;

/**
 * The holder of an active linked child, or null. Both sides must agree: the child's link names the
 * holder, and the holder's list holds an active entry for that child. Anything else is "not linked".
 */
export async function holderForChild(db: Reader, childUid: string): Promise<string | null> {
  if (!UID.test(childUid)) return null;
  const link = await db.doc(childLinkPath(childUid)).get();
  const holderUid: unknown = link.get('holderUid');
  if (typeof holderUid !== 'string' || !UID.test(holderUid)) return null;
  const entry = await db.doc(childEntryPath(holderUid, childUid)).get();
  return entry.exists && entry.get('active') === true ? holderUid : null;
}

/** The holder's active children. */
export async function childrenOfHolder(db: Reader, holderUid: string): Promise<ChildLink[]> {
  if (!UID.test(holderUid)) return [];
  const rows = await db.collection(childrenPath(holderUid)).get();
  const children: ChildLink[] = [];
  for (const row of rows.docs) {
    const nickname: unknown = row.get('nickname');
    if (row.get('active') !== true || typeof nickname !== 'string') continue;
    children.push({childUid: row.id, nickname, active: true,
      siblingOpenWithoutCode: row.get('siblingOpenWithoutCode') === true,
      createdAt: millis(row.get('createdAt'))});
  }
  return children;
}
