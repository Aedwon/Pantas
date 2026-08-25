# Question QA R1 source ledger — Mathematics

**Branch:** `web/content-qa-questions-r1`  
**Base:** `3a1ac087fd88bce1e1903d5c7996371054b36094`  
**Started:** 25 August 2026

This ledger records evidence for substantive Mathematics question corrections. Routine numerical items are verified by independent recomputation; external sources are used where a question contains a convention or domain-specific factual premise rather than pure arithmetic.

## Arithmetic and Number Sense

| Question | Finding | Disposition | Evidence |
|---|---|---|---|
| `q-arithmetic-number-sense-business-math-0002` | The original key silently rounded a 7.5 km excess distance upward. | CORRECTED | The charging convention is now stated directly in the hypothetical stem: each additional kilometer **or fraction thereof** is charged as a full kilometer. The computation is then self-contained: 7.5 km excess -> 8 chargeable km -> ₱27.40. |
| `q-arithmetic-number-sense-business-math-0007` | A 20% student jeepney discount was written as if it were a timeless external fare rule. | CORRECTED | The discount is now an explicit hypothetical input. The item therefore tests percentages without asserting a current regulated fare policy. |
| `q-arithmetic-number-sense-business-math-0014` | “15 passengers per trip” was ambiguous while the solution used 15 per one-way leg of every round trip. | CORRECTED | Stem now says each **one-way leg** carries 15 paying passengers. Recomputed: 8 round trips = 16 legs; 240 passenger rides; ₱3,120 gross; ₱1,370 after stated expenses. |
| `q-arithmetic-number-sense-divisibility-rules-0013` | Original constraints produce two valid digit pairs: `(3,5)` and `(7,9)`, so `x+y` is not unique. | CORRECTED | Direct divisibility-by-8 and divisibility-by-11 enumeration gives sums 8 and 16. Stem now asks for the **minimum** possible value, preserving key 8. |
| `q-arithmetic-number-sense-divisibility-rules-0014` | Original constraints produce two valid digit pairs: `(2,0)` and `(3,8)`, so `x+y` is not unique. | CORRECTED | Direct divisibility-by-8 and divisibility-by-9 enumeration gives sums 2 and 11. Stem now asks for the **maximum** possible value, preserving key 11. |
| `q-arithmetic-number-sense-properties-of-real-numbers-0005` | `1+(2+3)=(2+1)+3` cannot be justified by commutativity alone. | CORRECTED | First apply associativity: `1+(2+3)=(1+2)+3`; then commutativity: `(1+2)+3=(2+1)+3`. The item now asks for that two-property sequence. |
| `q-arithmetic-number-sense-order-of-operations-0010` | `36 ÷ 4(3)` relies on contested implicit-multiplication typography. | CORRECTED | The stem now writes the intended operation explicitly as `36 ÷ 4 × 3 + 2^3`, so ordinary equal-precedence left-to-right evaluation is unambiguous. |
| `q-arithmetic-number-sense-order-of-operations-0015` | Opening change-fund cash was counted in a quantity labelled “personal net income.” | CORRECTED | The item is now explicitly a **cash allocation** problem. Recomputed remaining balance is ₱362, split into two envelopes = ₱181 each. |
| `q-arithmetic-number-sense-real-imaginary-numbers-0001` | Whether 0 belongs to the natural numbers varies by convention. | CORRECTED | Stem now explicitly defines `N={1,2,3,...}`; the repository lesson uses this same convention. |
| `q-arithmetic-number-sense-real-imaginary-numbers-0015` | Original engineering context said `Z_total = Z1 * Z2` for two impedances and gave the product units as ohms. | CORRECTED | All About Circuits, “Series Resistor-Capacitor Circuits”: https://www.allaboutcircuits.com/textbook/alternating-current/chpt-4/series-resistor-capacitor-circuits/ — series impedances add in complex form to form total impedance. The item now tests only the mathematically valid complex-number product `(4+3i)(2-5i)=23-14i`, without claiming that product is total impedance. |
| `q-arithmetic-number-sense-sequences-and-series-0014` | The original conditions allow both `d=0` and `d=5`; the explanation rejected 0 only as “trivial.” | CORRECTED | Direct algebra gives `4d^2-20d=0`, hence `d=0` or `5`. Stem now specifies a **nonconstant** arithmetic sequence, making `d=5` unique. |

