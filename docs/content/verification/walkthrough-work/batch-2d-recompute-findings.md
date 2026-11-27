# Math batch 2d: Worker 2 independent recompute

Target: worktree at commit `9200f00e4`. Read-only. Lessons under `content/lessons/mathematics/arithmetic-number-sense/`
(short names below). Pictures under `content/illustrations/mathematics/arithmetic-number-sense/<lesson>/`.

Method: recomputed every display line, step, pair Right and Wrong line, check, try and Why answer, checklist value, and every
number and label in each picture. Solved each check and try from the stem first. Compared each pair's Wrong line with the
cited choice in `content/walkthrough-trap-evidence.json` (all 31 citations match; the two signed-integer and two
substituting ones match by mistake type, with different numbers than the quiz items).

Format: `Severity | file:line | value | my value | note`

## Numeric mismatches

None. Every number in all 11 lessons recomputed to the printed value.

## Item and wording findings (policy checks from the batch 2d brief)

Major | signed-integer-operations.md:20 | "A signed integer is a whole number with a plus or minus sign" | integer | "Whole number" excludes negatives; the examples are $-3$ and $-12$. Say "an integer (a counting number, its negative, or $0$) written with a plus or minus sign", or just "a number such as $5$, $-3$, $-12$ with no fraction part".
Major | arithmetic-sequence-terms.md:180 | `:::try` "add $1$ to count the first term" | $20$ | Hands the step and the arithmetic ($19+1$). Student does not choose the rule. Ask "Finish the count: how many terms in all?"
Major | arithmetic-series-sums.md:158 | `:::try` "find $a_6=S_6-S_5$" | $15$ | Gives the formula and both values; only $60-45$ is left. Ask "Use $S_6$ and $S_5$ to find $a_6$."
Major | geometric-sequence-terms.md:132 | `:::try` "multiply $a_1=3$ by $(-2)^7=-128$" | $-384$ | Hands the operation and both factors; only $3\times(-128)$ is left. Ask "Finish: find $a_8$."
Major | finite-geometric-series.md:146 | `:::try` "compute $S_8=8(5)$" | $40$ | The rule is applied in the step above and the try prints the product. Ask "Finish: find $S_8$."
Major | finding-number-patterns.md:197 | `:::try` "$38+3$" | $41$ | Same defect Codex found in 2c: rule already applied, only arithmetic left. Ask "Finish: what is the next term?"
Major | odd-and-even-position-patterns.md:123 | `:::try` "find the seventh term using the odd-position rule" | $11$ | The step above states position $7$ is odd and the odd group rises by $3$; the key can be matched from visible text ($8+3$). Ask only for the seventh term.
Major | odd-and-even-position-patterns.md:24 | picture placement | n/a | The picture sits before step 1 and already shows "odd positions: x 2" and "even positions: / 3", the two rules the student is asked to find in steps 1 and 2. Move it after step 2 (or after the answer line).
Major | substituting-negative-numbers.md:108-114 | step 6 ends with a colon, then a `:::pair`, then step 7 | n/a | The colon introduces a display line that never appears in the numbered flow; the pair's Right line carries it and breaks the step list. Put the line `4-(-18)+(-6)=4+18+(-6)` under step 6 and move the pair after step 7 or after the example.
Minor | substituting-negative-numbers.md:153 | `:::try` "$18-3+(-1)$" | $14$ | Only arithmetic is left, but adding a negative is a lesson skill. Optional: ask for the whole value.
Minor | signed-integer-operations.md:216 | `:::try` "$-3+4$" | $1$ | Uses the different-signs rule on handed numbers; acceptable, optional to ask for the value only.
Minor | infinite-geometric-series.md:149 | `:::try` "compare $|r|$ with $1$" | no finite sum | Names the test; $r=2$ is obvious. Optional: ask "Does it have a finite sum?"
Minor | harmonic-sequence-terms.md:131 | `:::try` "return from $17$" | $\dfrac{1}{17}$ | Only a flip is left; the three steps above show it. Optional: ask for the $6^{\text{th}}$ term.
Minor | fibonacci-type-sequence-terms.md:119 | `:::try` "add the coefficients of $a$ and combine the plain numbers" | $5a-1$ | Names the procedure. Optional: ask "Finish: find $z$."
Minor | arithmetic-series-sums.md:17 | $n$ | n/a | $n$ is both "number of terms" and the position in $a_n$; fine for these sums, no change needed.

