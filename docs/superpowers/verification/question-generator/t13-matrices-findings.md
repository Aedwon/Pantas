# Task 1.3: figure matrices

## Startup

- Policy: origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, a descendant of required 1295c1866. Read AGENTS.md, WORKFLOW.md, SUBAGENTS.md and process-improvement policy from that ref. `git fetch origin main` failed because the sandbox cannot write the shared Git FETCH_HEAD. `git ls-remote origin refs/heads/main` independently returned the identical commit, confirming the policy ref is current.
- Worktree initially clean. No staged changes or commits authorized.
- Read plan Global constraints, Parts 1 to 3b and Task 1.3; spec Part B; grouping report's figure contract and matrix table; source questions from origin/content/bite-sized-cse-algebra-r1 (88f38e698ee80448fde1a795638f794b68db4cfd).

## Grouping

Each exact candidate has one source at reserved index 0. No questions merge together. Prefixes below are qt-spatial-abstract-reasoning-matrix- and q-spatial-abstract-reasoning-figure-matrices-.

| Source | Candidate suffix | Rule |
| --- | --- | --- |
| 0001 | ray-turn | Equal ray turn across each row |
| 0003 | size-columns | Identical size progression down columns |
| 0004 | size-fill | Size by row, alternating fill by column |
| 0005 | ray-union | Keep both input rays |
| 0006 | fill-union | Combine complementary half fills |
| 0007 | corner-step | Clockwise corner step across each row |
| 0008 | size-dots | Size by row, increasing dots by column |
| 0009 | ray-intersection | Keep only shared rays |
| 0010 | corner-reflection | Reflect the corner dot left to right |
| 0011 | binary-fill-row | Repeat alternating binary fill across rows |
| 0012 | arrow-column | Quarter-turn arrows down columns |
| 0013 | form-ray | Form by row, equal ray steps across columns |
| 0014 | sized-ray-union | Combine rays, increase size down rows |
| 0015 | outline-latin | Each of three forms once per row and column |
| 0016 | dot-sum | Sum the first two dot counts in each row |
| 0017 | size-latin | Shift the three-size cycle by row |
| 0018 | growing-turn | Increase the within-row ray step down rows |
| 0019 | corner-grid | Clockwise corner steps across, counterclockwise down |
| 0020 | size-transfer | Size by row, dots rise and edge lines fall across |

Singles: 0002 has an undrawable six-dot answer choice. 0021 lacks figure data and requires unsupported multiple corner dots. Paper-fold and series 0019 are outside this file.

## Needs the lead

Stopped during contract review, before writing implementation or tests: the matrix 0019 named mistake `wrong-column-direction` does not reproduce its source distractor.

Source last column is bottom-right, top-right, blank. The correct counterclockwise next corner is top-left. Reversing that column step from top-right gives bottom-right, already the `copy-row-start` distractor. The source instead labels top-right as the wrong-column-direction answer, which repeats the cell above. Reversing the whole column from its top cell also cannot give top-right: two clockwise steps from bottom-right end at top-left.

The checker must prove each distractor equals its named mistake, while index 0 must retain the source wrong-choice set. The grouping report calls this candidate exact Y with `wrong-column-direction`. These requirements conflict under that mistake contract. A lead ruling must define a source-faithful mistake (for example, repeat-above) or arrange a source correction through the content approval gate. No source or governing document was edited, and no substitute mistake was silently selected.

No capacity was measured, no type is classified HELD or LIST 100, and no checker result exists. Implementation and all requested verification commands remain unrun because the explicit stop condition was reached before code changes.

## Review follow-up verification

