# Checker library growth, November 17

- Policy: origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, descendant of 1295c1866. Fetch could not write external FETCH_HEAD; git ls-remote confirms the local ref matches live main. Initial worktree clean. codex-pick status shows room. No staging or commits authorized.
- Read assigned plan, spec Part B, re-audit C and current decisions. Existing checker already rejects wrong choices supported by any library rule and permits agreement on the keyed answer. Add explicit planted agreement/disagreement coverage.
- Capacity currently collects ruleKeys before signature dedupe, violating ruling 5. Count only the first kept signature's key.
- RED: capacity fixture has 100 ruleKeys for one signature. Seven re-audit C examples fail because their library solvers are absent. Frozen audit examples recovered from f8b12b9 into test fixtures, since held lists were removed.
- Standard flutter test cannot bundle absent assets/seed/content.db. Supplemental --no-test-assets executes tool tests without modifying seed assets. No protected package regenerated.
- Added independent diagonal ray reflections and row/column dot product, absolute difference, maximum, minimum, and quotient solvers. Quotient is included because re-audit C indexes 79/95 explicitly require it. Matrix competitors dispatch by figure kind, across all originating matrix rules.
- GREEN: 14 focused tests pass with --no-test-assets. Frozen examples 6/59, 53, 68, 79, 10, 69 now expose their competing answers. Planted product/addition agreement is accepted. Fresh held-type draws reject competing offered answers; capacity counts only keys of kept signatures.
- content/types / qt-spatial-abstract-reasoning-series-fill-ray-dots: PASS (100 variants); 288 / 1247 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-series-four-tracks: PASS (100 variants); 2788 / 2788 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-series-ray-step: PASS (100 variants); 56 / 196 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-group-polygon-replacement: PASS (100 variants); 587 / 587 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-group-dot-count: PASS (100 variants); 7231 / 7231 at ceiling 10000.
- Generator constraints remain independent of checker code: ray draws rule out all four reflection axes; dot draws evaluate row and column alternatives arithmetically and discard only competing offered counts. Reserved index 0 is preserved. Both types stay held, and no type/list file is changed.
- Analyzer first pass found 25 issues: 19 in new edits (fixed with scoped Dart fixes), six pre-existing in figure_sheets_test.dart. The latter file is outside this assignment and remains untouched.
- content/types / qt-spatial-abstract-reasoning-group-dot-parity: PASS (100 variants); 2895 / 2895 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-matrix-ray-union: PASS (100 variants); 9224 / 9224 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-matrix-sized-ray-union: PASS (100 variants); 112 / 560 at ceiling 10000.
- Full supplemental suite exposed the old cube-net capacity contract expecting two keys for one signature. This directly conflicts with the new explicit ruling 5, so updated that capacity test to expect one retained key. No product decision needed: current assignment explicitly supersedes the old expectation.
## Needs the lead

