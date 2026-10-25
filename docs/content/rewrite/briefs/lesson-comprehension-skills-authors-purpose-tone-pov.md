# Brief: Identifying Author's Purpose, Tone, and Point of View

Lesson id: `lesson-comprehension-skills-authors-purpose-tone-pov`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/authors-purpose-tone-pov.md`

Tagged exams: acet, cse-professional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-authors-purpose-tone-pov|L05|0`
- Rule: L05
- Fix size: medium
- Quote:
> Vote yes on Proposition 12 to protect our local parks for future generations.
- Problem: This passage is presented as the entire example prompt with no exam-style question asking the student to identify or infer the author's purpose; the same answer-without-question pattern is used throughout the Examples section.
- Triage reason: All four examples show a quote and an answer with no exam-style question, so students never see real question wording.

### 2. `lesson-comprehension-skills-authors-purpose-tone-pov|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A passage can have more than one purpose, with one more central than the others.
- Problem: Mixed purpose is explicitly taught as an exam-relevant variation, but no worked example asks the student to weigh multiple purposes and identify the dominant one.
- Triage reason: Mixed purpose is taught but has no worked example weighing a main purpose against a second one.

### 3. `lesson-comprehension-skills-authors-purpose-tone-pov|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> **First person:** a narrator uses forms such as *I* or *we* and participates in or recounts the events.
- Problem: First-person narration is part of the taught perspective set, but there is no worked first-person classification example.
- Triage reason: First person is taught but has no worked classification example.

### 4. `lesson-comprehension-skills-authors-purpose-tone-pov|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> **Second person:** the text addresses a *you* and may cast that addressee as a participant.
- Problem: Second-person narration is part of the taught perspective set, but there is no worked second-person classification example.
- Triage reason: Second person is taught but has no worked classification example.

### 5. `lesson-comprehension-skills-authors-purpose-tone-pov|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> The direct call to action makes **persuasion** the dominant purpose.
- Problem: The worked answer is given as a single prose sentence with no Solution label and no numbered reasoning steps, so the required worked-example solution format is missing.
- Triage reason: Examples give a one-line answer with no Solution label or numbered steps; the guide requires numbered steps.

### 6. `lesson-comprehension-skills-authors-purpose-tone-pov|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> It is inferred from diction, imagery, syntax, emphasis, and context.
- Problem: This sentence relies on several unexplained academic terms, especially diction and syntax, so the teaching prose is not simple enough for the stated Grade 5 reading standard.
- Triage reason: Diction and syntax are unexplained words in a Grade 5 lesson; use plain words or define them.

### 7. `lesson-comprehension-skills-authors-purpose-tone-pov|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> It is inferred from diction, imagery, syntax, emphasis, and context.
- Problem: The lesson tells students to use diction, imagery, syntax, and emphasis as tone evidence without first explaining what those terms mean, and there is no prerequisite lesson supplying those meanings.
- Triage reason: Diction, imagery, and syntax are used as tone evidence with no meaning given; add short definitions.

## CSE teaching to add

### 1. `reading-comprehension-comprehension-skills#38`
- Facet: English: cohesion, paragraph relationships and patterns of development
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Systematic referential cohesion, rhetorical paragraph functions and comparison of development patterns.

### 2. `reading-comprehension-comprehension-skills#40`
- Facet: Reading: author's argumentative viewpoint distinct from narrative perspective
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Infer sustained argument position from evidence, evaluate fairness or compare perspectives.

### 3. `reading-comprehension-comprehension-skills#41`
- Facet: Critical reading: identify and explain bias
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Selection/framing/omission bias, separating viewpoint from distorted evidence and bias diagnosis.

### 4. `reading-comprehension-comprehension-skills#54`
- Facet: Grammar: wider sentence/rule families beyond locally used tense
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Voice/reported speech, agreement, parallelism, modals, modification, conditionals and general sentence construction.

## Optional, fix only if editing that passage anyway

- `lesson-comprehension-skills-authors-purpose-tone-pov|B08|0` (B08): The numeral 12 appears in prose outside inline math delimiters, which breaks the form's rule that numbers in prose must be written inside `$...$`. Reason: The number is part of a proper name inside a quoted sample; wrapping it in math adds little.
- `lesson-comprehension-skills-authors-purpose-tone-pov|L18|3` (L18): The only tone example is a short passage with uniformly negative cues, so the examples do not ramp to a sustained target-exam passage where several or competing tone cues must be weighed. Reason: A longer tone passage with competing cues would help, but the lesson already marks one-word evidence as a risk.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
