# Question QA R1 — Mathematics closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This subject-level checkpoint consolidates the completed item-by-item QA passes for all seven Mathematics topics present under `content/questions/mathematics/`:

1. Arithmetic and Number Sense
2. Algebra
3. Data Interpretation
4. Geometry
5. Precalculus & Basic Calculus
6. Statistics & Probability
7. Trigonometry

Every original authored/static Mathematics question has a persisted per-item disposition in the topic status ledgers. Numerical and symbolic items were independently recomputed or re-derived, and the passes also covered answer uniqueness, mathematical assumptions/domains, item independence, distractor validity, difficulty metadata, lesson conformity, duplicate/low-information content, and visual necessity.

## Consolidated result

- Original Mathematics question IDs reviewed: **713 / 713**
- Active after remediation: **712**
- Verified unchanged: **587**
- Corrected: **125**
- Retired: **1**
- Visual-required active questions: **0**

Topic totals:

| Topic | Reviewed | Verified | Corrected | Retired |
|---|---:|---:|---:|---:|
| Arithmetic & Number Sense | 135 | 124 | 11 | 0 |
| Algebra | 186 | 153 | 32 | 1 |
| Data Interpretation | 24 | 12 | 12 | 0 |
| Geometry | 120 | 113 | 7 | 0 |
| Precalculus & Basic Calculus | 56 | 52 | 4 | 0 |
| Statistics & Probability | 80 | 69 | 11 | 0 |
| Trigonometry | 112 | 64 | 48 | 0 |
| **Total** | **713** | **587** | **125** | **1** |

## Durable evidence

Per-item status is stored below `docs/content/audit/question-qa-r1-status-mathematics/`, organized by topic and source YAML file. Each topic also has a dedicated closeout and source ledger where substantive fixes and lesson conflicts or coverage gaps are documented.

## Main correction classes across Mathematics

- non-unique multiple-choice answers and distractors equivalent to the key;
- hidden domain, sign, rounding, or positivity assumptions;
- invalid or impossible geometric and trigonometric premises;
- questions depending on another question's table or computation;
- algebraic explanations that overgeneralized identities or omitted domain restrictions;
- invalid difficulty metadata and clearly inflated difficulty labels;
- malformed or misleading distractor rationales;
- low-information duplication, including one retired Algebra item;
- wording defects that changed mathematical meaning or attached angle units to dimensionless ratios.

## Lesson follow-up

Question fixes were not forced to match defective or incomplete lesson text. Follow-up lesson work is documented for Arithmetic & Number Sense, Algebra, Precalculus & Basic Calculus, and Statistics & Probability. Data Interpretation, Geometry, and Trigonometry did not surface a material lesson conflict in their completed passes.

These lesson findings remain separate from question correctness; no lesson files were modified as part of these topic closeouts.

## Visual classification

No active Mathematics question requires an external figure to remain valid and uniquely solvable. Many Algebra, Geometry, Trigonometry, and selected probability/statistics items are marked visual-beneficial in their item ledgers, but their written givens are sufficient.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart or repository test commands were available in this connector-based workflow. Validation consists of direct item-by-item recomputation/re-derivation, repository inspection, matching-lesson comparison, and persisted-file verification. `main` was not modified.
