# Brief: Syllogisms and Deductive Logic

Lesson id: `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic`
Lesson path: `content/lessons/reasoning/logical-verbal-reasoning/syllogisms-and-deductive-logic.md`

Tagged exams: acet, cse-professional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> "All mammals are warm-blooded. A whale is a mammal. Therefore, a whale is warm-blooded."
- Problem: The worked example supplies only an argument and no exam-style question or instruction telling the student what to determine; the other worked examples use the same statement-only format.
- Triage reason: Examples give only an argument; add a question such as whether it is valid.

### 2. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> 1. If $P$, then $Q$.
> 2. $P$.
> 3. Therefore, $Q$.
- Problem: Modus ponens is taught as a distinct valid form in Core Concept but has no worked example, so the examples do not cover every taught exam-relevant form.
- Triage reason: Modus ponens is taught as a core form but has no worked example.

### 3. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> **Denying the antecedent:** If $P$ then $Q$; not $P$; therefore not $Q$.
- Problem: Denying the antecedent is taught as a distinct invalid conditional form but has no worked example, leaving a separate reversal-related case uncovered.
- Triage reason: Denying the antecedent is a taught invalid form with no worked example.

### 4. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L26|1`
- Rule: L26
- Fix size: medium
- Quote:
> **For category arguments, use set/circle relationships.** Visualizing inclusion and exclusion can make quantifier mistakes easier to spot.
- Problem: The lesson names set/circle reasoning as a method but does not explain how class inclusion or exclusion is represented or used to test a conclusion.
- Triage reason: Circle method is named but not shown; a Venn figure with one example would clearly help.

### 5. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Deduction does **not** have to move from a general statement to a more specific one. Deductive arguments can have general or particular premises and conclusions; what matters is the logical consequence relation.
- Problem: The sentence uses abstract terms such as particular premises and logical consequence relation without simple explanation, making the teaching prose too difficult for the Grade 5 reading standard.
- Triage reason: "Particular premises" and "logical consequence relation" are above Grade 5.

### 6. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> A **categorical syllogism** is a deductive argument built from categorical propositions involving classes or categories.
- Problem: The phrase categorical propositions is advanced terminology and is not restated in simple Grade 5 language.
- Triage reason: "Categorical propositions" is advanced and unexplained; say statements about groups.

### 7. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L02|2`
- Rule: L02
- Fix size: small
- Quote:
> Under the stated inclusive disjunction, this is a **disjunctive syllogism**, another valid form.
- Problem: Inclusive disjunction and disjunctive syllogism appear together in a dense sentence without a simple-language explanation.
- Triage reason: Inclusive disjunction is dense jargon; say "or" may allow both.

### 8. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> 1. If $P$, then $Q$.
> 2. $P$.
> 3. Therefore, $Q$.
- Problem: The symbols $P$ and $Q$ are used to teach conditional forms without first explaining that they stand for propositions or statements.
- Triage reason: $P$ and $Q$ are used without saying they stand for statements.

### 9. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> Under the stated inclusive disjunction, this is a **disjunctive syllogism**, another valid form.
- Problem: Inclusive disjunction is needed to understand the explanation but is not defined or reminded anywhere before this use.
- Triage reason: Inclusive disjunction is used without definition; explain "or" in the example.

### 10. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L25|2`
- Rule: L25
- Fix size: small
- Quote:
> **For category arguments, use set/circle relationships.** Visualizing inclusion and exclusion can make quantifier mistakes easier to spot.
- Problem: The term quantifier is needed to understand what mistake the shortcut targets, but the lesson never explains what a quantifier is.
- Triage reason: "Quantifier" is unexplained; reword as words like all and some.

### 11. `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> Other examples include disjunctive syllogism and valid chains of conditionals.
- Problem: Valid chains of conditionals are only named; the lesson does not explain what a conditional chain means or how the conclusion follows through the chain.
- Triage reason: Conditional chains are only named; add one line showing if P then Q, if Q then R.

## CSE teaching to add

