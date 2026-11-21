# Task 1.4 second re-audit C

Read-only audit of matrix-ray-turn and matrix-dot-sum at candidate f8b12b9fada2cf979de93ae7bbe03deee0db28e4. Initial worktree clean. Only this findings file is writable, superseding the generic root FINDINGS.md instruction. No implementation, content, test, UI, staging, or commit change is authorized. Policy read from origin/main f417e5f6c438b6f0043386e1124af2a006f20318, confirmed descendant of 1295c1866. Estimate: 35 minutes; lead owns velocity and status integration.

## Needs the lead

- Policy freshness cannot be checked live: fetch cannot write external FETCH_HEAD, and git ls-remote cannot resolve github.com. The explicitly assigned origin/main policy is readable and meets the minimum revision. This limits freshness verification, not inspection of the assigned candidate.

## Findings and evidence

- Decision recovered: fix-c-findings.md records the lead ruling at Nov 17 09:00 UTC. Dot-sum reserved index 0 keeps its source row 1,2,3 because the second completed row rules out continuation. New draws exclude row-level equality. This audit follows that ruling.

- Verification blocker found before substantive auditing: all five required commands exit 1 during SDK startup, before checks execute. The Flutter wrapper cannot write outside the sandbox. No gate pass is claimed. Actual common output:

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

Commands attempted: `flutter test test/tool/generator`; `flutter analyze tool/generator test/tool/generator`; `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`; `dart run tool/checks/run_checks.dart`; `dart run tool/check_no_ai_attribution.dart`. Each exits 1 with the output above. Continue the authorized read-only audit; the lead needs executable gate evidence from a writable SDK environment.

qt-spatial-abstract-reasoning-matrix-ray-turn | Blocker | NEW: diagonal reflection of the internal ray gives an equally simple rule with a different offered answer. Index 6 changes the top triangle ray W (270) to N (0). Both a 90-degree clockwise turn and reflection across the NW-to-SE diagonal explain this. The bottom star starts NW (315). The turn keys NE (45), but diagonal reflection keeps NW, exactly the hold-ray choice. Both rules preserve each row outline. The fix checks only horizontal and vertical ray reflection, omitting the two diagonal axes. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml, index 6; tool/generator/lib/src/rules/figure_matrices/matrices.dart, ray-turn guard `[180, 360]`; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, reflectRays/reflectRaysUpDown; tool/generator/lib/src/check/solvers/solver.dart, reflection registrations.

qt-spatial-abstract-reasoning-matrix-dot-sum | Blocker | NEW: multiplication supports a different offered answer at index 53. Both completed rows are 2,2,4, equally explained by addition or multiplication. The target inputs 1,3 give keyed sum 4 or product 3, exactly the copy-second choice. The new counting-sequence competitor and equality guard do not address multiplication. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, index 53; tool/generator/lib/src/rules/figure_matrices/matrices.dart, dot-sum input guard; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, dot-sum; tool/generator/lib/src/check/solvers/solver.dart, no product-matrix competitor.

qt-spatial-abstract-reasoning-matrix-dot-sum | Blocker | NEW: simple column rules also produce offered alternatives. Index 68 has rows 1,4,5 / 2,1,3 / 1,3,blank. In each complete column, the bottom count is the absolute difference of the top two: |1-2|=1 and |4-1|=3. The last column then gives |5-3|=2, exactly subtract-inputs, while the row sum keys 4. The stem explicitly permits row and column rules. Indexes 79 and 95 similarly fit top divided by middle in both complete columns, then 4/2=2 rather than keyed 4. The solver library checks dot arithmetic only across rows. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, indexes 68,79,95; tool/generator/lib/src/check/solvers/figure_matrices/matrix_solver.dart, dot-sum checks row triples only.

qt-spatial-abstract-reasoning-matrix-ray-turn | Blocker | CLOSED: the specific reaudit-a horizontal/vertical reflection defect is removed. All 100 completed example rows reject both transforms (360-a)%360 and (180-a)%360. Current indexes 57 and 63 no longer reproduce the prior counterexamples. Both competitors are registered independently, and the preserved index-57 fixture is covered by reaudit_regression_test.dart. This closes the old defect only; the new diagonal-reflection Blocker remains. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml, indexes 0..99, especially 57,63; tool/generator/lib/src/check/solvers/solver.dart; test/tool/generator/reaudit_regression_test.dart.

qt-spatial-abstract-reasoning-matrix-dot-sum | Blocker | CLOSED: the specific reaudit-a arithmetic-continuation ambiguity is removed. No stored variant has both completed rows fitting 2b-a. All newly generated indexes 1..99 exclude equality in each completed row. Reserved index 0 alone has row 0 equal to 1,2,3, but row 1 is 2,2,4 and rejects continuation, as the lead explicitly allowed. Current index 56 has rows 2,2,4 and 2,3,5, which both reject continuation. The independent continuation competitor is registered and the old index-56 fixture is covered by reaudit_regression_test.dart. This closes the old defect only; the new multiplication/column-rule Blockers remain. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, indexes 0,56 and 1..99; docs/superpowers/verification/question-generator/fix-c-findings.md, Nov 17 09:00 UTC ruling; tool/generator/lib/src/check/solvers/solver.dart; test/tool/generator/reaudit_regression_test.dart.

Independent whole-list inspection, using Python standard-library parsing of committed JSON rows, without importing Dart generator or solver code:

```text
ray-turn: 100 variants; 100 stored signatures; 100 stored ruleKeys; 400 labels checked; 0 intended-key/mistake/label/slot/voice errors; old competitor fits []; completed-row equality []
dot-sum: 100 variants; 100 stored signatures; 79 stored ruleKeys; 400 labels checked; 0 intended-key/mistake/label/slot/voice errors; old competitor fits []; completed-row equality [(0, 0)]
```

