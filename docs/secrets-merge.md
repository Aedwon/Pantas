# Two secrets per project

Secret Manager bills $0.06 per active version a month after 6 free per billing account. Eight
secrets in two projects were 16 versions. The functions now read two secrets per project, so two
projects hold 4 versions (Fable 5.2 rule 7 ruling 1, split by Fable 5.2 on Nov 17).

Each secret is a JSON object, one text value per key. A missing key, an empty value or invalid
JSON fails that call closed (no fallback to another value, and the error never contains a value).
A function binds only the secret or secrets it reads. Only web checkout, the PayMongo webhook and
the RevenueCat webhook may bind the payment secret; a test fails if any other function does.

## Keys

### PANTAS_PAYMENT_SECRETS

- `PAYMONGO_SECRET_KEY`
- `PAYMONGO_WEBHOOK_SECRET`
- `REVENUECAT_SECRET_API_KEY`
- `REVENUECAT_WEBHOOK_SECRET`

### PANTAS_APP_SECRETS

- `TRIAL_IDENTITY_HMAC_KEY`
- `GUARDIAN_HMAC_KEY`
- `GUARDIAN_MAIL_API_KEY`
- `SIGN_IN_CODE_KEY`

## Readers

- `PAYMONGO_SECRET_KEY`: web checkout, PayMongo webhook.
- `PAYMONGO_WEBHOOK_SECRET`: PayMongo webhook.
- `REVENUECAT_SECRET_API_KEY` and `REVENUECAT_WEBHOOK_SECRET`: RevenueCat webhook.
- `TRIAL_IDENTITY_HMAC_KEY`: trial start and eligibility, plan list, account delete, guardian withdraw, the daily late job.
- `GUARDIAN_HMAC_KEY`: the guardian consent callables.
- `GUARDIAN_MAIL_API_KEY`: guardian send and answer, sign-in code request, the inactivity jobs.
- `SIGN_IN_CODE_KEY`: sign-in code request and verify, Google sign-in.

Keep every existing value unchanged when moving. In particular `TRIAL_IDENTITY_HMAC_KEY`
and `GUARDIAN_HMAC_KEY` must keep their current values or trial matching and guardian links break.

## Staging steps (for the lead)

1. Build the two JSON files in a private terminal from the current secret values. Never print them or paste them into chat.
2. Staging's payment value must hold test-mode keys only: PayMongo `sk_test_...` and its test webhook signing secret, a RevenueCat sandbox key. A live key on staging is a stop.
3. Set both, deploy, verify the callables, then destroy the old per-key secrets. See `docs/deploy-prod.md`, section 16.
4. A deploy before both secrets exist on the project fails; create them first.
