# Question QA R1 — Mathematics / Algebra closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question in the eleven `mathematics/algebra` YAML files. Numerical and symbolic answers were independently recomputed or re-derived. Review also covered answer uniqueness, algebraic domains, hidden assumptions, distractor validity, explanatory correctness, difficulty calibration, lesson conformity, duplicate/low-information items, and visual necessity.

## Result

- Original question IDs reviewed: **186 / 186**
- Active questions after remediation: **185**
- Verified unchanged: **153**
- Corrected: **32**
- Retired: **1**
- Substantive content/assumption/uniqueness corrections: **15**
- Difficulty-only metadata corrections: **17**
- Recomputed or re-derived: **186 / 186**
- Active questions solvable from text alone: **185 / 185**
- Visual-required questions: **0**
- Visual-beneficial active questions: **18**
- Item-level lesson gaps/conflicts recorded in the ledgers: **10**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/algebra/`

with one TSV per source YAML file. All 186 original IDs remain represented in the audit ledger, including the retired ID.

Correction evidence and lesson-only defects are recorded in:

`docs/content/audit/question-qa-r1-source-ledger-mathematics.md`

## Substantive correction classes

- preserved nonzero domains when simplifying algebraic quotients;
- stated positive-domain requirements for real logarithms;
- stated real/nonnegative variable assumptions for square-root simplification instead of silently treating `sqrt(x^2)` as `x`;
- added the invertibility premise required before referring to `f^-1` as an inverse function;
- replaced a markup-versus-profit conflation with a self-contained profit premise;
- repaired a polynomial factoring item with two algebraically valid choices by requiring complete GCF factoring;
- corrected the use of the zero-product property in a quadratic error-spotting item;
- distinguished the principal square-root function from the two solutions of `x^2=a`;
- corrected a false set-theory distractor rationale;
- tightened several explanations whose keys were correct but whose mathematical justification was overbroad;
- retired one low-information set item that merely subtracted a supplied union total from the supplied population total.

## Difficulty calibration

Difficulty changes were deliberately conservative. Seventeen question records were relabeled where the original `hard` designation was plainly inconsistent with the operation being tested, such as direct substitution, a single logarithm-to-exponential conversion, direct Vieta lookup, elementary function composition, or one-rule perpendicular-slope recognition.

Stable question IDs were preserved. Items were not renumbered merely to restore a cosmetic easy-to-hard ID sequence.

## Visual classification

No Algebra question requires an image to be valid or solvable. Eighteen active items are marked `TEXT SUFFICIENT; VISUAL BENEFICIAL` because an optional graph or Venn diagram could reinforce the concept, chiefly:

- slopes, intercepts, perpendicular lines, and inequality boundaries;
- line/parabola intersections;
- rational-function asymptotes and removable discontinuities;
- vertex/range concepts;
- three-set inclusion-exclusion.

These are pedagogical enhancement candidates, not missing-asset blockers.

## Lesson follow-up

Question fixes were not forced to match defective lesson wording. Separate lesson remediation is needed for three Algebra lessons:

1. `content/lessons/mathematics/algebra/exponents-and-logarithms.md`
   - omits nonzero restrictions when simplifying variable quotients;
   - omits positive-argument restrictions in real logarithm examples.
2. `content/lessons/mathematics/algebra/radicals-and-rationalization.md`
   - pulls variables from square roots without stating nonnegative assumptions or using absolute values;
   - omits related variable-domain restrictions in rationalization examples.
3. `content/lessons/mathematics/algebra/quadratic-equations.md`
   - calls all roots from a negative discriminant “imaginary” instead of non-real complex;
   - incorrectly treats factoring the left side of a nonzero-right-side equation as itself invalid;
   - says a positive number has two square roots, conflating principal square root with equation solutions;
   - gives an absolute “never divide by x” rule instead of explaining loss of a possible zero solution.

The other eight Algebra lessons reviewed in this pass support their corresponding question competencies without an identified item-level contradiction.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart or repository test commands were available in this connector-based workflow. Validation therefore consists of direct item-by-item mathematical recomputation/re-derivation, repository inspection, lesson comparison, and persisted-file verification. `main` was not modified.
