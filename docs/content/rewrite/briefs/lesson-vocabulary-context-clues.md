# Brief: Word Meanings through Context Clues

Lesson id: `lesson-vocabulary-context-clues`
Lesson path: `content/lessons/language-proficiency/vocabulary/context-clues.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-vocabulary-context-clues|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> The phrase "or official command" directly restates *edict*. The best answer is **C**.
- Problem: The worked solution is unnumbered prose instead of the required numbered-step format; the same formatting issue appears in all five solutions.
- Triage reason: Five solutions are unnumbered prose instead of numbered steps.

### 2. `lesson-vocabulary-context-clues|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Similar spelling can reflect real etymological relationships or pure coincidence.
- Problem: The terms "etymological relationships" and "pure coincidence" are much harder than the Grade 5 teaching-prose target and are not simplified or explained.
- Triage reason: Etymological relationships and pure coincidence are above Grade 5; simplify.

### 3. `lesson-vocabulary-context-clues|L02|1`
- Rule: L02
- Fix size: small
- Quote:
> If two choices remain plausible, use finer clues such as collocation, connotation, register, and the grammatical role of the word.
- Problem: This sentence stacks several advanced language terms in one instruction, making the teaching prose too difficult for the required Grade 5 reading level.
- Triage reason: Collocation, connotation and register are stacked without explanation; simplify.

### 4. `lesson-vocabulary-context-clues|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> The king's **edict**, or official command, required all citizens to pay the tax.
- Problem: The example gives a sentence and answer choices but no exam-style question or instruction asking what the target word means; the same prompt omission occurs in all five examples.
- Triage reason: The example stems have no question; add one asking what the word means.

### 5. `lesson-vocabulary-context-clues|L14|0`
- Rule: L14
- Fix size: small
- Quote:
> The forest contains many *nocturnal* animals, such as owls, bats, and flying foxes, that are active after dark.
- Problem: The target word nocturnal is italicized instead of bold, so it breaks the required target-word emphasis.
- Triage reason: Nocturnal is italic, not bold, as target words must be.

### 6. `lesson-vocabulary-context-clues|L14|1`
- Rule: L14
- Fix size: small
- Quote:
> The king's **edict**, or official command, required all citizens to pay the tax.
- Problem: The example has a bold target word but no prompt saying "the word in bold"; the same missing prompt occurs across the examples.
- Triage reason: Examples give a bold word but no prompt saying the word in bold.

### 7. `lesson-vocabulary-context-clues|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> If two choices remain plausible, use finer clues such as collocation, connotation, register, and the grammatical role of the word.
- Problem: Collocation, connotation, register, and grammatical role are introduced as tools students should use, but none is explained before that advice depends on them.
- Triage reason: Collocation, connotation and register are advice terms never explained; explain simply.

### 8. `lesson-vocabulary-context-clues|L26|0`
- Rule: L26
- Fix size: small
- Quote:
> use finer clues such as collocation, connotation, register, and the grammatical role of the word.
- Problem: These finer-clue concepts are only named. The lesson does not explain what each one means or how it helps distinguish between plausible word senses.
- Triage reason: The finer-clue terms are only named; give short plain meanings.

## CSE teaching to add

### 1. `language-proficiency-vocabulary#28`
- Facet: Register as a finer meaning clue
- Verdict: named-only
- Tier: curriculum
- Missing ideas:
  - Register not defined or worked; precise exam scope unknown.

## Optional, fix only if editing that passage anyway

- `lesson-vocabulary-context-clues|L18|0` (L18): Synonym or near-synonym clues are taught as a distinct clue type, but there is no worked example devoted to recognizing or using that scenario. Reason: Synonym clue is close to the restatement example; a separate example adds little.
- `lesson-vocabulary-context-clues|L18|1` (L18): The learning goal includes checking a candidate against grammar and context, but no worked example explicitly demonstrates the substitution-and-grammar check. Reason: Plug-back-in is a check that a solution step can show; a dedicated example is not required.
- `lesson-vocabulary-context-clues|L18|2` (L18): The lesson names the important edge case where two meanings remain plausible, but provides no worked example that resolves such ambiguity with finer clues. Reason: Better fixed by plain wording and a short explanation than a new example.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L14 | Target words are bold and the prompt says "the word in bold" | Major | Check prompts that refer to a word | LSG: Emphasis and de-AI rules |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
