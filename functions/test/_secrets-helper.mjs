// A test PANTAS_SECRETS value: the one Functions secret, a JSON object with every key the code reads.
export const TEST_SECRETS = {
  REVENUECAT_SECRET_API_KEY: 'test-revenuecat-api-key',
  REVENUECAT_WEBHOOK_SECRET: 'test-revenuecat-webhook-secret',
  TRIAL_IDENTITY_HMAC_KEY: 'test-trial-identity-hmac-key',
  GUARDIAN_HMAC_KEY: 'test-guardian-hmac-key',
  GUARDIAN_MAIL_API_KEY: 'test-guardian-mail-api-key',
  PAYMONGO_SECRET_KEY: 'test-paymongo-secret-key',
  PAYMONGO_WEBHOOK_SECRET: 'test-paymongo-webhook-secret',
  SIGN_IN_CODE_KEY: 'test-sign-in-code-key',
};

/** Sets process.env.PANTAS_SECRETS to the test object, with optional per-key overrides (undefined removes a key). */
export function setTestSecrets(overrides = {}) {
  const value = {...TEST_SECRETS, ...overrides};
  for (const key of Object.keys(value)) if (value[key] === undefined) delete value[key];
  process.env.PANTAS_SECRETS = JSON.stringify(value);
  return value;
}
