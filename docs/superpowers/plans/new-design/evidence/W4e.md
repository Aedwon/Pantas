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

## October 20 Claude builder run (Sonnet 5.5)

Policy read from `origin/main` (AGENTS, WORKFLOW, SUBAGENTS) at the start of the run. Base
`f6b76e56`. Visual acceptance remains Aedwon's; no screenshots were taken.

Commits, oldest first: `b25be7bf` manifest declares the payload schema 10 (writing and
verification, tests first; E02 schema 8 seed untouched); `f0bd24c2` shared mock grid with
part-local numbering, one-block Submit the Exam from the grid (`submitNow`, manual reason),
deep-link exit to `/quiz`, broken saved mock offers Discard; `b4f54a0d` MK_Paper next-question
slide; `a0cf0e3d` "Strict mode is on." copy from MK_LastQStrict; `7a891d1e` strict grace ten
seconds and part-deadline recovery precedence; `67e1f48d` pause screen (hourglass, entry and
Resume sequences, part list, discard copy), system back pauses (blocked in strict), leaving the
app pauses a non-strict paper, device-stored `mock_pause_warning_seen`; `bd2f0aeb` custom setup
with in-place wheels and saved values; `c56b38b4` server callable client and paper decoder;
`0bbe8fb8` ordered, account-bound web session; `bd25a807` web route and platform seam;
`904c37ed` deletions that have no caller left.

Open items and exact reasons are in the builder report to the lead:
- Pause warning "Don't show this again" checkbox: `CenteredDialog` has no slot for it (no W2
  ownership granted). The stored flag and corrected copy are in.
- Strict system-back "line": no approved copy.
- MK_Sheet/MK_SheetCSE: the shared `QuestionGridSheet` lacks the board's per-part "13 of 60"
  count, "Opens when this part starts." note, "Tap any question in this part to go to it."
  footer, and draws a part title for a one-block paper.
- Task 6 (finale and results): `HalfRingGauge` is 220x112 with a 44 px number; MK_Results draws
  264x128 with a 56 px number and one decimal; the finale's 241-element sequence is not built;
  "See full record" has no destination board.
- Task 7 (All questions review) not started.
- Web results, history, review and card availability wait for the server reader.

## October 21 finish/review continuation checkpoint

The lead resumed the existing `web/new-design-w4e-r1` worktree rather than restarting W4e.
Recovered local checkpoints were `33fc4d13`, `d7442bb4`, and then verified/committed Task 7 as
`49616b59` (`Finish stored-attempt mock review`). Focused review/access tests passed 17/17; scoped
analyzer, formatting, layering, attribution, and whitespace checks were clean before that commit.

This continuation closed two native correctness gaps with tests first:

- Historical `/mock/review/:attemptId` now uses feature-owned per-attempt access, including the
  stored attempt's tier coverage. The active selected exam no longer grants or removes historical
  paid-note entitlement. Direct review also cannot bypass the stored review lifetime; a denied or
  unresolved access path returns to the results route, which owns the existing loading/locked state.
- Fresh native submission now constructs the immutable finale input from the actual saved snapshot,
  frozen part ranges, scoring questions, answers, current part/cursor, and terminal reason after
  scoring/saving, and passes it through GoRouter `extra` with `fresh=1`. Retired questions are
  excluded consistently with scoring, the cursor is adjusted by retained ids before the original
  cursor, empty original parts remain, and an all-retired paper omits finale input instead of
  synthesizing outcomes. Historical results cannot reconstruct this payload.

Valid RED evidence: the historical review route first rendered `proIsActive=false` despite stored
coverage and allowed an expired direct review; the native submit route first reached results with
`state.extra == null`; the finale-builder tests first failed because the builder did not exist.
After the fixes, `mock_result_destination_test.dart`, `task4_route_test.dart`, and
`mock_finale_test.dart` pass together (9 tests). Final scoped verification on the six changed
source/test paths reports format 0 changes, analyzer `No issues found`, those 9 tests passing,
`check_layering: OK`, `check_no_ai_attribution: OK`, and clean `git diff --check`.

