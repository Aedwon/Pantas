# W4d quiz evidence

## Assignment and policy

- Policy: origin/main `cb4dc3cecb5788e9036db24d41c7478aacc3638d`, fetched October 12, 2026. Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md, the standing W4 rulings and the quiz plan's October 12 rulings.
- Product inputs: L3-W4d-quiz.md and L2-W4d-quiz.md on that main revision, all W4d traceability rows, the approved October 5 amendment, shared state-pattern contract, W2 October 10 contrast rulings, and design boards in the main checkout. Main checkout is read-only.
- Starting source: `958ed879`, branch `web/new-design-w4d-r1`, clean linked worktree. Integration already reached this branch, including W4e's MockCard. No previous W4d patch or commit was present.
- Authorization: October 5 restart applies to this design work. Other engineering pauses and main application-code freeze remain. Do not push or merge.
- Task order: 1, report contract/form from 7, then 2 through 9.
- Pre-flight shared interfaces: Task 1's lesson scope feeds Task 4; the report form feeds Tasks 4 and 6 and W4a; Task 4's checked outcomes feed Tasks 5 and 6. W4e's card is injected through the route layer, never imported by quiz presentation.
- Review and phone visual acceptance remain with the lead and Aedwon.

## Task 1: lesson and quick starts

Files:
- `lib/features/quiz/application/quiz_starts.dart`
- `lib/features/quiz/domain/use_cases/start_inline_lesson_quiz.dart`
- `test/features/quiz/domain/use_cases/start_inline_lesson_quiz_test.dart`

Public entry contracts: `startLessonQuiz(BuildContext context, LessonId lessonId, {required ExamId examId})` and `startQuickQuiz(BuildContext context, {required ExamId examId})`, both `Future<void>`. Each pushes the declared route, preserving the reader or Study return route. Inline selection filters on the W0 question lesson id before the existing five-question picker. A smaller lesson pool stays smaller; sibling questions never fill it.

Checks:
- Initial test load failed because ignored Freezed outputs were absent. Ran `dart run build_runner build --delete-conflicting-outputs`: exit 0, wrote 2816 outputs. No generated files staged. Existing generator SDK-range and obsolete drift-option warnings reported; no dependency or configuration changes.
- RED: `flutter test test/features/quiz/domain/use_cases/start_inline_lesson_quiz_test.dart --reporter expanded`: exit 1, +3 -2. Three-question pool wrongly returned five; seven-question pool included a sibling.
- GREEN task checks: `flutter test test/features/quiz test/features/review_prompt test/app --reporter expanded`: exit 0, +459, All tests passed!
- Format: three affected Dart files, 0 changed.

## Contrast changes

None yet.

## Waiting on a contract

None yet.

## Open questions and remaining work

Tasks 2 through 9 remain. No backend report function exists; reports must remain queued until a sender is approved. No deployment is authorized.
- `flutter analyze lib test tool`: exit 1, `1 issue found. (ran in 8.3s)`. Only the existing bookmarks `onReorder` deprecation at line 238, explicitly assigned to W4c Task 8 and recorded as accepted in W2 evidence. Zero quiz findings.

Task 1 commit: `4ce766957304055116187b6008142abd05a59894`.

## Task 7 early contract: report entry, form and local queue

Files: `lib/features/quiz/data/report_queue.dart`, `lib/features/quiz/presentation/report_form.dart`, their tests, `lib/core/ui/components/floating_bar.dart`, and `test/core/ui/components/floating_bar_content_test.dart`.

Contract: `Future<bool?> openQuestionReport(BuildContext context, String questionId, {required ReportQueue queue})`. The caller passes `ReportQueue` built from its app database. True means the report was saved locally, allowing the caller to color its icon teal. Cancellation returns null. No feature-specific provider or viewer route is required by W4a.

Boards read through outline.py and timeline.py: QN_Report, QN_ReportOffline, QN_ReportAgain, QN_ReportLimit. Form: title 17/700, detail 13/400 at 1.4, field 16 at 1.4, insets 18/18/18/16, field radius 12, pill height 44, spacing 10. Shared FloatingBar gains a content constructor with configurable radius and inset, allowing the 24-radius form without a feature-local surface. Existing row interface stays intact. Extension test lives beside W2 tests.

The approved no-op sender retains every queued report. Until the backend exists, production success uses the board's truthful offline saved line, not a claim of delivery. Limits are atomic, 3 per question lifetime and 20 per local day. Blank text consumes no slot. Existing report copy is retained for the per-question limit, which has no separate drawn board. A failed save retains the text and uses the shared retry line. Focus node, text controller and close timer are disposed.

Checks:
- RED queue and form tests: exit 1, missing new ReportQueue, ReportForm and openQuestionReport contracts.
- First form run: +6 -1; entry test did not pump the changed input before tapping its still-disabled Send. Corrected the test's interaction sequence.
- Task checks: `flutter test --no-pub test/features/quiz test/features/review_prompt test/app test/core/ui/components/floating_bar_content_test.dart --reporter expanded`: exit 0, +467, All tests passed!
- Focus ownership added; rerun affected tests: `flutter test --no-pub test/features/quiz/data/report_queue_test.dart test/features/quiz/presentation/report_form_test.dart test/core/ui/components/floating_bar_content_test.dart --reporter expanded`: exit 0, +8, All tests passed!
- `flutter analyze --no-pub lib test tool`: exit 1, `1 issue found. (ran in 3.6s)`, only the accepted W4c bookmarks deprecation. Fixed every new lint.
- `dart run tool/check_layering.dart`: exit 0, `check_layering: OK`.
- `dart run tool/check_no_ai_attribution.dart`: exit 0, `check_no_ai_attribution: OK`.

Remaining Task 7 work: wire the icon into the live question and viewer screens in Tasks 4 and 6; verify their return animation and recoloring with those screens. No report backend is approved or deployed.

## October 13 resumption and Task 2 partial checkpoint

Policy read in full from current GitHub main: AGENTS.md, WORKFLOW.md and SUBAGENTS.md, plus current relay README and project instructions. Policy revision: `93fe98f21f1d945fa5e78b423e7626d259b0d2e5`. Product inputs: current L2/L3 W4d, strategy, amendment spec, W4 collision map and standing October 12 rulings, relevant later decisions and W4d traceability rows. Board inputs read from the primary checkout using outline.py and timeline.py: QZ_Tab, QZ_Free, QZ_Resume, QZ_Done, QZ_First. No app screenshots or autonomous visual review.

Authorization: Aedwon said, "okay resume that. the plan already tells what to do exactly right?" The October 18 implementation wait is lifted. No deployment, publication, main code update or worker integration is authorized. The lead requested this stable checkpoint before Task 3 because the current usage window is nearly consumed.

Source on resumption: branch `web/new-design-w4d-r1`, assigned worktree `Pantas-wt-new-design-w4d-r1`, local and remote HEAD both `a2a0cb808afa4a5c808648170509949240d0e5df`. Relay #9489 fetched origin and verified repository, branch, HEAD and the same ten dirty paths previously observed in #9488. Task 1 and the early Task 7 report contract were preserved. No reset, discard, merge or remote branch update occurred.

### State

- Task 1: previously implemented and integrated. No redo.
- Task 7 report entry/form/queue: previously implemented and integrated. Wiring remains in Tasks 4 and 6.
- Task 2: independent Quiz tab implementation saved locally, partial. Not accepted or integrated.
- Tasks 3 through 6, remaining Task 7 wiring, Tasks 8 and 9: not started in this resumption.
- Current source and dirty patch identity before commit: `logs/W4d-task2-source-identity.json`. It records base HEAD and every changed/new source and test file's SHA-256. The deleted nudge test is recoverable from base HEAD. Full command outputs are in `logs/W4d-task2-*.txt`.

### Changes and draft defects

