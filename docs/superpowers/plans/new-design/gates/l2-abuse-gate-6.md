# Level 2 abuse amendment gate review 6

Reviewer: independent gate reviewer (Opus), read-only, October 6, 2026. Author of none of the reviewed documents.
Target: `git diff 50f0341e f5a2be00` on origin/main (HEAD f5a2be00, equal to origin/main). Files: strategy B7, decision log, L2 W3 §3 and §10 (AC-1, AC-3, AC-7), L2 W5 §1, gate 5 report.
Closing check against: `gates/l2-abuse-gate-5.md` (L2A5-1 to L2A5-8).
Code facts: `purchases_flutter` 10.8.0 (pub cache, the version in `wt-int/pubspec.lock`), which pins `purchases-hybrid-common` 18.29.0, which pins `purchases-android` 10.16.0 (read from GitHub at those tags); integration worktree `scratchpad/wt-int`.
Settled and not reopened: the October 6 log decisions, the 10-minute backward-step rule, the 3-day window, the pass ledger as the source of passes, and the open E14 clock decision itself.

## Totals

- Blockers: 0
- Should-fix: 1
- Notes: 4
- Part A status: 6 resolved (L2A5-2, L2A5-3 apart from its test, L2A5-4, L2A5-6, L2A5-7, L2A5-8), 1 deferred correctly to level 3 (L2A5-5), 1 partly (L2A5-1: the fix is in, the tests are not). The open clock decision stays recorded for Aedwon at E14 in AC-1, W5 and the log.

Verdict: **Gate does not pass** (one should-fix: missing tests carried from gate 4 and gate 5).

## Evidence pasted

