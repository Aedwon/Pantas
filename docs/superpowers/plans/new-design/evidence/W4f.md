# W4f launch implementation evidence

Policy: local origin/main 1a5089e0203af65b02dc03f3ac8d466770e07f11.
Candidate base: a6245e030a85fddd344c7f459ebab6b691aea286.
Assignment: Tasks 2–9, CSE PWA launch. Task 1 remains parked. No commits, fetches, deployment, or dependency additions.

## Task 2

Replaced root sheets and groups with profile, Pro, exam, Practice, Reminders (native only), Appearance and About destinations. Reused W2 page, grouped rows and avatar. Pro value names the owned plan.

Test first: `flutter test --no-pub test/features/settings/presentation/settings_home_page_test.dart --reporter expanded` failed with missing Avatar and expected Yearly, actual Pro. After implementation:

```
00:00 +2: All tests passed!
```

Visual acceptance remains with Aedwon. Dark and 200% states not yet verified.

## Task 3, in progress

Exam root now has inline date precision/wheels, study days and the last-day guard. Uses W4a's settings picker. Carry-over now opens a full screen and no longer prints the overlap count. Date test failed first because Your exam/Study days were missing, then passed. The issue 26 screen regression failed first because Count Them was missing and the old prompt was a sheet. Transfer regression is being checked.

Open contract: lesson-level exclusions on ST_IncludedOpen have no persistence contract in CustomTrackRepository (only topicIds). Do not invent lesson persistence or silently omit that state. Upgrade/pass-warning handling and confirmation remain incomplete.

## Task 4, partial

Practice and Appearance routes implemented; old sessions route redirects to Practice. Quiz length writes existing quiz preferences. Appearance writes existing theme, lesson text scale and retained table order providers. Practice failed first with missing SESSION LENGTH. Appearance failed first because its route was absent. After implementation:

```
00:00 +2: All tests passed!
00:00 +1: All tests passed!
```

Native Reminders is blocked by parked Task 1's missing ReminderPrefs/service contract. No draft files read or copied. Web root hides its row. The parked draft must retain notificationRationaleShownProvider and add its native route when it lands.

## Task 5, partial

About uses grouped rows, selectable DPO email, optional SharedLinksRow slot, debug/gallery links. Legal presentation uses the plain W2 page and missing-document state. About tests first failed on DPO wording, consent copy, selectable address and switch type. Legal test first failed on Privacy policy title. Legal document bodies remain unchanged pending reconciliation of ST_Privacy's approved summary and existing legal content. No legal wording was invented.

## Task 6, in progress

C3 contract gap: currentOffering does not return trial eligibility (its parser never sets trialEligible). startTrial reports notAvailable only after attempting the grant. The plan requires the trial line only when eligible. No invented eligibility or second-trial promise. Production trial offer depends on a server eligibility read or an approved alternative.

Task 6 focused checks: CSE offering while owning Student Pro and paused line failed first against the old page. After implementation:

```
00:01 +2: All tests passed!
```

Pro now consumes currentOffering and purchase/restore; handles C3 checkout returns once, redirected operation as busy, anonymous sign-in destination, and server trial results when an offering explicitly declares eligibility. No literal prices in presentation. Any-plan rows are separate from active-exam coverage. Records paywall seen for review cool-off. Remaining: savings/card details, exhaustive state copy, pending native purchase, pass expiry/soon states and student-plan-renewal notice require completion and wider tests. Web trial eligibility gap above remains.

## Task 7

Deleted the listed old purchase flow, widgets, notices and their tests. Removed their exports and recommendation dependency. The remaining offering display order uses SKU enum order. `/paywall` remains a compatibility redirect to `/settings/pro`, with no live pushes. Retirement guard failed first because the old files existed, then:

```
00:00 +2: All tests passed!
```

## Task 8, partial

Account now shows avatar, Name screen, public ID (digits copied, 2-second confirmation), signed-out Google action, backup group and account actions. Name saves on back and clearing removes it. Public ID test failed first because its row was absent; Name route test failed first because its route was absent. After implementation:

```
00:01 +1: All tests passed!
00:00 +1: All tests passed!
```

Unresolved: ST_SignOut promises retained phone progress, but AuthRepository.signOut wipes local state under the account-boundary contract. Existing destructive warning and behavior retained pending lead reconciliation. Backup Details requires measured backed-up-since and phone model, neither supplied by the current surface. PWA server storage also has no backup-status read contract. L_Restore needs real restoration stage/count signals; current auth result does not expose them. L_Delete's phone-then-cloud stage order differs from the current cloud-then-local deletion sequence. No fake stages/counts or completion claims were added. Existing deletion and fresh reauthentication remain unchanged.

## Resume, October 25

Current policy read from local `origin/main` 0176ea1e4f8a35f00cbe9f4f491cc2dcc665bd0e. No fetch or pull, per the lead brief. Branch `web/new-design-w4f-r2`, HEAD a6245e030a85fddd344c7f459ebab6b691aea286. Existing uncommitted changes retained. No terminal-relay tool is available in this session; commands run in the assigned Mac worktree. The older worktree was not opened.

Read the current L3/L2 plans, amendment spec, applicable decision rows, G-f traceability rows, gap-f inventory, pricing, PWA A6 and C3 handoff. Board HTML and timeline output were read from origin/main. No app screenshots or autonomous visual acceptance.

Pre-flight interfaces:
- Tasks 2/4 consume W4a/W4b providers and W2 components already present.
- Task 3 consumes the W4a picker and W3 switch outcome. Topic exclusions persist; lesson exclusions have no storage contract. Stop only that part.
- Task 4's native reminders depend on excluded Task 1. Preserve its imports/providers; web has no reminder row or route.
- Task 6 consumes C3. Trial eligibility is not returned by the actual gateway. Do not infer it from a Free entitlement.
- Tasks 6/8 read any-plan ownership separately from active-exam coverage. They do not change entitlement or account-boundary policy.
- Task 8's sign-out retention and deletion-stage requirements conflict with existing account-boundary operations. These need the lead's ruling; no security/data-layer rewrite under this presentation assignment.

Task 3 resume RED observed in the initial full-suite run:
```
Expected: exactly one matching candidate
Actual: Found 0 widgets with text "You're now studying for DOST"
a switch with no overlap confirms the kept date and study days [E]
```
Added the post-switch confirmation with the existing date and approved kept-date copy. No simulated rebuild stages or timing.

Task 3 confirmation GREEN:
```
flutter test --no-pub test/features/settings/presentation/exam_page_test.dart --reporter expanded
00:01 +11: All tests passed!
```
The initial full-suite diagnostic was interrupted after this new regression failed as expected. It is not reported as a completed full-suite check. A fresh final full suite is required.

