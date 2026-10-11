Audited `web/new-design-w3-r1` at `4a36a3b3`, against `origin/integration/new-design-r1` at `cee7a9c5`. Policy and plans came from `origin/main` at `da314d1e`. The worktree was clean.

Blocker: none confirmed in this static review.

Major findings:

1. **A crashed claims copy can preserve revoked Pro.** `functions/src/revenuecatClaims.ts:37`

   An older grant copy can wait while a newer revocation commits, copies successfully, and acknowledges its version. The older copy can then overwrite Auth with Pro and terminate before marking the mismatch. Firestore still says the newest version is synchronized. Duplicate delivery and hourly repair both skip it. Access can last until the old `proUntil`.

   Fix: serialize copies per account using durable work. Also reconcile actual Auth claims against Firestore, including records marked synchronized.

   Test gap: `functions/test/revenuecat-claims.emulator.mjs:46` lets the older copy finish its corrective work. Add termination immediately after its Auth write. The repair test at line 65 checks the version marker without asserting the repaired Auth values.

2. **Pausing does not trigger the required fresh online check.** `lib/features/paywall/application/offline_window.dart:22`

   The timer observes time and publishes paused access. It never requests fresh customer information. Cache invalidation occurs through configuration, Restore, or ledger refresh. A connected user can remain paused after correcting their clock until another operation triggers a check.

   Fix: trigger one controlled invalidate-and-fetch operation when paused or after a counted setback, and retry when connectivity returns.

   Test gap: `test/features/paywall/data/verified_offline_gateway_test.dart:108` and line 118 manually call configuration. Those tests pass without automatic recovery.

3. **Hourly repair reads every server document. Lead concern (b) confirmed.** `functions/src/revenuecatClaims.ts:69`

   The query pages through the entire `server` collection group. It filters synchronized records afterward. Paging limits memory, not billed reads. An unchanged population of N server documents generates approximately 24N document reads daily.

   Fix: maintain indexed, durable pending-repair work and query that. Keep a separate, less frequent consistency check for the crash case above.

Minor findings:

4. **Webhook records accumulate indefinitely. Lead concern (a) confirmed in repository code.** `functions/src/revenuecatClaims.ts:21`; `functions/src/revenuecatWebhook.ts:49`

   Event records and per-minute rate-limit records have neither expiration fields nor a cleanup path. Event records also retain full reconciliation facts, increasing storage as purchase history grows.

   Fix: add explicit retention and cleanup. Event records live under `webhookEvents/{eventId}/users/{uid}`. Deleting only their parent would not remove them. Preserve sufficient dedupe retention for legitimate retries.

5. **Pass-only Restore reports no active subscription despite confirmed access.** `lib/features/paywall/data/live_revenuecat_gateway.dart:587`

   Restore merges ledger passes into `confirmed`, but selects its result from the separate RevenueCat-only `reported` entitlement. A pass-only customer can regain access while receiving a failure result.

   Fix: determine Restore success from confirmed known coverage, including ledger passes. Test the returned status as well as access.

Clean areas in the inspected source:

- HMAC checks exact bytes and rejects stale signatures. RevenueCat documents fresh signature timestamps on retries, supporting the five-minute check. [Webhook documentation](https://www.revenuecat.com/docs/integrations/webhooks)
- Server reconciliation filters app, environment, known products, and promotional tiers. Cancellation preserves an active paid period.
- Pass products bind to specific exams. Ledger reconciliation handles refunds, duplicate delivery, transfers, and preserved sitting dates.
- Rules require live Pro claims for inspected sync paths. Server entitlement documents deny client access. Server Pro content remains closed.
- Public IDs use transactional uniqueness, retired-ID exclusion, protected lookup, and deletion guards.
- Client identity changes clear entitlement state and block purchases during association. Pending markers belong to individual accounts.
- Upgrade parameters use time proration. Trial display requires a Monthly free-phase offer.
- Editable local snapshots remain within AC-10’s accepted patched-client risk. They do not authorize server access.

Coverage limits: static review only. I ran no tests, builds, git writes, deployments, or service calls. I inspected selected abuse tests, not every test or unrelated integration difference. Live configuration, deployed retention policies, real purchase flows, and complete shared-phone data isolation remain unverified.