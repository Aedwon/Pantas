# PayMongo support request: subscriptions and QR Ph refunds

**Owner:** Aedwon (sends it from his PayMongo account). **Drafted:** 18 November 2026.
**Why:** Pantas sells weekly, monthly and yearly plans that renew, plus one-time season
passes (PSHS-NCE ₱1,499, Civil Service ₱499, Licensure ₱1,499; see `docs/pricing.md`).
PayMongo turns on Subscriptions only on request, and its refund API refuses QR Ph
payments ("Refunds are not allowed for payments with source type qrph", test mode,
9 November 2026; see `docs/OPERATIONS.md`, "Manual QR Ph refund").

## Status tracker

Update this table as replies arrive. Dates are Manila time.

| # | Item | Status | Date | Notes |
|---|---|---|---|---|
| 1 | Account upgraded from Individual to Sole Proprietor | Done | 18 Nov | Aedwon |
| 2 | Enable GCash and Maya (one-time payments) | Requested | 18 Nov | Aedwon started the request |
| 3 | Enable Visa and Mastercard | Requested | 18 Nov | Aedwon started the request |
| 4 | Enable Subscriptions (Maya and cards) | Sent | 19 Nov | Message below |
| 5 | Confirm whether GCash can be used for Subscriptions | Sent | 19 Nov | PayMongo's docs disagree |
| 6 | QR Ph refunds through PayMongo (dashboard or API) | Sent | 19 Nov | Until confirmed, refund QR Ph by bank transfer per `docs/OPERATIONS.md` |
| 7 | Security and billing lead: confirm how web checkout bills plans (PayMongo Subscriptions or one-time charge per period) | Answered Nov 18 | Security fixes lead | One-time charge per period; nothing renews today. See "Item 7 answer" below |
| 8 | Aedwon: renewals for launch? | Decided | 19 Nov | Prepaid periods for launch ("ok"). Items 4 and 5 are for after launch, not a launch blocker |

Statuses: To send, Sent, Waiting on PayMongo, Answered, Done, Declined.

## Message to send (copy and paste)

Fill in the two bracketed fields before sending.

> Subject: Enable Subscriptions, and refunds for QR Ph payments
>
> Hi PayMongo team,
>
> My account [business name, merchant ID] was recently upgraded from Individual to Sole
> Proprietor, and I have requested GCash, Maya and Visa/Mastercard. I'd like help with
> three things:
>
> 1. **Subscriptions.** Please enable Subscriptions on my account for Maya and for
>    Visa/Mastercard (with card vaulting). We sell weekly, monthly and yearly study
>    plans that renew automatically.
> 2. **GCash for subscriptions.** Your docs differ on whether GCash supports recurring
>    billing. Can GCash be used for Subscriptions on my account? If not, I'll offer it
>    for one-time payments only.
> 3. **Refunds for QR Ph payments.** In test mode, the refund API returned "Refunds are
>    not allowed for payments with source type qrph". Is there a way to refund QR Ph
>    payments through PayMongo, by API or from the dashboard? If not, what process do
>    you recommend, and will a refund made outside PayMongo still appear in my reports?
>
> Thank you,
> [Your name]

## After the reply

- Record each answer in the tracker and tell the operations manager.
- If PayMongo enables QR Ph refunds, the security and billing lead switches
  `docs/OPERATIONS.md` from the manual bank-transfer process to PayMongo's refund.
- If GCash cannot recur, plans that renew are offered on Maya and cards only; GCash and
  QR Ph stay available for season passes.


## Item 7 answer (security fixes and billing cap lead, Nov 18, 2026, read-only)

**How web checkout bills today: a one-time charge per period. Nothing renews.**

- The server creates a PayMongo **Checkout Session** (`POST /v2/checkout_sessions`, `functions/src/paymongoClient.ts`) with one line item at the plan's web price. It does not use PayMongo's Subscriptions, Plans or Customers APIs, and no payment method is saved.
- Payment methods: `card` and `qrph` by default (`functions/src/paymongoCheckout.ts`), overridable with `PAYMONGO_PAYMENT_METHODS` once the account has more enabled.
- When the paid webhook arrives, the server grants a **prepaid period** from `functions/src/products.json`: weekly = 7 days, monthly = 1 calendar month, yearly = 1 calendar year (Philippine time, `functions/src/paymongoPolicy.ts`). Buying the same tier again stacks behind the current end (`functions/src/paymongoGrants.ts`); exam passes end at their sitting and never stack.
- So on the web, "weekly", "monthly" and "yearly" are prepaid lengths the student buys again by hand. Access ends at the period's end unless they buy again. No reminder or auto-charge exists.
- Prod still uses PayMongo test keys.

**What would have to change if renewals must use PayMongo Subscriptions on Maya and cards only:**

1. **A second billing path in the functions:** a PayMongo plan per renewing product, a PayMongo customer per Pantas account, a subscription per purchase (first payment authorized on Maya or card), and webhook handling for each renewal (paid, failed, past due, cancelled). Each successful renewal extends the grant; a failure or cancellation lets it end at the period's end. Same signature checks, mode checks and duplicate-event protection as today's webhook.
2. **Methods split by product:** renewing plans offer only Maya and card. GCash and QR Ph stay available as one-time prepaid periods and for exam passes, which do not renew.
3. **Grants:** a renewing grant follows the subscription's period (with a short grace on a failed charge), alongside today's prepaid stacking; a student must not hold both a renewing web plan and a Google Play subscription for the same tier without a warning (the plan list already warns for Play).
4. **App screens (a Claude worker, visual companion first):** renewal wording at checkout, a "manage or cancel" place, and what happens on a failed charge.
5. **Legal text:** auto-renewal and cancellation terms in the purchase terms (drafted by an agent and critiqued by Codex GPT 6.1 Sol High, rule 5; Aedwon only checks).
6. **Before live keys either way:** the S-12 fix (a failed checkout creation can block that product for the account), not yet approved; a Codex audit of the money path.
7. **Unchanged:** secrets (PayMongo keys stay in `PANTAS_PAYMENT_SECRETS`, no new versions), so rule 7 is unaffected.

Rough size: about 3 to 5 days of backend work plus the screens and the legal text; balanced complexity; Aedwon's choice whether renewals are needed for launch or prepaid periods stay.
