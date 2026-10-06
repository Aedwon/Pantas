# Level 2 abuse amendment gate review 2

Reviewer: independent tier 2 reviewer (Opus), read-only, October 6, 2026.
Target: `git diff 1a547124 48a8f575` on origin/main (HEAD 48a8f575, equal to origin/main).
Closing check against: `gates/l2-abuse-gate-1.md` (L2A-1 to L2A-32).
Code facts: integration worktree `scratchpad/wt-int` at 1f79d880.
Policy: SUBAGENTS.md Part 7b. Settled and not reopened: the 3-day offline window, Google Play's trial rule.

## Totals

- Blockers: 1 (Part B)
- Should-fix: 9 (5 new in Part B; 4 carried from Part A as "partly")
- Notes: 10 (9 new in Part B; 1 carried from Part A)
- Part A status: 18 resolved, 8 partly, 3 deferred to level 3, 3 open decisions for Aedwon.
  Partials L2A-1, L2A-2 and L2A-26 are counted once, through Part B (L2A2-1, L2A2-5, L2A2-2).

Verdict: **Gate does not pass.**

## Evidence pasted

- `firestore.rules:92-95` (integration): `match /sync_state/{stateId} { allow read: if stateId == 'current' && isProOwner(uid); ... }`. `isProOwner` (line 21-23) requires `request.auth.token.pro == true`. Other `pro` readers: `isProUser` line 17-19, `proDossiers` line 193, `proContent` via `isProUser`.
- `functions/src/revenuecatPolicy.ts:47-80`: the signature header carries `t=` (Unix timestamp) and `v1=` HMAC over `${timestamp}.` + body. A signature-age check is feasible.
- `lib/core/sync/eligibility/sync_claim_gateway.dart:20`: `await user.getIdTokenResult(true)` (forced refresh exists in one place).
- L2 W6 line 58 (§3 contract table, unchanged by the diff): "`main: lib/index.js`, Node 20". Line 18 (§1, changed): "Node 22 in `engines` and `firebase.json`".
- Tier spec `2026-10-06-tier-pricing-design.md` B1 lines 78-80 still `{examId, sittingLastDay, purchasedAt, transactionId}`; B3 lines 95-97 still "the app sends the exam id as purchase metadata". The diff does not touch the spec.
- L3 W3 lines 31, 54, 89, 94, 188 still name "Task 1's runner" and `endsAt: null` (level 3 owns these).
- `grep -c '—'` on added diff lines: 0.

## Part A: closing check of gate 1

| ID | Status | Basis |
|---|---|---|
| L2A-1 | partly | High-water mark added, but a 10-minute tolerance that is not cumulative reopens repeated backdating. See L2A2-1. |
| L2A-2 | partly | Node 22 in W6 §1 item 1, `firebase.json` in W6 §8, and the Oct 30 redeploy question for Aedwon in W6 §4. W6 §3 contract still says Node 20. See L2A2-5. The live-backend redeploy is an open decision for Aedwon, before October 30. |
| L2A-3 | resolved | AC-1: a verified answer is judged by its own `requestDate`; a verified inactive answer revokes. |
| L2A-4 | resolved | AC-1 residual risk line; W5 §1 E14 list now includes refund then stay offline, with Yearly exposure. |
| L2A-5 | partly (should-fix carried) | Resolved: `proUntil` covers subscriptions, passes and grants; RENEWAL and INITIAL_PURCHASE are named; the comparison uses `toMillis()`; token refresh is specified. Open: AC-3 says "Rules compare it" without naming every rule that reads `pro` (`isProUser`, `isProOwner`, `proDossiers`, `sync_state`). The permission-denied refresh trigger is dropped. See also L2A2-3 and L2A2-4. |
| L2A-6 | resolved | AC-2 filters the reconciled answer; adds a sandbox tester allowlist in prod (lead decision, logged). The allowlist key is undefined: see L2A2-7. |
| L2A-7 | resolved | AC-3: signature age 5 minutes; stored answer time; a stale write is refused inside the transaction. |
| L2A-8 | partly (should-fix carried) | L2 W3 §3 is now keyed by `transactionId` with an `examId` field. Tier spec B1 and B3 are not amended ("changes go up first"), so the spec and L2 disagree on the record shape and the binding. The L3 Task 5 changes (`endsAt: null`, revoked state, key) are deferred to level 3. |
| L2A-9 | resolved | AC-4 names the refund-signal check for level 3, a stop rule, and a fallback, and states that choosing between the two CSE exams is acceptable. |
| L2A-10 | resolved | AC-G2: create-only upload path, PNG signature and size check, server-only copy, and admin takedown with an audit entry. |
| L2A-11 | open decision for Aedwon | Numbers and two proposed messages are marked for his approval. The owner (share screen) and the error (`resource-exhausted`) are named. |
| L2A-12 | partly (should-fix carried) | `paused` is added to the W3 state, and W4f §3 consumes it. Pro gates also live in other families (for example W4e `MK_PastFreeLocked`, `MK_ResultsFree`). No plan says those gates show the paused line rather than the Free upsell. Name one shared gate owner, or amend each gate's owner. |
| L2A-13 | resolved | W6 §3 `allowAtMost`; W4g counts its own share records. |
| L2A-14 | partly (should-fix carried) | One deploy policy, aligned in W3 §9, W4g §7 and W6 §4. Missing: the requested line that the lead reports whether the CX-1 and CX-7 holes are live today. Under per-workstream deploys, CX-1 stays live until W4g deploys. |
| L2A-15 | partly (note carried) | (a), (c) and (d) are resolved. (b): W3 and W4g both edit `index.ts` "after W6 Task 1", with no W3-then-W4g order. Low risk because only export lines change. |
| L2A-16 | resolved | L2 W3 §9: functions tasks start after W6 Task 1. The L3 W3 Task 1 and parallel-map edits are deferred to level 3. |
| L2A-17 | resolved | Verdict table row split; CX-16 is W3. |
| L2A-18 | resolved | 730 days (D8); orphan definition per the auth spec; active anonymous users are kept. |
| L2A-19 | open decision for Aedwon | W6 §9 defaults to B7 (Opus for rules, Sonnet otherwise) "unless Aedwon approves the Codex split (asked Oct 6)". |
| L2A-20 | resolved | AC-5 and AC-11: "Transfer to new App User ID" (lead decision, logged), tested. |
| L2A-21 | resolved | W5 §1 records the deployed revisions and compares them with the integrated commit. |
| L2A-22 | resolved | W6 §1 item 3: only the audit write is throttled; `ensurePublicId` always runs. |
| L2A-23 | resolved | AC-G2 accepts it explicitly. It is missing from the W5 E14 list: see L2A2-12. |
| L2A-24 | deferred to level 3 | Unchanged; the finding assigns it to level 3. |
| L2A-25 | deferred to level 3 | Unchanged; the finding assigns it to level 3. |
| L2A-26 | partly | Effective time after a check is defined. The mark is never reset, so an honest user stays paused. See L2A2-2. |
| L2A-27 | resolved | "Contracts consumed" and "Aedwon's check: none visual" added. |
| L2A-28 | resolved | Log now says 17 and 2. |
| L2A-29 | resolved | Rule-update ownership stated; Storage emulator is in the runner. |
| L2A-30 | resolved | The deploy check is an Aedwon-run step. |
| L2A-31 | open decision for Aedwon | AC-7 fallback and the `exportData` text are both marked for his approval (log lists them). |
| L2A-32 | deferred to level 3 | AC-G2: "level 3 sets both". |

