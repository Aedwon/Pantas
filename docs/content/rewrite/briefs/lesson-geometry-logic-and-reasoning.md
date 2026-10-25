# Brief: Logic and Reasoning (Conditional Statements, Converses, Inverses, Contrapositives)

Lesson id: `lesson-geometry-logic-and-reasoning`
Lesson path: `content/lessons/mathematics/geometry/logic-and-reasoning.md`

Tagged exams: acet, cse-professional, dcat, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-geometry-logic-and-reasoning|L17|0`
- Rule: L17
- Fix size: medium
- Quote:
> This chain is called the **Law of Syllogism**: if $p$ leads to $q$ and $q$ leads to $r$, then $p$ leads to $r$.
- Problem: The $p$ to $q$, $q$ to $r$, therefore $p$ to $r$ chaining formula is introduced for the first time inside Example 5. Mathematics formulas and formal patterns used in examples must first appear in Core Concept.
- Triage reason: The Law of Syllogism is first stated in Example 5; teach this chaining pattern in Core Concept before use.

### 2. `lesson-geometry-logic-and-reasoning|B01|0`
- Rule: B01
- Fix size: small
- Quote:
> Using one true statement plus a matching fact is the **Law of Detachment**.
- Problem: This is too broad. The Law of Detachment specifically requires a true conditional $p$ implies $q$ together with its true hypothesis $p$, which permits conclusion $q$. Any true statement plus a vaguely "matching" fact is not sufficient. OpenStax states the required conditional-and-hypothesis structure: https://openstax.org/books/contemporary-mathematics/pages/2-7-logical-arguments
- Triage reason: Law of Detachment needs a true conditional plus its true hypothesis; the lesson states it too loosely.

### 3. `lesson-geometry-logic-and-reasoning|B02|0`
- Rule: B02
- Fix size: small
- Quote:
> A janitor mops the floor. The ground is wet, but it is not raining.
- Problem: The proposed counterexample changes the relevant object from the ground to a floor. Mopping a floor does not establish that the hypothesis "the ground is wet" is true, so the counterexample is not valid as written.
- Triage reason: Counterexample mops a floor but the claim is about the ground; the example does not work.

### 4. `lesson-geometry-logic-and-reasoning|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Here is the most important fact in this lesson.
- Problem: This sentence is filler rather than teaching content. The voice rule says every sentence should teach something and specifically requires no filler.
- Triage reason: "Here is the most important fact in this lesson" is filler that teaches nothing; cut it.

### 5. `lesson-geometry-logic-and-reasoning|L04|0`
- Rule: L04
- Fix size: small
- Quote:
> Chain the conditionals like dominoes.
- Problem: This is an analogy inside the Examples section. The rule allows at most one analogy and requires any analogy to appear in Core Concept.
- Triage reason: The dominoes analogy sits in Examples; the guide allows at most one analogy and only in Core Concept.

### 6. `lesson-geometry-logic-and-reasoning|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> Using one true statement plus a matching fact is the **Law of Detachment**.
- Problem: The required conditions are not stated precisely. Detachment applies when a conditional $p$ implies $q$ is true and its hypothesis $p$ is true; the phrase "one true statement plus a matching fact" does not tell students when the rule actually applies.
- Triage reason: "One true statement plus a matching fact" does not state the actual condition: the conditional is true and its hypothesis is true.

## CSE teaching to add

### 1. `mathematics-geometry#29` [weak tier: add only if it fits]
- Facet: Biconditional meaning
- Verdict: thin
- Tier: weak
- Missing ideas:
  - No biconditional construction or two-direction proof example.

### 2. `mathematics-geometry#30` [weak tier: add only if it fits]
- Facet: Hypothetical syllogism and detachment
- Verdict: thin
- Tier: weak
- Missing ideas:
  - Chaining/detachment is introduced in the example; general core does not prepare these methods.

## Optional, fix only if editing that passage anyway

- `lesson-geometry-logic-and-reasoning|L03|0` (L03): The exam verb "Identify" appears as an instruction without the required one-line explanation of what the student should do. Reason: "Identify" is plain, and the solution immediately shows what to do.
- `lesson-geometry-logic-and-reasoning|L19|0` (L19): These are solution reasoning steps placed before the numbered list. The rule requires every solution step to be presented as part of the numbered solution list. Reason: The lead-in line before the steps is a hint, not a skipped step; no real defect.

## Figures

None.

## Rules cited

| B01 | Every fact is correct; an unconfirmed fact is left out | Blocker | Check each hard-to-remember fact against a source | SP: What needs a source |
| B02 | Every worked answer, example answer, and key is correct | Blocker | Solve it yourself from the question alone | LSG: Examples section; QSG: Blind solve |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L04 | At most one analogy, in Core Concept | Minor | Count analogies | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
