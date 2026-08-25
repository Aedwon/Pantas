# Question QA R1 source ledger — Mathematics / Statistics & Probability

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Reviewed:** 25 August 2026

This ledger records substantive corrections and lesson-coverage findings from the Statistics & Probability question pass. All 80 authored items were independently recomputed or re-derived from their stated data and conditions. All five matching repository lessons were reviewed. No external factual source was required because the findings are deterministic arithmetic, counting, probability, and statistical-definition issues.

## Corrected questions

| Question | Finding | Disposition |
|---|---|---|
| `q-statistics-and-probability-basic-probability-0014` | Bayes item referred to "Question 13" and reused its computed total-defect probability. | Removed the cross-item reference and recomputed `P(D)=0.038` inside the item before applying Bayes. Key remains `15/19`. |
| `q-statistics-and-probability-measures-of-central-tendency-0005` | Explanation incorrectly blurred ordinal data with quantitative/numerical data. | Clarified that a median requires meaningful order; ordinal and quantitative data can support it, nominal data cannot. |
| `q-statistics-and-probability-measures-of-central-tendency-0015` | The common `Mean > Median > Mode` relation for right skew could be read as a universal identity. | Qualified it as a heuristic for typical unimodal right-skewed distributions. |
| `q-statistics-and-probability-measures-of-central-tendency-0016` | The affine-transformation explanation stated the result without the structural reason relevant to median/mode. | Made the strictly increasing transformation/order-and-frequency preservation explicit. Key unchanged. |
| `q-statistics-and-probability-measures-of-variability-0005` | Standard deviation was described as a typical or "average distance," which can be confused with mean absolute deviation. | Replaced with the square-root-of-average-squared-deviation definition and same-units interpretation. |
| `q-statistics-and-probability-measures-of-variability-0013` | Stem called the assessment a 10-point quiz while one listed score was 12. | Removed the impossible maximum-score claim; all score data and the variance ratio `4` remain unchanged. |
| `q-statistics-and-probability-measures-of-variability-0015` | Bessel-correction unbiasedness was stated without its sampling assumptions. | Added independent random-sample and finite-population-variance assumptions and tightened the explanation of downward bias/degrees of freedom. |
| `q-statistics-and-probability-data-analysis-graphs-0004` | The `80`-ton distractor rationale cited arithmetic that did not cleanly explain that choice. | Repaired it to the actual February-to-April comparison `600-520=80`. |
| `q-statistics-and-probability-data-analysis-graphs-0005` | The `2,050` distractor rationale said the 15–29 group had been included in an at-least-30 sum; `2,050` is actually the total under age 30. | Repaired the rationale to identify the complement calculation `850+1,200`. |
| `q-statistics-and-probability-data-analysis-graphs-0007` | Several percentage distractor rationales did not correspond to their displayed choices. | Repaired the rationales while preserving the correct `65%` key. |
| `q-statistics-and-probability-data-analysis-graphs-0009` | The `6:5` and `4:3` distractor rationales cited quarter calculations that did not produce those ratios. | Repaired them against the actual annual totals `240` and `220`; key remains `12:11`. |

## Lesson coverage gaps

The matching lessons are correct at their stated introductory level, but each omits material used by some harder questions:

1. **Basic Probability:** the lesson does not explicitly teach conditional-probability notation, the Law of Total Probability, or Bayes' theorem used in items `0012`–`0014`.
2. **Combinatorics:** the lesson covers the counting principle, basic permutations, and combinations but not distinguishable permutations, circular permutations, adjacency/block methods, or complementary restricted arrangements used by several harder items.
3. **Measures of Central Tendency:** the lesson does not teach measurement-scale suitability, skewness heuristics, or general affine transformations of mean/median/mode.
4. **Measures of Variability:** the lesson demonstrates population-style variance with denominator `N` but does not teach the sample-variance `n-1` formula or Bessel's correction used in several questions.
5. **Data Analysis and Graphs:** the lesson focuses on pie charts, bar graphs, scatter plots, and percent change; grouped-frequency means, unknown-frequency weighted means, and contingency-table conditional percentages exceed that coverage.

These are lesson coverage gaps, not reasons to reject mathematically valid questions. Lesson files were not modified on this question-QA branch.

## Visual classification

No active item requires a separate visual asset. Data Analysis and Probability items that use tables embed the complete table directly in the stem. Circular seating and distribution-shape items can benefit from diagrams, but their written conditions are sufficient to determine a unique answer.
