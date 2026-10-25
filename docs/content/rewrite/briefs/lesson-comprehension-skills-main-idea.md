# Brief: Identifying the Main Idea / Topic Sentence / Paksa ng Talata

Lesson id: `lesson-comprehension-skills-main-idea`
Lesson path: `content/lessons/reading-comprehension/comprehension-skills/main-idea.md`

Tagged exams: acet, cse-professional, cse-subprofessional, dcat, dost-sei, pupcet, sm-foundation, upcat, ustet

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-comprehension-skills-main-idea|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> Many expository paragraphs place it near the beginning, but there is no rule that it must be first—or that every paragraph contains one explicit topic sentence.
- Problem: The lesson teaches that a topic sentence can occur somewhere other than the beginning, but no worked example covers that distinct scenario.
- Triage reason: The lesson says a topic sentence need not come first, but no example puts it last or in the middle.

### 2. `lesson-comprehension-skills-main-idea|L19|0`
- Rule: L19
- Fix size: medium
- Quote:
> The first sentence states the central idea, and the later sentences develop examples of those benefits.
- Problem: This worked solution is presented as an unnumbered paragraph rather than as numbered solution steps, which does not follow the required worked-example solution format.
- Triage reason: Solutions are unnumbered prose; the guide requires numbered steps.

### 3. `lesson-comprehension-skills-main-idea|B08|0`
- Rule: B08
- Fix size: small
- Quote:
> "Reading fiction improves empathy" is too narrow for Example 1 because it covers only one benefit.
- Problem: The numeral in "Example 1" appears in prose outside inline math delimiters, violating the rule that numbers in prose must be inside math notation.
- Triage reason: "Example 1" has a bare number in prose; the rule says wrap every prose number in math.

### 4. `lesson-comprehension-skills-main-idea|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A paragraph can include transitions, qualifications, counterpoints, definitions, or conclusions that serve the larger development of the idea.
- Problem: This sentence uses several abstract or uncommon terms at once, including "qualifications" and "counterpoints," making the teaching prose harder than the required Grade 5 simple-English standard.
- Triage reason: Qualifications and counterpoints are hard words for Grade 5; use plain words.

### 5. `lesson-comprehension-skills-main-idea|L05|0`
- Rule: L05
- Fix size: small
- Quote:
> "Reading fiction offers benefits beyond simple entertainment. Studies suggest it can improve empathy by exposing readers to different perspectives. It also strengthens vocabulary and comprehension through exposure to varied language. Many readers also use fiction for relaxation."
- Problem: Example 1 gives only the passage and then a solution. It does not provide an authentic exam-style question stem telling the student what to identify.
- Triage reason: Example 1 has no question stem; add one such as asking for the main idea.

### 6. `lesson-comprehension-skills-main-idea|L05|1`
- Rule: L05
- Fix size: small
- Quote:
> "The coach arrived an hour before practice to set up equipment. She stayed late after games to review footage with players. On weekends, she checked on their academic progress."
- Problem: Example 2 likewise omits the exam-style question itself, so the worked example does not model realistic target-exam wording.
- Triage reason: Example 2 has no question stem; add one asking for the main idea.

## CSE teaching to add

### 1. `reading-comprehension-comprehension-skills#73`
- Facet: Filipino: outline read text and explain logical relationships
- Verdict: absent
- Tier: curriculum
- Missing ideas:
  - Filipino outline production, cohesive links and logical-relationship explanation.

### 2. `reading-comprehension-comprehension-skills#77`
- Facet: Paragraph arrangement versus event chronology and main-point recognition
- Verdict: thin
- Tier: official
- Missing ideas:
  - Owned eight-body topic does not model arranging a complete scrambled paragraph or creating a paragraph; English transfer does not teach Filipino cohesive connectors.

## Optional, fix only if editing that passage anyway

- `lesson-comprehension-skills-main-idea|L18|1` (L18): The only implied-main-idea example is a very short three-sentence passage with one clear pattern. There is no harder worked case using multiple paragraphs or competing emphasis, so the examples do not ramp through the important implied-main-idea variation to target-exam difficulty. Reason: A harder multi-paragraph implied case would help, but the lesson is short and one clean case is defensible.

## Figures

None.

## Rules cited

| B08 | Maths notation: `\dfrac` at top level, numbers in prose inside `$...$`, no `\( \)` or `\[ \]` | Minor | Search the text | LSG: Math notation; `AGENTS.md`: Maths in content |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L05 | Example questions use exam wording and supply necessary problem-specific givens without supplying tested knowledge; solutions use simple language | Major | Check example stems against the expected-knowledge rule and compare wording with solutions | LSG: Voice, Examples section |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
