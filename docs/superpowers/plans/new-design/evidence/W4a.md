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
