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

## Tasks 4–6 continuation: shared presentation slice, October 16

Status: shared extensions implemented and focused checks passed, saved separately before callers.
Tasks 4–6 remain in progress. Task 3 remains separately authored; no Task 3 acceptance is claimed.

Policy: current-main `ae5c09421084c01d854e78150ea2e481afe7e0b2`, with AGENTS, WORKFLOW,
SUBAGENTS, current L2/L3 W4e, parallel map, amendment, traceability and relevant design decisions
read. Initial reconciliation was local `5e6cda45` versus remote `c999952b`, ahead 14, behind 0.
The fifteen Task 3 drafts were snapshotted by path/SHA-256 under
`/tmp/pantas-w4e-task3-baseline.json` before any source change. The separate Task 3 author then
saved/uploaded `ac712f6fd18042cf37f4a3f17a68386e026af207`. Fresh fetch confirmed local and
remote both at that revision. It is this slice's base; no reset, merge or rebase occurred.
The Task 3 saved-base ruling supersedes dirty-hunk staging restrictions.

The current-main lead ruling authorizes exactly two additive W2 changes:

- `new_design/QuestionGridSheet` accepts an optional `footer`, default null, after its ordinary
  content with 16 points of space. Existing quiz/default content is preserved.
- `CenteredDialog` accepts opt-in `inlineActions`, default false. It uses the existing inline
  pill geometry with accentFill/onAccent for Submit and fill/label for cancel. Destructive and
  ordinary stacked defaults are preserved. ButtonPair retains its large-text stacking behavior.

Verification, directly on the Mac with Flutter 3.44.6 / Dart 3.12.2:

- Baseline before implementation: `flutter test --no-pub --reporter expanded test/features/mock_exam test/app`,
  exit 0, `00:18 +386: All tests passed!`; `build/w4e/tasks4-6/baseline-mock-app.log`.
- Shared RED: missing `inlineActions` and `footer` named parameters, exit 1;
  `build/w4e/tasks4-6/shared-red.log`. The earlier Task 4 RED contract also remains uncommitted.
- First shared suite exposed only four new keyboard test fixture failures: the directly mounted
  dialog had no focused descendant. Tab focus before Escape corrected the fixture. No unrelated
  test failed and no production keyboard behavior changed.
- Focused GREEN: `00:00 +8: All tests passed!`, exit 0;
  `build/w4e/tasks4-6/shared-focused-green.log`.
- Shared suite: `flutter test --no-pub --reporter expanded test/core/ui/components`, exit 0,
  `00:25 +506: All tests passed!`; `build/w4e/tasks4-6/shared-suite-final.log`.
- Scoped analyzer: `No issues found! (ran in 0.5s)`, exit 0;
  `build/w4e/tasks4-6/shared-analyze-final.log`.
- Format: `Formatted 3 files (0 changed) in 0.02 seconds.`, exit 0.
- Layering: `check_layering: OK`, exit 0. Attribution: `check_no_ai_attribution: OK`, exit 0.
  `git diff --check`: exit 0, no output.

Source identity: sorted path + NUL + file bytes SHA-256
`dfaabca540cdbcc6a4d3c4768784312d7b2198aa0661ec3183da74da657f35dd`.
Manifest: the two shared source files above, `test/core/ui/components/mock_shared_contract_test.dart`,
and this evidence. Only this approved slice is staged. No source in Task 3, content, other
families, shared gauge, schema, signing or sync changed. No screenshot capture, phone verification,
independent review, integration, push, deployment, release or visual acceptance occurred.

## Task 4: between-parts data contract slice, October 16

Status: bounded controller/snapshot/resume contract implemented and focused checks passed.
Task 4 route integration and presentation remain in progress. Task 5 is not completed. The
lead's student-data review is required before integration. No combined-family acceptance.

Base: `40600f16420c4f0b80bfc2e17054da670986a915`. Additional controlling ruling read from
current-main `49b95eb2`: optional betweenParts/endedEarly in existing feature _session JSON,
with frozen next-part position, stopped clock, explicit Start and validated recovery.