Task 8 custom-track setup was re-audited rather than rewritten: the in-place Questions/Time wheels,
saved-value reopening, section breakdown, held-Save sentence, corpus ceiling/correction action,
dark/light 200% behavior, persistence, and sampler round-trip pass 26 focused tests.

Required holds that this family must not bypass:

1. Production web card availability and completed results/history/review still require the
   Claude/server-owned reader for next eligibility, result fields, and tier-filtered review data.
   No guessed endpoint or local authority was added.
2. The complete finale motion remains stopped by the approved fidelity ruling: launch CSE has
   155/145-question one-clock papers, while the approved motion board draws a different sampled
   four-part geometry. Packing/card height/path assignment/impact geometry for the launch counts
   has no faithful drawn representation. The real submission payload is now available, but no
   generalized or shortened substitute was introduced.
3. Task 9 cannot delete the old `MockPanel` yet because W4d Task 2 explicitly owns passing W4e's
   `MockCard` into the Quiz tab widget slot. Current production routing still calls `MockPanel`;
   deleting it here would break production and take W4d ownership. The other named obsolete W4e
   presentation candidates audited here are already absent.

Family rerun after removing the superseded active-exam review-route assertion: `test/app/router_mock_panel_test.dart` passes 7/7 and `test/features/mock_exam test/app` passes 547/547. The first family run failed only the two obsolete review cases; production was unchanged for that correction.

Aedwon's visual acceptance remains outstanding for the rebuilt W4e surfaces. These external/design
and inter-family holds prevent a truthful family-complete claim; they do not reopen the finished
W4e-owned native review, custom setup, or fresh-submission data contract above.


## October 21 local continuation and scoped review corrections

Exact user instruction in chat 01a15acf: "can you continue until completion? no need to use the relay, you have full access to local files and you're on codex". This authorizes local execution of the existing approved W4e scope. It does not substitute for the required CSE finale representation, human visual acceptance, or separate server ownership.

Startup fetched origin and read current main AGENTS/WORKFLOW at 49b15889577b29cddd0c6a30ce81aff9a4774c22. The assigned W4e worktree was clean at ecbb6c76bbd11e3c23e6207b77b6d2bee919152c, four expected continuation commits ahead of matching remote b5da6f99e599ce71a040b82f5b698fb0f7a7b0f3. Integration remained 72629940aa8dccf54bff0c6c568a364e0f10916d; main application source was not changed. No unexpected drift, reset, merge, relay request, or UI automation occurred.

Fresh baseline on ecbb6c76: `flutter test --no-pub --concurrency=1` exited 0, `08:54 +4147: All tests passed!`. Format checked 1479 files with zero changes; layering and attribution passed. Broad analysis reports only the existing accepted reader-family onReorder deprecation at bookmarks_sheet.dart:238:21, not a clean analyzer result.

An independent read-only reviewer inspected b5da6f99..ecbb6c76 from the separate regression-baseline worktree. This was a bounded review of saved continuation slices, not the still-premature complete-family engineering audit. Three P2 findings were confirmed in source:

- The new question viewer omitted hydrated passages and authored diagrams. It now uses existing QuestionCard with passage, figure, immutable choices and revealed answer state.
- The replacement removed individual study-flag controls. Both tiers now retain a functional viewer flag/unflag action using the existing flag repository. Saved study flags remain distinct from the immutable marks made under the clock; bulk saving refreshes their state too.
- Stored reasons/notes were never loaded into the editor. The existing snapshot decoder now supplies saved answers, preset selection and custom text; a successful save invalidates that data before reopening. The editor waits for saved data rather than mounting with an empty draft while it loads.

