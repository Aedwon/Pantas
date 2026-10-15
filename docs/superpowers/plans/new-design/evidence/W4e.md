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

Status: implemented; task tests and full suite passed. Broad analysis/format findings on an unchanged base test remain lead-owned. Independent review, integration and visual acceptance are pending. Tasks 3 through 9 are outside this dispatch.

Source parent: Task 1 commit `18c177111ee28bbcd76f5e1efdcc408d35592093`. No schema or package change.

- Compute and submit fill wrong and blank counts per section. Missing answers and note-only answers with selectedIndex -1 are blank. Missing and withdrawn questions leave the total. The submit path hydrates only active questions from the existing content database.
- Scores use the stored section counts. UPCAT earns correct minus wrong/4; other exams earn correct. Both divide by the surviving total and multiply by 100. No percentage or rounded decimal is stored in the database. Empty totals return zero. The raw database field remains the integer correct count. The final results presentation is rebuilt in Task 6, outside this run.
- One section-result decoder remains in `mock_results_route.dart`, named `decodeMockResults`. It reads new counts directly. For old null or missing counts, it counts saved selections by section and excludes inactive/missing ids supplied by the loader. It recovers wrong as answered minus stored correct and blank as stored total minus answered. Inconsistent saved data fails instead of guessing. The route and history provider use this same decoder.
- The result loader uses the shared loading/error helpers and active-exam Pro coverage. Retry reloads the provider. It does not print diagnostic errors.
- Review storage: snapshot JSON preserves missReason, blankReason and reasonNote. `MockAttemptRepo.saveReviewReason` atomically updates only those keys and the sync timestamp through the existing mutation recorder. It preserves selections, answer timing, flags and score. A blank note uses selectedIndex -1 and atSec 0; it cannot become a correct or wrong answer. It rejects a nonterminal attempt, a question outside that paper and a reason of the wrong kind. Task 7 wires the approved note controls to this writer.
- W4b contract: `application/mock_results_providers.dart` exposes `mockHistoryProvider`, a `StreamProvider<List<MockHistoryEntry>>`. It contains every submitted completed/forfeited mock for the device-local profile across exams, newest first, without a ten-row cap. Each entry has `attempt` and normalized `results`, including percent and section counts. It updates when the underlying history changes. Missing or malformed results fail the section instead of silently removing a record. Consumers use W4h's state helpers for errors/loading. This application file imports the family's existing route decoder to retain the plan's explicit single-decoder location; no other family imports this presentation file.
- Recency: the sampler receives ids from the two latest submitted completed/forfeited mocks of the same exam and profile. In-progress, discarded, other-exam and other-profile rows are excluded. The sampler's existing short-bank fallback is unchanged.
- The metrics payload reader is unchanged. Its regression test supplies the new result and review keys and verifies its existing inputs remain the same.

### Verification

- RED relay #9469: new scoring test fails because examId scoring, the decoder and the review writer do not exist. Log `build/w4e/t2-red.log`, exit 1.
- Recency RED: relay #9472, only the missing `recentQuestionIds` contract fails compilation; `build/w4e/t2-history-red-valid.log`, exit 1. An earlier run exposed two typing mistakes, corrected before this valid RED.
- Withdrawn-row RED: relay #9474, missing scoring-question provider; `build/w4e/t2-retirement-red.log`, exit 1.
- Live history RED: relay #9476, only the missing `watchHistory` contract fails compilation; `build/w4e/t2-history-feed-red-valid.log`, exit 1. The earlier run exposed a missing Question import, corrected before this valid RED.
- Focused scoring/history GREEN: relay #9473, `00:00 +10: All tests passed!`, exit 0. Scoped analysis then identified formatting findings, corrected in owned files.
- Task checks: relay #9477, `flutter test --no-pub --reporter expanded test/features/mock_exam test/app`: `00:26 +383: All tests passed!`, exit 0. Log `build/w4e/t2-task-3.log`.
- Metrics: relay #9477, `flutter test --no-pub --reporter expanded test/features/metrics`: `00:04 +99: All tests passed!`, exit 0. Log `build/w4e/t2-task-4.log`.
- Final scoped analysis, relay #9478: `No issues found! (ran in 2.6s)`, exit 0. Log `build/w4e/final-3.log`.
- Full suite, run once at the end, relay #9478: `flutter test --no-pub --reporter expanded`, exit 0, `05:55 +3902: All tests passed!`. Log `build/w4e/final-4.log`.
- Broad analysis, relay #9478: `flutter analyze --no-pub lib test tool`, exit 1, `12 issues found. (ran in 11.9s)`. One is the already accepted onReorder deprecation at `lib/features/lesson/presentation/widgets/bookmarks_sheet.dart:238:21`. The other 11 are in the unchanged base file `test/tool/firebase_indexes_layout_test.dart`: unnecessary raw strings at 104, 105, 107, 110, 111, 119 and 126; adjacent strings in list literals at 106, 108 and 111; missing trailing comma at 144. Log `build/w4e/final-5.log`. No new finding is in the W4e files.
- Broad format, relay #9478: `dart format --output=none --set-exit-if-changed lib test tool`, exit 1: `Changed test/tool/firebase_indexes_layout_test.dart`, `Formatted 1440 files (1 changed) in 2.42 seconds.` The output=none check did not change the file. Log `build/w4e/final-6.log`.
- Provenance of that base finding: last modifying commit `2d438daf` (W3 Task 14c), already in the assigned `ffc8045b` base. `git diff HEAD -- test/tool/firebase_indexes_layout_test.dart` is empty. This worker did not edit the unrelated test. The lead must resolve these findings before claiming clean combined verification. No full-suite repeat was run.
- Owned-file format, relay #9479: `dart format --output=none --set-exit-if-changed` on the 12 changed Dart files, exit 0: `Formatted 12 files (0 changed) in 0.04 seconds.` Log `build/w4e/final-owned-0.log`. Full argument list is preserved in that relay result and the file manifest below.
- `dart run tool/check_layering.dart`, relay #9479, exit 0: `check_layering: OK`. Log `build/w4e/final-owned-1.log`.
- `dart run tool/check_no_ai_attribution.dart`, relay #9479, exit 0: `check_no_ai_attribution: OK`. Log `build/w4e/final-owned-2.log`. It runs again after the local commit to include the message.
- Both tasks' source changes were read against the plan before the handoff. This author check does not replace the lead's independent audit/review. The local Task 2 commit saves the completed assigned scope with the broad base findings explicitly reported; it does not assert combined-family acceptance.