The resumed draft did not compile: build constructed a page without returning it (#9492). It also constructed a local sheet that never appeared. That unsupported sheet implementation was removed because W4b owns the missing contract. The paused row showed the daily count instead of the saved session position. Customize was not dimmed, the assessment card used radius 14 instead of 18, and the draft lacked the board entry timing. These unfinished drafts were corrected without redoing committed work.

The tab now shows assessment, available, paused and finished states; measured Today and practice counts; the router-injected MockCard; empty practice rows; Resume and Discard; refresh after returning from assessment/session and on app resumption. A failed discard keeps the saved session and offers the shared retry line. The route layer owns the MockCard dependency; quiz presentation does not import mock presentation.

Shared component extensions, authorized by the W4h ruling: ListRow's leading widget, optional value style and title color; PantasPage's bottom inset; ProgressRing's optional fill duration and delay. Existing defaults stay intact. Row metrics use the board's 24-point ring and 12-point gap, 15-point count, and 104-point bottom clearance. Section entries rise 12 points over 450 ms after 100/190/280 ms. Positive review/new rings fill over 700 ms after 500/620 ms; paused reviews begin after 600 ms. Reduce motion displays the endpoint. The assessment surface uses radius 18. The migrated tab shell expectation follows the new tab type.

The retired nudge UI and its provider/import/export were removed. The legacy tab remains until Task 9's deletion. The old nudge table and repository remain because the lesson cleanup still references the repository and schema must stay unchanged. No schema, attempt, per-question response-time or note storage change occurred.

### Verification

- #9492: existing draft test load failed with missing Widget return; shared extension tests +2 passed.
- #9494/#9498: expanded state and return regression tests added; interrupted draft compilation repaired.
- #9496: patch preflight rejected a zero-context patch. No partial application. Corrected with the guarded local edit in #9498.
- #9500: +16 -1. The failing assertion queried GoRouter's base route information after an imperative push. Corrected the test to assert the pushed screen and its completion return. This was a test assumption, not a product defect.
- #9502/#9503 RED: +11 -4. Four light/dark and 1x/2x paused tests expected saved "6 of 10" in Reviews but saw daily "12 of 18".
- #9505/#9507 RED: the paint/timeline regression required the missing ProgressRing fillDuration/fillDelay contract.
- #9506/#9509: smallest fixes and shared extensions.
- #9510: +475 tests passed, one load failure because the command named a nonexistent progress_ring_test.dart. No product test failed; the command was corrected.
- #9512: +974 -1. The shell test still expected the retired tab type. Analysis reported 85 findings: 78 trailing-comma notices, six owned cleanup notices and the existing bookmarks deprecation. Format, layering and attribution passed.
- #9514/#9515: corrected the migrated shell expectation and all owned analysis findings; mechanical fixes touched only the recorded task files.
- #9517 final affected tests: `flutter test --no-pub test/features/quiz test/features/review_prompt test/app test/core/ui/components test/features/shell --reporter expanded`: exit 0, `00:42 +975: All tests passed!`
- #9517 analysis: `flutter analyze --no-pub lib test tool`: exit 1, `1 issue found. (ran in 3.7s)`. Only the preexisting accepted bookmarks onReorder deprecation at line 238, owned by W4c Task 8. Zero Quiz or new shared-component findings. This is not a clean-analysis claim.
- #9517 format: `dart format --output=none --set-exit-if-changed lib test tool`: exit 0, `Formatted 1448 files (0 changed) in 1.40 seconds.`
- #9517 layering: exit 0, `check_layering: OK`.
- #9517 attribution: exit 0, `check_no_ai_attribution: OK`.
- #9517 `git diff --check`: exit 0.
- Full Flutter suite, family final checks, independent review, integrated-candidate checks and phone visual acceptance remain pending. These 975 checks prove this affected scope only.

### Waiting on a contract and remaining fidelity

- W4b Home Today rows/sheets: Reviews and New questions opening controls and their chevrons are omitted, with no disabled/dead substitute. Consume the shared contract when it reaches this branch. Current empty rings use W2's default 1.5-point outline; QZ_Resume draws the empty New questions ring at 2 points. Finish that metric with the shared Today rows before visual acceptance.
- Task 4's session metadata is still required for QZ_Resume's "Session 1 of 2" detail and origin-specific labeling. The current row displays the saved question position without inventing a session figure.
- Task 9 deletes the remaining legacy tab/screens/tests and coordinates retirement of the old nudge repository with the lesson cleanup. Keep the storage schema intact.
- Contrast changes for Task 2: none. Disabled and empty rows retain the drawn dimming. Wrong-answer contrast belongs to Task 4 and remains unverified here.
- No visual acceptance is claimed. Aedwon still checks QZ_* against the approved boards on his phones.

## October 14: Task 3 verified core slice, picker UI still pending

Resumption policy: current AGENTS.md, WORKFLOW.md and SUBAGENTS.md retrieved from GitHub main; their blobs are unchanged from the documents read in full earlier. Fetched main is `cec54bd782e4e40e22c8c12a9c086186a57e3452`. Current L3 W4d includes all three October 13 clarifications (Total time redistribution, partial-session recency, Questions-mode overrides), read before their affected implementation. The relay README and project instructions are unchanged. Aedwon's October 14 instruction was "continue".

#9555 reconciled the assigned worktree: local and remote `web/new-design-w4d-r1` both `0ad018fe64678a26ae8e35af665de5e94c79c45b`; the expected Task 3 drafts were preserved. Every source hash from #9554 still matched before editing. No merge, reset, discard or publication occurred.

### Implemented and verified in this slice

- A whole topic contributes each available lesson, not one topic-sized unit. Questionless lessons remain excluded; restored picks filter unavailable ids.
- Questions mode uses the approved 50-second starting pace and a measured average when available. Total time divides one budget across all selected lessons, with deterministic remainder allocation and real-pool caps.
- Questions-mode row overrides change actual counts and derived time while retaining the wheel's base. Total-time adjustments redistribute the current question budget. Singleton Total time cannot redistribute. Bounds retain a question per eligible pick and respect real capacity. Stale stored splits cannot change the current time-derived budget.
- Last picks and length/adjustments use the exact two per-exam device-pref keys, written together. No schema, synchronization or security-path change.
- Selection retains the seven-day attempt query and supplements it with batched existing checked-review timestamps. Seed states with zero reviews stay eligible. Recent questions top up small pools before shortening.
- Questions mix across selected lessons. Passage grouping remains contiguous, and the same final order is written into the durable session. Response times, attempt completion and existing per-answer writes stay intact.
- The measured pace refreshes on the existing completion revision. The shared ScopePicker supports questionless lessons, excludes them from topic ticks, dims them, and keeps titles on one line at 200% text.

The 17 source/test files in `logs/W4d-task3-core-final-identity.json` define the exact verified and staged scope. The shared ScopePicker extension is outside the original L2 directory table and is authorized by the W4h extension ruling, with its covering tests. No generated file or dependency change.

### Test-first evidence and actual results

- #9527 RED: +1 -4. Topic selection collapsed three lessons to one null lesson; the initial pace was absent; Total time returned 36 questions instead of 12; a zero-question lesson was selectable.
- #9535 first rule GREEN: +24. Recency/mixing RED: five failures after the passage-order test was added in #9539. Checked discarded partials and the seven-day boundary were missing from recency, old order stayed blocked, and required top-up ordering was wrong.
- #9538 RED: new adjustment and preference contracts absent.
- #9544: +40 and one preference test load failure from untyped record-map inference. Fixed with explicit generic types. The ScopeLesson.hasQuestions contract was absent in its RED test.
- #9548: the pace test returned null after seven completed attempts and a completion revision. The picker draft could not load because its screen was not yet implemented.
- #9551: +39 helper tests passed; stale-budget RED expected 12 but returned 40. Added the budget guard.
- #9554 broader applicable scope: `00:24 +522: All tests passed!`. Analysis found seven owned style notices. Format `1456 files (0 changed)`, layering, attribution and diff checks passed. Exact commands and the matching pre-style source hashes remain in `logs/W4d-task3-commands.json` and `logs/W4d-task3-source-identity.json`.
- #9556 fixed only the recorded block/constructor/local parameter style and trailing commas. #9557 reran the affected 45 tests: `00:01 +45: All tests passed!`.
- #9557 owned analysis: `Analyzing 17 items...`, `No issues found! (ran in 1.2s)`, exit 0.
- #9557 full format scope: `Formatted 1456 files (0 changed) in 1.55 seconds.`, exit 0.
- #9557 layering: `check_layering: OK`, exit 0.
- #9557 attribution: `check_no_ai_attribution: OK`, exit 0.
- #9557 diff check: exit 0.

The 522 tests were not repeated after purely mechanical style fixes; the 45 affected tests and owned analysis were refreshed. Exact argv/results and current hashes are in `logs/W4d-task3-core-final-commands.json` and `logs/W4d-task3-core-final-identity.json`. Full outputs are retained in `logs/W4d-task3-*.txt`.

### Remaining work and unverified acceptance

Task 3 is incomplete. The new picker screen, floating bar, How long? UI, mode/wheel/Reset interaction wiring, ordered preference-save lifecycle, and production route switch are not implemented. The RED draft `test/features/quiz/presentation/practice_picker_screen_test.dart` remains separate and unstaged; its hash is recorded. It still imports the absent new screen. The existing legacy picker remains the production route until the screen slice is finished. Full Task 3 tests, full family checks, independent review and phone visual acceptance are pending.

Task 2's shared Home rows/sheets and Task 4 session metadata remain pending exactly as previously recorded. Tasks 4 through 9 and the remaining report wiring were not started in this slice. No backend sender or deployment is approved.

Contrast change: the meaningful ScopePicker caret moves from tertiaryLabel (light `#AEAEB2`) to existing controlOutline (light `#8A8A8E`, dark `#8E8E93`) under the standing contrast ruling. Disabled annotations retain drawn dimming. All new picker-screen visuals and motion still need implementation and Aedwon's visual acceptance; no screenshot or autonomous visual review was performed.

## October 14: resumed Task 3 UI draft and remaining review correction

Task 3 core is committed at `15325e0465e2581171180fdb5b89325d159d76ab`, reviewed and uploaded by the lead through #9562. Task 2 partial is `0ad018fe64678a26ae8e35af665de5e94c79c45b`. This entry supersedes the prior UI-not-implemented status without rewriting that checkpoint. The new picker UI, production route, ordered persistence and shared opt-in extensions now exist as a dirty draft. No Task 3 UI commit or whole-family acceptance yet.

On this resumption, fetched current main `eaa9c924cb415bd508b44afaaccbbca08ea586c4`; retrieved AGENTS.md first, then WORKFLOW.md and SUBAGENTS.md in full, startup and linked workflow instructions, current L2/L3 W4d, amendment spec, strategy and collision map. Policy blobs remain AGENTS `3bdc2905aa3c2eb85f6280947528969464d379a3`, WORKFLOW `f4f2415256b8afbb5715d850a4b588c169d2d48c`, SUBAGENTS `b539ba3da0255d6272486d147fa8b4c80050482d`. Fetch, branch and remote inspection confirmed assigned local and remote HEAD both `15325e0465e2581171180fdb5b89325d159d76ab`; all 12 source hashes in #9623's `logs/W4d-task3-current-identity.json` matched before editing. No unexpected drift, merge, reset, generated file or dependency change. Aedwon said "continue" through the lead. The relay runner is offline; the lead recorded and authorized native execution in this isolated worktree. No relay request is queued and no service was changed.

### Implemented draft scope

- Production Customize route now consumes the new picker. It restores only current eligible lessons, preserves real caps, saves picks and atomic length/adjustments in order, prevents duplicate launches, waits for pending saves, retains picks on a failed launch, and retries the actual launch. Returning from a run refreshes pace and pool data. An in-progress pace refresh retains the picker rather than replacing the whole screen.
- ScopePicker is reused. The picker opts into the drawn 13-point check while existing callers retain 14. The fixed header uses the board's 28-point title and measured navigation positions. Floating bar uses the drawn picked/size lines, downward caret, pill, 44-point Start and .35 solid disabled state. At 200% text the bar stacks its controls to prevent overlap; phone visual acceptance remains pending.
- How long? uses W2 PantasSheet, ValueWheel and SegmentedSwitch, the drawn figures and separator, grouped topic metadata or individual lesson rows, scrolling count list, bounded steppers, Reset and struck/disabled invalid times. Shared PantasPage header metrics, PantasButton disabled opacity, SegmentedSwitch optional unselected weight and ScopePicker optional check size extend W2 in place under the standing W4h ruling. Existing defaults remain intact and covering tests run.
- L3 clarifications 4/5: mode matching evaluates actual capped destination totals, deterministic lower-wheel ties; nonpositive stored pace uses the approved initial 50 seconds consistently before division. Positive measured pace remains measured. Provider documentation now agrees with D-166 and no longer suggests hiding initial estimates.
- L3 clarification 6, recorded at `d77df3bd` before implementation: a positive nonempty estimate rounded to zero displays `<1` / `minute` in the existing derived figure and `under 1 min` in the footer. Core duration stays zero rounded minutes without clamping. Empty picker keeps its approved helper; Total time retains its selected budget. Regression covers 3 questions at measured 5 seconds, ordinary estimates, empty estimates and a fast measured Total-time request.
- QZ_Picker timeline: scope data saves immediately, while presentation holds its prior footer for 200 ms after a selection. Footer/Start change at that boundary and Clear fades linearly for 200 ms. Existing W2 check pop is 220 ms, caret 300 ms and unfolded list 600 ms. Reduced motion immediately shows endpoints; timers cancel on leaving and exam/context changes. Finger circles and replay holds are excluded. Main-board outline/timeline outputs and hashes are in `logs/W4d-task3-board-*`.

No schema, synchronization, security path, per-answer response-time or attempt-write change. The previously verified seven-day recency supplement, pool top-up, mixing, passage grouping and session ordering remain intact.

### Draft defects, RED evidence and corrected checks

Full raw outputs remain under `logs/W4d-task3-*`; relay numbers below refer to actual completed results, not inferred issue closure.

- #9563: page extension RED required the missing titleStyle contract. #9566: first UI load exposed missing Material ancestor and 30 versus drawn 28-point title. #9567 introduced a syntax error; outer wrapper exit 0 did not mean success: inner format exited 65, tests 1 and analysis had 94 findings. Corrected in #9568; 6 passed, 2 failed on large-text navigation and offscreen test tap.
- #9569: route/persistence/start regressions 7 passed, 4 failed; fixed Total-time caption, large header and test pumping. #9570: 18 passed, 34 owned style notices. #9573: 19 passed, 1 failed on binary rounding of 333 minutes to 5.5 rather than 5.6 hours. Explicit tenths fixed it; #9574 had 21 passes. #9576 Retry RED exposed saving instead of retrying launch; #9578 had 967 applicable passes and clean owned analysis.
- #9580 board RED caught navigation offset and an unsupported PICKED label. #9582 corrected board metrics, inline metadata, summary divider/rows and Adjust. #9584 empty helper/caret RED led to #9586: 19 passed, 2 failed at 200% bar overlap. #9588 responsive bar had 21 passes. #9591 broader scope: 984 passed, owned clean; global analysis only the explicitly accepted W4c bookmarks deprecation.
- #9592 zero pace RED reached Infinity.floor. #9593's temporary guard was superseded by later recorded rule 5; do not treat that old behavior as accepted. #9597 reconciled main `94cf8ea588fa6f148da78b58cba67c49d04b1394` and matched all eight then-existing UI hashes. #9599 rule4/5 RED covered zero/negative estimates, unbounded budgets and wrong capped matching. #9601: 79 passes, 31 style notices; #9605: 79 passes, one long comment; #9607 owned 11 clean.
- #9613 filter matched zero tests, exit 79, so it proved nothing. #9614 real motion/glyph RED: 2 failures, footer stepped immediately and glyph was 14 instead of 13. #9615: 89 passes, one redundant linear-curve notice. #9617 weak refresh test did not trigger a new provider read; #9618 exposed that test assumption. #9620 confirmed actual pending refresh and missing retained UI. #9623: 91 focused passes, one owned test cascade notice at line892; format1459 unchanged, layering/attribution/diff exit0. That checkpoint was preserved without a UI commit.
- Native rule6 RED: `logs/W4d-task3-rule6-red.txt`, exit1, missing `3 questions · under 1 min`. First GREEN: 93 passed, one test failure because the empty picker intentionally cannot open How long? Corrected the test assumption, retained empty helper coverage and added core empty/positive regressions. Also corrected the existing cascade notice. Final focused command/result: `logs/W4d-task3-rule6-final-commands.json`, 96 passed, exit0; owned12 analysis `No issues found! (ran in 1.4s)`, exit0; format `Formatted 1459 files (0 changed) in 1.39 seconds.`, exit0; layering `check_layering: OK`, attribution `check_no_ai_attribution: OK`, diff exit0.
- Native completed broader task checks: `flutter test --no-pub test/features/quiz test/features/review_prompt test/app test/core/ui/components --reporter expanded`, `00:44 +1007: All tests passed!`, exit0. `flutter analyze --no-pub lib test tool`, exit1, exactly one accepted preexisting W4c bookmarks onReorder deprecation at238:21; `1 issue found. (ran in 3.8s)`. Exact argv/results are `logs/W4d-task3-ui-complete-commands.json`; matching 12-source hashes/base/policy are `logs/W4d-task3-ui-complete-identity.json`. These checks precede the following new RED finding and are not a Task3 completion claim.

### Open review correction before saving

The lead identified a capped-pool repeated-toggle drift. A real UI regression reproduced it: pools `[24,2,13]`, measured `70000` ms, Questions wheel13 starts28 total questions. Four mode switches persist `[45,12,40,11]`, failing the stable expected `[45,13,45,13]`. `logs/W4d-task3-toggle-drift-red.txt`: exit1, `+0 -1`. L3 rule4 already requires toggles to settle; the simple successive-current-total conversion violates it. No production fix or Task3 save followed this RED result yet. The lead will record the technical amendment before affected code. The pending regression remains dirty.

### Contrast changes and acceptance still pending

The meaningful How long? handle uses existing controlOutline (light `#8A8A8E`, dark `#8E8E93`) instead of board `#D1D1D6` under standing ruling1. ScopePicker caret change is recorded above. Disabled Start retains the drawn .35 opacity exception. No wrong-answer contrast acceptance is implied.

Task2 remains partial: shared Home Reviews/New questions sheets and their opening controls/chevrons are omitted; empty New questions ring metric and Task4 session metadata remain pending. Tasks4–9 and live question/viewer report wiring have not started. No backend sender or deployment. Full Flutter suite, whole-family checks, independent/Astra review, integration and Aedwon's phone visual/motion acceptance remain pending. No browser control or screenshots occurred.

## October 14: Task 3 implementation checkpoint after scoped review corrections

The preceding open conversion finding is now fixed under main L3 clarification7, recorded by the lead at plan `7884deaa` / log `775960d6` before production changes. The screen retains the original actual aggregate count as transient conversion state across mode-only changes. Selection, wheel, manual allocation and Reset clear it; material selected-pool availability or effective-pace changes clear it. Destination matching still evaluates real capped totals with deterministic lower-wheel ties. No preference schema or additional stored history. Actual reproduction now stays `[45,13,45,13]`; each of six invalidators has a meaningful widget test. RED invalidator run: 4 passed,3 failed. GREEN: `00:01 +7: All tests passed!`, exit0, owned2 clean. Commands and logs: `logs/W4d-task3-target-green-*`.

Renewed broad Task3 scope after that production fix: `00:46 +1014: All tests passed!`, exit0; owned12 `No issues found! (ran in 1.4s)`, exit0; global analysis only the same accepted W4c bookmarks notice, exit1; format1459 unchanged, layering/attribution exit0. Source/argv/results are `logs/W4d-task3-ui-target-final-identity.json` and `logs/W4d-task3-ui-target-final-commands.json`. The first log name accidentally collided with six committed core-result files. Those six were restored byte-for-byte from HEAD, and the new outputs were moved to the unique ui-target-final names. No core evidence was lost. That run's whole-tree diff check returned2 because newly written analysis output had trailing spaces; the source-only check was clean. Exact raw output is retained in gzip companions where trailing-space normalization is needed for Git.

The lead's second scoped finding concerned owned async states. Existing W4h patterns were read from the assigned branch and main L3-W4h, then current main L3-W4d clarification8 (blob `db42461d58ad09782bc172f80d559e65075642d0`) was retrieved before production repair. Four real RED tests exposed an immediate spinner, local load/save patterns, and local Retry. The picker now reuses loadingFor, errorFor('picks', retry), saveFailureLine and W2 StateView with the recorded launch copy "Could not start your quiz.". Retry invalidates index, pace and saved picks together; save retry retains the real input and writes it successfully; launch retry starts the actual run. Diagnostics never appear in UI. Normal picker/bar geometry stays intact. Loading announces immediately, shows shapes only after300ms and removes them on completion. Background pace refresh still retains existing picker data.

The first shared-state GREEN command accidentally named nonexistent loading_state_test.dart and left a semantics handle active until too late in test teardown: 58 passed,2 failed. The path was corrected to existing state_patterns_test.dart/states_completion_test.dart, and the handle is disposed in the test's finally block. These were test execution defects, not accepted failures. Final affected state command: `flutter test --no-pub test/features/quiz/presentation/practice_picker_screen_test.dart test/core/error test/core/ui/components/state_patterns_test.dart test/core/ui/components/states_completion_test.dart`: `00:04 +73: All tests passed!`, exit0. Owned screen/test analysis clean. Exact commands/results: `logs/W4d-task3-shared-states-final-commands.json`.

Final static checks against all12 source/test paths: owned `No issues found! (ran in 1.5s)`, exit0; global `1 issue found. (ran in 2.9s)`, exit1, solely the recorded bookmarks deprecation; `Formatted 1459 files (0 changed) in 1.38 seconds.`, exit0; layering `check_layering: OK`, exit0; attribution `check_no_ai_attribution: OK`, exit0; source diff exit0. Exact current source hashes/base/policy/plan are `logs/W4d-task3-ui-checkpoint-identity.json`; exact argv/results are `logs/W4d-task3-ui-checkpoint-commands.json`. The 1014 broad tests were not repeated after state-only repairs: the affected screen, helper and loading/error component checks were renewed, along with all static gates. This scopes existing evidence to the actual changed behavior under SUBAGENTS Part5.

Task3 picker/core implementation is now ready for the lead's review and working-branch saving. It is not independently accepted, integrated or visually accepted. Task2's missing Home contract and Task4 metadata remain pending; Tasks4–9 remain to execute. The old picker remains as unused compatibility source until Task9 deletes it. Full family acceptance and required full-suite checks remain pending. No browser, screenshot, deployment, push or merge. New log plain-text copies trim only trailing whitespace; gzip companions preserve original bytes. A manifest binds every newly saved evidence artifact and the12 sources for handoff.

## October 14: selected sizing-tab review correction

The lead inspected immutable Task3 checkpoint `c140d5f24097c2337f775500a8fba703a5ec19c2` and requested a bounded correction before upload. Current main policy and startup were retrieved again; AGENTS/WORKFLOW/SUBAGENTS remain the same blobs recorded above. Fetched policy revision `33889da128bf26ca9b589cc7c63cf9c73b664d2e`. Local HEAD c140 and remote15325 match the explicit upload hold, and the assigned tree was clean before editing. Current L3 rules3/4/7 were read against actual picker and shared SegmentedSwitch source. Existing board geometry and motion inputs remain unchanged. Authorized native fallback continues while the relay is offline; no pending relay requests.

Actual UI RED: a Questions-mode row changed from10 to11 by its stepper; tapping its already-selected Questions tab silently changed the base wheel10 to11. Total-time adjustments7+5 were erased by tapping the already-selected Total time tab. `flutter test --no-pub test/features/quiz/presentation/practice_picker_screen_test.dart --name 'selected Questions tab|Total time redistributes'`: exit1, `00:01 +0 -2: Some tests failed.` Actual expectations were base10 versus11 and adjustments7+5 versus an empty map. Full output: `logs/W4d-task3-selected-tab-red.txt`.

The picker callback now returns immediately for the currently selected mode. A real mode change still performs equivalent-size conversion and clears overrides. The shared SegmentedSwitch defaults and behavior stay intact. Two owned source/test files only; no data contract, storage schema, dependency or visual change.

Focused picker/core/shared-scope checks: `00:04 +107: All tests passed!`, exit0. Layering `check_layering: OK`, attribution `check_no_ai_attribution: OK`, diff exit0. Initial owned analysis found one80-character comment created by the callback's deeper indentation. Shortened that comment only; renewed owned analysis `No issues found! (ran in 1.5s)`, exit0, and format `Formatted 1459 files (0 changed) in 1.46 seconds.`, exit0. The107 tests were not repeated for this comment-only correction. Existing1014 broader and73 shared-state results remain applicable to their unchanged behavior; no new full-suite claim. Exact commands/results and before/after-comment source hashes: `logs/W4d-task3-selected-tab-commands.json`, `logs/W4d-task3-selected-tab-style-commands.json`, `logs/W4d-task3-selected-tab-identity.json`, `logs/W4d-task3-selected-tab-final-identity.json`. Raw gzip companions preserve output bytes where plain copies trim whitespace.

Task3 remains an implementation checkpoint pending lead/Astra/independent and phone visual acceptance. The worker holds before Task4 under the lead's instruction. Home controls, session metadata, remaining family tasks and full-family checks remain pending. No push, integration or publication.

## October 15: Task 4 review-batch proposal for lead ruling, not implemented

Read main clarification9 at `9c0e6747ba2bfca44a9b6c8a432ea863e705063a` / log `c5a49a77` before proposing metadata. Numbered batches are Today's Reviews only. Custom quizzes and all other origins keep their actual whole-quiz session. The current mixed Today selection must not be relabeled as Reviews. Missing W4b Home review launch remains a contract dependency; independent question interaction work proceeds.

Proposed bounded storage contract for review-specific launch, subject to the lead's technical ruling:

- Reuse the existing app database `devicePrefs` table, owned quiz repository transaction and ordinary `quizSessions` rows. One versioned key `quiz_review_batch.v1.<userId>.<examId>` per local execution user/exam, containing JSON with schemaVersion1, batchId (first real session UUID), stable account principal identity, userId, examId, captured local day, captured sessionLength, immutable ordered question-id chunks, immutable generated session IDs for those chunks, and current ordinal. This is client-local execution metadata, not a SQL schema bump, synced payload or changed questionIdsJson encoding. Every session row keeps its existing question-id array and outcomes format.
- Only a new review-specific preparation supplies the actual ordered due-review membership. Split once using the captured setting, preserving existing passage grouping rules and recording the resulting real chunks. All-due means one chunk. Do not derive a total from remaining due count or reuse the truncated mixed Today plan. Question IDs, chunks and ordinals become immutable for the batch; changed preferences apply to the next batch. The lead must settle any passage-versus-hard-session-cap conflict before that split code.
- Creation: in one existing app-database transaction, verify the existing launch canPersist guard and current account-lifetime stamp, close the prior open session under normal rules, write batch metadata and create its first ordinary session row. Failure/cancellation rolls back both. Generate ordinary IDs before this transaction; no new identifier service. Existing metadata is replaced only after the prior batch has finished or been explicitly discarded under the same lifecycle.
- Completion: keep the existing Attempt plus session completedAt transaction. In its existing completion callback, validate that metadata's current ID/chunk exactly matches the completed row and capture its next ordinal in the same transaction. Leave the next session uncreated until Start Session N or the review-specific Continue action claims it. Repeated completion is idempotent and cannot advance twice. Preserve ordinary streak/notification effects after commit.
- Next: one guarded transaction verifies the same account principal, anchor row, exact previous completed session/ordinal and absence of another active batch session, then creates the preassigned next session row and updates the ordinal. Concurrent claims return the same active row. Do not call generic create in a way that silently quits a different active custom/lesson session. Respect the existing paused-session conflict gate.
- Resume: ordinary active-row resume remains authoritative. Only when that row's ID, exam, user, origin and question IDs exactly match the batch entry may UI show its ordinal/total. A completed previous row plus valid next-ready batch supports review-specific Continue after an app restart. No reselection, reordering or renumbering on preference/day changes; active captured membership remains until finish/discard. Verify content hydration preserves membership; missing/changed questions need the lead's failure/repair ruling rather than silently shrinking/renumbering.
- Account and reset boundary: inspect existing AuthState principal and preparation stamp's accountLifetimeToken before awaits and persistence. Store a stable principal identity for restart validation; do not persist the in-memory generation suffix as a permanent identity, because todayQuizPreparerProvider resets that counter on recreation. Use the full existing lifetime token as the runtime stale-operation guard. `SyncLocalStateWiper.wipeAll` deletes quizSessions but intentionally retains generic devicePrefs. Therefore a missing batch anchor row or mismatching principal invalidates and lazily deletes the metadata before any use. Every read checks the live anchor row in the same DB transaction. This also covers fresh/reset state that clears session rows without assuming a generic preferences wipe. Exam-specific metadata cannot resume another exam.
- Malformed/legacy: bounds/type-check JSON, unique IDs, nonempty chunks, valid ordinal, expected user/exam/principal, and matching authoritative session row. Never expose malformed values as student figures. A preexisting ordinary session without metadata keeps its existing resume behavior and shows no invented Session N of M. A malformed record cannot create a next session; retain valid authoritative active-row progress and report a generic shared failure with diagnostics outside UI. Delete unusable orphan metadata when its anchor is absent.
- Cleanup: remove terminal batch metadata in the final completion transaction and discard metadata in the same quit/discard transaction. A later review-specific create also removes orphan/terminal metadata for that user/exam, so there is no permanent batch history or unbounded per-session key set. No account-wiper/security-path edits. Tests must cover atomic rollback, duplicate create/complete/next, restart/resume, setting changes, account-token changes during awaits, retained prefs after wipe, wrong exam, malformed/legacy metadata, missing content, and final/discard cleanup.

This proposal is not an implemented or accepted storage contract. The metadata path stays held pending the lead's recorded decision. Current independent drafts contain only controller pick/check behavior and question-screen RED tests plus board logs.

## October 15: Task 4 verified controller slice, question screens still dirty

This entry supersedes the prior proposal's held status without rewriting it. The lead accepted the bounded Reviews-only contract before affected code at plan `a15be182003dde63d2f035bb3ab01d8ce17e232d`, Home consumer `1e1c8f7c`, collision map `d45e92e2` and log `d03f0c9e`; current L3 blob `e4e9a7661866cbd11eb0cf72417443887e568354` was read in full. It requires actual packed chunks under the existing whole-passage hard-cap rule, immutable captured membership/settings/versions, guarded atomic ordinary-row lifecycle and completion inside saveAtomically/completeRequired, stable principal plus runtime guard and anchor validation, strict legacy/malformed/content handling, and cleanup. No metadata model, parser, storage, launch or caller code has been implemented. Custom/other origins stay unsplit. The standalone review-specific contract is the next data slice and must be verified and reviewed before dependent integration; no SQL schema, stored JSON encoding, sync or wiper change.

On resumption, AGENTS.md first and current WORKFLOW/SUBAGENTS/startup were retrieved from GitHub main; governing blobs remain the same recorded versions. Main fetched at `fddda45d13308e797881f34db394741c15f10395` (policy `1e0ecb27`, status renewed by the lead). Local and remote branch both `c94868eb412be4b6320089429c688d294f8afbe4`; assigned branch/worktree matched, no staging/commit or unexpected drift. The tracked lib/test patch SHA256 matched the lead's `aef2795d10ca05d40a992f3802b435dd3311676f37f6be99385190933207f920`. Aedwon now explicitly prefers direct local Mac checks. No relay or hosted Actions request, service change, browser control or screenshot.

### Verified and scoped for this save

Only `lib/features/quiz/presentation/quiz_controller.dart` and new `test/features/quiz/presentation/quiz_pick_check_test.dart` are the source/test save. The running state carries a transient selected choice and in-flight Check flag. Pick validates readiness and the actual choice, can change before Check, and never writes an answer. Check alone invokes the existing SubmitAnswer path with the existing question, response timing, session/user/exam/origin arguments, and then records the returned outcome while staying on that question. Repeated Check/pick during a pending submission cannot write twice or change that submission. A failed Check preserves the choice and permits retry. Checked questions stay immutable. A late result cannot replace a reset/new session. The old answer method forwards through pick/check for the still-committed legacy renderer; its readiness errors remain compatible. Existing per-answer review state/log/session writes and attempt completion remain unchanged.

The lead's early source review found that the draft read StateNotifier.state before checking mounted after await and inside catch. Two actual disposal regressions failed: late success accessed disposed state; late error replaced the original error with the disposed-state error. Guards now check mounted before either state read. Late success makes no state access; late failure preserves the original error. Existing single-submission behavior remains intact. The new tests cover both outcomes with the actual ProviderContainer/controller disposal lifecycle.

### Actual checks and identity

- Initial core RED: the new pick/check/selectedChoiceId/checking API was absent, test load exit1. `logs/W4d-task4-pick-check-red.txt`.
- Initial core GREEN: 11 controller/start/readiness checks passed, exit0. `logs/W4d-task4-pick-check-green-1.txt`.
- Disposal RED: `flutter test --no-pub test/features/quiz/presentation/quiz_pick_check_test.dart --plain-name 'disposed pending Check'`: `+0 -2`, exit1, actual disposed getter errors. `logs/W4d-task4-disposed-check-red.txt`.
- After guards: combined new controller/screen focused run16 passed, exit0, without hit-test warnings. This was not the whole screen task.
- Broader core-only applicable tests: `flutter test --no-pub test/features/quiz/presentation/quiz_pick_check_test.dart test/features/quiz/presentation/quiz_controller_test.dart test/features/quiz/presentation/quiz_controller_today_launch_test.dart test/features/quiz/domain/use_cases test/features/quiz/data`: `00:02 +106: All tests passed!`, exit0. Analysis at that checkpoint had one owned test cascade notice; format/layering/attribution/diff exited0. Exact commands/results/hashes are `logs/W4d-task4-core-final-commands.json` and `logs/W4d-task4-core-final-identity.json`.
- Resumed fix: combined the two sequential test picks into a cascade only. Renewed controller/start/readiness tests: `00:00 +13: All tests passed!`, exit0. Owned two-file analysis `No issues found! (ran in 1.5s)`, exit0. Scoped format `Formatted 2 files (0 changed) in 0.01 seconds.`, exit0. Layering `check_layering: OK`, attribution `check_no_ai_attribution: OK`, scoped diff exit0. The106 tests were not repeated for a test-only cascade. Exact current source and separate UI-draft hashes: `logs/W4d-task4-core-resume-identity.json`; exact argv/results: `logs/W4d-task4-core-resume-commands.json`.

### Preserved screen drafts, not part of the source save

The dirty renderer and shared grid plus new screen tests remain unstaged: `lib/features/quiz/presentation/quiz_page.dart`, `lib/core/ui/components/new_design/question_grid_sheet.dart`, `test/features/quiz/presentation/quiz_question_screen_test.dart`. Their exact SHA256 values are recorded in both core identity manifests. The draft reuses W2 ChoiceRow, QuestionCard, AnswerReveal, FloatingBar, QuestionGridSheet, Toast and CenteredDialog, preserves the prior question prepaint structure, adds the report entry, read-only revisit with retained frontier pick/timing, system back handling, flag timing and long-grid current-position scroll. These are unaccepted drafts, not a completed Task4 UI.

Screen RED initially failed to load because test imports omitted ContentRepository/Question/Choice/Topic; after correcting test imports, actual UI RED had9 failures against the old screen. First GREEN9 passed with missed-tap warnings because the test selected an invisible prepared question. Tests now target hit-testable choices;16 combined controller/screen tests passed without warnings. Long-grid/current-position and flag timing RED added2 failures; their GREEN plus shared grid-state checks had15 passes. The draft flag follows the520ms two-part scale and200ms toast delay; toast exits through the existing300ms fade. Shared grid handle uses controlOutline under the standing contrast rule; its current cell scrolls into view. All phone visual/motion acceptance remains unverified.

The broader screen-affected draft command `flutter test --no-pub test/features/quiz/presentation test/features/quiz/domain/use_cases test/features/quiz/data --reporter expanded` failed: `00:12 +269 -12: Some tests failed.`, exit1. Exact raw output `logs/W4d-task4-affected-draft-3.txt`. Failures: chrome tests for outermost flag, 48dp counter, flag semantics and continuous rail; Leave refreshing Resume; page tests for first question, topic-scoped quick start, quit confirmation, submit/reveal, invisible next preparation, resumed next preparation, and Today retry. These are unresolved affected tests, not an accepted baseline. Last five-file analysis had117 findings, including trailing-comma/style notices; it is not clean and is not part of this controller save. A dart fix invocation with multiple files was invalid (exit64); later mechanical core fixes were run file-by-file. No source was changed by that invalid invocation.

Next: fix and verify screen draft behavior/semantics/fixtures, remaining owned style issues, answer/flag/Next failure recovery, long content/figure/lesson-scale/report coverage and exact board metrics. Implement the approved review-batch standalone contract with required atomicity/boundary/content tests. Then finish caller wiring when Home contracts reach the branch. Do not claim full Task4, whole-family or visual acceptance from the controller slice. Tasks5–9 remain pending; Task2 Home controls and session metadata remain explicitly pending. No own push, merge, deployment or publication.

## October 16: Task 4 standalone Reviews storage contract

### Resumption and scope

Current main policy was fetched at `9302090068b00b1cc5ecb0b8136674fb0f3f9efa`. AGENTS, WORKFLOW and SUBAGENTS were read from that revision, together with startup, current STATUS, L2/L3 W4d, the parallel map, amendment, strategy, W4d evidence and later W4d rulings. Policy blobs remain AGENTS `3bdc2905aa3c2eb85f6280947528969464d379a3`, WORKFLOW `f4f2415256b8afbb5715d850a4b588c169d2d48c`, SUBAGENTS `b539ba3da0255d6272486d147fa8b4c80050482d`. The October 15 storage contract and disabled-label ruling control this work.

Aedwon's assignment starts: "Resume the Pantas engineering restart and continue **W4d Task 4 only**." Its completion boundary is: "When Task 4 is complete, stop and report the exact commit SHA, tests/checks run, remaining blockers, and confirmation that Task 5 was not started." Local Mac execution is explicit. No relay, hosted Actions, Astra audit, integration, deployment, release, screenshots or visual acceptance was performed.

Initial reconciliation found the expected linked worktree `/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w4d-r1`, branch `web/new-design-w4d-r1`, local HEAD and remote both `ae4947ac7fc7f2340da483d46856d9f65222a72d`. The verified controller commit and every earlier task remain intact. Ten preserved screen/shared/test hashes matched `W4d-task4-ui-final-identity.json`; the eleventh, the question-screen test, had one later compact 200% RED regression already represented by `W4d-task4-compact-revisit-red.txt`. That test was preserved and repaired. No reset, rebase, cleanup or other worktree edit occurred.

### Public contract and ownership

Owned storage/API slice, separate from caller integration:

- `ReviewBatchScope`: execution user, exam, stable principal and the existing account-lifetime token. The token guards in-flight work and is never stored as a permanent identity.
- `PreparedReviewBatch.fromReviews(scope:, preferences:, localDay:, orderedDueReviews:)`: caller supplies the actual review selector's ordered membership. This is a binding input precondition. It does not accept a due count, manufacture historical sessions, turn the truncated mixed Today plan into Reviews, or select new/weak questions. It captures immutable grouped chunks and excluded oversized-set IDs. It preserves supplied order after the existing stable whole-passage grouping, packs under the hard selected cap, closes shorter chunks when needed, excludes an oversized passage set, and produces one actual chunk for All.
- `quizReviewBatchRepositoryProvider`: supplies `ReviewBatchRepository` with the real stable auth principal and the same runtime generation used by `todayQuizPreparerProvider`. Unknown/signed-out auth cannot establish a Reviews principal; known exam mismatch cannot claim another exam. The preparer exposes its existing token through an optional reader, without a second generation counter.
- `start(prepared:, content:, now:, canPersist:)` and `continueBatch(scope:, content:, now:, canPersist:)`: return `ReviewBatchSession?`. Null means stale/canceled work or an empty new preparation. A returned result exposes the actual ordinary `QuizSession`, one-based ordinal, and actual chunk total. Existing active membership/settings win over a newly supplied preparation. Next stays uncreated until an explicit start/continue claim. Concurrent duplicate claims return the same stored row.
- `discardBatch(scope:, now:)`: explicit guarded Reviews discard, including between chunks. It never quits an unrelated ordinary session. Malformed metadata can be explicitly removed without changing valid ordinary progress.
- `QuizSession.reviewBatch`: transient `ReviewBatchPosition` with batch anchor, execution user, ordinal and total. Ordinary resume restores it only from validated metadata. Record/advance/completion retain the snapshot after terminal metadata deletion. Legacy/custom sessions retain null and receive no invented ordinal.

The one durable key is `quiz_review_batch.v1.<userId>.<examId>`. It contains version 1, first real session UUID/anchor, stable principal/user/exam, captured local date, length/order, immutable actual question-ID chunks/content versions, preassigned real session UUIDs, and current/next-ready state. Ordinary session rows, questionIdsJson, outcomesJson, schema, synchronization payloads and account-wipe implementation remain unchanged. No generic batching framework or batch history was added.

Creation, metadata, next-row claim and explicit discard use the existing app DB transactions. Completion advances metadata inside AttemptsRepository.saveAtomically / QuizSessionRepository.completeRequired, alongside the Attempt and completedAt. Post-commit streak/notification order remains unchanged. Completion checks the supplied questions/outcomes against authoritative saved membership/versions; retry cannot advance twice. Runtime completion scope is captured before the first metadata DB await. Resume captures scope before its first active-row await and rechecks through hydration/metadata validation.

Hydration preserves exact IDs/order and expected versions. Missing/revised content fails without shrinking, substituting, renumbering or remapping answers. Legacy resume also rejects missing IDs/order instead of silently shortening the session. Existing shared question load/resume failure and retry handling receives these errors. Actual wipe removes the anchor while retaining devicePrefs; next batch use deletes the orphan metadata.

### Root and independent source review corrections

The author and independent reviewer inspected the final storage/lifecycle changes against the approved contract. The independent reviewer did not edit source or perform Astra/family acceptance. Its final result: "No remaining findings in the five corrected boundaries." All 22 combined source/test hashes matched `logs/W4d-task4-final-source-identity.json` at that review.

Corrections were proved with actual failing regressions before their fixes:

- A stale quit of an older session could delete a newer batch's key. Cleanup now requires the batch's current session ID to match the session being discarded. Explicit discard-all and explicit Reviews discard keep their scopes separate.
- A first implementation blocked ordinary custom/lesson creation between completed chunks. Ordinary quizzes can now start, resume and complete while next-ready Reviews metadata remains. Reviews Continue refuses to quit that unrelated active quiz. Discarding that ordinary quiz preserves the batch.
- Anchored principal metadata must remain when another principal tries to use it. It still protects its original principal's authoritative progress. Deleting it would let a later ordinary resume misclassify that row as legacy. Invalid use fails; original-principal return remains valid; actual missing-anchor/wipe cleanup deletes the unusable metadata. Both author and independent reviewer agreed this implements the recorded "only unusable metadata" ownership requirement. Another principal cannot discard the anchored batch or its saved row. No new key, security rule or wiper change.
- Resume and completion originally captured a new lifetime baseline after early awaits. They now retain the original operation scope before those awaits. Both actual regressions now reject the stale work and roll back terminal writes.
- Floating-point schema version 1.0 was accepted by numeric equality. Parsing now requires an integer, alongside strict types, scope, nonempty/unique IDs/chunks, version bounds, valid ordinals, anchor identity and lifecycle validation.

Relevant RED logs: `W4d-task4-review-batch-boundaries-red.txt`, `W4d-task4-review-completion-order-red.txt`, `W4d-task4-review-audit-red.txt`, `W4d-task4-review-discard-owner-red.txt`, `W4d-task4-review-completion-initial-guard-red.txt`, `W4d-task4-review-signedout-red.txt`, and `W4d-task4-review-malformed-discard-red.txt`. Initial storage API RED also exposed a drift/matcher `isNull` import ambiguity. The corrected import was used for all behavioral runs; that load failure alone is not behavioral proof. A missing selected-exam provider import also caused an intermediate failed compilation, then was corrected. Neither failure is an accepted baseline.

Final focused storage/account command: `flutter test --no-pub test/features/quiz/data/review_batch_repository_test.dart test/features/quiz/application/review_batch_scope_test.dart --reporter expanded`: `00:01 +36: All tests passed!`, exit 0, log `W4d-task4-review-final.txt`. Coverage includes hard cap/short chunks/All/oversized passages, frozen settings/membership, duplicate/concurrent starts and next claims, atomic first-create/metadata/complete/next failure rollback, restart, legacy/malformed/revised/missing content, actual wipe with retained preferences, wrong exam/principal/lifetime, repeated principal mismatch/return, first-await resume/completion races, stale historical quit, ordinary quizzes between chunks, explicit discard and final cleanup.

Code generation: `dart run build_runner build --delete-conflicting-outputs`, exit 0, `Built with build_runner/aot in 9s; wrote 1338 outputs.` Existing drift generate_connect_constructor warning remains diagnostic only. No generated file is staged. Exact ignored runtime/content/font/dependency hashes are in `logs/W4d-task4-final-material-inputs.json`.

### Remaining dependency and task boundary

This is the verified standalone storage/API contract, not actual Reviews selector/caller integration or full Task 4 acceptance. The independent reviewer confirmed that the caller-supplied actual ordered due membership precondition is sufficient for this first slice. The Home-owned Reviews launch/Continue/shared controls have not reached this branch. Their actual selector/caller integration and dependent Quiz controls remain listed dependencies, without substitute local widgets or fabricated payloads. Full Task 4 still needs that caller wiring and applicable checks. Task 5 was not started. No end-screen/viewer/flagged-list/family-delete task was implemented. Independent/Astra family review, integration and phone visual acceptance remain separate.

### Final automated verification for the combined Task 4 candidate

The local combined candidate includes this standalone contract and the independently reviewed screen changes, saved in the following separate screen checkpoint. Exact commands, exit codes and raw output are `logs/W4d-task4-final-check-commands.json` and `logs/W4d-task4-final-check-*.txt`. These results apply to the 22 source/test hashes in `logs/W4d-task4-final-source-identity.json`, not to an earlier partial commit by inference.

- Full local `flutter test --no-pub --reporter expanded`: exit 0, `05:41 +4064: All tests passed!`. This includes quiz, review prompt, app, shared UI/theme, storage and sync regression coverage. No hosted Actions, emulator, real release runner, deployment or phone check was run.
- Full analysis initially reported the accepted preexisting bookmarks onReorder notice plus one new missing-braces style info in the completion guard. Wrapped the existing condition/throw in braces only, with no behavioral change. Renewed affected storage/account/completion/controller tests: exit 0, `00:00 +47: All tests passed!`.
- Final owned analysis: `Analyzing 22 items...`, `No issues found! (ran in 1.3s)`, exit 0.
- Final global analysis: exit 1, `1 issue found. (ran in 2.9s)`, solely the recorded accepted bookmarks `onReorder` deprecation at line 238. This is not a clean-global-analysis claim; W4c owns its correction.
- Final format: exit 0, `Formatted 1467 files (0 changed) in 1.41 seconds.`
- Layering: exit 0, `check_layering: OK`.
- Attribution: exit 0, `check_no_ai_attribution: OK`.
- Source diff whitespace: exit 0.

Post-style exact commands/results are `logs/W4d-task4-post-style-commands.json`; final source identity is `logs/W4d-task4-verified-source-identity.json`. Only the braces changed after the full run; the 47 applicable tests and all static gates were renewed. The full suite was not repeated for that style-only change under SUBAGENTS Part 5. New or preserved intermediate failing logs remain diagnostic evidence, not passing baselines. Gzip companions preserve original output where text copies trim trailing whitespace.

Storage source save: the eleven quiz-owned application/data/domain/test paths above, this evidence, and applicable storage/combined verification logs only. Shared screen/button/theme changes remain separate until the next checkpoint. This separation implements the standalone-contract requirement without claiming caller integration, complete Task 4, Astra/family acceptance, integration or phone visual acceptance.

## October 16: Task 4 question-screen implementation checkpoint

The standalone Reviews contract is saved first, alone, at `f88e5af9f2d4a4fed9e1bd976c6e8184d3bf79f1`. This following screen checkpoint preserves and completes the independently buildable question-screen slice. It does not integrate Home callers or begin Task 5.

### Preserved and completed screen work

The preserved draft consumes the controller's explicit pick/Check split. Choice tapping only changes the transient pick; Check alone saves, reveals the explanation, colors the bar, and enables Next/Finish. W2 ChoiceRow, QuestionCard, AnswerReveal, FloatingBar, QuestionGridSheet, Toast and CenteredDialog remain the screen's shared components. There are no verdict words or return-interval promises. W1 lesson text scale applies to question/reveal content. Free/Pro wrong-choice-note behavior, figure, passage, long content, dark mode, large text and reduced motion have automated coverage.

The grid revisits answered questions read-only, retains the real frontier's pick and timing, and returns with the actual "Back to N". Unreached questions stay unavailable outside mock mode. Current-position scrolling works on long grids. Flag state, first-time Undo toast, flag removal, pop/toast delays, report form and recoloring use the existing shared contracts. Failed Check, Finish and flag-preference writes retain retryable intent; retrying a flag save sets the originally requested value instead of toggling it back. X and system back ask the existing Leave question once; leaving refreshes Resume without discarding checked progress. Existing prepaint/readiness/timing behavior remains covered.

The shared button/theme opt-in is exactly the recorded disabled-label ruling: disabledActionLabel light #B8B8BD/dark #5A5A5E, with constructor/copyWith/lerp coverage; optional disabledForeground defaults null and affects ordinary disabled foreground only. Existing enabled/busy/dimmed/default variant behavior remains. W4c's separate neutral variant was not copied or changed.

### Final review fixes and actual RED/GREEN

The preserved compact regression was reproduced locally before source edits: `W4d-task4-resume-compact-red.txt`, 0 passed/1 failed. At 320x640 and 200% text, the fixed horizontal action row left insufficient counter space, a long Back label overflowed, and the grid's unconstrained summary displaced its title. Large text now uses a counter/flag row plus full-width action and allocates the scroll body the bar's real height. The grid header wraps its title and summary. Flag targets retain at least 44x44. Normal-size presentation keeps its horizontal bar. The compact regression now checks targets, non-overlap, navigator/Back semantics, and unobscured scrolled explanation.

Independent review also found that missing/failed passage loading rendered an empty question. Two added actual RED cases (`W4d-task4-passage-retry-red.txt`) now use the shared quiz failure/retry and invalidate the actual passage provider. Retry restores the original question/passage without exposing diagnostics. Combined compact/recovery GREEN: `W4d-task4-resume-recovery-green.txt`, 3 passed, exit 0.

After these repairs, the prescribed quiz/review-prompt/app and affected shared-component command passed 1,050 tests, exit 0 (`W4d-task4-resume-ui-checks.txt`). Final combined full-suite and static results are recorded above: 4,064 tests passed; 47 affected completion/storage/controller tests renewed after style-only braces; owned 22-file analysis clean; global analysis has only the accepted bookmarks notice; formatting/layering/attribution/diff pass. The 11 screen/shared/test files retain the final verified hashes alongside the 11 standalone contract files. Current source and all saved evidence artifacts are bound by `logs/W4d-task4-checkpoint-manifest.json`.

### Contrast, scope and remaining work

The meaningful grid handle uses controlOutline under the standing W4 contrast rule. The disabled Check role is the exact drawn, disabled-control exception from the lead's October 15 ruling. Other shared component contrast behavior remains unchanged. No screenshots, visual comparison, phone motion check or visual acceptance is claimed.

The source save includes only the 11 planned/explicitly extended screen/shared/test paths, the existing W4d evidence and Task 4 logs. Public component extensions stay within the recorded shared ownership; no W4b/W4c/W4e worktree, dependency, schema, sync payload or generated source was changed/staged. Earlier verified tasks and controller commit remain intact.

Task 4 remains open for actual Reviews selection/caller integration and the missing Home-owned Reviews/Continue/shared controls, then their applicable checks. The legacy mixed Today launch is unchanged and is not relabeled Reviews. Dependent Quiz tab session details are not invented. Full-family/Astra review, integration and Aedwon's phone acceptance remain separate. Task 5 was not started; no end-screen implementation, integration merge, deployment or release work was performed.

## October 16: Task 5 standalone shared count-gauge contract

Resumed current-main policy `ae5c09421084c01d854e78150ea2e481afe7e0b2`; refreshed fetch and verified local/remote code HEAD `10045dbd646916e62488d1e37583b3cc6119cb59`, clean before the preserved Task 5 untracked drafts. AGENTS/WORKFLOW/SUBAGENTS are byte-identical to the previously read `63175b4d` policy files; their current-main versions, full current L2/L3 and shared rulings were recovered. Existing application freeze, independent reviews, missing Home contracts and separate phone acceptance remain. No cross-worktree changes, screenshot, relay, hosted CI, push or integration.

The lead's recorded Task 5 ruling authorizes only the additive named `HalfRingGauge.quizCount(correct:, total:)` and covering tests. This save contains that shared slice alone, before consumption by the unfinished end screen. Existing percentage construction, 220x112 geometry, 300–1400ms house timing, percentage semantics, overlay behavior, and default text stay intact.

Count mode uses the actual correct/total and the QV_EndPro arc (264x128, radius108,16 stroke). Its 60pt count rolls vertically in 64pt slots with a24pt /total, starting400ms and ending1600ms with Cubic(.2,.8,.25,1). Label is correct, semantics announce the real correct/total, and0/0 is defined without division. The same existing painter/lifecycle drives the arc. Number slots accommodate text scaling before fitting within the gauge; reduced motion renders the final frame immediately. Updates with unchanged fraction still update count/total. Motion-preference changes retain the displayed count.

Tests were written first. Initial missing-constructor RED is `W4d-task5-gauge-red.txt`. The first layout run exposed an infinite-width OverflowBox; the rolling strip now has its measured finite width. A separate actual RED (`W4d-task5-gauge-motion-red.txt`) reproduced the displayed count resetting when motion was enabled after a reduced-motion frame; the lifecycle now retains the count baseline. Test-harness semantics handles were corrected to dispose before test teardown verification. Intermediate failed outputs remain diagnostic, never a passing baseline.

Fresh final verification (`W4d-task5-gauge-commands.json`, exact raw output in `W4d-task5-gauge-verified-0..5.txt`):
- `flutter test --no-pub test/core/ui/components test/core/ui/theme --reporter expanded`: exit0, `00:24 +533: All tests passed!`.
- Focused analysis: exit0, `No issues found! (ran in 0.6s)`.
- Format2 files: exit0,0 changed.
- Layering: exit0, `check_layering: OK`.
- Attribution: exit0, `check_no_ai_attribution: OK`.
- Scoped diff whitespace: exit0.

`W4d-task5-gauge-manifest.json` binds source/test and evidence hashes, base, tracked patch and the unchanged runtime/content material-input record. Source ownership: shared gauge and its new focused quiz-count test only, plus this existing evidence and applicable logs/board extraction. End-screen skeleton/test remain untracked and deliberately excluded. The larger Task5, viewer/notes, flagged list, deletion, family/Astra review and phone acceptance remain unfinished. No completed-family/full-suite claim.

### Shared gauge independent review correction

Root's scoped review of65f05501 found an Important efficiency defect: the rolling Column built every integer from0 through the real correct count on each frame, even with reduced motion. Custom quizzes retain whole selected pools, so this scaled with quiz size. Actual RED with2400 correct of3000 proved the unbounded child count. The strip now builds only its current number and adjacent numbers (at most4), using one spacer to preserve exactly the same absolute64pt displacement and clipping. No timing, curve, geometry, semantics or setting changed.

`W4d-task5-gauge-bounded-red.txt` records the actual failure. Renewed new+existing gauge tests (`flutter test --no-pub test/core/ui/components/half_ring_gauge_quiz_count_test.dart test/core/ui/components/half_ring_gauge_test.dart --reporter expanded`): exit0, `00:00 +15: All tests passed!`. Coverage includes the large-count final/transition window and unchanged midpoint/final/updates/reduced-motion/percentage tests. Owned analysis: exit0, `No issues found! (ran in0.7s)` (raw output gives actual spacing/time). Source/test/log identities: `W4d-task5-gauge-bounded-manifest.json`. The prior533 affected shared tests remain applicable outside the amended rolling-count loop. No full-family acceptance or upload is claimed.

## October16: standalone truthful flagged-origin contract

Read the lead's current-main `f88ae99a` ruling before changing origin semantics. The new feature-owned `SessionOrigin.flagged('flagged')` uses the existing string column and JSON fields. Generic `StartPractice.fromQuestionIds` and controller callers default to drill; the actual flagged-list launch alone passes flagged explicitly. Existing enum values and legacy drill rows are unchanged. Creation, restart, resume, terminal completion and saved Attempt carry the actual value; flagged remains timed, non-streak practice. The old exhaustive debrief source switch now recognizes the value until Task9 replaces that page. No schema, migration, questionIds/outcomes encoding, sync shape, new history or other-family source changed.

Actual behavioral RED (`W4d-task5-origin-red.txt`) showed the new stored string recovered as today_topic before enum support. New real-database regressions cover explicit/default starts, persisted restart/resume/completion, unchanged drill recovery, non-streak identity and a12,000ms measured average that includes flagged practice. Existing custom-start tests still prove drill. Initial test-harness compilation errors from incorrect recordAnswer arguments were corrected before that recorded behavioral run; they are not RED proof.

Final exact commands/results: `W4d-task5-origin-commands.json` and raw `W4d-task5-origin-verified-0..5.txt`:
- Quiz domain/application/data, controller, flagged-page and metrics checks: exit0, `00:10 +399: All tests passed!`.
- Six-file analysis: exit0, `No issues found! (ran in1.0s)` (raw output retains exact spacing).
- Format6 files: exit0,0 changed.
- Layering/attribution: exit0, `check_layering: OK`, `check_no_ai_attribution: OK`.
- Scoped diff whitespace: exit0.

`W4d-task5-origin-manifest.json` binds the six owned source/test paths and evidence. These are the root's explicitly extended feature-owned files; no generated file is staged. This standalone save does not fix the old flagged-list presentation/undeclared route, implement new Done navigation, or claim Task5/8 complete. Those remain caller work. End-screen component drafts remain excluded from this commit; viewer/notes, report-viewer wiring, flagged rebuild, deletions and final family verification/review remain open.

## October16: end-screen draft preservation at the lead's checkpoint boundary

The lead explicitly requested an immediate checkpoint at87% short-window usage. Source HEAD is `dac15e8d`; the shared gauge contract/fix and flagged-origin contract are saved separately. The current end-screen component and its test remain untracked, unverified and unwired. This commit saves evidence only. `W4d-task5-end-draft-manifest.json` binds their exact current hashes and all draft logs/board extractions. `W4d-task5-end-draft-source.patch.gz` preserves an exact restorable snapshot of the two new files, without committing them as production source.

The draft takes actual session/attempt snapshots and callbacks. It renders the shared count gauge, answer circles, first three mistakes, all-mistakes/all-questions entries, Pro notes invitation/paused line, and guarded next-session callback UI. It shows Review ordinals only from the supplied actual batch position. It does not infer custom/flagged/mixed-Today sources. The new short-duration ruling on current main03242b61 was read and drafted, but its edge implementation does not yet have an isolated pre-fix RED record. Actual completion endpoints remain inputs; no new stored duration or wall-clock calculation.

Actual recorded widget results: `W4d-task5-screen-behavior-red.txt` had0passed/5failed against the empty component. Initial missing-file compile failure was not behavioral proof. The first UI run had3passed/2failed because lazily built notes invitation was not yet in the test viewport; tests now scroll through the real list. Final draft widget run (`W4d-task5-screen-green-draft3.txt`): exit0, `00:00 +6: All tests passed!`. The checks cover real score/time, three-mistake truncation, perfect score, actual-batch ordinal, compact200% text, and stable valid/absent/negative endpoint formatting. They do not establish complete screen/motion/accessibility fidelity.

Scoped analysis is intentionally preserved as diagnostic failure in `W4d-task5-screen-analysis-diagnostic.txt`. The remaining formatting/style issues must be fixed before any source save. No layering/attribution/full-family gate, independent review, app route, caller/Done return-stack wiring, next-batch claim integration, rating-prompt integration, all-questions screen or viewer/notes integration is claimed for the draft. The old end page remains the live application page. No app/route behavior changed from this draft.

Next: finish the existing Task5 draft under the approved boards, add the missing semantic/interaction/motion/dark/large-quiz checks, complete end data and real caller return/batch/rating wiring when internal contracts exist, then Task6 viewer/notes, remaining Task7 viewer report wiring, Task8 flagged rebuild/declared run route, and Task9 retirement/family gates. Home Reviews/Continue/shared-row callers remain absent, keeping Task2/4 integration OPEN. No fabricated Reviews membership or source labels. Main application freeze, independent/Astra review and phone visual acceptance remain separate. No push, merge, screenshot, relay, hosted CI, deployment or cleanup.


## October22: resumed Task5 independent end-body and exact hydration checkpoint

Policy refreshed from GitHub main6de899018f0e2056f0b5880292339779ca0e512a; later Task6 ruling317f256d read before its separate unfinished draft. User resumed existing W4d scope. Code base5e89e4fa matched remote; the two preserved end-screen drafts retained their prior hashes before work. Main's current PWA coordination handoff was read. Missing Home Reviews/shared rows remain dependencies, not fabricated implementations. Root owns shared-card/server integration and STATUS.

This checkpoint saves the end body, its tests, and strict completed-question hydration only. It keeps the approved actual score/count, first-three mistakes/all links, Pro-only notes/paused state, actual Reviews ordinals, immutable completed duration, guarded duplicate next action/retry, dark/reduced motion, normal entry/disposal, and large text. QV_EndFree explicitly contains no notes invitation, so Free has none. Board source overrides the generic plan wording, as confirmed by root. The body is still not the live app end page: real source Done stack, route/viewer/next-batch/rating wiring remain pending. No Task5 or family-complete claim.

Actual RED11365 reproduced both missing and revised original content: the old debrief provider emitted a result instead of rejecting either case. Shared feature-owned hydrateCompletedQuiz now batch-reads existing questionsByIds, reconstructs exact original Attempt order, and rejects unavailable IDs, versions or chosen/correct choice membership. A supplied actual completed session preserves its original question snapshot and batch/lesson metadata. It does not filter by Question.examIds because existing custom exams can draw source questions from other exam pools. No shortened paper, shifted answer, substituted question, schema, stored duration or new student figure. The old debrief provider consumes this helper until its Task9 retirement.

11375 final focused analysis: `No issues found! (ran in 0.7s)`, exit0. Format5 files/0changes, exit0. Quiz/review-prompt/app checks: `00:31 +624: All tests passed!`, exit0. These include 11 focused end/hydration cases. Earlier focused11368 passed9 before added dark/motion cases. Initial new harness compile/style failures and a missing semantics handle disposal were corrected; diagnostic logs are not passing evidence. 11369 layering and attribution both exit0/OK, renewed at scoped save. Full-family combined verification, independent/Astra review, integration, phone visual/live PWA acceptance remain pending.

Task6 repository/test changes and the new unfinished completedQuizProvider are explicitly excluded from this Task5 source save. The suite ran with that known dirty repository draft present; this is focused Task5 evidence, not an independently clean whole-family baseline. Their source identity is captured in the manifest's dirty patch hash and they remain separate owned work. No other family, generated source, screenshot, deployment or publication changed.


## October22: accepted shared neutral button dependency

Root ported only the already accepted W4c c912fb21 neutral variant and its unchanged tests into the current D branch. D's disabledForeground, disabledOpacity and all existing variants remain intact. This is the missing shared contract for the approved viewer note editor, not a local copy or new presentation choice. Relay11378 preserved exact import identity;11380 verified17 neutral/default/disabled/busy button tests, clean two-file analysis, format0changes and scoped diff. Raw commands/output are W4d-neutral-dependency-0..3.txt. No family, viewer wiring, global analysis or phone acceptance is claimed.


## October22: truthful Today figures and withheld launch dependency

Root found that the partial tab substituted every paused quiz's one-based position/total into the Reviews row, including custom/lesson/drill sessions, and called the truncated legacy mixed Today plan Continue Reviews. This contradicts the recorded Task4 split contract. Actual RED11381 reproduced all four dark/large-text paused cases plus the mixed-launch case:10pass/5fail. The tab now always displays actual quizTodayCounts review figures. Generic Resume remains available; its session position never masquerades as Reviews completion.

Per standing ruling2, the misleading mixed Today launch is omitted until Home supplies the actual Reviews/New caller contract. No replacement label, disabled control, synthetic membership or new shared widget was introduced. The drawn Reviews/New launch and sheets remain explicitly unfinished dependencies; this correction does not claim Task2 complete. Source scope is only the tab and its existing test; today_providers did not require a change.

GREEN11384:22 tab/leave-resume/panel tests pass, two-file analysis clean, format0changes. Exact commands/output are W4d-tab-truthful-green-0..2.txt; W4d-tab-truthful-red.txt preserves the actual failure. Scoped diff is clean. Broader family/combined verification, independent review, integration and phone acceptance remain pending.

Evidence hygiene for the root's tab RED: the gzip companion preserves original output bytes; the readable copy trims only trailing whitespace. Root checked the entire committed tab source/test delta and the readable log after normalization. No production source or test behavior changed.


## October23: shared rich question-title contract

Current-main17db830f records this narrow shared ownership before source changes. Root added only optional ListRow.titleWidget; required String title and every default row/variant/geometry/action remain unchanged. Rich consumers supply the existing MathText inside single-line DefaultTextStyle (ellipsis, no wrapping). No new generic row, dependency or feature import.

Initial interface RED11397 proves the old constructor lacks this contract; it is a missing-API compile failure, not a behavioral regression claim. Verification11399 initially stopped on runner rg absence before executing tests. Corrected11403 uses the available Python file inventory:26 shared/default/accessibility/gallery/rich-title tests pass. It found only four test trailing-comma infos.11407 applies those mechanical test fixes, renews all3 directly changed tests and two-file analysis:3pass, No issues found. Formatting is clean. Raw command output is W4d-rich-row-green-* and W4d-rich-row-final-*; gzip companions retain original output if readable copies trim trailing whitespace.

This verified shared slice lands before list consumers. It does not complete Task5/6/8, family review, integration or phone acceptance.


## October23: ordinary quiz routes read current active-exam Pro coverage

Startup policy refreshed from main17db830f931574f38530c51aed37c7d8ba2645e1. Root identified QuizPage's default false Pro argument as the actual cause of ordinary routes hiding paid wrong-choice notes. Production routes omit that argument. It now defaults null and reads the existing proForActiveExamProvider; explicit existing test overrides remain. The real current paused entitlement feeds ProPausedLine at an actual wrong-answer notes gate. Free and uncovered plans keep no notes invitation. No entitlement calculation, pricing, snapshot, server authority or shared defaults changed.

Actual route RED11404 used production quizRoutes and the real entitlement/catalog active-exam coverage chain. Covered CSE failed to show its paid note; paused CSE failed to show ProPausedLine; uncovered Student Pro on CSE correctly hid the note. The earlier11398 harness timed out180s without a saved subprocess tail and is not behavioral RED evidence. Warming the actual asynchronous coverage using tester.runAsync bounded the harness without changing the asserted production route.

11408: route coverage plus existing quiz chrome checks exit0, `00:01 +9: All tests passed!`. Its following analysis found only trailing-comma infos in the new test.11411 applies those test-only commas, then format2files and analysis both exit0, `No issues found! (ran in 1.0s)`. Production source behavior is unchanged from the9 passing tests. Required checks on the completed combined family remain with root. This scoped correction does not complete Task4's missing Home Reviews caller integration, Task5 end wiring, Task6 viewer, family review/integration or phone acceptance.

Source and command identities are in W4d-task4-route-pro-manifest.json. Exact raw log bytes are retained in gzip when a readable copy needed whitespace normalization. Root now owns the subsequent live end-page replacement in quiz_page.dart; this checkpoint releases that file after the bounded gate correction.


Gate-save correction:11413 stopped before staging/commit because the new quiz page and unfinished viewer imported the paywall barrel, which reexports presentation and violates R2.11417 changed those to the existing narrow application-provider and domain imports. The following scoped save renewed the9 route/chrome tests,2file analysis, format, layering and attribution against actual current source. No failing layering result was treated as accepted. The manifest/logs now bind that verified checkpoint rather than the failed save attempt.


## October23: Task8 scoped list and exact-membership checkpoint

The lead owns the list/provider/tests and the flagged-only fromQuestionIds branch under the recorded17db830f contract. The list now uses the approved shared page/group/row/button/state controls, numbered one-line math-capable question rows, actual subject groups and the preserved remove/practice actions. It opens the declared real-question viewer path and starts only the declared practice run path after the controller returns the actual matching flagged session. No Attempt, correctness, note or source is fabricated for an unanswered flag. Root uses actual current AsyncData only for practice controls and shows shared loading/error/retry; no raw diagnostic enters the interface. Global flags remain stored; only actual selected exam/track membership is visible.

The new flaggedExamReviewProvider supplies existing ReviewEntry models, real subjects and required passages. Missing requested content fails recoverably. The flagged start now batches exact IDs and fails before replacing a prior session if any requested flag is unavailable. Generic drill/default callers retain their original behavior. Source-backed regression11409 reproduced a shortened StartPracticeStarted result; the fixed real-DB test proves the previous session remains untouched.

Actual verification: scope RED11396 had2pass/3fail; after scope-only correction11402 isolated3 navigation failures;11405 added the actual shared-error regression (9pass/4fail).11418 passes28 UI/provider/domain tests, including original flagged provenance/default-drill/storage cases and compact320x640 light/dark at100/200percent text. After the narrow current-data loading correction,11420 renews all17 affected UI/provider tests, five-file analysis clean, format0changes, layering/attribution OK and scoped diff clean. Raw output remains in W4d-flagged-* logs; gzip companions preserve original bytes where readable copies trim whitespace.11395 was a setup assertion before any write/test, not RED evidence.

This is a partial Task8 checkpoint, not final family acceptance. Actual production viewer registration and integration remain with the Task6 viewer owner. The existing controller's flagged account-lifetime launch path still needs the lead's bounded guard and tests before Task8 completion. Required full combined checks, independent family review, development integration/upload and phone acceptance remain pending. Home Reviews/New controls remain a separate unavailable contract.


## October23: original-account flagged launch safeguards

Technical ownership and exact guard contract were recorded on maind6a96dc5 before source changes. The lead captured original actual-ready auth, runtime lifetime, database, selected exam and core context token before flagged content waits. The flagged-only predicate checks current AsyncData identity/exam and original token inside the existing write transaction and before success publication. Existing createGuarded now accepts FutureOr<bool> and awaits its same three checks; existing bool callers and default generic drill behavior remain. Hydration stays outside the app write transaction, so an actual wipe can complete while content is pending. There is no schema, new state store or new launch framework.

Actual RED11429:1stable pass/4 failures for account, exam, core-token replacement and real anonymous wipe. The old controller published Running even after the wipe. Actual disposal RED11432 additionally reproduced writing controller state after disposal. The bounded correction preserves previous sessions on stale requests, prevents resurrection after wipe, and avoids disposed-state publication.

11430 passes41 affected real-controller/repository/Today/custom/default-origin checks.11433 passes59 combined affected checks including17 flagged UI/provider cases and all6 lifetime cases. After the last two mechanical test commas,11435 renews the6 changed lifecycle tests; four-file analysis is clean, format0changes, layering/attribution OK and scoped diff clean. Root inspected the actual source and raw output personally. Raw/gzip evidence is W4d-flagged-launch-boundary-* and W4d-flagged-disposal-red.txt.

Task8 still awaits actual viewer route registration and final combined review/checks; no full-family acceptance, upload, development integration or phone acceptance is claimed. The lead proceeds to live end/list/Done/next/rating wiring within the approved Task5 scope.


## October23 Task6 viewer/notes scoped checkpoint

Policy main9cc82ebc, latest status4531ae3a. Root took over the implementor's saved drafts after its usage limit. Completed and actual never-answered flagged viewers now have distinct declared routes. Actual Attempt membership/order/version/outcomes and required passages remain strict; absent content fails recoverably. Pro notes use ready active-exam coverage, immutable original database/runtime/auth/exam/core owner and token, retained across retries. CompletedQuizRequest includes the retained original boundary identity so another account cannot reuse an offstage view's cache. Real account-switch/wipe regression11450 failed before the correction.

Note mutations read the latest Attempt inside the recorder transaction and preserve concurrent other-item edits. Guards run before/after read/write and recorder tail; stale writes and missing/foreign membership roll back. Legacy omitted-note behavior stays unchanged; explicit removal clears tag/note. No schema or sync-shape changes.

One shared frame follows source opening/closing radius/color/size/fade tracks. Stable child width prevents AnimatedSize snapping; reduced motion renders final state. The editor matches selected-dot pop, delayed enabled-action paint and318px existing-note geometry while preserving44px Remove. Saved-note icon follows300ms delay/260ms overshoot/160ms settle; canceled drafts are discarded. Native floating-point color interpolation is compared per channel at1e-9 tolerance instead of exact double/rounding-boundary equality. Root opened actual sources and reviewed the mutation/ownership/route diff.

Relay11462:32focused viewer/editor/provider/boundary/repository/route tests pass; full core storage213tests pass; all14owned files analyze clean; layering and attribution pass. Actual RED logs and exact final output retained. This is an IMPLEMENTED/TESTED local checkpoint only, not Task6/family independent acceptance or phone visual acceptance. Direct viewer Back still depends on planned All questions route, and live end/all/next/Done/rating/retirement remain pending. No application upload, development/main merge or publication.


## October23 Task5 live completion checkpoint

Root owns live completion/All/mistakes/viewer return/Done/rating and explicit next. Current policy read in full; technical amendments on main6c7879e8,9cc82ebc,a0fbda86,2677358b control completed identity, async readiness and hydration boundaries. Original elapsed time/source/outcome/subject/membership remain authoritative; live and historical results consume actual stored Attempts. All/mistakes preserve original paper numbers and actual viewer indices. Rich fallback stems render math. Viewer returns refresh saved notes, and route identity starts a fresh original-boundary lifetime when the paper/query changes.

Fresh custom provenance is the actual picker-launched session ID passed in route extra, matched to the live drill session. It is never inferred from mutable flags or generic restored drill. Custom Done pops its own picker to Quiz; actual flag/lesson/retake return stacks pop to their callers. Historical entries do not ask for ratings. Only a completion observed from that actual live session invokes existing finishedWell/maybeAsk; existing thresholds/store availability/cool-off remain unchanged.

Explicit next retains the completed view through pending/failure. continueBatch optional after validates the authoritative completed row, scope, position, real question/version order and core saved answers; stale Session1 cannot claim Session3. Duplicate immediate-next claims preserve the same row and live picks. Async original auth/exam/runtime/database/core guards surround actual writes and publication. Content loads outside the app write transaction, with immutable target/metadata reread before claim, so actual wiping finishes while content waits. Old requests cannot recreate wiped sessions/Attempts. Existing bool/default start/standalone contracts and metadata schema remain unchanged. Root inspected actual data/controller diff personally.

Pinned Riverpod can retain AsyncData with isLoading:true. Actual paid-reveal refresh RED required unwrapPrevious at owned ready-value reads. The regression pumps the scheduled consumer frame and settles native catalog work with bounded frame/real-I/O polling; expired coverage hides paid notes and restored coverage returns them. Auth/exam/note predicates use the same SDK readiness rule without new state/providers.

Actual evidence:11491 passes136focused cases,11489 passes43batch/controller cases including real wipe,11493 passes11route/telemetry/completed-view cases. Final11494 quiz/review_prompt/app suite: exit0,+692 All tests passed. Its one trailing-comma style finding is corrected; saved static checks analyze18owned files clean, layering/attribution pass. Original full-task failure had two test-contract findings (approved added routes and the existing async createGuarded signature); both corrected and renewed, with the complete692run green.

This is implemented/tested local saving only. Task9 retirement, accepted integration reconciliation, final combined gates and the independent family audit remain. Home initial Reviews/New row/launch contracts remain omitted under standing ruling2. No full-family or visual acceptance, application upload, development/main merge or deployment is claimed.


## October23 Task9 retirement implementation checkpoint

Removed the six replaced quiz UI classes (old tab, results, debrief, picker, panel and wheel), their eight UI-only test files and the three empty review-feature placeholders. The living quiz barrel exports the rebuilt tab/completed/viewer surfaces. Existing redirected legacy paths remain until the assigned W2 route closeout; no old screen serves them. Underlying Attempt/answer/metrics/domain inputs remain intact. Quiz-owned source has no retired InkTableRow, InkCheckbox or showInkSheet caller.

Preserved the meaningful old regressions instead of deleting them with the views: free-standing and six-question passage coverage now exercises the actual completed viewer and its shared passage surface, including navigation with one required passage per viewed question; Leave/Resume refresh exercises the rebuilt Quiz tab and real quiz page/coordinator seam. The first migrated renderer run failed because its lesson text-scale preference store was unstubbed. Supplied the existing real in-memory app database, then verified14cases green. This was fixture correction, not a production failure or fabricated RED.

Relay11499:14preserved passage/leave tests pass, three owned files analyze clean, layering and attribution pass. Saved raw setup failure and final outputs. Retirement source is saved locally; Task9 final combined verification and independent family audit remain due after accepted integration72b04f00 reconciliation. No full-family acceptance, app upload, development/main merge, human visual check or deployment. Home Reviews/New row/launch contracts remain deferred under standing ruling2.


## October23 accepted-dependency combination candidate

Verified D e4de760b and accepted development72b04f00 local/remote heads and clean tracked worktrees before merging accepted development into the D WORKING candidate. Only retained W4d diagnostic logs were untracked. Remote D5e89e4fa and development72b04f00 remain unchanged. This is not promotion of D into the development target.

Resolved seven reported conflicts from both original sources: quiz routes retain the living D tab/picker/end/All/flagged/viewer paths and D ready-native-Pro gate, while preserving all accepted E authoritative server availability/loading/error/upstream retry, server resume/results IDs, 30-day web versus14-day native availability and no-dead-results actions. Shared gauge retains both quizCount and mock constructors, original count/percentage motion, mock external fraction/number/label-opacity semantics and exact geometry. Rich rows preserve accepted W4c rich/value/trailing/footer/layout options plus D titleWidget math fallback. Buttons retain accepted neutral behavior plus D opt-in disabled labels/opacity. Grid retains accepted measured large-text header reflow and D quiz revisit behavior. Rings preserve accepted study/pull shapes and delay behavior plus D optional fill timing. Incoming no-dead-results regression remains.

A clean auto-merge also required initializing D's unselectedFontWeight in W4c's bookmarks-specific switch constructor, preserving its unused default and unchanged dedicated bookmark rendering. No accepted reader or mock feature source was replaced wholesale. Root read both source variants and inspected each conflict.

ContentDatabase schema advanced with the accepted dependency. Immediately after conflict resolution, normal ignored generation exited0: build_runner10seconds,1850outputs. No generated file is staged. Initial analysis found only the switch initializer and one comma; initial shared checks had552passes and four compile failures for that same initializer. Corrected both. Renewed full lib/test/tool analysis is clean; all20affected gallery/switch/MockCard/coverage tests pass. Existing quiz-count/mock/default gauge, ring, row and grid tests passed in the552case run; final full suite will cover the combined exact candidate. No unrelated baseline exception remains.

This local combined source checkpoint is frozen for full required verification and one independent family audit. It is not full-family acceptance, an upload, a development/main target update, a visual check or deployment. Home initial Reviews/New contracts remain unavailable and omitted under standing ruling2.


## October23 independent audit and bounded corrections

Baseline candidate3c64f078 combined accepted integration72b04f00. Full baseline flutter test --no-pub --concurrency=1 exits0,4635passed,09:15,2153source hashes unchanged. One fresh independent Astra family audit found exactly three confirmed issues: P1 custom launch lost original ownership across pending preferences/content; P1 flagged UI captured ownership after pending membership; P2 Quick promised resume but held only memory state. These were not accepted despite green baseline tests. Current main L3 amendmentcc25c01e records correction interfaces before implementation.

Root reproduced each defect before fixing it. Custom guards capture ready original auth/exam/database/preparer-lifetime/core token before UI waits, forward unchanged through existing createGuarded and reject expired results before navigation. Flagged UI additionally validates actual stored flags. Quick uses the ordinary durable session repository with unchanged origin/selector/timing, preserves a different paused session, and publishes persisted state only after original guards. No schema, visual design, new origin or framework. Meaningful Quick fixtures now supply ready ownership and storage; submit mocks assert persisted session arguments.

Targeted evidence: custom controller/domain18, picker44, flagged24, Quick8including real checked answer/reset/resume and preserving paused quiz, existing Quick19, renewed quiz/review_prompt/app668all pass.14owned files analyze clean; full static gates recorded alongside this entry. Root reviewed the data/source changes. Original reviewer bounded verification and renewed frozen-source full suite remain pending. Baseline evidence archived separately and never substituted for corrected acceptance. No upload/development-target integration/main merge/deployment/phone acceptance. Initial Home-owned Reviews/New rows/launch remain unavailable under standing ruling2; report no-op remains recorded.


### Original reviewer bounded verification and UI disposal correction

Original reviewer resolved all three original findings at e4f90cf2, but found one P2 correction-contract gap: controller lifetime did not cancel pending custom/flagged hydration after only the page disposed. Root stopped the incomplete corrected full run (relay11526), preserving its separate output, and amended current main L3 bba1a12f before affected code. Real widget regressions keep ProviderContainer/controller alive, block actual selection/hydration, dispose only the page, create a newer paused session and release content. Both failed because the old launch added a row and quit the newer session (11529). Both now pass with unchanged original owner guard composed with page mounted/original exam/generation before and after its await; the same composed predicate reaches existing guarded persistence.64related tests pass;3owned analysis and full static gates clean. Reviewer closure and renewed full source-hashed run remain pending. No new family audit or product scope.


## October23 final corrected engineering verification and review

Acceptance source a5355077607c80501103c95fb897dc9235cf81d9, containing accepted dependency integration72b04f00. Original independent Astra family audit plus bounded correction verification is closed with no remaining findings: P1 custom ownership, P1 flagged ownership, P2 Quick durable resume and follow-up P2 UI disposal resolved. Original reviewer retained clean detached3c64worktree and performed no edits or second whole-family audit. Root personally reviewed source/data changes.

Final full flutter test --no-pub --concurrency=1 exits0:4653tests passed, no failed groups, started2026-10-23T13:18:05.714048Z and finished13:27:31.586864Z (09:26). All2157tracked non-doc source/config/content file hashes remain unchanged and are rechecked immediately before this save. Exact raw final log, manifest and status archived W4d-final-*.gz. Final full lib/test/tool analysis clean; format1529/0changes; layering/attribution/diff pass. Prior baseline/interrupted runs remain separately labeled and do not establish final acceptance. All known unique W4d diagnostic logs preserved in this evidence directory.

This completes independent W4d engineering/review slices under standing ruling2. Overall W4d remains incomplete until Home-owned initial Reviews/New shared-row and launch contracts land and actual initial caller wiring is completed/checked. No fake or legacy mixed Today substitute. Working-branch upload is authorized for the reviewed verified work; development-target integration remains withheld for that dependency. Phone visual/device accessibility and live/backend report delivery remain unaccepted. No application main merge, deployment/publication or worktree cleanup. Keep the source/review worktrees and evidence for dependent resumption.


Final evidence confirmation from the original reviewer:4653passed, exit0, no failure/error,2157manifest hashes match, no source paths changed, all four findings remain closed. This is bounded evidence confirmation, not another audit or authorization to integrate/publish.


## October23 Today dependency completed and verified

Aedwon: "finish W4d's dependency with W4b so that W4d can finally be completed"; ownership transfer: "yes the previous chat has already stopped due to usage limits. i authorize you to continue". Current main policy d0d1a48f plus later controlling L3 rulings d51f34e/4ea8bb59; prior source eb383634 and accepted development72b04f00 preserved. Root personally inspected the shared data, repository hydration/claim transactions, exact membership, ownership guards and actual caller paths.

The bounded dependency now provides Home-owned reusable Today application membership and guarded Reviews/New starts, plus core row/sheet widgets consumed by Quiz. Reviews uses real immutable chunks/ordinal/answers; New is separate, uses actual plan IDs, retains read/unread ordering and ordinary durable resume/completion. Settings changes do not rewrite an active batch. Both real sheets open/start; Continue uses the actual batch, and unrelated paused work is preserved. New origin retains streak eligibility and truthful source text through completion. No schema/sync payload/backend change, duplicate Home UI or unrelated W4b work.

Independent bounded review identified P1 stale retry boundary recapture and P2 omitted missing Reviews IDs. Real preview-wipe regressions RED11549 and missing-review RED11550; corrected original guard Future stays bound to page/exam/generation/account/core across preview/Continue/error retry. Exact Reviews/New hydrated membership fails recoverably on omission. Immediate Future errors are observed before the builder mounts. Reviewer closes both findings and final mechanical changes with no findings. Existing original family Astra audit remains closed; no second family audit.

Root also finished the explicitly recorded QZ_Resume zero-ring dependency:24px/2px separator/radius11 and no last New-row divider. RED11558 captured prior1.5px chevron/radius11.25; GREEN11559all17ring/default/study/pull/motion cases. Null-default opt-ins preserve existing shared callers. Independent bounded review: no findings. Phone visual checking remains Aedwon's.

Final exact source: cd283f7bb3a3b408e6d4ed821902a93210fb036d. Shared/application/caller commits: 20b418fafd8e6f2f00c27e9b3291d570adab484b, ab0f8ec8fc5a6fad38188064d1f3ec8bccd63bbe, cd283f7bb3a3b408e6d4ed821902a93210fb036d. Relay11556:76focused tests and clean static checks before ring correction. Final relay11560 on frozen2163source/config/content files:4677tests passed, full exit0, actual final summary present; elapsed592.293seconds. All2163hashes remain unchanged. Full lib/test/tool analysis: No issues found. Format1535files/0changes, layering check_layering: OK, attribution check_no_ai_attribution: OK, git diff --check clean. Complete raw logs/status/source manifest/dirty patch archived as W4d-today-verified-final-*.gz. Earlier failed/RED outputs are explicitly diagnostic.11557was deliberately interrupted by root before the fidelity change; Flutter returned0 but no test summary and temporary-file errors, so its separately archived status is explicitly INTERRUPTED and provides no acceptance evidence.

Engineering scope and required review/checks are complete. Normal working-branch upload/development integration follow under standing permissions. Phone visual/device accessibility, deployed/live PWA/backend checks and explicitly deferred report delivery remain separate gates. Main application freeze and release/deployment permissions remain unchanged. Keep source/review worktrees for phone acceptance and dependent W4b work.
