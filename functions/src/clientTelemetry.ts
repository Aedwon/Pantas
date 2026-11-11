import {createHash} from 'node:crypto';
import {logger} from 'firebase-functions';
import {HttpsError, onCall, type CallableRequest} from 'firebase-functions/v2/https';
import {enforceAppCheck} from './_appCheck.js';
import {timed} from './_timed.js';

/**
 * Speed and error reports from the web app. A report is validated against a fixed contract and
 * written as one structured log line. Nothing is stored in Firestore, and the line never carries
 * the caller's identity: the validator rebuilds the report from known fields only.
 */

const VISITS = ['first', 'return', 'after_deploy'] as const;
const BROWSERS = ['chrome', 'safari', 'firefox', 'edge', 'samsung', 'other'] as const;
const VIEWPORTS = ['phone', 'tablet', 'wide'] as const;

const BUILD = /^[A-Za-z0-9._-]{1,40}$/;
const TIMING_NAME = /^[a-z0-9_.]{1,40}$/;

const MAX_TIMINGS = 40;
const MAX_ERRORS = 10;
const MAX_TIMING_MS = 600000;
const MAX_TYPE = 60;
const MAX_MESSAGE = 300;
const MAX_STACK_FRAMES = 8;
const MAX_STACK_FRAME = 200;
const MAX_COUNT = 1000;

export interface ClientTiming { n: string; ms: number }
export interface ClientError { type: string; msg: string; stack: string[]; count: number }
export interface ClientReport {
  v: 1;
  build: string;
  visit: typeof VISITS[number];
  browser: typeof BROWSERS[number];
  mobile: boolean;
  viewport: typeof VIEWPORTS[number];
  timings: ClientTiming[];
  errors: ClientError[];
}

const bad = (what: string): never => {
  throw new HttpsError('invalid-argument', `Invalid report: ${what}.`);
};

function record(value: unknown, keys: readonly string[], what: string): Record<string, unknown> {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return bad(`${what} must be an object`);
  const object = value as Record<string, unknown>;
  const names = Object.keys(object);
  if (names.length !== keys.length || names.some(name => !keys.includes(name))) return bad(`${what} has wrong keys`);
  return object;
}

function text(value: unknown, what: string, min: number, max: number): string {
  if (typeof value !== 'string' || value.length < min || value.length > max) return bad(what);
  return value;
}

function integer(value: unknown, what: string, min: number, max: number): number {
  if (typeof value !== 'number' || !Number.isInteger(value) || value < min || value > max) return bad(what);
  return value;
}

function choice<T extends string>(value: unknown, allowed: readonly T[], what: string): T {
  if (typeof value !== 'string' || !(allowed as readonly string[]).includes(value)) return bad(what);
  return value as T;
}

function list(value: unknown, max: number, what: string): unknown[] {
  if (!Array.isArray(value) || value.length > max) return bad(what);
  return value;
}

/** Throws `invalid-argument` unless `data` matches the contract exactly. Returns a clean copy. */
export function validateClientReport(data: unknown): ClientReport {
  const d = record(data, ['v', 'build', 'visit', 'browser', 'mobile', 'viewport', 'timings', 'errors'], 'report');
  if (d.v !== 1) bad('v must be 1');
  const build = text(d.build, 'build', 1, 40);
  if (!BUILD.test(build)) bad('build');
  if (typeof d.mobile !== 'boolean') bad('mobile');
  return {
    v: 1,
    build,
    visit: choice(d.visit, VISITS, 'visit'),
    browser: choice(d.browser, BROWSERS, 'browser'),
    mobile: d.mobile as boolean,
    viewport: choice(d.viewport, VIEWPORTS, 'viewport'),
    timings: list(d.timings, MAX_TIMINGS, 'timings').map(raw => {
      const t = record(raw, ['n', 'ms'], 'timing');
      const n = text(t.n, 'timing name', 1, 40);
      if (!TIMING_NAME.test(n)) bad('timing name');
      return {n, ms: integer(t.ms, 'timing ms', 0, MAX_TIMING_MS)};
    }),
    errors: list(d.errors, MAX_ERRORS, 'errors').map(raw => {
      const e = record(raw, ['type', 'msg', 'stack', 'count'], 'error');
      return {
        type: text(e.type, 'error type', 1, MAX_TYPE),
        msg: text(e.msg, 'error msg', 0, MAX_MESSAGE),
        stack: list(e.stack, MAX_STACK_FRAMES, 'error stack').map(frame => text(frame, 'stack frame', 0, MAX_STACK_FRAME)),
        count: integer(e.count, 'error count', 1, MAX_COUNT),
      };
    }),
  };
}

/**
 * Rolling-window limit per caller, kept in this instance's memory. Callers are keyed by a
 * SHA-256 of the uid, so the raw uid is never held. The map never grows past `maxKeys`.
 */
export class RateLimiter {
  private readonly hits = new Map<string, number[]>();

  constructor(
    private readonly limit = 30,
    private readonly windowMs = 60000,
    private readonly maxKeys = 5000,
  ) {}

  get size(): number {
    return this.hits.size;
  }

  keys(): string[] {
    return [...this.hits.keys()];
  }

  /** Records a report and returns true, or returns false when the caller is over the limit. */
  allow(uid: string, now = Date.now()): boolean {
    const key = createHash('sha256').update(uid).digest('hex');
    const recent = (this.hits.get(key) ?? []).filter(at => at > now - this.windowMs);
    const allowed = recent.length < this.limit;
    if (allowed) recent.push(now);
    this.hits.delete(key);
    if (recent.length) this.hits.set(key, recent);
    if (this.hits.size > this.maxKeys) this.prune(now);
    return allowed;
  }

  private prune(now: number): void {
    for (const [key, times] of this.hits) {
      if (times[times.length - 1] <= now - this.windowMs) this.hits.delete(key);
    }
    for (const key of this.hits.keys()) {
      if (this.hits.size <= this.maxKeys) break;
      this.hits.delete(key);
    }
  }
}

type Log = (message: string, fields: Record<string, unknown>) => void;

const limiter = new RateLimiter();

export function processClientReport(
  auth: {uid: string} | undefined,
  data: unknown,
  deps: {limiter?: RateLimiter; log?: Log; now?: number} = {},
): {ok: true; dropped?: true} {
  if (!auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const report = validateClientReport(data);
  if (!(deps.limiter ?? limiter).allow(auth.uid, deps.now)) return {ok: true, dropped: true};
  (deps.log ?? ((message, fields) => logger.info(message, fields)))('client_telemetry', {kind: 'client_telemetry', ...report});
  return {ok: true};
}

export const reportClientTelemetry = onCall({region: 'asia-southeast1', enforceAppCheck: enforceAppCheck},
  timed('reportClientTelemetry', (request: CallableRequest) => processClientReport(request.auth, request.data)));
