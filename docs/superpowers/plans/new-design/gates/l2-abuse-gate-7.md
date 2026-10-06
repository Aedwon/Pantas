# Level 2 abuse amendment gate review 7

Reviewer: independent gate reviewer (Opus), read-only, October 6, 2026. Author of none of the reviewed documents.
Target: `git diff f5a2be00 9bf62e5a` on origin/main (HEAD 9bf62e5a, equal to origin/main). Files: L2 W3 §10 AC-1 and AC-7, L2 W5 §1, gate 6 report (added).
Closing check against: `gates/l2-abuse-gate-6.md` (L2A6-1 to L2A6-5).
Settled and not reopened: the October 6 log decisions, the 10-minute backward-step rule, the 3-day window, the pass ledger as the source of passes, and the open E14 clock decision.

## Totals

- Blockers: 0
- Should-fix: 0
- Notes: 3
- Part A status: 4 resolved (L2A6-1, L2A6-2, L2A6-3, L2A6-5), 1 resolved in the plan with its level 3 item unrecorded (L2A6-4).

Verdict: **Gate passes** (no blockers, no should-fix; three notes for the lead).

## Evidence

- AC-1 tests line now adds: wrong-year clock corrected online invalidates the cache and unpauses; a same-boot closed-app setback counts once; a reboot then an ordinary start does not pause; RevenueCat down after the cache clear keeps Pro from the app's own last confirmed entitlement.
- AC-7 now carries: "tests: an old or refunded pass in RevenueCat's purchase list with no active ledger record covers nothing, L2A6-1".
- AC-1 boot rule now names `SystemClock.elapsedRealtime()`, a 2-second tolerance, and "a new boot is an elapsed time lower than the stored one".
- AC-1: "One setback is counted once, by whichever detector sees it first (L2A6-2, L2A6-3)."
- AC-1: "Cached Pro in this AC always means the app's own last confirmed entitlement (`entitlement_snapshot_store.dart`), never the SDK's cache, so a failed forced fetch changes nothing (L2A6-4)."
- W5 line 37: "(W3 AC-1) listed", parentheses balanced.
- The diff does not touch the decision log or any level 3 list; W3 does not mention iOS. W5 §1 runs "the same functional checklist on the iPhone" on the iOS build.
- Em dashes in added lines: none.

## Part A: closing check of gate 6

| ID | Status | Basis |
|---|---|---|
| L2A6-1 | resolved | All four AC-1 tests gate 6 asked for are present in substance (the `verifiedOnDevice` case is covered by the existing line). The AC-7 pass-ledger test is present. |
| L2A6-2 | resolved | The clock is named and counts deep sleep; same boot is defined by elapsed time going down; a 2-second tolerance stops the per-start false step. Misreading a new boot as the same boot (uptime now above the stored value) is harmless: an honest reboot always gives a later boot wall time, so nothing is counted. Remaining gaps are notes L2A7-1 and L2A7-2. |
| L2A6-3 | resolved | Double counting is now forbidden. The chosen wording differs from gate 6's "larger of the two"; see L2A7-2. |
| L2A6-4 | partly (plan resolved) | The AC-1 definition and a test are in. Gate 6's second fix, a level 3 item to confirm `invalidateCustomerInfoCache()` plus `getCustomerInfo()` gives a network answer on iOS, is not recorded anywhere in the diff. Folded into L2A7-1. |
| L2A6-5 | resolved | Extra parenthesis removed. |

## Part B: new problems in the diff

| ID | Severity | Plan / section | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L2A7-1 | note | L2 W3 §10 AC-1 boot rule | The boot rule names an Android-only API, while W5 runs the same functional checklist on the iOS build. An implementor has no named iOS clock and no stated iOS behavior. If the platform call is missing on iOS and the error is not handled, entitlement start-up could fail on iPhone; if it is handled by skipping, detection is just weaker. The iOS invalidate confirmation from L2A6-4 is also still unrecorded. No wrong Pro access on Android, and iOS is not stated to ship to users. | AC-1 "device clock minus `SystemClock.elapsedRealtime()`"; W5 line 28-29. | Add one sentence: on iOS, use a clock that counts sleep (for example `mach_continuous_time`), or skip the boot rule; a failed platform call never changes Pro. Add a level 3 item for both iOS checks if iOS ships. |
| L2A7-2 | note | L2 W3 §10 AC-1 counting once | "Whichever detector sees it first" does not say which runs first at app start, where both run together. If the reading-to-reading comparison runs first, it counts only the part of the setback below the last reading (setback minus time closed), so the setback is undercounted. It also does not say how an in-session step is marked as seen, so the boot detector does not count it again on the next start in the same boot; an implementor who misses this can double count a 6 to 10 minute honest correction and pause Pro offline until the next online check. Both effects are small. | AC-1 "One setback is counted once, by whichever detector sees it first". | Say: at app start, count the larger of the two measures; after any counted step, store the boot wall time again from the current clock. |
| L2A7-3 | note | L2 W3 §10 AC-1 trusted-time term | The L2A3-10 term "the last trusted time plus the elapsed time since it while the phone has not restarted" still does not name its clock. The new boot rule names `elapsedRealtime()` and defines a restart, so the implementor will likely reuse them, but the text does not say so. A clock that stops in sleep would make this term lag (weaker floor, no honest lockout). | AC-1 effective time sentence. | Add "(elapsed time and restart as in the boot rule)". |

## Check summary

1. All gate 6 items are fixed in the plans, apart from the unrecorded iOS level 3 item.
2. No change in the diff gives wrong Pro access or locks out an honest user beyond a brief offline pause that the next online check clears.
3. No contradiction with AC-3, AC-4, AC-7, W5 or the log was found in the diff.
4. No new product decision. The 2-second tolerance and the new-boot test are engineering choices within gate 6's suggestions.
5. Tier 1 items under SUBAGENTS Part 7b (money and entitlement): L2A7-1, L2A7-2 and L2A7-3 go to the lead.
