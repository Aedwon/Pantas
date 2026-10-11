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