Task 5 correction to the earlier resume note: the existing dirty patch already replaces the Privacy body with the three approved ST_Privacy sections. The earlier statement that its body was unchanged was stale. The approved copy is retained. Publication-date and prepaid Terms revisions remain launch-lane L4 work, not invented here.

## Resume implementation and focused results

- Task 2: existing root states retained. Root matrix covers named, no name, signed out, Pro and trial, light/dark and 100%/200% text.
- Task 3: added successful-switch confirmation and kept-date copy after the picker/transfer finishes. Issue 26 reverse-transition tests remain green. Lesson-level exclusions and the target-exam upgrade presentation remain blocked, as listed below.
- Task 4: Practice and Appearance are built. Web omits Reminders per A6. Native Reminders is explicitly excluded with Task 1, not reported implemented.
- Task 5: approved Privacy summary, About groups, selectable DPO email, legal error page, feedback and shared-links slot are present. The slot remains empty because W4g is deferred. Existing actual build version stays 0.1.0+1, matching pubspec. The existing document's update metadata is retained.
- Task 6: pinned purchase/restore controls; gateway-derived prices, savings and monthly equivalents; proper card type sizes; a published-date gate on pass selection; disabled no-date pass state; grant uses Ends; native account-bound pending purchase replaces plans. Web ignores native pending markers and Play links. C3 redirect and checkout-return wiring retained.
- Task 7: retired flow and route-push guards retained. No live Pro push uses /paywall.
- Task 8: Back Up Now calls the existing runtime and prevents duplicates; offline shows actual queued changes and disables manual backup. Uses live Saved/Backing up/Offline/failure states. Rebuilt delete confirmation with approved consequence rows and choices. Retained existing billing warning and actual auth/delete operation. Successful deletion resets onboarding completion and returns to Welcome. Fixed a stale route-provider reference exposed by the new route regression. Added ID copy/check glyphs through ListRow's explicit trailing slot.
- Task 9: removed unused replaced Settings placeholder. Retained notificationRationaleShownProvider and all Task 1 service/presentation code. Removed no parked-worktree files.

New resume RED evidence:
```
Task 6: card price expected 22, actual 17.0; pending card absent; date-less pass selectable; grant Ends absent.
Task 8 backup: Saved/Offline and manual backup action absent (2 tests failed).
Task 8 delete/ID: approved consequences absent; Copied check absent (2 tests failed).
Task 8 route: Welcome absent; direct diagnostic exposed Riverpod's outdated-ref assertion.
Task 9: replaced Settings placeholder still existed (1 test failed).
```
The proposed "Ends in 5 days" assertion was withdrawn before implementing that display: the records do not define when Until changes to Ends in. No guessed threshold was added. This is an open product decision, not a passing claim or skipped check.

Focused GREEN output:
```
flutter test --no-pub <Practice, Appearance, About, legal, Pro and checkout-return tests> --reporter expanded
00:03 +39: All tests passed!
flutter test --no-pub test/features/settings/presentation/w4f_backup_test.dart --reporter expanded
00:00 +2: All tests passed!
flutter test --no-pub <delete, public-ID, backup and Settings-detail tests> --reporter expanded
00:05 +19: All tests passed!
flutter test --no-pub test/features/settings/presentation/w4f_screen_states_test.dart --reporter expanded
00:01 +32: All tests passed!
```

## Open decisions and unavailable contracts

These are not accepted board deviations. The affected portions remain incomplete.

1. **ST_IncludedOpen:** the shared picker supports lessons, but CustomTrackRepository stores only excluded topic IDs. W0 needs a lesson-exclusion contract before the drawn partial-topic state can be persisted. No schema or shadow persistence added.
2. **ST_SwitchUpgrade, Task 6 renewal notice:** the current page does not implement the target-exam upgrade screen. The plan explicitly leaves Student-plan-still-renews copy awaiting Aedwon. On web, prepaid checkout also does not replace a Play subscription. Do not promise replacement or cancellation without a ruling.
3. **ST_ProCSE_v2, approved web trial notice:** C3 currentOffering never supplies trial eligibility. The UI honors explicit eligibility and handles startTrial results, but production cannot advertise an eligible web trial until C3 supplies that read contract or an alternative is approved. No second-trial promise or local eligibility inference.
4. **ST_PassSoon:** no threshold is recorded for changing Until to Ends in. **ST_PassEnded/ST_ProLapsed:** the gateway's active entitlement surface does not provide expired-pass/plan history. It cannot reliably show the actual past end date after login. Need a historical read contract. Current lapsed subscription layout can only render dates present in its input.
5. **ST_SignOut:** the board promises progress remains on the phone. AuthRepository.signOut wipes account-local data under the account-boundary contract. Existing truthful destructive copy and operation are retained pending the lead's reconciliation.
6. **ST_BackupDetails/ST_BackupNow/ST_BackupStates:** native status exposes some actual timestamps and queue counts, but not backed-up-since or phone model. Those rows are omitted. Web has no server backup-status reader or manual-backup contract. No fake Saved state, date, device name or completion signal added.
7. **O_SignIn/L_Restore, L_Delete:** auth results expose no restoration stage/count or deletion stage signals. Existing whole-operation loading/errors remain. Do not show made-up counts or mark staged work complete. The deletion backend runs cloud then local, opposite the drawn phone-then-cloud stages. The delete confirmation keeps the existing billing warning instead of asserting an unverified backup. No auth/security changes.
8. **ST_Privacy:** summary copy matches the approved board; existing legal update metadata differs from its illustrative Aug 3 date. Prepaid payment Terms and publishing remain launch lane L4.
9. **ST_ExamSwitchCount/L_ChangeExam2:** vessel transfer is retained from the prior run; its full transform/fade choreography is not yet 1:1. The confirmation uses settled copy, without fabricated timed rebuild stages. Aedwon's visual check is outstanding for every screen, including dark/large text. Automated no-overflow checks are not visual acceptance.

## Task 1 future landing

The native root still expects /settings/reminders. Task 1 must add that route, ReminderPrefs, permission handling, Follow up constraints, countdown control and the scheduling service. Keep notificationRationaleShownProvider until onboarding no longer imports it. Retain existing notification tests and service files while this task is parked. Web must keep the row/route absent. The native root destination remains unavailable until Task 1 lands; native is excluded from this PWA launch.

## Files outside the screen-family paths

Core ListRow honors an explicit trailing widget on value rows so ID copy/check and backup progress can render. CenteredDialog's existing patch disables Escape for the non-dismissable reconciliation choice. ScopePicker's existing patch adds the minimum-selection line. The icon map adds copy, cloud-slash and mobile-slash glyphs from the already-bundled Phosphor font; verified against its cached upstream regular map and local cmap. No dependency added. Router and existing onboarding picker changes connect the shared screen and prevent a current-exam switch. Legal and test guards change with the approved replacement. No generated source edited.

## Independent review and correction pass

