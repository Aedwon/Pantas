# Level 2 abuse amendment gate review 3

Reviewer: independent tier 2 reviewer (Opus), read-only, October 6, 2026.
Target: `git diff 48a8f575 b01f9e56` on origin/main (HEAD b01f9e56, equal to origin/main after fetch).
Closing check against: `l2-abuse-gate-2.md` (L2A2-1 to L2A2-15, plus the partials L2A-1, L2A-2, L2A-26).
Code facts: integration worktree `scratchpad/wt-int` at 1f79d880.
Policy read from origin/main: AGENTS.md, WORKFLOW.md, SUBAGENTS.md (Part 7b).
Settled and not reopened: Aedwon's October 6 answers in the decision log (no functions deployed, copy and limits, tier-named giveaways, the B7 model change).

## Totals

- Blockers: 1
- Should-fix: 4
- Notes: 6
- Part A status: 14 resolved, 4 partly (L2A2-1, L2A2-4, L2A2-14, L2A-1). Partials are counted once, through Part B.

Verdict: **Gate does not pass.**

## Evidence pasted

- `lib/features/paywall/data/revenuecat_sdk.dart:4,141`: `const _proEntitlementId = 'pro';` and `info.entitlements.active[_proEntitlementId]`. The app reads only the `pro` entitlement today.
- `lib/features/paywall/data/live_revenuecat_gateway.dart:48-52`: an active `pro` entitlement whose product is not one of the three SKUs becomes `Entitlement.activeUnknown(...)`, which is Pro.
- `firestore.rules:77-78`: `match /users/{uid} { allow read: if isOwner(uid);` and `isOwner` (line 13-15) requires a named, non-anonymous user. The `claimsChangedAt` location is readable without Pro.
- L2 W3 line 139 (unchanged by the diff): "W4f consumes W3's contracts. Opus implements and reviews (B7)."
- L2 W6 lines 21-23 (unchanged): "the lead asks Aedwon how the live backend was last deployed ... W6 reconciles with it and does not deploy." Line 96 (unchanged): "The live backend was deployed from code or settings not in the repository: stop".
- L2 W6 lines 119-121 (changed): "Executor: a non-Claude / per strategy B7 as amended October 6".
- L2 W5 line 38 (changed): "Before the first backend deploy, confirm that no user holds a `pro` claim and that RevenueCat's webhook URL points at the deployed function." L2 W6 §4: "W6 itself deploys after its review"; W5 runs last.
- `level4-setup-steps.md` Part 4 step 3 attaches the new products to entitlement `pro`; no step creates `promo_student` or `promo_civil_service`; no step enables the Cloud Functions API or confirms Blaze; lines 96 and 102 run `firebase functions:secrets:set`.
- `grep -c '—'` on added diff lines: 0.

## Part A: closing check of gate 2

| ID | Status | Basis |
|---|---|---|
| L2A2-1 | partly | Fixed as asked: effective time is never below the mark, and backward steps add to one running total. The new reset rule reopens the same attack through a cached answer. See L2A3-1. |
| L2A2-2 | resolved | A successful verified check resets the mark and clears the total. The fix for L2A3-1 must keep this behavior for a fresh server answer. |
| L2A2-3 | resolved | `claimsChangedAt` moved to `users/{uid}` (owner read, no Pro needed, rules line 78). Refresh after purchase, restore and one permission-denied sync. A 1-day margin covers late RENEWAL. |
| L2A2-4 | partly | The recorded fact (no functions ever deployed) removes the migration need. The confirming check sits in W5, which runs after the first deploys. See L2A3-3. |
| L2A2-5 | resolved | W6 §3 contract now says Node 22. |
| L2A2-6 | resolved | `recordGrant` removed from AC-7 and the W3 file list. `takedownShare` uses W6's `requireAdmin` (admin claim set only by Aedwon from the CLI, App Check, audit entry, denial test). `_admin.ts` is in W6 §8. |
| L2A2-7 | resolved | Named Pantas uids, maintained by Aedwon, each sandbox grant logged. |
| L2A2-8 | resolved | Level 3 confirms retry signing and widens the limit if needed. |
| L2A2-9 | resolved | "Every event type triggers reconciliation", list given as examples. |
| L2A2-10 | resolved | An inactive answer revokes only when its `requestDate` is newer than the active evidence. |
| L2A2-11 | resolved | Limits checked first, in a transaction with a counter document; the orphan cleanup names `upload/`. Wording leftover: see L2A3-8. |
| L2A2-12 | resolved | Fresh share limits for new anonymous accounts added to the W5 E14 list. |
| L2A2-13 | resolved | "Written only by server functions (the webhook and the reconciliation job)". |
| L2A2-14 | partly | Rewritten, but still broken: "Executor: a non-Claude per strategy B7 as amended". See L2A3-7. |
| L2A2-15 | resolved | AC-10 now precedes AC-11. |
| L2A-1 | partly | Closed for repeated small rollbacks; reopened by the cached-answer reset. See L2A3-1. |
| L2A-2 | resolved | Node 22 in W6 §1, §3 and §8. The live-backend question is answered: no functions were ever deployed. Stale text left elsewhere: see L2A3-4. |
| L2A-26 | resolved | Through L2A2-2. |