- Required run_checks.dart cannot compile because fresh worktree lacks generated application model files (Question/Choice and others). No application or generated file changed. Independent combined verification needs codegen in the lead's prepared checkout.
- Analyzer has six pre-existing findings in test/tool/generator/figure_sheets_test.dart (nullable casts, raw Map, long lines). They remain outside this assignment.
- content/types / qt-spatial-abstract-reasoning-matrix-form-ray: PASS (100 variants); 2141 / 2141 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-matrix-outline-latin: PASS (100 variants); 360 / 360 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-matrix-size-dots: PASS (100 variants); 24 / 120 at ceiling 10000.
  - qt-spatial-abstract-reasoning-matrix-size-transfer #1 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #1 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #2 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #2 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #3 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #3 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #4 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #4 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #5 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #5 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #7 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #7 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #8 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #8 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #10 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #10 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #11 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #11 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #12 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #12 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #13 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #13 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #14 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #14 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #15 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #15 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #16 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #16 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #18 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #18 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #19 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #19 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #21 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #21 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #22 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #22 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #23 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #23 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #25 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #25 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #27 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #27 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #28 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #28 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #29 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #29 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #32 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #32 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #33 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #33 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #35 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #35 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #36 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #36 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #40 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #40 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #44 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #44 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #45 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #45 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #47 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #47 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #48 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #48 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #49 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #49 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #50 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #50 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #51 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #51 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #52 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #52 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #54 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #54 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #55 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #55 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #57 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #57 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #58 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #58 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #59 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #59 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #60 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #60 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #61 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #61 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #63 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #63 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #66 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #66 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #67 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #67 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #68 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #68 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #69 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #69 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #70 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #70 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #72 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #72 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #73 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #73 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #74 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #74 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #75 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #75 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #76 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #76 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #78 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #78 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #79 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #79 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #80 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #80 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #81 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #81 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #83 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #83 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #84 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #84 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #87 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #87 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #89 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #89 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #90 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #90 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #91 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #91 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #92 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #92 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #94 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #94 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #96 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #96 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #97 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #97 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #99 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-size-transfer #99 correctness: wrong choice completes a library rule
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #1 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #1 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #2 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #2 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #3 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #3 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #4 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #4 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #5 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #5 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #7 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #7 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #8 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #8 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #10 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #10 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #11 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #11 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #12 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #12 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #13 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #13 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #14 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #14 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #15 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #15 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #16 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #16 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #18 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #18 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #19 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #19 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #21 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #21 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #22 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #22 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #23 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #23 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #25 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #25 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #27 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #27 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #28 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #28 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #29 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #29 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #32 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #32 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #33 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #33 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #35 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #35 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #36 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #36 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #40 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #40 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #44 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #44 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #45 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #45 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #47 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #47 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #48 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #48 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #49 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #49 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #50 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #50 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #51 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #51 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #52 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #52 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #54 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #54 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #55 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #55 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #57 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #57 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #58 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #58 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #59 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #59 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #60 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #60 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #61 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #61 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #63 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #63 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #66 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #66 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #67 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #67 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #68 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #68 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #69 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #69 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #70 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #70 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #72 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #72 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #73 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #73 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #74 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #74 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #75 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #75 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #76 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #76 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #78 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #78 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #79 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #79 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #80 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #80 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #81 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #81 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #83 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #83 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #84 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #84 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #87 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #87 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #89 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #89 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #90 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #90 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #91 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #91 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #92 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #92 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #94 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #94 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #96 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #96 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #97 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #97 competing rule matrix-dot-minimum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #99 competing rule matrix-dot-maximum-column
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-size-transfer #99 competing rule matrix-dot-minimum-column
- content/types / qt-spatial-abstract-reasoning-matrix-size-transfer: FAIL (138 findings); 192 / 960 at ceiling 10000.
- content/types / qt-spatial-abstract-reasoning-matrix-corner-reflection: PASS (100 variants); 144 / 144 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-corner-edge-count: NO LIST: capacity only; 8 / 40 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-dots-size: NO LIST: capacity only; 18 / 90 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-interleaved-count: NO LIST: capacity only; 161 / 161 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-outline-triple: NO LIST: capacity only; 12 / 12 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-size-corner-ray: NO LIST: capacity only; 48 / 48 at ceiling 10000.
- During full-suite verification, the first library implementation falsely flagged approved matrix-size-transfer: it checked dots but ignored a changing edge-line track. Fixed the library solver, not the approved type, to require other features constant within each row. Earlier size-transfer failures and competitor entries above are provisional and superseded by the corrected rerun below. Existing matrix_rules_test caught this defect before completion. No approved content changed.
- content/types-held / qt-spatial-abstract-reasoning-series-size-fill: NO LIST: capacity only; 2 / 10 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-transfer-count: NO LIST: capacity only; 9 / 45 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-binary-fill: NO LIST: capacity only; 6 / 24 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-double-fill: NO LIST: capacity only; 5 / 5 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-two-fill-steps: NO LIST: capacity only; 3 / 12 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-arrow-alternation: NO LIST: capacity only; 4 / 14 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-series-two-arrow-turns: NO LIST: capacity only; 4 / 14 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-adjacent-relation: PASS (1 variants); 25 / 25 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-all-opposites: NO LIST: capacity only; 7 / 7 at ceiling 10000.

## Corrected final approved-list rerun

