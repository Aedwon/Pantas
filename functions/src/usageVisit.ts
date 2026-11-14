import {logger} from 'firebase-functions';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';
import {onAccountCall as onCall} from './_accountAccess.js';
import {enforceAppCheck} from './_appCheck.js';
import {RateLimiter} from './clientTelemetry.js';
import {timed} from './_timed.js';

/**
 * Screen views from the web app, sent only by people who chose "Help improve Pantas by sharing
 * usage data". One record is one stretch of one visit: a random visit id made when the page
 * started, and the screens opened with the milliseconds since the visit began. The validator
 * rebuilds the record from known fields only, and the log line never carries the caller's
 * identity, so a record cannot be tied to an account.
 *
 * `SCREEN_IDS` is the closed set of screen names. It must match `lib/core/telemetry/screen_ids.dart`
 * (a Flutter test compares the two).
 */

export const SCREEN_IDS = [
  'home', 'performance', 'performance_topic', 'plan', 'plan_day', 'plan_history', 'plan_week',
  'record', 'tendencies', 'assessment', 'assessment_results', 'lesson',
  'quiz', 'quiz_all', 'quiz_debrief', 'quiz_flagged', 'quiz_flagged_question', 'quiz_inline',
  'quiz_practice', 'quiz_practice_run', 'quiz_quick', 'quiz_resume', 'quiz_retake', 'quiz_today',
  'quiz_viewer', 'study', 'study_ending',
  'mock_results', 'mock_review', 'mock_custom_setup', 'mock_resume', 'mock_setup',
  'legal', 'pro',
  'settings', 'settings_about', 'settings_accessibility', 'settings_account',
  'settings_adult_check', 'settings_delete_account', 'settings_account_name', 'settings_appearance',
  'settings_backup', 'settings_beta_feedback', 'settings_beta_feedback_sent',
  'settings_beta_survey', 'settings_exam', 'settings_exam_change', 'settings_exam_custom_name',
  'settings_exam_custom_subjects', 'settings_exam_included', 'settings_exam_transfer',
  'settings_exam_upgrade', 'settings_practice',
  'auth_email_link', 'beta', 'guardian', 'guardian_contact', 'guardian_manage',
  'guardian_waiting', 'guardian_withdrawn', 'onboarding', 'onboarding_custom_name',
  'onboarding_custom_subjects', 'update_required', 'wrapped', 'other',
] as const;

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