## Source and sampled wording

Read both complete type files, their shared rule and independent solver, solver registrations, regression tests, and samples 0,10,20,30,40,50,60,70,80,90,99, plus counterexamples and earlier regression indexes. Read the two reserved source questions and both referenced lessons/key points from prod using git show. No local content/questions file was used.

```text
ray-turn: reserved index 0 source figure, stem, key text, wrong text set and original order MATCH
dot-sum: reserved index 0 source figure, stem, key text, wrong text set and original order MATCH
```

Both types fit their named lesson/key point: line turns for Matrix Turns and Counts, and combining counts for Keeping All Features. The stems match the prod exam-style stem. Explanations use short plain English and discuss only the intended correct rule. All six notes identify a plausible mistake, explain its appeal, and give a relevant check. Their wording contains no fixed changing counts, directions, or shapes. No additional wording or named-mistake defect was found beyond choices that become defensible under the competing rules reported above. All 800 choice labels match figure data; index-0 labels were checked separately against the prod wording and figure data. No screen change or visual acceptance is proposed or claimed.

## Variety

qt-spatial-abstract-reasoning-matrix-dot-sum | Minor | OPEN: limited target and answer variety persists. All 100 targets use only 1,3 (56 variants) or 2,3 (44 variants), giving only two numerical choice sets. There are 79 distinct numeric shown grids; the other capacity comes from permitted constant-outline cosmetics. Completed rows vary and exact tasks do not repeat, but the target calculation soon feels familiar. This is a variety limitation, separate from the correctness Blockers. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, indexes 0..99, e.g. 0,10,20,30,40,50,60,70,80,90,99.

Ray-turn varies starting directions, row outlines, and steps: 42 use 45 degrees, 20 use 90 degrees, and 38 use 135 degrees. Its 100 ruleKeys and distinct displayed tasks provide meaningful variation within this one skill. Dot-sum varies completed row counts and constant outlines; its limited target variety is recorded above.

Independent D4 comparison transformed grid positions, ray directions, outline orientation, dot-layout orientation, and the correct answer together; distractors and wording did not add capacity:

```text
ray-turn: 100 distinct shown-grid plus correct-answer tasks under whole-task D4 transforms
dot-sum: 100 distinct shown-grid plus correct-answer tasks under whole-task D4 transforms; 79 numeric shown grids
```

## Additional counterexample coverage

qt-spatial-abstract-reasoning-matrix-ray-turn | Blocker | Additional evidence for the new diagonal-reflection finding: eight stored variants admit the hold-ray answer under a diagonal reflection, at indexes 6,12,29,37,43,59,81,89. For example, index 59 changes the top square N to E, fitting reflection across NE-to-SW; the bottom triangle SW stays SW under that reflection, while the key turns it to NW. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-turns-and-counts/qt-spatial-abstract-reasoning-matrix-ray-turn.variants.yaml, indexes 6,12,29,37,43,59,81,89.

qt-spatial-abstract-reasoning-matrix-dot-sum | Blocker | Additional evidence for the new column-rule finding: keeping the larger count down each column supports a wrong choice at indexes 1,10,28,35,70; keeping the smaller supports a wrong choice at 69,90. At index 10, rows are 2,1,3 / 1,3,4 / 2,3,blank: each bottom count can be the larger of the two above it, producing offered 4 instead of keyed 5. Combined with difference at 68 and division at 79,95, ten stored variants admit a simple column-rule alternative. | evidence: content/types/reasoning/spatial-abstract-reasoning/matrix-keeping-all-features/qt-spatial-abstract-reasoning-matrix-dot-sum.variants.yaml, indexes 1,10,28,35,68,69,70,79,90,95.

## Needs the lead: correctness and verification

- Both reaudit-a Blockers are CLOSED in their specific reported forms. Neither type is eligible for approval because the new Blockers above remain open. Resolve those through the implementation/content process, then repeat checker, blind solve, and independent audit. No fix was made here.
- The lead's dot-sum reserved-source exception remains honored. No source correction is requested for index 0 by this audit.
- Required executable gates remain unverified because the SDK wrapper cannot write its external cache. The read-only mathematical inspection is supplemental evidence and is not a substitute for those gates. No blind solve, ledger approval, figure sheet, device test, or visual acceptance was performed.

## Required command results

All five commands were attempted before substantive auditing. Each exited 1 during SDK startup. There are no test/analyzer/formatter/checker summary lines because their code never started. The exact common error is preserved above.

- FAIL to execute: `flutter test test/tool/generator`, exit 1, `engine.stamp.tmp.27913` and `engine.realm`: `Operation not permitted`.
- FAIL to execute: `flutter analyze tool/generator test/tool/generator`, exit 1, `engine.stamp.tmp.27944` and `engine.realm`: `Operation not permitted`.
- FAIL to execute: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, exit 1, `engine.stamp.tmp.27975` and `engine.realm`: `Operation not permitted`.
- FAIL to execute: `dart run tool/checks/run_checks.dart`, exit 1, `engine.stamp.tmp.28044` and `engine.realm`: `Operation not permitted`.
- FAIL to execute: `dart run tool/check_no_ai_attribution.dart`, exit 1, `engine.stamp.tmp.28075` and `engine.realm`: `Operation not permitted`.

## Per-type verdicts

PASS means no open Blocker or Major in this audit, independently of executable gates or approval status.

qt-spatial-abstract-reasoning-matrix-ray-turn | FAIL
qt-spatial-abstract-reasoning-matrix-dot-sum | FAIL
