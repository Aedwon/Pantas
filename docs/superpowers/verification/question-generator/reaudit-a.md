# Task 1.4 re-audit A

Read-only re-audit of candidate `df70d4b37e1275b4c9964ff0499f0bda27ba8752`. Initial worktree clean. Policy read with `git show origin/main` at `2bd4a95172704b228c5cc6e00a67a5597d2536a4`, descendant of required `1295c1866`. Prod source: `origin/content/bite-sized-cse-algebra-r1`. Only this file is writable; the specific assignment supersedes the generic root FINDINGS.md instruction. No fixes, tests authored, staging, commits, or UI work.

## Needs the lead

- Policy freshness cannot be checked live: fetch cannot write external FETCH_HEAD, and ls-remote cannot resolve github.com. The explicitly assigned origin/main policy snapshot is readable and meets the minimum revision.

## Findings and closure evidence

Verification limitation: all five required commands were attempted before substantive auditing and exited 1 before execution. Flutter/Dart startup cannot write `/opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>` or `engine.realm` (`Operation not permitted`). This blocks executable gates, not the read-only audit. No gate pass is claimed.

qt-spatial-abstract-reasoning-series-ray-step | Major | CLOSED: the early-restart note now resolves to "the last ray again" when the displayed direction has completed a cycle. Index 99 shows 135,225,315,45,135 and selects 135 for this mistake, so the note no longer falsely says the cycle has not ended. The generator derives restartAction from first versus last ray. | evidence: content/types/reasoning/spatial-abstract-reasoning/figure-turns-and-positions/qt-spatial-abstract-reasoning-series-ray-step.yaml and matching .variants.yaml, index 99; tool/generator/lib/src/rules/figure_series/series.dart, restartAction.

qt-spatial-abstract-reasoning-group-polygon-replacement | Minor | OPEN: the earlier fixed-distractor/low-reasoning-variety finding remains. Every sampled generated variant offers one polygon against the same circle, curved blob, and dotted circle. The row can be ignored. Fix-a explicitly defers this limitation to the lead; no new answer ambiguity was found. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-polygon-replacement.variants.yaml, indexes 0,10,20,30,40,50,60,70,80,90,99; tool/generator/lib/src/rules/figure_grouping/grouping.dart, polygon-replacement choices.

qt-spatial-abstract-reasoning-group-dot-parity | Minor | CLOSED: generated rows now contain exactly one hexagon, making the six-sided-outline cue distinguish the named choice. Index 80 now has blob, square, triangle, hexagon, rather than three hexagons. Generator enforces exactly one hexagon. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-dot-parity.variants.yaml, index 80 and all 100 rows; tool/generator/lib/src/rules/figure_grouping/grouping.dart, dot-parity hexagon-count guard.

qt-spatial-abstract-reasoning-matrix-dot-sum | Blocker | NEW: index 56 has two completed rows with counts 1,2,3. Each row equally supports adding the inputs or continuing their difference. The target starts 1,3, so the keyed 4 and add-sequence-step choice 5 are both defensible. Fixing the mistake to compute 2b-a makes that offered alternative exact. MatrixSolver tests only addition for these figure keys; there is no competing arithmetic-sequence matrix solver. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, index 56; tool/generator/lib/src/rules/figure_matrices/matrices.dart, add-sequence-step; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, dot-sum; tool/generator/lib/src/check/solvers/solver.dart, registry.

qt-spatial-abstract-reasoning-matrix-ray-turn | Blocker | OPEN, partial fix: the left-to-right reflection counterexamples are excluded, but up-to-down reflection of the internal ray still supports a wrong choice. At index 57 the top circle changes NE (45) to SE (135), equally explained by a 90-degree clockwise turn or an up-to-down reflection of the ray. The bottom triangle starts E (90); reflecting its ray keeps E, the hold-ray choice, while the key turns to S (180). Both readings keep each row outline fixed, as the intended rule also does when turning the internal ray. Index 63 has the same completed row with a W target, also held under reflection. The new solver hardcodes only 360-angle, and the generator only excludes that left-to-right transform. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml, indexes 57,63; tool/generator/lib/src/rules/figure_matrices/matrices.dart, ray-turn reflection guard; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, reflectRays.

## Needs the lead, correctness

