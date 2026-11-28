# Re-sync findings

- Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, matched remote main with git ls-remote. git fetch cannot write FETCH_HEAD outside this worktree; no policy gap remains.
- Fixed root 646326517 changes ray-intersection's first-exclusive distractor to copying the second input, interleaved-count's copy-even-count distractor to repeating the last odd count, and corner-grid's repeat-above note to accurately name copying the cell above.
- User instruction supersedes the earlier R5 100-version floor: activate only at 20 or more, generate min(100, measured capacity). No approvals will be changed.
- Verification environment: requested flutter test command fails before loading tests because assets/seed/content.db is absent. Generator tests need no assets; use Flutter's --no-test-assets flag for red/green evidence and report the literal requested command separately.
- RED confirmed: fixed-source fidelity failed for ray-intersection and interleaved-count; ray draw 1 admitted the highest-ray competitor; corner-grid's old note named a false mistake. New independent regression tests cover all three sources and 100 new draws per type.
- The fixed series source also spells its key as "Circle with three dots"; the stored literal used "Circle with 3 dots". Updated the literal to match exactly.
- Corner-grid draws now use only squares. Its three copy mistakes require distinct visible input positions; invalid blank positions redraw rather than inventing a note.
- Capacity measured with ceiling 2000, seed 20261117: ray-intersection 2000 distinct ruleKeys / 2000 signatures; interleaved-count 241 / 241; corner-grid 5 / 5. These are measured sampled draws, not estimates of unobserved capacity.

## Needs the lead

- Corner-grid stays held: only 5 distinct task signatures measured, below the authorized 20 floor. Its fixed index 0 and notes are repaired, but no active list is produced. Widening the rule or adding cosmetics to reach 20 is not authorized here.
- Full generator suite exposes two existing test lookup defects: matrix-size-fill and matrix-fill-union tests search only content/types-held although both files are active. These were not moved by this task. Leave unrelated behavior unchanged and report the failures.
- run_checks.dart cannot compile because generated question/choice Freezed and JSON parts are missing in this fresh worktree. No source or generated files were hand-edited to bypass it.
- Historical ambiguity regression tests now plant the original bad distractors explicitly, preserving proof that the checker rejects the audits' examples after the sources are fixed.
- To run the required checker suite without changing application source, regenerate only the missing question/choice model parts with build_runner build filters. These are ignored generated model files, not UI or protected-content outputs.
- Generated active lists: 100 each. R6 exact normalized keys peak at 9/100 for ray-intersection and 13/100 for interleaved-count. A durable regression checks both generated lists against the full independent checker and R6.
- Focused verification: flutter test --no-test-assets test/tool/generator/resync_test.dart test/tool/generator/reaudit_regression_test.dart: 16 tests passed, including full checker and R6 on both new lists. The original highest-ray bad choice is still rejected as a planted regression.
- Baseline proof for unrelated lookup failures: git ls-tree HEAD locates matrix-size-fill and matrix-fill-union in content/types, while the existing tests search only content/types-held.
- Final source identity: HEAD 3c63784bd4decd10135230ade21da0f469739127 plus this unstaged patch. Initial worktree was clean. No staging, commits, UI changes, question-source edits, or approval changes.
- Analysis: flutter analyze tool/generator test/tool/generator: No issues found! (ran in 33.4s). Format: Formatted 60 files (0 changed). Attribution: check_no_ai_attribution: OK.
- Requested flutter test test/tool/generator: FAIL before test loading, missing assets/seed/content.db. Final asset-free full-suite run is pending; focused tests passed 16/16.
- build_runner generated the missing model parts successfully: Built with build_runner/aot in 127s; wrote 13 outputs. All generated outputs remain ignored; application source is unchanged. Re-running run_checks.dart now.

## Files touched

- content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.yaml
- content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml
- content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.variants.yaml
- content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-interleaved-count.yaml
- content/types-held/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-corner-grid.yaml
- tool/generator/lib/src/rules/figure_matrices/matrices.dart
- tool/generator/lib/src/rules/figure_matrices/sources.dart
- tool/generator/lib/src/rules/figure_series/series.dart
- tool/generator/lib/src/rules/figure_series/sources.dart
- tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart
- tool/generator/lib/src/check/solvers/figure_series/series_solver.dart
- test/tool/generator/resync_test.dart
- test/tool/generator/matrix_rules_test.dart
- test/tool/generator/series_rules_test.dart
- test/tool/generator/audit_a_regression_test.dart
- test/tool/generator/reaudit_regression_test.dart
- FINDINGS.md
- The ray-intersection and interleaved-count definitions above were moved from the corresponding content/types-held paths with plain filesystem renames.
- Full generator checker: dart run tool/generator/bin/check.dart exited 0, no failures. This covers all 40 active types plus schema/solver validation for 18 held types, using fixed prod root 646326517. New active lists pass full correctness, source reproduction, signature, mistake, ranges, cosmetics and size checks.
- Final full generator suite with --no-test-assets: 02:48 +248 ~6 -2: Some tests failed. Both failures are the existing matrix-size-fill / matrix-fill-union held-only lookup defects above. All re-sync regressions pass. Six golden sheet tests are skipped as configured.