- Reconfirmed policy origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f with live `git ls-remote`; fetching remains blocked by shared Git metadata permissions.
- Review supplied NO FINDINGS and explicitly upheld matrix 0019's blocker. No lead ruling resolves it. Implementation remains stopped under Needs the lead; no finding is rejected. Requested verification proceeds independently of that blocked implementation.
- PASS (exit 0): `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 7.1s)`.
- PASS (exit 0): `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: `Formatted 44 files (0 changed) in 0.10 seconds.`
- PASS (exit 0): `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- Build runner exited 0. Warnings: removed `--delete-conflicting-outputs` option ignored; package language version 3.5.0 versus json_serializable required ^3.8.0; obsolete drift `generate_connect_constructor` option. No dependency or SDK edits made.
- PASS (exit 0): `flutter test test/tool/generator --no-test-assets`: `00:36 +155: All tests passed!`.
- PASS (exit 0): `dart run build_runner build --delete-conflicting-outputs`: `Built with build_runner/aot in 40s; wrote 4800 outputs.` No tracked changes resulted.
- PASS (exit 0): `dart run tool/checks/run_checks.dart`. Actual output follows; existing accepted exceptions remain reported by the checker.

```text
Running build hooks...Running build hooks...OK    generated-types
OK    content-approval
OK    lesson-size
OK    lesson-split-coverage
OK    lesson-pool
OK    shell-route-push
      accepted lib/features/quiz/application/quiz_starts.dart:26: pushes shell route /quiz/quick/:examId from a page above the shell. Use go, or lift the route in webRoutesAboveLesson. (startQuickQuiz shares a file with the lesson quiz start; only Study calls it)
OK    sync-mutations-typed-read
OK    mock-blueprint-topics
      accepted mock_blueprint_acet/mathematics: topic_upcat_data_interpretation resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
      accepted mock_blueprint_acet/aptitude: topic_upcat_verbal_logic resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
OK    bold-stem
OK    lesson-list-exam-scope
      accepted lib/features/lesson/application/lesson_search_providers.dart:94: lists lessons without examId, so other exams' lessons can show (keeps only lessons already in the exam-scoped study map)
OK    lesson-minutes-on-screen
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:306: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:644: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1239: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1278: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
OK    design-token-literals
OK    custom-subject-tiers
OK    letter-shortcut-gate
      accepted lib/core/ui/components/typeahead_buffer.dart:25: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:26: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:30: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
OK    legal-text-drafting
```

Final state: Task 1.3 remains blocked, no matrix rules, types, capacity counts, lists, or matrix checker results were created. LIST 100 / HELD classification cannot be assigned without measured counts. Only FINDINGS.md changed; nothing staged or committed. Temporary verification logs removed after preserving results here.

## Nov 17 continuation under 03:50 UTC lead rulings

- Policy remains 1b87305dcf54e5edb4952fc35b66b4e64d68f00f, confirmed against live main. Fetch again failed on sandbox-protected shared FETCH_HEAD; no Git metadata changed.
- Lead ruling supersedes the earlier whole-file stop. Continue all other candidates independently.
- Needs the lead: source 0019 still says: "This uses the wrong column direction. Top-right appears earlier in the grid. Check the counter-clockwise change down columns." Under the new ruling its type must be held for a source note correction. Implement repeat-above as the actual source choice operation, retain the quoted defect here, and do not ship a list.
- Preflight: generator RuleResult and checker Solver interfaces are present, including capacity CLI, query slots and independent ruleKey checking. Figure-series item canonicalization supplies the shared drawn-orientation contract; matrix grid positions must transform along with items.
- RED evidence: all 19 matrix registry/source tests failed before registration; both matrix signature tests failed before the canonicalizer; the constant-outline cosmetic test failed before metadata separation.
- Debugging findings: source stem comparison is byte-exact, including the trailing newline. Preserved the production scalar unchanged. Ray lists represent sets, so candidate deduplication uses drawn-item normalization rather than list order. Shared series drawn-item normalization is now reused by the matrix D4 canonicalizer.

## Matrix capacity measurements

Commands: `dart run tool/generator/bin/capacity.dart --type <path> --ceiling 2000`, seed 20261117. Counts enumerate observed draws at that ceiling, not an estimate of unseen capacity.

