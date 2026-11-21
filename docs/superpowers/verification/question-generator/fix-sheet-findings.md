# Sheet findings fix

- Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, confirmed current with git ls-remote and descendant of 1295c1866. git fetch could not write shared FETCH_HEAD; existing ref exactly matches remote main. Worktree initially clean. No staging or commits authorized.
- Scope: generator geometry constraints, source-style choice wording, directional-extreme solver library, regeneration, capacity and R6 measurements. Sheet harness and UI remain untouched.
- Reviews establish horizontal ray/dot-row overlap in fill-ray-dots, crowded small-triangle dots, and lowest/leftmost/rightmost competing rules missing from the checker.
- Source-ref gap: origin/content/bite-sized-cse-algebra-r1 is locally 88f38e698. The task explicitly pins source fidelity to 646326517, available locally; fixed-source checks will use that commit, as the existing checker does. No source question edits.
- Geometry: rays start at center; partial-fill boundary is horizontal at r*(1-2*fill). Nonhorizontal rays cannot lie along that boundary or horizontal dot row. Matrix base radius is 18 at its 180px/3-row contract; dot clearance can be tested against SeriesGeometry without changing UI.
- RED: focused regression run with --no-test-assets fails six tests on horizontal rays, small-triangle crowding, three missing directional solvers, and compact choice wording. Exact flutter test command is blocked by absent assets/seed/content.db; assets are irrelevant to these tool tests, so focused runs disable test assets. No package regeneration.
- GREEN: 10 focused geometry, directional-rule, source-wording and longest-key tests pass. Source-style count words required updating the old test that assumed numeric semicolon labels. Generated series now redraw when source-style prose would make the key uniquely longest.
- Grown-library sweep before regeneration finds the audited ray-intersection alternatives; other active types have no reported competing-answer failures. The first wider test run failed only the stale intersection list and the two wording assertions addressed above.

## Regeneration and measured capacity

Seed 20261117, ceiling 2000 draws; counts are observed distinct R1 tasks, never estimates. Existing list sizes are retained for wording-only changes. Geometry and intersection lists use min(100, observed capacity), with the current task authorizing lists of at least 20.


## Regeneration and measured capacity

Seed 20261117, ceiling 2000 draws; counts are observed distinct R1 tasks, never estimates. Existing list sizes are retained for wording-only changes. Geometry and intersection lists use min(100, observed capacity), with the current task authorizing lists of at least 20.

- series-dots-size: 16 ruleKeys, 80 signatures; list 80; R6 PASS; changed true.
- series-fill-ray-dots: 115 ruleKeys, 489 signatures; list 100; R6 PASS; changed true.
- series-four-tracks: 1397 ruleKeys, 1397 signatures; list 100; R6 PASS; changed true.
- series-interleaved-count: 241 ruleKeys, 241 signatures; list 100; R6 PASS; changed true.
- series-size-corner-ray: 48 ruleKeys, 48 signatures; list 48; R6 PASS; changed true.
- series-transfer-count: 9 ruleKeys, 45 signatures; list 45; R6 PASS; changed true.
- series-binary-fill: 6 ruleKeys, 24 signatures; list 24; R6 PASS; changed true.
- series-ray-step: 49 ruleKeys, 175 signatures; list 100; R6 PASS; changed true.
- matrix-dot-sum: 151 ruleKeys, 698 signatures; list 100; R6 PASS; changed true.
- matrix-fill-union: 12 ruleKeys, 24 signatures; list 24; R6 PASS; changed true.
- matrix-ray-union: 1947 ruleKeys, 1947 signatures; list 100; R6 PASS; changed true.
- matrix-sized-ray-union: 112 ruleKeys, 549 signatures; list 100; R6 PASS; changed true.
- matrix-ray-intersection: 2000 ruleKeys, 2000 signatures; list 100; R6 PASS; changed true.
- matrix-binary-fill-row: 32 ruleKeys, 32 signatures; list 32; R6 PASS; changed true.
- matrix-form-ray: 1308 ruleKeys, 1308 signatures; list 100; R6 PASS; changed true.
- matrix-outline-latin: 356 ruleKeys, 356 signatures; list 100; R6 PASS; changed false.
- matrix-size-dots: 18 ruleKeys, 55 signatures; list 55; R6 PASS; changed true.
- matrix-size-fill: 12 ruleKeys, 40 signatures; list 40; R6 PASS; changed false.
- matrix-size-latin: 72 ruleKeys, 72 signatures; list 72; R6 PASS; changed false.
- matrix-size-transfer: 192 ruleKeys, 839 signatures; list 100; R6 PASS; changed true.
- matrix-arrow-column: 6 ruleKeys, 30 signatures; list 30; R6 PASS; changed true.
- matrix-corner-reflection: 144 ruleKeys, 144 signatures; list 100; R6 PASS; changed true.
- matrix-growing-turn: 14 ruleKeys, 70 signatures; list 70; R6 PASS; changed true.
- matrix-ray-turn: 1168 ruleKeys, 1168 signatures; list 100; R6 PASS; changed true.
- Capacity reduction: source-style wording plus the longest-key guard changes series-dots-size from 90 to 80 and matrix-growing-turn from 80 to 70. The existing resync ruling explicitly supersedes R5's 100 floor with 20 (resync-findings.md and resync.brief.md); all regenerated lists remain above 20.
- Geometry-constrained matrix-size-dots now measures 18 ruleKeys / 55 task signatures; series-fill-ray-dots measures 115 / 489; ray-intersection measures 2000 / 2000 at ceiling 2000. All three regenerate with the reserved index 0 preserved in full. No type falls below the authorized 20 floor.
- Verification prerequisite: run_checks.dart exits 254 before checks because this fresh worktree lacks generated Question/Choice Freezed and JSON parts. Regenerate only those ignored model outputs with build_runner (no hand edits), then rerun. This is the same prerequisite recorded by the resync worker.

