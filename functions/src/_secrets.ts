import {defineSecret} from 'firebase-functions/params';
import {HttpsError} from 'firebase-functions/v2/https';

/**
 * Two Secret Manager secrets per project (Fable 5.2 rule 7 ruling 1, split on Nov 17: each active
 * version costs $0.06 a month after 6 free per billing account). Each value is a JSON object with the
 * keys of its group. A function declares only the group it reads. Only web checkout and the two
 * webhooks bind the payment group (test: secrets.test.mjs). docs/secrets-merge.md lists the keys.
 */
export const paymentSecrets = defineSecret('PANTAS_PAYMENT_SECRETS');
export const appSecrets = defineSecret('PANTAS_APP_SECRETS');

export const SECRET_GROUPS = {
  PANTAS_PAYMENT_SECRETS: [
    'PAYMONGO_SECRET_KEY',
    'PAYMONGO_WEBHOOK_SECRET',
    'REVENUECAT_SECRET_API_KEY',
    'REVENUECAT_WEBHOOK_SECRET',
  ],
  PANTAS_APP_SECRETS: [
    'TRIAL_IDENTITY_HMAC_KEY',
    'GUARDIAN_HMAC_KEY',
    'GUARDIAN_MAIL_API_KEY',
    'SIGN_IN_CODE_KEY',
  ],
} as const;
export type SecretKey = typeof SECRET_GROUPS[keyof typeof SECRET_GROUPS][number];
export const SECRET_KEYS: readonly SecretKey[] = [...SECRET_GROUPS.PANTAS_PAYMENT_SECRETS, ...SECRET_GROUPS.PANTAS_APP_SECRETS];

const PAYMENT_KEYS: readonly string[] = SECRET_GROUPS.PANTAS_PAYMENT_SECRETS;

// Parsed once per instance and per raw value; a rotated secret reaches a new instance with a new raw value.
const parsed: Record<string, {raw: string; values: Record<string, unknown> | null}> = {};

function unavailable(reason: string): HttpsError {
  // Never put a value, or the parser's own message (it can quote the text), in the error.
  return new HttpsError('failed-precondition', reason);
}

function load(group: string, raw: string): Record<string, unknown> | null {
  if (parsed[group]?.raw === raw) return parsed[group].values;
  let values: Record<string, unknown> | null = null;
  try {
    const json: unknown = JSON.parse(raw);
    if (json !== null && typeof json === 'object' && !Array.isArray(json)) values = json as Record<string, unknown>;
  } catch {
    values = null;
  }
  parsed[group] = {raw, values};
  return values;
}

/**
 * One secret value by key. A missing or empty key, a value that is not text, or an unset or invalid
 * group secret throws for this call; nothing falls back to another value. `emulatorStandIn` is for the
 * local emulator only, and only when the key is absent: invalid JSON still throws there.
 */
export function secret(key: SecretKey, options: {emulatorStandIn?: string} = {}): string {
  const group = PAYMENT_KEYS.includes(key) ? 'PANTAS_PAYMENT_SECRETS' : 'PANTAS_APP_SECRETS';
  const raw = (group === 'PANTAS_PAYMENT_SECRETS' ? paymentSecrets : appSecrets).value() ?? '';
  const emulator = process.env.FUNCTIONS_EMULATOR === 'true';
  if (!raw) {
    if (emulator && options.emulatorStandIn) return options.emulatorStandIn;
    throw unavailable('Secrets are not configured.');
  }
  const values = load(group, raw);
  if (!values) throw unavailable('Secrets are not readable.');
  const value = values[key];
  if (typeof value === 'string' && value !== '') return value;
  if (emulator && options.emulatorStandIn && (value === undefined || value === '')) return options.emulatorStandIn;
  throw unavailable(`Secret ${key} is not configured.`);
}
