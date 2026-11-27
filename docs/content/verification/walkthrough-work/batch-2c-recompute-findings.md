# Math batch 2c: independent recompute (Worker 2)

Target: working tree of `/Users/aedwon/.t3/worktrees/Pantas/content-lesson-walkthro-85719f9d9f054ca1` at lead commit `5a1526ea0`
(Math batch 2c: pre-check brief). Read-only. Method: every number was recomputed by hand from the stem, not from the
answer. Value counts below are approximate tallies of numbers, lines and labels checked.

Lesson paths are under `content/lessons/mathematics/arithmetic-number-sense/`. Pictures are under
`content/illustrations/mathematics/arithmetic-number-sense/<lesson>/`.

Format: `Severity | file:line | value | your value | note`

## Numeric mismatches

None. Every display line, step, pair Right and Wrong line, `:::check`, `:::try`, Why answer, Speed Trick value and checklist
value recomputed to the printed value. Every Wrong line is wrong in the way its note says. Each check and try has exactly one
answer. Examples verified by substitution: 52344 = 72 x 727; 74736 = 36 x 2076; 354211 = 11 x 32201; 324522 = 99 x 3278;
1331 = 11 x 121; 2541 = 7 x 363; 61, 123, 38, 74 leave the stated remainders for every stated divisor.

## Scope and wording findings (found while recomputing; not arithmetic errors)

