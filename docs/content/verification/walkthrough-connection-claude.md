# Walk-through connection pass (math), Claude lane

Rule source: Nov 26 entry "Walk-through examples still show math without saying where it comes from" in `docs/workflow/process-improvement.md`. Each example gets one short lead-in naming what we do and to what, and each chain runs from its expression to its value. No added narration.

Scope: committed lessons in `content/lessons/mathematics/` (algebra, arithmetic-number-sense, data-interpretation). Every value touched was recomputed.

## Finished (edited)

- arithmetic-number-sense/substituting-negative-numbers (approved target: "Let's substitute x = -2 into 3x, x^2 and 12/x", every chain ends at its value; x^2 now ends at 4)
- algebra/evaluating-and-composing-functions and algebra/functions-and-relations (f(-2) example: lead-in added, chain now ends at 15 in one line)
- algebra/radicals-and-rationalization and algebra/rationalizing-square-root-denominators (speed trick: "With x=10 and y=2", chain shows the middle step)
- algebra/word-problems (speed trick: "With a=6 and b=3", chain ends at 2)
- algebra/radicals-and-rationalization and algebra/simplifying-and-combining-radicals (example #2: lead-in before the first display)
- algebra/set-membership-and-operations and algebra/sets-and-set-notation (example #2: lead-in before the first display)
- algebra/polynomials, algebra/polynomial-terms-and-degree, algebra/polynomial-long-division (split chains joined into one, same words)
- arithmetic-number-sense/geometric-sequence-terms, harmonic-sequence-terms, prime-factorization-gcf-lcm (split chains joined into one, same words)

## Read and left alone (already connected)

- All of data-interpretation (9 lessons): every example already opens each display with a step sentence and ends at its value.
- arithmetic-number-sense/signed-integers-and-substitution.

## Not reached (as of the first commit)

- A line-by-line read of the remaining algebra and arithmetic-number-sense lessons. They were screened with pattern scans only (bare lead-ins, display directly after a heading or "Solution:", chains split across displays, chains ending before a numeric value). A scan can miss an example whose lead-in exists but is vague, so a full read of those lessons is still open.

## Second pass (Nov 26, 12:20 to 12:50 PM Manila, temporary Claude lesson lead)

### Kept from the stopped workers (36 files, lead reviewed every diff)

- Chains now start from their expression: algebraic-expressions, simplifying-and-evaluating-expressions, exponent-laws-and-zero-powers, exponents-and-logarithms, factoring-cubes, factoring-quadratic-equations, factoring-quadratics, polynomial-special-products, quadratic-equations, quadratic-inequalities-outside-the-roots, quadratic-inequalities-with-two-roots, ranges-on-restricted-domains, remainder-and-factor-theorems, exponential-growth-and-function-families, types-of-functions, line-slopes-and-intercepts, linear-equations-inequalities, systems-elimination, systems-of-equations, coin-and-digit-problems, word-problems, age-word-problems (algebra).
- Lead-ins added: cube-root-denominators-and-nested-radicals; counting-venn-diagram-regions and three-set-inclusion-exclusion (worker's lead-in trimmed by the lead to "Subtract the 5 who chose all three from each pairwise count:" because it had grown wordy).
- arithmetic-number-sense: identities-and-like-terms, imaginary-unit-and-powers, inverse-proportion-and-remaining-work, making-differences-with-given-digits, making-sums-with-given-digits, multiplying-and-dividing-decimals, operation-priority-and-left-to-right, order-of-operations, partitive-proportion-and-differences and percentage-base-and-fraction-division (pair lines now name their givens), prime-factors-and-powers.
- Restored from HEAD: none. No diff broke the rule or changed a value.

### Finished in this pass (two Sonnet workers, lead reviewed every diff)

- algebra: arithmetic-with-functions, classifying-linear-systems-by-slope, graphing-linear-systems (lead rewrote the check as "Substitute x = 2 and y = 3 into both equations" with each chain from its expression), linear-and-quadratic-functions, logarithm-product-quotient-and-power-laws, polynomial-operations, polynomial-multiple-factors, quadratic-equations-from-roots, quadratic-formula-and-irrational-roots, quadratic-inequalities-with-fewer-roots, quadratic-methods-and-root-properties, quadratic-rectangle-area, rates-and-consecutive-integers, rational-domains-and-holes, systems-lines-and-parabolas, systems-substitution-and-word-problems, work-rate-problems.
- arithmetic-number-sense: adding-and-multiplying-fractions, additive-and-multiplicative-inverses (lead replaced the worker's "For example:" with lead-ins that name the numbers, and wrote the reciprocal as 1 divided by -5/8), business-math, commutative-and-associative-properties, complex-products-and-quotients, decimal-and-percent-conversions, direct-proportion-and-travel, distribution-and-common-factors, fibonacci-type-sequence-terms, fractions-decimals-percentages, grouping-and-fraction-bars, growing-square-borders, properties-of-real-numbers, ratio-and-proportion, real-imaginary-numbers, sequences-and-series, signed-integer-operations, signed-integers-and-substitution (earlier listed as left alone; its chains now start from their expressions), simple-interest.
- Parent lessons brought in line with their child lessons by the lead: algebra/polynomials (examples #3, #5, #7, #8, #9 now start from their expression, as in polynomial-operations, polynomial-special-products, factoring-quadratics and factoring-cubes) and algebra/exponents-and-logarithms (example #6, as in logarithm-product-quotient-and-power-laws).
- Every touched value was recomputed. No wrong value was found in the originals.

### Read by a worker and left alone

- The other algebra and arithmetic-number-sense lessons on the worker lists (about 30 algebra, about 29 arithmetic). The workers read them fast (about 2.5 minutes per list), and the lead reviewed only the diffs. A slower student read of the unedited files is still worth doing.
- Mixture lesson: a five-step equation-solving sequence was left as separate displays, since joining equations with "=" would be wrong.

### Not reached

- geometry, precalculus-basic-calculus, statistics-and-probability, trigonometry (outside this lane's CSE scope).