Read-only independent review inspected the dirty candidate against current policy, plans and boards. It ran no Flutter commands and made no edits. Three Important findings:

- **Unresolved product decision, ST_ExamSwitchCount/L_ChangeExam2:** Count Them saves and finishes the transfer but never closes the route. There is no visible exit. An installed iPhone PWA cannot reach the kept-date confirmation. The repeating board preview does not settle automatic-return timing or approve a new button. This blocks acceptance of Task 3. No automatic time or extra control was invented.
- **Fixed:** changing month/year forced day 1, including dates that validation rejects in the current month. Tests observed expected day 25 versus actual day 1, and expected year 2026 versus actual 2027. The picker now preserves the day and clamps it to the selected month's valid range and today's lower bound.
- **Fixed:** multiple passes displayed the active exam next to the latest expiry across all ownership. Each pass now renders its own Plan/Exam/Ends group using catalog names and that pass's own ledger date. Subscription/grant dates are kept separate from pass dates.

Review-fix regression output:
```
flutter test --no-pub test/features/settings/presentation/w4f_exam_test.dart test/features/settings/presentation/w4f_pro_states_test.dart --reporter expanded
RED: 3 failed, 7 passed (two date-edit regressions and per-pass ownership/date regression).
GREEN: 00:01 +10: All tests passed!
```
No second independent review was requested. The author verified the corrections through these regressions. The unresolved exit finding is a blocker, not a clean-review claim.

The full-suite diagnostic also found two old delete-label contrast checks and the closed icon-inventory count. Updated the contrast checks to inspect the actual destructive button before/during its busy state; they still enforce white-on-red contrast and spinner color. Added the three already-approved Settings glyphs to the pinned-codepoint inventory. No golden baseline changed.

```
flutter test --no-pub test/core/ui/components/destructive_contrast_test.dart test/core/ui/icons/pantas_icons_test.dart test/features/settings test/features/paywall test/features/notifications test/features/legal test/app --reporter expanded
00:29 +729: All tests passed!
```

A further deletion regression checks the actual cached onboarding progress, not just a route stub. It exposed the retained age flag reopening Terms instead of Welcome. Success now clears onboarding completion and the age flag, invalidates their cached progress and user settings, then enters onboarding. This changes no authentication, cloud-deletion or account-wipe policy.

The full-suite diagnostic runs interrupted for the expected new regression, obsolete checks or corrected source inputs are not complete full-suite evidence. Only the completed final invocation below is the full-suite result.


## Run 2 preflight stop, October 25

Policy read using `git show origin/main:<file>` without fetch or pull:
`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, policy revision
`0176ea1e4f8a35f00cbe9f4f491cc2dcc665bd0e`.

All assigned worktrees were clean at preflight and matched the brief:
- CLIENT `web/new-design-w4f-r2`, e5900dfb17a1a357fb2233fc21d1deaaef8d2581.
- PAYMENTS SERVER `web/paymongo-r1`, b0946994073bd136121d0274e93f7386d544fd03.
- STUDY SERVER `codex/w4b-server-dependency`, 52419d645c18b200c6c6593016f90a47ee87585c.

Schema sequencing ambiguity found before implementation:
- CLIENT `lib/core/storage/data/app_database.dart:77`: `schemaVersion => 25`.
- Cached `origin/integration/new-design-r1` at
  0a21e5b9ed2fc4bc75abd2fc6d7b6b2e2528afc7 also declares 25.
- Cached `origin/web/pwa-staging-r1` at
  80ddb7c52f1b9728d7c07945f480d2ed0c3d5950 declares 26 and has
  `if (from < 26) { await m.createTable(cachedContent); }`.
- Current `W4-client-coordination.md`, Integration collisions, explicitly says
  schema 26 arrived on staging with its migration. The older W0 plan says 25.

No schema bump or migration was written. Reserving 26 again for lesson
exclusions would collide with the existing staging migration. Assigning 27
without reconciling the missing 26 migration would decide integration sequencing
outside this implementation brief. Stop pending the lead's migration-number and
sequencing ruling. No server branch was merged into the client.

Items 1–9: not implemented in this run. No new tests were written or run, so
there is no failing-first or final-gate claim. No dependencies, deployment,
commits, pushes, or generated-file changes. Only this evidence note changed.
All October 25 product choices in the brief remain accepted; the open issue is
technical migration sequencing, not a request to repeat those product decisions.


## Run 2 implementation, October 25

This section supersedes the earlier open-contract and migration-stop notes for
items 1–9 in the resumed lead brief. Initial dirty changes in all three assigned
trees were read and preserved. Nothing was committed, merged, pushed, fetched,
deployed, or added as a dependency.

Actual cached client origin/main verified during this run:
`d28f0f623221dbd67d8be54a0c659cabd01a85ce`. AGENTS.md, WORKFLOW.md and
SUBAGENTS.md were read with git show. Their contents are identical to the earlier
0176ea1 policy snapshot (`git diff` of all three policy files is empty). The
client remains based at e5900dfb17a1a357fb2233fc21d1deaaef8d2581. The brief's
October 25 rulings control the remaining behavior. The L2/L3 W4f plans,
amendment spec, pricing, C1-C10 ruling, coordination handoff and relevant board
HTML/timeline output were read from cached origin/main. No live deployed
callable or phone visual acceptance is claimed.

Items:

1. Sign-out uses the exact account-saved copy. The account-boundary wipe stays.
2. Pass offers change Until to Ends in within seven days, with singular 1 day.
3. Confirmed schemaVersion 25. No schema change was needed. Excluded lesson IDs
   use sorted JSON under `settings.excluded_lessons.<examId>` in existing
   accountPrefs. Topic and lesson updates share a transaction. The existing
   account wipe clears the key. No migration or database generation was needed.
   The Included picker now supplies lesson metadata, persists partial topics and
   guards the final selection. Native plans remove lessons, linked questions and
   due reviews. Their digest and in-flight owner guards include lesson scope.
   The existing settings sender sends both excludedTopicIds and excludedLessonIds.
   Study server validates both and filters both roadmap paths. The shared digest
   and its test are identical in client and study trees.
4. Web hides the native Backup group, manual backup and unavailable status,
   timestamps, device details and queue counts. A direct Backup destination shows
   only the account-saved statement. Native measured backup behavior stays.
5. The target-exam upgrade screen uses the full offering before changing focus.
   It has Monthly and Season Pass side by side, no trial, and Switch on Free.
   Native cancellation does not save the target. Web saves the target before its
   existing checkout redirect so the return opens the chosen exam. The exact
   approved Play renewal warning uses a server-confirmed flag. RevenueCat ingestion
   now retains explicit verified renewal status, and listWebPlans exposes it.
   Old records without renewal status stay unknown until the next existing
   RevenueCat refresh/webhook. No replacement or cancellation is inferred.
6. listWebPlans trialEligible and startWebTrial share the same history predicate.
   Anonymous accounts are ineligible. The gateway accepts only literal true and
   marks Monthly only. Offering reads refresh across auth changes and suppress
   previous account values while loading. Starting a trial invalidates eligibility.
   Active web trials use the approved no-charge sentence with their real end date.
7. The gateway reads known expired and revoked grant rows without granting access.
   It sorts real end dates and guards UID plus identity revision. Pro uses that
   history for ended pass/plan states, removes previous-account dates while a new
   owner loads, and retains the native source.
8. ST_ExamSwitchCount timing is normalized to the depicted tap at 700ms: prompt
   fade 0–300ms, vessel transform 50–500ms, pipe 550–850ms and 2350–2650ms,
   liquid 750–2350ms, check 2650–2950ms, final copy 2950–3300ms. It holds through
   the board's final hold, then returns at 5400ms. That resolves the prior no-exit
   finding without adding a control. Reduced motion shows the final state.
   L_ChangeExam2's actual completion starts the 450ms arrival and delayed 500ms
   check pop. No timed rebuild progress or invented work stage was added.
9. Restore and delete retain whole-operation loading, actual deletion order,
   existing billing warning and existing security operations on both platforms.

Independent review found five important issues: renewal data unavailable on web,
passes filtered to the old exam, eligibility cached across auth changes, native
selection saved before canceled payment, and retained history during owner reload.
All were corrected with focused regressions. The reviewer made no edits and ran
no Flutter commands. No second independent review is claimed. Root inspected both
server diffs and actual check logs.

Observed RED evidence:

- Repository API absent, then native stored-plan digest unchanged after lesson edit.
- Included picker had no lesson expander against the old implementation.
- Web backup still exposed manual action and Saved status.
- Gateway lacked grantHistory; eligibility test expected Monthly but received [].
- Server listing eligibility expected true but received false.
- Study same-day plan and compatibility linked-question tests retained excluded work.
- Upgrade screen lacked target API; its layout regression found vertically separated cards.
- Native cancellation regression observed the early save; delayed history regression
  retained the old end date; provider regression lacked a full owner-bound offering.
- Renewal ingestion expected true but got undefined; listing had no renewal field;
  gateway had no renewal getter. The active web trial had no approved end sentence.
- Motion test had no vessel transform; confirmation had no arrival animation.

The inherited sign-out/countdown changes and server validation patch existed at
entry. Their original failing-first executions are unavailable in this resumed
session. No new original-RED claim is made for those inherited changes.

Combined diagnostic runs exposed stale assertions and a native test dependency.
The native Pro page no longer constructs a web gateway. The checkout-return test
accounts for login, checkout and history ledger reads. The Included test expects
lesson leaf IDs. The old silent-sync Backup test waited for a continuous spinner
and banned the approved measured count. It now uses bounded pumping and asserts
the real count. Contrast-test formatting was needed for clean analysis. Interrupted
runs are diagnostic only and are not full-suite pass evidence.

Rulings and remaining acceptance:

- Storage follows the lead's no-schema preference. schemaVersion remains 25.
- The transfer exits after its board's final hold. Animation starts only after
  saving; it never represents a measured server-work duration.
- Existing renewal records without the newly retained field cannot produce the
  warning until a real RevenueCat refresh. No backfill or deployment was run.
- No product decision remains within items 1–9. Aedwon still owns phone visual
  acceptance, including dark and large text. Live staging, checkout and deployed
  App Check remain outside this local run. Parked reminders remain outside scope.

Final command output and source identity follow after verification completes.


### Final client output

```text
flutter test --reporter expanded
08:58 +4921: All tests passed!