## Arithmetic lesson dependencies

Question fixes were not replaced with defective lesson wording. The following lesson-only issues should be repaired separately:

1. `content/lessons/mathematics/arithmetic-number-sense/business-math.md`
   - describes the **Rule of 72** as a shortcut “for simple interest problems.” FINRA describes it as a heuristic for estimating doubling time under interest-on-interest / compound-growth contexts: https://www.finra.org/financial_knowledge_quiz/confirmation
2. `content/lessons/mathematics/arithmetic-number-sense/divisibility-rules.md`
   - says “Zero is divisible by every number.” The question bank correctly limits this to every **non-zero integer**, because division by zero is undefined.
3. `content/lessons/mathematics/arithmetic-number-sense/prime-factorization-gcf-lcm.md`
   - asks for the smallest positive integer leaving remainder 3 when divided by 6, 8, and 10 and gives 123. Without an additional lower-bound condition, **3 itself** satisfies all three remainder conditions and is the true smallest positive solution.

The other six arithmetic-number-sense lessons reviewed in this pass support the corrected/verified item competencies without an identified item-level contradiction.

## Algebra

| Question | Finding | Disposition | Evidence |
|---|---|---|---|
| `q-algebra-exponents-and-logarithms-0002` | Simplifying `x^7/x^3` to `x^4` without preserving `x != 0` broadens the domain of the original expression. | CORRECTED | The original denominator is zero at `x=0`; the simplified polynomial is defined there. Stem and explanation now state `x != 0`. |
| `q-algebra-exponents-and-logarithms-0010` | The original variable quotient omitted the restrictions required by denominator powers and the negative exponent. | CORRECTED | The expression contains `x^2 y^3` in the denominator and `y^-1`, so the real algebraic expression requires `x != 0` and `y != 0`. Those conditions are now explicit. |
| `q-algebra-exponents-and-logarithms-0011` | The log-condensation item omitted the positive-argument domain of the original real logarithms. | CORRECTED | `log(x)` and `log(y)` require `x>0` and `y>0`. The item now states both conditions before condensing to `log(x^2 y)`. |
| `q-algebra-radicals-and-rationalization-0008` | Pulling `x` from `sqrt(x^2)` as `x` silently assumes `x>=0`; in general `sqrt(x^2)=|x|`. | CORRECTED | Stem now assumes `x>=0`, under which the keyed simplification `6xy^2 sqrt(2x)` is valid. |
| `q-algebra-radicals-and-rationalization-0012` | `1/cuberoot(x)` is undefined at `x=0`, but the original item did not state that restriction. | CORRECTED | The denominator must be nonzero. Stem and explanation now state `x != 0`. |
| `q-algebra-radicals-and-rationalization-0016` | The original simplification used `sqrt(x^2)=x` and a real square root without specifying variable domains. | CORRECTED | Stem now states `x>=0` and `y>=0`, making both the real radical and the extraction of `x` valid. |
| `q-algebra-radicals-and-rationalization-0017` | The conjugate expression uses `sqrt(y)` but did not state a real-variable premise. | CORRECTED | Stem now states real `x` and `y>=0`; the algebraic identity then follows by difference of squares. |
| `q-algebra-functions-and-relations-0006` | `f^-1` was described as an inverse function without stating that `f` is invertible. | CORRECTED | An inverse function exists only when the original function is one-to-one on the stated domain. The stem now explicitly assumes `f` is invertible. |
| `q-algebra-linear-equations-inequalities-0009` | A per-shirt markup was treated as per-shirt profit. Markup alone does not establish profit without the underlying cost/revenue relationship. | CORRECTED | The hypothetical now states directly that the owner earns ₱80 profit per shirt; `80s=800` then tests only the intended linear equation. |
| `q-algebra-polynomials-0012` | The original stem said only “Factor,” while the choice `2x(2x+4)` is algebraically equivalent to `4x(x+2)`, creating two defensible answers. | CORRECTED | Stem now asks to factor **completely by taking out the greatest common factor**. The equivalent partial factorization is explicitly identified as incomplete. |
| `q-algebra-quadratic-equations-0006` | “Never divide both sides by x” was an overstatement. The real defect is dividing by a quantity that may be zero without handling that case. | CORRECTED | For `x^2=4x`, dividing by `x` assumes `x!=0` and discards the valid solution `x=0`. Explanation now states that precise reason. |
| `q-algebra-quadratic-equations-0011` | The original item said factoring the left side of `x^2-5x=6` was the mistake. Factoring it as `x(x-5)=6` is valid. | CORRECTED | The actual invalid step is changing the equation to `x(x-5)=0` without subtracting 6 from both sides. The rewritten item tests that exact zero-product error. |
| `q-algebra-quadratic-equations-0012` | The explanation said a positive number has two square roots, conflating the principal square-root function with solutions of a quadratic equation. | CORRECTED | `sqrt(25)=5` by definition of the principal root; the equation `x^2=25` has two real solutions, `x=5` and `x=-5`. The item now makes this distinction. |
| `q-algebra-quadratic-equations-0016` | The explanation used a loose sign heuristic where Vieta's formulas give an exact justification for this equation. | CORRECTED | Product `=6>0` means the two real roots have the same sign; sum `=-5<0` means both are negative. Key unchanged. |
| `q-algebra-sets-and-set-notation-0013` | One distractor rationale contradicted the item solution by saying both sets contain 3. | CORRECTED | `3` is in `A`, while `3^2=9` fails the strict condition `x^2<9`, so `3` is not in `B`. Rationale now matches the mathematics. |
| `q-algebra-sets-and-set-notation-0012` | After the three-set union item, this derivative item reduced to `100-93` and added essentially no new assessment information. | RETIRED | Removed from the YAML instead of preserving a low-information count-only item. Its original ID remains in the QA ledger with `RETIRED` status. |

