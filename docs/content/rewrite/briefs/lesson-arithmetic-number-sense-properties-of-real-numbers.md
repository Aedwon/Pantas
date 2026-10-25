# Brief: Properties of Real Numbers (Commutative, Associative, Distributive, Identity, Inverse)

Lesson id: `lesson-arithmetic-number-sense-properties-of-real-numbers`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/properties-of-real-numbers.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-properties-of-real-numbers|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> 4. Choice D is the multiplicative identity property.
- Problem: Identity is only treated as a distractor in an identification example. The examples do not include a worked case where an additive or multiplicative identity is actually used to simplify a calculation, even though that is part of the learning goal.
- Triage reason: Identity appears only as a distractor; no example uses it, and the lesson gives no worked identity case.

### 2. `lesson-arithmetic-number-sense-properties-of-real-numbers|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> Simplify $4(2x - 3y) - 2(x + 5y)$.
- Problem: The exam verb "Simplify" appears without the required one-line explanation when it is first used.
- Triage reason: "Simplify" is an exam verb and has no one-line meaning on first use.

### 3. `lesson-arithmetic-number-sense-properties-of-real-numbers|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Evaluate $847 \times 63 + 847 \times 37$.
- Problem: The exam verb "Evaluate" appears without the required one-line explanation when it is first used.
- Triage reason: "Evaluate" is an exam verb and has no one-line meaning on first use.

### 4. `lesson-arithmetic-number-sense-properties-of-real-numbers|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> 2. Combine like terms.
- Problem: The lesson requires students to combine like terms without first explaining what like terms are or how to recognize them, and no prerequisite lesson is identified.
- Triage reason: Like terms are never defined, and a Grade 5 student cannot combine them from the instruction alone.

### 5. `lesson-arithmetic-number-sense-properties-of-real-numbers|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> 1. Factor out the common factor $847$.
- Problem: The example requires students to understand a common factor and the instruction to factor it out before those ideas are explained, with no prerequisite lesson identified.
- Triage reason: Factoring out a common factor is used in Example 4 before Core Concept shows distribution read in reverse.

### 6. `lesson-arithmetic-number-sense-properties-of-real-numbers|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> 2. Combine like terms.
- Problem: Collecting like terms is only named as an instruction. The lesson does not explain what makes terms alike or how their coefficients are combined, so the method is not actually taught.
- Triage reason: The method of combining like terms is only named, never explained; fix with the like-terms finding.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#52`
- Facet: Collect like algebraic terms
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Develop Collect like algebraic terms or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-properties-of-real-numbers|B08|0` (B08): The numbered property label uses a prose number outside inline math. The same formatting is repeated for properties 2 through 5, contrary to the rule that numbers in prose belong inside `$...$`. Reason: Numbered property labels work as headings; wrapping the label digits in math would be pedantic.
- `lesson-arithmetic-number-sense-properties-of-real-numbers|L01|0` (L01): The learning goal says students should use identities to simplify calculations, but identity is only defined and then recognized as a distractor. There is no worked example that actually uses an additive or multiplicative identity to simplify a calculation. Reason: Learning goal lives in audit records, not the lesson; the missing identity example is covered by the L18 finding.
- `lesson-arithmetic-number-sense-properties-of-real-numbers|L17|1` (L17): Reverse distribution by factoring out a common factor is first introduced inside the worked example. Core Concept gives only the forward distributive forms, while the explicit reverse-distribution teaching appears later under Speed Tricks & Shortcuts. Reason: Reverse distribution is the stated distributive formula read backward; a one-line pointer in Core Concept would help but is minor.
- `lesson-arithmetic-number-sense-properties-of-real-numbers|L18|1` (L18): The lesson teaches the zero restriction as an important inverse edge case, but no worked example tests or applies that distinct case. Reason: The zero edge case is stated in Core Concept; it can fold into the identity example rather than need its own.
- `lesson-arithmetic-number-sense-properties-of-real-numbers|L19|0` (L19): The inverse transformation is a key mathematical step but is kept inline in prose instead of being shown as a display equation as required for worked-solution computations. Reason: The inverse step is a one-line fact, not a computation, so inline text is acceptable.

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
