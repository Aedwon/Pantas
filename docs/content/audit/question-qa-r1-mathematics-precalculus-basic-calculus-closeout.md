# Question QA R1 — Mathematics / Precalculus & Basic Calculus closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question across the four Precalculus & Basic Calculus YAML files. Results were independently recomputed or re-derived. Review also covered function domains, answer uniqueness, theorem/definition hypotheses, lesson conformity, difficulty calibration, distractor explanations, and whether a separate visual asset is required.

## Result

- Original questions reviewed: **56 / 56**
- Verified unchanged: **52**
- Corrected: **4**
- Retired: **0**
- Active after review: **56**
- Visual-required: **0**
- Lesson precision gaps recorded: **3**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/precalculus-basic-calculus/`

with one 14-row TSV per source YAML file.

Correction and lesson-gap evidence is recorded in `docs/content/audit/question-qa-r1-source-ledger-mathematics-precalculus-basic-calculus.md`.

## Corrected defect classes

- two derivative formulas that omitted points where the original functions are defined but their ordinary derivatives are not;
- a conic-classification rule that omitted the nondegeneracy hypothesis;
- a limit explanation that conflated literal division by zero with infinite limit behavior.

No corrected item required a change to its keyed answer.

## Lesson conflicts/gaps

The derivative, conic, and limits lessons contain corresponding precision omissions/overstatements documented in the source ledger. They were not modified here because this branch's current scope is question-bank QA plus durable recording of lesson issues.

## Visual review

No item requires an external figure. Several tangent, definite-integral, conic, and piecewise-limit questions are marked `TEXT SUFFICIENT; VISUAL BENEFICIAL`, but every active item is answerable from the written stem alone.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart validation commands were available in this connector-based workflow. `main` was not modified.
