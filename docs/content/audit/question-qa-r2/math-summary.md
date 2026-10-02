# Mathematics question QA round r2 summary

## Assignment and source identity

- Scope: mathematics question YAML only, its per-lesson ledgers, and this summary.
- Assigned branch: `content/question-qa-r2-math`.
- Worktree: `/Users/aedwon/Documents/Projects/Pantas-wt-content-qa-r2-math`.
- Current-main policy read in full at startup: `244d74b661c4aa5a88ddb216c29056a45dca3b75` (`AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`).
- Approved assignment: 1 October 2026 question audit and expansion, recorded in `docs/superpowers/decisions/2026-10-01-question-explanations-log.md` on main, plus the explicit r2 dispatch and resumption instructions.
- Rules read from that policy revision: question style guide, authoring runbook, and mathematics blueprint. Source lessons were read on the assigned branch before edits.
- Main advanced to `5f9637ec369cd9a69bad5bd2112555e9f9d3cd04` during execution. The three policy files and the three content guides above are unchanged from the recorded startup revision. The updated question-explanations decision log was read in full; its later importer-fixture ruling adds no writable paths for this worker.
- Audit baseline before the first r2 lesson commit: `1f79d880264e9c80c7507c95a365126d251c3837`.
- Resumed from clean, matching local and remote head `aab5f96048911d119764fa81d7a6271ff53b9f3b`.
- Completed content and ledger candidate before this summary: `3dd29bd1ac6e74b3a06f8cc73fac894abcf886d0`.
- The relay runners were checked and all three were offline. Execution used the assigned local worktree.
- Other subject groups, CSE vocabulary placeholders, application code, tools, tests, lessons, and seed assets were not changed.
- No push, merge, branch switch, protected-package rebuild, signing, or device test was performed.

## Completed work

- Task 1: audited all 712 existing questions across 46 mathematics lessons.
- Task 2: added 208 questions. The importer emits all 920 mathematics questions as active.
- Task 3: completed 46 TSV ledgers, with one row per question.
- Task 4: validated each newly completed or amended lesson with the whole-bank importer and content checks, then committed it. Completed ledgers were skipped on resumption except for the required checks of flagged explanations, notes, and formatting.
- Finish: this summary records the aggregate counts, findings, active counts, source identity, and verification evidence.
- Every mathematics lesson has exactly 20 imported active questions. No mathematics question is figure-pending.
- Existing question IDs and approval states are preserved. All added questions have `approved: false`.

## Status counts

- VERIFIED: 311
- CORRECTED: 343
- NEW: 208
- NEEDS AEDWON: 58

## Severity counts before correction

- NONE: 509
- LOW: 47
- MEDIUM: 343
- HIGH: 21

## Answer-key checks

- SOLVED-MATCH: 711
- SOLVED-FIXED: 1
- NEW: 208

## Every HIGH finding

