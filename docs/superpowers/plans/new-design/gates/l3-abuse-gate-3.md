# Level 3 abuse gate review 3

Reviewer: independent level 3 gate reviewer; not an author of the reviewed documents. Date: October 6, 2026.
Repository: origin/main 63978752 (main checkout HEAD equal). Code facts: read-only worktree `wt-int`.
Scope: closing check of L3X2-1 to L3X2-8 and L3X-9 (partly) against `git diff 488d088a 63978752`, then new problems in that diff only, with a focus on the new W2 component `ProPausedLine`.
Nothing was edited, committed or pushed in the repository.

Totals: 0 blockers, 0 should-fix, 4 notes.

Gate verdict: Gate passes.

Hygiene: no em dashes in added lines. Commit 63978752 has no attribution trailer (same as 488d088a).

---

## Part A. Closing check

| ID | Status | Evidence |
|---|---|---|
| L3X2-1 | Resolved | W6 Task 1: first stage is `node --test test/*.test.mjs`; emulator stage runs `test/*.rules.mjs test/*.emulator.mjs`; naming rule stated; Task 5 names `test/cleanup.emulator.mjs`. Tried locally (Node 26.7.0, `sh`): a `.behavior.test.mjs` file runs in the first stage, a `.emulator.mjs` file does not, and the emulator-stage glob with no `.emulator.mjs` file yet exits 0. No plan outside the gates still names `.emulator.test.mjs`. Existing `wt-int/functions/test/*.test.mjs` files are source-text checks with no emulator use. The suggested Task 1 self-test was not added; the naming rule is enough. |
| L3X2-2 | Resolved | Task 3b replaced by Task 5b (Tasks 1 to 5, audit, review, integration; deploys stay in Task 7). W3 header, W3 Task 1, W4g header, map dependency row, wave 2 cell and `index.ts` row all say Task 5b. Tasks 4 and 5 need nothing from W3, W4g or Aedwon, so no deadlock and no wait on deploys. |
| L3X2-3 | Resolved | L2 W2 adds `ProPausedLine` (approved copy, in place of the Pro invitation while `paused`, no button); L3 W2 Task 5 builds it; W4f Task 6 now says every family's Pro gate shows it (matches L2 W4f §2); W4b, W4d, W4e and W4g headers add it with a widget test. W4a, W4c and W4h have no Pro gates (L2: "Free and Pro: same"). Restart log records it. Notes L3X3-2 to L3X3-4. |
| L3X-9 | Resolved | Closed by the L3X2-3 fix. |
| L3X2-4 | Resolved | W3 Task 1: "after W6 Task 5b lands". |
| L3X2-5 | Resolved | W3 Task 2 step 4 splits subscriptions and `promo_*` (Task 2), passes (Task 5), shared rule (Task 13 TS half). |
| L3X2-6 | Resolved, with note L3X3-1 | Check and copy before the transaction, record inside, upload delete after commit; an existing record owned by the caller is a success. |
| L3X2-7 | Resolved | W3 Task 11: E14 item if App Store purchases come into scope; `MissingPluginException` treated as no reading, with a test. |
| L3X2-8 | Resolved | L2 W3 AC-3 now says the answer time is the function's own server time taken before the read. |

W2 consistency checks for `ProPausedLine`:
- L2 W2 §3 row and L3 W2 Task 5 agree (name, copy, placement, no button).
- Gallery (L3 W2 Task 7) lists "every component and state", so it picks the component up with no edit.
- Close-out (Task 9) is unaffected: `ProPausedLine` supersedes no file.
- L2 W2 §4 "Free and Pro: `ProTag` only" is not contradicted: a paused student is not Free, and the line replaces the invitation, not the tag.
- Dependency order holds: W2 integrates before every W4 family; the component needs nothing from W3.

---

## Part B. New findings

| ID | Severity | Plan and task | Finding | Evidence | Fix |
|---|---|---|---|---|---|
| L3X3-1 | note | L3-W4g Task 3b step 2 | The stated order checks the upload's bytes and copies it before anything looks for an existing record. After a lost response, the upload is already deleted (after commit), so the retry fails at the upload check and the "existing record is a success" path is not reached in the common case. The pre-transaction copy also overwrites the image of the caller's own live link when a `shareId` is reused, and the order of the limit check against the existing-record check is not stated (a retry at the 10th or 50th link would get `resource-exhausted`). No other user's file or record is affected, and the honest student still sees the link in Shared links. | L3-W4g l.51-58. | First step: read the record; if it exists and the caller owns it, return success with no copy and no counter change; if another user owns it, refuse. Then check, copy, transaction, delete. Add a test: a retry after commit succeeds and leaves the image unchanged. |
| L3X3-2 | note | traceability.md X-2; L2-W3 AC-1 | X-2 still lists only W3 and L3 W3 Task 11. The paused display now spans W2 Task 5 and the W4b, W4d, W4e, W4f and W4g gates. L2 W3 AC-1 still says "(W4f shows it)". | traceability.md l.883; L2-W3 AC-1. | Add W2 Task 5 and the W4 family headers to the X-2 row; change AC-1 to "W2's `ProPausedLine`, shown by the Pro page and every Pro gate". |
| L3X3-3 | note | L3-W4d header vs Task 2; L3-W4e Task 1 | The new header uses "W3's entitlement state is `paused`". Task 2 already says "paused state blocks Customize your own and the mock", which means a quiz left partway (L2 W4d l.44; W4e "paused-quiz block"). A worker who reads it as the entitlement state would block the Free mock for a paused student. | L3-W4d l.21, l.36; L3-W4e l.23. | Say "a paused quiz (left partway)" in W4d Task 2 and W4e Task 1. |
| L3X3-4 | note | L3-W2 Task 5 | No board shows `ProPausedLine`, and the task names no test for its copy. The general rule (each L2 state, light and dark, 200% text) covers layout but not the exact string or "no button". | L3-W2 Task 5; L2-W2 §3 row. | Add a test: the exact approved string, body text style, no button. State that no board exists and the L2 row is the source. |

Not raised (outside the diff): L3-W4g Task 3b deploy line still says "after W6 Task 1"; the rules order W6, W3, W4g suggests "after W6 Task 7 and W3's deploys".

Not checked: no builds, tests or emulators run in the repository; Node 22 behavior of `node --test` with a glob that matches nothing (Node 26 exits 0).
