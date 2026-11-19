# Under-13 accounts: build plan

Date: November 19, 2026. Lead: under-13 build lead (Opus 5.5, Claude Code desktop). Velocity row E-124.
Branch: `claude/under-13-build-386afc` (from main be5da7afa). Integration target: main, then staging
through the integrator steps (`docs/deploy-prod.md` sections 14 and 15). Prod only after Aedwon's
"ship it", relayed by the manager.
Policy read: origin/main bbd17f194 (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`,
`docs/workflow/orchestrator.md`, `docs/workflow/process-improvement.md`).
Spec: `docs/superpowers/specs/2026-11-17-under-13-accounts-design.md` (spec branch d5402f31f, copied here).
Decisions: `docs/superpowers/decisions/2026-11-17-under-13-accounts-log.md` (Decisions 1 to 8, and
Decision 9, the build-conflict rulings, added Nov 19).
Legal text (signed off Nov 19): `docs/legal/drafts/2026-11-17-under-13-legal-draft.md`.
Boards: Claude Design artifact PqxcZvKQheCogaXH6LidPM, picks 1A 2A 3A 4B 5 6B 7A 8A 9A. Two changes from
Aedwon: 7A's description more direct and concise; 8A's code gate reuses the beta sign-in code entry
(`CodeBoxes` in `sign_in_parts.dart`, as used by `email_sign_in_page.dart`) 1:1.

Progress (Nov 20): T1 to T8 and T11 merged (T7 board 5 state ready; server 748 unit and 910 emulator
tests pass). Rate-limit records now purge within 30 days (Aedwon confirms the notice wording at staging).
Codex 6.2 Sol High reviews server and switching. Next after the Claude 5-hour reset: T9 (boards 3A, 4B, 4
confirms, 5, the parents delete link and checkout box screen), then T10, T12, T13.

## Global constraints

- Tests first for every task (`SUBAGENTS.md` Part 3). Workers stage nothing; the lead reviews and commits.
- UI tasks go to Sonnet workers only, never Codex. Codex (through `~/.local/bin/codex-pick`) only
  reviews the server, token and code-gate paths.
- Restricted by default (spec B2 rule 2): every check on `minor` treats `child` and any unknown or
  missing-but-expected value as restricted.
- Holder data is never stored on the device (rule 4d). No form prefills holder details.
- No new fixed-cost cloud item (process rule 7). This build adds callables only (no minimum
  instances), no scheduled job (3 of 3 already used), no secret, no bucket. Free-tier count: 0 new
  fixed items. Child Firebase users and their study data are per-real-user cost.
- Child accounts must not open on prod until the signed child privacy impact assessment exists. A
  server flag (Decision 9, item 9) keeps setup closed on prod.
- Public repo: test data only, no tester names, emails or account ids. Never print secrets.
- Commits: why-messages, no AI attribution or trailers.
- Mail: product-sent (codes, receipts) only; capped per holder (Decision 9, item 6).

## Code facts (map of main bbd17f194, Nov 19)

- Spec B1 line references hold. Corrections: the device also stores `age_blocked_minimum`,
  `passed_age_gate`, `setup_acceptance_*` and `guardian_closed_uid`; the guardian-contact erase fix
  (rule 4d prerequisite) already shipped (`fe3210b6b`).
- `paymongoCheckout.ts:46` returns no attestation requirement for anything but `minor`: a `child`
  or missing record passes. `guardianConsent.ts:145` maps unknown groups to null.
- Emailless custom-token users break `webTrial.ts:28-31` (throws; also breaks `deleteUserData.ts:59-66`),
  `betaAccess.ts:13-14` (not selected), `cleanupOrphanAnons.ts:7-14` (treated as orphan),
  `purgeInactiveAccounts.ts:204-210` (no-email accounts deleted at 24 months without warning),
  `auth_repository.dart:466-473` and `deleteAccount.ts:12-37` (recent Google re-auth).
- `exportData.ts` is a stub that always throws: For parents shows the data protection officer contact.
- One local database. A switch to another real account wipes it (`sync_runtime_controller.dart:500-517`),
  pending uploads included. Sync is Pro-only. `prepareForAccountSwitch` is empty.
- Age group, selected exam and `passed_age_gate` are device-wide (`devicePrefs`), not per account.
- Speed and error reports default on and are not tied to age. Push tokens are never registered; "push"
  means the local reminders permission step and the Reminders row.
- Wrapped shares: rules allow any named user (`firestore.rules:419-446`, `storage.rules:40-50`);
  `renderWrappedPage.ts:52` checks only that the account is active.
- PSHS-NCE is `exam_pshs_nce`, `comingSoon: true`; web onboarding shows CSE only. No Android check in lib/.
- Beta code entry: `CodeBoxes` (`sign_in_parts.dart:975`); callables `requestSignInCode` and
  `verifySignInCode` in `signInCode.ts` (keyed-hash storage, limits, 10-minute life, 5 wrong tries).
- Resend Free: 100 mails a day across all mail. Prod caps: guardian 20, sign-in 20 open and 40 reserved.
- Functions tests: `cd functions && npm test` (unit, then emulator suites). Journeys:
  `node tool/journeys/journeys.mjs [base] [filter]` (Playwright, local emulators by default).

## Tasks

Estimates are working days, including tests and lead review. Order is the dependency order; tasks in
the same wave touch different files and may run in parallel worktrees.

### Wave 1: server foundation (non-UI; Sonnet workers; Codex Sol High review after the Nov 22 reset)

**T1. Age group `child` and restricted-by-default (0.5).** Server helper and client enum where
unknown or missing-but-expected is restricted. Fix every site in the map's list (client 15, server 9):
checkout attestation, `getStatus`, purge of `ageGroup`, guardian gating, sharing lock, analytics force-off,
home notices, payment gateway. Custom claim on child users (Decision 9, item 7). Tests: each site with
`child`, unknown and missing.

**T2. Holder and child accounts, setup callable (1.5).** `setupChildAccount`: named sign-in required;
server flag open; holder classification (existing account with profile or progress refused with the
spec message; empty named account becomes holder; holder study and checkout refused); limit 5 active;
both ticks with text versions; evidence per child (`ageGroup: child`, `method: guardian_held`, holder id,
link, document versions, server time); nickname stored server-side; creates the emailless child user and
returns its custom token. `listChildren` (nicknames and masked holder email, never cached on device).
`openChildSession` (custom token; checks the target child's opt-in or a verified code). Receipt email per
child (legal draft section 6) with a delete link that confirms after sign-in. Tests: emulator suite for
every refusal, the limit, evidence fields, token issue.

**T3. Guardian code gate, server (0.75).** `requestGuardianCode(action, childId)` and
`verifyGuardianCode`: reuse `signInCode.ts` hashing and limits; bound to holder, child and action;
expiry, single use, limited tries; switching children cancels a pending code; per-holder mail cap
(Decision 9, item 6). Email text from the legal draft. Tests: binding, expiry, reuse, tries, cap.

**T4. Emailless-child server fixes (0.5).** Orphan cleanup exempts linked children; beta gate, web trial
and data deletion handle a child token (Decision 9, items 2 and 3); inactivity purge per item 5; holder
gets all child mail. Tests for each.

**T5. Child limits and parent actions, server (0.75).** Checkout: refuse non-PSHS products on a child;
require the box on every PSHS-NCE purchase, any age group; record text version and time; pass bound to
the child chosen at checkout. Wrapped: rules and `renderWrappedPage` refuse children. Withdraw and
delete per child behind a verified code (replaces recent-login for children, item 4); closing the last
child deletes the holder. Sibling opt-in setter behind a code, recorded with time and notice version.
Tests: emulator suites.

### Wave 2: client foundation (Sonnet workers)

**T6. Device state, sign-in restore and switching (1.25, plus Decision 9 item 1).** Age fork state
`needsGuardianSetup` (reinterpret stored under-13 blocks; a new age does not clear it). Sign-in reads
the age group from the server; `child` skips the age step and applies limits. Child open and switch:
holder session dropped once the child session starts; holder data erased; each child's records isolated
per Decision 9 item 1; one child's records never reach another's account. Tests: extend
`account_switch_leak_test.dart` with two children, free and Pro, pending records.

**T7. Child limits, client (0.5).** Exam picker on a child: PSHS-NCE only, others "For ages 13 and up"
(board 5); PSHS-NCE selectable per Decision 9 item 8; analytics, speed and error reports, share cards
and Wrapped, reminders permission off; PSHS-NCE hidden on Android. Tests per limit.

### Wave 3: screens, built 1:1 to the picked boards (Sonnet workers, never Codex)

**T8. Boards 1A and 2A (1.0).** Under-13 guardian screen (no back; closed-on-prod state per item 9);
parent setup: sign-in, two ticks, error "This email already has a Pantas account...", short child
notice; nickname step label and help text. Goldens, one sheet per screen.

**T9. Boards 3A, 4B and 5 (0.75).** Adult "Is this for a child under 13?" dialog on PSHS-NCE select or
switch; For parents entry (Child Notice, data copy via the data protection officer, withdraw, delete,
confirms incl. the last-child line, "managed by a parent or guardian" line); exam picker on a child.

**T10. Boards 6B, 7A, 8A and 9A (1.0).** Switch Child ("Who is studying?"), Add a Child (7A with the
shorter description, settled by the lead under rule 4 and recorded), code gate reusing `CodeBoxes` and
the beta code screen's structure 1:1, sibling opt-in with the sharing notice.

**T11. Legal texts and checkout box (0.5).** Child Notice as a legal document with its own version;
Terms and Privacy changes; checkout box text on every PSHS-NCE purchase; every sync item in legal
draft section 9 (versions together on client and server, one real publish date).

### Wave 4: integration and staging (lead)

**T12. Journey and combined checks (0.75).** Two-child family journey in `tool/journeys/`: age under 13,
setup, second child, switch with code, opt-in, test-mode PayMongo purchase, withdraw. Full check set
(analyze, format, layering, attribution, `run_checks.dart`, flutter test, functions `npm test`, web build)
on hosted CI.

**T13. Staging (0.5).** Merge to main with green CI; integrator staging steps; staging flag open;
journey against staging with test data; handoff to the manager for Aedwon's visual check.

Total: 10.25 days before Decision 9 additions. The spec estimate is 8.5 to 10.

## Reviews

- Lead reviews every worker diff against the task's file list and this plan.
- Codex GPT 6.2 Sol High (`codex-pick`, Aedwon Nov 19) reviews T2 to T5 and the switching fix (T6) (server, tokens, code gate) once the weekly
  limits reset Nov 22. Review only; fixes go back to a Sonnet worker.
- UI tasks: an independent Sonnet reviewer checks component use and compares the golden sheet with the board.

## Out of scope

Spec B3. Also: the 12-month child inactivity deletion (backlog, due before November 2027), the
PSHS-NCE product and content, the catalog flip from `comingSoon`, live payment setup.

## Open items for Aedwon (through the manager)

- Board artifact: shared Nov 19; workers read the copy in the session notes folder `u13-boards/` (board
  titles in `project/canvas.json`).
- Signed child privacy impact assessment before prod opens child accounts.
- Rule 9 email: no existing user's collection changes, so no notice email is needed (lead's reading).