Valid regression RED: four new viewer tests failed on absent passage text, absent gear painter, absent flag action and absent saved-note text field. After correction the original 14 tests plus all four regressions passed. A fifth regression reproduced the delayed-note load through Finish the Notes; after the loading gate, the final file passes 19/19. Logs: build/w4e/finish-review/review-regressions-red.log, review-regressions-green.log, notes-wait-red.log, review-regressions-final.log. The first attempted RED had a nonexistent test-fixture copyWith and was corrected before valid behavioral RED; it is not counted as regression evidence.

The user has been asked whether this lead should also own the missing server reader on a separate working branch. No server changes are authorized by an unanswered question. Existing production web reader, CSE finale geometry, W4d caller/deletion, full-family audit and phone visual-acceptance holds remain unchanged. Verification closeout follows below.


### Local continuation verification closeout

Final frozen-source run: `flutter test --no-pub --concurrency=1`, exit 0, `08:14 +4152: All tests passed!` (review-fix-full-final.log). All five new regressions ran in that full run. A prior post-fix run overlapped deliberate regression-RED editing, compiled the intermediate delayed-note behavior, and failed that case; it was interrupted and is not acceptance evidence (review-fix-full-suite.log). The final run started only after production/test edits stopped, and the manifest below remained unchanged throughout it.

Final focused review file: exit 0, `00:01 +19: All tests passed!` (review-regressions-final.log). Scoped analysis of all three changed Dart paths: exit 0, `No issues found! (ran in 1.9s)` (review-fix-scoped-analysis.log). Broad analysis: exit 1, exactly the existing accepted onReorder deprecation in the unchanged reader-family bookmarks sheet, `1 issue found. (ran in 4.5s)` (review-fix-broad-analysis-final.log). Do not describe broad analysis as clean. Formatting: exit 0, `Formatted 1479 files (0 changed)` (review-fix-format-check.log). Layering and attribution exit 0 with `check_layering: OK` and `check_no_ai_attribution: OK`. Whitespace check clean.

Frozen source SHA256:

```text
a2700b31a19891bc94c9a7509b4d529281b3dfa64759fa582cbc1b4765757eda  lib/features/mock_exam/application/mock_review_providers.dart
e434f48ab1a8d3f3d053d645a4a9c2e6b7cf297271bcb4655eaf63f60a7203f6  lib/features/mock_exam/presentation/pages/mock_review_page.dart
e83c240352c217bf7c02379191d7f5f4351436886f811ddae922b01c38e2a1d0  test/features/mock_exam/presentation/mock_review_page_test.dart
```

The three scoped reviewer findings are corrected and verified. No deferred minor finding was reported. This completed bounded correction slice may be uploaded with the four saved reviewed native continuation commits. It is not Task6 motion completion, complete-family engineering acceptance, development integration, phone visual acceptance, live-server acceptance or publication. Current staging20692945380876e649045dd9f537db405e9d34c4 still exposes only startMock/getMockPaper/controlMock/submitMock; its completed reader remains absent. Root has not edited a server-owned branch or invented a local web authority. The current status/decision record on main was refreshed at67843ff3; a final status closeout records the pushed checkpoint and releases this continuation's lock.


## October21 bounded authorization and CSE finale proposal v1

Latest exact user instruction: "i authorize you to complete W4e including its dependencies (unless it's on another workstream)". Startup fetched origin and reread main AGENTS/WORKFLOW at a4003d849ad49dc622880b89a8d6bf5ebdc17a84. The W4e branch and GitHub matched00b0f1e2 with a clean tree. Existing authorization to execute locally remains in effect. The exception preserves the separate PWA server-track reader and W4d Quiz caller ownership; it does not authorize taking those workstreams over. Existing product approvals remain binding; no new complexity menu or routine execution gate is introduced for settled W4e work.

