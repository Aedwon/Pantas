# Brief: Basic Probability (Independent vs. Dependent Events, Mutually Exclusive Events)

Lesson id: `lesson-statistics-and-probability-basic-probability`
Lesson path: `content/lessons/mathematics/statistics-and-probability/basic-probability.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-statistics-and-probability-basic-probability|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> summary: "How to compute probabilities for single and combined events, with and without replacement."
- Problem: The lesson promises both replacement cases, but every sequential-sampling worked example is without replacement. There is no worked with-replacement case showing the reset of counts and resulting probability choice.
- Triage reason: The summary promises with-replacement cases but every sequential example is without replacement.

### 2. `lesson-statistics-and-probability-basic-probability|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> For any events $A$ and $B$ with the needed conditional probability defined:
- Problem: This sentence uses abstract wording and the unexplained technical phrase "conditional probability defined," which is not simple Grade 5 teaching prose.
- Triage reason: "Needed conditional probability defined" is abstract; use plain words.

### 3. `lesson-statistics-and-probability-basic-probability|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> $$P(A\text{ and }B)=P(A)\,P(B\mid A)$$
- Problem: The notation for conditional probability is used before the lesson explains what $P(B\mid A)$ means or how the condition after the bar should be read.
- Triage reason: P(B|A) is used before saying it reads as the probability of B given A.

### 4. `lesson-statistics-and-probability-basic-probability|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> The $36$ ordered pairs are equally likely.
- Problem: The solution asserts the 36-outcome sample space without explaining how two six-face dice produce 6 times 6 ordered outcomes or what the order represents.
- Triage reason: The 36 ordered pairs are asserted without showing six outcomes for each die times six.

### 5. `lesson-statistics-and-probability-basic-probability|L27|0`
- Rule: L27
- Fix size: small
- Quote:
> summary: "How to compute probabilities for single and combined events, with and without replacement."
- Problem: The lesson explains how no replacement changes the second draw, but never explains the contrasting with-replacement condition, where the item is returned and the original counts are restored.
- Triage reason: With replacement is never explained, so students cannot tell when the counts stay the same.

## CSE teaching to add

### 1. `mathematics-statistics-and-probability#1` [weak tier: add only if it fits]
- Facet: Ordered two-dice sample-space probabilities
- Verdict: thin
- Tier: weak
- Missing ideas:
  - The36 ordered pairs are asserted; the outcome-pair count is not developed. Conditional-probability rules remain separate from this count model.

### 2. `mathematics-statistics-and-probability#8` [weak tier: add only if it fits]
- Facet: Sampling with replacement
- Verdict: thin
- Tier: weak
- Missing ideas:
  - No explicit reset-of-counts replacement-sampling explanation/application; coin/die independence is another model.

## Optional, fix only if editing that passage anyway

- `lesson-statistics-and-probability-basic-probability|L19|0` (L19): Example 3 gives its reasoning and computation without any numbered solution step, although the rule requires every solution step to be presented as a numbered list. Reason: Example 3 is a single computation after one fact; forcing a numbered list adds nothing.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
| L27 | Relevant conditions, limitations, and exceptions explain when a rule, formula, or shortcut applies | Major | Check applicability explanations under the shared reuse rule | LSG: Teaching completeness |
