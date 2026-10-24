# W4a implementation evidence

## Identity and permissions

- Policy and plan reference: origin/main at da314d1e8bb1d68f617ef50ee0b23aea46ee605b, fetched and read on resumption.
- Original policy read before interruption: 56f642543e9c04de7dc673f8d1674c6cc222c4d6.
- Execution base: cee7a9c55387674787030c722967104705d7bb3a.
- Workspace: Pantas-wt-new-design-w4a-r1, branch web/new-design-w4a-r1. Clean at startup. Remote has no branch of this name.
- Read L3 and L2 W4a, W4a traceability rows, the amendment spec, restart decisions, shared state-pattern contract, L3 parallel map and W2 lead rulings.
- Main's design references are absent on the application base. Read-only reference extraction: /tmp/pantas-w4a-context.xJGiZz, from the pinned main revision above. No merge or source replacement.
- No push, merge, publication or change to paused work. Human visual acceptance and independent review remain with the lead.

## Dependencies

W4f Task 1 has not landed on this base. ReminderPrefs does not exist here. Task 8 must wait for that contract. The lead was asked for the dependency revision. No substitute reminder settings are introduced.

## Task 1: flow foundation

Implemented the complete step enum, storage-derived progress, six-segment mapping, and branch-preserving Back model. Rebuilds no longer repeat step telemetry. Screen wiring and moving the actual completion write out of Name remain required as the later screen tasks replace the widgets. Task 1 is not yet fully complete or accepted.

O_Flow progress measurements: Age 1/6, Terms 2/6, Picker 3/6, Date 4/6, Days 5/6, Name 6/6. Custom Name and Subjects remain on segment 3. Launch, Welcome and Reminders have no bar. Segments are height 4, radius 9, gap 6, horizontal inset 20.

Tests use the real database to distinguish absent study days from the default all-days value. An unknown date has a device-local answer flag because an intentionally unset date cannot prove the step was answered. No schema change.

### Observed commands

- Initial telemetry test could not compile: ignored database-generated files were absent. No product code changed to repair this.
- `dart run build_runner build --delete-conflicting-outputs`: exit 0. `Built with build_runner/aot in 25s; wrote 2735 outputs.` Ignored outputs are not staged.
- Telemetry RED: exit 1. Expected one onboardingStepReached event; actual two after a rebuild.
- Flow-model RED: exit 1, planned new API absent. GREEN: exit 0, `00:00 +5: All tests passed!`.
- Storage-resume RED: exit 1, onboardingProgressProvider absent. Corrected a test's mistaken call of the existing StudyDays.all constant before confirming the missing API failure.
- `flutter test test/features/onboarding/application test/features/onboarding/onboarding_telemetry_test.dart`: exit 0, `00:00 +7: All tests passed!`.
- `flutter test test/features/onboarding test/features/assessment test/app`: exit 0, `00:19 +173: All tests passed!`.

No full-suite run, device capture or autonomous visual review performed.

## October 12 resumption

Policy refreshed from main at 1b42368085918a1cdf6df3e905b156b01387c451. AGENTS, WORKFLOW and SUBAGENTS read in full. L3 W4a, L2 W4a, the amendment spec and W2 rulings are unchanged from the earlier pinned reference. Read the later restart-log addition concerning W4h integration and W3 audit 1. The application worktree remains at the assigned cee7a9c5 base with this worker's unsaved changes. No work was discarded.

## Open questions

- Task 1/8: O_Flow Reminders frames have no Back link or progress bar. L2 requires Back after Welcome and L3 says system Back equals the Back link on every step. The model already walks Reminders back to Name. Confirm whether the Reminders view needs a visible Back link. No Reminders view is implemented while this question and its missing W4f contract remain open.
- Task 8: supply the W4f Task 1 revision containing ReminderPrefs. It is absent at this base. No merge or cherry-pick is performed by this worker.

## Task 2: Launch and Welcome

Implemented and automated checks passed. Independent review and human visual acceptance are pending. Task 1's model and storage tests remain uncommitted drafts while its full screen wiring is unfinished. Task 2 is independent of the open Reminders questions.

Boards read with outline.py first: O_Launch and O_Flow. timeline.py: logo pop starts at 150 ms, reaches scale 1.12 at 510 ms, settles at 750 ms, using (.34,1.56,.64,1) within each keyframe interval. Page fade is 300 ms ease. Subsequent step entry pushes 40 px over 380 ms with (.2,.9,.3,1). Motion-off skips Launch in the actual flow and shows Welcome at rest. Hidden incoming/outgoing controls do not participate in focus or semantics.