- Controller now enters MockSessionBetweenParts at an elapsed or early part ending. It freezes
  the actual next-part index/first question and full next-part clock. Only startNextPart leaves
  the gate, once; ticks while waiting do nothing. Last-part endings submit. Strict mode cannot
  end a part early, and strict background forfeiture still works while waiting and is idempotent.
- Snapshot/flush models carry optional boolean transition state, default false for legacy
  snapshots. Decoder rejects non-booleans, endedEarly without a gate, missing/inconsistent frozen
  parts and impossible next-part indices. Controller restoration also checks next-part position
  and an unstarted clock.
- Resume preserves elapsed while waiting and adds intervening wall time to accumulated paused
  time. Repeated resumes cannot consume the next part. It preserves strict background metadata
  and all saved answers. An inconsistent saved clock/position fails before a progress write;
  it does not repair or remap the answers. No SQL, database schema or sync mapper changed.

Verification:

- RED `t4-transition-red.log`: new transition state/API/metadata absent, exit 1.
- RED `t4-data-guard-red.log`: waiting tick and strict-background operations incorrectly require
  running state; both fail with `Bad state: Mock session is not in progress`, exit 1.
- GREEN `flutter test --no-pub --reporter expanded` with six files (between_parts_recovery,
  mock_session_snapshot, mock_lifecycle_use_cases, mock_session_parts, mock_session_controller,
  mock_persistence_scheduler): exit 0, `00:00 +42: All tests passed!`;
  `build/w4e/tasks4-6/t4-data-final-tests.log`.
- Scoped analyzer on the seven manifest Dart paths: exit 0,
  `No issues found! (ran in 1.1s)`; `build/w4e/tasks4-6/t4-data-analyze-final.log`.
- Format: exit 0, `Formatted 7 files (0 changed) in 0.02 seconds.`
- Layering: exit 0, `check_layering: OK`. Attribution: exit 0, `check_no_ai_attribution: OK`.
  `git diff --check`: exit 0, no output.
- A wider domain/application run during the paper changes had 112 passes and two expected,
  owned old 20-minute-proctor expectations failing. Those belong to the still-uncommitted
  paper slice; this does not claim that wider run passed.

Manifest: `application/mock_session_controller.dart`, `application/mock_persistence_scheduler.dart`,
`domain/mock_session_state.dart`, `domain/mock_session_snapshot.dart`, `domain/use_cases/resume_mock.dart`
under `lib/features/mock_exam/`; `test/features/mock_exam/domain/between_parts_recovery_test.dart`;
`test/features/mock_exam/application/mock_session_parts_test.dart`; this evidence.
Sorted path + NUL + bytes SHA-256 for those seven source/test paths:
`4a9b4dbd6859ea507232720e7c379aea55495aa41e4dca5f525b05a85746ca56`.

Still pending before Task 4 completion: route transition display/restoration, ordered transition
and explicit-Start flushes, failure/retry tests, strict-background versus expiry integration
assertions, paper/grid presentation and final task checks. These are not covered by the bounded
data-contract pass. Paper files remain separate dirty work. No other Task 3 file changed.

## Task 4 paper presentation checkpoint, October 16

Status: bounded paper presentation slice verified locally and saved. Tasks 4, 5 and 6 are NOT
complete. The lead requested a capacity checkpoint before further runtime/finale work.
No combined mock-family check, independent acceptance, visual acceptance or upload is claimed.

Base: local `4509861f`. The lead identified an Important unresolved integration finding in that
data commit: MockStartRoute still has no MockSessionBetweenParts case in build or snapshot/flush
handling. At a part boundary it can show the loading state and combine the advanced part index
with an older snapshot. Therefore this commit and its unuploaded data ancestor are held from
working-branch upload/integration until coherent runtime consumers and their tests land.
The paper presentation below does not resolve that finding.

Implemented in the bounded presentation:

- Clock includes hours, with a centered 120x5 time bar. It uses teal normally, amber under five
  minutes and red in the last minute. Strict mode removes pause. Shared FloatingBar replaces
  the old floating-bar widget at this call site, preserving a centered counter and controls.
