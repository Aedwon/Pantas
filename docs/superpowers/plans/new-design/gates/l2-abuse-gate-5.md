# Level 2 abuse amendment gate review 5

Reviewer: independent gate reviewer (Opus), read-only, October 6, 2026. Author of none of the reviewed documents.
Target: `git diff be018f89 50f0341e` on origin/main (HEAD 50f0341e, equal to origin/main after fetch). Files: strategy B7, decision log, L2 W3 §3 and §10, gate 4 report.
Closing check against: `gates/l2-abuse-gate-4.md` (L2A4-1 to L2A4-10).
Code facts: `purchases_flutter` 10.8.0 from the pub cache; RevenueCat Android SDK source from GitHub (`RevenueCat/purchases-android`, main); integration worktree `scratchpad/wt-int`.
Policy read from origin/main: SUBAGENTS.md (Parts 1 to 3, 7b by reference); AGENTS.md and WORKFLOW.md as cited by the gate series.
Settled and not reopened: the October 6 log decisions (no functions deployed, copy and limits, tier-named giveaways, B7 model change, 3-day window, 1-day claim margin).

## Totals

- Blockers: 0
- Should-fix: 4
- Notes: 4
- Part A status: 6 resolved (L2A4-3 counted with its follow-up in Part B), 1 recorded as an open decision for Aedwon at E14 (L2A4-2), 2 partly (L2A4-1 tests, L2A4-10), 1 not addressed (L2A4-8). Partials are counted once, through Part B.

Verdict: **Gate does not pass.**

## Evidence pasted

- `purchases-android` `common/caching/DateExtensions.kt`: `(dateProvider.now.time - cacheLastUpdated.time).milliseconds >= cacheDuration` (foreground 5 minutes, background 25 hours). `DeviceCache.kt:275-276`: `isCustomerInfoCacheStale` uses this with the device clock; the timestamp is written from the device clock when the answer is cached. If the device clock is now earlier than the time the cache was written, the difference is negative and the cache is never stale.
- `purchases_flutter-10.8.0/lib/purchases_flutter.dart:867`: `static Future<void> invalidateCustomerInfoCache()`; on Android this clears the cache timestamp (`DeviceCache.clearCustomerInfoCacheTimestamp`), so the next `getCustomerInfo()` fetches from the network.
- `customer_info_wrapper.dart:16,23`: `activeSubscriptions` (product ids) and `nonSubscriptionTransactions` (every consumable ever bought, with no end date and no active flag).
- L2 W3 §3 "Pass ledger": "the app's `passes` (exam id to end date) is derived from the active records (gate L2A-8)". §3 "Season Pass end": a pass ends on the exam's published date.
- L2 W5 line 33-36 accepted-risk list for E14: lists refund-then-stay-offline; no clock-setback item.
- AC-3 deploy steps now have three items (claim inventory, webhook URL plus test event, one-time reconciliation); the sentence still ends "W5 re-checks both on the final build."
- Decision log October 6 level 3 list (line 781-782): "setup steps for the Functions API, Blaze and the two promotional entitlements". The review 4 entry adds no level 3 items. `level4-setup-steps.md`: no line on promotional grants (unchanged).
- Strategy B7 line 230: "Opus does not write implementation code." Added line 237: "Any code the lead writes while integrating (conflict resolutions included)".
- L3 W3 key P1: "RevenueCat secret API key (V2, read-only customer access)". RevenueCat API v2 has a list-customers call, so the one-time reconciliation can enumerate customers with that key.
- Traceability X-2 and X-11 still point at AC-1 and AC-7; no change needed.
- Em dashes in added plan, strategy and log lines: none.

## Part A: closing check of gate 4

