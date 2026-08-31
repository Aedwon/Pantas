# Question QA R1 source ledger — Mathematics / Data Interpretation

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Reviewed:** 25 August 2026

This supplemental ledger records the substantive Data Interpretation corrections. Numerical answers were independently recomputed from the tabulated values. No external factual source was required because the data are hypothetical and self-contained.

## Findings

| Questions | Finding | Disposition | Evidence |
|---|---|---|---|
| `q-data-interpretation-rates-ratios-and-percentages-in-context-0002`, `0004`, `0006`, `0008`, `0010`, `0012` | Each item said to refer to a table from a previous question, so it was not independently answerable when served or shuffled by ID. | CORRECTED | Each item now embeds the complete table it needs. Recomputed keys remain respectively `2:3`, `5:7`, `60%`, `2:3`, `1:3`, and `33.33%`. |
| `q-data-interpretation-tables-and-charts-0002`, `0004`, `0006`, `0008`, `0010`, `0012` | Each item depended on a table shown only in the preceding item. | CORRECTED | Each item now embeds its own source table. Recomputed keys remain respectively `45,000`, `990 metric tons`, `7 million PHP`, `1,300`, `1,060`, and `90`. |
| `q-data-interpretation-rates-ratios-and-percentages-in-context-0012` | A direct percentage-of-total calculation was labeled `hard`. | CORRECTED | Difficulty was recalibrated to `medium`, consistent with the repository authoring progression; the mathematical key is unchanged. |

## Lesson conformity

Both matching lessons support the corrected question competencies:

- `content/lessons/mathematics/data-interpretation/rates-ratios-and-percentages-in-context.md` gives the percentage-change, percentage-of-total, and ratio formulas used by the bank.
- `content/lessons/mathematics/data-interpretation/tables-and-charts.md` explicitly teaches reading row/column headers, checking units, summing categories, and computing differences from tables/charts.

No question/lesson contradiction was identified in this topic.

## Visual classification

All 24 items are `TEXT SUFFICIENT`. Their tables are part of the stem content and therefore are not external illustration dependencies. A rendered table is structurally important to readability, but no separate `figure` asset is required for any item in this topic.