Metrics: logo 120 on Launch, 104 on Welcome; Welcome top inset 180, logo-to-heading gap 28, heading-to-detail gap 10; heading 34/700, height 1.12, spacing -0.748; detail 17/400, height 1.45; footer insets 20/12/20/34, button minimum height 52, radius 14. Colors use W1's surface, label, secondaryLabel, accent and button tokens. Tests cover light/dark, 390-wide screens, 200% text, contrast, target labels, keyboard activation, reduced motion and controller teardown.

The exact logo paths already exist in a private painter in W4h's Update screen. This family uses those same board paths without changing that other screen. No new asset, package or color literal is introduced.

Files: onboarding_page.dart, onboarding_welcome_step.dart; onboarding telemetry, page, Welcome and new Launch tests; test/app/router_redirect_test.dart updates the Welcome expectation only; this evidence file. The router test is within this plan's test/app scope. No production router change.

### Observed checks

- Welcome RED: old heading/copy and old control fail the board tests. GREEN: 5 tests passed.
- Launch RED: the new screen API was absent. Added fade and keyframe tests also failed before their implementations.
- Push RED: expected 380 ms, actual 220 ms.
- Launch/Welcome/page focused checks: exit 0, `00:01 +10: All tests passed!`.
- Task checks: `flutter test test/features/onboarding test/features/assessment test/app`, exit 0, `00:10 +179: All tests passed!`. This run includes seven uncommitted Task 1 model/storage tests; Task 2 does not import that draft model.
- Focused Dart analysis of changed onboarding source and tests: exit 0, `No issues found!`. Initial 27 lint findings were corrected with scoped trailing-comma/unused-import fixes and formatting.
- `git diff --check`: exit 0.

The full suite has not run. No device screenshots, autonomous visual review, pushes or merges occurred.

## Latest resumption and Task 3

Policy refreshed and read from main at 9e8e029d7edb38859a63aec4e906ed4685ed931b. AGENTS, WORKFLOW and SUBAGENTS read in full. Product spec, L2/L3 W4a, traceability and W2 rulings are unchanged from the earlier references. No main merge.

Task 3 implements O_Age and O_Consent. Age opens on 2012 for the fixed 2026 fixture, allows the default value, blocks a year newer than 2013, and writes only the age-passed boolean. No birth year is stored. The blocked state has the 72 px logo, 26/700 title, 17 px detail and Try a Different Year. The whole blocked frame fades for 300 ms ease; returning pushes 40 px over 380 ms riseIn. State transitions hide inactive controls from focus.

Usage consent comes first and starts off. Terms comes last and enables Continue. Both legal links activate and return without clearing either choice, including keyboard activation. Usage choice saves before policy acceptance, so a failed write cannot leave the acceptance resume marker ahead of an unfinished choice. The existing acceptance writer records policy version 1. Both screens use the shared saveFailureLine and retain their input for retry.

Shared extensions, permitted by the dispatch:

- PantasPage.onboarding: O_Age/O_Consent header 52 high, Back target 44 with 24 icon, six progress segments height 4/radius 9/gap 6/inset 20; title 30/700/1.12/-0.66, detail 17/400/1.4, body inset 16/4/16/32, footer 20/12/20/34. Optional progress, detail, bodyGap, centered body and surface background serve the drawn variants. Existing constructor behavior stays unchanged.
- ValueWheel.birthYear: O_Age seven rows, row height 44 at ordinary text, selected 22/600, other years 19/400, tabular figures, selected background fill/radius 10. Rows grow to 73.4 at 200% text. Adjacent years use label, farther years secondaryLabel. No local colors.
- ListRow.checkbox: O_Consent 24 square/radius 7/controlOutline 1.5, gap 14, inset 16/14, body label 16/400/1.4 with wrapping. Selected check uses the exact 15 px SVG with 24-unit viewBox and 3-unit stroke, popping over 500 ms. Optional content supports independently focusable legal links. A private style flag preserves the existing ListRowVariant enum and ordinary row contracts.
- StateView.onboardingBlocked: O_Age 72 mark, gap 12, title 26/700/1.35/-0.312, detail 17/400/1.35. It announces the state. Existing empty/error variants retain their behavior.

Extensions have tests beside W2's tests. Color pairs are checked against the actual surface/selection backgrounds in light/dark. The unchecked boundary uses W2's controlOutline ruling, not the board's low-contrast chevron color. The logo widget is exposed within this family for Age to reuse the exact Launch paths. No other family's screen is restyled.

Two existing ValueWheel defects were reproduced and fixed in the shared component: controlled vertical updates echoed a selection while an ancestor was rebuilding; vertical keyboard moves emitted two callbacks. Programmatic jumps now suppress the scroll notification, and a keyboard move emits its explicit callback once. Tests failed before each fix.

Visible and system Back from Age/Terms return to the same preceding step. Completion and resume wiring for the later screens remain part of unfinished Task 1. Callback guards prevent an old Age/Terms save from advancing a screen after Back.

### Exact observed checks