Root prepared the missing CSE geometry/motion comparison rather than asking Aedwon to resolve it without a preview. Artifact: docs/design/proposals/w4e-cse-finale-2026-10-21-v1.html, SHA256 09d5c4ddeeb2c994068e9ffd8e303f7bfba81cfb04311354d275e2710cc4389f. It is self-contained, with the actual approved MK_Finale source embedded once and its171 original dot-flight tracks retained as data. The reference stays unchanged. The two proposals show a single booklet in a390x844 preview:

- A, recommended:13columns, original330x189 initial card and352x199 checking card for full CSE counts; tighter initial vertical spacing. Least card/scan geometry change.
- B:10columns, taller cards and a longer scan in the same time; more initial dot spacing but additional card/scan geometry adjustments.

Both expose155/145 exam selection, shorter actual papers from1 through the selected total, mixed/all-correct/no-correct illustrative outcomes, dark mode, synchronized replay, time scrubber and phase controls. Correct outcomes map evenly onto the existing171 sampled flight tracks, with an affine endpoint correction toward the original195,359 gathering point; original per-stop timing/opacity/deformation remains. No-correct samples omit the ball, impact effects and shake. An all-retired paper retains the existing skip-finale rule. Scores shown in this proposal derive from the explicitly labeled example counts, not student data. The draft-selection control does not authorize implementation; Aedwon sends the selection in chat.

Represented interval:0–6seconds, including initial booklet, opening, scanning, gathering, ball deformation and gauge impact. Existing later results/breakdown/history motion is outside this proposal and is not re-approved here. Dark colors come from the candidate's W1 token values. Large-text/native rendering, strict early-end adaptation and phone visual acceptance remain separate implementation checks. This preview is a proposal, not a claim that the app currently renders it.

Non-browser checks: JavaScript parses;84 combinations across both layouts, seven paper sizes, three outcome patterns and light/dark pass the DOM/data control probe with exact generated dot count and final score; all310 layouts for1–155 questions keep dots inside the card and above the count line. No browser/desktop automation or screenshots were used. Root has not performed visual acceptance. The app source is unchanged; existing4152-pass evidence still applies to00b0f1e2. Only the proposal and this evidence change in this slice. Waiting for Aedwon's choice before implementing a new geometry.


## October21 taller compact CSE finale implementation

Execution approvals are preserved on main e5f2f3fc913a41909f97d660d363221e82ea7b9f and the candidate spec/plan2026-10-21-w4e-cse-finale.md. Root fetched and reconciled clean local/remote86269158 before editing; current policy files were read from main99f708a8 and remained unchanged by the approval-log commit. User explicitly selected13columns, then approved extending the rows downward and waived another preview for that extension. Original proposal remains unchanged for chronology.

Implemented in the existing W4e worktree, without relay, server edits, schema/content changes or other-family source:

- Feature-owned immutable paper geometry:13columns,9pxquestion dots, initial/checking horizontal22/24 and vertical16/18.155retained questions produce155question dots, initial/checking cards255/237high, and scan end494.145 and shorter actual papers derive their own rows/bounds; no preview sample answers or permutation enter the app.
- Deterministic extraction of171 original flight tracks and34 original effect/reveal tracks, preserving source keyframes, cubic curves, scale, opacity, ball deformation, trails, impact, source scanner shadow and glow. Regeneration is byte-identical. The generator reads the main design source and disables Python bytecode writes to that source folder.
- A single9650ms sequence clock drives the real CSE submission snapshot, actual correct/wrong/blank outcomes, scanner/gathering/ball, gauge arc and separately timed number/caption, results/header/breakdown/review/Done and original Today-point/path/label reveal. The illustrated finger and demonstration scroll are not autoplayed. The result view remains scrollable and retains its real access/actions.
- The optional mock-gauge number/caption opacity and independently displayed fraction preserve Home/default gauge behavior and the existing mock size. Hidden numeric/caption content is not announced. Shared default-gauge tests remain applicable; W4d's unmerged count extension was not touched.
- Fresh native CSE Professional/Subprofessional only: actual nonempty snapshot must match saved total/correct counts. History, missing/mismatched input and other exams do not replay/reconstruct the finale. Strict exits retain the already-drawn static Not finished result; no undrawn strict-exit animation is invented. Reduced motion initially or during playback completes immediately and never restarts. Large text reflows the title/counts and preserves the real gathering/gauge alignment.

