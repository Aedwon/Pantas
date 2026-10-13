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
