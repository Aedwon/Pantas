# Brief: Laws of Exponents and Logarithms

Lesson id: `lesson-algebra-exponents-and-logarithms`
Lesson path: `content/lessons/mathematics/algebra/exponents-and-logarithms.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-exponents-and-logarithms|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> 3. Rewrite the negative exponent.
- Problem: The worked examples cover negative and fractional exponents but never cover the distinct zero-exponent case identified in the Level 3 record, so example coverage of defined powers is incomplete.
- Triage reason: Zero exponent is never taught or worked, though a^m divided by a^n gives it when m equals n.

### 2. `lesson-algebra-exponents-and-logarithms|L03|0`
- Rule: L03
- Fix size: small
- Quote:
> Simplify $\dfrac{(x^3y^2)(x^4y^{-1})}{x^2y^3}$ for nonzero $x$ and $y$.
- Problem: The exam verb "Simplify" appears without the required one-line explanation on its first use.
- Triage reason: Simplify is a first-use exam verb with no one-line explanation.

### 3. `lesson-algebra-exponents-and-logarithms|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Evaluate $8^{-\dfrac{2}{3}}$.
- Problem: The exam verb "Evaluate" appears without the required one-line explanation on its first use.
- Triage reason: Evaluate is a first-use exam verb with no one-line explanation.

### 4. `lesson-algebra-exponents-and-logarithms|L03|2`
- Rule: L03
- Fix size: small
- Quote:
> For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.
- Problem: The exam verb "express" appears without the required one-line explanation on its first use.
- Triage reason: Express is a first-use exam verb with no one-line explanation.

### 5. `lesson-algebra-exponents-and-logarithms|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Write the equivalent exponential equation:
- Problem: Example 3 presents its solution as unnumbered prose and display equations instead of the required numbered solution steps.
- Triage reason: Example 3 has no numbered steps, unlike the rest of the lesson.

### 6. `lesson-algebra-exponents-and-logarithms|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Because the exponential function with base $2$ is one-to-one, equate exponents.
- Problem: The term "one-to-one" is needed to justify equating exponents, but the lesson never explains what one-to-one means before using it.
- Triage reason: One-to-one is used to justify equating exponents but is never explained; say if 2^a = 2^b then a = b.

### 7. `lesson-algebra-exponents-and-logarithms|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.
- Problem: The example uses "common logarithm" before the lesson explains that an unwritten log base means base 10; that explanation appears only later in Traps to Watch For.
- Triage reason: Common logarithm is used in Example 4 but defined only in the last trap.

### 8. `lesson-algebra-exponents-and-logarithms|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> For expressions where the indicated powers and divisions are defined:
- Problem: The lesson's stated goal covers simplifying defined powers, but it never explains the zero-exponent identity a^0=1 for nonzero a, which the Level 3 record identifies as a distinct skill.
- Triage reason: The zero-exponent identity is missing from the laws; add a^0 = 1 for nonzero a with a short reason.

### 9. `lesson-algebra-exponents-and-logarithms|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> $$(a^m)^n=a^{mn}$$
- Problem: The lesson does not state the limitation needed for negative real bases with fractional outer exponents. Merely saying the indicated powers are defined is insufficient because both sides can be defined and still differ.
- Triage reason: The power-of-a-power law fails for some negative bases with fractional exponents, so the stated condition is too loose.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-algebra-exponents-and-logarithms|B01|0` (B01): As stated for all cases where the indicated powers are defined, this is false over the reals. With a=-1, m=2, and n=1/2, the left side is 1 while the right side is -1, and both sides are defined. Reason: True for the exponents exams use; adding 'for a > 0 or whole-number exponents' is cheap.
- `lesson-algebra-exponents-and-logarithms|L03|3` (L03): The exam verb "Solve" appears without the required one-line explanation on its first use. Reason: Solve is plain English a Grade 5 student already knows.
- `lesson-algebra-exponents-and-logarithms|L18|1` (L18): The logarithm examples cover direct evaluation and log-law manipulation but do not work a logarithmic equation with an unknown argument, a distinct inverse-log scenario identified in the Level 3 record. Reason: Example 3 already finds a log value via the exponential form; a solve-for-the-argument case is optional.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