| ID | Status | Basis |
|---|---|---|
| L2A4-1 | resolved, with a gap | The definition is now the observable test: `verified` (not `verifiedOnDevice`, `notRequested` or failed) and `requestDate` strictly later than the stored trusted time. Only such an answer moves the stored trusted time. Dropping the "fresh fetch" wording removed the only line that made the app reach the network; see L2A5-1. The wrong-year recovery test from the gate 4 fix is missing (L2A5-1). |
| L2A4-2 | open decision, recorded | AC-1 lists it as a residual risk for Aedwon's acceptance at E14 with the lead recommending accept; the log records it as open for E14. Two defects in the record: the W5 E14 list lacks it (L2A5-2), and the stated attack cost and the reason it cannot be closed are inaccurate (L2A5-4). |
| L2A4-3 | resolved, with a new conflict | (a) Coverage is the union on both sides; an unknown product adds nothing and removes nothing. (b) Existing promotional `pro` grants are listed and reissued before W3 ships. (c) §3 defines `unknown` as adding no coverage. The new union wording counts every non-subscription purchase, which conflicts with the pass ledger (L2A5-3). |
| L2A4-4 | resolved | One-time reconciliation through the webhook's code path, right after the URL is set and the test event passes, with Aedwon's approval and a reported count. P1 (v2 read-only) can list customers. Wording follow-up: L2A5-6. |
| L2A4-5 | resolved | B7 adds a separate review of the lead's integration code (fresh Opus session or Astra audit of the merge diff); money and entitlement conflicts go back to the Sol worker where practical. Wording follow-up: L2A5-8. |
| L2A4-6 | resolved | Stored trusted time and mark belong to the device and survive sign-out and account switch; AC-5 clears only the cached entitlement. |
| L2A4-7 | resolved | Period instead of semicolon. |
| L2A4-8 | not addressed | Neither the log's level 3 list nor the setup steps gained "grant giveaways only with `promo_*`" or "new products enter the product table before sale". AC-7 still says the setup steps tell Aedwon. See L2A5-5. |
| L2A4-9 | resolved | B7: "The 'Independent reviewers' line above is replaced from level 4 on by these lines." |
| L2A4-10 | partly | Four AC-1 tests are now named in L2. Missing: a fresh verified answer after a wrong-year clock unpauses and stays on across restarts; a `verifiedOnDevice` answer with a forward clock resets nothing and does not move the stored trusted time. See L2A5-1. |

## Part B: new problems in the diff