Major | coprime-divisibility-tests.md:53 | "start with the last-digit test. It limits the ending digit y to a few choices" | true only when the other missing digit x lies outside the ending digits the test reads | Fails e.g. for a multiple of 8 written 32x1y (test reads x1y, x unknown, so y is not limited by itself). Add the condition "when x is not among the last 2 (for 4) or 3 (for 8) digits". Both examples satisfy it.
Major | digit-sums-and-six.md:78-79 | pair only-even-middle-digit, Wrong line | evidence cites wrong choice `8` (q-...-divisibility-rules-0021); Wrong line shows "d=9 is ruled out" and never shows 8 | 8 gives digit sum 23, which fails 3, so a student who forces d even and picks the greatest even digit lands on 8. Make the Wrong line show d=8 (digit sum 23).
Major | least-common-multiple.md:68 | counting meetings in a time window | no worked numbers | Linked quiz needs it: -0009 (3 joint departures in 9 hours with LCM 180 min), -0012 (next joint time after 12:00 PM, LCM 240 min), -0015 (rounds completed by the first joint return, LCM 225 min = 5 and 3 trips). The lesson only says "check the time window" and shows one LCM = 60. Add one worked line: count = window length / LCM, and trips per vehicle = LCM / interval.
Major | prime-factors-and-powers.md:27 | "To test a number below 49 ... check whether 2, 3, 5 divide it" | fails for 2, 3, 5 themselves (each divides itself) and for 1 | State it for numbers from 7 to 48, or "other than 2, 3 and 5". 29 is fine.
Major | real-number-sets.md:22 | "Fractions and negative numbers are not whole numbers" | 6/3 is a fraction and equals the whole number 2 | Say "negative numbers and fractions that are not integers".
Major | real-number-sets.md:39 | "square roots of integers that are not perfect squares" | the root of a negative integer is not real, so not irrational | Say "positive integers". The pair note at line ~66 already says positive.
Major | imaginary-unit-and-powers.md:93 | pair negative-root-product Right line, "-3/i = 3i" | correct value (3i), but no step shows it | The rule 1/i = -i appears only later in Speed Tricks (line 164); Example 2's try shows multiply by i. Add the step -3/i = (-3 x i)/(i x i) = -3i/-1 = 3i, or move the 1/i rule above the pair.
Major | imaginary-unit-and-powers.md:164 | "Any four consecutive powers of i add to 0" | no worked numbers | Linked quiz -0012 (sum of i^1 to i^99 = -1) needs a worked count: 99 = 4(24) + 3, 24 groups sum to 0, leftover i + (-1) + (-i) = -1. Add one worked line.
Minor | coprime-divisibility-tests.md:90-91 | pair stop-at-first-case | Right and Wrong lines omit "a multiple of 45"; the note adds the numbers 3x0 and 7x5 | Add "multiple of 45" to both lines (conditions stated).
Minor | coprime-divisibility-tests.md:150 | split 88 = 8 x 11 | no worked numbers | Linked quiz -0013 (5x3,4y6 divisible by 88) uses 8 then 11 on two unknown digits; examples cover 8, 9, 4, 5 only.
Minor | last-digit-divisibility.md:34-35 | pair add-digits-for-four | 4+5+1+6 = 16, and 4,516 does pass 4 | The Wrong method gives the same verdict by coincidence (it is the cited question's design). Optional: add "(it only happens to pass here)" or use a number where the digit sum misleads (e.g. 4,514: sum 14, last two digits 14 fail).
Minor | same-remainder-numbers.md:98-101 | pair forget-remainder | lines state L = 120 and r = 3 but not the divisors 6, 8, 10 that the note uses | Add the divisors to both lines.
Minor | real-number-sets.md:55 | "if their product is a perfect square" | ambiguous: means the product of the numbers under the roots (16), not the product of the roots (4) | Say "if the numbers under the roots multiply to a perfect square".
Minor | imaginary-unit-and-powers.md (quiz -0010, linked to this lesson) | "sum of two irrational numbers is always irrational" is a distractor | lesson never shows a sum of irrationals that is rational (e.g. sqrt(2) + (-sqrt(2)) = 0) | Optional worked line.
Minor | greatest-common-factor.md (quiz -0014, linked) | rounding up trips (60 packages, 25 or 35 per trip) | not taught | Beyond this lesson's scope; note only.

## Pictures (11 lessons, 8 SVG markers + 1 code figure)

All numbers, labels and positions recomputed and compared with the paragraph and display lines beside each marker.

- coprime-divisibility-tests 01-prime-tiles-for-4-and-6.svg: 4 = 2,2; 6 = 2,3; first tile of each row outlined and joined by a dashed line; "2 x 2 x 3 = 12"; "24 needs 2 x 2 x 2 x 3". Matches text and marker. 0 mismatches.
- divisibility-by-seven-and-eleven 01-alternating-digit-groups-for-2728.svg: boxes 2,7,2,8; odd arc links box 1 and 3 (2+2=4); even arc links box 2 and 4 (7+8=15); 4 - 15 = -11. Matches text. 0.
- greatest-common-factor 01-shared-prime-tiles-of-48-and-180.svg: 48 = 2^4 x 3 drawn as 2,2,3 (outlined) then 2,2; 180 = 2^2 x 3^2 x 5 drawn as 2,2,3 (outlined) then 3,5; "only in 180" under the 5; GCF = 2^2 x 3 = 12. Tile multisets are correct. 0.
- imaginary-unit-and-powers 01-four-step-cycle-of-powers-of-i.svg: i^1 = i (r1), i^2 = -1 (r2), i^3 = -i (r3), i^4 = 1 (r0); clockwise from top left; arrow heads point 1 to 2 to 3 to 4 to 1. Matches text. 0.
- last-digit-divisibility 01-ending-digits-of-48672.svg: digits 4,8,6,7,2; brackets cover last 3 (x 214-342), last 2 (260-342), last 1 (306-342) digit boxes; 672 / 8 = 84; 72 for 4; 2 for 2. Matches. 0.
- least-common-multiple 01-jeepney-timelines-meet-at-60.svg: 15-minute marks at 70 px steps (110, 180, 250, 320); 20-minute marks at 93.3 px steps (133.3, 226.7, 320); same 0-60 scale (x 40 to 320); dashed line at 60; "LCM = 60 min". To scale. 0.
- prime-factors-and-powers 01-factor-tree-for-60.svg: 60 to 2 and 30; 30 to 2 and 15; 15 to 3 and 5; leaves 2,2,3,5 circled; edges meet node circles; 60 = 2^2 x 3 x 5. Matches. 0.
- same-remainder-numbers 01-number-line-of-36k-plus-2.svg: marks 2, 38, 74 at x = 47, 173, 299 (3.5 px per unit from x = 40), so to scale; two jumps +36; k = 0, 1, 2; N = 36k + 2. Matches. 0.
- real-number-sets code figure (nested-boxes JSON): the renderer ignores the order of the `boxes` list and draws fixed nesting: Natural in Whole in Integers in Rational, Irrational beside Rational, both inside Real. Equal to the text and the mnemonic (natural numbers start at 1). 0 mismatches.

Text-label size and viewBox fit checked by position arithmetic only (no render, no screenshot).

## Tallies per lesson (approximate values checked, numeric mismatches; scope findings in brackets)

- coprime-divisibility-tests: 52 values, 0 mismatches [1 Major, 2 Minor]
- digit-sums-and-six: 46 values, 0 mismatches [1 Major]
- divisibility-by-seven-and-eleven: 48 values, 0 mismatches [0]
- last-digit-divisibility: 50 values, 0 mismatches [1 Minor]
- greatest-common-factor: 48 values, 0 mismatches [1 Minor, note only]
- least-common-multiple: 52 values, 0 mismatches [1 Major]
- prime-factors-and-powers: 38 values, 0 mismatches [1 Major]
- same-remainder-numbers: 54 values, 0 mismatches [1 Minor]
- real-number-sets: 36 values, 0 mismatches [2 Major, 1 Minor]
- complex-products-and-quotients: 54 values, 0 mismatches [0]
- imaginary-unit-and-powers: 52 values, 0 mismatches [2 Major, 1 Minor]

Trap-evidence check: every pair's cited wrong choice was looked up in `content/walkthrough-trap-evidence.json` and the
question file. All are shown by the Wrong line except the one noted for only-even-middle-digit. For last-two-for-eight the
Wrong line shows k = 3 (the cited k = 5 is not shown; acceptable, one choice is shown).

RECOMPUTE VERDICT: PASS (0 numeric mismatches, 0 Blockers). 8 Majors and 6 Minors on scope and wording, listed above, for the lead to rule on.