## Needs the lead

- Exact flutter test command cannot load tests without the absent seed asset. Asset-free generator verification is running separately; no protected package was rebuilt.
- Required full formatter reports `Changed test/tool/generator/figure_sheets_test.dart`, `Formatted 64 files (1 changed)`, exit 1. --output=none writes nothing. The harness is unchanged from HEAD and explicitly owned by the Claude worker; this worker must not format or edit it.
- Regeneration invalidates existing ledger approval for the changed approved lists. No approval entry is edited or created here; independent review and reapproval belong to the lead.

## Changed approved lists, approval now void

- qt-spatial-abstract-reasoning-series-dots-size
- qt-spatial-abstract-reasoning-series-fill-ray-dots
- qt-spatial-abstract-reasoning-series-four-tracks
- qt-spatial-abstract-reasoning-series-interleaved-count
- qt-spatial-abstract-reasoning-series-size-corner-ray
- qt-spatial-abstract-reasoning-series-transfer-count
- qt-spatial-abstract-reasoning-series-binary-fill
- qt-spatial-abstract-reasoning-series-ray-step
- qt-spatial-abstract-reasoning-matrix-dot-sum
- qt-spatial-abstract-reasoning-matrix-fill-union
- qt-spatial-abstract-reasoning-matrix-ray-union
- qt-spatial-abstract-reasoning-matrix-sized-ray-union
- qt-spatial-abstract-reasoning-matrix-binary-fill-row
- qt-spatial-abstract-reasoning-matrix-form-ray
- qt-spatial-abstract-reasoning-matrix-size-dots
- qt-spatial-abstract-reasoning-matrix-size-transfer
- qt-spatial-abstract-reasoning-matrix-arrow-column
- qt-spatial-abstract-reasoning-matrix-corner-reflection
- qt-spatial-abstract-reasoning-matrix-growing-turn
- qt-spatial-abstract-reasoning-matrix-ray-turn

## Files touched

- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-dots-size.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-four-tracks.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-transfer-count.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/figure-counts-and-fills/qt-spatial-abstract-reasoning-series-binary-fill.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-fill-union.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-ray-union.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-sized-ray-union.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-binary-fill-row.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-form-ray.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-transfer.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-arrow-column.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-corner-reflection.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-growing-turn.variants.yaml`
- `content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml`
- `test/tool/generator/series_wording_test.dart`
- `tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart`
- `tool/generator/lib/src/check/solvers/solver.dart`
- `tool/generator/lib/src/rules/figure_matrices/matrices.dart`
- `tool/generator/lib/src/rules/figure_series/series.dart`
- `test/tool/generator/sheet_findings_test.dart`: geometry, wording and library regressions.
- `test/tool/generator/fixtures/bad/sheet-extreme-rays.yaml`: original audited bad variants 2, 8 and 12.
- `FINDINGS.md`: required live findings and verification evidence.
- Full generator checker: `dart run tool/generator/bin/check.dart` exits 0 after regeneration. Every one of the 30 active types passes correctness against the grown library, named mistakes, R1 signatures, ranges, source fidelity to 646326517, size and R6. Held definitions also retain registered solvers.
- Asset-free full suite: `flutter test --no-pub --no-test-assets test/tool/generator`: `01:04 +280 ~10: All tests passed!` Ten sheet tests are opt-in and skipped by the existing harness.
- `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 4.2s)`.
- `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`, exit 0.
- Full formatter: `Changed test/tool/generator/figure_sheets_test.dart`, `Formatted 64 files (1 changed) in 0.07 seconds.`, exit 1. All files authored by this worker are formatted; the unchanged harness remains with its owner.
- Ignored missing model parts regenerated successfully: `Built with build_runner/aot in 25s; wrote 13 outputs.` No tracked lib files changed.
- Review boundary: source index 0 intentionally retains the live-source horizontal ray and crowded triangle findings. New draws exclude them. Source wording on fixed indexes, source-content fixes, sheet rendering and independent visual acceptance remain outside this worker's scope.
- R5 correction before handoff: this task explicitly says R5 for matrix-size-dots, while only ray-intersection receives the task's explicit minimum-20 exception. The older release/resync notes use 20 but the assigned spec still says 100. To follow the current task conservatively, moved matrix-size-dots's definition and regenerated 55-item list to content/types-held/ with plain filesystem renames, no staging. Its full list passed all checker conditions and R6 before moving. Earlier statements treating its 55-item list as active are superseded. The remaining 29 active types are unchanged by this move.
- Needs the lead: record a single controlling floor in the plan/spec. Releasing the held size-dots list at 55 requires a lead ruling under the inconsistent historical floor records. No need to widen it or alter the painter.
- Final repository checks before the size-dots hold: `OK generated-types`; `FAIL content-approval (21)`, consisting of 20 edited approved lists plus ray-intersection not approved; all other checks OK. Exit 1, approvals deliberately untouched.
- Independent reserved-draw comparison: all 21 changed lists retain index 0 exactly equal to HEAD, including the moved size-dots list. The pre-hold full source checker established equality to prod root 646326517.
- Final moves: `content/types/.../matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.yaml` and its variants file now live under the matching `content/types-held/` path. Source definition bytes are unchanged.
- Source identity: HEAD aa8aad800de510847b924dc2dad15a014c3ebd29 plus this unstaged patch. No commits, staging, dependencies, app source, source questions or approval entries changed.
- Final asset-free suite after the size-dots hold: `00:59 +280 ~10: All tests passed!`, exit 0. The hold introduced no test failure.
- Final `dart run tool/checks/run_checks.dart`: exit 1; `OK generated-types` for the remaining 29 active lists; `FAIL content-approval (20)` (19 edited active approvals plus unapproved ray-intersection). Every other check is OK. Size-dots is held and not approved here.
- Completion verification: exact requested Flutter suite FAILS before loading tests (`No file or variants found for asset: assets/seed/content.db.`); asset-free suite PASS (280 passed, 10 skipped); analyzer PASS (`No issues found!`); requested formatter FAILS only unchanged sheet harness; repository checks FAIL only approval as listed; attribution PASS (`check_no_ai_attribution: OK`). `git diff --check` PASS; cached diff empty; protected lib/question/sheet-harness scope unchanged.
- Work delivered for lead review, not acceptance or approval. Source fixes and visual acceptance remain with their respective owners. No further generator code work is known necessary for the settled findings; the held 55-item size-dots floor ruling and renewed approvals remain for the lead.

## Verification follow-up, November 17

- Supplied review has no findings to fix or reject. Existing uncommitted implementation is preserved.
- Policy origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885 includes required 1295c1866. Fetch was denied writing external Git FETCH_HEAD; read-only git ls-remote confirms origin/main equals current remote main.
- Running all five required commands again in this writable environment; no type approval or UI change authorized.

- Fresh command `flutter test test/tool/generator`: exit 1. Full output: `.dart_tool/fix-sheet-verification-1.log`.
```text
  vm_service 15.2.0 (15.4.0 available)
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
133 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Error detected in pubspec.yaml:
No file or variants found for asset: assets/seed/content.db.

Error: Failed to build asset bundle
```

- Fresh command `flutter analyze tool/generator test/tool/generator`: exit 0. Full output: `.dart_tool/fix-sheet-verification-2.log`.
```text
  vector_math 2.2.0 (2.4.4 available)
  very_good_analysis 6.0.0 (11.0.0 available)
  vm_service 15.2.0 (15.4.0 available)
  web 1.1.1 (1.1.2 available)
  webdriver 3.1.0 (3.2.0 available)
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
133 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing 2 items...                                            
No issues found! (ran in 3.5s)
```

- Fresh command `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: exit 1. Full output: `.dart_tool/fix-sheet-verification-3.log`.
```text
Changed test/tool/generator/figure_sheets_test.dart
Formatted 64 files (1 changed) in 0.07 seconds.
```

- Fresh command `dart run tool/checks/run_checks.dart`: exit 1. Full output: `.dart_tool/fix-sheet-verification-4.log`.
```text
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

- Fresh command `dart run tool/check_no_ai_attribution.dart`: exit 0. Full output: `.dart_tool/fix-sheet-verification-5.log`.
```text
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

- Fresh repository-check summary: `OK generated-types`; `FAIL content-approval (20)` (19 edited active approvals and unapproved ray-intersection). Every other check passes. Renewal remains with the lead; no approvals changed.
- Supplemental `flutter test --no-pub --no-test-assets test/tool/generator`: exit 0, `01:00 +280 ~10: All tests passed!`. This does not change the exact requested command failure.
- Follow-up files touched: FINDINGS.md only, plus ignored .dart_tool verification logs. Existing source, lists, tests, held files and sheet harness preserved; no staging or commits. `git diff --check` passes and cached diff remains empty.
- Needs the lead: provide the seed asset for exact test execution; have the sheet-test owner fix its formatting; renew affected approvals after review. Existing held-size-dots floor ruling remains pending. No supplied finding was rejected because the supplied findings list is empty.
- Lead ruling (Nov 17 12:00 UTC): matrix-size-dots ships at 55 under Revision 1 (floor 20, not 100); moved back to content/types/.
