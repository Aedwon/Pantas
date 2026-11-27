# Blind pre-check findings, Math batch 2d (Worker 1)

Target: working tree at commit `9200f00e4`. Lessons under `content/lessons/mathematics/arithmetic-number-sense/`. Check and try items were solved from the visible text before opening any answer. All ten keys matched the printed answers. Broad-rule list (maintools, main `8ed6a0b4f`) was run on all 11 lessons. Every printed rule line was tested for counterexamples. None failed. Quiz-question links were not checked, because the brief names no command for that.

Format: `Severity | file:line | item | problem | fix`

## Findings

Major | arithmetic-sequence-terms.md:180 | try | The stem hands over the step ("add 1 to count the first term"). The student only does 19+1. The rule is not used | Ask "Finish the count: what is n?" with the 19 gaps shown, and no named step
Major | arithmetic-series-sums.md:41 | pair omit-divide-by-two | Right and Wrong use S_10 with 4 and 31, but the 10 terms and the series 4,7,10,... are not introduced until the next subsection. The student cannot check the numbers | State the series ("For 4,7,10,...,31, which has 10 terms") above the lines
Major | arithmetic-series-sums.md:158 | try | The stem gives the whole method (a_6 = S_6 - S_5) and both sums are printed, so only 60-45 is left | Ask "Use S_6 and S_5 to find a_6" with no formula in the stem
Major | geometric-sequence-terms.md:132 | try | The stem prints (-2)^7 = -128 and says "multiply a_1 = 3". Only 3 x (-128) is left | Ask "Finish the last step: find a_8" without the product setup
Major | finite-geometric-series.md:55 | pair omit-sum-denominator | S_5 with 5 and 3^5 appears with no a_1 = 5, r = 3 stated. The next pair introduces 5,15,45,... later | State "a_1 = 5, r = 3, n = 5" above the lines
Major | finite-geometric-series.md:146 | try | Stem says "compute S_8 = 8(5)". The formula is already applied. Only 8 x 5 is left | Ask "Finish the last step: find S_8" and leave the formula to the student
Major | finding-number-patterns.md:197 | try | "Finish the last step: $38+3$." The rule has been applied in the stem. Same pattern Codex failed in 2c | Ask "Finish the last step: find the next term" with no expression
Major | odd-and-even-position-patterns.md:24 | picture 1 | The picture shows both rules ("odd positions: x 2", "even positions: / 3") before steps 1 and 2 find them. It gives away the worked result ahead of the text | Move the marker below step 4 or after "The next two numbers are 32, 3"
Major | odd-and-even-position-patterns.md:123 | try | The step before it already says position 7 is odd and the odd rule is +3. The stem says "use the odd-position rule". Only 8+3 is left | Ask "Finish the last step: find the seventh term" and drop the rule named in the stem
Major | signed-integer-operations.md:20 | definition | "A signed integer is a whole number with a plus or minus sign, such as 5, -3, -12." Whole numbers are not negative, so -3 is not one. A set statement that is false for the numbers it names | Write "A signed integer is an integer written with a plus or minus sign" or "a number such as ..." and avoid "whole number"
Major | substituting-negative-numbers.md:108 | example 1 | Step 6 ends with a colon and no display line. The pair that follows interrupts the example and its Right line is the missing step | Print the line "4-(-18)+(-6)=4+18+(-6)" in step 6 and move the pair after step 7
Major | substituting-negative-numbers.md:153 | try | The stem prints the whole expression "18-3+(-1)". Only the arithmetic is left | Ask "Finish the last step: find the value" with the expression left in the example

