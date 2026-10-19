# PayMongo integration notes

Checked on October 19, 2026 against PayMongo's published documentation (docs.paymongo.com;
developers.paymongo.com redirects there). No live or test PayMongo account was called.
Pages were read as Markdown (append `.md` to the page URL).

## Verified from the documentation

| Fact | Source |
|---|---|
| Create session: `POST https://api.paymongo.com/v2/checkout_sessions` (v2 is recommended; v1 exists). Basic auth with the secret key as username and an empty password. Body `data.attributes` with `line_items` (name, amount in centavos, currency `PHP`, quantity), `payment_method_types`, `success_url`, `cancel_url`, `reference_number`, `metadata` (object), `description`, `send_email_receipt`. Response `data.id` (`cs_...`) and `data.attributes.checkout_url`. | https://docs.paymongo.com/docs/payment-channels-hosted-checkout.md, https://docs.paymongo.com/docs/payment-channels-hosted-checkout-quick-start.md, https://docs.paymongo.com/reference/create_checkout_sessions_2.md |
| Retrieve: `GET /v1/checkout_sessions/{id}`. Attributes include `metadata` (string values), `status`, `payments[]` (id, amount in centavos, currency, status `paid`), `payment_intent`, `reference_number`. | https://docs.paymongo.com/reference/get_checkout_sessions.md |
| Payment method type values: `card`, `gcash`, `paymaya`, `grab_pay`, `shopeepay`, `qrph`. | https://docs.paymongo.com/docs/payment-acceptance-e-wallets.md, quick start and checkout resource pages |
| Paid event: `checkout_session.payment.paid`. Envelope `data.id` (`evt_...`), `data.attributes.type`, `.livemode`, `.created_at`, `.data` (the full Checkout Session). "At most one entry in `payments` has `status: paid`." There is no event when a session expires. | https://docs.paymongo.com/docs/developer-tools-webhooks-events.md |
| Refund and dispute event names: see the next section. The docs disagree with each other. | see below |
| Signature header `Paymongo-Signature: t=<unix seconds>,te=<test hex>,li=<live hex>`. Signed string is `<t>.<raw body>`, HMAC-SHA256 with the webhook secret. Use `te` for test events and `li` for live events. A timestamp check is optional but recommended. | https://docs.paymongo.com/docs/developer-tools-webhook-setup-management.md ("Securing a webhook") |
| Delivery succeeds on HTTP 200 to 209 with a JSON body within 30 seconds. Failures retry up to 12 times with exponential backoff. Duplicate deliveries happen. Unrecognized events should get 200. Raw body must be kept for verification. | https://docs.paymongo.com/docs/developer-tools-retry-logic.md, https://docs.paymongo.com/docs/developer-tools-best-practices.md, https://docs.paymongo.com/docs/developer-tools-go-live-checklist.md |

## Refund and dispute events: what the documentation says (rechecked)

The documentation does not settle the refund event name. Two pages disagree, so the code
handles every candidate and the webhook should subscribe to all of them.

1. https://docs.paymongo.com/docs/developer-tools-webhooks-events.md (updatedAt 2026-10-14),
   the per-event payload page, has sample payloads for `refund.succeeded` (data type `refund`),
   `dispute.created` and `dispute.resolved` (data type `dispute`). The samples show only
   `amount`, `currency`, `status`, `reason`. They show no payment id.
2. https://docs.paymongo.com/reference/webhook-resource.md (updatedAt 2026-03-19), field
   `events`: "Refunds: `payment.refunded` and `payment.refund.updated`". The same list is in
   https://docs.paymongo.com/reference/create-a-webhook.md and the table in
   https://docs.paymongo.com/docs/webhook-testing.md (rows `payment.refund.updated`,
   `payment.refunded`). Neither page has a sample payload for these events, so whether the
   resource is the payment (payment id in `data.id`) or a refund is UNCONFIRMED.
3. https://docs.paymongo.com/docs/qrph-refunds.md shows the refund resource: `id` `ref_...`,
   `type` `refund`, `attributes.payment_id` `pay_...`, `attributes.status`.
4. No page lists dispute event names other than `dispute.created` and `dispute.resolved`
   (events page and the go-live checklist).

What the code does:
- Handles `refund.succeeded`, `payment.refunded`, `payment.refund.updated` and `dispute.created`.
  `dispute.resolved` is acknowledged and ignored. Subscribe the webhook to all four handled names
  plus `checkout_session.payment.paid`.
- Payment id: `data.id` when `data.type` is `payment` (or the id starts with `pay_`), otherwise
  `attributes.payment_id`, otherwise `attributes.payment.id`.
- `payment.refund.updated` revokes only when the payload shows a succeeded refund (`status`
  `succeeded` on a refund resource, or a `refunds[]` entry with status `succeeded` on a payment
  resource). Other updates are acknowledged and ignored. The payload shape is UNCONFIRMED.
