# Held abstract reasoning types

- Policy c6feb916b matches remote main and includes 0172e8dfb. Fetch could not write shared FETCH_HEAD. Prod ref resolves to d97de9415.

## Needs the lead

- series-fill-ray-dots #0, mistake value: live 0018 shows three-quarter and half fills. Their sum is 1.25, outside the drawable levels, while the source offers full. Exact source reproduction and the new arithmetic check cannot both pass. Preserve index 0 for checking, keep the type held, and measure the non-source fix independently.

## Regression evidence

- RED: both planted audit versions reproduced the checker misses. The generator arithmetic test also failed. Four diagonal solver registrations were absent.
- The two source questions were read from the CET production ref. The existing merged-source comparisons passed on their pre-fix index 0 data.

- matrix-ray-intersection candidate: 100 distinct ruleKeys and 100 signatures. Full candidate check, answer variety and live 0009 reproduction pass. Stored the regenerated candidate alongside its held definition pending lead approval. Its generator rejects wrong choices accepted by any registered matrix solver.
- series-fill-ray-dots candidate: 61 distinct ruleKeys and 100 signatures. Full check returns exactly one failure, `#0 choices: choice differs from mistake accumulate-fill`. The 99 new versions pass, including answer variety for the complete candidate. Kept this candidate out of the release tree.
- Capacity run at ceiling 2,000 and seed 20261117, deduplicated by signature: matrix 2,000 ruleKeys / 2,000 signatures (ceiling reached); series 87 ruleKeys / 345 signatures. Series counts include the reserved source, which fails its mistake check.
- Focused regression and sheet findings tests: `00:02 +18: All tests passed!`

## Production-root sweep

The merged-source and full variant checks against d97de9415 covered all 28 active types and both held candidates. Counts below are for the lists checked, after deduplication. The 28 active types were read without edits.

| Type | Distinct ruleKeys | Total signatures | Checker |
|---|---:|---:|---|
| `series-fill-ray-dots` | 61 | 100 | FAIL |
| `matrix-ray-intersection` | 100 | 100 | PASS |
| `series-dots-size` | 16 | 80 | PASS |
| `series-four-tracks` | 100 | 100 | PASS |
| `series-interleaved-count` | 100 | 100 | PASS |
| `series-size-corner-ray` | 48 | 48 | PASS |
| `series-transfer-count` | 9 | 45 | PASS |
| `series-binary-fill` | 6 | 24 | PASS |
| `series-ray-step` | 47 | 100 | PASS |
| `net-three-at-corner` | 64 | 64 | PASS |
| `group-boundary` | 42 | 42 | PASS |
| `group-polygon-replacement` | 100 | 100 | PASS |
| `group-dot-count` | 100 | 100 | PASS |
| `group-dot-parity` | 100 | 100 | PASS |
| `group-side-double-dots` | 68 | 68 | PASS |
| `matrix-dot-sum` | 77 | 100 | PASS |
| `matrix-fill-union` | 12 | 24 | PASS |
| `matrix-ray-union` | 100 | 100 | PASS |
| `matrix-sized-ray-union` | 72 | 100 | PASS |
| `matrix-binary-fill-row` | 32 | 32 | PASS |
| `matrix-form-ray` | 100 | 100 | PASS |
| `matrix-outline-latin` | 100 | 100 | PASS |
| `matrix-size-dots` | 18 | 55 | PASS |
| `matrix-size-fill` | 12 | 40 | PASS |
| `matrix-size-latin` | 72 | 72 | PASS |
| `matrix-size-transfer` | 81 | 100 | PASS |
| `matrix-arrow-column` | 6 | 30 | PASS |
| `matrix-corner-reflection` | 100 | 100 | PASS |
| `matrix-growing-turn` | 14 | 70 | PASS |
| `matrix-ray-turn` | 100 | 100 | PASS |

## Needs the lead

- `qt-spatial-abstract-reasoning-series-fill-ray-dots #0 choices: choice differs from mistake accumulate-fill`
- Checked 30 types. 29 passed and 1 failed.

- The existing series source regression expected no errors for live 0018. It now asserts the exact held-source mistake failure and still fails on any source reproduction discrepancy.

## Candidate files

Workstream base `9f551066a` plus the unstaged worker changes below. The pre-existing brief changes are outside this list.

- `content/types-held/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-fill-ray-dots.yaml`
- `content/types-held/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection.variants.yaml`
- `tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart`
- `tool/generator/lib/src/check/solvers/figure_series/series_solver.dart`
- `tool/generator/lib/src/check/solvers/solver.dart`
- `tool/generator/lib/src/rules/figure_matrices/matrices.dart`
- `tool/generator/lib/src/rules/figure_series/series.dart`
- `tool/generator/lib/src/rules/figure_series/sources.dart`
- `test/tool/generator/fixtures/bad/held2.yaml`
- `test/tool/generator/held2_regression_test.dart`
- `test/tool/generator/series_rules_test.dart`
- `FINDINGS.md` and `FINDINGS-held2.md`

## Verification

