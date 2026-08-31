# Question QA R1 — Mathematics / Trigonometry closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question across the seven Trigonometry YAML files. Numerical values, identities, triangle constraints, principal ranges, and answer choices were independently recomputed or re-derived. Review also covered answer uniqueness, item independence, difficulty-schema validity, lesson conformity, distractor explanations, wording/units, and visual requirements.

## Result

- Original questions reviewed: **112 / 112**
- Verified unchanged: **64**
- Corrected: **48**
- Retired: **0**
- Active after review: **112**
- Visual-required: **0**
- Matching lessons with material coverage gaps: **0 / 7**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/trigonometry/`

with one 16-row TSV per source YAML file.

Correction evidence is recorded in `docs/content/audit/question-qa-r1-source-ledger-mathematics-trigonometry.md`.

## Corrected defect classes

- three multiple-answer/answer-uniqueness failures;
- one impossible SSA triangle;
- one wrong keyed hillside-geometry answer;
- one wrong-sign balloon-height formula;
- one Law-of-Cosines drafting artifact;
- incorrect or overbroad trigonometric-identity rationales;
- distractor values/rationales that did not represent their stated error path;
- twelve unsupported `medium-hard` difficulty labels normalized to `hard`;
- repeated `degrees in degrees` wording and dimensionless trig ratios incorrectly described as being in degrees.

No question was retired. Stable question IDs were preserved.

## Lesson conformity

All seven matching lessons support the concepts used by the active question banks. In particular, the lessons themselves expose several of the repaired question defects: the Unit Circle lesson requires `(cos θ, sin θ)` coordinate order, the Laws lesson explicitly covers impossible/ambiguous SSA cases, and the Solving Right Triangles lesson establishes the horizontal-distance geometry needed for elevation/depression models.

No lesson file was modified in this topic.

## Visual review

No item requires a separate figure to be solvable. Unit-circle and triangle diagrams are beneficial for many items, and that classification is recorded in the per-item ledgers, but every active item supplies sufficient textual givens for a unique answer.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart validation commands were available in this connector-based workflow. `main` was not modified.