- `purchases_flutter-10.8.0/lib/purchases_flutter.dart:797` `getCustomerInfo()` takes no fetch policy; `:867` `invalidateCustomerInfoCache()` exists. Android plugin `PurchasesFlutterPlugin.java:655,676` calls `CommonKt.getCustomerInfo` and `CommonKt.invalidateCustomerInfoCache`.
- `purchases-hybrid-common` 18.29.0 `common.kt:884-889`: `Purchases.sharedInstance.getCustomerInfoWith(...)`, default policy. iOS `CommonFunctionality.swift:458`: `fetchPolicy: .default`; `:143-144` forwards `invalidateCustomerInfoCache()`.
- `purchases-android` 10.16.0 `PurchasesOrchestrator.kt:934-936`: `invalidateCustomerInfoCache()` calls `deviceCache.clearCustomerInfoCache(appUserID)`. `DeviceCache.clearCustomerInfoCache` removes both the timestamp and the cached customer info (`editor.remove(customerInfoCacheKey(appUserID))`). Gate 5 said it clears only the timestamp; it removes the cached answer too.
- `CacheFetchPolicy.default()` is `CACHED_OR_FETCHED`. `CustomerInfoHelper.getCustomerInfoCachedOrFetched` (10.16.0, lines 225-245): if a cached answer exists it is returned at once and a refresh runs in the background only if stale; if none exists, the SDK fetches from the network and returns that answer. So after `invalidateCustomerInfoCache()`, the next `getCustomerInfo()` returns a network answer when RevenueCat is reachable. The plan's assumption holds on Android. The only other source is `offlineEntitlementsManager.offlineCustomerInfo` (on-device, used on server errors), which AC-1 already refuses because it is not `verified`.
- `wt-int/lib/features/paywall/data/entitlement_snapshot_store.dart` (`payment_last_confirmed_entitlement_v1`) and `payment_entitlement_state.dart:26,44`: the app already keeps its own last confirmed entitlement, separate from the SDK cache.
- AC-1 tests line is unchanged from 50f0341e: "a cached answer does not reset the mark; a `verifiedOnDevice` answer does not count; repeated small setbacks pause Pro; a clock moved back during a session counts."
- AC-7 has no test line for "a non-subscription purchase ... never grants coverage by itself".
- W5 line 37: "clock setbacks hidden by a reboot before every session (W3 AC-1)) listed": one more closing parenthesis than opening ones in the sentence.
- Log review 5 entry lists the five level 3 setup-step items (Functions API and Blaze, the two `promo_*` entitlements, giveaways only with them, new products in the table before sale, list and reissue promotional `pro` grants before W3's release).
- Em dashes in added lines: none.

## Part A: closing check of gate 5

| ID | Status | Basis |
|---|---|---|
| L2A5-1 | partly | AC-1 now says: when Pro is paused, or a backward step was counted, and the phone is online, the app calls `invalidateCustomerInfoCache()` before `getCustomerInfo()`. Verified against the pinned SDK chain (evidence above): this yields a network answer on Android. The wrong-year case (clock ahead when cached, then corrected) is covered: the correction is either counted as a step or leaves the mark ahead until Pro pauses, and both trigger the forced fetch. The two tests gate 5 asked for (and gate 4 L2A4-10 before it) are still missing. The iOS confirmation gate 5 assigned to level 3 is not written down. See L2A6-1 and L2A6-4. |
| L2A5-2 | resolved | W5 §1 now lists the clock residual "as an open decision with the lead's recommendation to accept". Punctuation nit: L2A6-5. |
| L2A5-3 | resolved, test missing | AC-7 union is now active subscriptions of known products, passes from the pass ledger only, and active `promo_*`; "A non-subscription purchase in RevenueCat's lists never grants coverage by itself". Consistent with §3 Pass ledger, AC-3 `proUntil` and AC-4. The test gate 5 asked for is missing (L2A6-1). |
| L2A5-4 | resolved | Residual text corrected: it now needs automatic time off, RevenueCat blocked, and a clock change plus reboot before every session. The no-reboot part is closed offline by the boot wall time rule. The log entry is corrected in place with a dated note. The decision stays open for Aedwon at E14 with the lead's recommendation, in AC-1, W5 and the log. The residual is accurate: a setback below the stored mark is already visible across a reboot; only a setback that keeps the clock above the last reading and is hidden by a reboot is unseen. Follow-ups on the new rule: L2A6-2, L2A6-3. |
| L2A5-5 | deferred to level 3, correctly | The log's review 5 entry adds the three missing setup-step items to the level 3 list, next to the earlier Functions API, Blaze and `promo_*` items. AC-7's "the setup steps tell Aedwon" now has a home. |
| L2A5-6 | resolved | AC-3: "W5 re-checks the webhook URL and that claims match RevenueCat on the final build." Matches W5 line 39. |
| L2A5-7 | resolved | §3: "`unknown` applies only when nothing known is active; otherwise the state follows the known coverage and the unknown item is only logged". |
| L2A5-8 | resolved | B7: "Opus does not write implementation code, except integration conflict resolutions, reviewed as below." |

## Part B: new problems in the diff

| ID | Severity | Plan / section | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L2A6-1 | should-fix | L2 W3 §10 AC-1 and AC-7 tests | The honest-lockout fix (L2A5-1) and the pass-ledger-only rule (L2A5-3) have no named tests. Gate 4 (L2A4-10) and gate 5 (L2A5-1) both asked for the wrong-year test; this is the third round. Without it, nothing in W3's acceptance shows that a corrected clock unpauses an online user, which is the lockout L2A2-2 promised to prevent. The new boot wall time rule also has no test. | AC-1 tests line unchanged; AC-7 has no tests line. | Add to AC-1 tests: (1) clock ahead when RevenueCat cached an answer, then corrected, network up: the next check calls invalidate, gets a `verified` answer with a later `requestDate`, unpauses, and Pro stays on across restarts; (2) a `verifiedOnDevice` answer with a forward clock resets nothing and does not move the stored trusted time; (3) clock set back while the app is closed, same boot: counted as a backward step of that size; (4) a reboot with no clock change counts nothing. Add to AC-7: an old consumable transaction with no active ledger record covers no exam. |
| L2A6-2 | note | L2 W3 §10 AC-1 boot wall time | "Time since boot" is not pinned to a clock, and "same boot" and a tolerance are not defined. On Android the rule works only with `SystemClock.elapsedRealtime()` (counts deep sleep). Dart's `Stopwatch` and `uptimeMillis` stop during sleep: the computed boot wall time then rises while the phone sleeps, so a setback smaller than the sleep time is hidden (weaker detection; no honest lockout). The wall clock and the boot clock are read at slightly different moments, so the boot wall time wobbles by milliseconds and is "earlier" on about half of all starts; with no tolerance, "a backward step was counted" is true almost every start, which forces a network fetch and deletes the SDK cache each time (harmless to Pro, see L2A6-4, but it makes the trigger meaningless). The same clock choice applies to the existing L2A3-10 elapsed-time term. | AC-1 "device clock minus time since boot"; "on the next start in the same boot"; "elapsed time since it while the phone has not restarted". Flutter has no built-in boot clock. | Name the clock: Android `SystemClock.elapsedRealtime()` through a platform channel; level 3 names the iOS clock that counts sleep if iOS ships. Define same boot (for example Android `Settings.Global.BOOT_COUNT` unchanged, or time since boot larger than the stored value). Ignore boot wall differences under 1 second. |
| L2A6-3 | note | L2 W3 §10 AC-1 backward steps | Two detectors can count one setback twice. A setback made while the app is closed, in the same boot, is seen by the boot wall time rule (full size) and, if the clock now reads below the last stored reading, also by the reading-to-reading comparison. An honest manual correction of 6 to 10 minutes made shortly after closing the app could then count 12 to 20 minutes and pause Pro while offline. It clears on the next online check, so the cost is small. | AC-1 "Every backward step of the device clock ... adds to one running total" and the new "counts as a backward step of that size". | State that at app start the setback is the larger of the two measures, not their sum. |
| L2A6-4 | note | L2 W3 §10 AC-1 forced fetch | `invalidateCustomerInfoCache()` deletes the SDK's cached answer, not only its timestamp (gate 5's description was incomplete). If the forced fetch then fails (RevenueCat down, captive portal, flaky network), the SDK has no answer to give. AC-1 says a failed refresh inside the window stays silent, which is correct only if Pro comes from the app's own last confirmed entitlement (`entitlement_snapshot_store.dart` exists today), never from the SDK cache. The plan does not say this, and an implementor could read "Cached Pro" as the SDK cache. Gate 5's "level 3 confirms the same invalidate behavior on iOS" is also not recorded. | `PurchasesOrchestrator.kt:934-936`; `DeviceCache.clearCustomerInfoCache`; AC-1 "Cached Pro holds until ..."; "Inside the window a failed refresh stays silent". | Add to AC-1: "Cached Pro" is the app's own last confirmed entitlement; a forced fetch that fails leaves it unchanged. Add a level 3 item: confirm `invalidateCustomerInfoCache()` plus `getCustomerInfo()` returns a network answer on iOS if iOS ships. |
| L2A6-5 | note | L2 W5 §1 abuse checks | Unbalanced parenthesis: "(W3 AC-1))". The sentence still reads correctly. | W5 line 37. | Delete one closing parenthesis, or close the accepted-risk list after "Yearly" and drop the second. |

## Check summary

1. `invalidateCustomerInfoCache` exists in `purchases_flutter` 10.8.0 and, through hybrid-common 18.29.0 and `purchases-android` 10.16.0, removes the cached answer so the next default `getCustomerInfo()` fetches from the network. The plan's assumption holds on Android; iOS is unconfirmed (L2A6-4).
2. In-boot clock detection works on Android only with a boot clock that counts deep sleep, a same-boot test and a small tolerance (L2A6-2); it can double count with the existing step rule (L2A6-3). Neither causes wrong Pro access for an honest user beyond a brief offline pause.
3. The corrected residual is accurate and stays an open decision for Aedwon at E14 in AC-1, W5 and the log.
4. AC-7 now agrees with §3, AC-3 and AC-4 on passes.
5. Level 3 setup-step items from L2A5-5 are recorded in the log.
6. No contradiction found between the diff and the strategy, other plans or the log.
7. Tier 1 items under SUBAGENTS Part 7b (money and entitlement): L2A6-1, L2A6-2, L2A6-3 and L2A6-4 go to the lead. No new product decision for Aedwon.