Valid TDD evidence: geometry/scene/gauge/reveal APIs failed as missing before implementation; the fresh-CSE route test failed on absent CseMockFinale before wiring. The original Today-point stop test observed radius3.57044 instead of2.8 at8310.016ms before using the sampled source pop. The nonlinear card-fade test first failed on missing source track; after extraction, its tolerance was corrected to the actual Flutter Cubic solver's documented0.001 numerical bound rather than replacing the curve. A first scene ticker assertion included the test helper's AnimatedTheme transition; the fixture now finishes that framework tween before checking that no ticker remains.

An independent read-only reviewer inspected the14-path manifest before/after at exactly the same hashes, using a separate baseline worktree and current policy e5f2f3fc. This was a bounded CSE source review, not the deferred complete-family audit. Two P2 findings were accepted and corrected in one tests-first pass:

1. The dot checked-time equation used linear row timing and included the shared large-text offset. The scanner itself eased and shifted with that offset. One feature-owned eased scanYAt now drives both the bar position and row-color decision in relative geometry. The regression first observed a premature checked first row; final assertions also prove the offset100 bottom row is checked before fade.
2. An access-provider refresh could unmount/recreate the fresh finale and replay it. The result route now remembers the consumed/interrupted submission for its own attempt lifetime. Loading/error/missing-data transitions finish that presentation; restoring access keeps actual static results without replay. New attempts reset the local UI marker. The same valid regression failed with a new active CseMockFinale after access refresh for both CSE exams, and passes after correction. No persisted flag, schema or entitlement bypass was added.

Focused post-correction motion/route tests15pass; prior complete new/gauge focused32pass; renewed mock/app/gauge family585pass. Cases cover every1–155question booklet geometry, actual outcomes/cursor preservation, original source stops, no-correct omission, 320/390/430 widths, light/dark and200%text through each phase, reduced motion initially/mid-sequence, disposal/rebuild, history/strict/extra gates, real result controls and access-refresh non-replay. These are automated render/data checks, not human visual acceptance.

Current static gates: scoped changed-source analysis has no owned finding; broad analysis retains exactly the recorded reader-family onReorder deprecation. Format1487files/0changes, layering/attribution/whitespace pass. Root froze the12-code-path manifest before the final full suite; detailed source hashes and raw outputs remain under build/w4e/cse-finale. Full-suite closeout follows below, only after its actual result.

Scope limits remain explicit: the separate server reader and W4d caller/deletion are excluded by the user's authorization; no web completed-result authority or endpoint was invented. This CSE slice does not implement UPCAT/two-ball or other multi-part finales, claim all W4e Tasks3–9 complete, integrate into development/main application source, or satisfy phone/live PWA acceptance. Preserve these dependencies and all worktrees.


### Taller compact CSE finale: final verification closeout

Final command `flutter test --no-pub --concurrency=1` exited0 with `10:37 +4174: All tests passed!` (build/w4e/cse-finale/full-final.log). Frozen12-code-path identity was checked during and after this run with no source changes. Source-track regeneration after the run is byte-identical, including the generator's no-bytecode-write safeguard. Mock/app/gauge combined checks pass585 (family-reviewed.log); reviewed regression pair passes15 (review-fixes-green.log). Source uses exact original sampled track values with the Flutter Cubic solver's normal0.001 error bound.

Final broad analysis exits1 with exactly the existing reader-family onReorder deprecation at bookmarks_sheet.dart238:21, `1 issue found. (ran in3.4s)` (analysis-reviewed.log). No owned analysis finding remains. Format gate exits0, `Formatted1487files (0changed)` (format-reviewed.log). Layering and attribution exit0 with `check_layering: OK` and `check_no_ai_attribution: OK`; whitespace clean. Attribution runs again after the commit. No screenshot, browser automation, real-phone visual acceptance or live PWA verification was performed.