- New board/API tests failed before the shared extensions and rebuilt screens existed.
- Save-failure tests failed without the handlers, then passed with the shared retry line and retained input.
- Age/Terms Back test failed before wiring and PopScope, then passed.
- Blocked whole-frame fade test failed before the full frame animated.
- Tabular-figure and recorded check-stroke tests failed before those board details were implemented.
- Controlled vertical update and keyboard callback tests failed before their respective fixes.
- Focused new UI/shared tests: exit 0, `00:01 +33: All tests passed!` before the final added keyboard/stroke cases.
- Task checks plus extension tests: `flutter test test/features/onboarding test/features/assessment test/app test/core/ui/components/onboarding_extensions_test.dart`, exit 0, `00:19 +205: All tests passed!`.
- Existing affected W2 suites plus extensions: `flutter test test/core/ui/components/onboarding_extensions_test.dart test/core/ui/components/structure_completion_test.dart test/core/ui/components/inputs_completion_test.dart test/core/ui/components/states_completion_test.dart test/core/ui/components/row_dialog_accessibility_test.dart test/core/ui/components/audit_horizontal_wheel_test.dart`, exit 0, `00:03 +54: All tests passed!`.
- Focused analysis of changed shared components and onboarding files/tests: exit 0, `No issues found!`.
- Scoped formatting and `git diff --check`: exit 0.

The family runs still include seven uncommitted Task 1 draft tests. No full suite, device check, independent acceptance, push or merge is claimed.

## Task 4 preflight findings

O_DateKnown's selected weekday uses 11/600 rgba(255,255,255,0.85) on #0B7A68. The composite is RGB (218.4,235.05,232.35), contrast 4.265127309719463:1. Active small text requires 4.5:1. Full-opacity W1 on-accent text gives 5.252707549062497:1. The same pair appears on O_DateToday. This needs a lead design ruling before reproducing or changing that pair.

D-34 permits an exam today and reaching the exam-day Home state. D-39 and Task 7 require a study day before the exam. There is no calendar day in [today,today). The plan does not state the today exception for Study days. The lead must choose that behavior; it is not inferred by the worker.

## October 12 picker resumption

Policy refreshed and read at origin/main 2d3fd381598fefbd0570b048c019aa7500ae1d30. The assigned branch remains web/new-design-w4a-r1, based on cee7a9c5. The remote has no matching working branch. Existing commits da8a3020 and eea651c0 and all uncommitted drafts were preserved. L2/L3 W4a and the amendment spec are unchanged. The later restart-log entry records W3 integration at 2d438daf; no integration into this worker's branch is authorized or performed.

## Task 5: ExamPickerScreen

Implemented O_Picker and ST_ExamPick modes. The W0 catalog supplies groups, names, published metadata and selectable/Coming soon status. Onboarding chooses locally, then writes the exam selection on Continue without completing onboarding. Settings returns the selection to its caller without changing onboarding preferences, so W4f retains ownership of switching. Search matches the supplied exam and organization names. All clears the group filter. The custom action stays first. Loading, failure, empty and save-failure states use W4h helpers or W2 StateView, with retained selection and live announcements. Back and system Back agree in both modes; the embedded picker returns to Terms exactly once.

Boards read with outline.py first and timeline.py. O_Picker uses the shared 300 ms ease fade; ST_ExamPick has no CSS animation. Existing W2 SearchField retains Aedwon's accepted placeholder contrast ruling. PUPCET's organization line is explicitly supplied by O_Custom and is included. No new package, local color literal, generated file or other family's screen change.

Shared extensions and metrics:

- PantasButton.filterChip: 32 minimum height, radius 99, horizontal inset 14, text 14/600, selected label/surface colors reversed. At 200% text it grows to 38. Existing button variants keep their behavior.
- ListRow.exam: onboard vertical inset 11, settings 10, horizontal 16, title 17/400/1.35/-0.204 with the existing one-line title rule; detail 13/400/1.35; selected check 18 with the board's 2.4-unit stroke. Disabled rows use opacity .45 and Coming soon 13/500, stacking the status below labels at large text. Optional divider is .5, inset 16 for onboarding and full width for Settings.
- GroupedSection.headerStyle: optional override supports onboarding header 13/500 and Settings 13/600, leaving the default unchanged.
- ListRow.titleColor: optional override supplies the custom-exam action's accent text.
- PantasPage.settingsPicker: header 44, insets 4/6/8/0; body 16/8/16/32; title 28/700/1.2, gap 22. Onboarding adds optional detailLineHeight; O_Picker uses 1.35 and bodyGap 24.

Files: lib/features/onboarding/presentation/exam_picker_screen.dart and onboarding_page.dart; lib/core/ui/components/grouped_section.dart, list_row.dart, pantas_button.dart and pantas_page.dart; test/core/ui/components/exam_picker_extensions_test.dart; test/features/onboarding/presentation/exam_picker_screen_test.dart and onboarding_page_test.dart; test/app/router_onboarding_completion_test.dart and router_redirect_test.dart. The consent test additionally scrolls to the actual checkbox before tapping at 200% and asserts the resulting choice; this removes a missed-tap warning found during the required family checks.