flutter analyze lib test tool
Analyzing 3 items...
No issues found! (ran in 10.2s)

dart format --output=none --set-exit-if-changed lib test tool
Formatted 1591 files (0 changed) in 1.87 seconds.

dart run tool/check_layering.dart
check_layering: OK

dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
```

Full logs and a per-file production/test source manifest are retained locally in
ignored `build/w4f-run2`. The manifest includes modified and untracked source and
tests, including the new lesson-picker regression. Manifest SHA-256:
`f7880c9b8424420daf5ab6e9f34ead7470732c1129a109feb2ba8e59c0b0573d`.
No application source changed during the passing full suite.

The cached origin/main advanced externally to
40b35bc4c6640aeec9234b3ed72cc37f8c510b1f during this run. A final comparison of
AGENTS.md, WORKFLOW.md and SUBAGENTS.md against the read d28f snapshot is empty.
No fetch, pull or main integration was performed by this task.

### Server output

```text
PAYMENTS, functions
npm_config_cache=/tmp/w4f-npm-cache npx tsc --noEmit
exit 0
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
Plain: 119 pass, 0 fail
Emulator: 145 pass, 0 fail
Script exited successfully (code 0)

STUDY, functions
npx tsc --noEmit
exit 0
PATH=/opt/homebrew/opt/node@22/bin:/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
# tests 183
# pass 183
# fail 0
# tests 238
# pass 238
# fail 0
Script exited successfully (code 0)

STUDY
server_dart/build.sh --check
generated JS is current
```

Both full server runs used isolated emulator ports. Payments additionally used
execution-only serialized emulator tests because an existing global-ledger sweep
races parallel tests. Its temporary runner/config files were restored byte for
byte. The earlier parallel failure remains in diagnostic logs. No skipped test
or altered assertion was used to obtain final server totals. The compiled study
bridge was regenerated after the shared digest changed, then checked again after
constructor formatting. It remains uncommitted, as do all other changes.

### Final status snapshots

All changes remain uncommitted. No server branch was merged into the client.

### CLIENT status

```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4f.md
 M lib/app/routes/settings_routes.dart
 M lib/core/storage/data/repos/custom_track_repository.dart
 M lib/core/storage/track_scope.dart
 M lib/features/home/application/study_delivery.dart
 M lib/features/paywall/application/paywall_providers.dart
 M lib/features/paywall/data/web_payment_gateway.dart
 M lib/features/roadmap/application/roadmap_inputs_reader.dart
 M lib/features/roadmap/application/roadmap_providers.dart
 M lib/features/roadmap/domain/day_snapshot.dart
 M lib/features/settings/presentation/carry_over_prompt.dart
 M lib/features/settings/presentation/pages/account_page.dart
 M lib/features/settings/presentation/pages/backup_page.dart
 M lib/features/settings/presentation/pages/exam_page.dart
 M lib/features/settings/presentation/pages/pro_page.dart
 M lib/features/settings/presentation/pages/whats_included_page.dart
 M test/core/storage/data/repos/custom_track_repository_test.dart
 M test/core/sync/silent_sync_test.dart
 M test/core/ui/components/destructive_contrast_test.dart
 M test/features/home/application/study_remote_providers_test.dart
 M test/features/paywall/application/paywall_providers_test.dart
 M test/features/paywall/data/web_payment_gateway_test.dart
 M test/features/roadmap/application/roadmap_controller_test.dart
 M test/features/roadmap/domain/day_snapshot_test.dart
 M test/features/settings/presentation/account_page_test.dart
 M test/features/settings/presentation/carry_over_screen_test.dart
 M test/features/settings/presentation/exam_page_test.dart
 M test/features/settings/presentation/w4f_backup_test.dart
 M test/features/settings/presentation/w4f_checkout_return_test.dart
 M test/features/settings/presentation/w4f_pro_states_test.dart
 M test/features/settings/presentation/whats_included_page_test.dart
