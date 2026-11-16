// Test values for the two Functions secrets. Each is a JSON object with the keys of its group.
export const PAYMENT_GROUP = 'PANTAS_PAYMENT_SECRETS';
export const APP_GROUP = 'PANTAS_APP_SECRETS';
export const TEST_GROUPS = {
  [PAYMENT_GROUP]: {
    PAYMONGO_SECRET_KEY: 'test-paymongo-secret-key',
    PAYMONGO_WEBHOOK_SECRET: 'test-paymongo-webhook-secret',
    REVENUECAT_SECRET_API_KEY: 'test-revenuecat-api-key',
    REVENUECAT_WEBHOOK_SECRET: 'test-revenuecat-webhook-secret',
  },
  [APP_GROUP]: {
    TRIAL_IDENTITY_HMAC_KEY: 'test-trial-identity-hmac-key',
    GUARDIAN_HMAC_KEY: 'test-guardian-hmac-key',
    GUARDIAN_MAIL_API_KEY: 'test-guardian-mail-api-key',
    SIGN_IN_CODE_KEY: 'test-sign-in-code-key',
  },
};
export const TEST_SECRETS = {...TEST_GROUPS[PAYMENT_GROUP], ...TEST_GROUPS[APP_GROUP]};

/** Sets both secret env vars to the test objects, with optional per-key overrides (undefined removes a key). */
export function setTestSecrets(overrides = {}) {
  for (const [group, keys] of Object.entries(TEST_GROUPS)) {
    const value = {...keys};
    for (const key of Object.keys(overrides)) if (key in keys) value[key] = overrides[key];
    for (const key of Object.keys(value)) if (value[key] === undefined) delete value[key];
    process.env[group] = JSON.stringify(value);
  }
  return {...TEST_SECRETS, ...overrides};
}

/** Only these functions may bind the payment secret. */
export const PAYMENT_FUNCTIONS = ['createPaymongoCheckout', 'paymongoWebhook', 'revenuecatWebhook'];

/** endpoints: {exportName: {secretEnvironmentVariables: [{key}]}}. Returns one line per violation. */
export function paymentBindingViolations(endpoints) {
  const lines = [];
  for (const [name, endpoint] of Object.entries(endpoints)) {
    const bound = (endpoint?.secretEnvironmentVariables ?? []).map(s => s.key);
    if (bound.includes(PAYMENT_GROUP) && !PAYMENT_FUNCTIONS.includes(name)) lines.push(`${name} binds ${PAYMENT_GROUP}`);
  }
  for (const name of PAYMENT_FUNCTIONS) {
    const bound = (endpoints[name]?.secretEnvironmentVariables ?? []).map(s => s.key);
    if (!bound.includes(PAYMENT_GROUP)) lines.push(`${name} does not bind ${PAYMENT_GROUP}`);
    if (bound.includes(APP_GROUP)) lines.push(`${name} binds ${APP_GROUP} but reads no key of it`);
  }
  return lines;
}