- PASS `flutter analyze tool/generator test/tool/generator`: `No issues found! (ran in 24.6s)`.
- PASS `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: `Formatted 65 files (0 changed) in 1.21 seconds.`
- PASS `dart run tool/check_no_ai_attribution.dart`: `check_no_ai_attribution: OK`.
- PASS focused live 0018 regression, `00:09 +1: All tests passed!` The matrix candidate replay at count 100 passed.
- PASS `git diff --check`. The Git index was empty.
- PASS `dart run tool/checks/run_checks.dart`. Summary includes `OK    generated-types`, `OK    content-approval`, and `OK    legal-text-drafting`.
- PASS `dart tool/generator/bin/check.dart --questions-ref origin/content/cet-bite-r1`, exit 0 and no diagnostics. The full 30-type sweep above separately includes both held candidates because the standard CLI only checks held definitions and solver registration.
- Capacity at ceiling 10,000 and seed 20261117, deduplicated by signature:
  - matrix-ray-intersection measured 9,966 distinct ruleKeys and 9,966 total signatures.
  - series-fill-ray-dots measured 87 distinct ruleKeys and 345 total signatures, including the failing reserved source.
- PASS `flutter test test/tool/generator`: `04:10 +290 ~10: All tests passed!`

## Held2 review follow-up

- Policy ref observed at 80f0c8ef5. Version 46 reproduces a geometry gap: the renderer clips rays to 80% of the outline distance, capped at 80% of the radius. The upper-left ray wins in the circle but is shorter than the projected up ray in the triangle.
- B5.1 requires independence. The matrix generator currently calls the checker while drawing.
- Needs the lead: series-fill-ray-dots #0 still requires a source-lane ruling. Production 0018 gives 1.25 for the named mistake and offers full. The exact live source must be preserved.
- Remote main is e8f12c872. Its policy blobs are available locally and were used when the shared Git directory denied FETCH_HEAD writes. The three startup policy files match 80f0c8ef5. The newer process rule concerns hosted runs, and these checks run locally.
- RED confirmed: the planted version 46 Flutter test failed because the checker returned no correctness diagnostic.
- Added independent ray-tip ranking to the checker in all eight directions alongside angle-only selection. The generator now screens its raw draws with a separate trigonometric calculation and no checker solver calls.

## Held2 resumption

- Policy origin/main 9b7567092 matches remote main. The paused commit includes the version 46 regression and the independent implementations. The held matrix list still needs regeneration and a fresh production-root sweep.
- The direct Dart checker rejects the planted version 46 for correctness. This probe did not run Flutter tests. The shared Git directory denied FETCH_HEAD writes. Remote main matched the readable local ref.
- Regenerated the held matrix candidate at seed 20261117. The merged-source and full variant sweep against d97de9415 checked 30 types. All 28 active types and the matrix passed. Matrix has 100 distinct ruleKeys and 100 signatures. Series has 61 and 100, with only index 0 failing.

### Needs the lead

- series-fill-ray-dots #0 choices: choice differs from mistake accumulate-fill. The source must stay a single until the content lane resolves 0018. The 99 generated versions passed.

### Fresh production-root sweep

| Type | Distinct ruleKeys | Total signatures | Checker |
|---|---:|---:|---|
| series-dots-size | 16 | 80 | PASS |
| series-four-tracks | 100 | 100 | PASS |
| series-interleaved-count | 100 | 100 | PASS |
| series-size-corner-ray | 48 | 48 | PASS |
| series-transfer-count | 9 | 45 | PASS |
| series-binary-fill | 6 | 24 | PASS |
| series-ray-step | 47 | 100 | PASS |
| net-three-at-corner | 64 | 64 | PASS |
| group-boundary | 42 | 42 | PASS |
| group-polygon-replacement | 100 | 100 | PASS |
| group-dot-count | 100 | 100 | PASS |
| group-dot-parity | 100 | 100 | PASS |
| group-side-double-dots | 68 | 68 | PASS |
| matrix-dot-sum | 77 | 100 | PASS |
| matrix-fill-union | 12 | 24 | PASS |
| matrix-ray-union | 100 | 100 | PASS |
| matrix-sized-ray-union | 72 | 100 | PASS |
| matrix-binary-fill-row | 32 | 32 | PASS |
| matrix-form-ray | 100 | 100 | PASS |
| matrix-outline-latin | 100 | 100 | PASS |
| matrix-size-dots | 18 | 55 | PASS |
| matrix-size-fill | 12 | 40 | PASS |
| matrix-size-latin | 72 | 72 | PASS |
| matrix-size-transfer | 81 | 100 | PASS |
| matrix-arrow-column | 6 | 30 | PASS |
| matrix-corner-reflection | 100 | 100 | PASS |
| matrix-growing-turn | 14 | 70 | PASS |
| matrix-ray-turn | 100 | 100 | PASS |
| matrix-ray-intersection | 100 | 100 | PASS |
| series-fill-ray-dots | 61 | 100 | FAIL |

`Checked 30 types. 29 passed, 1 failed.`

- Regeneration produced a byte-identical matrix list. The paused commit already contained the regenerated candidate.
- PASS direct SDK format, exit 0. `Formatted 65 files (0 changed) in 0.09 seconds.`
- PASS direct SDK attribution check, exit 0. `check_no_ai_attribution: OK`.
- PASS direct SDK repository checks, exit 0. All 15 checks reported OK, including `OK    generated-types`, `OK    content-approval`, and `OK    legal-text-drafting`.
- Flutter tests and analysis were left for the lead under the machine cap.
- Fresh capacity at 10,000 draws and seed 20261117: matrix 9,961 distinct ruleKeys and 9,961 signatures, series 87 distinct ruleKeys and 345 signatures. The series capacity includes the failing reserved source.
- `git diff --check` passed and the Git index is empty. Only the two findings files changed on resumption.
