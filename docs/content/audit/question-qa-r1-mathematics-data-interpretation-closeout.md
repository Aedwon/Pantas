# Question QA R1 — Mathematics / Data Interpretation closeout

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Closeout date:** 25 August 2026

## Scope

This pass reviewed every original authored/static question in the two `data-interpretation` YAML files. Every numerical answer was independently recomputed. Review also covered answer uniqueness, item independence, difficulty calibration, lesson conformity, and visual necessity.

## Result

- Original questions reviewed: **24 / 24**
- Independently recomputed: **24 / 24**
- Verified unchanged: **12**
- Corrected: **12**
- Retired: **0**
- Active after review: **24**
- Visual status: **24 TEXT SUFFICIENT**
- Item-level lesson conflicts: **0**

Per-item status is stored under:

`docs/content/audit/question-qa-r1-status-mathematics/data-interpretation/`

with one 12-row TSV per source YAML file.

Substantive correction evidence is recorded in `docs/content/audit/question-qa-r1-source-ledger-mathematics-data-interpretation.md`.

## Main defect class

Twelve items depended on a table contained only in the immediately preceding question. Because authored/static questions may be served independently or shuffled, the dependent items were not self-contained. Each repaired item now embeds the table it requires while preserving the stable question ID and original mathematical key.

One of those items (`rates-ratios-and-percentages-in-context-0012`) also had its difficulty recalibrated from `hard` to `medium` because it is a single percentage-of-total computation.

## Validation constraints

No GitHub Actions were used. No Sanity writes were performed. No local Flutter/Dart validation commands were available in this connector-based workflow. `main` was not modified.