- All 13 approved lists PASS after the count solver preserves other row features. All provisional size-transfer failures above are CLOSED as checker implementation defects. Capacity counts above remain valid, since this fix changes neither generation nor signatures.
- content/types-held / qt-spatial-abstract-reasoning-net-nonadjacent: NO LIST: capacity only; 52 / 52 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-opposite-easy: NO LIST: capacity only; 52 / 52 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-opposite-hard: PASS (2 variants); 5 / 5 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-opposite-medium: NO LIST: capacity only; 52 / 52 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-overlap-medium: NO LIST: capacity only; 4 / 4 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-strip-first-overlap: NO LIST: capacity only; 1 / 1 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-three-at-corner: NO LIST: capacity only; 64 / 64 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-top-and-shadow: NO LIST: capacity only; 52 / 52 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-net-validity-test: NO LIST: capacity only; 24 / 24 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-boundary: NO LIST: capacity only; 42 / 42 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-outline-symmetry: NO LIST: capacity only; 5 / 5 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-side-count-easy: NO LIST: capacity only; 12 / 12 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-side-count-medium: NO LIST: capacity only; 13 / 13 at ceiling 10000.

## Verification checkpoint

- Codegen resolved the initial missing-model blocker: `dart run build_runner build --delete-conflicting-outputs`: Built with build_runner/aot in 35s; wrote 4831 outputs. Only ignored generated outputs, no hand edits.
- Required `flutter test test/tool/generator`: FAIL, exit 1: No file or variants found for asset: assets/seed/content.db. Error: Failed to build asset bundle.
- Supplemental `flutter test --no-test-assets test/tool/generator`: PASS: `01:03 +237 ~6: All tests passed!` Six figure-sheet tests are intentionally skipped unless their rendering flag is enabled; no UI rendering requested.
- `flutter analyze tool/generator test/tool/generator`: FAIL: `7 issues found. (ran in 7.5s)`. Correction to initial count: all seven are in unchanged figure_sheets_test.dart, lines 49,135,142 (two),153,167,247. No findings in edited source/tests.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: FAIL, exit 1: `Changed test/tool/generator/figure_sheets_test.dart`; `Formatted 59 files (1 changed) in 0.17 seconds.` --output=none left that unrelated UI test unchanged.
- `dart run tool/checks/run_checks.dart`: PASS, exit 0, 14 OK checks; final line `OK    legal-text-drafting`.
- `dart run tool/check_no_ai_attribution.dart`: PASS: `check_no_ai_attribution: OK`.
- content/types-held / qt-spatial-abstract-reasoning-group-side-parity: NO LIST: capacity only; 12 / 12 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-center-cuts: NO LIST: capacity only; 21 / 21 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-line-count: NO LIST: capacity only; 20 / 20 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-region-parity: NO LIST: capacity only; 1 / 1 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-group-side-double-dots: NO LIST: capacity only; 68 / 68 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-dot-sum: NO LIST: capacity only; 151 / 751 at ceiling 10000.
- qt-spatial-abstract-reasoning-matrix-dot-sum: fresh 10000 draws, correctness failures 0. No list written.
- content/types-held / qt-spatial-abstract-reasoning-matrix-fill-union: NO LIST: capacity only; 12 / 24 at ceiling 10000.
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #0 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #6 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #17 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #20 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #34 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #49 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #53 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #60 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #61 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #64 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #67 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #80 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #84 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #87 correctness: wrong choice completes a library rule
  - qt-spatial-abstract-reasoning-matrix-ray-intersection #95 correctness: wrong choice completes a library rule
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #0 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #6 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #17 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #20 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #34 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #49 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #53 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #60 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #61 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #64 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #67 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #80 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #84 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #87 competing rule matrix-highest-ray
  - Needs the lead: qt-spatial-abstract-reasoning-matrix-ray-intersection #95 competing rule matrix-highest-ray
- content/types-held / qt-spatial-abstract-reasoning-matrix-ray-intersection: FAIL (15 findings); 9978 / 9978 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-binary-fill-row: NO LIST: capacity only; 32 / 32 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-corner-grid: NO LIST: capacity only; 6 / 28 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-size-columns: NO LIST: capacity only; 10 / 10 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-size-fill: NO LIST: capacity only; 12 / 40 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-size-latin: NO LIST: capacity only; 72 / 72 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-arrow-column: NO LIST: capacity only; 6 / 30 at ceiling 10000.
  - qt-spatial-abstract-reasoning-matrix-corner-step #0 correctness: shown figures do not support exactly one keyed answer
  - qt-spatial-abstract-reasoning-matrix-corner-step #0 ranges-text: unsupported form
  - qt-spatial-abstract-reasoning-matrix-corner-step #0 ranges-text: unsupported form