- Paper uses shared new-design question/choice/passage components and existing figure renderer.
  Selection remains editable and never exposes answer correctness. The part-name/one-block
  interface is ready, but the running route has not been updated to supply its new arguments.
- Last-question dialog uses real blank counts/time and approved End Part copy. The added
  one-block submit interface uses the approved inline accent dialog; route wiring is pending.
- Proctor calls now occur at 10, 5 and 1 minutes. Surface is the drawn rounded warning pill.
  Existing eight-second status exposure and haptics remain. Existing pause-warning and back/
  leave behavior remain for the separate Task 5 work.

Contrast changes under the October 12 standing ruling: board red #D70015 against dark #000000
failed the required text ratio at 3.900243:1. Timer/proctor red uses existing wrongText, light
#D70015 and dark #FF6961; the background stays unchanged. Clock-bar red uses the same readable
red. Light/dark last-minute tests require at least 4.5:1. No shared token changed.

Actual verification:

- Initial RED `build/w4e/tasks4-6/t4-red.log`: seven missing proctor/hour/bar/color contracts,
  exit 1. First GREEN attempt exposed the dark red contrast failure above, then corrected under
  the standing ruling.
- Final paper-focused command: `flutter test --no-pub --reporter expanded` on
  task4_paper_contract, pages/mock_session_page, mock_session_page, clock_rule, proctor_toast,
  end_part_early and domain/part_clock test files. Exit 0, `00:01 +40: All tests passed!`;
  `build/w4e/tasks4-6/t4-paper-focused-final.log`.
- Final scoped analyzer: exit 0, `No issues found! (ran in 1.0s)`;
  `build/w4e/tasks4-6/t4-paper-analyze-final.log`. Earlier eight owned style infos were fixed.
- Final owned format: exit 0, `Formatted 10 files (0 changed) in 0.01 seconds.`
- Layering: exit 0, `check_layering: OK`. Attribution: exit 0, `check_no_ai_attribution: OK`.
  Whitespace check: exit 0, no output. No further full-suite run at this checkpoint.

Paper manifest, all under the assigned W4e scope:

- `lib/features/mock_exam/domain/part_clock.dart`
- `lib/features/mock_exam/presentation/clock_rule.dart`
- `lib/features/mock_exam/presentation/pages/mock_session_page.dart`
- `lib/features/mock_exam/presentation/proctor_toast.dart`
- `test/features/mock_exam/domain/part_clock_test.dart`
- `test/features/mock_exam/presentation/clock_rule_test.dart`
- `test/features/mock_exam/presentation/end_part_early_test.dart`
- `test/features/mock_exam/presentation/pages/mock_session_page_test.dart`
- `test/features/mock_exam/presentation/proctor_toast_test.dart`
- `test/features/mock_exam/presentation/task4_paper_contract_test.dart`
- This evidence.

Sorted path + NUL + bytes identity for the ten Dart paths:
`648e7ecf4f9bebd31ece1daf925ac0223c5e09f092a1d18e6a17076bbefd2844`.
Content inputs remain content.db `0ef89a64f2d2f63854b3d22048a7d992d5c04fb03df4fec2e7f4e898e6d083dc`
and content.manifest.json `51bc0a766558879e540475ab972f03df7e3077241bab8f688c1b50ece5874f23`.
Task 3 setup, preparation, blueprints, routes and runtime source remain byte-for-byte identical
to the separate `ac712f6f` commit; this checkpoint has not changed its owned tests.

Remaining authorized work, exactly:

1. Task 4 runtime: handle between-parts state coherently in route build/snapshot/flush, preserve
   explicit preparation/start, stop/reset clock, persist the gate and explicit Start in order,
   keep failure/retry authoritative and start once. Test elapsed/early endings, restart, queued
   write ordering/failure, ordinary paper after the first part, strict-background/expiry order.
2. Task 4 presentation: match/rebuild PartTransitionPage to MK_BetweenA/MK_PartEnded including
   actual answered/blank dots, part list/arrow and exact timeline. Wire shared QuestionGridSheet
   with real section-local numbering, one-block submit footer/dialog, and declared exit. Implement
   the MK_Paper outgoing/incoming 260ms/80ms-delayed-280ms overlap and delayed counter change;
   current paper switching has not implemented that approved motion. Finish all task mock/app checks.