## Final verification

- PASS dart run tool/generator/bin/check.dart: exit 0, no failures.
- PASS focused tests: 00:50 +16: All tests passed!
- FAIL flutter test test/tool/generator: No file or variants found for asset: assets/seed/content.db. Failed to build asset bundle.
- FAIL flutter test --no-test-assets test/tool/generator: 02:48 +248 ~6 -2: Some tests failed. Existing failures: constant matrix outline is recorded separately from ruleKey; fill union uses every permitted pair of distinct sizes. Both search only the held directory for already-active types.
- PASS flutter analyze tool/generator test/tool/generator: No issues found! (ran in 33.4s).
- PASS dart format --output=none --set-exit-if-changed tool/generator test/tool/generator: Formatted 60 files (0 changed).
- FAIL dart run tool/checks/run_checks.dart: exit 1. OK generated-types; FAIL content-approval (12). The two newly active types are unapproved as required; the other 10 listed unapproved types were already active. Every other repository check passes. No approvals changed.
- PASS dart run tool/check_no_ai_attribution.dart: check_no_ai_attribution: OK.
- PASS git diff --check; no staged changes.
- Remaining with the lead: corner-grid's under-20 capacity, required independent audit/blind solve/approvals for the two new active lists, the missing seed asset, and the two existing test lookup defects. No visual acceptance or release claimed.

Repository-check approval findings (verbatim):

```
Running build hooks...Running build hooks...OK    generated-types
FAIL  content-approval (12)
      qt-spatial-abstract-reasoning-series-corner-edge-count: not approved
      qt-spatial-abstract-reasoning-series-interleaved-count: not approved
      qt-spatial-abstract-reasoning-net-adjacent-relation: not approved
      qt-spatial-abstract-reasoning-net-nonadjacent: not approved
      qt-spatial-abstract-reasoning-net-opposite-easy: not approved
      qt-spatial-abstract-reasoning-net-opposite-medium: not approved
      qt-spatial-abstract-reasoning-net-top-and-shadow: not approved
      qt-spatial-abstract-reasoning-net-validity-test: not approved
      qt-spatial-abstract-reasoning-group-center-cuts: not approved
      qt-spatial-abstract-reasoning-group-line-count: not approved
      qt-spatial-abstract-reasoning-matrix-ray-intersection: not approved
      qt-spatial-abstract-reasoning-group-specific-rule: not approved
```

## Resync verification retry, November 17

- No review findings were supplied, so no implementation fix is requested. Existing changes are preserved.
- Policy read from origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, a descendant of 1295c1866. Fetch failed because the shared Git FETCH_HEAD is outside writable roots; existing origin/main policy was available.
- Retry: flutter test test/tool/generator exited 1: No file or variants found for asset: assets/seed/content.db. Failed to build asset bundle.
- Retry: flutter analyze tool/generator test/tool/generator exited 0: No issues found! (ran in 6.5s).
- Retry: dart format --output=none --set-exit-if-changed tool/generator test/tool/generator exited 0: Formatted 60 files (0 changed) in 0.10 seconds.
- Retry: dart run tool/check_no_ai_attribution.dart exited 0: check_no_ai_attribution: OK.
- Remote main independently confirmed with git ls-remote: 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, identical to origin/main.
- Retry focused regressions: flutter test --no-pub --no-test-assets test/tool/generator/resync_test.dart test/tool/generator/reaudit_regression_test.dart exited 0: 00:18 +16: All tests passed! Includes fixed-source checks, new draws, full active-list checking and R6.
- Retry corner-grid capacity at ceiling 2000: distinct ruleKeys: 5; distinct signatures: 5; 100 reachable: no. Remains held under the authorized 20 minimum.
- Retry git diff --check exited 0. Only FINDINGS.md edited in this retry; existing implementation preserved.
- Retry full generator checker: dart run tool/generator/bin/check.dart exited 0, no failures printed, fixed prod root 646326517.
- Retry repository checks: dart run tool/checks/run_checks.dart completed, exit 1: OK generated-types; FAIL content-approval (12). All other checks reported OK. Approvals remain unchanged as explicitly required.
- No supplied review finding was rejected: the supplied finding list was NO FINDINGS. No implementation changes were needed in this retry.
