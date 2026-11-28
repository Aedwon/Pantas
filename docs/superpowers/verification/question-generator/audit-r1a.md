# Task 1.4, Revision 1 audit A

Read-only audit of the ten assigned active types. Candidate HEAD: `2d727d231cb531555b8af668ca7964f9f4223a7d`. Initial worktree clean. Policy read with `git show origin/main:<path>` at `17f514bfb6224fa4caeb51fcc5efc2ed32da7885`, a descendant of required `1295c1866`. Revision 1 and later adviser rulings read from origin/main; task code, plan and earlier audit evidence read on the candidate. Only this findings file may be written; no fixes, staging or commits.

## Needs the lead

- Environment: `git fetch origin main` failed because the sandbox denies writing the shared worktree `FETCH_HEAD`. Required policy files and Revision 1 rulings are available from the supplied origin/main ref, which meets the requested minimum revision. Proceeding with the explicitly requested `git show origin/main` policy source; cannot certify a fresh fetch.

## Findings and evidence

- Verification environment: `flutter test test/tool/generator` exited 1 before loading tests. Flutter tried to write `/opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.*` and `engine.realm`, outside the sandbox. No test result is available from that command.

qt-spatial-abstract-reasoning-series-corner-edge-count | Major | The explanation and freeze-dot/skip-corner notes describe a clockwise walk around corners of the outline, but 32 of 40 variants substitute a circle, triangle, pentagon or star for the square while keeping four square-corner positions. A circle has no corners; a triangle cannot have top-left, top-right, bottom-right and bottom-left corners. This repeats the earlier size-corner-ray defect in another type. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-corner-edge-count.yaml, explanation and notes; matching .variants.yaml, indexes 1 (circle), 4 and 10 (triangle); tool/generator/lib/src/rules/figure_series/series.dart, state corner-edge-count; tool/generator/lib/src/check/solvers/figure_series/series_solver.dart, corner-edge-count accepts the same four-position walk without checking outline corners.

qt-spatial-abstract-reasoning-group-line-count | Major | choose-first and choose-central are position-only picks rather than meaningful line-count mistakes. All three wrong circles are identical. The generator and solver select the first and second positions solely by row index, so the notes cannot diagnose why one identical circle was chosen instead of another. R3 explicitly rejects position-only picks. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-line-count.yaml, choose-first and choose-central; matching .variants.yaml, indexes 0, 1, 4 and 10; tool/generator/lib/src/rules/figure_grouping/grouping.dart and tool/generator/lib/src/check/solvers/figure_grouping/grouping_solver.dart, positional filters i == 0 and i == 1.

qt-spatial-abstract-reasoning-group-line-count | Major | The choose-central note always says "The two cuts intersect visibly" and miscount-repeated-cuts always says "It repeats the two-line figure. Trace both full cuts." Generated common counts include 0, 1, 3 and 4, so those notes teach false figure descriptions. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-line-count.yaml, named notes; matching .variants.yaml, index 1 (three lines), 4 (four lines), 10 (one line); tool/generator/lib/src/rules/figure_grouping/grouping.dart, common = r.nextInt(5) and unslotted notes.

qt-spatial-abstract-reasoning-group-center-cuts | Major | Extrema-based distractors still accept tied counts. At index 18 all four circles have four lines: fewest-lines, even-line-count and most-regions are assigned to three identical centered circles by row order. No circle has a smaller line set or a count that stands out; every count is even. These are filler diagnoses, including the tied-maximum case R3 rejects. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.yaml, named notes; matching .variants.yaml, index 18; tool/generator/lib/src/rules/figure_grouping/grouping.dart, extrema retain ties then allocate remaining positions; tool/generator/lib/src/check/solvers/figure_grouping/grouping_solver.dart, only most-dots rejects tied maxima. Indexes 4, 6, 8, 12 and 16 also assign most-regions to one of tied maxima.

