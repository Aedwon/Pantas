# Security and billing lead r2: live PayMongo payments, paused on the live key

Written Nov 25, 17:20 UTC (Nov 26, 1:20 AM Manila). Policy: main 27b8accf3 and later (AGENTS, WORKFLOW, SUBAGENTS,
orchestrator, process-improvement with the Nov 24 and 25 entries). Task estimate E-185 (timer running, paused for the
live key). Integrator: CSE release lead r8; it merges every PR and gives the go for each functions deploy.

## Done

- **#109, money-path server fixes** (merged 97937526f). Staging proof passed twice (Nov 24 on the branch, Nov 25 on main).
  Prod functions deploy of the 43 affected functions from main 27b8accf3, 16:51 UTC, with P7 (#138). Checkout-closed
  probe on prod: 400 `checkout-closed`. Queued-plan repair script on prod: 0 plans to move (dry run and live). 15-minute
  watch: no errors, no 5xx.
- **#91, web entitlement** (merged 8f8cc211f): stale replies dropped, pass rows not counted as connected coverage, Pro
  page shows no plan for an ended reward or another exam's reward, and web checkout errors read "We couldn't start your
  payment. Try again." / "Payments open soon." (integrator ruling). ENT-06 parts dropped for main's #119. Rides the
  integrator's next web ship.
- **#136, every lost dispute writes an owner follow-up; QR Ph only at checkout** (merged fd71e0512). Codex Sol High review
  and a narrow re-check, all findings fixed test-first. Staging proof with a simulated QR Ph payment passed. Prod deploy of
  five functions from main fb996cf24, 17:08 UTC; checkout-closed probe passed; watch result in the launch log.
- **#139, admin-only checkout after the live key** (merged c403f3881): prod checkout opens to everyone only when the key
  is live and `PAYMONGO_CHECKOUT_OPEN=true` (false in `functions/.env.pantas-prod`). The opening ship sets it (integrator
  has the step). Not yet deployed: it goes out with the live-key step.
- **Owner alert** "Payment follow-up created (owner action)" made on staging and prod (log-based, owner email, 5-minute
  rate limit). A synthetic staging log line was sent at 17:10 UTC; email arrival not yet confirmed by Aedwon.
- **Test-mode PayMongo grants on prod:** 0 (Nov 25, 17:15 UTC). Count again right before the switch.

Rollbacks and revision lists: `Pantas-private/releases/2026-11-26-money-path-prod/`.

## Left (in order)

1. **Live key** (Aedwon, morning of Nov 26; PayMongo dashboard was in maintenance). The manager runs
   `Pantas-private/releases/2026-11-26-money-path-prod/live_cutover.mjs <key file>` then `--apply` in one command. It
   registers the live webhook for the paid, refund and dispute events (falls back without dispute events and says so),
   and adds a secret version with the live key and the webhook secret. It prints no secret.
2. Recount test-mode PayMongo grants on prod (expect 0). Then, after the integrator's go, deploy
   `createPaymongoCheckout`, `paymongoWebhook`, `revenuecatWebhook` from the origin/main tip with the pinned CLI
   (`npx --prefix functions firebase deploy --only ...`). Probe: a student is still refused (`checkout-closed`), the admin
   account can open a QR Ph checkout. Then disable and destroy the old secret version (free tier: 6 versions).
3. **Real payment (M3):** Aedwon, signed in as the admin account, buys Weekly (₱49) by QR Ph. Verify grant, claims, the
   webhook log and the receipt. QR Ph cannot be refunded through the API: record the refund with the signed manual
   refund command (`docs/OPERATIONS.md`) and confirm access ends; the money itself is his own. Tell the integrator when
   done so the opening ship can set the switch.
4. Disable the prod **test** webhook (`hook_xDX1i5zipTnQMnEzad4TPbVx`) after the live switch, so staging test payments
   stop reaching prod. Until then, every staging payment run pauses it first.
5. Open, owner CSE release lead: six display-only items from the money-path review (private residuals note).

## Notes

- The first webhook delivery of a payment often returns 500 because PayMongo's session does not yet show the payment as
  paid; PayMongo's retry succeeds. This is by design (`paymentNotYetPaid`).
- A staging payment run must pause the prod test webhook while prod runs test keys, or the event reaches prod and leaves a
  stray follow-up there (one from Nov 24 is still pending on prod; delete it only with the manager's OK).
