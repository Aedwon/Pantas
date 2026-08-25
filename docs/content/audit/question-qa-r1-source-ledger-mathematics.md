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