?? test/features/settings/presentation/w4f_lesson_scope_test.dart
```

### PAYMENTS status

```text
git status --short
 M functions/src/revenuecatPolicy.ts
 M functions/src/revenuecatSubscriber.ts
 M functions/src/webPlans.ts
 M functions/src/webTrial.ts
 M functions/test/revenuecat-subscriber.test.mjs
 M functions/test/web-plans.emulator.mjs
 M functions/test/web-plans.test.mjs
 M functions/test/web-trial.emulator.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
 M test/features/paywall/data/web_payment_gateway_test.dart
?? docs/superpowers/plans/pwa-launch/evidence/
```

### STUDY status

```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4b-server-dependency.md
 M functions/src/generated/pantas_core.js
 M functions/src/roadmap.ts
 M functions/test/study-roadmap.emulator.mjs
 M lib/features/roadmap/domain/day_snapshot.dart
 M test/features/roadmap/domain/day_snapshot_test.dart
```

### Lead final cross-tree verification

```text
flutter test test/features/metrics test/features/roadmap --reporter expanded
03:43 +314: All tests passed!
```

The client full suite passed 4921 tests. Its final analysis, format, layering
and attribution checks are clean. Payments passed 119 plain and 145 emulator
tests. Study passed 183 plain and 238 emulator tests. Both TypeScript checks
passed. The study bridge check reports `generated JS is current`.

The two web_payment_gateway.dart files are byte-identical. The changed shared
Dart digest and its test are byte-identical across client and study. All three
branch heads are unchanged from the assigned baselines. Everything remains
uncommitted. The tracked regenerated study bridge is also uncommitted.

No product decision remains within the resumed items 1–9. Phone visual acceptance
and live deployed behavior were not checked. Historical Play records with unknown
renewal status need their next real RevenueCat refresh before the warning can be
confirmed. No backfill or deployment was performed.


## October 25 audit-fix candidate

This section supersedes older candidate statuses above for the current assignment.
Policy was read from local `origin/main` with `git show`: `73572280cf4d9478d56e42247be04dad8ad1acd9`.
CLIENT `web/new-design-w4f-r2` started clean at `78ee40770c5cd25b7ad5c15df75c451166d76d6c`.
PAYMENTS started clean at `8e5fac5d17ac0eb99a6ddbd5f919ce0035c8cc2e`.
STUDY started clean at `e5dbc20ae552455071c1956fa8e1195494109869`.
All three cached matching remote branch refs equal those heads. No fetch or pull was run.
The current lead brief supplies the audit rulings and authorizes the settled corrections.
L2/L3 W4f, the amendment spec, parallel/dependency map, startup policy, relevant decision rows,
and board sources were read from cached origin/main because the assigned client lacks those plan files.
No terminal relay tool is exposed in this session. Commands ran in the assigned Mac worktrees.
No commit, push, merge, dependency addition, deployment, or schema change was made.

### Per-item result

1. Done. `/pro` redirects to `/settings/pro` through the router. Replacing the URI path preserves
   its raw full query, including repeated keys and encoded values. Both success and cancellation
   are exercised through `settingsRoutes`; success invokes the actual checkout-return ledger read.
   The server return URL stays unchanged.
2. Done. Expired pass history uses “It ended after your exam on {date}.” Subscription expiry keeps
   its own existing wording. Both stale wrong-text assertions were amended.
3. Done. Every owned pass section has “A one-time purchase. It ends after the exam and never renews.”
4. Done. The eligible web pretrial action says “No payment needed.” The active web trial keeps its
   approved real end-date sentence. W4f student-facing contractions use curly apostrophes. Matching
   assertions changed with the text. The backup-state domain strings also supply student text and
   received the same punctuation correction.
5. Done. The confirmation claims carried work only after Count Them with measured overlap.
   Start My Numbers Fresh and zero overlap omit that claim. An unset exam date has no kept-date footer.
6. Done. Web upgrade asks the carry-over choice before checkout. It writes an account-keyed device
   marker, containing the source exam, target exam, tier, and choice. It changes neither selected exam
   nor carry-over setting before redirect. A confirmed success return applies the marker only when
   the same account still has the source exam and the confirmed live coverage includes the target.
   The local setting changes and marker removal share a database transaction. Cancellation clears
   that account’s marker. Unconfirmed returns, another account, insufficient Student coverage, and
   changed exam focus do not apply it. Abandoning checkout leaves the selected exam unchanged.
   The existing immutable study-settings publication runs after applying the choice.
7. Done. All listed catches report their error and stack through telemetryProvider.recordError.
   Captured telemetry sinks survive asynchronous route departure. Sign-in/sign-out use the connection
   line only for network errors. Other errors use the shared board generic error state with retry.
8. Not implemented. The exam value still says All subjects. The board sources draw only All subjects
   (ST_Exam and ST_ExamDate), with no approved partial-scope label. No replacement wording was invented.
9. Done. A web trial deletion warning omits the Google Play cancellation sentence. Native wording stays.
10. Evidence-only note recorded: native Free sign-out copy promises retained work, but the current
    native account-boundary wipe can remove local work before backup covers Free. Native is excluded
    from launch. No data-retention policy change was made here.
11. Done for the final 7 days. Upgrade and ordinary pass cards share the real-date countdown, including
    singular day. On exam day they use the existing Until date wording, never Ends in 0 days.
    No exam-day-specific pass board wording was found; that remains an explicit product copy gap.
12. Done. The target-exam upgrade has a real named route and opens with context.push. Popping returns
    to Change exam. The marker and source selection remain intact when leaving the upgrade.
13. Done. The root trial value says 1 day left, with plural wording for other counts.
14. Done. Redirected checkout busy state clears when the route becomes current again or the app resumes.
    The regression exercises both route return and visibility/lifecycle return. Pending native operations
    retain their existing duplicate-operation guard.
15. Evidence-only note recorded: native `/settings/reminders` lands with parked Task 1. The web row stays hidden.
16. Done in PAYMENTS. Failed eligibility or renewal reads retain plans, suppress trial eligibility,
    omit the renewal flag, and record the failure. Separate failing-first cases cover both reads.
17. Evidence-only note recorded in PAYMENTS: `8e5fac5d` already includes renewal ingestion and
    googlePlayPlanRenews. History is unchanged.
18. Done in STUDY. Catalog existence no longer switches the legacy loader. Authored relationships
    only identify excluded work when scope exclusions require them. A lessonless included topic
    permits all lessons to be excluded, matching the client’s at-least-one-topic rule.
19. Partially done within the existing configuration. About reads the configured BUILD_NUMBER through
    kBuildNumber and preserves explicit overrides. A BUILD_NUMBER=42 test demonstrates it. There is
    no existing runtime semantic-version source; the existing 0.1.0 default remains a known limit.

Additional audit requests: no dedicated billing-problem style or Gift state is drawn among the
available ST_Pro boards. S0-35 explicitly calls those undrawn states. No new visual treatment or
Gift label was invented under the brief’s “if a board draws it” condition. The billing-problem line
therefore retains its existing presentation, pending a board or explicit lead style ruling.

### Failing-first and diagnostic evidence

- Return router: both PayMongo success and cancelled cases failed because Pro was not reached;
  after the redirect, 3 checkout-return tests passed. `/tmp/w4f-router-red.log`, `-green.log`.
- Ended pass: correct text assertion failed, then passed (`/tmp/w4f-ended-red.log`, `-green.log`).
- Owned pass: footer absent failed, then passed (`/tmp/w4f-footer-red.log`, `-green.log`).
- Pretrial: No payment needed absent failed, then passed (`/tmp/w4f-trial-red.log`, `-green.log`).
- Confirmation: Fresh and zero-overlap cases failed, then all 12 exam tests passed
  (`/tmp/w4f-confirm-red.log`, `-green.log`).
- Pending return: success did not apply and cancellation did not clear the marker, 2 failed/2 passed;
  then all 4 passed. Later insufficient-coverage/source-focus guard cases verify existing guards.
  `/tmp/w4f-pending-red.log`, `-green.log`.
- Upgrade-route test was written before the route change. Its initial entitlement fixture lacked
  an expiry, so its first failure did not prove the intended upgrade behavior. After correcting
  that fixture and inspecting router state, the final test verifies the real route, choice-before-
  checkout, both choices, and abandonment. No claim that the first route-12 failure was valid RED.
  The new preparation catch was already present when its telemetry test was added; it passed first.
- Busy restoration: both lifecycle and route-return cases expected false but found true, then both
  passed. `/tmp/w4f-busy-red.log`, `-green.log`. Earlier lifecycle transition/pump-timeout diagnostics
  were corrected in the test; they are not failing-first behavior evidence.
- Countdown: upgrade day-1 and day-7 labels failed, then all 0/1/7/8 cases passed
  (`/tmp/w4f-countdown-red.log`, `-green.log`).
- Telemetry/web deletion: initial focused checks showed 11 failures; carry-over’s offscreen tap was
  corrected and its real missing-telemetry RED rerun separately. Remaining Pro user lookup, launcher,
  and exam-save telemetry cases each failed with no recorded error. Preparation telemetry passed
  first because the newly added preparation catch already recorded it.
  `/tmp/w4f-settings-errors-red.log`, `/tmp/w4f-carry-error-red.log`,
  `/tmp/w4f-pro-exam-errors-red.log`. Combined focused run passed 60 tests before the punctuation sweep.
- About configured build/singular day: 2 failed first; 48 focused tests passed with BUILD_NUMBER=42.
  `/tmp/w4f-about-trial-red.log`, `/tmp/w4f-about-trial-green.log`.
- Curly punctuation: the student-text assertion failed first (`/tmp/w4f-curly-red.log`). The family
  run then exposed two stale assertions: backup domain copy and the complete route inventory.
  Both were corrected; final focused checks passed 7/7 (`/tmp/w4f-latest-focused.log`).
- Consumer conversion required ProviderScope in direct deletion mounts, including the existing contrast
  test. Those test fixtures were corrected. Production deletion behavior and contrast tokens stay unchanged.

Independent read-only review found no behavior blocker in the checkout flow or backend fallback.
A separate reviewer inspected telemetry/web deletion/build-label changes and found no issue.
The remaining straight apostrophes were reported and corrected. Final visual acceptance remains
Aedwon’s; no app screenshot capture, live checkout, staging deployment, or device acceptance is claimed.

Final gate output and current status follow below after the full run completes.


### Late review corrections before final verification

The first combined full client run was interrupted without a pass claim after review exposed an
account-loading gap. Its diagnostic log is `build/w4f-audit/flutter-test-interrupted.log`.
The final full suite was restarted after the corrections below.

A pending return while currentUserProvider reloaded retained the old owner through valueOrNull.
The regression failed with expected exam_upcat, actual exam_cse_pro while identity was loading.
Identity-sensitive reads now unwrap previous values. A second regression demonstrated that a web
upgrade could call checkout while its current UID was still null; the purchase action now returns
before starting. Both cases were observed failing before their corrections. Logs:
`/tmp/w4f-owner-loading-red.log`, `/tmp/w4f-loading-offer-red.log`.
The first null-UID test asserted busy alone and passed; it was strengthened to observe actual
checkout calls before its valid RED. Corrected focused output:
```text
00:05 +25: All tests passed!
00:05 +39: All tests passed!
```
The active paid native warning’s apostrophe was normalized too. Its words and billing meaning
remain unchanged; the native trial warning is unchanged. That domain assertion failed first and
its remaining presentation assertion was updated. `/tmp/w4f-native-curly-red.log`.

STUDY review found two compatibility edge cases. Legacy topic-only exclusions must work without
reading an unreadable catalog. Also, authored topic relationships may be many-to-one with legacy
slugs; excluding one authored topic must retain included sibling questions and lessons. Both
regressions failed before correction. The final server totals are 183 plain and 242 emulator
passes; the study evidence records the amended source hashes. The original unconditional legacy
loader remains the source of compatibility content. Authored links only filter scoped work.

No application source changes are planned during the restarted full client run. Current source
identity is retained in `build/w4f-audit/source-manifest.json`; copied focused diagnostic logs are
in the same ignored directory. The final section below records its hash and full gate summaries.


Final independent rereview confirmed both identity-loading findings are resolved. No remaining
concrete checkout guard blocker was reported. Study’s final independent rereview also confirmed
legacy-only scope and authored sibling filtering, with source hashes matching its amended evidence.
The lead inspected final payments and study diffs and their actual check logs/summaries.

The exact approved pretrial selection supplied in the lead brief was “\"No payment needed.\" (Rec.)”.
No product copy was chosen by the implementor for the undrawn partial-scope or exam-day state.


### Final audit gate output and status

Flutter 3.44.6 stable, Dart 3.12.2. Flutter framework revision
`ee80f08bbf97172ec030b8751ceab557177a34a6`. Full environment is retained in
`build/w4f-audit/flutter-environment.json`. No application source/test file changed
between the final manifest and the passing full suite. Source/test manifest SHA-256:
`0d5ee771ee868c6cfe784fa46b342c572b2b1702c3b0d88e727ef838938e897e` (35 changed/untracked source/test files).

```text
flutter test --reporter expanded
09:45 +4960: All tests passed!
exit 0

