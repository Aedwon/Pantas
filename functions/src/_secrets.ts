import {defineSecret} from 'firebase-functions/params';
import {HttpsError} from 'firebase-functions/v2/https';

/**
 * The project's one Secret Manager secret (Fable 5.2 rule 7 ruling 1: each active version costs
 * $0.06 a month after 6 free per billing account). Its value is a JSON object with the keys below.
 * A function that reads any key declares `secrets: [pantasSecrets]`; docs/secrets-merge.md lists the keys.
 */
export const pantasSecrets = defineSecret('PANTAS_SECRETS');

export const SECRET_KEYS = [
  'REVENUECAT_SECRET_API_KEY',
  'REVENUECAT_WEBHOOK_SECRET',
  'TRIAL_IDENTITY_HMAC_KEY',
  'GUARDIAN_HMAC_KEY',
  'GUARDIAN_MAIL_API_KEY',
  'PAYMONGO_SECRET_KEY',
  'PAYMONGO_WEBHOOK_SECRET',
  'SIGN_IN_CODE_KEY',
] as const;
export type SecretKey = typeof SECRET_KEYS[number];

// Parsed once per instance and per raw value; a rotated secret reaches a new instance with a new raw value.
let parsed: {raw: string; values: Record<string, unknown> | null} | undefined;

function unavailable(reason: string): HttpsError {
  // Never put a value, or the parser's own message (it can quote the text), in the error.
  return new HttpsError('failed-precondition', reason);
}

function load(raw: string): Record<string, unknown> | null {
  if (parsed?.raw === raw) return parsed.values;
  let values: Record<string, unknown> | null = null;
  try {
    const json: unknown = JSON.parse(raw);
    if (json !== null && typeof json === 'object' && !Array.isArray(json)) values = json as Record<string, unknown>;
  } catch {
    values = null;
  }
  parsed = {raw, values};
  return values;
}

/**
 * One secret value by key. A missing or empty key, a value that is not text, or an unset or invalid
 * PANTAS_SECRETS throws for this call; nothing falls back to another value. `emulatorStandIn` is for the
 * local emulator only, and only when the key is absent: invalid JSON still throws there.
 */
export function secret(key: SecretKey, options: {emulatorStandIn?: string} = {}): string {
  const raw = pantasSecrets.value() ?? '';
  const emulator = process.env.FUNCTIONS_EMULATOR === 'true';
  if (!raw) {
    if (emulator && options.emulatorStandIn) return options.emulatorStandIn;
    throw unavailable('Secrets are not configured.');
  }
  const values = load(raw);
  if (!values) throw unavailable('Secrets are not readable.');
  const value = values[key];
  if (typeof value === 'string' && value !== '') return value;
  if (emulator && options.emulatorStandIn && (value === undefined || value === '')) return options.emulatorStandIn;
  throw unavailable(`Secret ${key} is not configured.`);
}