Final code SHA256:

```text
a19be5cff4bbb12557128a0171cd7f835e972f8d6b7d0b3e4c88b6d938de935d  lib/core/ui/components/half_ring_gauge.dart
caa7827ce992daa7fa72af2444edb4d177e934e664087c0b6bf6ef8cc777716e  lib/features/mock_exam/presentation/pages/mock_results_page.dart
1ffdb397f3952cb03d867b3877a9f01fb374eb67556481f30f1ffce5d5c6e563  lib/features/mock_exam/presentation/pages/mock_results_route.dart
553858a3c141662f4727f8627346b84cb02bff6c4c21d625d7a418b82fa31ac0  lib/features/mock_exam/presentation/widgets/cse_finale_motion.dart
3388f798fd3f14477f33ac34828266ffff6419b4509aa35f8500f18cc53d81d6  lib/features/mock_exam/presentation/widgets/cse_finale_tracks.dart
f968b34961633a5c1332c21225f728e60df456fb52dd77d8410351293a2a3978  lib/features/mock_exam/presentation/widgets/cse_mock_finale.dart
17a94484475b685429029add28219914667abf8913573aec6a732b88349c189f  test/core/ui/components/mock_gauge_reveal_test.dart
5eed4d7e30d39e2cf213bde961cc442854cb95dd37fc5b7cef0725d7d9ff11e1  test/features/mock_exam/presentation/cse_finale_chart_motion_test.dart
5f35b9b3f5ed1c4096d36cbb1905f97820f94beefea8ad9f3d80a617caef244d  test/features/mock_exam/presentation/cse_finale_motion_test.dart
c307564931eebdc6a8f41916a5051a256a09f65eeee0d57d08043a956038ffa0  test/features/mock_exam/presentation/cse_finale_route_test.dart
bc05210055fb2b5bb923226c628a4c987aa88b00193982388905fbe2a42a7370  test/features/mock_exam/presentation/cse_mock_finale_test.dart
a0a15ed0f1d2e0c3301af7838bd452faff16c50203831dbd22fbe7786cc4a856  tool/extract_cse_finale_motion.py
```

Independent review covered the original14-path manifest unchanged before/after. Root then corrected both findings with valid failing regressions, shared the scanner's eased coordinate owner, and made the route retain consumed presentation state across access reloads. Subsequent root-only changes were those fixes, their tests, literal fidelity/style corrections and disabling extractor bytecode output; final combined verification applies to the exact hashes above. There is no claim that the reviewer personally reran a full suite or visually accepted these screens.

Approved CSE sequence is implemented/reviewed/tested for this bounded slice and may now be committed/uploaded to its existing working branch. Keep existing source-data/evidence worktrees. No development/main application merge, whole-family audit, publication, server reader, W4d handoff, or non-CSE/UPCAT finale completion is implied. The current main status will identify the actual pushed SHA and release the lock after its remote identity is confirmed.

## October21 CSE launch finish: authoritative reader wiring and final engineering audit

User authorization: "thanks, i give you full authorization on all you need to do to complete w4e". Root recommended the necessary C8 dependency first, at balanced scope. Later root asked CSE launch versus every original exam; Aedwon selected exactly "CSE launch scope". Current main decision/status records preserve both. This explicitly defers non-CSE/UPCAT rebuilt finales; it does not claim them complete or remove existing native behavior. Local execution remains authorized without relay. Policy refreshed through main1fe036e4/04aa30f4 (policy content unchanged).

