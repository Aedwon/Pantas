# Brief: Distinguishing Fact, Opinion, and Projection

Lesson id: `lesson-comprehension-skills-fact-vs-opinion`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/fact-vs-opinion.md`

Tagged exams: acet, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet, cse-professional, cse-subprofessional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-fact-vs-opinion|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A claim can be factual in type but poorly supported or false.
- Problem: This learning-goal distinction is only stated in the shortcut section. No worked example makes the student classify a false or poorly supported factual-type claim without confusing support with claim type.
- Triage reason: The point that a factual claim can be false is stated but never classified in an example.

### 2. `lesson-comprehension-skills-fact-vs-opinion|B02|0`
- Rule: B02
- Fix size: small
- Quote:
> Treat it as an opinion unless the text supplies measurable criteria and evidence for a narrower factual claim.
- Problem: Lack of evidence does not by itself turn an empirical comparative claim into an opinion. The sentence is underspecified, but evidential support and claim type must remain separate.
- Triage reason: A claim is a fact or an opinion by its type, not by whether evidence is given; the lesson mixes the two.

### 3. `lesson-comprehension-skills-fact-vs-opinion|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> - **Fact about a projection:** "The agency projects a population of 10 million by 2030." This can be verified by checking the agency's published projection.
- Problem: The prose numerals 10 and 2030 are written outside inline math delimiters.
- Triage reason: The numbers 10 and 2030 in the quoted statement are outside inline math.

### 4. `lesson-comprehension-skills-fact-vs-opinion|B08|1`
- Rule: B08
- Fix size: small
- Quote:
> - **Projection itself:** "The population will be 10 million in 2030." This concerns an uncertain future outcome and depends on assumptions.
- Problem: The prose numerals 10 and 2030 are not wrapped in inline math.
- Triage reason: The numbers 10 and 2030 in the quoted statement are outside inline math.

### 5. `lesson-comprehension-skills-fact-vs-opinion|B08|2`
- Rule: B08
- Fix size: small
- Quote:
> - **Opinion:** "A population of 10 million would be disastrous." This is an evaluative judgment unless the relevant standard of "disastrous" is defined and defended.
- Problem: The prose numeral 10 appears outside the required inline math delimiters.
- Triage reason: The numbers 10 in the quoted statement are outside inline math.

### 6. `lesson-comprehension-skills-fact-vs-opinion|B08|3`
- Rule: B08
- Fix size: small
- Quote:
> (a) "The Philippines has more than 7,000 islands."
- Problem: The prose number 7,000 is not enclosed in inline math delimiters.
- Triage reason: The numbers 7,000 in the quoted statement are outside inline math.

### 7. `lesson-comprehension-skills-fact-vs-opinion|B08|4`
- Rule: B08
- Fix size: small
- Quote:
> "The new stadium cost ₱2 billion to build and is an unnecessary waste of public money."
- Problem: The prose numeral 2 is outside inline math even though every number in prose must use dollar delimiters.
- Triage reason: The numbers the 2 in the cost in the quoted statement are outside inline math.

### 8. `lesson-comprehension-skills-fact-vs-opinion|B08|5`
- Rule: B08
- Fix size: small
- Quote:
> "Based on current assumptions, the population is projected to reach 10 million by 2030."
- Problem: The prose numerals 10 and 2030 are written outside inline math.
- Triage reason: The numbers 10 and 2030 in the quoted statement are outside inline math.

### 9. `lesson-comprehension-skills-fact-vs-opinion|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A **factual claim** is a claim whose truth or falsity can in principle be checked against evidence, measurement, records, or observation.
- Problem: This definition uses abstract phrasing such as "truth or falsity" and "in principle" instead of the very simple Grade 5 English required for teaching prose.
- Triage reason: Truth or falsity and in principle are abstract; say a claim you can check as true or false.

### 10. `lesson-comprehension-skills-fact-vs-opinion|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> It is a model-based statement about a possible or expected future outcome under stated or implicit assumptions.
- Problem: Terms such as "model-based," "outcome," and "implicit assumptions" make this core definition substantially harder than the required Grade 5 teaching voice.
- Triage reason: Model-based, outcome and implicit assumptions are hard words for a Grade 5 reader.

### 11. `lesson-comprehension-skills-fact-vs-opinion|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> (a) "The Philippines has more than 7,000 islands."
- Problem: The worked example presents statements but never gives an exam-style question or instruction telling the student what to identify, so the task is only inferred from the heading.
- Triage reason: Examples 1 to 4 show statements without a question telling the student what to decide.

### 12. `lesson-comprehension-skills-fact-vs-opinion|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> It is a model-based statement about a possible or expected future outcome under stated or implicit assumptions.
- Problem: The definition relies on the technical ideas "model-based" and "assumptions" before explaining what a model or an assumption means, and there is no prerequisite lesson to supply those meanings.
- Triage reason: Assumptions and model are used without meaning; one plain line saying a guess about the future fixes it.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-comprehension-skills-fact-vs-opinion|B08|6` (B08): The prose numeral 2030 is not wrapped in inline math delimiters. Reason: 2030 is a year, not a quantity; wrapping it in math adds nothing for a student.
- `lesson-comprehension-skills-fact-vs-opinion|L01|0` (L01): The recorded goal requires separating claim type from truth or evidential support, but this example makes evidence a condition for treating the claim as factual-type. Reason: No goals are recorded, so the learning-goal check is not applied.
- `lesson-comprehension-skills-fact-vs-opinion|L18|1` (L18): This distinct projection case appears in a trap, but the worked examples cover only the projection itself and never work a factual claim about a published projection. Reason: Example 4 already says the existence of the projection can be factual; extra example optional.
- `lesson-comprehension-skills-fact-vs-opinion|L19|1` (L19): This worked answer is written as an unnumbered paragraph rather than numbered solution steps. Reason: Example 2 is one decision with short reasoning; numbering is optional.
- `lesson-comprehension-skills-fact-vs-opinion|L19|2` (L19): This worked answer is not presented as a numbered list of solution steps. Reason: Example 3 classifies two parts in one sentence; numbering is optional.

## Figures

None.

## Rules cited

| B02 | Every worked answer, example answer, and key is correct | Blocker | Solve it yourself from the question alone | LSG: Examples section; QSG: Blind solve |
| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
