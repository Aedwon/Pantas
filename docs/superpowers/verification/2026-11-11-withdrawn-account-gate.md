# Withdrawn gate verification

Policy main: 38f74462da82729e1adc85663348b52db8de8f3a.
Code base: see the parent of the rules commit on web/withdrawn-gate-r1.
Only local demo-pantas-test emulators used. Node 22 and Java 21 selected from
Homebrew. npm ci reported one low-severity dependency advisory; no lock change.

## Task 1: rules

Command (from functions, after npm ci):
`firebase emulators:exec --only auth,firestore,storage --project demo-pantas-test "node --test --test-concurrency=1 test/withdrawn-account.rules.mjs"`

Before rule edits: 36 tests, 18 pass, 18 fail. Every blocked-account case failed
with `Expected request to fail, but it succeeded.` Normal accounts passed.
After edits: 36 tests, 36 pass, 0 fail (2450.863333 ms).
Raw local logs: `.dart_tool/withdrawn-gate/rules-{red,green}.log`.

Both rulesets read two distinct server-owned document paths: accountDeletions/uid
and users/uid/server/guardianConsent. A present task short-circuits refusal.
Absent or trimmed consent permits normal ownership checks. Consent exists/get
uses the same path and cached lookup; maximum two document reads, including
Storage's two-document limit. Existing sync access adds its own generation paths.
The ten-row sync batch passes, exercising repeated-check caching under the batch
access-call budget. All own reads/writes, passes/grants (including anonymous),
feedback, sync and wrapped shares use the common gate. Admin SDK bypasses rules.

## Task 2: callable dispatch

New emulator suite discovers all 45 deployed own-account callables from index.js,
excluding only five token-authorized guardian visitor actions. It exercises each
with withdrawn consent, a pending task plus confirmed consent, and a pending task
after consent removal. Refusal must carry permission-denied and reason account-closed.
The same previously successful ingest request is refused after withdrawal. Admin
cleanup remains successful.

Before implementation: 137 tests, 1 pass (Admin cleanup), 136 fail (135 missing
structured refusals plus the still-accepted ingest replay).
After implementation, together with guardian-manage.emulator.mjs: 167 tests,
167 pass, 0 fail (4271.454625 ms). Four existing transaction-level assertions
changed from failed-precondition to permission-denied for the new terminal reason.
Guardian visitor retry and daily Admin cleanup are unguarded, still authorized
by their existing token/job checks. Timed handlers remain intact; ordinary
callable imports use one shared dispatch wrapper. Two uncached Admin document
reads per authenticated dispatch; errors fail closed. Internal Admin functions
are not callable exports and do not go through this gate.

Raw local logs: `.dart_tool/withdrawn-gate/callables-{red,green}.log`.


## Task 3: app continuation, November 12 local session

Policy refreshed from main: `c7c6b3a790953f4348fd2bbf011ff95637cc6549`.
Started from clean `ca8f3b332` on `web/withdrawn-gate-r1`. This is the bounded
app-only continuation of the earlier unchecked commit. No push, Firebase project
access, deployment, generated source change, dependency change, or history rewrite.
Existing spec and plan remain controlling. Estimate: under 20 minutes.

### Behavior and review

All eight SDK callable clients now use the shared owner-bound wrapper. The five
guardian visitor actions, identified by their token payloads, keep their independent
visitor authorization. Ordinary permission errors and network failures retain their
existing behavior. A structured permission-denied with reason account-closed marks
only the request owner closed and refuses subsequent dispatch for that owner.

Guardian JSON recognizes withdrawn. Startup and app resume refresh guardian status,
including for already-cleared minors. The app holds the existing withdrawal title
and detail before attempting sign-out. Failed sign-out cannot remove the hold;
confirmed offline cache and direct navigation cannot bypass it. Guardian manage
and legal links remain reachable. Late status results for another identity do not
sign out that identity, replace its cache, or hold its routes.

Independent read-only app review found one important issue: sync activation's
credential-refresh helper retried terminal refusals, potentially replaying the old
payload after identity change. Fixed at the helper with the shared structured-error
predicate. Its new regression first failed by returning activated under the other
identity; it now preserves the refusal without refreshing or dispatching again.
Existing ordinary permission-denied refresh-and-retry coverage still passes.