- Rule on the remaining ray-only reflection ambiguity and the new dot-sum arithmetic-sequence ambiguity before approving these types. No fix was made. The affected two types fail this audit; other types continue.

## Whole-list read-only checks

Independent Python inspection of committed JSON rows, without importing generator or solver code. Recomputed intended answers and exact mistake values. Compared grouping as unordered multisets with keyed shapes marked, and series/matrices under whole-task rotations and reflections with drawn-feature orientation. Wrong choices do not add capacity. These checks do not prove absence of competing human rules.

```text
series-fill-ray-dots: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 85 stored ruleKeys; freeze checks 0, left-column 0
series-four-tracks: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 0, left-column 0
series-ray-step: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 51 stored ruleKeys; freeze checks 0, left-column 0
group-polygon-replacement: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 0, left-column 0
group-dot-count: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 0, left-column 0
group-dot-parity: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 0, left-column 0
matrix-ray-turn: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 100, left-column 0
matrix-size-dots: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 24 stored ruleKeys; freeze checks 100, left-column 35
matrix-form-ray: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 100, left-column 38
matrix-size-transfer: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 81 stored ruleKeys; freeze checks 200, left-column 76
matrix-dot-sum: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 85 stored ruleKeys; freeze checks 0, left-column 0
matrix-outline-latin: 100 variants; 100 canonical tasks; 100 raw ordered tasks; 100 stored ruleKeys; freeze checks 0, left-column 0
AUDIT DATA CHECK: 12 types, 1200 variants, 0 intended-key/mistake/slot/voice errors
```

## Remaining earlier-finding dispositions

qt-spatial-abstract-reasoning-matrix-size-dots | Major | CLOSED: freeze-dots now copies the neighboring cell in the same row, including left-column blanks, and the note says "adjacent". At index 19 the correct count is 3 and the distractor is the right neighbor's 4, not the preceding row's 5; index 59 similarly copies 3, not 4. All 100 stored variants pass the independent neighbor-value check. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-dots.yaml and matching .variants.yaml, indexes 19,59; tool/generator/lib/src/rules/figure_matrices/matrices.dart; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart.

qt-spatial-abstract-reasoning-matrix-form-ray | Major | CLOSED: freeze-ray uses a same-row neighbor and says "adjacent". At index 19 the NW blank's distractor is the E ray to its right. At index 29 the SE blank's distractor is the neighboring SW ray. All 100 stored variants pass the independent neighbor-value check. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-form-ray.yaml and matching .variants.yaml, indexes 19,29; tool/generator/lib/src/rules/figure_matrices/matrices.dart; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart.

qt-spatial-abstract-reasoning-matrix-size-transfer | Major | CLOSED: both freeze notes now say "adjacent", and both wrong values come from the same-row neighbor. At the top-left blank in index 29, the key has 2 dots and 4 edge lines; the adjacent cell has 3 dots and 3 lines, exactly the two distractor values. All 200 freeze choices pass, including 76 choices at left-column blanks. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-size-transfer.yaml and matching .variants.yaml, indexes 19,29; tool/generator/lib/src/rules/figure_matrices/matrices.dart; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart.

qt-spatial-abstract-reasoning-matrix-dot-sum | Major | CLOSED for the earlier fixed-2 filler: the sequence mistake now equals 2b-a for every stored variant. Index 9 has target inputs 1,3 and gives 5; index 59 has target inputs 2,3 and gives 4. The new counting-sequence ambiguity at index 56 remains a separate Blocker above. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.yaml and matching .variants.yaml, indexes 9,59; tool/generator/lib/src/rules/figure_matrices/matrices.dart; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart.

qt-spatial-abstract-reasoning-matrix-outline-latin | Minor | CLOSED: all 100 stored variants now have distinct shown-grid plus correct-answer tasks, independently checked under D4. The generator and solver no longer include distractor-only extraForm in rule parameters; it remains only a rendering/mistake slot. Indexes 2 and 9 now have different grids. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-row-and-column-rules/qt-spatial-abstract-reasoning-matrix-outline-latin.yaml and matching .variants.yaml, indexes 2,9; tool/generator/lib/src/rules/figure_matrices/matrices.dart; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart.