| ID | Severity | Plan / section | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L2A5-1 | should-fix | L2 W3 §10 AC-1 | Honest lockout while online. The new definition no longer requires the app to fetch, and the SDK decides staleness with the device clock. Case: the phone clock was ahead (for example a wrong year) when RevenueCat cached an answer; the clock is then corrected. The backward step exceeds 10 minutes, so Pro pauses. Every later `getCustomerInfo()` returns the cache, because "now minus cache time" is negative and the cache is never stale. The cached answer's `requestDate` equals the stored trusted time, so it is not "strictly later" and never counts. The user is online, sees "Connect once to keep using Pro.", and stays paused until the device clock passes the old cache time (up to the size of the original error). This breaks AC-1's own promise that "an honest user whose clock was once wrong is not locked out" (L2A2-2). The same happens on a smaller scale after any rollback within 5 minutes of a cached fetch. | `DateExtensions.kt` `isCacheStale`; `DeviceCache.kt:275-276`; AC-1 "A successful check means ..." and "so an honest user whose clock was once wrong is not locked out". | State in AC-1: whenever the app needs a successful check (app start, return to foreground, the paused screen's retry, and after any counted backward step), it calls `invalidateCustomerInfoCache()` and then `getCustomerInfo()`, so the answer comes from the network when RevenueCat is reachable. Add the missing tests: wrong-year clock (ahead, then corrected) with the network up unpauses on the next check and stays on across restarts; a `verifiedOnDevice` answer with a forward clock resets nothing and does not move the stored trusted time. Level 3 confirms the same invalidate behavior on iOS if iOS ships. |
| L2A5-2 | should-fix | L2 W5 §1 abuse checks vs L2 W3 AC-1 | AC-1 now names two residual risks for Aedwon's acceptance at E14. The W5 list of accepted risks "listed for Aedwon's acceptance at E14" still has only refund-then-stay-offline. W5 runs E14, so the open clock-setback decision may never reach Aedwon there. | W5 lines 33-36; AC-1 "Residual risks for Aedwon's acceptance at E14 (gates L2A-4, L2A4-2)". | Add the clock-setback residual to the W5 list, worded as an open decision with the lead's recommendation, not as already accepted. |
| L2A5-3 | should-fix | L2 W3 §10 AC-7 vs §3 Pass ledger and Season Pass end | AC-7 defines coverage as the union over "all active subscriptions and non-subscription purchases RevenueCat reports". On the phone, non-subscription purchases are `nonSubscriptionTransactions`: every consumable ever bought, with no end date and no exam id. Read literally, a pass bought for a past sitting, or a refunded pass, covers forever, and the exam comes from nowhere. §3 says passes come only from the server ledger's active records (gate L2A-8), and AC-4 binds the exam to the verified transaction. The two rules contradict, and the literal one reopens CX-3 and CX-4. The server side has the same risk with the REST `non_subscriptions` list. | `customer_info_wrapper.dart:23`; §3 Pass ledger and Season Pass end; AC-4; AC-7 new first sentence. | Reword the union: active subscriptions of known products, active passes from the pass ledger only, and active `promo_*` entitlements. A non-subscription purchase grants nothing by itself; it reaches coverage only through a ledger record. Test: an old consumable transaction with no active ledger record covers no exam. |
| L2A5-4 | should-fix | L2 W3 §10 AC-1 residual; decision log review 4 entry | The open decision put to Aedwon misstates the attack and the cost of closing it. (a) The attack needs one reboot after the last successful check, not a reboot "before each session": after any reboot the elapsed-time term is gone, and from then on setting the clock back while the app is closed is invisible without further reboots. "Each needs several deliberate steps every session" overstates the effort. (b) "Closing them would need an online check the offline rule forbids" is not correct. Gate 4 option (b) closes the no-reboot part offline: store the boot's wall time (device clock minus elapsed time) and the elapsed time at every app start, and count any change within the same boot as a backward step. Only the per-session reboot variant then remains. Aedwon may decide differently with accurate costs. | AC-1 residual text; log line 789-791; gate 4 L2A4-2 fix (b). | Correct the residual text and the log entry: one reboot suffices; the no-reboot part can be closed offline at no honest cost (gate 4 option b); only the reboot-every-session variant needs acceptance. Keep the lead's recommendation, restated for the narrower residual, and leave the decision to Aedwon at E14. |
| L2A5-5 | note | Decision log level 3 list; AC-7 | L2A4-8 carried forward: AC-7 says "the setup steps tell Aedwon to grant giveaways only with the two entitlements below, and new products enter the product table before they go on sale", but no level 3 item or setup step records either. The new step to list and reissue existing promotional `pro` grants has no setup-step home either. | Log line 781-782 and review 4 entry; `level4-setup-steps.md`. | Add three items to the level 3 setup-step list: giveaways only with `promo_*`; new products enter the table before sale; list and reissue existing promotional `pro` grants before W3's release. |
| L2A5-6 | note | L2 W3 §10 AC-3 | "W5 re-checks both on the final build" now follows three deploy steps. W5 re-checks the webhook URL and that claims match RevenueCat, which covers the reconciliation result, so the meaning holds, but "both" is stale. | AC-3 last sentence; W5 line 37. | "W5 re-checks the webhook URL and that claims match RevenueCat on the final build." |
| L2A5-7 | note | L2 W3 §3 Entitlement `state` | `state` is a single value and now includes `unknown` ("adds no coverage"). Under the AC-7 union, a user with a known subscription and an unknown product must stay `active`. An implementor could set `state = unknown` whenever anything unknown appears, and some gate could read the state instead of `coversExam`. | §3 Entitlement; AC-7 "adds nothing and removes nothing". | Add: `unknown` applies only when nothing known is active; otherwise the state follows the known coverage, and the unknown item is only logged. |
| L2A5-8 | note | Strategy B7 | "Opus does not write implementation code" (unchanged) and "Any code the lead writes while integrating (conflict resolutions included)" (added) read as a conflict. | B7 lines 230 and 237. | Add "except integration conflict resolutions, reviewed as below" to the line that says Opus writes no implementation code. |

## Check summary

1. Successful check (AC-1): the `verified` plus strictly-later `requestDate` test works in `purchases_flutter` 10.8.0 and blocks cache, replay and `verifiedOnDevice`. It needs a forced fetch, or an honest user with a corrected clock stays paused while online (L2A5-1).
2. Clock-setback residual: correctly left open for Aedwon at E14, but missing from W5's E14 list (L2A5-2) and described with the wrong attack cost and closing cost (L2A5-4).
3. Coverage union (AC-7): consistent on phone and server for subscriptions and `promo_*`; the non-subscription clause conflicts with the pass ledger (L2A5-3). `promo_*` entitlements read from `entitlements.active` and `activeSubscriptions` both work in the Flutter SDK.
4. One-time reconciliation (AC-3): placement, approval and code path are right; P1 (v2 read-only) can enumerate customers.
5. Firestore rules: the diff does not change the claim shape or the rule comparison; `firestore.rules:18,22` still need W3's change as planned.
6. B7: the review gap is closed; one wording conflict (L2A5-8).
7. Traceability X-2 and X-11 still point at the right AC rows.
8. Tier 1 items under SUBAGENTS Part 7b (money and entitlement): L2A5-1, L2A5-3 and L2A5-4 go to the lead; L2A5-4 changes the record of an open decision for Aedwon.