- content/types-held / qt-spatial-abstract-reasoning-matrix-corner-step: FAIL (3 findings); 9 / 9 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-growing-turn: NO LIST: capacity only; 16 / 80 at ceiling 10000.
- content/types-held / qt-spatial-abstract-reasoning-matrix-ray-turn: NO LIST: capacity only; 1725 / 1725 at ceiling 10000.
- qt-spatial-abstract-reasoning-matrix-ray-turn: fresh 10000 draws, correctness failures 0. No list written.
- content/types-held / qt-spatial-abstract-reasoning-group-specific-rule: NO LIST: capacity only; 45 / 45 at ceiling 10000.

## Final results and handoff

- Completed all five assigned items. Measured every one of the 13 approved and 45 held types at ceiling 10000, seed 20261117. Full checked all 17 existing lists against prod content (13 approved, four held). All 13 approved lists PASS, no approved file or list edited.
- Corrected final per-type result: content/types / qt-spatial-abstract-reasoning-matrix-size-transfer: PASS (100 variants); 192 / 960. The earlier provisional failures were a library implementation defect, fixed and covered by the existing matrix regression suite. They are not product blockers.
- Held lists: net-adjacent-relation PASS (one variant), net-opposite-hard PASS (two variants); matrix-ray-intersection FAIL (15 competing highest-ray indexes recorded above); matrix-corner-step FAIL (source index 0, unsupported circle form and correctness). Both failures were already held; neither type or list changed.
- Held ray-turn: 1725 rule-parameter sets / 1725 total versions. Held dot-sum: 151 / 751. Each separately checked 10000 fresh generated draws, including fixed source index 0: zero correctness failures. No list written or approval granted. The lead decides whether to resume them.
- Current source: HEAD 94b383b89da706583075842540f08485703bfb0e plus this unstaged patch. No staging, commits, dependency, app source, UI, content/questions, approved types, or variant lists changed. Temporary measurement scripts removed after completion.
- Files touched: FINDINGS.md; capacity.dart; solvers/solver.dart; new solvers/figure_matrices/library_solver.dart; rules/figure_matrices/matrices.dart; capacity_test.dart; cube_net_capacity_contract_test.dart; new library_growth_test.dart; two frozen reaudit-c fixture YAML files under test/tool/generator/fixtures/bad/.
- Remaining: standard test asset unavailable; seven existing analyzer findings and existing formatter failure in unchanged figure_sheets_test.dart. No visual, device, blind solve, approval, or release verification performed. Independent review and integration belong to the lead.

## Review correction, column structure

- Refreshed policy at origin/main 17f514bfb6224fa4caeb51fcc5efc2ed32da7885, matching live main by ls-remote. Fetch still cannot write external FETCH_HEAD. Existing unstaged work preserved; codex-pick reports room.
- Accepted P2: column count solvers compare non-count features across rows. A constant outline down each column must be supported, with the blank's candidate compared along that column. Add positive and negative regression coverage before changing the solver.
- RED confirmed: the new column-difference regression fails with Expected true, Actual false. SDK startup now works in this session.
- Fix preserves existing row-constant structure support and additionally accepts column-constant structure for column arithmetic. Full structure validation includes the candidate, so incorrect outlines remain rejected.

```text
COMMAND: flutter test test/tool/generator
EXIT: 1
  xml 6.6.1 (7.1.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
133 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Error detected in pubspec.yaml:
No file or variants found for asset: assets/seed/content.db.
Error: Failed to build asset bundle
```

```text
COMMAND: flutter analyze tool/generator test/tool/generator
EXIT: 1
   info • Don't cast a nullable value to a non-nullable type. Try adding a not-null assertion ('!') to make the type non-nullable • test/tool/generator/figure_sheets_test.dart:142:20 • cast_nullable_to_non_nullable
warning • The generic type 'Map<dynamic, dynamic>' should have explicit type arguments but doesn't. Use explicit type arguments for 'Map<dynamic, dynamic>' • test/tool/generator/figure_sheets_test.dart:142:55 • strict_raw_type
   info • Don't cast a nullable value to a non-nullable type. Try adding a not-null assertion ('!') to make the type non-nullable • test/tool/generator/figure_sheets_test.dart:153:16 • cast_nullable_to_non_nullable
   info • The line length exceeds the 80-character limit. Try breaking the line across multiple lines • test/tool/generator/figure_sheets_test.dart:167:81 • lines_longer_than_80_chars
   info • The line length exceeds the 80-character limit. Try breaking the line across multiple lines • test/tool/generator/figure_sheets_test.dart:247:81 • lines_longer_than_80_chars
   info • Missing a required trailing comma. Try adding a trailing comma • test/tool/generator/library_growth_test.dart:57:9 • require_trailing_commas
   info • Missing a required trailing comma. Try adding a trailing comma • test/tool/generator/library_growth_test.dart:62:13 • require_trailing_commas
9 issues found. (ran in 3.4s)
```