flutter analyze lib test tool
No issues found! (ran in 26.3s)
exit 0

dart format --output=none --set-exit-if-changed lib test tool
Formatted 1595 files (0 changed) in 6.35 seconds.
exit 0

dart run tool/check_layering.dart
Running build hooks...Running build hooks...check_layering: OK
exit 0

dart run tool/check_no_ai_attribution.dart
Running build hooks...Running build hooks...check_no_ai_attribution: OK
exit 0
```

PAYMENTS actual final summaries (full literal npm wrapper used isolated ports,
isolated temporary storage, and execution-only serial emulator tests):
```text
npx tsc --noEmit
exit 0
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 121
ℹ pass 121
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔ Script exited successfully (code 0)
```
STUDY actual final summaries (plain runner and full isolated emulator globs;
default npm wrapper’s Firestore8080 collision is recorded in its evidence):
```text
npx tsc --noEmit
exit 0
Plain: # tests 183 / # pass 183 / # fail 0
Emulator: # tests 242 / # pass 242 / # fail 0
Script exited successfully (code 0)
flutter test test/features/metrics test/features/roadmap --reporter expanded
04:17 +314: All tests passed!
server_dart/build.sh --check
generated JS is current
```

Gateway files remain byte-identical. All three HEADs and their cached matching
remote refs equal their assigned baselines. Every diff check exited 0.
No changes were committed, staged, pushed, merged, deployed, or discarded.
No new dependency was added. Logs and status snapshots are in ignored
`build/w4f-audit/`; backend detailed logs remain at their evidence paths.

CLIENT final status:
```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4f.md
 M lib/app/routes/settings_routes.dart
 M lib/features/settings/application/settings_providers.dart
 M lib/features/settings/domain/backup_status.dart
 M lib/features/settings/domain/delete_account_copy.dart
 M lib/features/settings/presentation/carry_over_prompt.dart
 M lib/features/settings/presentation/pages/about_page.dart
 M lib/features/settings/presentation/pages/account_page.dart
 M lib/features/settings/presentation/pages/backup_page.dart
 M lib/features/settings/presentation/pages/delete_account_page.dart
 M lib/features/settings/presentation/pages/exam_page.dart
 M lib/features/settings/presentation/pages/name_page.dart
 M lib/features/settings/presentation/pages/pro_page.dart
 M lib/features/settings/presentation/pages/session_building_page.dart
 M lib/features/settings/presentation/pages/whats_included_page.dart
 M lib/features/settings/presentation/settings_value_formats.dart
 M test/app/router_paths_preserved_test.dart
 M test/core/sync/silent_sync_test.dart
 M test/core/ui/components/destructive_contrast_test.dart
 M test/features/settings/domain/backup_status_test.dart
 M test/features/settings/domain/delete_account_copy_test.dart
 M test/features/settings/presentation/about_page_test.dart
 M test/features/settings/presentation/account_page_test.dart
 M test/features/settings/presentation/carry_over_screen_test.dart
 M test/features/settings/presentation/delete_account_page_test.dart
 M test/features/settings/presentation/exam_page_test.dart
 M test/features/settings/presentation/pro_page_payments_test.dart
 M test/features/settings/presentation/settings_detail_pages_test.dart
 M test/features/settings/presentation/w4f_checkout_return_test.dart
 M test/features/settings/presentation/w4f_exam_test.dart
 M test/features/settings/presentation/w4f_pro_states_test.dart
 M test/features/settings/presentation/whats_included_page_test.dart