- `q-algebra-algebraic-expressions-0007`: Both displayed lines were wrong; the stem did not ask for the first error.
- `q-algebra-algebraic-expressions-0012`: Both displayed results were wrong; the stem did not specify the first error.
- `q-algebra-quadratic-equations-0008`: Complex includes real numbers; the complex-root choice could also describe the repeated real roots.
- `q-algebra-systems-of-equations-0006`: Two supposedly wrong ordered pairs also solved the system; now asks for the number of solutions.
- `q-algebra-systems-of-equations-0010`: Best method was subjective and graphing was defensible; now tests a substitution step.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0014`: Without requiring the maximum package count, one package and one trip were valid; added the missing grouping condition.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0015`: Fare collection per round and counting the endpoint were unstated; defined completed-round earnings to remove alternate readings.
- `q-arithmetic-number-sense-properties-of-real-numbers-0015`: Wrong key: the y coefficients sum to 9-2+5=12, not 14. Correct choice and mistaken distractor derivations fixed.
- `q-arithmetic-number-sense-sequences-and-series-0006`: The sequence type was unstated; arithmetic was required for the marked answer.
- `q-arithmetic-number-sense-sequences-and-series-0009`: The mean type was unstated; specified arithmetic means to exclude geometric means.
- `q-geometry-basic-geometric-concepts-0012`: Explanation falsely said using three times the complement gives thirty degrees; it gives forty-five. Removed the wrong-choice discussion.
- `q-geometry-logic-and-reasoning-0005`: A distractor was a true contrapositive of a premise and therefore also followed logically; replaced it with a nonvalid partial negation.
- `q-geometry-parallel-perpendicular-lines-0009`: Endpoint labels did not determine whether the angles were alternate or same-side interior; stated the intended alternate pair.
- `q-geometry-parallel-perpendicular-lines-0012`: The inclination direction was ambiguous, allowing different crossing angles; specified that both transversals rise left to right.
- `q-geometry-quadrilaterals-and-polygons-0006`: The old note falsely said a pentagon has interior angles larger than 144 degrees; a regular pentagon has 108-degree angles.
- `q-geometry-triangles-0001`: The old note claimed subtracting 120 from 90 gives positive 30; replaced the choice and note.
- `q-geometry-triangles-0015`: The lesson does not teach area scaling; the old 9.6 note also claimed an inverted ratio produces it, which is false. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0002`: A circle is a special ellipse; requested the most specific type to avoid two defensible classifications.
- `q-statistics-and-probability-basic-probability-0008`: Removed an unsupported claim that Baguio weather records establish the probability.
- `q-statistics-and-probability-measures-of-variability-0006`: Replaced positive root with nonnegative root because zero SD is possible.
- `q-trigonometry-solving-right-triangles-0002`: The 125-degree note claimed supplementary subtraction, but 180-35 is 145; corrected the distractor.

## Every NEEDS AEDWON item

These questions remain active. Their stems, choices, and keys are preserved under the dispatch rule. Their explanations, wrong-choice notes, and formatting were checked and corrected as needed. The ledger gives the lesson-coverage issue or retained ambiguity.

- `q-algebra-sets-and-set-notation-0004`: The lesson does not teach the empty set or its universal subset property.
- `q-algebra-sets-and-set-notation-0008`: The lesson does not teach counting subsets or the rule 2^n.
- `q-algebra-sets-and-set-notation-0013`: The lesson does not teach set-builder notation or relative-complement notation.
- `q-algebra-sets-and-set-notation-0014`: The lesson does not teach De Morgan’s identities.
- `q-algebra-types-of-functions-0015`: The lesson does not teach perpendicular slopes; stem, choices and key retained.
- `q-arithmetic-number-sense-business-math-0002`: The lesson does not teach the distance-based fare rule or rounding partial kilometers.
- `q-arithmetic-number-sense-business-math-0005`: The lesson does not teach commissions on net profit.
- `q-arithmetic-number-sense-business-math-0006`: The lesson does not teach profit margin on selling price.
- `q-arithmetic-number-sense-business-math-0007`: The lesson does not teach the distance-based fare rule.
- `q-arithmetic-number-sense-business-math-0012`: The lesson does not teach tiered commissions; the old note for 8700 had an incorrect derivation.
- `q-arithmetic-number-sense-business-math-0013`: The lesson does not teach conversion between margin and markup.
- `q-arithmetic-number-sense-business-math-0014`: The lesson does not teach fare-revenue accounting.
- `q-arithmetic-number-sense-business-math-0015`: The lesson does not teach payment allocation to interest before principal.
- `q-arithmetic-number-sense-fractions-decimals-percentages-0004`: The lesson does not teach repeating-decimal conversion; stem, choices and key retained.
- `q-arithmetic-number-sense-fractions-decimals-percentages-0010`: The lesson does not teach simple interest; two notes had incorrect numerical derivations, now corrected.
- `q-arithmetic-number-sense-prime-factorization-gcf-lcm-0013`: The lesson does not teach counting divisors with exponent choices; stem, choices and key retained.
- `q-arithmetic-number-sense-properties-of-real-numbers-0012`: The lesson does not teach closure or the standard number sets; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-arithmetic-number-sense-ratio-and-proportion-0007`: The lesson does not teach area or squared map scales; stem, choices and key retained.
- `q-arithmetic-number-sense-ratio-and-proportion-0012`: The lesson does not teach the distance-speed-time formula; stem, choices and key retained. The old 32 note lacked a specific calculation, now identified as a forty-minute hour.
- `q-geometry-basic-geometric-concepts-0011`: The lesson does not define perpendicular rays; stem, choices and key retained.
- `q-geometry-basic-geometric-concepts-0014`: The lesson does not teach the 360-degree sum around a point; stem, choices and key retained.
- `q-geometry-circles-0008`: The lesson does not teach cyclic-quadrilateral opposite angles; stem, choices and key retained.
- `q-geometry-circles-0009`: The lesson does not teach the interior intersecting-chord angle theorem; stem, choices and key retained.
- `q-geometry-circles-0010`: The lesson does not teach the exterior secant-angle theorem; stem, choices and key retained.
- `q-geometry-circles-0011`: The lesson does not teach perpendicular-from-center chord bisection; stem, choices and key retained.
- `q-geometry-circles-0012`: The lesson does not teach the tangent-secant power theorem; stem, choices and key retained.
- `q-geometry-circles-0013`: The lesson does not teach the area of an inscribed square; stem, choices and key retained.
- `q-geometry-circles-0015`: The lesson does not teach equal tangent triangles and the thirty-degree right-triangle rule; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0008`: The lesson does not teach triangle area from coordinates; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0012`: The lesson does not teach parallelogram area from coordinates; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0013`: The lesson does not teach circle equations and completing squares; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0014`: The lesson does not teach solving simultaneous line equations; stem, choices and key retained.
- `q-geometry-coordinate-geometry-0015`: The lesson does not teach the point-to-line distance formula; stem, choices and key retained.
- `q-geometry-logic-and-reasoning-0012`: The lesson does not teach diagonal properties of parallelograms, rectangles, and rhombi; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-geometry-logic-and-reasoning-0013`: The lesson does not teach the formal negation of a conditional; stem, choices and key retained.
- `q-geometry-measurement-0011`: The lesson gives cone volume and slant height but not cone surface area; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0007`: The lesson does not teach the trapezoid midsegment-length rule; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0008`: The lesson does not teach the Pythagorean theorem needed for perimeter from rhombus diagonals; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0011`: The lesson does not teach counting polygon diagonals; stem, choices and key retained.
- `q-geometry-quadrilaterals-and-polygons-0013`: The lesson does not teach square area from its diagonal; stem, choices and key retained.
- `q-geometry-triangles-0013`: The lesson does not teach the right-triangle altitude proportion; stem, choices and key retained.
- `q-geometry-triangles-0015`: The lesson does not teach area scaling; the old 9.6 note also claimed an inverted ratio produces it, which is false. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0004`: The lesson does not teach focal-locus definitions; the stem also lacks an absolute-difference condition. Stem, choices and key retained.
- `q-precalculus-basic-calculus-conic-sections-0014`: The lesson does not teach the parabola focus parameter; stem, choices and key retained.
- `q-statistics-and-probability-basic-probability-0014`: The lesson does not teach reverse conditioning with Bayes rule; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0006`: Repeated-letter arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0007`: Circular arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0011`: Block arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0013`: Circular block arrangements are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-combinatorics-0015`: Excluded-adjacency block counting are not taught in the lesson; stem, choices and key retained.
- `q-statistics-and-probability-data-analysis-graphs-0012`: Weighted or grouped-data means are not taught in this graph lesson; stem, choices and key retained. Replaced vague guess or rounding notes with explicit row-copying and premature-rounding mistakes.
- `q-statistics-and-probability-data-analysis-graphs-0013`: Weighted or grouped-data means are not taught in this graph lesson; stem, choices and key retained. Replaced vague guess or rounding notes with explicit row-copying and premature-rounding mistakes.
- `q-statistics-and-probability-measures-of-central-tendency-0015`: The lesson does not teach the usual mean-median-mode ordering in a skewed distribution; that ordering is not universal. Stem, choices and key retained.
- `q-statistics-and-probability-measures-of-variability-0015`: The lesson gives the sample denominator but does not teach unbiased estimation or Bessel correction; stem, choices and key retained.
- `q-trigonometry-inverse-trigonometric-functions-0014`: The lesson does not teach secant; stem, choices and key retained.
- `q-trigonometry-inverse-trigonometric-functions-0016`: The lesson does not teach cotangent; stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-trigonometry-solving-right-triangles-0011`: The lesson does not teach cotangent. The intended level-ground and ground-level observations are also unstated. Stem, choices and key retained. Correct choice remains longest under the preservation rule.
- `q-trigonometry-solving-right-triangles-0016`: The lesson does not teach cotangent. The intended level-ground and ground-level observations are also unstated. Stem, choices and key retained. Correct choice remains longest under the preservation rule.

## Final per-lesson active counts

Counts below come from the importer output, not from the mere presence of a YAML row.

- `algebra/algebraic-expressions`: active 20, existing audited 18, added 2.
- `algebra/exponents-and-logarithms`: active 20, existing audited 15, added 5.
- `algebra/functions-and-relations`: active 20, existing audited 15, added 5.
- `algebra/linear-equations-inequalities`: active 20, existing audited 18, added 2.
- `algebra/polynomials`: active 20, existing audited 18, added 2.
- `algebra/quadratic-equations`: active 20, existing audited 18, added 2.
- `algebra/radicals-and-rationalization`: active 20, existing audited 18, added 2.
- `algebra/sets-and-set-notation`: active 20, existing audited 14, added 6.
- `algebra/systems-of-equations`: active 20, existing audited 18, added 2.
- `algebra/types-of-functions`: active 20, existing audited 15, added 5.
- `algebra/word-problems`: active 20, existing audited 18, added 2.
- `arithmetic-number-sense/business-math`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/divisibility-rules`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/fractions-decimals-percentages`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/order-of-operations`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/prime-factorization-gcf-lcm`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/properties-of-real-numbers`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/ratio-and-proportion`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/real-imaginary-numbers`: active 20, existing audited 15, added 5.
- `arithmetic-number-sense/sequences-and-series`: active 20, existing audited 15, added 5.
- `data-interpretation/rates-ratios-and-percentages-in-context`: active 20, existing audited 12, added 8.
- `data-interpretation/tables-and-charts`: active 20, existing audited 12, added 8.
- `geometry/basic-geometric-concepts`: active 20, existing audited 15, added 5.
- `geometry/circles`: active 20, existing audited 15, added 5.
- `geometry/coordinate-geometry`: active 20, existing audited 15, added 5.
- `geometry/logic-and-reasoning`: active 20, existing audited 15, added 5.
- `geometry/measurement`: active 20, existing audited 15, added 5.
- `geometry/parallel-perpendicular-lines`: active 20, existing audited 15, added 5.
- `geometry/quadrilaterals-and-polygons`: active 20, existing audited 15, added 5.
- `geometry/triangles`: active 20, existing audited 15, added 5.
- `precalculus-basic-calculus/basic-derivatives`: active 20, existing audited 14, added 6.
- `precalculus-basic-calculus/basic-integrals`: active 20, existing audited 14, added 6.
- `precalculus-basic-calculus/conic-sections`: active 20, existing audited 14, added 6.
- `precalculus-basic-calculus/limits-and-continuity`: active 20, existing audited 14, added 6.
- `statistics-and-probability/basic-probability`: active 20, existing audited 16, added 4.
- `statistics-and-probability/combinatorics`: active 20, existing audited 16, added 4.
- `statistics-and-probability/data-analysis-graphs`: active 20, existing audited 16, added 4.
- `statistics-and-probability/measures-of-central-tendency`: active 20, existing audited 16, added 4.
- `statistics-and-probability/measures-of-variability`: active 20, existing audited 16, added 4.
- `trigonometry/angles-and-radian-measure`: active 20, existing audited 16, added 4.
- `trigonometry/basic-trigonometric-ratios`: active 20, existing audited 16, added 4.
- `trigonometry/inverse-trigonometric-functions`: active 20, existing audited 16, added 4.
- `trigonometry/laws-of-sines-and-cosines`: active 20, existing audited 16, added 4.
- `trigonometry/solving-right-triangles`: active 20, existing audited 16, added 4.
- `trigonometry/trigonometric-identities`: active 20, existing audited 16, added 4.
- `trigonometry/unit-circle`: active 20, existing audited 16, added 4.