- If no payment id can be found, the webhook writes an `audit_logs` row
  (`paymongoRevokeWithoutPayment`) and returns 500 so PayMongo retries and the log alerts.
- If the payment id is valid but no grant exists yet, a tombstone `paymongoRevocations/{paymentId}`
  is written (server-only). The later paid event creates the grant already revoked, with an
  `audit_logs` row (`paymongoGrantBornRevoked`).
- Partial refunds (Aedwon's decision, decision log "partial refunds shorten access
  proportionally"): the grant stores `paidAmount` (centavos) and `refunds` keyed by refund id. New
  length is the original length times (1 - refunded/paid), measured from `startsAt` and rounded
  down to the second (`fullEndsAt` keeps the unrefunded end). Several refunds add up, the same
  refund id twice changes nothing, and refunds totaling at least the amount paid revoke the
  grant. A grant that already ended only records the refund. Later stacked grants are re-planned
  as for a revoke. A dispute revokes the whole grant.
- The refund amount comes from the event payload when it is a positive integer and the status is
  succeeded. Otherwise the refund is read from PayMongo (`GET /v1/refunds/{id}`, see below) and
  only that is trusted: it must have the same id and `payment_id`, a positive integer amount and
  (for `refund.succeeded`) status `succeeded`. If it cannot be read or does not match, the webhook
  writes an audit row (`paymongoRefundAmountUnverified`) and returns 500.
- The tombstone carries the refund map and a dispute flag, so a grant created later is born
  shortened, or revoked when the refunds cover the payment or a dispute was recorded.
- Revoking a grant moves later stacked grants of the same account and tier that have not started
  earlier, in the same transaction, keeping each length. A grant covers only
  `[startsAt, endsAt)`.

Retrieve a refund: https://docs.paymongo.com/reference/retrieve-a-refund.md (updatedAt
2026-10-14) documents `GET /refunds/{id}` on server `https://api.paymongo.com`, Basic auth, response
`data.id` (`ref_...`), `data.type` `refund`, `data.attributes.amount` (centavos),
`payment_id`, `status` (sample `succeeded`). The page shows the path without a version prefix; the
create-refund example on https://docs.paymongo.com/docs/payment-acceptance-refunds.md uses
`/v1/refunds`, so the client calls `/v1/refunds/{id}` (version prefix UNCONFIRMED for retrieve).
Refund resource: https://docs.paymongo.com/reference/refund-resource.md.

## UNCONFIRMED (designed defensively)

1. **Refund and dispute event names and payment id location.** See the section above. Check a
   real test-mode refund and dispute event before launch.
2. **Whether PayMongo signs a retried delivery with a fresh `t`.** If a retry keeps the old
   timestamp, the 5 minute tolerance rejects it with 401. Mitigation: resend from the dashboard.
3. **Whether `GET /v1/checkout_sessions/{id}` returns sessions created through `/v2`.** The docs
   describe the v1 path only. The client reads `payments` at the top level and falls back to
   `payment_intent.attributes.payments`. If v1 reads fail for v2 sessions, the webhook returns 500
   (retry) and grants nothing.
4. **Checkout session `status` after payment.** The paid sample still shows `active`, so the code
   does not use it. It requires exactly one `payments[]` entry with status `paid`, currency `PHP`
   and the exact centavo price.
5. **Payment methods enabled on the merchant account.** Types beyond the six above (for example
   `dob`, `dob_ubp`, `billease`) are not confirmed here. Set `PAYMONGO_PAYMENT_METHODS`
   (comma separated) once the account has them. A disabled type may make the create call fail.
6. **`Idempotency-Key` on checkout creation.** Recommended for POSTs by the go-live checklist, but
   not confirmed for this endpoint. Not sent.
7. **Dispute outcome.** `dispute.resolved` with status `won` is ignored. A revoked grant stays
   revoked. Decide whether a won dispute should restore access.
8. **Return URLs.** `success_url` and `cancel_url` are `<origin>/pro?checkout=success` and
   `?checkout=cancelled`, where origin is `PANTAS_WEB_ORIGIN` (default `https://pantas.study`).
   Lane C3 owns the real routes and may change these.

## Configuration

Secrets: `PAYMONGO_SECRET_KEY`, `PAYMONGO_WEBHOOK_SECRET`. Test mode vs live mode is taken from the
secret key prefix (`sk_live_` means live). An event whose `livemode` differs from that mode is
acknowledged and ignored. The webhook URL to register is the `paymongoWebhook` function
(region asia-southeast1) with the event types `checkout_session.payment.paid`, `refund.succeeded`,
`payment.refunded`, `payment.refund.updated` and `dispute.created`.