Server dependency is complete/reviewed/tested/uploaded on separate web/w4e-server-reader-r1 at0c17bfb0f6874cddb1cbdb807c0510bbd7f959ff; local/GitHub match and worktree is clean. Original staging20692945 remains untouched. It supplies actual result/history/availability/review access and paid-note writes, current exam-specific ledger coverage, server time/recheck metadata, server-only setup preview counts, per-exam lasttwo recency and original-paper answer validation. D-258 now atomically records chosen mock answers/totals/review states through the existing native scheduler, idempotently across manual/strict/timeout/history recovery. Existing C9 review answers advance those states; server roadmap consumes real due reviews and validates its cached input-session count. Final Node22 suites165plain/205emulator pass, exact native VM/JS parity6pass, scoped bridge analysis clean. Its evidence and first independent review of the newly implemented feed are on that branch. Broader server/web/global integration/deployment remains a later launch stage.

Client implementation preserves native paths and approved visible designs. Feature-owned strict decoded server views never write server mocks/results into local attempts. Account/entitlement changes mask old data; queued history stops after actor changes, and A-to-B-to-A load events cannot revive an old paper. Web setup gets its preview count from the actual server sampler, without starting a clock or locally assembling a paper. Acknowledged submissions and completed resumes open the actual server result; only a real fresh snapshot carries the selected CSE end sequence. Paid reasons use the actual server writer and preserve failed drafts/immutable retry. Original content hydrates in paper order; missing question/passage data yields recoverable error, not a shorter paper or guessed retirement. The approved MockCard replaces the obsolete MockPanel in its existing slot; its web rule/date/Pro values come from the server. CustomMockSummary moves unchanged into its domain contract. Unrelated W4d layout/review controls and its branch/drafts are preserved.

### Independent whole-family audit and correction evidence

Astra inspected frozen123client/8server manifests against full CSE scope and original boards/timelines; no screenshots/browser automation. The pre-fix client run reports08:45+4176 All tests passed, but that source was NOT accepted. Audit findings and valid regression corrections:

1. P1: 30day browser timers exceeded the signed32bit delay. Timers now use safe segments and authoritative server deadlines anchored to existing monotonic elapsed time. A25day fake-time test first observed no refresh; after correction both result/card readers refresh safely. Platform evidence: installed Dart runtime and https://developer.mozilla.org/en-US/docs/Web/API/Window/setTimeout#maximum_delay_value.
2. P2: device wall clock controlled Free expiry. A fast-device regression first retained review; serverNow/accessRecheckAt now control scheduling, including Pro lapse removing paid notes and applying the Free window.
3. P2: Retry invalidated only derived adapters and reused upstream errors. The widget regression first observed one callable attempt after Retry instead of two. Result/review/setup/card actions now invalidate their actual authoritative reader.
4. P1: flag operations could continue after account switches. Delayed-query regression first wrote into the next profile; original identity epoch/current actor and mounted checks now guard individual/bulk remaining writes and preference acknowledgment. Additional bulk verification confirms only the already-started original write can complete; no subsequent write or offer acknowledgment follows a switch.
5. P2: server recency was account-global. Different-exam intervening submissions first caused reuse; the server now filters requested exam/completed timestamps before limiting to two.
6. P2: cooldown on an exam never taken showed a dead results action. Regression first found View Last Results; absent applicable history now supplies the existing null-action contract, preserving the real account-wide reopen date.
7. P2: partial hydrated content silently shortened review. Regression first emitted an empty successful list; missing original questions/passages now produce a retryable error.
8. P2: server accepted duplicate/foreign paper answers. Regression first persisted invalid input; saving/submission now validate original membership/uniqueness and logical blank correctness before mutation, preserving the accepted client-correctness trust limit.

All eight are accepted/fixed, no deferred minor finding. The audit's D-258 handoff gap was implemented under the user's dependency authorization, then received its FIRST independent scoped source review with no consequential finding; this was not a second whole-family audit or repeat review of fixed findings. Human visual acceptance, deployment and combined web build were explicitly outside automated engineering acceptance. No authoritative server retirement feed exists; no inferred retirement protocol was introduced. Native retirement behavior remains covered.