## Part B: new problems in the diff

| ID | Severity | Plan / section | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L2A2-1 | blocker | L2 W3 §10 AC-1 | The 10-minute tolerance compares one reading with the mark and is not cumulative. It also does not say that effective time never goes below the mark. Attack: buy Weekly, block RevenueCat, and before each session set the clock to (mark minus 9 minutes). No single check sees a rollback over 10 minutes. Paid time is then used only while the app runs, so a 10-day window (7 paid days plus 3) lasts for months of real use. This is the CX-2 clock scenario that L2A-1 blocked on, and it needs no APK change. | AC-1: "if the device clock is ever earlier than the mark by more than 10 minutes, the offline window counts as used". | Effective time = max(device clock, mark), so time never runs backward. Add every backward step since the last successful check to one total. If the total exceeds 10 minutes, the window counts as used. Add tests: repeated 9-minute setbacks pause Pro; one 2-minute time-sync correction does not. |
| L2A2-2 | should-fix | L2 W3 §10 AC-1 | The mark is never reset after a successful check. Suppose an honest user's clock once ran far ahead, for example a wrong year, and is then corrected. The device clock stays earlier than the mark, so every start pauses Pro again, even after each successful check. This is a paying user locked out. | AC-1 defines effective time after a check but not the mark after a check. | A successful verified check sets the mark to the trusted time and clears the rollback total. Add a test: clock a year ahead, then corrected, then one check, then Pro stays on across restarts. |
| L2A2-3 | should-fix | L2 W3 §10 AC-3 | The `claimsChangedAt` marker sits on the user's sync state. The integration rules let only `isProOwner` read `sync_state/current`, and AC-3 adds `proUntil > now` to that check. So the app cannot read the marker when it needs it: a first purchase or pass (no `pro` claim yet), or a renewal processed after the old `proUntil` passed. The claim "a renewal moves `proUntil` before the old one passes" cannot hold, because Play renews at period end and the RENEWAL event arrives after it. Gate 1 also asked for a refresh on permission-denied; AC-3 dropped it. | `firestore.rules:92-95`; AC-3 text. | Put the marker on `users/{uid}`, which the owner reads without Pro. Force a token refresh after purchase and restore, when the marker changes, and on a permission-denied sync. Either add a small margin to `proUntil` (level 3 sets it) or state that sync retries after a refresh near period end. |
| L2A2-4 | should-fix | L2 W3 §10 AC-3, §9 deploy | No migration for current Pro users. Their claims have `pro: true` and no `proUntil`. In rules, comparing a missing token field fails, so access is denied. Once the new rule deploys, every current subscriber loses sync and server Pro content until their next RevenueCat event. For Yearly subscribers that can take up to a year. | AC-3 rule text; W3 §9 per-workstream deploy. | Before the rule deploys, a one-time job reconciles every user with `pro == true` and sets `proUntil`. Deploy order: functions and backfill first, rules after. Add a rules test for a token with no `proUntil` and a check that the backfill ran. |
| L2A2-5 | should-fix | L2 W6 §3 contract table vs §1 item 1 | The Functions package contract still says "Node 20". §1 and §8 say Node 22. Implementors follow the contract table, and W3 and W4g are told to use "this contract". | W6 line 58 vs line 18. | Change the contract row to Node 22 (`engines` and `firebase.json`). |
| L2A2-6 | should-fix | L2 W3 AC-7 `recordGrant`; L2 W4g AC-G2 `takedownShare` | Neither plan defines what "admin-only" checks. `recordGrant` writes grant records that feed `proUntil` (AC-3), so it can grant server Pro and tiers. An undefined admin check on a Pro-granting endpoint is an entitlement hole. | AC-7, AC-3, AC-G2. | Define one server-side admin check, either a server-held uid allowlist or an `admin` claim set only from the CLI by Aedwon. Require App Check and an audit entry. Accept no tier or end date the server cannot check. Test: a non-admin call is denied. State that `recordGrant` reconciles the user's claim. |
| L2A2-7 | note | L2 W3 AC-2 | The tester allowlist does not say what it lists. The webhook sees the Pantas uid (RevenueCat app user id), not the Play tester's Google account. Anonymous uids change on reinstall. | AC-2 "accounts on a server-side tester allowlist". | List named Pantas uids, maintained by Aedwon, and log each sandbox grant in prod. |
| L2A2-8 | note | L2 W3 AC-3 | A 5-minute signature age may refuse RevenueCat retries if retries keep the original `t=`. A lost refund or cancellation then keeps the claim until `proUntil`. | `revenuecatPolicy.ts` `t=` handling; AC-3. | Level 3 confirms how retries are signed. If retries keep the original time, rely on the AC-4 daily reconciliation for subscriptions too, or widen the age limit. |
| L2A2-9 | note | L2 W3 AC-3 | The event list omits `SUBSCRIPTION_EXTENDED`, `SUBSCRIPTION_PAUSED`, `TEMPORARY_ENTITLEMENT_GRANT` and `REFUND_REVERSED`. Because each event reconciles from current state, the safe rule is "every event type reconciles". | AC-3 list. | State "every event type triggers reconciliation", with the list as examples. Level 3 confirms that the REST version used (L3 W3 line 46 says v2) returns a request time and a sandbox flag per purchase. |
| L2A2-10 | note | L2 W3 AC-1 | "A verified inactive answer always revokes" also revokes on a cached inactive answer older than a newer active one, for example the SDK cache from before a purchase. | AC-1. | Revoke only when the inactive answer's `requestDate` is newer than the active evidence held. |
| L2A2-11 | note | L2 W4g AC-G2 | The limit checks run after the copy and are not in a transaction. Parallel calls can pass the 10-a-day and 50-live limits. Uploads left in `upload/` by an abandoned share need the W6 orphan job to scan that prefix. | AC-G2 order of steps; W6 §1 item 5. | Check limits first, in a transaction (or with a counter document). Name `upload/` in the orphan cleanup. |
| L2A2-12 | note | L2 W5 §1 | The accepted risk "new anonymous accounts get fresh share limits" (AC-G2) is missing from the E14 list Aedwon accepts. | W5 §1 list. | Add it to the E14 list. |
| L2A2-13 | note | L2 W3 §3 pass ledger vs AC-4 | The ledger says "Written only by the webhook", but the AC-4 fallback adds a daily reconciliation that writes it. | §3; AC-4. | Say "written only by server functions (webhook and reconciliation)". |
| L2A2-14 | note | L2 W6 §9 | The edit left a broken sentence: "Executor: is per strategy B7 unless ...". | W6 §9. | Rewrite: "Executor: per strategy B7 unless ...". |
| L2A2-15 | note | L2 W3 §10 | AC-11 is listed before AC-10. | W3 table. | Reorder. |

## Check summary

1. Contradictions: W6 §3 vs §1 runtime (L2A2-5). Tier spec B1 and B3 vs L2 W3 §3 ledger (L2A-8). The pass ledger writer (L2A2-13). W3, W4g, W6 and the strategy agree on deploy policy. Traceability X-1 to X-19 owners match the plans; X-16 now matches the verdict table.
2. Closure: AC-1 does not close repeated small rollbacks (L2A2-1) and can lock honest users (L2A2-2). AC-3's claim mechanics do not work as written: the marker is unreadable when needed (L2A2-3), and current Pro users have no backfill (L2A2-4). `request.time.toMillis()` compared with a number claim is valid rules syntax. `recordGrant` is an undefined admin path to Pro (L2A2-6).
3. Payments and entitlement items are tier 1 under SUBAGENTS Part 7b: L2A2-1 to L2A2-4 and L2A2-6 go to the lead for ruling.