## Gaps and retained limitations

- The mathematics blueprint and historical generation plan predate the explanation-only rule, immutable IDs, new-question approval setting, single-dollar display rule, and 20-active minimum. The current style guide and explicit dispatch controlled those differences.
- The authoring runbook topic-to-exam table does not list Mathematics. Existing exam tags were preserved; no new topic or exam mapping was introduced.
- The historical generation manifest has 44 lessons. The assigned bank also has two data-interpretation lessons; both already have completed r2 ledgers and are included in the 46-lesson totals.
- No final bank importer error occurred in another subject group.
- The importer on this workstream does not itself require every wrong-choice rationale. A separate explicit content check enforced that requirement for mathematics.
- The requested preservation of flagged stems, choices, and keys leaves the listed lesson mismatches and ambiguities for Aedwon. This summary does not claim those items were resolved.
- A raw choice-text length diagnostic flagged 22 answers. Eight belong to preserved NEEDS AEDWON questions. The other 14 are in previously completed ledgers, which the resumption rule says to skip. Source-string length includes LaTeX and is not rendered length. Those 14 candidates were not reopened or visually checked.

Preserved flagged length candidates:

- `q-arithmetic-number-sense-properties-of-real-numbers-0012`
- `q-geometry-logic-and-reasoning-0012`
- `q-precalculus-basic-calculus-conic-sections-0004`
- `q-statistics-and-probability-measures-of-central-tendency-0015`
- `q-statistics-and-probability-measures-of-variability-0015`
- `q-trigonometry-inverse-trigonometric-functions-0016`
- `q-trigonometry-solving-right-triangles-0011`
- `q-trigonometry-solving-right-triangles-0016`

