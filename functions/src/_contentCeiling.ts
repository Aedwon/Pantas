import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {phDay} from './_phDate.js';

/**
 * Daily ceiling on delivered lesson and question documents across ALL accounts. It stops bulk
 * copying that spreads over many accounts, which the per-account limits cannot see.
 * Aedwon approved the design; the value may be tuned.
 */
export const DAILY_DELIVERED_CEILING = 200_000;

/**
 * A second, separate daily pool for anonymous accounts and accounts made in the last 24 hours.
 * Throwaway accounts are free to make, so bulk copying uses them. They draw only on this pool,
 * and named accounts older than a day draw only on the main pool above, so a full new-account
 * pool cannot block them. The two add up to at most 250,000 ids a day.
 */
export const DAILY_NEW_ACCOUNT_CEILING = 50_000;
/** An account younger than this draws on the new-account pool. */
export const NEW_ACCOUNT_AGE_MS = 86_400_000;
export type CeilingPool = 'main' | 'new';

/** The pool a caller draws on. An unknown account age counts as new, the stricter choice. */
export function contentPool(caller: {anonymous: boolean; createdAt: number | null; now: number}): CeilingPool {
  if (caller.anonymous || caller.createdAt === null) return 'new';
  return caller.now - caller.createdAt < NEW_ACCOUNT_AGE_MS ? 'new' : 'main';
}

/** `DAILY_NEW_ACCOUNT_CONTENT_CEILING` in `functions/.env` overrides the new-account pool. */
export function configuredNewAccountCeiling(env: NodeJS.ProcessEnv = process.env): number {
  const value = Number.parseInt(env.DAILY_NEW_ACCOUNT_CONTENT_CEILING ?? '', 10);
  return Number.isFinite(value) && value > 0 ? value : DAILY_NEW_ACCOUNT_CEILING;
}

/**
 * The value in force. `DAILY_CONTENT_CEILING` in `functions/.env` overrides it at the next
 * deploy, for a manual raise or lowering without a code change. Read when an instance starts.
 */
export function configuredCeiling(env: NodeJS.ProcessEnv = process.env): number {
  const value = Number.parseInt(env.DAILY_CONTENT_CEILING ?? '', 10);
  return Number.isFinite(value) && value > 0 ? value : DAILY_DELIVERED_CEILING;
}

/**
 * The total is split over this many counter documents. One document takes about one write a
 * second, and the ceiling adds one write for every call that delivers anything, so a single
 * counter would be the limit on content traffic.
 */
export const CEILING_SHARDS = 50;

/** How long an instance trusts its last read of the total. */
const FRESH_MS = 30_000;
/** Once the total passes 90% the read is repeated this often, to keep the overshoot small. */
const NEAR_FRESH_MS = 2_000;
const NEAR_FRACTION = 0.9;
const WARN_FRACTION = 0.8;

export type CeilingStore = {
  /** The sum of all counters of `pool` for the Philippine day `day`. */
  read: (day: string, pool?: CeilingPool) => Promise<number>;
  add: (day: string, shard: number, amount: number, pool?: CeilingPool) => Promise<void>;
};

export type Ceiling = {
  /** False once today's delivered total of `pool` (default the main pool) has reached its ceiling. */
  isOpen: (pool?: CeilingPool) => Promise<boolean>;
  /** Adds what one call delivered to `pool`. One write. Never throws. */
  record: (delivered: number, pool?: CeilingPool) => Promise<void>;
};

export function firestoreCeilingStore(db: Firestore): CeilingStore {
  // The main pool keeps its original documents. The new-account pool has its own day document.
  const shardRef = (day: string, shard: number, pool: CeilingPool) =>
    db.collection('contentCeiling').doc(pool === 'new' ? `${day}-new` : day).collection('shards').doc(String(shard));
  return {
    read: async (day, pool = 'main') => {
      const refs = Array.from({length: CEILING_SHARDS}, (_, shard) => shardRef(day, shard, pool));
      const snapshots = await db.getAll(...refs);
      return snapshots.reduce((sum, snapshot) => {
        const value: unknown = snapshot.get('count');
        return sum + (typeof value === 'number' ? value : 0);
      }, 0);
    },
    add: async (day, shard, amount, pool = 'main') => {
      // A blind increment: no read, no transaction. `purgeAfter` is the field for the TTL policy
      // on the `shards` collection group, which covers both pools.
      await shardRef(day, shard, pool).set({
        count: FieldValue.increment(amount),
        purgeAfter: Timestamp.fromMillis(Date.now() + 3 * 86_400_000),
      }, {merge: true});
    },
  };
}

