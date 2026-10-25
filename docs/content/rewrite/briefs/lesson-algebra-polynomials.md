# Brief: Polynomials

Lesson id: `lesson-algebra-polynomials`
Lesson path: `content/lessons/mathematics/algebra/polynomials.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-polynomials|L26|0`
- Rule: L26
- Fix size: large
- Quote:
> Polynomial long division works for division by a nonzero polynomial.
- Problem: Polynomial long division is only named with a condition; the lesson never explains the division algorithm or how the method works.
- Triage reason: Long and synthetic division are only named; no procedure or worked example is taught though division is in the goal.

### 2. `lesson-algebra-polynomials|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> If $A=3x^2-2x+5$ and $B=-x^2+4x-1$, simplify $2A-B$.
- Problem: The recorded learning goal includes classifying polynomial terms, but the worked examples begin with polynomial operations and never include a polynomial-versus-nonpolynomial classification case.
- Triage reason: Core Concept says which terms are polynomial terms but no example classifies one.

### 3. `lesson-algebra-polynomials|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> Find $(x-3)(x+3)(x^2+9)$.
- Problem: The multiplication coverage relies on special-product identities and does not provide a worked example of general term-by-term polynomial multiplication by distribution.
- Triage reason: No example multiplies polynomials term by term; Example 2 uses only special products.

### 4. `lesson-algebra-polynomials|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> Factor $6x^2-7x-3$ completely.
- Problem: The lesson teaches both monic and nonmonic quadratic factoring, but its only direct quadratic-factorization example is nonmonic, leaving the distinct monic case without a worked example.
- Triage reason: The monic quadratic method is taught but only a nonmonic factoring example exists.

### 5. `lesson-algebra-polynomials|L25|1`
- Rule: L25
- Fix size: medium
- Quote:
> Standard synthetic division is a shortcut for a linear divisor of the form $x-c$.
- Problem: The lesson uses the term "synthetic division" without explaining what the procedure is before later giving a sign rule for it.
- Triage reason: Synthetic division is named but never explained or worked; teach it briefly or drop it.

### 6. `lesson-algebra-polynomials|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A polynomial in $x$ is a finite sum of terms of the form $a_kx^k$, where each coefficient $a_k$ is a number and each exponent $k$ is a nonnegative integer.
- Problem: This opening sentence packs several advanced terms and ideas into one long sentence, including finite sum, coefficient, exponent, and nonnegative integer, which is above the required Grade 5 teaching-prose standard.
- Triage reason: The opening definition packs several formal terms into one sentence, too hard for Grade 5.

### 7. `lesson-algebra-polynomials|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> A numerical substitution can help **disprove** an incorrect proposed simplification quickly.
- Problem: The phrase uses abstract vocabulary such as numerical substitution, disprove, and proposed simplification without simpler wording, making the teaching prose harder than the required Grade 5 level.
- Triage reason: Numerical substitution and disprove are hard words; say try a number to show a wrong answer.

### 8. `lesson-algebra-polynomials|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> If $A=3x^2-2x+5$ and $B=-x^2+4x-1$, simplify $2A-B$.
- Problem: The exam verb "simplify" appears without the required one-line explanation of what the student is being asked to do.
- Triage reason: Simplify is a first-use exam verb with no one-line explanation.

### 9. `lesson-algebra-polynomials|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Factor $6x^2-7x-3$ completely.
- Problem: The exam verb "Factor" appears without a one-line explanation on its first use as an instruction.
- Triage reason: Factor means write as a product but is never defined, and it is the lesson main verb.

### 10. `lesson-algebra-polynomials|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> $$(x-3)(x+3)=x^2-9$$
- Problem: Example 2 uses the difference-of-squares identity before Core Concept has stated its formula. Core Concept only names the identity, so the formula is introduced for the first time inside the example.
- Triage reason: Core Concept only names difference of squares and perfect squares; the formulas are first shown in an example.

### 11. `lesson-algebra-polynomials|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Then subtract all terms of $B$:
- Problem: Example 1 presents its solution as unnumbered prose and equations instead of the required numbered sequence of solution steps.
- Triage reason: Example 1 has no numbered steps.

### 12. `lesson-algebra-polynomials|L19|1`
- Rule: L19
- Fix size: small
- Quote:
> $$(x-3)(x+3)=x^2-9$$
- Problem: Example 2 gives successive equations without any numbered solution steps, contrary to the required worked-example format.
- Triage reason: Example 2 has no numbered steps.

### 13. `lesson-algebra-polynomials|L19|2`
- Rule: L19
- Fix size: small
- Quote:
> By the Remainder Theorem, the remainder is $P(2)$.
- Problem: Example 4 uses unnumbered prose followed by a display equation instead of presenting each solution step as a numbered list.
- Triage reason: Example 4 has no numbered steps.

### 14. `lesson-algebra-polynomials|L19|3`
- Rule: L19
- Fix size: small
- Quote:
> Set the polynomial equal to $0$ at $x=3$.
- Problem: Example 5 gives the substitution and algebra as unnumbered prose and equations instead of numbered solution steps.
- Triage reason: Example 5 has no numbered steps.

### 15. `lesson-algebra-polynomials|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> For a monic quadratic $x^2+bx+c$, two numbers that multiply to $c$ and add to $b$ give a direct factorization.
- Problem: The term "monic quadratic" is required to understand this factoring rule but is never defined, and there is no prerequisite lesson supplying the meaning.
- Triage reason: Monic is never defined; say the x squared term has coefficient 1.

### 16. `lesson-algebra-polynomials|L26|1`
- Rule: L26
- Fix size: small
- Quote:
> For sums or differences of cubes, the common **SOAP** mnemonic can help with signs: Same, Opposite, Always Positive.
- Problem: The lesson names a mnemonic for cube factoring without teaching the sum-of-cubes and difference-of-cubes identities or explaining how the mnemonic maps onto them.
- Triage reason: Sum and difference of cubes identities are never stated, so SOAP has nothing to attach to.

### 17. `lesson-algebra-polynomials|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> For sums or differences of cubes, the common **SOAP** mnemonic can help with signs: Same, Opposite, Always Positive.
- Problem: The mnemonic is introduced without the underlying cube identities, so the student is not shown the precise pattern and conditions under which each sign choice applies.
- Triage reason: Same gap as the SOAP finding: the cube identities and when they apply are missing.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

None.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
