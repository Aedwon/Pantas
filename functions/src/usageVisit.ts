import {logger} from 'firebase-functions';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {enforceAppCheck} from './_appCheck.js';
import {RateLimiter} from './clientTelemetry.js';
import {SCREEN_IDS} from './_screenIds.js';
import {timed} from './_timed.js';

/**
 * Screen views from the web app, sent only by people who chose "Help improve Pantas by sharing
 * usage data". One record is one stretch of one visit: a random visit id made when the page
 * started, and the screens opened with the milliseconds since the visit began. The validator
 * rebuilds the record from known fields only, and the log line never carries the caller's
 * identity, so a record cannot be tied to an account.
 *
 * `SCREEN_IDS`, the closed set of screen names, lives in `_screenIds.ts` and is re-exported here.
 */

export {SCREEN_IDS};

const BUILD = /^[A-Za-z0-9._-]{1,40}$/;
const VISIT_ID = /^[0-9a-f]{16}$/;

const MAX_SCREENS = 100;
const MAX_T = 7 * 24 * 60 * 60 * 1000;

export interface UsageScreen { s: typeof SCREEN_IDS[number]; t: number }
export interface UsageVisit { v: 1; build: string; visit_id: string; screens: UsageScreen[] }

const bad = (what: string): never => {
  throw new HttpsError('invalid-argument', `Invalid usage record: ${what}.`);
};

function record(value: unknown, keys: readonly string[], what: string): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return bad(`${what} must be an object`);
  const object = value as Record<string, unknown>;
  const names = Object.keys(object);
  if (names.length !== keys.length || names.some(name => !keys.includes(name))) return bad(`${what} has wrong keys`);
  return object;
}

/** Throws `invalid-argument` unless `data` matches the contract exactly. Returns a clean copy. */
export function validateUsageVisit(data: unknown): UsageVisit {
  const d = record(data, ['v', 'build', 'visit_id', 'screens'], 'record');
  if (d.v !== 1) bad('v must be 1');
  if (typeof d.build !== 'string' || !BUILD.test(d.build)) bad('build');
  if (typeof d.visit_id !== 'string' || !VISIT_ID.test(d.visit_id)) bad('visit_id');
  if (!Array.isArray(d.screens) || d.screens.length < 1 || d.screens.length > MAX_SCREENS) bad('screens');
  return {
    v: 1,
    build: d.build as string,
    visit_id: d.visit_id as string,
    screens: (d.screens as unknown[]).map(raw => {
      const item = record(raw, ['s', 't'], 'screen');
      if (typeof item.s !== 'string' || !(SCREEN_IDS as readonly string[]).includes(item.s)) bad('screen id');
      if (typeof item.t !== 'number' || !Number.isInteger(item.t) || item.t < 0 || item.t > MAX_T) bad('screen time');
      return {s: item.s as UsageScreen['s'], t: item.t as number};
    }),
  };
}

type Log = (message: string, fields: Record<string, unknown>) => void;

const limiter = new RateLimiter();

export function processUsageVisit(
  auth: {uid: string} | undefined,
  data: unknown,
  deps: {limiter?: RateLimiter; log?: Log; now?: number} = {},
): {ok: true; dropped?: true} {
  if (!auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const visit = validateUsageVisit(data);
  if (!(deps.limiter ?? limiter).allow(auth.uid, deps.now)) return {ok: true, dropped: true};
  (deps.log ?? ((message, fields) => logger.info(message, fields)))('usage_visit', {kind: 'usage_visit', ...visit});
  return {ok: true};
}

export const reportUsageVisit = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('reportUsageVisit', (request: CallableRequest) => processUsageVisit(request.auth, request.data)));
