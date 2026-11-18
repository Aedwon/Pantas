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
| 4 | Enable Subscriptions (Maya and cards) | To send | | Message below |
| 5 | Confirm whether GCash can be used for Subscriptions | To send | | PayMongo's docs disagree |
| 6 | QR Ph refunds through PayMongo (dashboard or API) | To send | | Until confirmed, refund QR Ph by bank transfer per `docs/OPERATIONS.md` |
| 7 | Security and billing lead: confirm how web checkout bills plans (PayMongo Subscriptions or one-time charge per period) | Open | | Needed before live payments |

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
