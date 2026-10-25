# Brief: Sequences and Series (Arithmetic, Geometric, Fibonacci, Harmonic)

Lesson id: `lesson-arithmetic-number-sense-sequences-and-series`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/sequences-and-series.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-sequences-and-series|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> Finite geometric series for $r\ne1$:
- Problem: Finite geometric-series sums are taught as a distinct exam-relevant case but receive no worked example, so the example set does not cover every distinct scenario.
- Triage reason: The finite geometric sum formula is taught but no example uses it; add one worked case.

### 2. `lesson-arithmetic-number-sense-sequences-and-series|L03|1`
- Rule: L03
- Fix size: small
- Quote:
> Evaluate $18+6+2+\dfrac{2}{3}+\dots$.
- Problem: The exam verb "Evaluate" is used without the required one-line explanation on its first use.
- Triage reason: "Evaluate" has no one-line meaning on first use.

### 3. `lesson-arithmetic-number-sense-sequences-and-series|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> The reciprocals of its nonzero terms form an arithmetic sequence.
- Problem: The lesson requires students to use reciprocals to understand and solve harmonic sequences but never explains that taking a reciprocal means replacing a nonzero number x with 1/x; the prerequisite also does not supply that definition with a reminder.
- Triage reason: "Reciprocal" is used to define harmonic sequences without saying it means one over the number.

### 4. `lesson-arithmetic-number-sense-sequences-and-series|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> Infinite geometric series converges only when $|r|<1$:
- Problem: The term "converges" is needed to understand the recorded learning goal and the infinite-series rule, but its meaning is not explained before it is used.
- Triage reason: "Converges" is used without a plain meaning such as the sum settles near one number.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#80`
- Facet: General number-pattern discovery
- Verdict: thin
- Tier: official
- Missing ideas:
  - Develop General number-pattern discovery or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-sequences-and-series|L03|0` (L03): The exam verb "Find" is used in a question without a one-line explanation of what the verb asks the student to do. Reason: "Find" is an everyday verb; a gloss is unnecessary.
- `lesson-arithmetic-number-sense-sequences-and-series|L17|0` (L17): The symbolic Fibonacci-type recurrence $x+y=z$ is introduced for the first time inside the worked example; Core Concept states the relationship only in prose, while L17 requires every formula used in an example to appear in Core Concept first. Reason: Core Concept already states the sum-of-two-preceding rule in words; x+y=z is trivial notation.
- `lesson-arithmetic-number-sense-sequences-and-series|L18|1` (L18): The special r=1 finite-geometric case is an explicit edge case in the teaching but has no worked example showing how to recognize and solve it. Reason: The r=1 case is a stated edge case that is rarely tested; an example is optional.
- `lesson-arithmetic-number-sense-sequences-and-series|L18|2` (L18): The divergent infinite-geometric case is an explicit edge case, but every infinite-series example uses a convergent ratio, leaving this case unworked. Reason: The divergent case is stated in Core Concept and again in Trap 3; a separate example is optional.
- `lesson-arithmetic-number-sense-sequences-and-series|L26|0` (L26): The lesson states the convergence condition and then gives a sum formula, but it never explains what convergence means or how an infinite sequence of partial sums can approach a finite value. Reason: Same gap as the converges finding; one plain explanation fixes both.

## Figures

None.

## Rules cited

| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