## Task 3: Mock Setup closeout

Status: implementation and Task 3 checks passed. Task 4 remains separately owned and was not started, edited, staged, or committed by this worker. Aedwon visual acceptance, independent audit, integration, deployment, and the W5 signed release-package rebuild remain outside this closeout.

Recovery source identity: local branch `web/new-design-w4e-r1` at `5e6cda4541a80609b27f2784fc2e58d39731a33b`, with the preserved Task 3 dirty draft exactly as recovered. Current policy and plans were reread from `main` at `ae5c09421084c01d854e78150ea2e481afe7e0b2`; current relay instructions were reread from relay `main` at `61ae420f11b6891485069dcc3de6352e11578adf`. Remote W4e branch was `c999952bb037b5cb31a745907d5e2f26232671fc` before this closeout.

Owned behavior and content:

- MK_Setup, MK_SetupStrict, MK_SetupDCAT, MK_SetupCSE and L_MockStart use the approved setup table, paper rules, exclusions, short-paper disclosure, strict-mode switch, explicit start action, and preparation state. The setup switch defaults from the stored Settings preference but applies only to the attempt being started.
- The start route carries that per-attempt strict choice, prepares the blueprint/sample/parts without starting the attempt, and starts the persisted attempt clock only after the explicit `Start the Paper` action. Resume behavior remains separate.
- The feature blueprint reader preserves W0 `BlueprintValue` placeholder metadata while exposing the numeric value to existing runtime consumers. Setup renders approved placeholder figures instead of presenting unresolved figures as settled facts.
- Built-in Task 3 blueprints are `content/mock/cse_pro.yaml`, `content/mock/cse_sub.yaml`, and `content/mock/acet.yaml`. CSE per-subject item splits and ACET aptitude time retain the approved development-only placeholder marker and note.
- The signed content/release package was not rebuilt. That remains W5 scope.

### Verification

- Reused recovery evidence: relay #9922, the pre-closeout `flutter test --no-pub test/features/mock_exam test/app` candidate passed; relay #9923 scoped analyzer passed with `No issues found!`; relay #9924 broad format reported `Formatted 1462 files (0 changed)`. These runs were treated as historical recovery evidence only and were followed by fresh final-candidate checks.
- Fresh focused Task 3 checks, relay #10118: six owned test files, exit 0, `25 tests passed`. This covers blueprint marker parsing/content, setup contract and strict local state, CSE placeholder rendering, DCAT exclusions, short-paper disclosure, preparation-before-clock behavior, large text/dark state, and persisted mock route behavior.
- Fresh family check, relay #10120: all 54 `test/features/mock_exam/**/*_test.dart` files except the explicitly out-of-scope `test/features/mock_exam/presentation/task4_paper_contract_test.dart`, plus `test/app`, exit 0.
- The unfiltered family command in relay #10119 exited 1 only after discovering the separately owned Task 4 RED contract file. Its failures are Task 4 proctor/clock contract failures. This worker did not change those expectations or implementation.
- Owned analyzer, relay #10121: 12 Task 3 source/test items, exit 0, `No issues found! (ran in 2.0s)`.
- Broad analyzer, relay #10122: exit 1 with 20 info findings. One is the previously accepted bookmarks `onReorder` deprecation. The remaining findings are all in the separately owned untracked Task 4 contract test. No Task 3 owned file has an analyzer finding.
- Owned format gate, relay #10130: exit 0, `Formatted 12 files (0 changed) in 0.02 seconds.` Broad format relay #10123 exits 1 only because the out-of-scope Task 4 test would be formatted. `--output=none` did not edit it.
- Protected Task 4 file identity before checks, relay #10109, and after the broad format check, relay #10129: SHA-256 `68da6e5d41eb7661f5e59e309600280e545cb0594e9e6ab65239af3dcd63c99a` both times.
- Layering, relay #10124: exit 0, `check_layering: OK`.
- Attribution, relay #10125: exit 0, `check_no_ai_attribution: OK`.
- Diff whitespace, relay #10126: `git diff --check`, exit 0 with no output.
- Content export validation, relay #10127: exit 0, `skipped 0 figure-pending questions`. Output was written only to `/tmp`; no signed release artifact was produced.

