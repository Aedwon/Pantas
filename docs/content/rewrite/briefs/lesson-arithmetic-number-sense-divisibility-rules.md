# Brief: Divisibility Rules

Lesson id: `lesson-arithmetic-number-sense-divisibility-rules`
Lesson path: `content/lessons/mathematics/arithmetic-number-sense/divisibility-rules.md`

Tagged exams: cse-subprofessional, upcat

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-arithmetic-number-sense-divisibility-rules|L17|0`
- Rule: L17
- Fix size: medium
- Quote:
> * **Rule for $9$:** If the sum of the digits is divisible by $9$, the whole number is divisible by $9$.
- Problem: A rule used in the worked examples is taught in Mnemonics & Memory Aids instead of Core Concept. For mathematics, the substantive rule should be introduced in Core Concept before an example relies on it.
- Triage reason: The tests for 2 to 11 sit only in Mnemonics, while Core Concept has just the definition; move them to Core Concept.

### 2. `lesson-arithmetic-number-sense-divisibility-rules|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> When checking divisibility by $3$ or $9$, you can ignore any group of digits whose sum is a multiple of $9$ because removing such a group does not change the digit sum modulo $9$.
- Problem: This sentence is long and introduces the unexplained technical word "modulo," making the teaching prose harder than the required Grade 5 level.
- Triage reason: The cast-out-nines sentence is long and uses modulo, which a Grade 5 student does not know.

### 3. `lesson-arithmetic-number-sense-divisibility-rules|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> Only $1$ remains, so the original digit sum is congruent to $1$ modulo $9$ and the number is divisible by neither $3$ nor $9$.
- Problem: The unexplained terms "congruent" and "modulo" make this explanation unnecessarily technical for the required simple teaching voice.
- Triage reason: Congruent and modulo are unexplained jargon; say the remainder is 1 when divided by 9.

### 4. `lesson-arithmetic-number-sense-divisibility-rules|L17|1`
- Rule: L17
- Fix size: small
- Quote:
> 1. Since $72 = 8 \times 9$ and $8$ and $9$ are relatively prime, the number must be divisible by both $8$ and $9$.
- Problem: Example #4 uses the relatively-prime product split before the lesson teaches that split; the fuller rule appears only later under Speed Tricks & Shortcuts, not in Core Concept.
- Triage reason: The relatively prime split is used in Example 4 but taught only later in Speed Tricks.

### 5. `lesson-arithmetic-number-sense-divisibility-rules|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> 1. Since $72 = 8 \times 9$ and $8$ and $9$ are relatively prime, the number must be divisible by both $8$ and $9$.
- Problem: The term "relatively prime" is needed to understand why the combined test is valid, but it is used before being explained and is never actually defined in the lesson.
- Triage reason: Relatively prime is used before it is defined.

### 6. `lesson-arithmetic-number-sense-divisibility-rules|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> Only $1$ remains, so the original digit sum is congruent to $1$ modulo $9$ and the number is divisible by neither $3$ nor $9$.
- Problem: The terms "congruent" and "modulo" are necessary to understand this shortcut explanation, but neither term is defined before or at this use.
- Triage reason: Same gap as the L02 finding: congruent and modulo are not defined.

## CSE teaching to add

### 1. `mathematics-arithmetic-number-sense#20` [weak tier: add only if it fits]
- Facet: Coprime composite-divisor tests
- Verdict: thin
- Tier: weak
- Missing ideas:
  - Develop Coprime composite-divisor tests or its distinct application before complete local facet teaching is claimed.

## Optional, fix only if editing that passage anyway

- `lesson-arithmetic-number-sense-divisibility-rules|L18|0` (L18): The lesson teaches last-digit divisibility tests, but the Examples section gives no worked scenario for divisibility by $5$ or $10$; coverage of this distinct exam-relevant case is therefore incomplete. Reason: The rules for 5 and 10 are trivial last-digit checks and an example would add little.
- `lesson-arithmetic-number-sense-divisibility-rules|L19|0` (L19): Example #2 puts key computations in bullet points with inline math. The solution-format rule requires key computations to appear as display equations within the numbered solution steps. Reason: Digit sums in a short list are readable and match the multiple-choice layout.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