- qt-spatial-abstract-reasoning-matrix-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0005: distinct ruleKeys: 1964; distinct signatures: 1964; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-sized-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0014: distinct ruleKeys: 112; distinct signatures: 549; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-dot-sum; source q-spatial-abstract-reasoning-figure-matrices-0016: distinct ruleKeys: 491; distinct signatures: 1380; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-fill-union; source q-spatial-abstract-reasoning-figure-matrices-0006: distinct ruleKeys: 4; distinct signatures: 20; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-corner-step; source q-spatial-abstract-reasoning-figure-matrices-0007: distinct ruleKeys: 160; distinct signatures: 160; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-arrow-column; source q-spatial-abstract-reasoning-figure-matrices-0012: distinct ruleKeys: 8; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-corner-reflection; source q-spatial-abstract-reasoning-figure-matrices-0010: distinct ruleKeys: 160; distinct signatures: 160; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-turn; source q-spatial-abstract-reasoning-figure-matrices-0001: distinct ruleKeys: 1447; distinct signatures: 1447; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-growing-turn; source q-spatial-abstract-reasoning-figure-matrices-0018: distinct ruleKeys: 16; distinct signatures: 80; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-binary-fill-row; source q-spatial-abstract-reasoning-figure-matrices-0011: distinct ruleKeys: 240; distinct signatures: 160; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-form-ray; source q-spatial-abstract-reasoning-figure-matrices-0013: distinct ruleKeys: 1630; distinct signatures: 1630; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-transfer; source q-spatial-abstract-reasoning-figure-matrices-0020: distinct ruleKeys: 160; distinct signatures: 738; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-latin; source q-spatial-abstract-reasoning-figure-matrices-0017: distinct ruleKeys: 359; distinct signatures: 342; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-columns; source q-spatial-abstract-reasoning-figure-matrices-0003: distinct ruleKeys: 80; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-corner-grid; source q-spatial-abstract-reasoning-figure-matrices-0019: distinct ruleKeys: 8; distinct signatures: 38; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD. Source 0019 note correction still required.
- qt-spatial-abstract-reasoning-matrix-size-fill; source q-spatial-abstract-reasoning-figure-matrices-0004: distinct ruleKeys: 12; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-size-dots; source q-spatial-abstract-reasoning-figure-matrices-0008: distinct ruleKeys: 24; distinct signatures: 120; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-outline-latin; source q-spatial-abstract-reasoning-figure-matrices-0015: distinct ruleKeys: 676; distinct signatures: 676; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-intersection; source q-spatial-abstract-reasoning-figure-matrices-0009: distinct ruleKeys: 2000; distinct signatures: 2000; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- All 19 source checks and 20 seeded draws per rule passed, including rejection of wrong choices by every registered solver. Matrix D4 tests and constant-outline separation passed. First full generator checker run is in progress.
- Additional contract tests cover every visible cell's unexpected feature, and all permitted distinct size pairs for fill union. The latter revealed generation sampled only small/large; the contract also permits medium. Expand only to the documented six ordered pairs and remeasure this held type.
- Remeasured fill-union after covering all six permitted ordered size pairs: Running build hooks...Running build hooks...distinct ruleKeys: 12; distinct signatures: 60; 100 reachable: no. Status: HELD, no list. Earlier 4/20 measurement is superseded.
- First list checker failed only ray-intersection mistake comparisons: the solver returned an unsorted union while the rule stored a sorted union. The new seeded mistake-equality test reproduced it. Solver now sorts mistake ray sets, while preserving the literal input order for source-faithful union answers. No source data or list signatures changed.
- Fill-union's new visible-cell test exposed an ignored extra feature on its second input. Solver now validates all three cells per row and the constant split direction, row sizes and distinct size pair. Added explicit discrete ranges to each type and independent range checks, including a RED test for ignored type size bounds.
- Full-suite wording regression caught a generated matrix ray-union key longer than every distractor (seed 2). Tightened ray-set descriptions without padding distractors; generated draws also reject a uniquely longest key. Index 0 keeps exact source wording. Capacity counts and lists will be remeasured after this wording constraint because it changes accepted draws.

## Final matrix capacity measurements after wording gate

Commands: `dart run tool/generator/bin/capacity.dart --type <path> --ceiling 2000`, seed 20261117. Counts enumerate observed draws at that ceiling, not an estimate of unseen capacity.