Previously completed raw-text length candidates, not reopened:

- `q-geometry-triangles-0009`
- `q-precalculus-basic-calculus-basic-derivatives-0006`
- `q-precalculus-basic-calculus-basic-derivatives-0009`
- `q-precalculus-basic-calculus-basic-integrals-0010`
- `q-precalculus-basic-calculus-conic-sections-0015`
- `q-precalculus-basic-calculus-conic-sections-0018`
- `q-statistics-and-probability-basic-probability-0007`
- `q-statistics-and-probability-combinatorics-0005`
- `q-statistics-and-probability-combinatorics-0014`
- `q-statistics-and-probability-measures-of-central-tendency-0018`
- `q-statistics-and-probability-measures-of-central-tendency-0019`
- `q-trigonometry-angles-and-radian-measure-0015`
- `q-trigonometry-basic-trigonometric-ratios-0008`
- `q-trigonometry-basic-trigonometric-ratios-0009`

## Verification evidence

Content and ledger source identity: `3dd29bd1ac6e74b3a06f8cc73fac894abcf886d0`. All 92 changed paths relative to the audit baseline are 46 mathematics question files and 46 mathematics ledgers. This summary is the only additional path.

Whole-bank command:

```sh
dart run tools/import_questions/import_questions.dart --root content/questions > /dev/null
```