```text
COMMAND: dart format --output=none --set-exit-if-changed tool/generator test/tool/generator
EXIT: 1
Changed test/tool/generator/figure_sheets_test.dart
Formatted 59 files (1 changed) in 0.07 seconds.
```
- GREEN: focused library_growth_test.dart passes all 11 tests, including the supplied counts and triangle answer, plus rejection of a square answer and wrong count. Initial analyzer found two new missing commas; corrected both. Unrelated figure_sheets_test.dart findings remain untouched.

```text
COMMAND: dart run tool/checks/run_checks.dart
EXIT: 0
      accepted lib/features/quiz/presentation/practice_picker_screen.dart:1278: reads estimatedMinutes; show the lesson label instead (LessonBiteLabel) (PracticeSummary.estimatedMinutes is the length of a practice session the student sets, not a lesson)
OK    design-token-literals
OK    custom-subject-tiers
OK    letter-shortcut-gate
      accepted lib/core/ui/components/typeahead_buffer.dart:25: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:26: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
      accepted lib/core/ui/components/typeahead_buffer.dart:30: a key event character is handled outside LetterShortcuts, so the Keyboard Shortcuts setting cannot turn it off (type-ahead in Select and Popover acts only while the open list has focus, which WCAG 2.1.4 exempts)
OK    legal-text-drafting
```

```text
COMMAND: dart run tool/check_no_ai_attribution.dart
EXIT: 0
Running build hooks...Running build hooks...check_no_ai_attribution: OK
```

- Final analyzer and formatter after correcting the regression test commas:

```text
Try `flutter pub outdated` for more information.
Analyzing 2 items...                                            
   info • Don't cast a nullable value to a non-nullable type. Try adding a not-null assertion ('!') to make the type non-nullable • test/tool/generator/figure_sheets_test.dart:49:19 • cast_nullable_to_non_nullable
   info • The line length exceeds the 80-character limit. Try breaking the line across multiple lines • test/tool/generator/figure_sheets_test.dart:135:81 • lines_longer_than_80_chars
   info • Don't cast a nullable value to a non-nullable type. Try adding a not-null assertion ('!') to make the type non-nullable • test/tool/generator/figure_sheets_test.dart:142:20 • cast_nullable_to_non_nullable
warning • The generic type 'Map<dynamic, dynamic>' should have explicit type arguments but doesn't. Use explicit type arguments for 'Map<dynamic, dynamic>' • test/tool/generator/figure_sheets_test.dart:142:55 • strict_raw_type
   info • Don't cast a nullable value to a non-nullable type. Try adding a not-null assertion ('!') to make the type non-nullable • test/tool/generator/figure_sheets_test.dart:153:16 • cast_nullable_to_non_nullable
   info • The line length exceeds the 80-character limit. Try breaking the line across multiple lines • test/tool/generator/figure_sheets_test.dart:167:81 • lines_longer_than_80_chars
   info • The line length exceeds the 80-character limit. Try breaking the line across multiple lines • test/tool/generator/figure_sheets_test.dart:247:81 • lines_longer_than_80_chars
7 issues found. (ran in 5.4s)
```

```text
Changed test/tool/generator/figure_sheets_test.dart
Formatted 59 files (1 changed) in 0.09 seconds.
```

## Needs the lead, review correction verification

- Standard tests cannot bundle missing assets/seed/content.db. Analyzer reports seven existing issues, and formatter reports one existing file, both confined to unchanged figure_sheets_test.dart. No unrelated UI test or seed asset edited. Required checker and attribution commands now execute successfully. No review finding rejected.

- Supplemental full generator suite: `flutter test --no-pub --no-test-assets test/tool/generator`, exit 0: `00:42 +238 ~6: All tests passed!` (six figure-sheet tests skipped by their existing configuration).
- Review correction touches only FINDINGS.md, tool/generator/lib/src/check/solvers/figure_matrices/library_solver.dart, and test/tool/generator/library_growth_test.dart. Existing uncommitted lib1 changes preserved. `git diff --check` exits 0. No staging or commits.