export type CeilingOptions = {
  store: CeilingStore;
  limit?: number;
  /** The new-account pool's ceiling. */
  newAccountLimit?: number;
  now?: () => number;
  random?: () => number;
  /** Logs an alertable line. Defaults to `console.error`, as the guardian email cap does. */
  alert?: (message: string) => void;
};

/**
 * Reading the total is cached in the instance, and what this instance delivers since the read is
 * added to it. The ceiling can still be passed by what OTHER instances deliver while this one
 * trusts its cache. Near the ceiling that window is 2 seconds, so the overshoot is bounded by
 * the other instances' deliveries in 2 seconds: at most 9 other instances x about 13 calls x 20
 * ids, roughly 2,500 ids (about 1.3%).
 */
export function createCeiling(options: CeilingOptions): Ceiling {
  const limits: Record<CeilingPool, number> = {
    main: options.limit ?? configuredCeiling(),
    new: options.newAccountLimit ?? configuredNewAccountCeiling(),
  };
  const labels: Record<CeilingPool, string> = {main: 'Daily content ceiling', new: 'Daily new-account content ceiling'};
  const clock = options.now ?? Date.now;
  const random = options.random ?? Math.random;
  const alert = options.alert ?? ((message: string) => console.error(message));
  const pools: Record<CeilingPool, PoolState> = {main: freshPool(), new: freshPool()};

  const refresh = async (pool: CeilingPool): Promise<void> => {
    const state = pools[pool];
    const limit = limits[pool];
    const now = clock();
    const today = phDay(now);
    if (today !== state.day) {
      // A first call may follow `record` calls made before any read; they still belong to today.
      const carried = state.day === '' ? state.sinceRead : 0;
      Object.assign(state, freshPool(), {day: today, sinceRead: carried});
    }
    const age = now - state.readAt;
    const fresh = state.total + state.sinceRead >= limit * NEAR_FRACTION ? NEAR_FRESH_MS : FRESH_MS;
    if (state.readAt !== 0 && age < fresh) return;
    state.total = await options.store.read(state.day, pool);
    state.readAt = now;
    state.sinceRead = 0;
  };

  return {
    isOpen: async (pool = 'main') => {
      await refresh(pool);
      const state = pools[pool];
      const limit = limits[pool];
      const used = state.total + state.sinceRead;
      if (!state.warned && used >= limit * WARN_FRACTION) {
        state.warned = true;
        alert(`${labels[pool]} reached 80% (${used} of ${limit} ids delivered today).`);
      }
      if (used >= limit) {
        if (!state.reported) {
          state.reported = true;
          alert(`${labels[pool]} reached. ${used} of ${limit} ids delivered today; lessons and questions are refused until tomorrow.`);
        }
        return false;
      }
      return true;
    },
    record: async (delivered, pool = 'main') => {
      if (delivered <= 0) return;
      pools[pool].sinceRead += delivered;
      try {
        const shard = Math.min(CEILING_SHARDS - 1, Math.floor(random() * CEILING_SHARDS));
        await options.store.add(phDay(clock()), shard, delivered, pool);
      } catch (error) {
        console.error('Daily content ceiling counter could not be written.', error);
      }
    },
  };
}

type PoolState = {day: string; total: number; readAt: number; sinceRead: number; warned: boolean; reported: boolean};
const freshPool = (): PoolState => ({day: '', total: 0, readAt: 0, sinceRead: 0, warned: false, reported: false});

const shared = new WeakMap<Firestore, Ceiling>();

/** One ceiling per Firestore instance, so the cache is shared by every call in the instance. */
export function sharedCeiling(db: Firestore): Ceiling {
  let ceiling = shared.get(db);
  if (!ceiling) {
    ceiling = createCeiling({store: firestoreCeilingStore(db)});
    shared.set(db, ceiling);
  }
  return ceiling;
}
