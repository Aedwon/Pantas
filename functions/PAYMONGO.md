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
| Refund event: `refund.succeeded` (resource type `refund`). Dispute events: `dispute.created`, `dispute.resolved` (resource type `dispute`). | same events page |
| Signature header `Paymongo-Signature: t=<unix seconds>,te=<test hex>,li=<live hex>`. Signed string is `<t>.<raw body>`, HMAC-SHA256 with the webhook secret. Use `te` for test events and `li` for live events. A timestamp check is optional but recommended. | https://docs.paymongo.com/docs/developer-tools-webhook-setup-management.md ("Securing a webhook") |
| Delivery succeeds on HTTP 200 to 209 with a JSON body within 30 seconds. Failures retry up to 12 times with exponential backoff. Duplicate deliveries happen. Unrecognized events should get 200. Raw body must be kept for verification. | https://docs.paymongo.com/docs/developer-tools-retry-logic.md, https://docs.paymongo.com/docs/developer-tools-best-practices.md, https://docs.paymongo.com/docs/developer-tools-go-live-checklist.md |

## UNCONFIRMED (designed defensively)

1. **Refund and dispute payloads do not show which payment they refer to.** The sample bodies
   have only amount, currency, status and reason. The code reads `payment_id` (or `payment.id`)
   from the resource. If absent, it writes an `audit_logs` row (`paymongoRevokeWithoutPayment`)
   and returns 200 without revoking. Check a real test-mode refund event before launch.
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
(region asia-southeast1) with the event types `checkout_session.payment.paid`, `refund.succeeded`
and `dispute.created`.
