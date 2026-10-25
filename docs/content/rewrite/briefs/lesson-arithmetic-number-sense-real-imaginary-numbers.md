# Brief: Real and Imaginary Number Systems

Lesson id: `lesson-arithmetic-number-sense-real-imaginary-numbers`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/real-imaginary-numbers.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-real-imaginary-numbers|L17|1`
- Rule: L17
- Fix size: medium
- Quote:
> Multiply numerator and denominator by the conjugate $1+i$ so the denominator becomes real.
- Problem: Example 4 uses the conjugate-product method before Core Concept introduces the conjugate identity; the general identity appears only later in Speed Tricks & Shortcuts.
- Triage reason: The conjugate and its product rule appear only in Speed Tricks, after Example 4 uses them; teach them in Core Concept first.

### 2. `lesson-arithmetic-number-sense-real-imaginary-numbers|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> 1. Expand.
- Problem: Complex multiplication is part of the learning goal, but the lesson never teaches the multiplication method in Core Concept; the method first appears as an instruction inside the worked example.
- Triage reason: Complex multiplication (expand, then use i squared equals negative one) is never taught before Example 3 uses it.

### 3. `lesson-arithmetic-number-sense-real-imaginary-numbers|L26|1`
- Rule: L26
- Fix size: medium
- Quote:
> Multiply numerator and denominator by the conjugate $1+i$ so the denominator becomes real.
- Problem: Complex division is part of the learning goal, but the conjugate method is introduced only while solving the example instead of being explained beforehand as a concept and method.
- Triage reason: The idea of multiplying by the conjugate to clear the denominator is first met inside Example 4; fix with the conjugate finding.

### 4. `lesson-arithmetic-number-sense-real-imaginary-numbers|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Reduce each exponent modulo $4$.
- Problem: The solution uses the uncommon technical word "modulo" without first explaining it in simple Grade 5 language.
- Triage reason: "Modulo" is not a Grade 5 word; say divide by 4 and use the remainder.

### 5. `lesson-arithmetic-number-sense-real-imaginary-numbers|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> so the real-number identity $\sqrt{a}\sqrt{b}=\sqrt{ab}$ cannot be applied blindly when both radicands are negative.
- Problem: This teaching sentence uses the rare term "radicands" and a relatively dense construction instead of the required very simple Grade 5 prose.
- Triage reason: "Radicands" is a rare term, and the sentence is dense for a Grade 5 reader.

### 6. `lesson-arithmetic-number-sense-real-imaginary-numbers|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> Evaluate $i^{143}+i^{2024}$.
- Problem: The exam verb "Evaluate" is used without the required one-line explanation on its first use.
- Triage reason: "Evaluate" has no one-line meaning on first use.

### 7. `lesson-arithmetic-number-sense-real-imaginary-numbers|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> The powers of $i$ repeat every four powers:
- Problem: The four-power pattern used by Example 2 is introduced in Mnemonics & Memory Aids instead of Core Concept, but mathematics formulas used in examples must first appear in Core Concept.
- Triage reason: The four-power cycle of i is taught only in the Mnemonics section; Core Concept should state it before Example 2.

### 8. `lesson-arithmetic-number-sense-real-imaginary-numbers|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Reduce each exponent modulo $4$.
- Problem: The term "modulo" is needed to follow the method but is never defined or explained before the solution uses it.
- Triage reason: "Modulo" is used without a plain explanation of remainder cycles; same fix as the L02 finding.

### 9. `lesson-arithmetic-number-sense-real-imaginary-numbers|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> Multiply numerator and denominator by the conjugate $1+i$ so the denominator becomes real.
- Problem: The term "conjugate" and what makes 1+i the conjugate of 1-i are not explained before the division method depends on that meaning.
- Triage reason: "Conjugate" and why 1+i pairs with 1-i are never explained before the division method uses them.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-real-imaginary-numbers|L03|1` (L03): The exam verb "Express" is used without the required one-line explanation on its first use. Reason: "Express in standard form a+bi" states its own task; a separate verb gloss adds little.
- `lesson-arithmetic-number-sense-real-imaginary-numbers|L19|0` (L19): This is a key computation in the worked solution, but it is kept inline instead of being placed on its own display-equation line as required. Reason: The remainder facts are short inline steps; display math would be nicer but nothing is skipped.
- `lesson-arithmetic-number-sense-real-imaginary-numbers|L19|1` (L19): This second key computation is also kept inline instead of being shown as a display equation between numbered solution steps. Reason: Same as the other power-of-i step: inline is acceptable and no step is skipped.
- `lesson-arithmetic-number-sense-real-imaginary-numbers|L27|0` (L27): The lesson teaches complex division but never states the essential limitation that the complex divisor must be nonzero. Reason: The divisor must be nonzero is true but trivial and rarely tested for complex division.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