### Observed checks

- RED before the earlier interrupted implementation: the new picker and shared extension APIs were absent. Detail line-height and row-divider tests also failed before their changes.
- PUPCET organization RED: exit 1, expected Polytechnic University of the Philippines, found none. GREEN in the final run below.
- Initial resumed family run exposed asset loading under a fake clock and off-screen CSE taps in existing router/page fixtures. Tests now preload the actual W0 catalog outside that clock and scroll to the row before tapping. The interrupted run is not counted as green.
- New check paint verification initially failed on float32 representation of 2.4; the assertion now pins the board width through Paint's actual stored representation.
- `flutter test test/features/onboarding test/features/assessment test/app test/core/ui/components/exam_picker_extensions_test.dart`: exit 0, `00:21 +211: All tests passed!`. This includes seven uncommitted Task 1 foundation tests and the existing legacy picker tests pending Task 11 deletion.
- `flutter test test/core/ui/components/structure_completion_test.dart test/core/ui/components/row_dialog_accessibility_test.dart test/core/ui/components/exam_picker_extensions_test.dart`: exit 0, `00:02 +17: All tests passed!`.
- Focused Dart analysis of the twelve changed source/test files: `No issues found!` before the final formatting-only trailing-comma correction to the consent test. The correction is rechecked before commit.
- Scoped formatting and git diff --check: exit 0.
- Source/test identity for the named twelve files, sorted paths and contents with NUL separators: SHA256 db8ebd061419898773ccab1961ad9b659458bd83cfd4250b01f9091f857d4ff0 before the final formatting-only comma correction.

Task 5 is implemented and checked. Independent review and Aedwon's visual acceptance remain pending. No full suite, push or merge.

## Task 6 preflight contrast finding

O_Custom draws the active Exam name placeholder at 19/500 in #AEAEB2 on #FFFFFF: 2.211218681144401:1. This is below 4.5:1 for active text. The SearchField exception is specific to search. W1 secondaryLabel #6E6E73 gives 5.071321606018516:1 on white. Asked for either that token or an explicit exemption; no answer has arrived. Dependent input styling is held.

## Latest resumption at e354ebe3

Fetched origin and read AGENTS.md, WORKFLOW.md and SUBAGENTS.md again at e354ebe3c37e2d23a035f79da393c4e0da94a33e. The policy files and W4a product documents are unchanged. The changed status record still says W4f and W4d have not started. No missing dependency was supplied. Branch head remains 1af8dc0bf12377c180ba86d3518519313797ba2f. No push or merge.

Task 5's final formatting-only consent-test correction was rechecked with Dart analysis: exit 0, No issues found! The Task 5 evidence is committed at 1af8dc0b. Later notes in this section remain uncommitted with the incomplete task drafts, so the worker does not create a second Task 5 commit or claim the full plan passed.

### Task 9 independent selector draft

Changed the cap from 35 to 30 in lib/core/storage/domain/assessment_question_selector.dart. The feature's named selector file is an export; the implementation is in this core file. The per-topic contributing-topic formula is unchanged.

- RED: flutter test test/features/assessment/domain/services/assessment_question_selector_test.dart --plain-name 'respects the 30-question cap', exit 1. Expected 30, actual length 35.
- GREEN: flutter test test/features/assessment/domain/services/assessment_question_selector_test.dart, exit 0, 00:00 +7: All tests passed!
- dart analyze lib/core/storage/domain/assessment_question_selector.dart test/features/assessment/domain/services/assessment_question_selector_test.dart: exit 0, No issues found!
- dart format --output=none --set-exit-if-changed on the same two files: exit 0, Formatted 2 files (0 changed) in 0.01 seconds.
- git diff --check: exit 0.

This is an uncommitted Task 9 draft, not a finished Task 9. The assessment screen has not been rebuilt. The existing zero-content regression already exercises the real selector and checks the not-ready copy; it is not claimed as a new failing regression.

### Additional required contract gap

AS_Question, AS_Picked and AS_Leave draw the top-right Report control (21 px icon, stroke 1.9, target 44). The controlling design decisions specify the shared report form in the floating bar. W4d Task 7 owns its form and local report_queue.dart. That file and any report form or entry interface are absent in the assigned base. The current main status says W4d has not started. A dead or disabled substitute would change the approved board. The lead must supply the shared report entry contract/revision or record a plan ruling before this part of Task 9 can be built. No other family's files were changed to invent it.