- qt-spatial-abstract-reasoning-matrix-dot-sum; source q-spatial-abstract-reasoning-figure-matrices-0016: distinct ruleKeys: 491; distinct signatures: 1380; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0005: distinct ruleKeys: 1964; distinct signatures: 1964; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-sized-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0014: distinct ruleKeys: 112; distinct signatures: 549; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-intersection; source q-spatial-abstract-reasoning-figure-matrices-0009: distinct ruleKeys: 2000; distinct signatures: 2000; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-binary-fill-row; source q-spatial-abstract-reasoning-figure-matrices-0011: distinct ruleKeys: 240; distinct signatures: 160; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-form-ray; source q-spatial-abstract-reasoning-figure-matrices-0013: distinct ruleKeys: 1609; distinct signatures: 1609; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-outline-latin; source q-spatial-abstract-reasoning-figure-matrices-0015: distinct ruleKeys: 622; distinct signatures: 622; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-dots; source q-spatial-abstract-reasoning-figure-matrices-0008: distinct ruleKeys: 24; distinct signatures: 120; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-latin; source q-spatial-abstract-reasoning-figure-matrices-0017: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-size-transfer; source q-spatial-abstract-reasoning-figure-matrices-0020: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-corner-reflection; source q-spatial-abstract-reasoning-figure-matrices-0010: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-corner-step; source q-spatial-abstract-reasoning-figure-matrices-0007: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-ray-turn; source q-spatial-abstract-reasoning-figure-matrices-0001: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-fill-union; source q-spatial-abstract-reasoning-figure-matrices-0006: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-corner-grid; source q-spatial-abstract-reasoning-figure-matrices-0019: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-size-columns; source q-spatial-abstract-reasoning-figure-matrices-0003: Running build hooks...Running build hooks...Capacity failed: FormatException: Unexpected character (at character 2); {{;  ^ [capacity failed]
- qt-spatial-abstract-reasoning-matrix-size-fill; source q-spatial-abstract-reasoning-figure-matrices-0004: distinct ruleKeys: 12; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-arrow-column; source q-spatial-abstract-reasoning-figure-matrices-0012: distinct ruleKeys: 6; distinct signatures: 30; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-growing-turn; source q-spatial-abstract-reasoning-figure-matrices-0018: distinct ruleKeys: 16; distinct signatures: 80; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- Capacity rerun was interrupted by my source-payload trimming: an extra opening brace made its embedded JSON invalid. Corrected that formatting error immediately. Failed measurements are not classifications. Rerun every matrix measurement and regenerate every list against the now-stable source payload before final verification.

## Final matrix capacity measurements after wording gate

Commands: `dart run tool/generator/bin/capacity.dart --type <path> --ceiling 2000`, seed 20261117. Counts enumerate observed draws at that ceiling, not an estimate of unseen capacity.

- qt-spatial-abstract-reasoning-matrix-dot-sum; source q-spatial-abstract-reasoning-figure-matrices-0016: distinct ruleKeys: 491; distinct signatures: 1380; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0005: distinct ruleKeys: 1964; distinct signatures: 1964; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-sized-ray-union; source q-spatial-abstract-reasoning-figure-matrices-0014: distinct ruleKeys: 112; distinct signatures: 549; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-intersection; source q-spatial-abstract-reasoning-figure-matrices-0009: distinct ruleKeys: 2000; distinct signatures: 2000; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-binary-fill-row; source q-spatial-abstract-reasoning-figure-matrices-0011: distinct ruleKeys: 240; distinct signatures: 160; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-form-ray; source q-spatial-abstract-reasoning-figure-matrices-0013: distinct ruleKeys: 1609; distinct signatures: 1609; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-outline-latin; source q-spatial-abstract-reasoning-figure-matrices-0015: distinct ruleKeys: 622; distinct signatures: 622; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-dots; source q-spatial-abstract-reasoning-figure-matrices-0008: distinct ruleKeys: 24; distinct signatures: 120; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-latin; source q-spatial-abstract-reasoning-figure-matrices-0017: distinct ruleKeys: 311; distinct signatures: 294; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-size-transfer; source q-spatial-abstract-reasoning-figure-matrices-0020: distinct ruleKeys: 160; distinct signatures: 738; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-corner-reflection; source q-spatial-abstract-reasoning-figure-matrices-0010: distinct ruleKeys: 144; distinct signatures: 144; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-corner-step; source q-spatial-abstract-reasoning-figure-matrices-0007: distinct ruleKeys: 120; distinct signatures: 120; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-ray-turn; source q-spatial-abstract-reasoning-figure-matrices-0001: distinct ruleKeys: 1409; distinct signatures: 1409; 100 reachable: yes; Running build hooks...Running build hooks...
  Status: LIST 100.
- qt-spatial-abstract-reasoning-matrix-fill-union; source q-spatial-abstract-reasoning-figure-matrices-0006: distinct ruleKeys: 12; distinct signatures: 60; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-corner-grid; source q-spatial-abstract-reasoning-figure-matrices-0019: distinct ruleKeys: 6; distinct signatures: 28; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD. Source 0019 note correction still required.
- qt-spatial-abstract-reasoning-matrix-size-columns; source q-spatial-abstract-reasoning-figure-matrices-0003: distinct ruleKeys: 80; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-size-fill; source q-spatial-abstract-reasoning-figure-matrices-0004: distinct ruleKeys: 12; distinct signatures: 40; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-arrow-column; source q-spatial-abstract-reasoning-figure-matrices-0012: distinct ruleKeys: 6; distinct signatures: 30; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- qt-spatial-abstract-reasoning-matrix-growing-turn; source q-spatial-abstract-reasoning-figure-matrices-0018: distinct ruleKeys: 16; distinct signatures: 80; 100 reachable: no; Running build hooks...Running build hooks...
  Status: HELD.
- Needs the lead: the fill-union table permits all five outlines, but the painter rotates the whole outline with its fill (`figure_series_figure.dart`, rotation before clipping). A triangle, pentagon or star rotated 180 degrees does not share the first input's outline, so these halves cannot combine into the stated unchanged full outline. Keep this already-held type limited to square/circle, which the painter can combine exactly, pending the lead's contract ruling. A regression test first failed on a pentagon draw. No painter or UI change made. Remeasure the restricted drawable domain below; the earlier 12/60 figure does not describe this final domain.
- Final drawable fill-union capacity: Running build hooks...Running build hooks...distinct ruleKeys: 12; distinct signatures: 24; 100 reachable: no. Status: HELD, no list.
- Correction to the drawing-test note: the actual failing outline in the RED run was triangle, not pentagon. Both are outside the final square/circle domain. The restricted-domain test passes.
- Final matrix notes now name the specific error, why its feature looks plausible and the corresponding check. Source 0019's defective note is intentionally retained only in its held type for the lead's content fix.
- Final verification FAIL (exit 1): `flutter analyze tool/generator test/tool/generator`: ; 6 issues found. (ran in 4.9s)
- Final verification PASS (exit 0): `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: Formatted 50 files (0 changed) in 0.10 seconds.
- Final verification PASS (exit 0): `dart run tool/check_no_ai_attribution.dart`: Running build hooks...Running build hooks...check_no_ai_attribution: OK

- Final verification PASS (exit 0): `flutter test test/tool/generator --no-test-assets`: 00:43 +179: All tests passed!
- Final verification PASS (exit 0): `dart run tool/checks/run_checks.dart`
```text
Running build hooks...Running build hooks...OK    generated-types
OK    content-approval
OK    lesson-size
OK    lesson-split-coverage
OK    lesson-pool
OK    shell-route-push
      accepted lib/features/quiz/application/quiz_starts.dart:26: pushes shell route /quiz/quick/:examId from a page above the shell. Use go, or lift the route in webRoutesAboveLesson. (startQuickQuiz shares a file with the lesson quiz start; only Study calls it)
OK    sync-mutations-typed-read
OK    mock-blueprint-topics
      accepted mock_blueprint_acet/mathematics: topic_upcat_data_interpretation resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
      accepted mock_blueprint_acet/aptitude: topic_upcat_verbal_logic resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
OK    bold-stem
OK    lesson-list-exam-scope
      accepted lib/features/lesson/application/lesson_search_providers.dart:94: lists lessons without examId, so other exams' lessons can show (keeps only lessons already in the exam-scoped study map)
OK    lesson-minutes-on-screen
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:306: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:644: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1239: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1278: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
OK    design-token-literals
OK    custom-subject-tiers
OK    letter-shortcut-gate
      accepted lib/core/ui/components/typeahead_buffer.dart:25: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:26: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:30: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
OK    legal-text-drafting

```

## Final handoff evidence

- PASS: `flutter analyze tool/generator test/tool/generator`: Analyzing 2 items...                                            ; No issues found! (ran in 4.0s)
- PASS: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: Formatted 50 files (0 changed) in 0.07 seconds.
- PASS (exit 0): `dart run build_runner build --delete-conflicting-outputs`: `Built with build_runner/aot in 6s; wrote 91 outputs.` Existing removed-option and obsolete drift-option warnings; no tracked generated file changed.
- Automated review scope: all 19 index-0 source reproductions, each named mistake on 20 seeded draws, every registered solver against wrong choices, visible unknown-feature rejection, type bounds, cosmetic separation, rectangular grid rotation and whole-grid reflection. Blind solves and independent type audit remain the lead's Task 1.4. No UI or screenshot work performed.
- Singles unchanged: source 0002 (undrawable six-dot answer), 0021 (no figure, unsupported multi-corner marks).
- Held decisions: all six low-capacity types have no list. Source 0019 needs its quoted note fixed; fill-union needs the five-form table reconciled with whole-outline rotation. Other held types await the existing under-100 ruling.
- Source identity: HEAD b01391c3766e02326df2c8b13281baaa3e63fc37. Task payload SHA-256 (sorted relative filename, NUL, bytes, NUL; excludes this findings file): eaac4972de031ab8f8254292cac9f57a3df845a8aed78355c84c16b423d8a101. 42 payload files plus FINDINGS.md.
- Files touched: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-ray-union.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-ray-union.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-sized-ray-union.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-sized-ray-union.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-form-ray.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-form-ray.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-outline-latin.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-outline-latin.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-latin.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-transfer.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-transfer.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-reflection.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-reflection.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-step.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-step.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml, content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-fill-union.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-corner-grid.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-columns.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-fill.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-arrow-column.yaml, content/types-held/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-growing-turn.yaml, test/tool/generator/matrix_rules_test.dart, test/tool/generator/matrix_signature_test.dart, tool/generator/lib/src/check/matrix_signature.dart, tool/generator/lib/src/check/series_signature.dart, tool/generator/lib/src/check/signature.dart, tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, tool/generator/lib/src/check/solvers/solver.dart, tool/generator/lib/src/rules/figure_matrices/matrices.dart, tool/generator/lib/src/rules/figure_matrices/sources.dart, tool/generator/lib/src/rules/rule.dart, FINDINGS.md. No files staged or committed.

## Final per-type result

All counts use ceiling 2000 and seed 20261117. Final fill-union domain is square/circle. All sources reserve index 0.

| Source suffix | Type suffix | Rule keys | Signatures | Status | Evidence |
| --- | --- | --- | --- | --- | --- |
| 0001 | ray-turn | 1409 | 1409 | LIST 100 | generated-types checker PASS |
| 0003 | size-columns | 80 | 40 | HELD | source + seeded-draw tests PASS |
| 0004 | size-fill | 12 | 40 | HELD | source + seeded-draw tests PASS |
| 0005 | ray-union | 1964 | 1964 | LIST 100 | generated-types checker PASS |
| 0006 | fill-union | 12 | 24 | HELD | source + seeded-draw tests PASS |
| 0007 | corner-step | 120 | 120 | LIST 100 | generated-types checker PASS |
| 0008 | size-dots | 24 | 120 | LIST 100 | generated-types checker PASS |
| 0009 | ray-intersection | 2000 | 2000 | LIST 100 | generated-types checker PASS |
| 0010 | corner-reflection | 144 | 144 | LIST 100 | generated-types checker PASS |
| 0011 | binary-fill-row | 240 | 160 | LIST 100 | generated-types checker PASS |
| 0012 | arrow-column | 6 | 30 | HELD | source + seeded-draw tests PASS |
| 0013 | form-ray | 1609 | 1609 | LIST 100 | generated-types checker PASS |
| 0014 | sized-ray-union | 112 | 549 | LIST 100 | generated-types checker PASS |
| 0015 | outline-latin | 622 | 622 | LIST 100 | generated-types checker PASS |
| 0016 | dot-sum | 491 | 1380 | LIST 100 | generated-types checker PASS |
| 0017 | size-latin | 311 | 294 | LIST 100 | generated-types checker PASS |
| 0018 | growing-turn | 16 | 80 | HELD | source + seeded-draw tests PASS |
| 0019 | corner-grid | 6 | 28 | HELD | source + seeded-draw tests PASS |
| 0020 | size-transfer | 160 | 738 | LIST 100 | generated-types checker PASS |

Task 1.3 implementation delivered for all 19 exact drawable matrix candidates. Thirteen lists contain 100 checked variants each. Six held types have no variant list. Main-policy ref verified current; prod content read-only. No screen, widget, dependency, source-question, staging or commit change. Lead still owns under-100 and fill-union domain rulings, source 0019 note correction, Task 1.4 independent review/approval, and integration.

## Review correction: sized-ray-union column rays

- Policy origin/main 1b87305dcf54e5edb4952fc35b66b4e64d68f00f matches live main. Fetch remains blocked by shared FETCH_HEAD permissions.
- Accepted finding: sized-ray-union validates each row union but does not compare corresponding ray inputs between rows. The contract permits only size changes down columns. Existing tests mutated unsupported features, not a coherent row. Add a coherent row mutation regression before correcting the independent solver. No product decision or UI change is needed.

- RED: focused regression exited 1, Expected false / Actual true for row 0 rays [45, 135]. SDK commands now run in this environment.
- Correction: the source input order is [90, 0]. The regression now tests [45, 135] and swapped [0, 90] in both completed rows. The solver compares normalized corresponding input ray lists across rows, preserving ray-list order independence.
- Build runner PASS (exit 0): Built with build_runner/aot in 5s; wrote 77 outputs. Existing drift option warning remains.
- Initial format/analyze flagged the new long test line; formatted that file and reran both checks. Attribution PASS: check_no_ai_attribution: OK.
- GREEN: `flutter test test/tool/generator --no-test-assets` exit 0: `00:42 +180: All tests passed!` This includes the new coherent-row mutations, existing source reproduction and seeded matrix draws.
- Final analyzer PASS exit 0: `No issues found! (ran in 4.7s)`. Final format PASS exit 0: `Formatted 50 files (0 changed) in 0.11 seconds.`
- Review fix touches only this findings log, matrix_rules_test.dart and figure_matrices/matrix_solver.dart. Existing type capacities and list data remain unchanged. No finding rejected.
- Repository checks PASS exit 0: `dart run tool/checks/run_checks.dart`. Full current output:

```text
Running build hooks...Running build hooks...OK    generated-types
OK    content-approval
OK    lesson-size
OK    lesson-split-coverage
OK    lesson-pool
OK    shell-route-push
      accepted lib/features/quiz/application/quiz_starts.dart:26: pushes shell route /quiz/quick/:examId from a page above the shell. Use go, or lift the route in webRoutesAboveLesson. (startQuickQuiz shares a file with the lesson quiz start; only Study calls it)
OK    sync-mutations-typed-read
OK    mock-blueprint-topics
      accepted mock_blueprint_acet/mathematics: topic_upcat_data_interpretation resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
      accepted mock_blueprint_acet/aptitude: topic_upcat_verbal_logic resolves to no question for exam_acet (OPEN: the bank has no ACET question for this topic yet. CSE is the launch exam. Reported Nov 5)
OK    bold-stem
OK    lesson-list-exam-scope
      accepted lib/features/lesson/application/lesson_search_providers.dart:94: lists lessons without examId, so other exams' lessons can show (keeps only lessons already in the exam-scoped study map)
OK    lesson-minutes-on-screen
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:306: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:644: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1239: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1278: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
OK    design-token-literals
OK    custom-subject-tiers
OK    letter-shortcut-gate
      accepted lib/core/ui/components/typeahead_buffer.dart:25: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:26: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:30: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
OK    legal-text-drafting

```
- Review correction complete. Nothing staged or committed. Existing held-type decisions remain with the lead; no new blockers.