Verification environment, remaining assigned commands: `flutter analyze tool/generator test/tool/generator`, `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, `dart run tool/checks/run_checks.dart`, and `dart run tool/check_no_ai_attribution.dart` all exited 1 before executing their checks. Each reported `update_engine_version.sh: line 71: .../cache/engine.stamp.tmp.*: Operation not permitted` and `line 78: .../cache/engine.realm: Operation not permitted`. No product failures or passes can be inferred. No SDK files were changed.

qt-spatial-abstract-reasoning-group-specific-rule | Minor | PARTLY CLOSED: the earlier duplicate-capacity problem is removed, but the earlier narrow-variety limitation remains. Thirty of the 45 distinct tasks key exactly four sides, and every generated stem explicitly narrows the task to side count while reusing the same three broad distractor rules. The list is honest about its size, but repeated practice still heavily favors quadrilaterals. This does not block approval. | evidence: content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.variants.yaml, all 45 rows; indexes 22,26,31,35,40,44; tool/generator/lib/src/rules/figure_grouping/grouping.dart, specific-rule stem/choices. Earlier finding: audit-a.md, group-specific-rule variety Minor.

Additional evidence for the group-line-count position-only finding: every key is Figure 3 or Figure 4 (10 variants each). Figure 1 and Figure 2 are always wrong because the mistake allocator reserves them. This creates a stable answer clue even when answer choices are shuffled. All 20 variants checked.

## Earlier findings rechecked

qt-spatial-abstract-reasoning-series-size-corner-ray | Major | CLOSED: the audit-a non-square-corners defect is removed. All 48 variants use square outlines, and both generator and solver require a square for this rule. The three notes now remain true across their changing sizes, corners and rays. | evidence: content/types/reasoning/spatial-abstract-reasoning/combined-and-mixed-figure-patterns/qt-spatial-abstract-reasoning-series-size-corner-ray.variants.yaml, indexes 0..47, including 10; tool/generator/lib/src/rules/figure_series/series.dart, square guard; tool/generator/lib/src/check/solvers/figure_series/series_solver.dart, _initialValid.

qt-spatial-abstract-reasoning-group-boundary | Minor | CLOSED: the audit-a repeated-outline distractors are removed. Every current row has four distinct outlines. All 42 rows are distinct as unordered figure sets, and the selected equal-length, different-side-count and elongated shapes satisfy their named features. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-outlines-and-symmetry/qt-spatial-abstract-reasoning-group-boundary.variants.yaml, indexes 0..41, including 30 and 40; tool/generator/lib/src/rules/figure_grouping/grouping.dart, distinct-row guard.

qt-spatial-abstract-reasoning-group-center-cuts | Major | CLOSED, earlier duplication only: the list now contains 21 distinct unordered tasks rather than inflating those tasks to 100 by row permutations. Revision 1 permits its true size of 21. The new tied-distractor Major above remains open. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-center-cuts.variants.yaml, indexes 0..20; independent unordered row comparison.

qt-spatial-abstract-reasoning-group-side-double-dots | Major | CLOSED: every current most-dots choice has a unique maximum over the full row. All 68 variants have one matching three-dot hexagon, two matching two-dot quadrilaterals, and one violating figure. No tied-maximum filler remains. Both generator and solver reject ties for most-dots. | evidence: content/types/reasoning/spatial-abstract-reasoning/grouping-regions-and-inside-details/qt-spatial-abstract-reasoning-group-side-double-dots.variants.yaml, indexes 0..67, including 20; tool/generator/lib/src/rules/figure_grouping/grouping.dart and tool/generator/lib/src/check/solvers/figure_grouping/grouping_solver.dart, unique-most-dots guards.

qt-spatial-abstract-reasoning-group-specific-rule | Minor | CLOSED, classification wording only: common-symmetry now says "symmetric outlines" rather than incorrectly calling rectangles and rhombuses regular. All shown outlines have reflection symmetry. The separate variety Minor remains as recorded above. | evidence: content/types/reasoning/spatial-abstract-reasoning/testing-a-figure-group-rule/qt-spatial-abstract-reasoning-group-specific-rule.yaml, common-symmetry; matching .variants.yaml, indexes 0..44, including 18,31,40.

The prior R5 hold reason of fewer than 100 versions no longer applies to any assigned type: Revision 1 permits 20 to 100 total distinct versions. No other earlier finding for these ten types was located in audit-b.md or reaudit-a/b/c.md. The specific findings-file instruction supersedes the generic root FINDINGS.md instruction.

## Audit coverage and independent checks

Read all ten type files, their rule branches in figure_series/series.dart or figure_grouping/grouping.dart, both complete corresponding solvers, the solver registrations and task signature code. Reviewed at least these 11 spread samples per list, including every choice description, rendered explanation and all named notes:

| Type suffix | Distinct tasks / stored variants | Stored ruleKeys | Sample indexes |
|---|---|---|---|
| series-corner-edge-count | 40 / 40 | 8 | 0,4,8,12,16,20,23,27,31,35,39 |
| series-dots-size | 90 / 90 | 18 | 0,9,18,27,36,44,53,62,71,80,89 |
| series-size-corner-ray | 48 / 48 | 48 | 0,5,9,14,19,24,28,33,38,42,47 |
| series-transfer-count | 45 / 45 | 9 | 0,4,9,13,18,22,26,31,35,40,44 |
| series-binary-fill | 24 / 24 | 6 | 0,2,5,7,9,12,14,16,18,21,23 |
| group-boundary | 42 / 42 | 42 | 0,4,8,12,16,20,25,29,33,37,41 |
| group-center-cuts | 21 / 21 | 21 | 0,2,4,6,8,10,12,14,16,18,20 |
| group-line-count | 20 / 20 | 20 | 0,2,4,6,8,10,11,13,15,17,19 |
| group-side-double-dots | 68 / 68 | 68 | 0,7,13,20,27,34,40,47,54,60,67 |
| group-specific-rule | 45 / 45 | 45 | 0,4,9,13,18,22,26,31,35,40,44 |

Distinct-task counts were independently recomputed with Python standard-library code, without importing generator or solver implementations. Grouping rows were unordered multisets, with the keyed figure marked where appropriate. Series comparisons transformed shown figures and the answer together under whole-task rotations and reflections, including outline orientation, corner/ray directions, dot-row direction and bottom edge/fill direction. Distractors did not add capacity. No repeated task was found.

A separate independent Python inspection re-derived intended answers and all series mistake values for every stored variant, scanned rendered wording for empty slots, em dashes, selected British spellings and top-level fraction markup, and compared index 0 with each reserved prod source. Actual output:

```text
SUMMARY: 10 types; 443 variants; 10 reserved source comparisons; 0 intended-key/mistake-value/source errors; 0 rendered-slot/voice-scan hits
ERRORS []
VOICE []
```

This verifies intended answers and exact stored mistake operations, not pedagogical plausibility: the semantic Majors above remain even when the intended solver accepts the data. No new competing-rule counterexample was found among the ten types. The five series have more than two examples for count continuation, so adding one and doubling cannot both match their shown count tracks. The grouping stems specify the relevant property; each current key uniquely breaks that property. This is a read-only audit, not the separate blind-solve gate.

Reserved source questions were read with `git show origin/content/bite-sized-cse-algebra-r1:content/questions/reasoning/spatial-abstract-reasoning/figure-series.yaml` and the matching figure-grouping.yaml, never from local content/questions. Compared figure data, rendered stem, correct choice text and wrong-choice text set. All ten match. Read all five referenced lesson files and key points from that same prod ref: combined-and-mixed-figure-patterns, figure-counts-and-fills, grouping-outlines-and-symmetry, grouping-regions-and-inside-details and testing-a-figure-group-rule. The intended skills fit those lessons/key points. Sampled wording is plain and explanation text stays on the correct rule; the recorded corner and fixed-count defects are the exceptions.

Variety: dots-size covers three starting counts, six ordered size pairs and five constant outlines. Transfer-count covers nine initial count pairs and five outlines. Binary-fill has six phase/length patterns over four outlines. Corner-edge-count has eight parameter sets over five outlines, subject to its Major. These cosmetic expansions are allowed by the adviser ruling, and their low reasoning capacity is a disclosed limit, not a short-list finding. Size-corner-ray varies size pairs and ray/corner offsets across 48 tasks. Boundary and side-double-dots vary actual outline/count combinations. Center-cuts varies 21 line arrangements; line-count covers all 20 unequal common/odd count pairs but has the recorded note and positional defects. Specific-rule retains the recorded Minor bias.

## Needs the lead: disposition and verification

- Resolve four open Majors across series-corner-edge-count, group-center-cuts and group-line-count through a separate fix assignment. The corresponding type verdicts are FAIL. If restricting corner-edge-count to real four-corner outlines lowers its measured capacity, the lead rules on disposition; this audit changes no ranges or list.
- group-line-count retains its positional mistakes at reserved index 0 from the prod source. Any required source correction belongs to the content lane and approval gate. Do not silently replace its reserved source.
- Decide the remaining group-specific-rule variety Minor. Seven audit PASS verdicts mean no open Blocker/Major in this audit only. They do not assert checker, blind solve, ledger approval or release acceptance.
- Run the five requested gates in an environment whose existing Flutter SDK cache is writable. They all failed to execute here; the supplemental Python checks do not replace them.
- No UI change was needed or made. No screenshots, device testing, figure sheets or visual acceptance were performed. The supplied net-adjacent-relation example is outside this ten-type assignment; no verdict is given on that type.

## Required command results

All commands exited 1 before reaching their own checks. There are no test/analyzer/checker summary lines to paste. Actual common output:

```text
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 71: /opt/homebrew/share/flutter/bin/cache/engine.stamp.tmp.<pid>: Operation not permitted
/opt/homebrew/share/flutter/bin/internal/update_engine_version.sh: line 78: /opt/homebrew/share/flutter/bin/cache/engine.realm: Operation not permitted
```

- FAIL to execute: `flutter test test/tool/generator`, exit 1, denied SDK cache files engine.stamp.tmp.5470 and engine.realm.
- FAIL to execute: `flutter analyze tool/generator test/tool/generator`, exit 1, denied SDK cache files engine.stamp.tmp.10336 and engine.realm.
- FAIL to execute: `dart format --output=none --set-exit-if-changed tool/generator test/tool/generator`, exit 1, denied SDK cache files engine.stamp.tmp.10339 and engine.realm.
- FAIL to execute: `dart run tool/checks/run_checks.dart`, exit 1, denied SDK cache files engine.stamp.tmp.10338 and engine.realm.
- FAIL to execute: `dart run tool/check_no_ai_attribution.dart`, exit 1, denied SDK cache files engine.stamp.tmp.10337 and engine.realm.

Only this findings file was written. No fixes, tests authored, dependencies, generated files, source questions, UI files, staging or commits.

Evidence clarification: the additive-versus-doubling statement applies to the three series with numeric count tracks (corner-edge-count, dots-size and transfer-count). Binary-fill and size-corner-ray have no numeric count track.

Final read-only verification: `git status --short` lists only this untracked findings file; `git diff --cached --stat` is empty; `git diff --check` exits 0. HEAD remains `2d727d231cb531555b8af668ca7964f9f4223a7d`. Prod input ref resolves to `88f38e698ee80448fde1a795638f794b68db4cfd`. No index or commit changes.

## Per-type verdicts

PASS means no open Blocker or Major in this audit. The executable gates remain unverified.

qt-spatial-abstract-reasoning-series-corner-edge-count | FAIL
qt-spatial-abstract-reasoning-series-dots-size | PASS
qt-spatial-abstract-reasoning-series-size-corner-ray | PASS
qt-spatial-abstract-reasoning-series-transfer-count | PASS
qt-spatial-abstract-reasoning-series-binary-fill | PASS
qt-spatial-abstract-reasoning-group-boundary | PASS
qt-spatial-abstract-reasoning-group-center-cuts | FAIL
qt-spatial-abstract-reasoning-group-line-count | FAIL
qt-spatial-abstract-reasoning-group-side-double-dots | PASS
qt-spatial-abstract-reasoning-group-specific-rule | PASS
