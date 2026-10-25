# Brief: Confusing Words (Affect vs. Effect, Its vs. It's, Nang vs. Ng, Sila vs. Sina)

Lesson id: `lesson-vocabulary-confusing-words`
Lesson path: `content/lessons/language-proficiency/vocabulary/confusing-words.md`

Tagged exams: cse-professional, cse-subprofessional, upcat

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-vocabulary-confusing-words|L08|0`
- Rule: L08
- Fix size: medium
- Quote:
> The distinction between Filipino **ng** and **nang** cannot be reduced to one English translation. Useful school-grammar cues include:
- Problem: This section teaches Filipino grammar in English. The Filipino-language standard requires teaching prose for Filipino grammar content to be written in simple Filipino.
- Triage reason: The ng and nang section teaches Filipino grammar in English; the guide wants simple Filipino with glosses.

### 2. `lesson-vocabulary-confusing-words|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> - **ng** commonly marks a non-topic noun phrase, possession/relationship, quantities, and certain time expressions: *kumain ng mangga*, *bahay ng guro*, *alas singko ng hapon*.
- Problem: No worked example has ng as the correct choice for any of these functions. The lesson therefore lacks a positive ng decision, including the named quantity and time-expression cases.
- Triage reason: No example has ng as the correct answer; add one ng example.

### 3. `lesson-vocabulary-confusing-words|L18|4`
- Rule: L18
- Fix size: medium
- Quote:
> - **sila** is a plural personal pronoun: "Umalis sila."
- Problem: The only worked sila/sina item has sina as the correct answer. There is no worked example in which sila must be selected as the pronoun.
- Triage reason: Sila is never the correct answer in an example; add one sila item.

### 4. `lesson-vocabulary-confusing-words|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> After modal *will*, the sentence needs a base-form verb meaning "influence." **Affect** is the ordinary choice: "will severely affect."
- Problem: The worked solution is presented as an unnumbered prose paragraph instead of numbered solution steps. The same unnumbered solution pattern is used for all five examples.
- Triage reason: All five solutions are unnumbered prose instead of numbered steps.

### 5. `lesson-vocabulary-confusing-words|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> In formal edited Filipino, use **sina** when directly marking a coordinated set of personal names. Colloquial and regional speech can show other constructions, so do not describe everyday speakers as "ungrammatical" merely because they differ from the formal target variety.
- Problem: This teaching prose is well above the Grade 5 simplicity target. It relies on dense terms such as coordinated set, colloquial, regional, ungrammatical, and formal target variety in a long sentence.
- Triage reason: Coordinated set, colloquial and ungrammatical are too hard; rewrite in plain words.

### 6. `lesson-vocabulary-confusing-words|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> - **ng** commonly marks a non-topic noun phrase, possession/relationship, quantities, and certain time expressions: *kumain ng mangga*, *bahay ng guro*, *alas singko ng hapon*.
- Problem: The lesson relies on "non-topic noun phrase" as a decision cue but never explains what a topic or non-topic noun phrase means, and there is no prerequisite lesson to supply that meaning.
- Triage reason: Non-topic noun phrase is a grammar cue never explained; explain simply or replace.

### 7. `lesson-vocabulary-confusing-words|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> - **nang** commonly introduces an adverbial manner expression, can mean "when" in clauses such as *nang dumating siya*, and appears in repeated-action constructions such as *takbo nang takbo*.
- Problem: The lesson uses "adverbial manner expression" as a key cue for nang without explaining the grammar term before the worked example relies on manner.
- Triage reason: Adverbial manner expression is not explained before the example relies on it.

## CSE teaching to add

### 1. `language-proficiency-vocabulary#8`
- Facet: Ng quantities and time expressions
- Verdict: thin
- Tier: official
- Missing ideas:
  - Time phrase given; quantity function named with no corresponding number/quantity example.

### 2. `language-proficiency-vocabulary#14`
- Facet: English versus Filipino taught scope
- Verdict: thin
- Tier: official
- Missing ideas:
  - English/Filipino target examples are present. English teaching prose explains both languages; this is partial bilingual content evidence, not full Filipino instruction or Level4 voice judgment.

## Optional, fix only if editing that passage anyway

- `lesson-vocabulary-confusing-words|L14|0` (L14): The prompt explicitly refers to a bold target word but does not use the required wording "the word in bold." Reason: The prompt names a word, not a passage target; adding the word in bold wording is optional.
- `lesson-vocabulary-confusing-words|L18|0` (L18): The lesson works the less-common effect-as-verb case in Example 5, but it never gives a worked example for the distinct affect-as-noun exception introduced here. Reason: Affect as a noun is a rare psychology use; trim it or leave it rather than add an example.
- `lesson-vocabulary-confusing-words|L18|1` (L18): The worked its/it's item tests possession only. The distinct positive it-has contraction case named here is not independently worked, leaving that variation uncovered. Reason: The it has contraction is a minor variation of it is; no separate example needed.
- `lesson-vocabulary-confusing-words|L18|3` (L18): Example 3 works only the manner use. Its when-clause nang is supplied rather than solved, and no worked example covers the repeated-action construction. Reason: The when use is shown in the stem and repeated action is rare; one added line suffices.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L08 | Filipino lessons teach in simple Filipino at the Grade 5 standard | Major | Read as a Grade 5 student | LSG: Filipino-language lessons |
| L14 | Target words are bold and the prompt says "the word in bold" | Major | Check prompts that refer to a word | LSG: Emphasis and de-AI rules |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
