# Question QA R1 — Mathematics / Geometry closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question across the eight Geometry YAML files. Numerical and symbolic results were independently recomputed or re-derived. Review also covered geometric consistency of the stated configurations, answer uniqueness, lesson conformity, difficulty calibration, item independence, distractor explanations, and whether a separate visual asset is actually required.

## Result

- Original questions reviewed: **120 / 120**
- Verified unchanged: **113**
- Corrected: **7**
- Retired: **0**
- Active after review: **120**
- Visual-required: **0**
- Item-level lesson conflicts: **0**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/geometry/`

with one 15-row TSV per source YAML file.

Correction evidence is recorded in `docs/content/audit/question-qa-r1-source-ledger-mathematics-geometry.md`.

## Corrected defect classes

- an impossible trapezoid dimension set;
- a parallel-line explanation referencing an undefined point;
- a geometrically impossible angle name caused by three collinear intersection points;
- an unnecessary `figure` dependency plus the orientation ambiguity exposed when converting that item to text-only;
- a triangle root-domain explanation that did not enforce positivity of every side;
- one incorrect distractor/trap label;
- one clearly inflated difficulty label in formal logic.

No corrected item required a change to its mathematical keyed answer.

## Visual review

Geometry is naturally diagram-friendly, and many items are marked `TEXT SUFFICIENT; VISUAL BENEFICIAL` in their ledgers. None requires an external figure to be answerable after remediation. This avoids making otherwise complete questions figure-pending/inactive merely for decorative reinforcement.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart validation commands were available in this connector-based workflow. `main` was not modified.