Minor | arithmetic-sequence-terms.md:31 | picture 1 | Bracket text "4 steps (n - 1), not 5" shows the n-1 result one paragraph before the text explains it | Place the marker after the paragraph beginning "To reach the fifth term"
Minor | arithmetic-series-sums.md:31 | picture 1 | Repeats all three pair sums and 3 x 23 = 69 already printed above. It adds only the nested layout | Keep, or move the pair sums out of the text above
Minor | infinite-geometric-series.md:149 | try | Stem says "compare |r| with 1". It uses the rule but names the step | Ask "Does the series have a finite sum?" alone
Minor | infinite-geometric-series.md:157 | checklist | "nonzero series with |r| >= 1 diverge" is ambiguous, since it means a nonzero first term. The "(including alternating series)" aside makes it heavy | Write "when a_1 is not 0, check |r| < 1 first"
Minor | finite-geometric-series.md:139 | example 2 | "the common ratio is a division of equal numbers" is awkward | Write "Every term is 5, so r = 5/5 = 1"
Minor | harmonic-sequence-terms.md:52 | text | "The fourth reciprocal is 4/6" has no line showing 3/6 + 1/6 | Add the line
Minor | harmonic-sequence-terms.md:131 | try | Stem names the step ("return from the arithmetic term 17"). The student still must flip | Ask "Finish: what is the 6th harmonic term?"
Minor | fibonacci-type-sequence-terms.md:119 | try | Stem names how to combine terms. The student still groups the numbers | Ask "Finish: find z"
Minor | finding-number-patterns.md:98 | pair wrong-square-step | "instead of adding 4 to 16" has no source. The 4 was the second jump, not the last | Say "added 4 to 16 (the second jump)" or "reused the earlier jump" or change the Wrong to 32+16=48
Minor | odd-and-even-position-patterns.md:82 | pair mix-position-groups | The Wrong line uses the odd-position rule +5, but the lesson never shows the odd terms 7,12,17,22 | Show the odd group in step 2 or name the +5 source
Minor | odd-and-even-position-patterns.md:88 | pair copy-wrong-step | Right line "43-7=36" repeats the previous pair's Right line. The Wrong also flips the sign (a +5 step used as -5) with no mention | Note "the sign also flipped" or use a different Right
Minor | signed-integer-operations.md:216 | try | The stem prints "-3+4". The student still uses the different-signs rule, so it is a real use | Optional: ask "Finish the last step" alone

## Pictures (10)

- arithmetic-sequence-terms 01: numbers right (5,9,13,17,21; four +4 arcs; bracket "4 steps (n - 1), not 5"). 1 Minor (placement).
- arithmetic-series-sums 01: numbers right. 1 Minor (repeats text).
- infinite-geometric-series 01: widths 160, 80, 40, 20, gap 20, total 320 = 2 x 160. Matches. 0 findings.
- harmonic-sequence-terms 01: right and adds the flip relation. 0 findings.
- fibonacci-type-sequence-terms 01: right. 0 findings.
- finding-number-patterns 01: right (+5,+8,+11,+14; +3 x3). 0 findings.
- odd-and-even-position-patterns 01: numbers right, 1 Major (rules shown before the steps).
- signed-integer-operations 01: ticks -6 to 6, bracket 0 to -6 at 6 steps. 0 findings.
- signed-integer-operations 02: -7 arrow to -7, +4 arrow to -3, circled. Matches text. 0 findings.
- substituting-negative-numbers 01: outline covers "(-3)" in the left panel, only "3" in the right. Matches text. 0 findings.
No picture shows the key of a check or try.

## Per lesson

- arithmetic-sequence-terms: 1 Major, 1 Minor
- arithmetic-series-sums: 2 Major, 1 Minor
- geometric-sequence-terms: 1 Major
- finite-geometric-series: 2 Major, 1 Minor
- infinite-geometric-series: 0 Major, 2 Minor
- harmonic-sequence-terms: 0 Major, 2 Minor
- fibonacci-type-sequence-terms: 0 Major, 1 Minor
- finding-number-patterns: 1 Major, 1 Minor
- odd-and-even-position-patterns: 2 Major, 2 Minor
- signed-integer-operations: 1 Major, 1 Minor
- substituting-negative-numbers: 2 Major

PRECHECK VERDICT: PASS (0 Blockers, 12 Majors)