3. Task 5: exact pause warning with remembered opt-out, hourglass fall/shrink/reverse flow,
   discard deletes answers without consuming allowance, 10-second strict grace, strict back block,
   non-strict app/back pause, recovery/errors/discard and expiry precedence. No Task 5 code started.
4. Task 6: ordered full finale, UPCAT two-ball/deduction, results/breakdown/past-record motion,
   Free window/lapse/paused-Pro rules and Done origin. No Task 6 code started. Existing percentage
   gauge has a concrete geometry/timing gap; D owns its separately saved count variant. Before
   any shared gauge edit, return exact required percentage/finale-driven interface from real
   board timelines to the lead. Do not scale/approximate or edit it concurrently.
5. Final affected/full required checks, independent lead review and Aedwon visual acceptance.
   No screenshots, phone/emulator checks, publication, merge, push, cleanup or main code update.

Board outlines/timelines for all 24 assigned Task 4–6 boards were generated directly from the
main checkout into ignored `build/w4e/tasks4-6/`. They support continuation; no captured app
screenshots or autonomous visual review occurred. This checkpoint is a capacity hold, not a
product/behavior ruling and not task completion.

## Task 4 coherent runtime and transition checkpoint, October 16

Status: bounded runtime/transition implementation verified and saved for independent lead review.
This supplies the missing runtime consumer for `4509861f` and resolves the previously recorded
BetweenParts loading/stale-snapshot integration finding. It does not complete Task 4. The lead
requested a checkpoint before new phone-bar/grid/question-motion work. Tasks 5 and 6 remain open.

Fresh reconciliation: policy/main `03242b61863427ab3390b7717d5917ed9003ca3b`, local
`b6ba49d3a47f270d7b89d379fa362b22fb0fe318`, remote `40600f16420c4f0b80bfc2e17054da670986a915`,
ahead 2/behind 0, clean. Current policy files were retrieved; their blobs match the already-read
policy. Current L3 clarification, decision log and prior checkpoint evidence were reread.

Runtime now restores and displays the saved transition, stops the next-part stopwatch, includes
the actual waiting snapshot in every progress write and persists an elapsed/early ending
immediately. Explicit Start persists its new authoritative state before accepting new answers;
only its own successful write acknowledgement starts the next clock. Retry remains at the gate
when that write fails. A queued lifecycle checkpoint waits for the Start outcome before taking
its snapshot, so it cannot restore a stale gate behind acknowledged Start. Flush failures belong
to each write future instead of a shared error slot that a later success can clear.

Between-parts checkpoints accrue all intervening wall time before saving. Fractional seconds
remain in the local pause timestamp instead of being lost on repeated checkpoints. Real saved
answers, flags, current position, strict background timestamp and strict-versus-expiry precedence
are retained. The ordinary running paper is usable after explicit Start. No schema or sync change.

PartTransitionPage now shows actual answered/blank positions without flags, the real part list,
Time is up versus Part N ended, and the approved Start action/clock line. Dots enter at 200ms,
12ms apart for 200ms; the closing-node pop runs 1400–1780ms; the arrow moves 1600–2050ms with
the specified curves and overlaps. Reduced motion shows the last frame. Tests cover both themes,
320x640 at 200% text, the final arrow position and those timing boundaries. Ahem's larger test
text exposed a legend overflow; flexible text fixes it without changing the ordinary layout.
A floating-point boundary in the arrow interval was also fixed at the exact timeline endpoints.
Visual acceptance remains Aedwon's.

Actual verification and limits:

- Runtime RED: `t4-runtime-red-valid.log`, exit 1, five missing transition/Start cases; the strict
  saved-forfeit regression already passed. The earlier import-error run is not valid RED evidence.
- UI RED: `t4-transition-ui-red.log`, absent transition presentation contract, exit 1.
- Interleaving RED: `t4-runtime-interleaving-red.log`, exit 1, missing waiting-time accrual and
  lifecycle/Start handling. The lifecycle fixture was corrected to inspect the saved gate before
  resuming to inspect UI, because a background app does not render the new paper.
