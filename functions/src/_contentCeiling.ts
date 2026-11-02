import {FieldValue, Timestamp, type Firestore} from 'firebase-admin/firestore';
import {phDay} from './_phDate.js';

/**
 * Daily ceiling on delivered lesson and question documents across ALL accounts. It stops bulk
 * copying that spreads over many accounts, which the per-account limits cannot see.
 * Aedwon approved the design; the value may be tuned.
 */
export const DAILY_DELIVERED_CEILING = 200_000;

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
  /** The sum of all counters for the Philippine day `day`. */
  read: (day: string) => Promise<number>;
  add: (day: string, shard: number, amount: number) => Promise<void>;
};

export type Ceiling = {
  /** False once today's delivered total has reached the ceiling. */
  isOpen: () => Promise<boolean>;
  /** Adds what one call delivered. One write. Never throws. */
  record: (delivered: number) => Promise<void>;
};

export function firestoreCeilingStore(db: Firestore): CeilingStore {
  const shardRef = (day: string, shard: number) =>
    db.collection('contentCeiling').doc(day).collection('shards').doc(String(shard));
  return {
    read: async (day) => {
      const refs = Array.from({length: CEILING_SHARDS}, (_, shard) => shardRef(day, shard));
      const snapshots = await db.getAll(...refs);
      return snapshots.reduce((sum, snapshot) => {
        const value: unknown = snapshot.get('count');
        return sum + (typeof value === 'number' ? value : 0);
      }, 0);
    },
    add: async (day, shard, amount) => {
      // A blind increment: no read, no transaction. `expireAt` lets a TTL policy remove old days.
      await shardRef(day, shard).set({
        count: FieldValue.increment(amount),
        expireAt: Timestamp.fromMillis(Date.now() + 3 * 86_400_000),
      }, {merge: true});
    },
  };
}

export type CeilingOptions = {
  store: CeilingStore;
  limit?: number;
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
  const limit = options.limit ?? configuredCeiling();
  const clock = options.now ?? Date.now;
  const random = options.random ?? Math.random;
  const alert = options.alert ?? ((message: string) => console.error(message));
  let day = '';
  let total = 0;
  let readAt = 0;
  let sinceRead = 0;
  let warned = false;
  let reported = false;

  const refresh = async (): Promise<void> => {
    const now = clock();
    const today = phDay(now);
    if (today !== day) {
      // A first call may follow `record` calls made before any read; they still belong to today.
      if (day !== '') sinceRead = 0;
      day = today;
      total = 0;
      readAt = 0;
      warned = false;
      reported = false;
    }
    const age = now - readAt;
    const fresh = total + sinceRead >= limit * NEAR_FRACTION ? NEAR_FRESH_MS : FRESH_MS;
    if (readAt !== 0 && age < fresh) return;
    total = await options.store.read(day);
    readAt = now;
    sinceRead = 0;
  };

  return {
    isOpen: async () => {
      await refresh();
      const used = total + sinceRead;
      if (!warned && used >= limit * WARN_FRACTION) {
        warned = true;
        alert(`Daily content ceiling reached 80% (${used} of ${limit} ids delivered today).`);
      }
      if (used >= limit) {
        if (!reported) {
          reported = true;
          alert(`Daily content ceiling reached. ${used} of ${limit} ids delivered today; lessons and questions are refused until tomorrow.`);
        }
        return false;
      }
      return true;
    },
    record: async (delivered) => {
      if (delivered <= 0) return;
      sinceRead += delivered;
      try {
        const shard = Math.min(CEILING_SHARDS - 1, Math.floor(random() * CEILING_SHARDS));
        await options.store.add(phDay(clock()), shard, delivered);
      } catch (error) {
        console.error('Daily content ceiling counter could not be written.', error);
      }
    },
  };
}

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
