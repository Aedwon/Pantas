# Brief: Number and Letter Sequences

Lesson id: `lesson-logical-verbal-reasoning-number-and-letter-sequences`
Lesson path: `content/lessons/reasoning/logical-verbal-reasoning/number-and-letter-sequences.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-logical-verbal-reasoning-number-and-letter-sequences|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> Find the intended next letter: $B,D,G,K,\ldots$
- Problem: The worked examples cover arithmetic, geometric, changing-difference, and alphabet-position patterns, but omit distinct numerical cases taught in Core Concept: interleaved odd/even rules, alternating operations, and recurrence patterns.
- Triage reason: Interleaved and recurrence patterns are taught but have no worked example.

### 2. `lesson-logical-verbal-reasoning-number-and-letter-sequences|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> All shown consecutive differences are $+5$, so the simple arithmetic continuation gives **24**.
- Problem: The answer number 24 appears in prose as bold text instead of inline math, violating the rule that numbers in prose must be inside $...$.
- Triage reason: Bold answer number 24 sits outside inline math.

### 3. `lesson-logical-verbal-reasoning-number-and-letter-sequences|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> The differences are $1,2,3,4$. Continuing that simple difference pattern with $+5$ gives **17**.
- Problem: The answer number 17 appears in prose as bold text instead of inline math, so the number is not wrapped in $...$.
- Triage reason: Bold answer number 17 sits outside inline math.

### 4. `lesson-logical-verbal-reasoning-number-and-letter-sequences|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> 4. Letter 16 is **P**.
- Problem: The number 16 appears in prose outside inline math; it should be written inside $...$ under the lesson math-notation rule.
- Triage reason: Number 16 in "Letter 16" sits outside inline math.

### 5. `lesson-logical-verbal-reasoning-number-and-letter-sequences|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A finite list does **not** mathematically determine one unique continuation.
- Problem: This sentence uses abstract terms such as “finite,” “mathematically determine,” and “unique continuation,” making the teaching prose harder than the required Grade 5 level.
- Triage reason: "Finite", "mathematically determine" and "unique continuation" are above Grade 5.

### 6. `lesson-logical-verbal-reasoning-number-and-letter-sequences|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> All shown consecutive differences are $+5$, so the simple arithmetic continuation gives **24**.
- Problem: Example #1 gives the whole solution as prose instead of numbered steps and provides no display equation for the key computation.
- Triage reason: Example 1 is a bare sentence with no steps or display equation.

### 7. `lesson-logical-verbal-reasoning-number-and-letter-sequences|L19|2`
- Rule: L19
- Fix size: small
- Quote:
> The differences are $1,2,3,4$. Continuing that simple difference pattern with $+5$ gives **17**.
- Problem: Example #3 gives the reasoning in prose instead of numbered steps and has no display equation for the key computation.
- Triage reason: Example 3 has no steps or display equation for the differences.

### 8. `lesson-logical-verbal-reasoning-number-and-letter-sequences|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> - **Recurrence:** later terms depend on earlier terms, as in the Fibonacci sequence.
- Problem: The lesson names Fibonacci as the recurrence example but never explains its sum-of-the-two-previous-terms rule, so this concept is named without showing how it works.
- Triage reason: Fibonacci is named but its add-the-last-two rule is never stated.

## CSE teaching to add

### 1. `reasoning-logical-verbal-reasoning#4`
- Facet: Interleaved odd/even subsequences
- Verdict: thin
- Tier: official
- Missing ideas:
  - A fuller decision/representation explanation beyond the local illustration.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 2. `reasoning-logical-verbal-reasoning#5`
- Facet: Alternating operations
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure for applying this named family/form.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 3. `reasoning-logical-verbal-reasoning#6`
- Facet: Earlier-term recurrence patterns
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure for applying this named family/form.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 4. `reasoning-logical-verbal-reasoning#7`
- Facet: Fibonacci pattern
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure for applying this named family/form.
  - A reasoned relation/form application, or a discriminating decision where applicable.

## Optional, fix only if editing that passage anyway

- `lesson-logical-verbal-reasoning-number-and-letter-sequences|L17|0` (L17): This content is placed in a Speed Tricks & Shortcuts section, but the subject-fit rule for Reasoning requires the reduced Core Concept → Examples → Traps layout and says to drop Speed Tricks. Reason: Approved ruling (Oct 25): keep Speed Tricks only if it holds a real shortcut.
- `lesson-logical-verbal-reasoning-number-and-letter-sequences|L19|1` (L19): Example #2 has a display equation, but the solution is not presented as a numbered step list as required. Reason: One-step solution already has a display equation; a numbered list adds nothing.
- `lesson-logical-verbal-reasoning-number-and-letter-sequences|L19|3` (L19): Example #4 uses numbered steps, but its key conversions and difference computations remain inline instead of being shown as display equations. Reason: Short inline steps are readable; display equations are optional here.
- `lesson-logical-verbal-reasoning-number-and-letter-sequences|L25|0` (L25): The term “ratio” is needed to understand the geometric pattern, but it is used without being explained, and there is no prerequisite lesson supplying that meaning. Reason: Ratio is common enough, and the example shows multiplying by $3$.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
