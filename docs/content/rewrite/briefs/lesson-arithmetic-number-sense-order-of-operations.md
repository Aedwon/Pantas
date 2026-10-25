# Brief: Order of Operations (PEMDAS/GEMDAS)

Lesson id: `lesson-arithmetic-number-sense-order-of-operations`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/order-of-operations.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, pupcet, sm-foundation, upcat

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-order-of-operations|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> First, evaluate **G**rouping symbols or **P**arentheses.
- Problem: The exam verb "evaluate" is used without the required one-line explanation of what the verb asks the student to do.
- Triage reason: Evaluate is a first-use exam verb with no one-line explanation.

### 2. `lesson-arithmetic-number-sense-order-of-operations|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Simplify: $2 [ 5 + 3 ( 4 - 2 )^2 ] - 10$.
- Problem: The exam verb "Simplify" appears in a worked-example prompt without a one-line explanation when it is first introduced.
- Triage reason: Simplify is a first-use exam verb with no one-line explanation.

### 3. `lesson-arithmetic-number-sense-order-of-operations|L18|0`
- Rule: L18
- Fix size: small
- Quote:
> Second, evaluate **E**xponents and roots.
- Problem: Roots are included in the operation hierarchy, but no worked example requires evaluating a root. This leaves a distinct operation type named by the lesson without worked-example coverage.
- Triage reason: Roots are listed in the order of operations but no example has one.

### 4. `lesson-arithmetic-number-sense-order-of-operations|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Second, evaluate **E**xponents and roots.
- Problem: The terms "exponents" and "roots" are used before their meanings are explained. The exponent prerequisite is not referenced or briefly recalled here, and roots are not explained locally.
- Triage reason: Exponents and roots are used without a short reminder of what they mean.

### 5. `lesson-arithmetic-number-sense-order-of-operations|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> Second, evaluate **E**xponents and roots.
- Problem: Root evaluation is only named as part of the operation order. The lesson does not explain what a root means or how a student evaluates one.
- Triage reason: Roots are named but not explained; add one line and a small example.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#37`
- Facet: Signed integer operation rules
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop Signed integer operation rules or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-order-of-operations|L26|1` (L26): Substitution with a negative input is part of the recorded learning goal, but the method is first stated inside a worked solution. The lesson does not first explain why the negative value should be parenthesized when substituted. Reason: Example 4 gives the reason, and Trap 2 explains why the parentheses matter.

## Figures

None.

## Rules cited

| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