AS_Results draws elapsed minutes, but this base captures no assessment timing: CompleteAssessment writes responseMs 0 and the same now to attempt startedAt and completedAt. No 24-minute board sample, zero-minute substitute or inferred duration is printed. The result work will need actual timing capture using the existing storage, or a recorded ruling for unavailable legacy timing, before that line can be reproduced. Task 10's required cache refresh must land in the rebuilt completion path from Task 9. The archived source has been retrieved read-only; no cherry-pick or merge was attempted.

### Remaining task states

- Task 1: model/storage drafts checked, no commit; complete screen/resume wiring and the completion-write move are unfinished. Waits for the later screens and the Reminders ruling/contract.
- Task 2: committed da8a3020.
- Task 3: committed eea651c0.
- Task 4: held for the selected weekday contrast ruling and the exam-today Study days rule.
- Task 5: committed 1af8dc0b.
- Task 6: held for the active name-placeholder contrast ruling. No custom-track replacement is implemented.
- Task 7: held for the exam-today Study days rule; no Days/Name replacement is implemented.
- Task 8: held for W4f ReminderPrefs and visible Back ruling.
- Task 9: independent cap draft checked, no commit; reporting contract gap above.
- Task 10: not implemented; rebuilt completion path and actual timing need resolution.
- Task 11: not complete. Legacy deletions, the one full-suite run, combined gates, independent review and Aedwon's phone checks remain.

### Additional gates observed

- dart run tool/check_layering.dart: exit 0, check_layering: OK.
- dart run tool/check_no_ai_attribution.dart: exit 0, check_no_ai_attribution: OK.

These checks ran at committed Task 5 before the independent selector draft. No full-suite run has occurred. No runtime screenshots or device checks are claimed.

### Exact committed file inventory


Task 2, da8a3020bb3e3375beaa9aa9c91097651f737bb6:

- docs/superpowers/plans/new-design/evidence/W4a.md
- lib/features/onboarding/presentation/onboarding_page.dart
- lib/features/onboarding/presentation/onboarding_welcome_step.dart
- test/app/router_redirect_test.dart
- test/features/onboarding/onboarding_telemetry_test.dart
- test/features/onboarding/presentation/onboarding_launch_step_test.dart
- test/features/onboarding/presentation/onboarding_page_test.dart
- test/features/onboarding/presentation/onboarding_welcome_step_test.dart

Task 3, eea651c090d34c55c3a7f690119428d66f5b6550:

- docs/superpowers/plans/new-design/evidence/W4a.md
- lib/core/ui/components/list_row.dart
- lib/core/ui/components/pantas_page.dart
- lib/core/ui/components/state_view.dart
- lib/core/ui/components/value_wheel.dart
- lib/features/onboarding/presentation/onboarding_age_gate_step.dart
- lib/features/onboarding/presentation/onboarding_consent_step.dart
- lib/features/onboarding/presentation/onboarding_page.dart
- lib/features/onboarding/presentation/onboarding_welcome_step.dart
- test/core/ui/components/onboarding_extensions_test.dart
- test/features/onboarding/presentation/onboarding_age_gate_step_test.dart
- test/features/onboarding/presentation/onboarding_consent_step_test.dart
- test/features/onboarding/presentation/onboarding_page_test.dart

Task 5, 1af8dc0bf12377c180ba86d3518519313797ba2f:

- docs/superpowers/plans/new-design/evidence/W4a.md
- lib/core/ui/components/grouped_section.dart
- lib/core/ui/components/list_row.dart
- lib/core/ui/components/pantas_button.dart
- lib/core/ui/components/pantas_page.dart
- lib/features/onboarding/presentation/exam_picker_screen.dart
- lib/features/onboarding/presentation/onboarding_page.dart
- test/app/router_onboarding_completion_test.dart
- test/app/router_redirect_test.dart
- test/core/ui/components/exam_picker_extensions_test.dart
- test/features/onboarding/presentation/exam_picker_screen_test.dart
- test/features/onboarding/presentation/onboarding_consent_step_test.dart
- test/features/onboarding/presentation/onboarding_page_test.dart

## Resumption under the October 12 lead rulings

Policy revision: origin/main 900e9f3730a93442fbf4004c148e815bfd45170a. AGENTS.md, WORKFLOW.md, SUBAGENTS.md, Standing rulings for W4 families and L3 W4a's Lead rulings read. The lead merged integration into this branch at ed010a89. Existing work and all drafts were preserved. No schema change entered through that merge.

The earlier contrast and behavior questions are resolved by the new rulings. Selected translucent white becomes full onAccent. Placeholders stay as drawn. For an exam today, one chosen study day is enough. Reminders has no visible Back or bar, with system Back returning to Name. Missing family controls are omitted and listed; they no longer stop the remainder of a task.

Waiting on a contract: Task 8 needs W4f Task 1 ReminderPrefs. The AS Report control needs W4d Task 7's report-entry function. Task 11 waits for Task 8. No disabled or dead replacement is added.

