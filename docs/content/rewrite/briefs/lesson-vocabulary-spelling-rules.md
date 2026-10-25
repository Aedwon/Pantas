# Brief: Spelling Rules

Lesson id: `lesson-vocabulary-spelling-rules`
Lesson path: `content/lessons/language-proficiency/vocabulary/spelling-rules.md`

Tagged exams: cse-subprofessional, upcat

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-vocabulary-spelling-rules|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> **C**. The standard spelling is **truly**. The other three show why simple suffix rules have exceptions and spelling-preservation patterns.
- Problem: The suffix section teaches dropping silent e, retaining e, and lexical exceptions as distinct cases, but this worked example directly solves only truly; managing and noticeable remain unworked distractors, so the distinct suffix cases do not each get a worked example.
- Triage reason: Silent-e dropping and retaining are taught but only truly is worked; add an example.

### 2. `lesson-vocabulary-spelling-rules|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> For many one-syllable words and stressed final syllables ending in a single consonant after a single vowel, the final consonant doubles before certain vowel-initial suffixes: *run → running, begin → beginning*.
- Problem: This sentence is too long and jargon-heavy for the Grade 5 teaching-prose standard, especially the unexplained phrases "stressed final syllables" and "vowel-initial suffixes".
- Triage reason: Stressed final syllables and vowel-initial suffixes are jargon in one long sentence; simplify.

### 3. `lesson-vocabulary-spelling-rules|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> **B** is misspelled; the standard spelling is **conceive**. Notice that *seize* is also standard even though it does not follow the familiar mnemonic. This is why the rhyme is a memory aid, not a universal rule.
- Problem: The worked solution is prose rather than a numbered list of solution steps. No display equation is needed for this spelling item, but the required numbered-step format is still missing.
- Triage reason: Solution is prose, not numbered steps.

### 4. `lesson-vocabulary-spelling-rules|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Spelling is partly regular and partly lexical: patterns can help, but many words must also be learned individually.
- Problem: The necessary term "lexical" is used immediately as part of the core explanation but is never defined or restated in simple language.
- Triage reason: Lexical is used without meaning; say some words must be learned one by one.

### 5. `lesson-vocabulary-spelling-rules|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> The exact pattern depends on stress, spelling, and suffix; it is not merely "CVC always doubles."
- Problem: The abbreviation "CVC" is needed to understand the stated limitation and later trap, but the lesson never explains that it means consonant-vowel-consonant.
- Triage reason: CVC is never explained; spell out consonant-vowel-consonant.

### 6. `lesson-vocabulary-spelling-rules|L25|2`
- Rule: L25
- Fix size: small
- Quote:
> **Look at the whole morphological family.** *Begin/beginning* and *refer/referred* can help you see stress/doubling patterns, but remember that families can also contain irregularities.
- Problem: The term "morphological family" is presented as a shortcut students should use, but its meaning is not explained before the student is expected to use it.
- Triage reason: Morphological family is a shortcut term never explained; use plain words.

## CSE teaching to add

### 1. `language-proficiency-vocabulary#77`
- Facet: Multisyllabic phonics and syllable-based spelling
- Verdict: thin
- Tier: curriculum
- Missing ideas:
  - Stress is named, but no syllable division, sound-letter mapping or multisyllabic phonics procedure.

## Optional, fix only if editing that passage anyway

- `lesson-vocabulary-spelling-rules|L03|0` (L03): The exam verb "Choose" first appears here without the required one-line explanation of what the student should do. Reason: Choose is a plain instruction word, not an exam verb needing a gloss.

## Figures

None.

## Rules cited

| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L03 | Exam instruction words with an exam-specific meaning are explained in one line on first use; everyday words are not | Minor | Find the first use of each such word | LSG: Voice |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