- Confirmed regression RED: `t4-lifecycle-gate-regression-red-valid.log`, exit 1, expected saved
  betweenParts false but actual true with only the serialized lifecycle checkpoint guard removed.
  The exact guard was restored in a finally block. The preceding compile-error attempt is not RED evidence.
- Final runtime-focused run: `t4-runtime-interleaving-green-2.log`, exit 0, 11 tests passed before
  the additional disposal characterization. Transition UI final: `t4-transition-ui-final.log`,
  exit 0, `00:00 +5: All tests passed!`.
- Disposal characterization passed without a production guard change; it is a passing boundary
  check, not a reproduced defect or a claim that a disposal defect was fixed. Actual output copied
  to `t4-dispose-start-characterization-green.log`. The lead explicitly directed no defensive
  guard without reproduction.
- First combined task run: 413 passes, one affected old UPCAT end-to-end test still navigated
  immediately after part timeout. It now asserts the stopped state and explicitly starts the
  next part before checking that closed questions remain inaccessible. No unrelated test failed.
- Final `flutter test --no-pub --reporter expanded test/features/mock_exam test/app`: exit 0,
  `00:22 +415: All tests passed!`; `build/w4e/tasks4-6/t4-runtime-checkpoint-tests.log`.
- Final scoped analyzer: six changed Dart paths, exit 0, no issues;
  `build/w4e/tasks4-6/t4-runtime-checkpoint-analyze-final.log`.
- Owned format: exit 0, `Formatted 6 files (0 changed) in 0.02 seconds.`
- Layering: exit 0, `check_layering: OK`. Attribution: exit 0, `check_no_ai_attribution: OK`.
  `git diff --check`: exit 0, no output. Full project suite and broad analysis are not claimed here.

Manifest:

- `lib/features/mock_exam/presentation/pages/mock_start_route.dart`
- `lib/features/mock_exam/presentation/part_transition_page.dart`
- `test/features/mock_exam/presentation/between_parts_route_test.dart`
- `test/features/mock_exam/presentation/mock_start_route_persistence_test.dart`
- `test/features/mock_exam/presentation/part_transition_page_test.dart`
- `test/features/mock_exam/upcat_end_to_end_test.dart`
- This evidence.

Sorted path + NUL + bytes identity for the six Dart paths:
`f7956a5bfb8c3536280a52808f7904de165e1a7686c6e7e5ad301f2d7ed9abe1`.
Task 3 preparation/explicit-start method range remains byte-identical to `ac712f6f`:
SHA-256 `542268223c453c1e858144c5e9c6e20168835c5dbdb4f49ac1e0e7dd49546486` on both
saved and current source. Only existing runtime assertions changed in its persistence test.
Other Task 3 setup/content paths remain untouched. Content inputs remain the prior checkpoint identities.

Still pending before Task 4 completion: real Geist 320/390 phone-bar geometry and reachable-content
checks, figure/passage/error-retry coverage, shared grid integration and section-local numbering,
non-strict one-block Submit wiring without bypassing strict no-early-ending, declared exit route,
and the exact overlapping paper/question/counter motion. Task 5 pause/hourglass/preferences,
discard/recovery and 10-second strict grace are not implemented by this slice. Task 6 finale/results
and the required exact percentage-gauge interface proposal are not started. No shared gauge edit,
Task 7+, push, merge, main application update, screenshot capture, phone check, publication or cleanup.
The lead owns review, working-branch upload and any acceptance decision.

### Task 5 recovery check added by the lead at this checkpoint

The existing strict recovery comparison uses the overall attempt deadline. Earlier parts ended
before their time can leave an overall budget later than the actual last-part deadline. Task 5
must compare the actual current-part deadline against the 10-second background grace, including
a last part that expires first after earlier early endings. A stopped between-parts gate is a
separate case and cannot consume the next part's time. The current Task 4 tests cover overall
expiry versus forfeit and a strict saved gate; they do not establish complete sectional recovery
precedence. No fix or full strict-recovery acceptance is claimed. This remains an explicit next-scope
regression requirement before Task 5 completion. The lead requested no new implementation breadth
before reviewing the saved Task 4 runtime checkpoint `67c02af9`.