No wrong-verdict Wrong lines found. No Wrong line carries an extra uncited mistake (checked all pairs). No Why question names the
wrong thing. No "whole number" other than the one above is misused ("positive whole number" for $n$ is correct).

## Pictures (10): recomputed numbers and labels

Picture | verdict | notes
--- | --- | ---
arithmetic-sequence-terms/01 | OK | Boxes 5, 9, 13, 17, 21; four arcs +4; bracket spans first to fifth box, "4 steps (n - 1), not 5". Matches the text below it.
arithmetic-series-sums/01 | OK | 4, 7, 10, 13, 16, 19; pairs 10+13, 7+16, 4+19 each 23; 3 x 23 = 69. Matches the text above it.
infinite-geometric-series/01 | OK | To scale: total 320 px = 2, so 1 = 160, 1/2 = 80, 1/4 = 40, 1/8 = 20, dashed gap 1/8 = 20. Pieces fill 1.875. Matches running totals 1.5, 1.75, 1.875.
harmonic-sequence-terms/01 | OK | 1/3, 1/7, 1/11 flip to 3, 7, 11; two +4 arcs. Matches text.
fibonacci-type-sequence-terms/01 | OK | 2, 5, 7, 12, 19; 2+5=7, 5+7=12, 7+12=19. Matches text.
finding-number-patterns/01 | OK | 6, 11, 19, 30, 44; jumps +5, +8, +11, +14; second jumps +3 x3. Matches text. Picture does not show 17 or 61.
odd-and-even-position-patterns/01 | numbers OK, placement Major | 4, 81, 8, 27, 16, 9; x2 on odd, divide by 3 on even. Numbers match; picture is before the steps that find the rules (see above).
signed-integer-operations/01 | OK | Ticks -6 to 6 at 26 px; bracket 0 to -6 = 6 steps; |-6| = 6.
signed-integer-operations/02 | OK | 30 px per unit; arrow 0 to -7 (210 px), then +4 (120 px) to -3 (circled). Matches text.
substituting-negative-numbers/01 | OK | (-3)^2 = (-3) x (-3) = 9; -3^2 = -(3 x 3) = -9. Outlines match the text. No key of a check or try is shown (the check uses $-a^2$ with $a=-4$).

No picture shows a number missing from or different from the text beside it. Bar widths in the infinite-series picture are to scale.

## Per lesson (values checked, numeric mismatches, other findings)

Lesson | values checked | mismatches | other findings
--- | --- | --- | ---
arithmetic-sequence-terms | 40 | 0 | 1 Major
arithmetic-series-sums | 45 | 0 | 1 Major, 1 Minor
geometric-sequence-terms | 40 | 0 | 1 Major
finite-geometric-series | 45 | 0 | 1 Major
infinite-geometric-series | 45 | 0 | 1 Minor
harmonic-sequence-terms | 35 | 0 | 1 Minor
fibonacci-type-sequence-terms | 35 | 0 | 1 Minor
finding-number-patterns | 50 | 0 | 1 Major
odd-and-even-position-patterns | 35 | 0 | 2 Major (try, picture placement)
signed-integer-operations | 55 | 0 | 1 Major, 1 Minor
substituting-negative-numbers | 40 | 0 | 1 Major, 1 Minor

RECOMPUTE VERDICT: PASS on numbers (0 mismatches). Item and wording findings above: 0 Blockers, 9 Majors, 6 Minors.