?? test/features/settings/application/w4f_trial_label_test.dart
?? test/features/settings/presentation/w4f_error_reporting_test.dart
?? test/features/settings/presentation/w4f_pending_exam_test.dart
?? test/features/settings/presentation/w4f_upgrade_checkout_test.dart
```

PAYMENTS final status:
```text
git status --short
 M docs/superpowers/plans/pwa-launch/evidence/W4f-payments.md
 M functions/src/webPlans.ts
 M functions/test/web-plans.test.mjs
```

STUDY final status:
```text
git status --short
 M docs/superpowers/plans/new-design/evidence/W4b-server-dependency.md
 M functions/src/roadmap.ts
 M functions/test/study-roadmap.emulator.mjs
```

### Remaining product decisions and limits

- Item 8: approve a partial-scope value for Your exam. Current board text is only All subjects.
  The current value remains incorrect when exclusions exist; this is an unresolved finding.
- Item 11: approve exam-day-specific pass wording if desired. The existing drawn Until date
  is used on day zero. No Ends in 0 days is printed.
- Extra billing-problem request: supply a board or explicit style ruling. Its existing line is
  retained because no specific board treatment was found.
- The conditional Gift request has no drawn Gift board. It remains unchanged. S0-35’s undrawn
  row suggestion is recorded above; no new board state was created.
- Item 19: semantic version remains the existing 0.1.0 default. The build number is configured.
- Native Free sign-out copy/backup coverage and native Reminders remain launch exclusions.
- Valid initial RED was not established for route 12’s first fixture or the newly added
  preparation-telemetry catch. Final functional coverage passes. Other listed observed RED
  evidence is preserved without treating compile errors or fixture errors as behavior proof.
- Aedwon’s phone visual acceptance and real deployed checkout behavior were not verified.


## Second fix round, October 25, 2026

Policy read with `git show origin/main:AGENTS.md`, `WORKFLOW.md`, and
`SUBAGENTS.md`: cached origin/main `73572280cf4d9478d56e42247be04dad8ad1acd9`.
No fetch or pull. CLIENT base `ce4f97d4d1c00e89a97286dfa6ea950a0aa9084a`.
PAYMENTS base `22c25edf`. Only these two assigned worktrees were changed.
No commits, staging, merges, pushes, deploys, hosting edits, or dependency additions.
Read the cached-main L2/L3 W4f plans, amendment spec, parallel map, startup,
routing and Actions policy, gap-f inventory, pricing, coordination handoff,
and ST_DeleteAccount board. Read C3's plan and actual checkout implementation
in PAYMENTS. This brief controls the bounded fixes below.

### Findings and current state

1. Client safeguards implemented. Every checkout return consumes the stored
   intent, including cancellation, no grant, wrong coverage, wrong session,
   old intent, changed exam focus, or a missing target. A new purchase, trial
   attempt, Free switch, failed checkout, and return to the waiting page clear
   the old intent. Before opening checkout, the gateway callback stores the
   returned session ID and creation time. Applying requires the same resolved
   account, explicit matching target and tier, matching `session_id` return query,
   confirmed coverage, unchanged source exam, and age between zero and 24 hours.
   Gateway code is byte-identical in CLIENT and PAYMENTS.
   **End-to-end integration is unresolved:** the actual server returns only
   `/pro?checkout=success|cancelled`, without session correlation. The ordinary
   return page also has no target. Such returns safely leave the selected exam
   unchanged. Asked the lead whether to add a server-generated return token tied
   to the returned session ID. No answer received during this run. No guessed
   PayMongo URL substitution or new server checkout contract was implemented.
2. **Target-exam trial change not implemented.** Current `trial` explicitly
   requires `!upgrade`. The approved plan and existing test require no trial on
   the target-exam upgrade. The reported duplicate trial prompt cannot execute
   through the current target-exam page. Asked whether to retain that rule or
   enable web target-exam trials. No answer received. The existing ordinary web
   trial now clears a stale intent before it starts. No new target-exam trial
   behavior or carry-over result contract was invented.
3. **Web-lineage integration requirement:** `web/pwa-staging-r1` must build with
   path URLs and a hosting rewrite that serves the Flutter app for
   `/pro?checkout=success|cancelled`. Test that exact browser return URL on the
   integrated web build. This worktree does not change hosting or URL strategy.
4. Done. Web prepaid plans omit the Play and future-charge billing warnings.
   The board has no prepaid web deletion sentence, so no replacement was added.
   The existing web trial sentence and native billing copy stay intact.
5. Done in code. The account-change exit after preparation resets busy and
   discards the original account's intent. Regression scenarios check busy is
   false and checkout never opens when identity changes around persistence.
   **Evidence limit:** the original-source characterization failed on checkout
   opening, not the busy assertion itself. A separate busy-only RED was not
   reproduced. This is not claimed as a distinct test-first reproduction.
6. Done. `_sameAccount` explicitly rejects loading. Checkout returns await the
   resolved current user before applying. Malformed JSON or typed fields are
   consumed and reported without replacing the payment result with a save error.
   Same-owner refresh and changed-owner loading cases are covered.
7. Done in PAYMENTS. Renewal and eligibility are read and caught separately.
   Each error is recorded. One failure preserves the other's successful value.

### Observed failing tests

- Pending-intent tests before the fix: `00:01 +4 -8: Some tests failed.`
  Stale intents remained after an unconfirmed return and changed coverage/focus.
  Missing-target, wrong-session and expired intents incorrectly switched exams.
  Malformed JSON remained stored and replaced checkout feedback with a save error.
  Log: `build/w4f-r2/pending-red.log`.
- Upgrade persistence/abandonment tests before gateway/cleanup changes:
  `00:07 +0 -2: Some tests failed.` The persisted value had no session/time and
  remained after returning. Initial assertions inside the fake opener were
  swallowed by gateway error handling; final assertions inspect captured state
  outside the opener. Only the observed abandonment failure is claimed from that
  initial run. Log: `build/w4f-r2/checkout-red.log`.
- Account-change regression characterization against temporarily restored HEAD
  Pro-page source: `00:11 +0 -16: Some tests failed.` Expected no checkout open,
  actual one. The edited source was restored in a Python `finally` block.
  The narrower edited-source race run also failed for later persistence
  interleavings. Logs: `busy-original-red.log`, `busy-red.log` in the same directory.
- Web deletion tests before the fix: `00:02 +2 -6: Some tests failed.` Paid plans
  displayed Play/future-billing copy or the native dated-expiry sentence.
  Afterward: `00:02 +10: All tests passed!`, including both native/web trial cases.
- PAYMENTS before the fix: 10 tests, 7 pass, 3 fail. Eligibility failure lost
  successful renewal (`undefined` instead of `true`). Renewal failure lost trial
  eligibility (`false` instead of `true`). Two failures recorded only one error.
  Afterward: 10 tests, 10 pass, 0 fail. Logs:
  `/tmp/w4f-r2-plans-red.log`, `/tmp/w4f-r2-plans-green.log`.

Required final checks and source/status identity are recorded below after completion.
Phone visuals, real PayMongo checkout, deployed App Check and real web returns
were not tested. Independent acceptance remains with the lead.

### Final automated verification

CLIENT code/test diff SHA-256: `82f70d892199feb789377ff16c5af6abbb084810905badc336a3b2c68facd6d9`.
PAYMENTS functions/gateway diff SHA-256: `a5a2cac38ae0847aa2765ae306c7a81eb4d314739f8d3dfba3bf3634a2628737`.
Digests exclude documentation. The final source remains uncommitted at its assigned base.

Actual summaries:
```text
flutter test test/features/settings test/features/paywall test/app --reporter expanded
00:42 +684: All tests passed!
flutter analyze lib test tool
No issues found! (ran in 4.9s)
dart format --output=none --set-exit-if-changed lib test tool
Formatted 1595 files (0 changed) in 2.93 seconds.
dart run tool/check_layering.dart
check_layering: OK
dart run tool/check_no_ai_attribution.dart
check_no_ai_attribution: OK
npx tsc --noEmit
exit 0
PATH=/opt/homebrew/opt/openjdk@21/bin:$PATH npm test
ℹ tests 122
ℹ pass 122
ℹ fail 0
ℹ tests 145
ℹ pass 145
ℹ fail 0
✔  Script exited successfully (code 0)
```

All commands above exited zero. Final client logs: `build/w4f-r2/` (ignored).
PAYMENTS execution details and full log are in its W4f-payments evidence.
Gateway `cmp` and both worktrees' `git diff --check` exited zero.

CLIENT `git status --short`:
```text
 M docs/superpowers/plans/new-design/evidence/W4f.md
 M lib/features/paywall/data/web_payment_gateway.dart
 M lib/features/settings/presentation/pages/delete_account_page.dart
 M lib/features/settings/presentation/pages/pro_page.dart
 M test/features/settings/presentation/w4f_error_reporting_test.dart
 M test/features/settings/presentation/w4f_pending_exam_test.dart
 M test/features/settings/presentation/w4f_upgrade_checkout_test.dart
```

PAYMENTS `git status --short`:
```text
 M docs/superpowers/plans/pwa-launch/evidence/W4f-payments.md
 M functions/src/webPlans.ts
 M functions/test/web-plans.test.mjs
 M lib/features/paywall/data/web_payment_gateway.dart
```

Files outside the original W4f presentation table: shared gateway (required
pre-redirect session persistence, mirrored in PAYMENTS), PAYMENTS plans source
and unit tests (explicit item 7), and the two existing evidence files.
No other worktree was read or changed. No independent review or acceptance of
the unresolved checkout/trial contracts is claimed. Stop conditions: actual
checkout return lacks session correlation; target-exam trial request conflicts
with the approved no-trial upgrade and current behavior. Required user rulings
remain pending. The exact busy-only defect has no separate observed RED.
