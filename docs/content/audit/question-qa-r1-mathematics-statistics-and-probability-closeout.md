# Question QA R1 — Mathematics / Statistics & Probability closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question across the five Statistics & Probability YAML files. All numeric and counting results were independently recomputed; conceptual items were re-derived from their definitions and stated assumptions. Review also covered item independence, answer uniqueness, population-vs-sample conventions, lesson conformity, difficulty, distractor explanations, embedded-table sufficiency, and visual requirements.

## Result

- Original questions reviewed: **80 / 80**
- Verified unchanged: **69**
- Corrected: **11**
- Retired: **0**
- Active after review: **80**
- Visual-required: **0**
- Matching lessons with documented coverage gaps: **5 / 5**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/statistics-and-probability/`

with one 16-row TSV per source YAML file.

Correction and lesson-gap evidence is recorded in `docs/content/audit/question-qa-r1-source-ledger-mathematics-statistics-and-probability.md`.

## Corrected defect classes

- one cross-item Bayes dependency;
- central-tendency data-type, skew-heuristic, and transformation precision;
- standard-deviation definition, an impossible score ceiling, and Bessel-correction assumptions;
- four distractor rationales whose stated arithmetic did not correspond to their displayed choices.

No corrected item required a change to its keyed answer.

## Lesson coverage

All five matching lessons support their introductory core material, but harder questions extend beyond them in conditional/Bayesian probability, advanced combinatorics, measurement scales/skew/transformations, sample variance/Bessel's correction, and grouped/contingency-table analysis. These gaps are recorded for later lesson remediation; lesson files were not changed here.

## Visual review

No item requires an external figure. Tables are embedded directly in the relevant stems. Several circular-seating and distribution concepts are visual-beneficial, but every active item remains answerable from its written givens.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart validation commands were available in this connector-based workflow. `main` was not modified.