Actual result, followed by parsed-import and source checks:

```text
whole-bank importer exit: 0
ledgers: 46 questions: 920 audited: 712 new: 208 imported active: 920
status: VERIFIED=311 CORRECTED=343 NEW=208 NEEDS AEDWON=58
severity: NONE=509 LOW=47 MEDIUM=343 HIGH=21
per-lesson imported active counts: all 46 are 20
missing wrong-choice notes: 0
notes on correct choices: 0
unprefixed frac commands: 0
em dashes: 0
double-dollar delimiters: 0
removed existing IDs: 0
changed existing approval states: 0
new approval/status mismatches: 0
incomplete or mismatched ledger rows: 0
position-dependent choice text: 0
scope violations: 0
```

Attribution command and actual output:

```sh
dart run tool/check_no_ai_attribution.dart
```

```text
check_no_ai_attribution: OK
```

`git diff --check` completed with exit 0 after the amended lessons.

## Stop conditions and unverified work

- No policy contradiction, missing required lesson, missing dependency, or unresolvable importer error stopped this pass.
- Relay runners were offline; the already-authorized local execution path was available.
- The first aggregate diagnostic attempted to group a reference object as a string and failed. It was corrected to read the lesson reference. The corrected diagnostic passed against fresh importer output.
- No application builds, Flutter tests, analysis, layering checks, emulator checks, Question Studio approvals, rendered-choice length inspection, or protected-seed rebuild were run. They are outside this content-only assignment or require separate visual/release acceptance.
- No independent review was launched. The accepted decision says the lead does not audit Codex output. The group completion here is separate from combined integration, release verification, and publication.
- The orchestrator remains responsible for recording the group handoff in the broader project SSOT and for any authorized upload or combined integration. This worker was restricted to mathematics questions, ledgers, and this summary.