Difficulty-only metadata corrections are recorded in the per-item Algebra TSVs and are not duplicated in this evidence table.

## Algebra lesson dependencies

Question fixes were not forced to match inaccurate or incomplete lesson wording. The following lesson issues should be repaired separately:

1. `content/lessons/mathematics/algebra/exponents-and-logarithms.md`
   - simplifies variable quotients without preserving nonzero-domain restrictions;
   - condenses logarithms without stating that the real logarithm arguments must be positive.
2. `content/lessons/mathematics/algebra/radicals-and-rationalization.md`
   - simplifies `sqrt(72x^3y^4)` to `6xy^2 sqrt(2x)` without stating `x>=0` or using an absolute-value treatment;
   - similarly omits necessary domain restrictions in variable radical/rationalization examples.
3. `content/lessons/mathematics/algebra/quadratic-equations.md`
   - says a negative discriminant gives two “imaginary” answers; the precise result is two **non-real complex** roots, which need not be purely imaginary;
   - says factoring the left side before setting the equation to zero is itself wrong, although factoring `x^2-5x` as `x(x-5)` is algebraically valid;
   - says every positive number has two square roots, conflating the principal square-root function with the two real solutions of `x^2=a`;
   - gives “never divide both sides by x” as an absolute rule instead of explaining that division by a possibly-zero expression can discard solutions.

The other eight Algebra lessons reviewed in this pass support their corresponding corrected/verified question competencies without an identified item-level contradiction.
