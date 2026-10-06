# Level 3 abuse gate review 2

Reviewer: independent level 3 gate reviewer; not an author of the reviewed documents. Date: October 6, 2026.
Policy revision read: origin/main 488d088a (AGENTS.md, SUBAGENTS.md Part 2). Main checkout HEAD equal to origin/main after fetch.
Scope: closing check of L3X-1 to L3X-19 against `git diff d9ea8406 488d088a`, then new problems in that diff only.
Code facts: read-only worktree `wt-int` at 1f79d880; purchases_flutter 10.8.0 in the pub cache; Node test runner behavior tried locally (Node 26.7.0).
Nothing was edited, committed or pushed in the repository.

Totals: 0 blockers, 3 should-fix, 5 notes.

Gate verdict: Gate does not pass (3 should-fix).

Hygiene: the only em dash in added lines is inside a quoted grep command in `gates/l3-abuse-gate-1.md` l.19. Commit 488d088a has no attribution trailer.

---

## Part A. Closing check

| ID | Status | Evidence |
|---|---|---|
| L3X-1 | Resolved | W6 Task 1: behavior tests import `../lib/`, `.ts` test converted to `.behavior.test.mjs`, `sync-generation.policy.mjs` renamed to `sync-generation.behavior.test.mjs` importing `../lib/syncGenerationPolicy.js`; facts line corrected. tsconfig (`NodeNext`, no `"type": "module"`) emits CommonJS, and Node's named-export detection reads tsc's `exports.x =` output, so the `.mjs` named imports work. New glob defect: L3X2-1. |
| L3X-2 | Resolved | `--only auth,firestore,storage --project demo-pantas-test`; `firebase-tools` dev dependency; Java named. `firebase.json` configures all three emulators and `storage.rules`; the CLI finds `firebase.json` in the parent folder. |
| L3X-3 | Resolved | W6 Task 3b integrates Tasks 1 to 3 after audit and review; deploys stay in Task 7; map dependency row and wave 2 cell updated. No deadlock: Task 3b waits on nothing from W3 or W4g. New contradiction: L3X2-2. |
| L3X-4 | Resolved | W3 Task 2 step 2: function server time taken before the v2 read; recorded in the restart log. |
| L3X-5 | Resolved | W3 Task 11 names `MainActivity.kt` (`pantas/trusted_clock`, `elapsedRealtime`) and `revenuecat_bootstrap.dart` with `entitlementVerificationMode = EntitlementVerificationMode.informational` (field and value confirmed in 10.8.0 `purchases_configuration.dart` l.59, `entitlement_verification_mode.dart` l.14). Map row added. L2 W3 §8 was not amended, but the L3 plan's file list and the map now name the file, which is what SUBAGENTS Part 2 checks. iOS: note L3X2-7. |
| L3X-6 | Resolved | W3 Task 2 step 7 and files add `syncGenerationPolicy.ts`; `proUntil > Date.now()` matches the rules' millisecond unit; a missing `proUntil` fails both. Map row "W6 Task 3, then W3 Task 2". Test added. |
| L3X-7 | Resolved, with note L3X2-5 | Execution order stated in the W3 header and the map cell. |
| L3X-8 | Resolved | Task 7 defers to Task 13; Task 13 names `StoreProduct.subscriptionOptions` and `freePhase` (both in 10.8.0). |
| L3X-9 | Partly resolved | `paused` added to W4f Task 6 with the line and a test; the gate behavior contradicts L2: L3X2-3. |
| L3X-10 | Resolved | Live-link count by query on `wrapped_shares` (`ownerUid`, `revoked == false`); test "remove one at 50, next create succeeds". The daily counter document is written in the same transaction, so concurrent creates by one user still serialize. |
| L3X-11 | Resolved | Create that fails if `shareId` exists; cross-user test added. Side note L3X2-6. |
| L3X-12 | Resolved | Setup Part 4d; W6 Task 7 references it. |
| L3X-13 | Resolved | W3 Tasks 2, 5, 10 and 14 in both map rows. |
| L3X-14 | Resolved | W6 Task 1 step 4 and W3 Task 4 each add their JSON with a built-`lib/` test. |
| L3X-15 | Resolved | Task 2 tagged AC-10; Task 11 test "a `failed` verification result grants nothing". |
| L3X-16 | Resolved | `test/tools/release` in the check; `firebase crashlytics:symbols:upload` named; bootstrap-key risk added; "final release candidate build". |
| L3X-17 | Resolved | `logIn(newUid)` on every sign-in and switch; `logOut` only with no Firebase user, anonymous-user error ignored and tested. |
| L3X-18 | Resolved | W0 and W4g final steps name the Astra audit and Opus review. |
| L3X-19 | Resolved | Setup Part 4e (`config/testers`, field `uids`); empty means no sandbox purchase counts. The catch-all rule at `firestore.rules:225` keeps `config` client-closed. |

---

## Part B. New findings