### 1. `reasoning-logical-verbal-reasoning#14`
- Facet: Categorical class inclusion
- Verdict: thin
- Tier: official
- Missing ideas:
  - A fuller decision/representation explanation beyond the local illustration.

### 2. `reasoning-logical-verbal-reasoning#20`
- Facet: Denying the antecedent
- Verdict: thin
- Tier: official
- Missing ideas:
  - A fuller decision/representation explanation beyond the local illustration.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 3. `reasoning-logical-verbal-reasoning#22`
- Facet: Conditional chains
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure for applying this named family/form.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 4. `reasoning-logical-verbal-reasoning#23`
- Facet: Set/circle reasoning for quantified classes
- Verdict: named-only
- Tier: official
- Missing ideas:
  - A local procedure for applying this named family/form.
  - A reasoned relation/form application, or a discriminating decision where applicable.

### 5. `reasoning-logical-verbal-reasoning#50` [weak tier: add only if it fits]
- Facet: Contraposition as implication equivalence
- Verdict: thin
- Tier: weak
- Missing ideas:
  - Modus tollens inference supplied, but reverse-and-negate implication transformation/equivalence not taught.

## Optional, fix only if editing that passage anyway

- `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L17|0` (L17): This content is placed in a Speed Tricks & Shortcuts section, but the subject-fit standard for Reasoning requires the reduced Core Concept → Examples → Traps layout and says to drop Speed Tricks. Reason: Approved ruling (Oct 25): keep Speed Tricks only if it holds a real shortcut.
- `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L18|2` (L18): The final example is still a short one-step form-recognition item, so the sequence does not clearly ramp from basic practice to authentic target-exam difficulty. Reason: All examples are one-step; harder ramp would help but is a style call.
- `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|L19|0` (L19): The worked solution is a prose paragraph rather than numbered solution steps; the same unnumbered solution format is used throughout the Examples section. Reason: Verbal validity judgments read fine as short prose; numbering adds little.

## Figures

### `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|B03|0` (B03)
- Quote:
> "All mammals are warm-blooded. A whale is a mammal. Therefore, a whale is warm-blooded."
- Problem: This Reasoning example has no illustration or illustration placeholder, although the subject-fit standard requires every Reasoning example to be figure-driven.
- Triage reason: Approved ruling (Oct 25): add a Venn diagram (E6).

### `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|B03|1` (B03)
- Quote:
> "If a student studies hard, they will pass the exam. Maria passed the exam. Therefore, Maria studied hard."
- Problem: This Reasoning example has no illustration or illustration placeholder, although the subject-fit standard requires every Reasoning example to be figure-driven.
- Triage reason: Approved ruling (Oct 25): add a Venn diagram (E6).

### `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|B03|2` (B03)
- Quote:
> "If the alarm is working properly under these conditions, it will ring during a fire. It did not ring during the fire. Therefore, it was not working properly under those stated conditions."
- Problem: This Reasoning example has no illustration or illustration placeholder, although the subject-fit standard requires every Reasoning example to be figure-driven.
- Triage reason: Approved ruling (Oct 25): add a Venn diagram (E6).

### `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|B03|3` (B03)
- Quote:
> "All birds can fly. A penguin is a bird. Therefore, a penguin can fly."
- Problem: This Reasoning example has no illustration or illustration placeholder, although the subject-fit standard requires every Reasoning example to be figure-driven.
- Triage reason: Approved ruling (Oct 25): add a Venn diagram (E6).

### `lesson-logical-verbal-reasoning-syllogisms-and-deductive-logic|B03|4` (B03)
- Quote:
> "Either the document is in Cabinet A or it is in Cabinet B. It is not in Cabinet A. Therefore, it is in Cabinet B."
- Problem: This Reasoning example has no illustration or illustration placeholder, although the subject-fit standard requires every Reasoning example to be figure-driven.
- Triage reason: Approved ruling (Oct 25): add a Venn diagram (E6).

## Rules cited

| B03 | Required content is present: outline sections, required figures | Blocker | Compare with the outline entry and figure needs | LSG: Section structure, Illustration placeholders |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