No earlier per-type finding exists in audit-a.md or audit-b.md for series-fill-ray-dots, series-four-tracks, or group-dot-count. Their prior no-Major/no-Blocker assessment was rechecked. All earlier entries for the other nine assigned types are dispositioned above: seven CLOSED, polygon-replacement Minor OPEN, ray-turn Blocker OPEN with a narrower remaining counterexample.

Evidence correction to the matrix-dot-sum CLOSED entry: current index 9 has target inputs 2,3 and gives sequence distractor 4, just like index 59. The entry's statement that current index 9 has 1,3 was a transcription error. The all-100 2b-a verification and closure conclusion are unchanged.

## Source, wording, and variety evidence

Read all 12 type files, matching rules and solvers, and samples 0,10,20,30,40,50,60,70,80,90,99 from each list, plus the cited regression and counterexample indexes. Read all 12 reserved source questions from prod using git show, never local content/questions. Read the seven referenced prod lessons and their key points.

```text
PROD SOURCE AND DESCRIPTION CHECK: 12 reserved variants; 3564 generated figure-choice descriptions; 0 mismatches
group-polygon-replacement: 56 unordered shown rows
group-dot-count: 100 unordered shown rows
group-dot-parity: 100 unordered shown rows
matrix-dot-sum: target-input pairs {(1, 3): 57, (2, 3): 43}
```

The source comparisons cover figure data, keyed/wrong choice text, and resolved stem. The generated-label check covers outlines, sizes, counts, and compass directions. Manual wording review found no additional open Major or Blocker: explanations stay on the correct answer, notes name feature-based mistakes with a reason and check, and sampled content fits the claimed lesson/key point. No appearance or visual acceptance is claimed.

Variety judgment: exact task repetition has been removed from these lists. The two combined series vary multiple feature tracks. Ray-step varies turn size, length, start and constant outline, with 51 ruleKeys; size-dots has 24 ruleKeys and relies on permitted constant-outline cosmetics for part of its capacity. Form-ray, size-transfer, outline-latin and both dot groups vary their shown data meaningfully within one skill. Dot-sum now has only two target input pairs (1,3 and 2,3), despite varying the completed rows and outlines; this is limited answer variety, in addition to its recorded correctness Blocker. Polygon-replacement retains the OPEN Minor noted above.

## Required command results

All commands exited 1 during SDK startup, before their own checks ran. No test assertion, analyzer, formatter, repository-check, or attribution result is available from this sandbox. Actual common output:

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

- `flutter test test/tool/generator`: FAIL to execute, exit 1, SDK cache write denied.
- `flutter analyze tool/generator test/tool/generator`: FAIL to execute, exit 1, SDK cache write denied.
- `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`: FAIL to execute, exit 1, SDK cache write denied.
- `dart run tool/checks/run_checks.dart`: FAIL to execute, exit 1, SDK cache write denied.
- `dart run tool/check_no_ai_attribution.dart`: FAIL to execute, exit 1, SDK cache write denied.

Only reaudit-a.md was written. Final git status shows only this untracked findings file, and the index is empty. git diff --check exits 0. No source, content/questions, UI, dependency, generated file, test, staging, or commit change. Lead work remaining: resolve the two correctness blockers, rerun required commands in a writable SDK environment, handle the deferred polygon-replacement Minor, and perform approval/blind-solve steps. No held or out-of-scope net type was audited.

## Per-type verdicts

PASS means no open Blocker or Major in this read-only audit. It does not mean gates or type approval passed.

qt-spatial-abstract-reasoning-series-fill-ray-dots | PASS
qt-spatial-abstract-reasoning-series-four-tracks | PASS
qt-spatial-abstract-reasoning-series-ray-step | PASS
qt-spatial-abstract-reasoning-group-polygon-replacement | PASS
qt-spatial-abstract-reasoning-group-dot-count | PASS
qt-spatial-abstract-reasoning-group-dot-parity | PASS
qt-spatial-abstract-reasoning-matrix-ray-turn | FAIL
qt-spatial-abstract-reasoning-matrix-size-dots | PASS
qt-spatial-abstract-reasoning-matrix-form-ray | PASS
qt-spatial-abstract-reasoning-matrix-size-transfer | PASS
qt-spatial-abstract-reasoning-matrix-dot-sum | FAIL
qt-spatial-abstract-reasoning-matrix-outline-latin | PASS