| ID | Severity | Plan and task | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L3X2-1 | should-fix | L3-W6 Task 1 (test script); W6 Task 5, W3 Tasks 2 and 10, W4g Task 3b (emulator tests) | The new `npm test` first stage `node --test test/*.test.mjs test/*.behavior.test.mjs` runs outside the emulators, and `test/*.test.mjs` also matches every `test/*.emulator.test.mjs`. Each emulator test therefore runs first with no `FIRESTORE_EMULATOR_HOST` or `FIREBASE_AUTH_EMULATOR_HOST` set, so it fails (or the Admin SDK tries a real project with no credentials), and `npm test` exits nonzero before the emulator stage starts. The defect stays hidden in Task 1 (a stub that touches no emulator passes) and appears in W6 Task 5's cleanup tests, the first real emulator tests. The `behavior` files match both globs; Node 26 runs each once, Node 22 was not tried. | Local run: a file `y.emulator.test.mjs` ran under `node --test test/*.test.mjs test/*.behavior.test.mjs`; L3-W6 l.27-29, l.96. | Give emulator tests a suffix the first glob does not match, for example `*.emulator.mjs` (like `*.rules.mjs`), and drop the redundant `test/*.behavior.test.mjs` from the first stage. Add to the Task 1 test: an emulator-stage file is not run by the first stage. |
| L3X2-2 | should-fix | Map row `functions/src/index.ts`; W6 Tasks 3b, 4, 5; W3 Tasks 5 and 10 | The order row still says "W6 Tasks 1, 4, 5, then W3 (new exports)". W3's functions tasks now start after W6 Task 3b (Tasks 1 to 3 only), while W6 Tasks 4 and 5 edit `index.ts` afterwards (remove `getProContent` and `purgeOldExports`, add `cleanupWrappedOrphans`), and W6 integrates them only in Task 8, after the Task 7 deploys that wait on Aedwon. W3 adds exports (`recomputePassEnds`, `publicIdAdmin`). To obey the row, W3 must wait for W6 Task 8, which recreates the L3X-3 wait on production deploys. | L3-parallel-map l.89; L3-W6 Task 3b, Task 4 l.79-81, Task 5, Tasks 7 and 8; L3-W3 Task 5 step 3, Task 10. | Either move W6 Tasks 4 and 5 into the Task 3b slice, or change the row to "W6 Task 1, then W3 and W6 Tasks 4 and 5 in either order; the lead merges export lines at integration". |
| L3X2-3 | should-fix | L3-W4f Task 6 (paused, AC-1) | L2 W4f §2 (amended Oct 6) says "the Pro page and paused gates show the approved paused line". L3 now says other families' Pro gates "show their normal Pro invitation" while paused. A paying student who is offline past the window would see an offer to buy Pro instead of "Connect once to keep using Pro.", which can prompt a second purchase. This changes approved behavior and copy placement without a recorded decision. | L2-W4f l.43-44; L3-W4f l.86-89. | Follow L2: gates show the paused line when `state == paused` (name the owner: W4f provides a shared paused gate widget, or each W4 family's gate placeholder reads it). Or record Aedwon's decision that gates show the normal invitation and amend L2 W4f §2. |
| L3X2-4 | note | L3-W3 Task 1 | Task 1 still says "Rebase onto the integration branch after W6 Task 1 lands"; the header and map now say after W6 Task 3b. | L3-W3 l.38-40 vs l.7-9. | Say "after W6 Task 3b". |
| L3X2-5 | note | L3-W3 Task 2 step 4 vs order | Task 2 runs before Task 5 (forced: Task 5 writes inside Task 2's transaction) and before Task 13's TS half, yet step 4 defines `proUntil` from subscriptions, ledger passes and `promo_*`. A test-first worker cannot test the pass part in Task 2. | L3-W3 header l.8-9; Task 2 step 4; Task 5 step 2. | State that Task 2 covers subscriptions and `promo_*`, Task 5 adds passes, and Task 13's TS half moves the calculation onto the shared rule and vectors. |
| L3X2-6 | note | L3-W4g Task 3b step 2 | Storage side effects inside a retried Firestore transaction: if the copy and upload delete run in the transaction body, a contention retry finds the upload gone and fails an honest create. Also, a client retry with the same `shareId` after a lost response is refused although the link exists. | L3-W4g l.48-54. | Check and copy before the transaction, delete the upload after commit; treat an existing record owned by the caller as success. |
| L3X2-7 | note | L3-W3 Task 11 (iOS) | "`ProcessInfo.systemUptime` is not continuous" is correct, but Darwin has a continuous clock (`clock_gettime(CLOCK_MONOTONIC)` / `mach_continuous_time`), so skipping the boot detector on iOS is a choice, not a limit. Harmless while App Store purchases are out of beta scope (W5 Task 6). The Dart wrapper must also treat a missing channel (`MissingPluginException`: iOS, tests, background isolates) as "no reading", never as a setback. | L3-W3 l.234-238; L3-W5 Task 6 last lines. | If Aedwon brings App Store purchases into scope, implement the iOS channel or add the gap to the E14 list. Add a wrapper test for the missing channel. |
| L3X2-8 | note | L3-W3 Task 2 step 2 (answer time) | The function clock taken before the read is a lower bound on the answer's freshness; two overlapping reads can be ordered wrongly by the read latency (seconds). Both reads follow the events that caused them, and every later event reconciles again, so no wrong Pro access results. L2 AC-3's "RevenueCat answer's own time" wording now differs from L3; the restart log records the change. | L2-W3 AC-3; restart log Oct 6 entry. | None needed; optionally amend the AC-3 wording at L2 for traceability. |

Not checked: no builds, tests or emulators were run in the repository; Node 22 glob deduplication; Firestore Admin `Transaction.get(AggregateQuery)` support in the firebase-admin version W6 Task 1 will pick (supported in current @google-cloud/firestore from memory, not verified against the chosen version).
