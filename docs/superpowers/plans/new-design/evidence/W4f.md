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
