# One secret per project: PANTAS_SECRETS

Secret Manager bills $0.06 per active version a month after 6 free per billing account. Eight
secrets in two projects were 16 versions. The functions now read one secret, `PANTAS_SECRETS`,
so two projects hold 2 versions. Fable 5.2 rule 7 ruling 1.

`PANTAS_SECRETS` is a JSON object, one text value per key. All 8 keys are required wherever a
function reads them; a missing key, an empty value or invalid JSON fails that call closed (no
fallback to another value, and the error never contains a value). Only functions that read a
secret declare `PANTAS_SECRETS`.

## Keys

- `REVENUECAT_SECRET_API_KEY`
- `REVENUECAT_WEBHOOK_SECRET`
- `TRIAL_IDENTITY_HMAC_KEY`
- `GUARDIAN_HMAC_KEY`
- `GUARDIAN_MAIL_API_KEY`
- `PAYMONGO_SECRET_KEY`
- `PAYMONGO_WEBHOOK_SECRET`
- `SIGN_IN_CODE_KEY`

Which functions read which key:

- `TRIAL_IDENTITY_HMAC_KEY`: trial start and eligibility, plan list, account delete, guardian withdraw, the daily late job.
- `GUARDIAN_HMAC_KEY`: the guardian consent callables.
- `GUARDIAN_MAIL_API_KEY`: guardian send and answer, sign-in code request, the inactivity jobs.
- `SIGN_IN_CODE_KEY`: sign-in code request and verify, Google sign-in.
- `PAYMONGO_SECRET_KEY`: web checkout, PayMongo webhook.
- `PAYMONGO_WEBHOOK_SECRET`: PayMongo webhook.
- `REVENUECAT_SECRET_API_KEY` and `REVENUECAT_WEBHOOK_SECRET`: RevenueCat webhook.

Keep every existing value unchanged when merging. In particular `TRIAL_IDENTITY_HMAC_KEY`
and `GUARDIAN_HMAC_KEY` must keep their current values or trial matching and guardian links break.

## Staging steps (for the lead)

1. Build the JSON in a private terminal from the current secret values. Never print it or paste it into chat.
2. Staging's value must hold test-mode keys only: PayMongo `sk_test_...` and its test webhook signing secret, a RevenueCat sandbox key. A live key on staging is a stop.
3. Set it, deploy, verify the callables, then destroy the old per-key secrets and old versions. See `docs/deploy-prod.md`, "The merged secret".
4. A deploy before `PANTAS_SECRETS` exists on the project fails; create it first.
