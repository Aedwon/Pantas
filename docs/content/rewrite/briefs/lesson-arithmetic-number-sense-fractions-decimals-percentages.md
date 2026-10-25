# Brief: Fractions, Decimals, and Percentages

Lesson id: `lesson-arithmetic-number-sense-fractions-decimals-percentages`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/fractions-decimals-percentages.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L01|0`
- Rule: L01
- Fix size: medium
- Quote:
> To turn a percentage into a decimal, divide by $100$. To turn a decimal into a percentage, multiply by $100$. To turn a fraction into a decimal, divide the numerator by the denominator; then multiply the decimal by $100$ if you need a percentage.
- Problem: The recorded goal also requires choosing the correct base for percentage calculations, but Core Concept teaches only conversion directions and never teaches a general way to identify the percentage base before examples require it.
- Triage reason: Choosing the percentage base is in the goal but Core Concept only teaches conversions.

### 2. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L17|1`
- Rule: L17
- Fix size: medium
- Quote:
> $$0.40x = 72$$
- Problem: This percent-amount equation is first introduced inside Example #3. Core Concept does not first teach the percent-base relationship or the equation form used here.
- Triage reason: The part = rate x whole relationship behind 0.40x = 72 is never stated in Core Concept.

### 3. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> To turn a percentage into a decimal, divide by $100$. To turn a decimal into a percentage, multiply by $100$. To turn a fraction into a decimal, divide the numerator by the denominator; then multiply the decimal by $100$ if you need a percentage.
- Problem: The examples do not fully work every conversion scenario named by the learning goal. Fraction-to-decimal and percent-to-decimal appear only as stated intermediate results, and there is no worked percent-to-fraction conversion, so coverage is incomplete.
- Triage reason: No example converts a percent to a fraction, a conversion the lesson implies.

### 4. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L26|1`
- Rule: L26
- Fix size: medium
- Quote:
> If $40\%$ of a number is $72$, what is $15\%$ of the same number?
- Problem: The lesson's goal requires choosing the correct percentage base, but no general explanation of what the base is or how to identify it appears before this example requires that reasoning.
- Triage reason: Same gap as the L01 finding: what the base is and how to find it is never explained.

### 5. `lesson-arithmetic-number-sense-fractions-decimals-percentages|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> A **fraction** compares a numerator with a denominator, where the denominator is not zero. A **decimal** represents values using powers of $10$. A **percentage** means "per hundred" or "out of 100."
- Problem: The numeral 100 appears in prose outside inline math in the phrase "out of 100," which violates the rule that numbers in prose must be inside $...$.
- Triage reason: The 100 in out of 100 should be wrapped in math.

### 6. `lesson-arithmetic-number-sense-fractions-decimals-percentages|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> > **D** to **P**: multiply by $100$, so the decimal point moves 2 places right.
- Problem: The numeral 2 appears in prose outside inline math, so it should be wrapped as $2$.
- Triage reason: The 2 in 2 places should be wrapped in math.

### 7. `lesson-arithmetic-number-sense-fractions-decimals-percentages|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> > **P** to **D**: divide by $100$, so the decimal point moves 2 places left.
- Problem: The numeral 2 appears in prose outside inline math, so it should be wrapped as $2$.
- Triage reason: The 2 in 2 places should be wrapped in math.

### 8. `lesson-arithmetic-number-sense-fractions-decimals-percentages|B08|3`
- Rule: B08
- Fix size: small
- Quote:
> The percent sign ($\%$) can remind you that percent means "per 100."
- Problem: The numeral 100 appears in prose outside inline math in "per 100," which violates the math-notation rule.
- Triage reason: The 100 in per 100 should be wrapped in math.

### 9. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> Evaluate $\dfrac{3}{4} + 0.50 - 25\%$ and express the answer as a decimal.
- Problem: The exam verb "Evaluate" appears for the first time here, but the lesson never gives the required one-line explanation of what that verb asks the student to do.
- Triage reason: Evaluate is a first-use exam verb with no one-line explanation.

### 10. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> $$0.125 = \dfrac{125}{1000}$$
- Problem: This decimal-to-fraction place-value method is first introduced inside Example #1. Core Concept does not teach the method or formula before the example uses it.
- Triage reason: The place-value method for decimals to fractions is first shown in Example 1.

### 11. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L17|2`
- Rule: L17
- Fix size: small
- Quote:
> $$P = \dfrac{1}{4} \times \dfrac{8}{5} = \dfrac{2}{5}=0.4$$
- Problem: The solution uses division by a fraction through multiplication by its reciprocal, but Core Concept never introduces that method before the example uses it.
- Triage reason: Dividing by a fraction by multiplying by its reciprocal is used without being taught.

### 12. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A **fraction** compares a numerator with a denominator, where the denominator is not zero.
- Problem: The lesson uses "numerator" and "denominator" to define a fraction and later tells students to divide one by the other, but it never explains which part of a fraction each term names.
- Triage reason: Numerator and denominator are used without saying which part is which.

### 13. `lesson-arithmetic-number-sense-fractions-decimals-percentages|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> The last digit is in the thousandths place, so:
- Problem: The decimal-to-fraction method is developed for the first time inside this worked example instead of being explained as a general concept before application.
- Triage reason: Same gap as the L17 finding: the decimal to fraction method is not explained before Example 1.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#23`
- Facet: Decimal to fraction and simplification
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop Decimal to fraction and simplification or its distinct application before complete local facet teaching is claimed.

### 2. `mathematics-arithmetic-number-sense#25`
- Facet: Percent amount and base
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Develop Percent amount and base or its distinct application before complete local facet teaching is claimed.

### 3. `mathematics-arithmetic-number-sense#26`
- Facet: Fraction division/reciprocals
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop Fraction division/reciprocals or its distinct application before complete local facet teaching is claimed.

### 4. `mathematics-arithmetic-number-sense#29`
- Facet: Unlike-denominator addition/subtraction
- Verdict: absent
- Tier: official
- Missing ideas:
  - Develop Unlike-denominator addition/subtraction or its distinct application before complete local facet teaching is claimed.

### 5. `mathematics-arithmetic-number-sense#30`
- Facet: Fraction multiplication
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop Fraction multiplication or its distinct application before complete local facet teaching is claimed.

### 6. `mathematics-arithmetic-number-sense#31`
- Facet: Decimal multiplication/division procedures
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop Decimal multiplication/division procedures or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-fractions-decimals-percentages|L19|0` (L19): Example #5 states key calculations in prose instead of showing them as display equations. The same solution also states the final-price and total-drop calculations without display equations. Reason: The prose steps are simple arithmetic and no step is skipped.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