## October 19 PWA resumption: phone paper and content recovery slice

Status: independent Task 4 presentation slice implemented and focused checks passed. Full E3–9,
server runtime wiring, final family gates/audit and Aedwon's visual acceptance remain open.

Reconciled local/remote `e3ba378551d6876763fac5c217f8b31453e91854`, clean, before edits. Read the
Codex lead note first, then current-main policy at `5b77018a33e4e7fadac8532be12ffb41e3c017f9`,
PWA spec, plan/rulings, complete PWA log, RESUME, L2/L3 and actual source. Later adapter ruling
`252d26e2062f04827a3fb3936d1a8939be2d805c` and copy decision `33b3fd2e` were retrieved.
Read-only staging advanced from `2c2332e0` to `8e0420c9cad45c9ac2d5efe600d6b41b67675908`;
`mock.ts` and `_answers.ts` are unchanged between them. No Claude-owned branch was edited.

- Actual Geist 320x640/200% tests reproduced 29-pixel control overflows in both themes. The
  paper now measures its counter at the active text scale. When the ordinary single row cannot
  contain the counter and four 44x44 controls, it uses existing FloatingBar.content with a
  centered counter above the controls. Ordinary 100% rows remain 60 high. No shared component
  was changed and no cross-family code was copied.
- Content padding and status placement use the actual bar/text height. Eight real-font cases
  (320/390, light/dark, 100/200%) assert centered counter, distinct in-bounds 44x44 controls,
  real callback behavior, actual passage/figure rendering, and a final answer reachable above
  the floating bar. The initial scroll assertion needed a layout pump after scrolling; that
  fixture correction is separate from the valid 320-width overflow RED.
- A missing hydrated question previously had no recovery action. Both missing and failed
  content now use the shared question-error/Retry pattern, retaining the original question id.
  The tests retry to the real passage and chart and ensure diagnostics are not displayed.
  No local paper, clock, allowance, result, content cache or provider authority changed.

Verification (serialized Mac execution):

- `t4-phone-red-valid.log`: exit 1, only the two 320/200% control-overflow cases fail;
  both 390 cases already pass after the scroll fixture correction.
- `t4-question-retry-red.log`: exit 1, missing=true has no Retry; exception recovery already passes.
- Five affected presentation test files: exit 0, `00:01 +31: All tests passed!`;
  `build/w4e/tasks4-6/t4-phone-final-tests.log`.
- Scoped analyzer: exit 0, `No issues found! (ran in 1.7s)`;
  `build/w4e/tasks4-6/t4-phone-analyze-final.log`.
- Format: exit 0, `Formatted 2 files (0 changed) in 0.01 seconds.`
- Layering and attribution: exit 0, `check_layering: OK`, `check_no_ai_attribution: OK`.
  Whitespace check: exit 0, no output. Full-family gates are deferred until implementation is complete.

Manifest: `lib/features/mock_exam/presentation/pages/mock_session_page.dart`,
`test/features/mock_exam/presentation/paper_phone_accessibility_test.dart`, this evidence.
Sorted Dart path + NUL + bytes SHA-256:
`ba044968aab3ac09a8706c6a1bfaad5d4353c3b6db88915d99c2b75e2a146879`.
Task 3 setup/content remains untouched. CSE source blueprints and the separate personal-items
copy preview remain with their owners; no explanatory copy was added here.

Pending server dependency: published start/get/control/submit operations cover pinned CSE papers
and overall clocks, but completed results/history, server review visibility and next eligibility
still lack the reader required by the approved card/results/review. The lead recorded the narrow
feature-only adapter proposal in L3 and W4-client-coordination.md before dependent edits. Display
cursor/flags may be account+mock scoped; they do not become paper/clock/eligibility authority.
Accepted client-correctness trust is documented in the PWA log, not treated as a new blocker.
No push, merge, deployment, screenshots, phone operation, new reviewer or family acceptance.