### Task 3 file manifest

- `content/mock/acet.yaml`
- `content/mock/cse_pro.yaml`
- `content/mock/cse_sub.yaml`
- `lib/app/routes/mock_routes.dart`
- `lib/features/mock_exam/data/blueprint_section.dart`
- `lib/features/mock_exam/presentation/pages/mock_setup_page.dart`
- `lib/features/mock_exam/presentation/pages/mock_setup_route.dart`
- `lib/features/mock_exam/presentation/pages/mock_start_preparation_page.dart`
- `lib/features/mock_exam/presentation/pages/mock_start_route.dart`
- `test/features/mock_exam/data/blueprint_section_test.dart`
- `test/features/mock_exam/data/task3_mock_blueprints_test.dart`
- `test/features/mock_exam/presentation/mock_setup_page_test.dart`
- `test/features/mock_exam/presentation/mock_start_route_persistence_test.dart`
- `test/features/mock_exam/presentation/pages/mock_setup_page_test.dart`
- `test/features/mock_exam/presentation/pages/mock_start_preparation_page_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4e.md`

Remaining unverified items are deliberately outside Task 3: Task 4 RED contracts, Aedwon visual acceptance, independent audit, integration, deployment, and W5 signed release-package verification.

## File manifest for the lead

Task 1, commit `18c17711`:

- `lib/features/mock_exam/presentation/widgets/mock_card.dart`
- `lib/features/mock_exam/application/mock_availability_provider.dart`
- `lib/features/mock_exam/mock_exam.dart`
- `test/features/mock_exam/presentation/mock_card_test.dart`
- `test/features/mock_exam/application/mock_availability_provider_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4e.md`

Task 2:

- `lib/features/mock_exam/application/mock_results_providers.dart`
- `lib/features/mock_exam/data/mock_attempt_repo.dart`
- `lib/features/mock_exam/domain/mock_results.dart`
- `lib/features/mock_exam/domain/mock_session_snapshot.dart`
- `lib/features/mock_exam/domain/use_cases/compute_results.dart`
- `lib/features/mock_exam/domain/use_cases/submit_mock.dart`
- `lib/features/mock_exam/mock_exam.dart`
- `lib/features/mock_exam/presentation/pages/mock_results_route.dart`
- `lib/features/mock_exam/presentation/pages/mock_start_route.dart`
- `test/features/mock_exam/application/mock_history_contract_test.dart`
- `test/features/mock_exam/domain/data_scoring_contract_test.dart`
- `test/features/metrics/signals/mock_payload_reader_test.dart`
- `docs/superpowers/plans/new-design/evidence/W4e.md`

The metrics test is required by Task 2. No metrics implementation, core component/token, other family's screen, functions, content, or generated file changed. All files fit the L2 directory scope or the explicit Task 2 metrics check/evidence instruction.

## Open questions and acceptance limits

No product or design questions identified. No app screenshots, emulator or phone checks performed. Aedwon owns visual acceptance. The lead owns independent review and integration.

Lead follow-up: resolve the 11 analysis findings and formatting failure in the unchanged W3 indexes test described above. No board or visual values are involved. The accepted onReorder notice belongs to the reader family. This is not a claim that broad analysis or broad format passed.

Final source/test identity, after formatting and before the final suite: SHA-256 `321753676ad89005be2f2512119b2a47445b79b6ddb1ff417c941f81995e538e`. This hashes each of the 16 changed source/test paths in sorted order as path, NUL, file bytes. Evidence prose is excluded.

Prepared content inputs, unchanged by this run:

- `assets/seed/content.db`: SHA-256 `0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc`.
- `assets/seed/content.manifest.json`: SHA-256 `51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23`.

Current task status is recorded here at each task boundary. Updating the program's external SSOT is lead-owned and pending the handoff; this worker does not claim program acceptance. The main checkout and other worktrees remain untouched. No push, merge, release or cleanup is authorized in this dispatch.

Remote check before handoff: `git ls-remote origin refs/heads/web/new-design-w4e-r1` returned no branch. The assigned local branch stays unpushed for the lead.