## Task 1 commit: flow, resume and completion boundary

The storage progress model, six segment mapping, complete step enum and Back model are now wired into OnboardingPage's initial resume and telemetry. Terms cannot be bypassed by an exam selection. Name saves without writing the completion flag. The new custom/date/day screen tasks fill the corresponding model branches as they replace the old widgets. Reminders remains an omitted branch until its contract lands.

RED: Name tests expected false completion but received true. Custom Back expected Picker but received Custom Name. A page-resume regression expected Terms but the old page showed Welcome. The new flow and removal of Name's completion write pass these tests.

Required task checks: flutter test test/features/onboarding test/features/assessment test/app, exit 0, 00:33 +213: All tests passed! Includes the preserved independent Task 9 selector draft. The interrupted runs are not counted as green.

The new policy-accepted fixture creates sync work on the integrated branch. Router assertions passed but database teardown hung while the app remained mounted. The affected app fixtures now unmount the widget and dispose its providers before closing the database. The isolated retired-route test passes (00:02 +1: All tests passed!). Temporary diagnostic prints were removed. One RED invocation was mistakenly started before an earlier hanging run ended; all subsequent Flutter commands were serialized.

Focused Dart analysis and formatting are checked before this commit. No full suite, phone check, independent acceptance, push or merge is claimed.

Task 1 final focused checks: exit 0, 00:05 +19: All tests passed! Focused analysis: exit 0, No issues found! Formatting and git diff --check: exit 0.


## October24 CSE PWA continuation candidate, before family audit

Controlling policy main06c6ca79 read in full, refreshed workflow context21e9ee80; current status/authorization recorde176253d. Read the original approved amendment, L2/L3 W4a, standing W4 rulings and October19 PWA launch spec/plan in full. Later L3 October24 implementation details govern measured completion and the web branch. User expressly resumed W4a while W4b is paused and authorized direct local execution. The original four modified files and one untracked date test were preserved. Remote42ee0327 is an ancestor of original local3b2d8b33; no remote-only commits existed. Retained stash preserves the complete pre-dependency continuation patch.

Accepted development4113ad78 merged into W4a atba5f1e8a. Three explicit shared component conflicts preserve both onboarding and accepted ordinary/quiz/mock/bookmark contracts; automatic ListRow initialization repaired. Generation: exit0,2026outputs.45affected component tests pass. Native/web/source tests run locally, no relay required or used after the user's override.

### Implemented launch scope

- Tasks1/4/6/7: actual storage resume and branch-preserving custom flow, published first-day or month/optional day/unknown date, today allowed, Sunday-first initially empty study days with date availability, required trimmed40-character name and custom name, unticked corpus subjects with at least one required, retained saved Name/days/date on return, shared save/retry UI. Custom creation explicitly keeps completion false. Built-in and custom paths reach date, days and Name inside onboarding. Web writes completion once only after valid Name and emits completion telemetry once. Other built-in exams show Coming soon on web, while native catalog behavior stays unchanged.
- Task8: web omission is implemented per the approved PWA adjustment. Native ReminderPrefs screen/service remains parked with W4f and is outside this launch candidate; no native reminder completion is claimed.
- Tasks9/10: selector cap30 with narrowed-track formula preserved; pick/change pick then Next, real count without jumping, real report entry/queue, one destructive leave dialog, not-ready/load/retry states. Completed assessment routes Home. Session start/response timing and stable attempt identity are captured in memory. Attempt, assessment and review seeds commit atomically, same-attempt retry does not seed twice, a second attempt cannot overwrite a completed assessment, original database/account-lifetime/context-token/exam/UI boundary stays checked across waits. Stale picks are discarded with retry UI. Today/Quiz/roadmap caches refresh after completion, including custom tracks.
- Results aggregate actual topic scores by actual subject, weakest first; show measured count/elapsed duration and weakest topic; no legacy duration is invented. Acknowledgement is keyed to the persisted assessment completion; after Go to Today a later results visit routes Home. AS_Results entry/bar/count tracks are represented through one-shot effects and the shared assessment-count gauge variant. Per-question timing remains excluded from existing legacy assessment speed signals; no W4b insight or learning-rule change is part of this candidate.
- Task11: unused legacy picker and its superseded tests deleted. Custom URL aliases remain for existing route callers and return through the real flow. No generated files, schema, dependency, price, payment, server ownership, or paused W4b changes.

### Fresh observed checks before freeze

