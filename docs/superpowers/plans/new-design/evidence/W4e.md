# W4e mock exam evidence

## Assignment and source identity

- Worker scope: L3 W4e Tasks 1 and 2 only, one commit each. No push or merge.
- Policy: `origin/main` `900e9f3730a93442fbf4004c148e815bfd45170a`, fetched October 12, 2026. Read AGENTS, WORKFLOW and SUBAGENTS from this revision.
- Plans: L2 and L3 W4e, W4e traceability rows, L3 parallel map standing W4 rulings and L3 W2 lead rulings, from the same main revision.
- Spec: approved October 5 new-design amendment; stage 0 decisions and engineering restart log, from the same main revision. October 5 authorization covers this work. Other paused engineering and the main application-code freeze remain unchanged.
- Source base: `ffc8045bc7eb2d427c82931f7bc1c43263e5223f`, branch `web/new-design-w4e-r1`, assigned worktree. Initial status clean. Origin is Aedwon/Pantas. Remote main is a policy source, not this workstream's application source.
- Boards and tools: read from the main checkout, no edits there. QZ_Tab, QZ_Free, QZ_Resume and QZ_First outlines and timelines read before implementation. Board HTML read only for omitted flex/baseline details.
- Shared state helpers: read `drafts/state-patterns.md` from this worktree before implementation. No local loading, load-failure, save-failure or no-exam helpers added.
- Runner availability: relay runner `aedwon-m4-chatgpt-relay` online and idle before checks. The other two relay runners were offline. Flutter checks run sequentially through relay requests. No browser dispatcher, screenshots or device operation.

## Task 1: mock card contract

Status: implemented and task checks passed. Lead review, integration and Aedwon visual acceptance pending.

Contract for W4d: `presentation/widgets/mock_card.dart` exposes `MockCardModel`, `MockCardState` and `MockCard`. W4d supplies measured paper/history values, Pro for the active exam, paused entitlement state and callbacks. States: never taken, ready, Free waiting, mock in progress, quiz paused, custom unset, custom ready and unavailable. Missing callbacks omit their controls entirely. The older MockPanel and callers remain until W4d replaces its caller and W4e Task 9 removes the adapter.

Board metrics: group radius 14; header inset 16 and bottom gap 7; content inset 16 and gaps 12; name 20/700, height 1.35, tracking -0.24; duration 15/400, height 1.35, tabular; figures 28/700, height 1.12, tracking -0.56; suffix 15/600, gap 1; figure labels 13/400, gap 2; figures inset top 6 and bottom 2, equal columns; rule 13/400, height 1.4; body 15/400, height 1.4; action 48 high, radius 14, 17/600. At large text the header and figures stack so their values stay visible.

Motion: all four card boards hold at opacity 0 and translateY 12 through 190 ms, then rise through 640 ms using cubic-bezier(.3,.9,.3,1). The card plays once, never the board's demo reset. Tests sample 190, 415 and 640 ms, including the intermediate translation. Reduced motion shows the final frame. Invisible entrance controls cannot receive focus.

W2 components: GroupedSection, PantasButton, ProPausedLine. W1 type, colors, dates and curve. No shared component extension or color literals. Free reopening comes from W3 `Entitlement.mockLimit`, replacing the provider's local 14-day calculation.

### Contrast changes

None. Light uses the board's label/secondaryLabel on surface and accent on accentTint. Dark uses W2's existing secondary-action foreground on accentTint. Tests check actual rendered backgrounds with Flutter's contrast guideline.

### Waiting on a contract

None for Tasks 1 and 2. W4d must place the card. Later task controls stay out of this run.

### Verification

- RED: relay #9463, `flutter test test/features/mock_exam/presentation/mock_card_test.dart`, exit 1. New card contract was absent: `Error when reading ...mock_card.dart: No such file or directory`, `0 tests passed, 1 failed`.
- Initial run: relay #9464, 18 passed and 3 failed. Test fixture used Friday for October 10, 2026, which is Saturday; corrected the fixture expectation. The semantics handle was disposed too late; disposed before the test finishes. No product ruling required.
- Relay #9465 found missing ignored generator outputs: 121 tests passed, 46 files could not compile. No product test failed after compilation. Regenerated with `dart run build_runner build --delete-conflicting-outputs`, relay #9466, exit 0: `Built with build_runner/aot in 24s; wrote 2810 outputs.` No generated files staged.
- Relay #9466: 371 tests passed; scoped analysis found 44 formatting/directive infos in this task's new files. Corrected those, with no other source changes.
- Final task checks, relay #9467. `flutter test --no-pub --reporter expanded test/features/mock_exam test/app`: `00:16 +371: All tests passed!`, exit 0.
- `flutter analyze --no-pub lib/features/mock_exam test/features/mock_exam`: `No issues found! (ran in 2.4s)`, exit 0.
- `dart format lib/features/mock_exam test/features/mock_exam`: `Formatted 104 files (2 changed) in 0.07 seconds.`, exit 0. Only the two new files changed.
- `dart run tool/check_layering.dart`: `check_layering: OK`, exit 0.
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`, exit 0.
- Exact output retained under ignored `build/w4e/t1-clean-*.log`; the relay issues preserve bounded output. Candidate files reviewed against the Task 1 contract before local commit. The barrel export makes the contract discoverable; existing MockPanel stays until Task 9.

## Task 2: data and scoring

Not started. Tasks 3 through 9 are outside this dispatch.

## Open questions and acceptance limits

No product or design questions identified. No app screenshots, emulator or phone checks performed. Aedwon owns visual acceptance. The lead owns independent review and integration.
