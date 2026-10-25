# Brief: Types of Functions (Linear, Quadratic, Rational, Absolute Value, Exponential, Logarithmic, Piecewise)

Lesson id: `lesson-algebra-types-of-functions`
Lesson path: `content/lessons/mathematics/algebra/types-of-functions.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-algebra-types-of-functions|L18|0`
- Rule: L18
- Fix size: large
- Quote:
> Rational graphs may have vertical, horizontal, or slant asymptotes, and they may also have removable discontinuities.
- Problem: The lesson gives a worked example only for vertical and equal-degree horizontal asymptotes. It provides no worked slant-asymptote or removable-discontinuity case even though those are distinct graph scenarios named in the teaching.
- Triage reason: Slant asymptotes and removable holes are named but never worked or even explained.

### 2. `lesson-algebra-types-of-functions|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> Transformed absolute-value functions can shift, stretch, or reflect this graph.
- Problem: Shift, stretch, and reflection are distinct absolute-value graph variations, but none receives a worked example, so the stated graph behavior is not covered by the examples.
- Triage reason: Shift, stretch and reflection of the absolute-value graph are named with no example.

### 3. `lesson-algebra-types-of-functions|L25|0`
- Rule: L25
- Fix size: medium
- Quote:
> Rational graphs may have vertical, horizontal, or slant asymptotes, and they may also have removable discontinuities.
- Problem: The terms "slant asymptote" and "removable discontinuity" are introduced without explanation in this lesson or the identified prerequisite, before students are expected to recognize rational graph features.
- Triage reason: Slant asymptote and removable discontinuity are used without any meaning given.

### 4. `lesson-algebra-types-of-functions|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> Transformed absolute-value functions can shift, stretch, or reflect this graph.
- Problem: The lesson names shift, stretch, and reflection but does not explain how a transformed absolute-value function produces those changes, so the concept is only named.
- Triage reason: Transformations are named but how each changes the graph is not explained.

### 5. `lesson-algebra-types-of-functions|L26|2`
- Rule: L26
- Fix size: medium
- Quote:
> Rational graphs may have vertical, horizontal, or slant asymptotes, and they may also have removable discontinuities.
- Problem: Slant asymptotes and removable discontinuities are named but their meaning and mechanism are not explained; the prerequisite lesson does not supply those explanations.
- Triage reason: Same gap as the L25 finding: slant asymptote and removable hole meanings and causes are missing.

### 6. `lesson-algebra-types-of-functions|L27|0`
- Rule: L27
- Fix size: medium
- Quote:
> Numerator and denominator have the same degree. Their leading coefficients are both $1$, so the horizontal asymptote is:
- Problem: The lesson teaches only the equal-degree horizontal-asymptote case inside the example. It does not explain the other degree conditions or when cancellation changes a denominator zero from a vertical asymptote into a removable hole.
- Triage reason: Only the equal-degree asymptote case is taught; other degree cases and hole cancellation are missing.

### 7. `lesson-algebra-types-of-functions|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> For a fixed exponential base $a>1$, $a^x$ eventually grows faster than any fixed polynomial as $x\to\infty$. This statement does **not** apply to an exponential with $0<a<1$, which decays as $x$ increases.
- Problem: This trap uses dense terms and a long two-clause explanation such as "fixed polynomial" and behavior as x approaches infinity without simplifying them to the Grade 5 teaching-prose standard.
- Triage reason: Trap #3 uses fixed polynomial and limit notation that is too dense for Grade 5.

### 8. `lesson-algebra-types-of-functions|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Solve $2^{x+1}=32$, then evaluate $\log_3 81$.
- Problem: The exam verb "evaluate" appears without the required one-line explanation of what the student is being asked to do.
- Triage reason: Evaluate is a first-use exam verb with no one-line explanation.

### 9. `lesson-algebra-types-of-functions|L18|2`
- Rule: L18
- Fix size: small
- Quote:
> If $a>1$, the function grows as $x$ increases; if $0<a<1$, it decays.
- Problem: Growth and decay are distinct exponential cases, but the examples only solve a same-base exponential equation and do not work either growth or decay behavior.
- Triage reason: Growth versus decay is stated but no example identifies either case.

### 10. `lesson-algebra-types-of-functions|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> Since $32=2^5$:
- Problem: Example 5 presents its reasoning and display equations without a numbered solution-step list, contrary to the required worked-solution format.
- Triage reason: Example 5 has no numbered steps.

### 11. `lesson-algebra-types-of-functions|L19|1`
- Rule: L19
- Fix size: small
- Quote:
> For $x=2$, use the second rule:
- Problem: Example 6 presents branch selection and calculations as prose plus display equations without numbering the solution steps.
- Triage reason: Example 6 has no numbered steps.

### 12. `lesson-algebra-types-of-functions|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> **Absolute value:** $f(x)=|x|$ has a V-shaped graph and outputs only nonnegative values.
- Problem: The notation |x| and the meaning of absolute value are not defined before the lesson later uses the concept to split an absolute-value equation into two cases.
- Triage reason: Absolute value and the bars notation are never defined; add distance from zero and the two-case definition.

### 13. `lesson-algebra-types-of-functions|L26|1`
- Rule: L26
- Fix size: small
- Quote:
> $$2x-5=7\quad\text{or}\quad2x-5=-7$$
- Problem: The worked solution uses the two-branch absolute-value rule without first explaining why an equation |u|=c with positive c leads to u=c or u=-c.
- Triage reason: The split into u = c or u = -c is not justified; add that |u| is the distance from zero.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-algebra-types-of-functions|L03|0` (L03): The exam verb "Classify" is used as a command without the required one-line explanation before its first use. Reason: Classify is easy to read and the Core Concept already names the families.
- `lesson-algebra-types-of-functions|L18|3` (L18): Graph matching is presented as an exam-relevant recognition method, but there is no worked graph-matching example showing the method at target difficulty. Reason: Graph matching is a strategy tip; a full figure-based example is optional.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
