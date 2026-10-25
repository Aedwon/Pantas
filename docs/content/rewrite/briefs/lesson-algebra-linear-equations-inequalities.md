# Brief: Linear Equations and Inequalities (Solving and Graphing)

Lesson id: `lesson-algebra-linear-equations-inequalities`
Lesson path: `content/lessons/mathematics/algebra/linear-equations-inequalities.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-linear-equations-inequalities|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> In one variable, its solution is shown on a number line.
- Problem: The lesson names one-variable inequality graphing but gives no worked example showing endpoint choice and shading direction on a number line.
- Triage reason: Number-line graphing of a one-variable inequality is taught but never worked.

### 2. `lesson-algebra-linear-equations-inequalities|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> If $B=0$, the equation is a vertical line $x=\dfrac{C}{A}$ and its slope is undefined.
- Problem: Vertical and horizontal slope edge cases are taught but never worked as an example, so the example set does not cover this distinct exam-relevant variation.
- Triage reason: Vertical and horizontal line slopes are taught as edge cases but no example works them.

### 3. `lesson-algebra-linear-equations-inequalities|L01|0`
- Rule: L01
- Fix size: small
- Quote:
> A store sells basic calculators for Php $150$ and scientific calculators for Php $400$. If it sells $30$ calculators for total revenue of Php $7,000$, how many basic calculators were sold?
- Problem: This worked two-variable system modeling problem is outside the recorded learning goal, which covers one-variable linear relations, slope/intercept/boundary information, and interpretation of a two-variable linear-inequality region.
- Triage reason: Example 5 is a two-variable system, which the Core Concept never teaches and the goal does not cover; remove or relocate it.

### 4. `lesson-algebra-linear-equations-inequalities|L17|0`
- Rule: L17
- Fix size: small
- Quote:
> 1. Because $B=5\ne0$, the slope of $Ax+By=C$ is $-\dfrac{A}{B}$.
- Problem: The standard-form slope formula is introduced for the first time inside Example 3 instead of appearing earlier in Core Concept.
- Triage reason: The standard-form slope formula appears first in Example 3 and later in Speed Tricks, not in Core Concept.

### 5. `lesson-algebra-linear-equations-inequalities|L17|1`
- Rule: L17
- Fix size: small
- Quote:
> 2. A nonvertical line perpendicular to a line of nonzero slope has slope equal to the negative reciprocal.
- Problem: The perpendicular-slope relationship is introduced inside Example 3 rather than being established first in Core Concept.
- Triage reason: The perpendicular-slope rule is only in Example 3 and the traps, never stated in Core Concept.

### 6. `lesson-algebra-linear-equations-inequalities|L17|2`
- Rule: L17
- Fix size: small
- Quote:
> 3. Use point-slope form.
- Problem: Point-slope form is invoked here and used in the next displayed equation, but its formula is never introduced in Core Concept before the example.
- Triage reason: Point-slope form is used in Example 3 but its formula is never stated.

### 7. `lesson-algebra-linear-equations-inequalities|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Let $b$ be the number of basic calculators and $s$ the number of scientific calculators.
- Problem: Example 5 presents its solution as unnumbered prose and equations instead of the required numbered sequence of solution steps.
- Triage reason: Example 5 has no numbered steps.

### 8. `lesson-algebra-linear-equations-inequalities|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> In one variable, its solution is shown on a number line.
- Problem: The lesson names the number-line representation but does not explain how open versus closed endpoints and left-versus-right shading work.
- Triage reason: Open versus closed endpoints and shading direction on a number line are not explained.

### 9. `lesson-algebra-linear-equations-inequalities|L26|1`
- Rule: L26
- Fix size: small
- Quote:
> 1. Cross-multiply.
- Problem: The lesson uses equation-solving procedures without explaining the equality-preserving idea that equivalent operations must keep both sides balanced.
- Triage reason: Cross-multiply is used with no reason; say that equal fractions stay equal when both sides are multiplied by the denominators.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-algebra-linear-equations-inequalities|L03|0` (L03): The exam verb "Solve" is used in a worked-example prompt without the required one-line explanation of what the verb asks the student to do. Reason: Solve is plain English a Grade 5 student already knows.
- `lesson-algebra-linear-equations-inequalities|L03|1` (L03): The exam verb "Find" is used in a worked-example prompt without a one-line explanation on its first use as an exam instruction. Reason: Find is plain English and needs no exam-verb definition.
- `lesson-algebra-linear-equations-inequalities|L18|1` (L18): This graphing procedure has no worked example that constructs a line from slope-intercept information, leaving a distinct in-goal scenario uncovered. Reason: Example 4 already uses slope and intercept to find a boundary; a separate graphing example is optional.

## Figures

None.

## Rules cited

| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
