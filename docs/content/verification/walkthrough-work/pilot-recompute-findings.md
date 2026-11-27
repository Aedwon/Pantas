# Recompute findings, Math pilot (Worker 2, E-204 step 4)

Target: working tree on commit edc956501. Read-only. Checks and tries were solved from the stem first, then compared with the
printed answer. Counts are my own tally of distinct numeric claims (display lines, steps, pair Right and Wrong lines, Why
lines, check, try, speed trick, checklist values, table figures); they are approximate to within a few.

Format: `Severity | file:line | value | your value | note`

## Arithmetic mismatches

None found.

## Citation notes (not arithmetic errors)

Each pair's Wrong line was compared with the cited wrong choice in `content/walkthrough-trap-evidence.json` and the question
in `content/questions/mathematics/`. Every cited id exists and every cited wrong choice exists in its question. These
pairs show the same mistake as the cited choice but not the identical wrong value or wording:

- Minor | arithmetic-number-sense/percentage-base-and-fraction-division.md:88 | pair #percent-decimal-shift Wrong `7.5%` | cited wrong choice is `5.5%` (q-...-fractions-decimals-percentages-0012, from 0.55) | Same one-place shift error on a different number (0.75). Lesson line is internally correct (0.075 is 7.5%).
- Minor | arithmetic-number-sense/discounted-prices.md:64 | pair #price-not-discount Wrong `Php 200` | cited choices are `P120.00` (business-math-0004) and `P725.00` (business-math-0009) | Same error (reports the discount, not the price). Lesson line is correct: 800 x 0.25 = 200, 800 - 200 = 600.
- Minor | arithmetic-number-sense/discounted-prices.md:90 | pair #successive-discounts Wrong `20%+10%=30%, 700` | cited choices are `P4,250.00` (0009, from adding 10% and 5% to 15%) and "equivalent discount is 30%" (0019) | The 30% wording matches the second citation. The P4,250 citation is not shown. Lesson line is correct: 1,000 x 0.70 = 700.
- Minor | arithmetic-number-sense/identities-and-like-terms.md:89 | pair #swapped-letters Wrong "cannot be combined" | cited choice is `3xy+5yx+5x^2` (properties-0024) | Same error (treating yx as unlike xy). The Wrong line is a statement, not the cited expression.
- Minor | algebra/age-word-problems.md:91 | pair #wrong-person-or-time Wrong `14` | two citations: `14 years old` (0001, shown) and `12 years old` (0011, Carlo four years ago) | The 0011 citation has no matching line in the lesson. Citation 0001 is shown exactly.

All other pair Wrong lines match their citation exactly: change-both-ages (18), average-work-times (4.5), rate-not-time
(5/24 hour), subtract-solo-times (5 hours), omit-original-volume (0.30x), report-final-volume (30 L), zero-multiplication,
unlike-exponents (-5), drop-whole-part (11/40), wrong-place-count (5/8), one-place-shift (0.25), wrong-percentage-base (10.8),
stop-at-the-base (180), interest-instead-of-total (3,750), months-as-years (10,800), months-as-decimal-years (54,500),
divide-by-new-value (20%), label-change-as-percent (10%), percent-from-zero (100%), missing-unit-scale (25),
wrong-column-entry (46,000), reverse-difference-order (-550).

## Checks and tries (solved from the stem before reading the answer)

All 10 checks and all 10 tries match their printed answers. Each stem has exactly one answer.

- age: check c-4 and 52-c; try 22/2 = 11
- mixture: check 0.25(6)+0.45(14) = 7.8 L in 20 L = 39%; try 1.2/0.24 = 5 L
- work: check 1/20+1/30+1/60 = 1/10, 10 hours; try 1/(2/30) = 15 hours
- discounted prices: check 1,500 - 1,020 = 480; try 24,000 x 0.85 = 20,400
- percentage base: check 54/0.20 = 270, 270 - 54 = 216; try 0.875 = 87.5%
- identities: check x + 5 = -4, x = -9; try 5x^2 + 5x - 5
- decimals: check 18/100 = 9/50; try 45/100 = 9/20
- simple interest: check 18 months = 1.5 yr, 8,000 x 0.05 x 1.5 = 600, total 8,600; try 1,500/37,500 = 4%
- percentage change: check (54-60)/60 = -10%; try -0.15 = -15%
- table: check 4.8 + 5.1 = 9.9 million = 9,900,000 pesos; try 56 x 1,000 = 56,000 pesos

## Other recomputed items worth noting

- Mixture examples back-check: #1 x = 16 gives 3.2 + 4 = 7.2 = 0.30(24). #2 w = 5 gives 0.24(25) = 6. Core example 10 L + 10 L gives 3 + 1 = 4.
- Age #2 back-check: Mia 11, Leo 29. Five years ago 24 and 6 (4 times). In 7 years 36 and 18 (twice).
- Work #2 back-check: 1/15 + 1/10 = 1/6.
- Discount Why: 200 + 80 = 280 = 28% of 1,000. Speed trick 20 + 10 - 2 = 28%. Checklist 28% and 720 agree.
- Percentage change combined categories: 20 x 1.4 = 28, 30 x 1.2 = 36, totals 50 and 64, 14/50 = 28%, average of rates 30% (so the "larger category grew more slowly" sentence is true).
- Percentage base speed tricks: 16% of 25 = 4 = 25% of 16; 10% of 180 = 18, 5% = 9, 15% = 27.
- Table figures: both illustrations match the text. Operations Q3 = 27; Administration 12, 15, 18, 11 = 56. Illustration 01 and 02 values agree with the inline comments.
- Simple interest pair: 50,000 x 0.06 x 1.25 = 3,750 and 3,750 x ... total 53,750; at 1.5 years 4,500, total 54,500. Both consistent with business-math-0008.
- Identities Wrong line `-5` is what you get if the a^2 and a terms are merged and cancel (3a^2 - 3a becomes 0). It is consistent with its note.

## Per lesson

- algebra/age-word-problems.md: about 38 values checked, 0 mismatches
- algebra/mixture-word-problems.md: about 46 values checked, 0 mismatches
- algebra/work-rate-problems.md: about 48 values checked, 0 mismatches
- arithmetic-number-sense/discounted-prices.md: about 42 values checked, 0 mismatches (2 citation notes)
- arithmetic-number-sense/percentage-base-and-fraction-division.md: about 46 values checked, 0 mismatches (1 citation note)
- arithmetic-number-sense/identities-and-like-terms.md: about 38 values checked, 0 mismatches (1 citation note)
- arithmetic-number-sense/decimal-and-percent-conversions.md: about 42 values checked, 0 mismatches
- arithmetic-number-sense/simple-interest.md: about 46 values checked, 0 mismatches
- data-interpretation/percentage-change.md: about 44 values checked, 0 mismatches
- data-interpretation/table-values-and-totals.md: about 40 values checked, 0 mismatches
- age-word-problems.md also carries 1 citation note (0011 citation not shown)

RECOMPUTE VERDICT: PASS (0 mismatches). Five Minor citation notes listed above for the lead to decide on.
