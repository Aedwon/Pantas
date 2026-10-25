# Brief: Prime Factorization, GCF, and LCM

Lesson id: `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/prime-factorization-gcf-lcm.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L01|0`
- Rule: L01
- Fix size: medium
- Quote:
> Find the greatest common factor and the least common multiple of $12x^3y^2$ and $18xy^4$, assuming the variables represent nonzero quantities for the LCM expression.
- Problem: The recorded goal is about using prime powers for common groups, repeating events, and remainder conditions. This full worked example instead develops the separate monomial GCF/LCM extension, so substantial lesson content falls outside the recorded learning goal.
- Triage reason: Example 2 is algebraic GCF and LCM, which is outside the goal and not taught; remove it or teach it.

### 2. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L17|0`
- Rule: L17
- Fix size: medium
- Quote:
> 2. For the GCF, use each shared factor to the smaller exponent.
- Problem: The mathematics section-fit rule requires methods used by examples to be established in Core Concept. The lesson never teaches how the prime-power GCF/LCM method extends to variable factors before Example #2 applies it to x and y powers.
- Triage reason: Core Concept never teaches how prime powers extend to variables, which Example 2 uses.

### 3. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> This avoids a common error in a "continuous division" shortcut: dividing only by primes common to all rows and then multiplying the remaining bottom row does **not** always produce the LCM for three or more numbers.
- Problem: This sentence is long and syntactically dense for the Grade 5 teaching-prose standard. It combines the shortcut, the incorrect procedure, and its limitation in one sentence instead of using short, simple statements.
- Triage reason: This sentence is long and mixes the shortcut, the error and its limit; split it.

### 4. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L16|0`
- Rule: L16
- Fix size: small
- Quote:
> > **A.L.L.** for LCM: Take **A**ll prime bases and use the **L**argest exponent for each.
- Problem: The mnemonic appears constructed for this lesson instead of being a genuine or natural mnemonic, and its three-letter A.L.L. label does not even map to three stated mnemonic words. The guide says forced mnemonics should be omitted.
- Triage reason: A.L.L. and P.I.G. are made-up acronyms; the guide says drop forced mnemonics.

### 5. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Divide repeatedly by primes:
- Problem: Example #1 does not present its solution as a numbered list. It gives an unnumbered instruction, one display equation, and an unnumbered answer sentence, contrary to the required worked-solution format.
- Triage reason: Example 1 has no numbered steps.

### 6. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L21|0`
- Rule: L21
- Fix size: small
- Quote:
> $$360 = 2 \times 180 = 2^2 \times 90 = 2^3 \times 45 = 2^3 \times 3^2 \times 5.$$
- Problem: This chained display places several successive equalities and products on one line, making it too wide for the lesson guide's phone-screen display-equation requirement.
- Triage reason: The chained factorization line is too wide for a phone; split it into steps.

### 7. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> 1. Factor the coefficients.
- Problem: The term "coefficients" is needed to follow Example #2 but is never defined or briefly explained earlier, and the packet provides no prerequisite lesson that teaches it.
- Triage reason: Coefficient is used in Example 2 and never defined.

### 8. `lesson-arithmetic-number-sense-prime-factorization-gcf-lcm|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> If a factor is still composite, continue factoring it.
- Problem: The term "composite" is used as the condition for continuing prime factorization, but the lesson never defines what a composite number is and there is no prerequisite supplying that meaning.
- Triage reason: Composite is used but never defined.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

None.

## Figures

None.

## Rules cited

| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L16 | Section titles are exact; mnemonics only when genuine; extra sections sparing | Minor | Compare headings with the guide | LSG: Section structure |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L21 | Display equations fit a phone screen | Minor | Look for long display lines | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