The helper `lib/core/sync/eligibility/sync_claim_gateway.dart` and its existing
`test/core/sync/claim_expiry_test.dart` are the two additions to the plan's named
app file scope, required to fix that reviewed retry path. No separate design or
product decision was needed. Combined integration, hosted CI and publication remain
with the lead. No new visual presentation or copy was introduced.

### Failing-first evidence

Temporarily restored all lib files from `613a2d949` while retaining the WIP tests,
then restored lib from HEAD before implementing. Baseline commands:

- `flutter test test/features/guardian/guardian_controller_test.dart --reporter expanded`:
  10 passed, 3 failed. Withdrawn parsed as needsContact/none; account-closed fell
  back to the confirmed cache and cleared the gate.
- `flutter test --no-pub test/app/withdrawn_account_gate_test.dart test/core/platform/account_access_test.dart --reporter expanded`:
  0 passed, 2 loading failures, because the baseline has no AccountAccess or app
  closure-provider APIs. These are compilation failures, not behavioral proof.
  The three controller failures above are the baseline behavioral proof.
- Additional late-identity controller regressions: 13 passed, 2 failed before the
  identity guards; the returned withdrawn status incorrectly affected another identity.
- Sync retry regression: 3 passed, 1 failed before the terminal-refusal exclusion.

Local logs: `.dart_tool/withdrawn-gate/resume/before-guardian.log`,
`before-app.log`, `stale-red.log`, `retry-red.log`.

### Final checks

- `flutter test --no-pub test/app/withdrawn_account_gate_test.dart test/core/platform/account_access_test.dart test/features/guardian test/core/sync/claim_expiry_test.dart --reporter expanded`:
  `+142: All tests passed!` (5 app, 4 shared-access, 129 guardian, 4 sync-claim).
- `flutter analyze lib test`: `No issues found!`.
- Changed Dart files formatted; format recheck reports 0 changes.
- `dart run tool/checks/design_lint.dart`:
  `OK    design-lint: 631 finding(s) match the baseline`.
- `dart run tool/check_layering.dart`: `check_layering: OK`.
- `dart run tool/checks/run_checks.dart`: all nine checks OK; existing documented
  acceptances unchanged.
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- `git diff --check`: clean.

One Flutter command ran at a time. Flutter printed dependency update notices;
no package versions were changed. Existing generated databases and seed assets
were already available locally. Functions and emulator suites were not rerun:
the server source is unchanged, and the earlier evidence above remains separate.
No device, live-project, hosted CI or release verification was performed here.

Final logs live in `.dart_tool/withdrawn-gate/resume/`: `tests-final.log`,
`analyze-final.log`, `format-check.log`, `design-final.log`, `layering-final.log`,
`checks-final.log`, `attribution.log`, and `retry-green.log`.
App source/test diff identity relative to `613a2d949`, SHA-256:
`7031bbfb0f95c907f3dc3402181d9e49456ddf115ad372a849c63234e7b2b319`.

### Files changed in the finishing commit

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/app/routes/guardian_routes.dart`
- `lib/core/auth/firebase_auth_functions_gateway.dart`
- `lib/core/content/remote/content_remote.dart`
- `lib/core/platform/account_access.dart`
- `lib/core/sync/eligibility/sync_claim_gateway.dart`
- `lib/core/sync/firestore/firebase_sync_functions_gateway.dart`
- `lib/core/telemetry/client_report.dart`
- `lib/features/guardian/application/guardian_providers.dart`
- `lib/features/guardian/data/guardian_gateway.dart`
- `lib/features/guardian/domain/guardian_consent.dart`
- `lib/features/guardian/presentation/guardian_screen.dart`
- `lib/features/guardian/presentation/guardian_waiting_page.dart`
- `lib/features/home/data/study_api.dart`
- `lib/features/mock_exam/data/server_mock_api.dart`
- `lib/features/paywall/data/web_payment_gateway.dart`
- `test/app/withdrawn_account_gate_test.dart`
- `test/core/platform/account_access_test.dart`
- `test/core/sync/claim_expiry_test.dart`
- `test/features/guardian/guardian_controller_test.dart`

The existing waiting-page regression in `ca8f3b332` needed no further edit.
This verification record, the launch log and E-036 timing note are also updated.

Timer `E-036-app-finish`: Nov 11 16:18 to 16:27 UTC, 8 min 56 s active/wall
for this bounded implementation and verification continuation. Local save and
handoff follow that measured interval; this is not the whole E-036 duration.