## Part B: new problems in the diff

| ID | Severity | Plan / section | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L2A3-1 | blocker | L2 W3 §10 AC-1 (line 147) | The new reset rule lets a cached RevenueCat answer count as a successful check. With RevenueCat blocked, the SDK returns its cached, still-verified customer info, and its `requestDate` is the old server time. AC-1 then "resets the mark to the trusted time and clears the total", and sets effective time to that old time plus elapsed time. Attack, no APK change: buy Weekly, block RevenueCat, set the clock back to inside the paid week before each start. Each start the cached answer "succeeds", moves the mark back, and clears the total. Pro then lasts indefinitely, far beyond the paid period plus 3 days. This also defeats the L2A2-1 fix. | AC-1: "A successful verified check resets the mark to the trusted time and clears the total"; AC-1: "After a successful check, effective time is the trusted time plus elapsed time since it". | Define a successful check as a fresh server answer: verified, and its `requestDate` newer than the newest trusted time already held. A cached or repeated answer never resets the mark, never clears the total, and never sets effective time. Keep the trusted-time high-water mark separately from the device-clock mark, so the honest reset (L2A2-2) still works. Tests: a cached answer after a clock rollback keeps Pro paused; a fresh answer after a wrong-year clock unpauses Pro and stays on across restarts. |
| L2A3-2 | should-fix | L2 W3 §10 AC-7 (line 153), AC-2 (line 148), §3 Entitlement | A promotional grant of the `pro` entitlement still has no defined tier. RevenueCat lets anyone with dashboard access grant `pro` itself, not only the new `promo_*` entitlements. AC-7 says only that an unknown promotional entitlement grants nothing, and `pro` is a known entitlement. Client: today's code maps an active `pro` with an unknown product to `activeUnknown` (Pro), and the W3 `unknown` state has no defined coverage, so the grant can read as every tier. Server: AC-2 filters to products in the product table, so the same grant gives no claim. The client and the server then disagree, and the grant reads as the wrong tier. | `revenuecat_sdk.dart:141`, `live_revenuecat_gateway.dart:48-52`; AC-7 "a promotional entitlement the table does not know grants nothing". | State in AC-7: a `pro` entitlement whose product is not in the product table (promotional store or unknown product) grants nothing, on the client and the server, and is logged. Define `unknown` coverage in §3 as no tier (or Student only), never higher. Add tests on both sides. Add a step for Aedwon: before W3 ships, list any existing promotional `pro` grants in RevenueCat prod and reissue them as tier-named, so no giveaway winner loses Pro. |
| L2A3-3 | should-fix | L2 W5 §1 (line 38) vs L2 W3 AC-3 (line 149), L2 W6 §4 | Both deploy checks sit in W5, but W5 runs after W6 and W3 have deployed. (a) The "no user holds a `pro` claim" check must run before the first deploy of the `proUntil` rule (W3's rules deploy), or a stray claim without `proUntil` silently loses access. (b) If RevenueCat's webhook URL does not point at the deployed function when W3 deploys, no claim is ever set, and every honest paying user is denied sync and server Pro content until W5 runs. | W5 line 38; AC-3 "W5 confirms this before the first deploy"; W6 §4 "W6 itself deploys after its review". | Move both checks to the deploy steps: the claim inventory before W3's first rules deploy, and the webhook URL and a test event right after W3's functions deploy, each with Aedwon's approval. W5 re-checks them on the final build. |
| L2A3-4 | should-fix | L2 W6 §1 item 1 (lines 21-23), §7 (line 96) | Two passages still assume a live functions backend: the lead asks how it "was last deployed" and "W6 reconciles with it and does not deploy" (this also contradicts §4, which makes W6's package the first deploy), and the §7 stop condition. The real live state is the console setup: Firestore rules, Storage rules and settings that Aedwon set by hand. The first `firebase deploy` of rules overwrites the console rules, and no step records them first. | W6 lines 21-23, 96; W6 §4 "Aedwon set up the rest in the Firebase console". | Replace both with: before the first rules or functions deploy, the lead exports the live Firestore and Storage rules from each project, compares them with the repository, and reports any difference to Aedwon. Remove "does not deploy" or limit it to "does not deploy before its review". |
| L2A3-5 | should-fix | Strategy B7 amendment (line 221); L2 W3 §9 (line 139) | The amendment was not carried into W3: W3 §9 still says "Opus implements and reviews (B7)", which now contradicts B7 for the payments workstream. The amendment also does not say whether the Astra audit adds to or replaces the independent review. The reviewer line ("Opus for gate reviews and for W0 and W3 code review ... Never the author") survives only by implication. SUBAGENTS Part 7b requires a tier 2 independent review, and anything touching money or entitlement goes to the lead (tier 1). The amendment covers audit findings, but not the lead's acceptance of each W3 and W6 money or entitlement change. | Strategy lines 219-232; W3 line 139; W3 line 95 "Independent Opus code review (B7)"; SUBAGENTS Part 7b. | Add one line to B7: the Astra audit adds to, and does not replace, the independent tier 2 review, which stays as the reviewer line states (Opus for W0 and W3; W6 per its own §6). Add a second line: the lead accepts every money and entitlement change (W3, W6 rules). Change W3 §9 to "Built per B7 as amended; independent Opus review; Astra audit." |
| L2A3-6 | note | Level 3 plans, parallel map | Every L3 executor line (W0 "Executor: Opus", W3 "Executor and reviewer: Opus", W1, W2, W4a to W4h, W5 "Sonnet workers") and `L3-parallel-map.md` lines 39-40 contradict the amended B7, which applies from level 4. Out of level 2 scope. | L3 line 5 of each plan. | Level 3 updates them before the first dispatch. |
| L2A3-7 | note | L2 W6 §9 (lines 119-121) | The sentence is still broken: "Executor: a non-Claude per strategy B7 as amended". | W6 line 119. | "Executor: per strategy B7 as amended October 6 (...)". |
| L2A3-8 | note | L2 W4g AC-G2 (line 106) | The counting method is now stated two ways: "a transaction with a counter document" and "a count per window over its share records". There is also a lowercase sentence start: `make a new one.". the share screen`. | AC-G2. | Keep one method (the counter document, since it runs in the transaction). Capitalize "The". |
| L2A3-9 | note | `level4-setup-steps.md`; W6 §4 | W6 says the Cloud Functions API and Blaze steps "go in" the setup steps; they are not there yet. The existing secrets steps (lines 96, 102) need Blaze and the Secret Manager API, so they would run before the enabling step. No step creates the `promo_student` and `promo_civil_service` entitlements in RevenueCat, which AC-7 needs. | Setup steps Parts 1-4. | Level 3 adds "enable the Cloud Functions API, confirm Blaze" before the secrets steps, and "create the two promotional entitlements" in Part 4. |
| L2A3-10 | note | L2 W3 AC-1 | AC-1 gives two definitions of effective time: the later of the device clock and the mark, and "trusted time plus elapsed time" after a check. It does not say which governs, or what happens when the elapsed-time counter resets on reboot. | AC-1. | State: effective time is the later of (device clock, device mark, last trusted time plus elapsed time since it, when elapsed time is still valid). |
| L2A3-11 | note | L2 W3 AC-3 | The new 1-day `proUntil` margin gives server Pro (sync, server content) up to 1 day after a canceled plan or a pass ends without a final event. It is within the 3-day client window, but it is not stated as accepted. | AC-3 "plus a 1-day margin". | Add one line: accepted; a refund or revocation event removes the claim at once, because a refunded period is not active. |

## Check summary

1. AC-1 time rules: repeated small rollbacks are closed. A cached RevenueCat answer reopens them through the reset rule (L2A3-1, blocker). An honest user with a once-wrong clock recovers after one fresh check (L2A2-2), and the L2A3-1 fix keeps that behavior.
2. AC-3 claim and refresh: the marker location, refresh triggers and margin work with the rules as they stand. Both deploy checks sit too late (L2A3-3).
3. AC-7: tier-named grants close the default-tier path. A promotional grant of `pro` itself still reads as an undefined tier on the client and as none on the server (L2A3-2).
4. B7 amendment: it does not contradict AGENTS.md or WORKFLOW.md. Workers follow SUBAGENTS.md, and the author never reviews. It leaves W3 §9 contradicting it, and it does not state that the tier 2 review and the lead's entitlement acceptance remain (L2A3-5).
5. No live functions: W3 and W5 now reflect it. W6 §1 and §7 still assume a live backend and miss the console-set rules (L2A3-4).
6. Tier 1 items under SUBAGENTS Part 7b (money and entitlement): L2A3-1 to L2A3-3 and L2A3-5 go to the lead for ruling.
