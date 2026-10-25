# Brief: Sentence Completion / Fill-in-the-Blanks

Lesson id: `lesson-language-application-sentence-completion`
Lesson path: `content/lessons/language-proficiency/language-application/sentence-completion.md`

Tagged exams: cse-professional, cse-subprofessional, sm-foundation

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-language-application-sentence-completion|L18|1`
- Rule: L18
- Fix size: medium
- Quote:
> **Collocation and idiom.** Some words naturally occur together: *strong evidence*, *make a decision*, *interested in*.
- Problem: Collocation and idiom are part of the lesson's completion method and learning goal, but no worked example requires choosing or eliminating an answer by word combination.
- Triage reason: Collocation is a taught clue with no worked example; add one example.

### 2. `lesson-language-application-sentence-completion|L18|2`
- Rule: L18
- Fix size: medium
- Quote:
> Agreement, tense/aspect, complementation, articles, prepositions, and parallel structure can eliminate choices.
- Problem: The examples give only one narrow finite-verb grammar case; they do not work the other distinct grammar eliminators the lesson names, such as articles, prepositions, or parallel structure.
- Triage reason: Only a verb-form case is worked; articles, prepositions or parallel structure need an example.

### 3. `lesson-language-application-sentence-completion|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> Agreement, tense/aspect, complementation, articles, prepositions, and parallel structure can eliminate choices.
- Problem: The lesson names these grammar concepts but does not explain how each one works or how a student would use it to judge a completion.
- Triage reason: The lesson lists grammar checks but does not explain how each works.

### 4. `lesson-language-application-sentence-completion|B02|0`
- Rule: B02
- Fix size: small
- Quote:
> (A) careless, confident (B) thorough, nervous (C) thorough, confident (D) minimal, nervous
- Problem: The keyed answer B is not unique. A is also grammatical and gives a coherent despite-contrast: careless preparation would normally reduce confidence, yet she felt confident.
- Triage reason: Choice A also gives a coherent despite-contrast; the key is not unique. Change a choice.

### 5. `lesson-language-application-sentence-completion|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> Agreement, tense/aspect, complementation, articles, prepositions, and parallel structure can eliminate choices.
- Problem: This sentence stacks several uncommon grammar terms without simple wording, making the teaching prose harder than the Grade 5 reading standard.
- Triage reason: Agreement, tense, complementation and similar terms are stacked unexplained; use plain wording.

### 6. `lesson-language-application-sentence-completion|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> In this standalone sentence, **approved** produces the natural reading of one completed review-and-decision event and supplies a finite verb.
- Problem: The solution uses abstract phrases such as standalone sentence, natural reading, review-and-decision event, and finite verb instead of the required simple teaching language.
- Triage reason: Standalone sentence, natural reading and finite verb are jargon in a solution; simplify.

### 7. `lesson-language-application-sentence-completion|L19|0`
- Rule: L19
- Fix size: small
- Quote:
> *Although* sets up a contrast between the bad forecast and the outcome. **Successful** provides that contrast and fits grammatically.
- Problem: The worked solutions are written as unnumbered prose rather than numbered solution steps. No reasoning step is clearly skipped, but the required solution format is not followed.
- Triage reason: Solutions are unnumbered prose instead of numbered steps.

### 8. `lesson-language-application-sentence-completion|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> Agreement, tense/aspect, complementation, articles, prepositions, and parallel structure can eliminate choices.
- Problem: Several necessary grammar terms are introduced as names only, without explaining their meanings before students are expected to use them to eliminate choices.
- Triage reason: Grammar terms are named but never explained before students use them.

### 9. `lesson-language-application-sentence-completion|L25|1`
- Rule: L25
- Fix size: small
- Quote:
> and supplies a finite verb.
- Problem: Finite verb is used to justify the answer in Example 4 without being defined earlier in this lesson, and there is no prerequisite lesson supplying that meaning.
- Triage reason: Finite verb is used in the solution without a meaning; define it or drop it.

## CSE teaching to add

### 1. `language-proficiency-language-application#49` [FILIPINO SECTION]
- Facet: Filipino: sentence completion
- Verdict: absent
- Tier: official
- Missing ideas:
  - Filipino contextual meaning, grammar and natural combinations in completion.

## Optional, fix only if editing that passage anyway

- `lesson-language-application-sentence-completion|L02|1` (L02): Words such as discourse relations, nuanced, and versus make this warning unnecessarily difficult for the required Grade 5 teaching level. Reason: Slightly abstract wording; a plainer sentence helps but this is a minor readability point.
- `lesson-language-application-sentence-completion|L18|0` (L18): The worked examples cover contrast and cause, but none works a result or illustration relation, so the taught discourse-relation cases are not fully covered. Reason: Example 2 already works a cause and result link; illustration adds little for exam value.

## Figures

None.

## Rules cited

| B02 | Every worked answer, example answer, and key is correct | Blocker | Solve it yourself from the question alone | LSG: Examples section; QSG: Blind solve |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
