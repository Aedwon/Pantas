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