- Original date/cap drafts retained; cap RED expected30/actual35 is in prior evidence. Date APIs/today rejection, required-name/custom-selection, missing study-days view and old flow produced RED failures before implementation.
- Custom full web flow RED: legacy completion true immediately after custom creation. GREEN: actual custom-to-date-to-days-to-name-to-Home flow keeps false until Name.
- Saved Name and explicitly saved study days RED before restoration, then13restoration/web cases passed.
- Account/context replacement RED left old picks active; corrected real UI regression plus seven existing assessment cases pass8.
- Measured timing/retry identity and second-session completion protections have domain regression coverage; renewed domain pass included in388case run.
- Date calendar cards/large-text/reduced-motion/selected strip/year320ms tests pass. Reduced-motion AnimatedSize layout mutation was reproduced and bypassed at the shared wrapper; optional-day header wraps without overflow. Day strip uses450ms delay and900ms house-strip curve, selected year uses320ms push; ordinary constructor retained.
- Results subject aggregation, empty result, one-time acknowledgement, light/dark and200% cases pass7.
- Final combined focused command: flutter test --no-pub test/features/onboarding test/features/assessment test/app test/features/settings test/core/ui/components/onboarding_date_extensions_test.dart: exit0,01:31 +388: All tests passed!
- Last bounded web-completion/Days run after telemetry/date-copy correction: exit0,00:02 +7: All tests passed! Telemetry RED produced six completions before the terminal latch; GREEN asserts exactly one.
- dart analyze lib test tool: exit0, No issues found!
- git diff --check: exit0. Final full-suite/static identity evidence and whole-family audit are pending, not claimed.

### Fidelity and deferred boundaries

The original approved boards, supplied metrics and sampled timeline are the implementation source. Standing contrast rulings apply: selected weekday uses full onAccent, meaningful checkbox/day boundaries use controlOutline, name placeholders retain the approved low-contrast exemption. No app screenshots, computer control or autonomous visual review. Aedwon's phone visual/device accessibility acceptance remains required. Actual web build/live checks require the separate Lane B/C combination; this accepted development base has no web platform directory. The report form queues locally; its deferred backend sender is unchanged. No publication, deployment, main application update, or family acceptance yet.


## October 24 audit fixes (lead rulings, fix list at 844bdade)

Policy revision: origin/main 34f28e689f73ae4406b78f023bd1506cae928fa4. AGENTS.md, WORKFLOW.md, SUBAGENTS.md, L3 W4a and the cited boards (O_Days, O_DateKnown, O_DateToday, AS_Leave, AS_Question, AS_Results) read from that revision. Base 844bdade. No push, merge or schema change. Each item is test first: the new test was run and failed for the stated reason before the change.

| Item | Commit | Failed before the change because |
|---|---|---|
| 0 Layering R2 | f63ddb89 | `check_layering` reported R2: assessment page imported a quiz screen |
| 1 Bookmark layout | a6d2553a | mark was 60 not 34 |
| 2 Next re-entry guard | b4592ebd | second tap skipped a question (3 of 3 shown instead of 2 of 3) |
| 3 Native dead end | f4f41750 | native never reached Home after Name; web logged a reminders step |
| 4 O_Days calm line | 49324e16 | calm line absent from the Days card, still on the date step |
| 5 AS_Leave copy | aae4180d | old title found, board title absent |
| 6 Custom Back | cc395f11 | two custom tracks after Back then Continue |
| 7 Today plan and Progress count | 4f9803bf | Progress count stayed 0 (Today test passes on the integrated refresh and fails when it is removed) |
| 8 Silent failures | 0dfe0d9d | spinner never ended, wrong retry, no error report |
| 10 "1 day" | c8e0a853 | "1 days from today" absent of singular |
| 11 Results ring | 1d4f59a7 | ring said 12 questions, rows covered 8 |
| 12 Question header | 885387e6 | header showed the topic only |

Item 0 resolution: the report form and its queue only depend on core, so both moved without behavior change to `lib/core/ui/components/report_form.dart` and `lib/core/storage/data/report_queue.dart` with their tests. Quiz imports updated (W4d-owned files `quiz_page.dart` and `quiz_review_page.dart`, import lines only). No baseline or exception changed.

Item 3: the reminders step is now only the "finish onboarding" state on every platform (loading, or the save-failure line with retry), and it logs no step event. Name completes onboarding on web and native.

Item 4 condition: shown in the Days card for a day-precision exam date 1 to 6 days away once a valid day is chosen, with the real count ("1 day" at one). Month-only dates, an exam today and no date keep the usual Days line. The 1-to-6 bound is D-34 ("Under a week away") and L3 Task 4; the board draws only the 3-day case.

Item 6: the page remembers the created track. Re-entering Subjects renames and re-scopes it (topics outside every subject stay excluded as `create` left them).

Item 8: reports go through `telemetryProvider.recordError`, the helper bootstrap uses. Covered: date restore and save, Days load and save, Name restore and save.

### Checks run (after the last fix commit 885387e6)