Valid focused logs are retained under build/w4e/completion. Initial timer test cleanup left a fake timer pending after correct assertions; its fixture now explicitly disposes subscriptions/container before widget invariant verification. The first added bulk fixture used obsolete label strings, then was corrected to actual Flagged12/Save All12 before verification. Those setup failures are not counted as product RED evidence. New typed result tests first failed on absent results API; valid actual failure regressions establish all consequential corrections.

### Corrected client checks and final exit-flow correction

Frozen corrected command flutter test --no-pub --concurrency=1 exits0,08:33+4184 All tests passed; source-corrected-sha256.txt stayed unchanged during the run. Broad analysis has exactly the accepted unchanged reader onReorder deprecation, no owned finding; layering/attribution pass. Timer/content/provider and review/flag regressions pass33; the combined retry/card/review group passes40 before final added cases. Shared/default gauge behavior and the selected CSE motion remain covered by the full run.

Final exit-flow inspection then reproduced cached available state after returning from non-strict discard, although the server keeps the original open paper. One existing-reader invalidation on close corrects it. The valid regression observed expected in-progress vs actual available before correction; all18web route tests now pass. First fixture attempt blocked on a changing default entitlement stream and was interrupted; the stable entitlement fixture provides the valid behavioral RED/GREEN and is not a production workaround. Final feature acceptance uses the combined development-integration full gates, which cover this last correction and the accepted W4c inputs. The4184 run is correctly labeled as the immediately preceding source, not this final one-line correction.

No main application merge, release, live server/browser/device verification or visual acceptance is claimed. Final working-branch/development source identities and combined verification follow in the closeout after actual gates complete. Preserve all unique worktrees/evidence and the pending human/global stages.

### Final CSE launch engineering closeout

Accepted combined application source: development merge17b2f0b32e4c62808fd6f7097c9054c52f7616c1, containing W4e feature f9c283749384eab95afb61d84e6bbd0cff8a1104 and previously accepted W4c72629940. The merge is conflict-free; all68W4c changed paths remain byte-identical and final W4e feature paths are unchanged. No server-owned branch, main application source or publication target was mutated.

The incoming ContentDatabase9→10 migration carries its nullable unscoredItems migration in the original implementation commit. The initial pre-generation check was stopped and is not acceptance evidence. Normal build_runner generation completed before the accepted integration checks. No AppDatabase/pubspec change arrived in this merge. Ignored generated database code now matches the merged source.

Actual final combined command flutter test --no-pub --concurrency=1 exits0,09:16+4439 All tests passed (integration worktree build/w4e/integration/full-final.log and full-final.exit). This includes the final discard/card refresh regression and all accepted reader inputs. Final integrated flutter analyze --no-pub: No issues found (3.8s). Format1492files/0changes, layering and attribution OK; clean tracked worktree throughout accepted run. Source identity and input preservation are recorded in input-identity.txt. No unchanged full suite is repeated for the following documentation-only closeout.

All eight whole-family audit findings are fixed and verified. The necessary D-258 server implementation has independent first-review acceptance, exact existing scheduler parity,165plain/205emulator pass on Node22 and clean Dart bridge analysis. Server working branch is0c17bfb0f6874cddb1cbdb807c0510bbd7f959ff with matching GitHub head and clean tree. The app/source working and development branches are uploaded normally after this documentation closeout; main STATUS records their exact final heads.

W4e CSE-launch ENGINEERING implementation/review/testing/development integration is complete. Other-exam/UPCAT rebuilt finales remain explicitly deferred. The agreed later global server/web/PayMongo/content-cache integration, signed content/release work, Aedwon's phone visual checks and real staging/browser/device acceptance are not claimed by these local checks. Preserve all necessary worktrees/evidence for those stages and the queued W4d work. No deferred minor finding or unresolved W4e engineering decision remains.