- `flutter test test/features/onboarding test/features/assessment test/core/ui test/app`: `01:08 +1039: All tests passed!`
- `flutter analyze lib test tool`: `No issues found! (ran in 4.0s)`
- `dart format --output=none --set-exit-if-changed lib test tool`: exit 0, `Formatted 1549 files (0 changed)`
- `dart run tool/check_layering.dart`: `check_layering: OK`
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`

The full suite, integration and visual acceptance remain with the lead and Aedwon.

### Known limits, recorded and not changed

- "Today" is the device-local date. No plan line requires Philippine time and students are in the Philippines.
- Hardware-keyboard capitalization in the Name field.
- The "A or B or C" join in the Days warning.

### Open items for Aedwon

- AS_Results "No assessment found.": the page shows this plain line when no result exists. No board draws that state, and no copy or control was added.
- AS_Results "in 0 minutes": an assessment under one minute prints "in 0 minutes". The board draws only "in 24 minutes". No board wording for under a minute.
- O_DateKnown card for an exam today: the card prints "0 days from today". No board draws the card for today. O_DateToday draws "today" only in the calendar note.
- Calendar note in the date step: O_DateKnown and O_DateToday draw "Wednesday, 11 November · 42 days from today" (and "· today"). The shared picker prints "Wednesday, November 11" with no count.
- AS_Leave layout: the board stacks a full-width teal "Keep Going" above a red "Leave" text. The dialog draws two inline pills (red Leave, gray Keep Going). Only the copy was changed.
- Calm line for an exam today: no board wording; none shown.

### Other findings

- Quiz page (W4d, not changed): the live question header passes the topic name only; AS_Question draws "SUBJECT · TOPIC".
- Silent `catch (_)` remains in consent, age gate, exam picker, onboarding page `_finish`, custom Subjects, assessment `_complete` and results acknowledge. Not in the fix list.
- Backing out of Subjects to the picker and choosing a built-in exam leaves the created custom track in the exam list.


## Round 2 fixes (lead review of items 0 to 12 accepted)

Same policy revision (origin/main 34f28e68). Each item is test first; the new test failed for the stated reason before the change.

| Item | Commit | Failed before the change because |
|---|---|---|
| A AS_Leave layout | 9c06499b | Keep Going was an inline pill, not a full-width primary button above red text |
| B Chosen-day note | da78eded | note read "Wednesday, November 11"; card said "0 days from today" |
| C Silent catches | 039d7892 | `recordError` received nothing from seven failing saves |
| D Abandoned custom track | 05c6aa22 | a custom track remained after Back to the picker |

A: the shared dialog only draws a pair of pills, so the assessment feature draws its own dialog (`_LeaveDialog`) from `PantasButton` and theme colors, matching the board: surface radius 20, title 20/700, body 15 at 1.45, full-width 52 high Keep Going, then a 44 high red 17/600 Leave text. No other dialog changed. Escape means Keep Going.

B: `MonthFirstDatePicker` gained an optional `dayNote` parameter. Without it the note is unchanged for every other caller, and a test pins that. The onboarding step supplies "Wednesday, 11 November · 42 days from today", "· 1 day from today" and "· today". Month-only dates still show "No day yet?" with no count. The known-date card prints "today" instead of "0 days from today".

C: reported through `telemetryProvider.recordError` with the user-visible behavior unchanged: consent, age gate, exam picker, custom Subjects, onboarding `_finish`, assessment `_complete`, results acknowledge. The acknowledge error is reported in the page callback and rethrown so the body still shows its retry line.

D: Back to the picker deletes the track this flow created unless it has an attempt or a completed assessment (then it is kept and reused). The exam list, active exam and scope providers are refreshed. The selected-exam preference is not cleared (no existing method); the picker's existing "needs selection" path covers a deleted exam.

### Checks run (after 05c6aa22)

- `flutter test test/features/onboarding test/features/assessment test/core/ui test/app`: `01:07 +1053: All tests passed!`
- `flutter analyze lib test tool`: `No issues found! (ran in 3.9s)`
- `dart format --output=none --set-exit-if-changed lib test tool`: `Formatted 1550 files (0 changed)`
- `dart run tool/check_layering.dart`: `check_layering: OK`
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`

Round 1 open items now resolved: the picker note and today wording (B), AS_Leave layout (A), silent catches (C), lingering custom track (D). Still open for Aedwon: AS_Results "No assessment found." and "in 0 minutes", and the calm line for an exam today.


## Round 3: AS_Results elapsed time under one minute

Aedwon approved ("2 is approved") that elapsed time under one minute reads "in under a minute" instead of "in 0 minutes". One minute stays "in 1 minute", more stays "in N minutes". The new test failed first (no "in under a minute" text). Checks: `flutter test test/features/assessment` `00:02 +56: All tests passed!`; `flutter analyze lib test tool` `No issues found!`; format `Formatted 1550 files (0 changed)`; `check_layering: OK`. Still open: "No assessment found." (Aedwon is choosing its design) and the calm line for an exam today.
